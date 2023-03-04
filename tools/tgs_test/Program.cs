// Simple app meant to test tgstation's TGS integration given a fresh TGS install with the default account
//
// Args: Repository Owner/Name, TGS instance path, TGS API port, Pushed commit hash (For .tgs.yml access), GitHub Token

using System.Reflection;
using System.Text;

using Octokit;
using Tgstation.Server.Api;
using Tgstation.Server.Api.Models.Request;
using Tgstation.Server.Api.Models;
using Tgstation.Server.Api.Models.Response;
using Tgstation.Server.Client;
using YamlDotNet.Serialization.NamingConventions;
using YamlDotNet.Serialization;

Console.WriteLine("Parsing args...");

const int ExpectedArgs = 5;
if (args.Length != ExpectedArgs)
{
	Console.WriteLine($"Incorrect number of args: {args.Length}. Expected {ExpectedArgs}");
	return 1;
}

var repoSlug = args[0];
var instancePath = args[1];
var tgsApiPortString = args[2];
var pushedCommitHash = args[3];
var gitHubToken = args[4];

var repoSlugSplits = repoSlug.Split('/', StringSplitOptions.RemoveEmptyEntries);
if(repoSlugSplits.Length != 2)
{
	Console.WriteLine($"Invalid repo slug: {repoSlug}");
	return 2;
}

var repoOwner = repoSlugSplits[0];
var repoName = repoSlugSplits[1];

if (!ushort.TryParse(tgsApiPortString, out var tgsApiPort))
{
	Console.WriteLine($"Invalid port: {tgsApiPortString}");
	return 3;
}

