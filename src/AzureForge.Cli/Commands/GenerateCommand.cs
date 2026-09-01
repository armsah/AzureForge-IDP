using AzureForge.Cli.Generation;
using AzureForge.Cli.Parsing;
using AzureForge.Cli.Validation;
using System.CommandLine;

namespace AzureForge.Cli.Commands;

public static class GenerateCommand
{
    public static Command Create()
    {
        var specArgument = new Argument<FileInfo>("spec")
        {
            Description = "Path to an AzureForge YAML service specification."
        };

        var outputOption = new Option<FileInfo>("--output")
        {
            Description = "Path for the generated Terraform variable JSON file.",
            Required = true
        };

        var command = new Command(
            "generate",
            "Generate deterministic Terraform variables from an AzureForge service specification.")
        {
            specArgument,
            outputOption
        };

        command.SetAction(parseResult =>
        {
            var specFile = parseResult.GetValue(specArgument);
            var outputFile = parseResult.GetValue(outputOption);

            if (specFile is null)
            {
                Console.Error.WriteLine(
                    "error: service specification path is required.");

                return ExitCodes.InvalidArguments;
            }

            if (outputFile is null)
            {
                Console.Error.WriteLine(
                    "error: output path is required.");

                return ExitCodes.InvalidArguments;
            }

            if (!specFile.Exists)
            {
                Console.Error.WriteLine(
                    $"error: file not found: {specFile.FullName}");

                return ExitCodes.FileNotFound;
            }

            var parser = new ServiceSpecParser();
            var parseResultValue = parser.Parse(specFile.FullName);

            if (!parseResultValue.IsSuccess)
            {
                Console.Error.WriteLine(
                    $"error: invalid YAML: {parseResultValue.Error}");

                return ExitCodes.InvalidSpec;
            }

            var validator = new ServiceSpecValidator();
            var validation = validator.Validate(parseResultValue.Spec!);

            if (!validation.IsValid)
            {
                Console.Error.WriteLine(
                    $"Service specification is invalid ({validation.Errors.Count} error(s)):");

                foreach (var error in validation.Errors)
                {
                    Console.Error.WriteLine(
                        $"  - {error.Path}: {error.Message}");
                }

                return ExitCodes.InvalidSpec;
            }

            var generator = new TerraformDesiredStateGenerator();
            var desiredState = generator.Generate(parseResultValue.Spec!);

            var serializer = new TerraformDesiredStateSerializer();
            var content = serializer.Serialize(desiredState);

            if (outputFile.Directory is not null)
            {
                outputFile.Directory.Create();
            }

            File.WriteAllText(outputFile.FullName, content);

            Console.WriteLine(
                $"Generated Terraform variables: {outputFile.FullName}");

            return ExitCodes.Success;
        });

        return command;
    }
}