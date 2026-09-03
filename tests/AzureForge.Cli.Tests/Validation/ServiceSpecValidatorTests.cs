using AzureForge.Cli.Models;
using AzureForge.Cli.Validation;

namespace AzureForge.Cli.Tests.Validation;

public sealed class ServiceSpecValidatorTests
{
    private readonly ServiceSpecValidator _validator = new();

    [Fact]
    public void Validate_ValidGoldenPathSpec_ReturnsValid()
    {
        var result = _validator.Validate(CreateValidSpec());

        Assert.True(result.IsValid);
        Assert.Empty(result.Errors);
    }

    [Fact]
    public void Validate_UnsupportedRuntime_ReturnsError()
    {
        var spec = CreateValidSpec();
        spec = WithRuntime(spec, language: "node");

        var result = _validator.Validate(spec);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, error => error.Path == "runtime.language");
    }

    [Fact]
    public void Validate_WorkloadIdentityDisabled_ReturnsError()
    {
        var spec = CreateValidSpec();
        spec = Copy(spec, security: new SecurityDefinition
        {
            PublicIngress = false,
            WorkloadIdentity = false
        });

        var result = _validator.Validate(spec);

        Assert.Contains(result.Errors, error => error.Path == "security.workloadIdentity");
    }

    [Fact]
    public void Validate_MinReplicasGreaterThanMaxReplicas_ReturnsError()
    {
        var spec = CreateValidSpec();
        spec = Copy(spec, compute: new ComputeDefinition
        {
            Type = "container-apps",
            MinReplicas = 6,
            MaxReplicas = 5
        });

        var result = _validator.Validate(spec);

        Assert.Contains(result.Errors, error => error.Path == "compute");
    }

    [Fact]
    public void Validate_DuplicateServiceBusQueues_ReturnsError()
    {
        var spec = CreateValidSpec();
        spec = Copy(spec, messaging: new MessagingDefinition
        {
            ServiceBus = new ServiceBusDefinition
            {
                Queues = ["price-update", "PRICE-UPDATE"]
            }
        });

        var result = _validator.Validate(spec);

        Assert.Contains(result.Errors, error => error.Path == "messaging.serviceBus.queues");
    }

    [Fact]
    public void Validate_LifecycleTtlBelowMinimum_ReturnsInvalid()
    {
        var spec = CreateValidSpec();
        spec = Copy(spec, lifecycle: new LifecycleDefinition
        {
            TtlDays = 0
        });

        var result = _validator.Validate(spec);

        Assert.False(result.IsValid);
        Assert.Contains(
            result.Errors,
            error =>
                error.Path == "lifecycle.ttlDays" &&
                error.Message == "must be greater than or equal to 1.");
    }

    [Fact]
    public void Validate_LifecycleTtlAboveMaximum_ReturnsInvalid()
    {
        var spec = CreateValidSpec();
        spec = Copy(spec, lifecycle: new LifecycleDefinition
        {
            TtlDays = 91
        });

        var result = _validator.Validate(spec);

        Assert.False(result.IsValid);
        Assert.Contains(
            result.Errors,
            error =>
                error.Path == "lifecycle.ttlDays" &&
                error.Message == "must not exceed 90 days.");
    }

    private static ServiceSpec CreateValidSpec() => new()
    {
        Service = new ServiceDefinition
        {
            Name = "pricing-api",
            Owner = "commerce-team",
            Criticality = "medium"
        },
        Runtime = new RuntimeDefinition
        {
            Language = "dotnet",
            Version = "10"
        },
        Compute = new ComputeDefinition
        {
            Type = "container-apps",
            MinReplicas = 0,
            MaxReplicas = 5
        },
        Data = new DataDefinition
        {
            Postgres = true
        },
        Messaging = new MessagingDefinition
        {
            ServiceBus = new ServiceBusDefinition
            {
                Queues = ["price-update"]
            }
        },
        Security = new SecurityDefinition
        {
            PublicIngress = false,
            WorkloadIdentity = true
        },
        Observability = new ObservabilityDefinition
        {
            AppInsights = true,
            Alerts = "standard"
        },
        Kubernetes = new KubernetesDefinition
        {
            Namespace = new KubernetesNamespaceDefinition
            {
                Enabled = false
            }
        },
        Cost = new CostDefinition
        {
            MonthlyBudgetEur = 80
        },
        Lifecycle = new LifecycleDefinition
        {
            TtlDays = 30
        }
    };

    private static ServiceSpec WithRuntime(ServiceSpec spec, string language) =>
        Copy(spec, runtime: new RuntimeDefinition
        {
            Language = language,
            Version = spec.Runtime.Version
        });

    private static ServiceSpec Copy(
        ServiceSpec spec,
        RuntimeDefinition? runtime = null,
        ComputeDefinition? compute = null,
        MessagingDefinition? messaging = null,
        SecurityDefinition? security = null,
        LifecycleDefinition? lifecycle = null) =>
        new()
        {
            Service = spec.Service,
            Runtime = runtime ?? spec.Runtime,
            Compute = compute ?? spec.Compute,
            Data = spec.Data,
            Messaging = messaging ?? spec.Messaging,
            Security = security ?? spec.Security,
            Observability = spec.Observability,
            Kubernetes = spec.Kubernetes,
            Cost = spec.Cost,
            Lifecycle = lifecycle ?? spec.Lifecycle
        };
}
