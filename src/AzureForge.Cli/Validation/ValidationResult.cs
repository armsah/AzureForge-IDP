namespace AzureForge.Cli.Validation;

public sealed record ValidationError(string Path, string Message);

public sealed class ValidationResult
{
    public ValidationResult(IReadOnlyList<ValidationError> errors)
    {
        Errors = errors;
    }

    public IReadOnlyList<ValidationError> Errors { get; }

    public bool IsValid => Errors.Count == 0;
}
