using System.Text.RegularExpressions;
using AzureForge.Cli.Models;

namespace AzureForge.Cli.Validation;

public sealed partial class ServiceSpecValidator
{
    private static readonly HashSet<string> AllowedCriticalities =
        new(StringComparer.OrdinalIgnoreCase) { "low", "medium", "high" };

    public ValidationResult Validate(ServiceSpec spec)
    {
        var errors = new List<ValidationError>();

        ValidateService(spec.Service, errors);
        ValidateRuntime(spec.Runtime, errors);
        ValidateCompute(spec.Compute, errors);
        ValidateMessaging(spec.Messaging, errors);
        ValidateSecurity(spec.Security, errors);
        ValidateObservability(spec.Observability, errors);
        ValidateCost(spec.Cost, errors);
        ValidateLifecycle(spec.Lifecycle, errors);

        return new ValidationResult(errors);
    }

    private static void ValidateLifecycle(
    LifecycleDefinition lifecycle,
    List<ValidationError> errors)
    {
        if (lifecycle.TtlDays < 1)
        {
            errors.Add(new("lifecycle.ttlDays", "must be greater than or equal to 1."));
        }
        else if (lifecycle.TtlDays > 90)
        {
            errors.Add(new("lifecycle.ttlDays", "must not exceed 90 days."));
        }
    }

    private static void ValidateService(ServiceDefinition service, List<ValidationError> errors)
    {
        if (string.IsNullOrWhiteSpace(service.Name))
        {
            errors.Add(new("service.name", "is required."));
        }
        else if (!ServiceNameRegex().IsMatch(service.Name))
        {
            errors.Add(new(
                "service.name",
                "must be 3-30 characters, start with a lowercase letter, and contain only lowercase letters, digits, or hyphens."));
        }

        if (string.IsNullOrWhiteSpace(service.Owner))
        {
            errors.Add(new("service.owner", "is required."));
        }

        if (!AllowedCriticalities.Contains(service.Criticality))
        {
            errors.Add(new("service.criticality", "must be one of: low, medium, high."));
        }
    }

    private static void ValidateRuntime(RuntimeDefinition runtime, List<ValidationError> errors)
    {
        if (!string.Equals(runtime.Language, "dotnet", StringComparison.OrdinalIgnoreCase))
        {
            errors.Add(new("runtime.language", "P1 supports only 'dotnet'."));
        }

        if (runtime.Version != "10")
        {
            errors.Add(new("runtime.version", "P1 supports only .NET version '10'."));
        }
    }

    private static void ValidateCompute(ComputeDefinition compute, List<ValidationError> errors)
    {
        if (!string.Equals(compute.Type, "container-apps", StringComparison.OrdinalIgnoreCase))
        {
            errors.Add(new("compute.type", "P1 supports only 'container-apps'."));
        }

        if (compute.MinReplicas < 0)
        {
            errors.Add(new("compute.minReplicas", "must be greater than or equal to 0."));
        }

        if (compute.MaxReplicas < 1)
        {
            errors.Add(new("compute.maxReplicas", "must be greater than or equal to 1."));
        }

        if (compute.MaxReplicas > 10)
        {
            errors.Add(new("compute.maxReplicas", "must not exceed the P1 catalog limit of 10."));
        }

        if (compute.MinReplicas > compute.MaxReplicas)
        {
            errors.Add(new("compute", "minReplicas must be less than or equal to maxReplicas."));
        }
    }

    private static void ValidateMessaging(MessagingDefinition messaging, List<ValidationError> errors)
    {
        if (messaging.ServiceBus is null)
        {
            return;
        }

        var queues = messaging.ServiceBus.Queues;

        if (queues.Any(string.IsNullOrWhiteSpace))
        {
            errors.Add(new("messaging.serviceBus.queues", "queue names cannot be empty."));
        }

        if (queues.Count != queues.Distinct(StringComparer.OrdinalIgnoreCase).Count())
        {
            errors.Add(new("messaging.serviceBus.queues", "queue names must be unique."));
        }
    }

    private static void ValidateSecurity(SecurityDefinition security, List<ValidationError> errors)
    {
        if (!security.WorkloadIdentity)
        {
            errors.Add(new(
                "security.workloadIdentity",
                "must be true; managed workload identity is mandatory on the golden path."));
        }
    }

    private static void ValidateObservability(
        ObservabilityDefinition observability,
        List<ValidationError> errors)
    {
        if (!observability.AppInsights)
        {
            errors.Add(new(
                "observability.appInsights",
                "must be true; Application Insights is required by the golden path."));
        }

        if (!string.Equals(observability.Alerts, "standard", StringComparison.OrdinalIgnoreCase))
        {
            errors.Add(new("observability.alerts", "P1 supports only the 'standard' alert profile."));
        }
    }

    private static void ValidateCost(CostDefinition cost, List<ValidationError> errors)
    {
        if (cost.MonthlyBudgetEur <= 0)
        {
            errors.Add(new("cost.monthlyBudgetEur", "must be greater than 0."));
        }
    }

    [GeneratedRegex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", RegexOptions.CultureInvariant)]
    private static partial Regex ServiceNameRegex();
}
