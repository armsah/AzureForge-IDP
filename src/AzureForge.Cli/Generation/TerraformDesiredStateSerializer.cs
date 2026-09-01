using System.Text.Json;
using System.Text.Json.Serialization;

namespace AzureForge.Cli.Generation;

public sealed class TerraformDesiredStateSerializer
{
    private static readonly JsonSerializerOptions Options = new()
    {
        WriteIndented = true,
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never
    };

    public string Serialize(TerraformDesiredState desiredState)
    {
        ArgumentNullException.ThrowIfNull(desiredState);

        return JsonSerializer.Serialize(desiredState, Options) + Environment.NewLine;
    }
}