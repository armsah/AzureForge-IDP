using AzureForge.Cli.Parsing;
using AzureForge.Cli.Validation;
using System.CommandLine;

namespace AzureForge.Cli.Commands;

public static class ValidateCommand
{
    public static Command Create()
    {
        var specArgument = new Argument<FileInfo>("spec")
        {
            Description = "Path to an AzureForge YAML service specification."
        };

        var command = new Command("validate", "Validate an AzureForge service specification.")
        {
            specArgument
        };

        command.SetAction(parseResult =>
        {
            var specFile = parseResult.GetValue(specArgument);

            if (specFile is null)
            {
                Console.Error.WriteLine("error: service specification path is required.");
                return ExitCodes.InvalidArguments;
            }

            if (!specFile.Exists)
            {
                Console.Error.WriteLine($"error: file not found: {specFile.FullName}");
                return ExitCodes.FileNotFound;
            }

            var parser = new ServiceSpecParser();
            var parseResultValue = parser.Parse(specFile.FullName);

            if (!parseResultValue.IsSuccess)
            {
                Console.Error.WriteLine($"error: invalid YAML: {parseResultValue.Error}");
                return ExitCodes.InvalidSpec;
            }

            var validator = new ServiceSpecValidator();
            var validation = validator.Validate(parseResultValue.Spec!);

            if (!validation.IsValid)
            {
                Console.Error.WriteLine($"Service specification is invalid ({validation.Errors.Count} error(s)):");
                foreach (var error in validation.Errors)
                {
                    Console.Error.WriteLine($"  - {error.Path}: {error.Message}");
                }

                return ExitCodes.InvalidSpec;
            }

            Console.WriteLine($"Valid AzureForge service specification: {parseResultValue.Spec!.Service.Name}");
            return ExitCodes.Success;
        });

        return command;
    }
}
