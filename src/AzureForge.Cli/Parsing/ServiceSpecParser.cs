using AzureForge.Cli.Models;
using YamlDotNet.Core;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace AzureForge.Cli.Parsing;

public sealed class ServiceSpecParser
{
    private readonly IDeserializer _deserializer;

    public ServiceSpecParser()
    {
        _deserializer = new DeserializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
    }

    public ServiceSpecParseResult Parse(string path)
    {
        try
        {
            var yaml = File.ReadAllText(path);
            var spec = _deserializer.Deserialize<ServiceSpec>(yaml);

            if (spec is null)
            {
                return ServiceSpecParseResult.Failure("document is empty.");
            }

            return ServiceSpecParseResult.Success(spec);
        }
        catch (YamlException ex)
        {
            return ServiceSpecParseResult.Failure(ex.Message);
        }
        catch (IOException ex)
        {
            return ServiceSpecParseResult.Failure(ex.Message);
        }
        catch (UnauthorizedAccessException ex)
        {
            return ServiceSpecParseResult.Failure(ex.Message);
        }
    }
}

public sealed record ServiceSpecParseResult(ServiceSpec? Spec, string? Error)
{
    public bool IsSuccess => Spec is not null && Error is null;

    public static ServiceSpecParseResult Success(ServiceSpec spec) => new(spec, null);

    public static ServiceSpecParseResult Failure(string error) => new(null, error);
}
