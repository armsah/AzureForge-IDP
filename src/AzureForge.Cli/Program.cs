using AzureForge.Cli.Commands;
using System.CommandLine;

var rootCommand = new RootCommand("AzureForge internal developer platform CLI");

rootCommand.Subcommands.Add(ValidateCommand.Create());

return rootCommand.Parse(args).Invoke();
