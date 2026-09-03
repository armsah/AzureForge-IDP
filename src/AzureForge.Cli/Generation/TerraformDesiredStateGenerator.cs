using AzureForge.Cli.Models;

namespace AzureForge.Cli.Generation;

public sealed class TerraformDesiredStateGenerator
{
    private const string DefaultEnvironment = "dev";
    private const string DefaultLocation = "westeurope";

    public TerraformDesiredState Generate(ServiceSpec spec)
    {
        ArgumentNullException.ThrowIfNull(spec);

        var serviceName = spec.Service.Name;
        var team = spec.Service.Owner;

        var queues = spec.Messaging.ServiceBus?.Queues
            .OrderBy(queue => queue, StringComparer.Ordinal)
            .ToArray()
            ?? [];

        var tags = new SortedDictionary<string, string>(StringComparer.Ordinal)
        {
            ["criticality"] = spec.Service.Criticality,
            ["environment"] = DefaultEnvironment,
            ["managed-by"] = "azureforge",
            ["service"] = serviceName,
            ["team"] = team
        };

        return new TerraformDesiredState(
            ServiceName: serviceName,
            Team: team,
            Environment: DefaultEnvironment,
            Location: DefaultLocation,
            ResourceGroupName: $"rg-{serviceName}-{DefaultEnvironment}-weu",
            ManagedIdentityName: $"id-{serviceName}-{DefaultEnvironment}",
            LogAnalyticsWorkspaceName: $"log-{serviceName}-{DefaultEnvironment}-weu",
            ApplicationInsightsName: $"appi-{serviceName}-{DefaultEnvironment}",
            RuntimeLanguage: spec.Runtime.Language,
            RuntimeVersion: spec.Runtime.Version,
            ComputeType: spec.Compute.Type,
            MinReplicas: spec.Compute.MinReplicas,
            MaxReplicas: spec.Compute.MaxReplicas,
            PostgresEnabled: spec.Data.Postgres,
            ServiceBusQueues: queues,
            PublicIngress: spec.Security.PublicIngress,
            WorkloadIdentity: spec.Security.WorkloadIdentity,
            ApplicationInsightsEnabled: spec.Observability.AppInsights,
            Alerts: spec.Observability.Alerts,
            MonthlyBudgetEur: spec.Cost.MonthlyBudgetEur,
            EnvironmentTtlDays: spec.Lifecycle.TtlDays,
            AksNamespaceEnabled: spec.Kubernetes.Namespace.Enabled,
            AksNamespaceName: spec.Kubernetes.Namespace.Enabled ? serviceName : null,
            Tags: tags);
    }
}