try
{
	Console.WriteLine($"Retrieving .tgs.yml (@{pushedCommitHash})...");
	var assemblyName = Assembly.GetExecutingAssembly().GetName();
	var gitHubClient = new GitHubClient(
		new ProductHeaderValue(
			assemblyName.Name,
			assemblyName.Version!.Semver().ToString()))
	{
		Credentials = new Credentials(gitHubToken)
	};

	var tgsYmlContent = await gitHubClient.Repository.Content.GetRawContentByRef(repoOwner, repoName, ".tgs.yml", pushedCommitHash);
	var tgsYmlString = Encoding.UTF8.GetString(tgsYmlContent);

	var deserializer = new DeserializerBuilder()
		.WithNamingConvention(new UnderscoredNamingConvention())
		.Build();

	var tgsYml = deserializer.Deserialize<TgsYml>(tgsYmlString);

	const int SupportedTgsYmlVersion = 1;
	if (tgsYml.Version != SupportedTgsYmlVersion)
	{
		Console.WriteLine($"Unsupported .tgs.yml version: {tgsYml.Version}. Expected {SupportedTgsYmlVersion}");
		return 4;
	}

	var targetByondVersion = Version.Parse(tgsYml.Byond);

	Console.WriteLine($".tgs.yml Security level: {tgsYml.Security}");

	Console.WriteLine("Downloading and checking BYOND version in dependencies.sh...");
	var dependenciesShContent = await gitHubClient.Repository.Content.GetRawContentByRef(repoOwner, repoName, "dependencies.sh", pushedCommitHash);
	var dependenciesSh = Encoding.UTF8.GetString(dependenciesShContent);
	var dependenciesShLines = dependenciesSh.Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

	int dependenciesShByondMajor = 0;
	int dependenciesShByondMinor = 0;
	foreach(var dependenciesShLine in dependenciesShLines)
	{
		var trimmedLine = dependenciesShLine.Trim();
		var lineSplit = trimmedLine.Split('=', StringSplitOptions.RemoveEmptyEntries);
		if (lineSplit.Length != 2)
			continue;

		if (lineSplit[0].EndsWith("BYOND_MAJOR"))
			dependenciesShByondMajor = Int32.Parse(lineSplit[1]);
		else if (lineSplit[0].EndsWith("BYOND_MINOR"))
			dependenciesShByondMinor = Int32.Parse(lineSplit[1]);
	}

	var dependenciesByondVersion = new Version(dependenciesShByondMajor, dependenciesShByondMinor);
	if(dependenciesByondVersion != targetByondVersion)
	{
		Console.WriteLine($".tgs.yml BYOND version does not match dependencies.sh! Expected {dependenciesByondVersion} got {targetByondVersion}!");
		return 5;
	}

	// Connect to TGS
	var clientFactory = new ServerClientFactory(
		new System.Net.Http.Headers.ProductHeaderValue(
			assemblyName.Name!,
			assemblyName.Version!.Semver().ToString()));

	var tgsApiUrl = new Uri($"http://127.0.0.1:{tgsApiPort}");
	var giveUpAt = DateTimeOffset.UtcNow.AddMinutes(2);
	IServerClient client;
	for (var I = 1; ; ++I)
	{
		try
		{
			Console.WriteLine($"TGS Connection Attempt {I}...");
			client = await clientFactory.CreateFromLogin(
				tgsApiUrl,
				DefaultCredentials.AdminUserName,
				DefaultCredentials.DefaultAdminUserPassword);
			break;
		}
		catch (HttpRequestException)
		{
			//migrating, to be expected
			if (DateTimeOffset.UtcNow > giveUpAt)
				throw;
			await Task.Delay(TimeSpan.FromSeconds(1));
		}
		catch (ServiceUnavailableException)
		{
			// migrating, to be expected
			if (DateTimeOffset.UtcNow > giveUpAt)
				throw;
			await Task.Delay(TimeSpan.FromSeconds(1));
		}
	}


	Console.WriteLine("Getting TGS information...");

	var tgsInfo = await client.ServerInformation(default);

	var scriptDictionaryToUse = tgsInfo.WindowsHost ? tgsYml.WindowsScripts : tgsYml.LinuxScripts;
	Console.WriteLine($"Downloading {scriptDictionaryToUse.Count} EventScripts...");

	var scriptDownloadTasks = new Dictionary<string, Task<byte[]>>();
	foreach (var scriptKvp in scriptDictionaryToUse)
	{
		scriptDownloadTasks.Add(
			scriptKvp.Key,
			gitHubClient.Repository.Content.GetRawContentByRef(repoOwner, repoName, scriptKvp.Value, pushedCommitHash));
	}

	await Task.WhenAll(scriptDownloadTasks.Values);

	Console.WriteLine("Setting up TGS instance...");

	var instance = await client.Instances.CreateOrAttach(
		new InstanceCreateRequest
		{
			ConfigurationType = ConfigurationType.HostWrite,
			Name = "tgstation",
			Path = instancePath
		},
		default);

	instance = await client.Instances.Update(
		new InstanceUpdateRequest
		{
			Id = instance.Id,
			Online = true
		},
		default);

	var instanceClient = client.Instances.CreateClient(instance);

	Console.WriteLine("Cloning main branch of repo...");
	var repoCloneJob = await instanceClient.Repository.Clone(
		new RepositoryCreateRequest
		{
			Origin = new Uri($"http://github.com/{repoSlug}"),
			UpdateSubmodules = true,
			AccessUser = "Testing",
			AccessToken = gitHubToken
		},
		default);

	Console.WriteLine("Installing BYOND...");
	var byondInstallJob = await instanceClient.Byond.SetActiveVersion(
		new ByondVersionRequest
		{
			Version = targetByondVersion
		},
		null,
		default);

	Console.WriteLine("Updating server/compiler settings...");
	await instanceClient.DreamMaker.Update(
		new DreamMakerRequest
		{
			ApiValidationSecurityLevel = tgsYml.Security
		},
		default);

	await instanceClient.DreamDaemon.Update(
		new DreamDaemonRequest
		{
			SecurityLevel = tgsYml.Security,
			Visibility = DreamDaemonVisibility.Invisible
		},
		default);

	Console.WriteLine("Uploading EventScripts...");
	var configurationUploadTasks = new List<Task<ConfigurationFileResponse>>();
	foreach (var scriptDownloadKvp in scriptDownloadTasks)
	{
		var scriptContent = await scriptDownloadKvp.Value;

		var memoryStream = new MemoryStream(scriptContent);
		configurationUploadTasks.Add(
			instanceClient.Configuration.Write(new ConfigurationFileRequest
			{
				Path = $"EventScripts/{scriptDownloadKvp.Key}"
			},
			memoryStream,
			default));
	}

	await Task.WhenAll(configurationUploadTasks);

	Console.WriteLine("Creating GameStaticFiles structure...");
	var staticFileDownloadTasks = new Dictionary<string, Dictionary<string, Task<byte[]>>>();
	foreach (var staticFile in tgsYml.StaticFiles)
	{
		if (!staticFile.Populate)
		{
			Console.WriteLine($"Creating empty directory GameStaticFiles/{staticFile.Name}...");
			await instanceClient.Configuration.CreateDirectory(new ConfigurationFileRequest
			{
				Path = $"GameStaticFiles/{staticFile.Name}"
			},
			default);
		}
		else
		{
			// not by ref here as we are relying on master being not broken
			Console.WriteLine($"Enumerating repo path {staticFile.Name}...");
			var repositoryFilesToUpload = new Queue<RepositoryContent>(await gitHubClient.Repository.Content.GetAllContents(repoOwner, repoName, staticFile.Name));
			while (repositoryFilesToUpload.Count != 0)
			{
				var repositoryFileToUpload = repositoryFilesToUpload.Dequeue();
				if (repositoryFileToUpload.Type == ContentType.File)
				{
					// serial because easier to track errors
					Console.WriteLine($"Transferring {repositoryFileToUpload.Path}...");
					var fileContent = await gitHubClient.Repository.Content.GetRawContent(repoOwner, repoName, repositoryFileToUpload.Path);
					using var memoryStream = new MemoryStream(fileContent);
					await instanceClient.Configuration.Write(new ConfigurationFileRequest
					{
						Path = $"GameStaticFiles/{repositoryFileToUpload.Path}"
					},
						memoryStream,
						default);
				}
				else
				{
					Console.WriteLine($"Enumerating repo path {repositoryFileToUpload.Path}...");
					var additionalFiles = await gitHubClient.Repository.Content.GetAllContents(repoOwner, repoName, repositoryFileToUpload.Path);
					foreach (var additionalFile in additionalFiles)
						repositoryFilesToUpload.Enqueue(additionalFile);
				}
			}
		}
	}

	async Task<bool> WaitForJob(JobResponse originalJob, int timeout)
	{
		Console.WriteLine($"Waiting for job \"{originalJob.Description}\"...");
		var job = originalJob;
		var previousProgress = job.Progress;
		do
		{
			if (job.Progress != previousProgress)
				Console.WriteLine($"Progress: {previousProgress = job.Progress}");

			await Task.Delay(TimeSpan.FromSeconds(1));
			job = await instanceClient!.Jobs.GetId(job, default);
			--timeout;
		}
		while (!job.StoppedAt.HasValue && timeout > 0);

		if (!job.StoppedAt.HasValue)
		{
			await instanceClient!.Jobs.Cancel(job, default);
			Console.WriteLine($"Timed out!");
			return false;
		}
		else if (job.ExceptionDetails != null)
		{
			Console.WriteLine($"Error: {job.ExceptionDetails}");
			return false;
		}

		return true;
	}

	if (!await WaitForJob(byondInstallJob.InstallJob!, 120))
		return 6;

	if (!await WaitForJob(repoCloneJob.ActiveJob!, 600))
		return 7;

	Console.WriteLine("Deploying...");
	var deploymentJob = await instanceClient.DreamMaker.Compile(default);
	if (!await WaitForJob(deploymentJob, 1800))
		return 8;

	Console.WriteLine("Launching...");
	var launchJob = await instanceClient.DreamDaemon.Start(default);
	if (!await WaitForJob(launchJob, 300))
		return 9;

	return 0;
}
catch (Exception ex)
{
	Console.WriteLine(ex);
	return 4;
}
