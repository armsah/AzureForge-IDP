using AzureForge.Cli.Generation;
using AzureForge.Cli.Parsing;

namespace AzureForge.Cli.Tests.Generation;

public sealed class TerraformDesiredStateGeneratorTests
{
    [Fact]
    public void PricingApi_GeneratesExpectedTerraformDesiredState()
    {
        var repositoryRoot = FindRepositoryRoot();

        var specPath = Path.Combine(
            repositoryRoot,
            "examples",
            "pricing-api.yaml");

        var goldenPath = Path.Combine(
            repositoryRoot,
            "tests",
            "AzureForge.Cli.Tests",
            "Fixtures",
            "Golden",
            "pricing-api.tfvars.json");

        var parser = new ServiceSpecParser();
        var parseResult = parser.Parse(specPath);

        Assert.True(parseResult.IsSuccess, parseResult.Error);
        Assert.NotNull(parseResult.Spec);

        var generator = new TerraformDesiredStateGenerator();
        var desiredState = generator.Generate(parseResult.Spec!);

        var serializer = new TerraformDesiredStateSerializer();
        var actual = NormalizeLineEndings(serializer.Serialize(desiredState));

        var expected = NormalizeLineEndings(
            File.ReadAllText(goldenPath));

        Assert.Equal(expected, actual);
    }

    [Fact]
    public void ServiceBusQueues_AreGeneratedInDeterministicOrder()
    {
        var repositoryRoot = FindRepositoryRoot();

        var specPath = Path.Combine(
            repositoryRoot,
            "examples",
            "pricing-api.yaml");

        var parser = new ServiceSpecParser();
        var parseResult = parser.Parse(specPath);

        Assert.True(parseResult.IsSuccess, parseResult.Error);
        Assert.NotNull(parseResult.Spec);

        var spec = parseResult.Spec!;

        spec.Messaging.ServiceBus!.Queues.Add("alpha-queue");
        spec.Messaging.ServiceBus.Queues.Add("zeta-queue");

        var generator = new TerraformDesiredStateGenerator();
        var desiredState = generator.Generate(spec);

        Assert.Equal(
            ["alpha-queue", "zeta-queue"],
            desiredState.ServiceBusQueues);
    }

    private static string NormalizeLineEndings(string value)
    {
        return value.Replace("\r\n", "\n");
    }

    private static string FindRepositoryRoot()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);

        while (directory is not null)
        {
            if (Directory.Exists(Path.Combine(directory.FullName, ".git")))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }

        throw new DirectoryNotFoundException(
            "Could not locate the AzureForge repository root.");
    }
}