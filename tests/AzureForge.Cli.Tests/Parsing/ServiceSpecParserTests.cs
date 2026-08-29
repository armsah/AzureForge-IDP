using AzureForge.Cli.Parsing;

namespace AzureForge.Cli.Tests.Parsing;

public sealed class ServiceSpecParserTests
{
    [Fact]
    public void Parse_ValidYaml_DeserializesServiceSpec()
    {
        var path = FixturePath("valid-pricing-api.yaml");

        var result = new ServiceSpecParser().Parse(path);

        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Spec);
        Assert.Equal("pricing-api", result.Spec.Service.Name);
        Assert.Equal("dotnet", result.Spec.Runtime.Language);
        Assert.Equal(5, result.Spec.Compute.MaxReplicas);
    }

    [Fact]
    public void Parse_MalformedYaml_ReturnsFailure()
    {
        var path = FixturePath("malformed.yaml");

        var result = new ServiceSpecParser().Parse(path);

        Assert.False(result.IsSuccess);
        Assert.Null(result.Spec);
        Assert.NotNull(result.Error);
    }

    private static string FixturePath(string fileName) =>
        Path.Combine(AppContext.BaseDirectory, "Fixtures", fileName);
}
