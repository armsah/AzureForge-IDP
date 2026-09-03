namespace AzureForge.Cli.Models;

public sealed class ServiceSpec
{
    public ServiceDefinition Service { get; init; } = new();
    public RuntimeDefinition Runtime { get; init; } = new();
    public ComputeDefinition Compute { get; init; } = new();
    public DataDefinition Data { get; init; } = new();
    public MessagingDefinition Messaging { get; init; } = new();
    public SecurityDefinition Security { get; init; } = new();
    public ObservabilityDefinition Observability { get; init; } = new();
    public CostDefinition Cost { get; init; } = new();
    public LifecycleDefinition Lifecycle { get; init; } = new();
}

public sealed class ServiceDefinition
{
    public string Name { get; init; } = string.Empty;
    public string Owner { get; init; } = string.Empty;
    public string Criticality { get; init; } = string.Empty;
}

public sealed class RuntimeDefinition
{
    public string Language { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
}

public sealed class ComputeDefinition
{
    public string Type { get; init; } = string.Empty;
    public int MinReplicas { get; init; }
    public int MaxReplicas { get; init; }
}

public sealed class DataDefinition
{
    public bool Postgres { get; init; }
}

public sealed class MessagingDefinition
{
    public ServiceBusDefinition? ServiceBus { get; init; }
}

public sealed class ServiceBusDefinition
{
    public List<string> Queues { get; init; } = [];
}

public sealed class SecurityDefinition
{
    public bool PublicIngress { get; init; }
    public bool WorkloadIdentity { get; init; }
}

public sealed class ObservabilityDefinition
{
    public bool AppInsights { get; init; }
    public string Alerts { get; init; } = string.Empty;
}

public sealed class CostDefinition
{
    public decimal MonthlyBudgetEur { get; init; }
}

public sealed class LifecycleDefinition
{
    public int TtlDays { get; init; }
}
