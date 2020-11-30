using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Tgstation.Server.Api.Models;
using Tgstation.Server.Client;
using Tgstation.Server.Client.Components;

namespace SetupProgram
{
	class Program
	{
		public static async Task<int> Main()
		{
			var repo = Environment.GetEnvironmentVariable("TGS_REPO")?.Trim();
			if (String.IsNullOrWhiteSpace(repo))
			{
				Console.WriteLine("ERROR: Environment variable TGS_REPO not set to a git url!");
				return 1;
			}

			var byondStr = Environment.GetEnvironmentVariable("TGS_BYOND")?.Trim();
			if (String.IsNullOrWhiteSpace(byondStr) || !Version.TryParse(byondStr, out Version byond) || byond.Build != -1)
			{
				Console.WriteLine("ERROR: Environment variable TGS_BYOND not set to a valid BYOND version!");
				return 2;
			}

			var clientFactory = new ServerClientFactory(new ProductHeaderValue("LinuxOneShot", "1.0.0"));

			IServerClient serverClient = null;
			Instance instance = null;
			IInstanceClient instanceClient;
			void CreateInstanceClient() => instanceClient = serverClient.Instances.CreateClient(instance);

			async Task CreateAdminClient()
			{
				Console.WriteLine("Attempting to reestablish connection to TGS (120s max wait)...");
				var giveUpAt = DateTimeOffset.Now.AddSeconds(60);
				do
				{
					try
					{
						serverClient = await clientFactory.CreateServerClient(new Uri("http://tgs:80"), User.AdminName, User.DefaultAdminPassword, default, default);
						if (instance != null)
							CreateInstanceClient();
						break;
					}
					catch (HttpRequestException)
					{
						//migrating, to be expected
						if (DateTimeOffset.Now > giveUpAt)
							throw;
						await Task.Delay(TimeSpan.FromSeconds(1));
					}
					catch (ServiceUnavailableException)
					{
						// migrating, to be expected
						if (DateTimeOffset.Now > giveUpAt)
							throw;
						await Task.Delay(TimeSpan.FromSeconds(1));
					}
				} while (true);
			}

			async Task WaitForJob(Job originalJob, CancellationToken cancellationToken)
			{
				var job = originalJob;
				int? lastProgress = null;
				do
				{
					try
					{
						await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken).ConfigureAwait(false);
						job = await instanceClient.Jobs.GetId(job, cancellationToken).ConfigureAwait(false);
						if (job.Progress != lastProgress)
						{
							Console.WriteLine($"Progress: {job.Progress}");
							lastProgress = job.Progress;
						}
					}
					catch (UnauthorizedException)
					{
						await CreateAdminClient();
					}
				}
				while (!job.StoppedAt.HasValue);

				if (job.ExceptionDetails != null)
				{
					Console.WriteLine(job.ExceptionDetails);
					Environment.Exit(3);
				}
			}

			await CreateAdminClient();

			Console.WriteLine("Listing instances...");
			var instances = await serverClient.Instances.List(default);
			if (instances.Any())
			{
				Console.WriteLine("One or more instances already exist, aborting!");
				return 3;
			}

			Console.WriteLine("Creating instance...");
			instance = await serverClient.Instances.CreateOrAttach(new Instance
			{
				ConfigurationType = ConfigurationType.HostWrite,
				Name = "AutoInstance",
				Path = "/tgs4_instances/main"
			}, default);

			Console.WriteLine("Onlining instance...");
			instance.Online = true;
			instance = await serverClient.Instances.Update(instance, default);

			CreateInstanceClient();

			Console.WriteLine("Starting repo clone...");
			var cloneJobTask = instanceClient.Repository.Clone(new Repository
			{
				Origin = repo
			}, default);

			Console.WriteLine($"Starting BYOND install {byond}...");
			var byondInstallTask = instanceClient.Byond.SetActiveVersion(new Byond
			{
				Version = byond
			}, default);

			Console.WriteLine("Setting DD Settings to Ultrasafe|Startup Timeout=120|AutoStart=true|HeartbeatSeconds=120...");
			var ddUpdateTask = instanceClient.DreamDaemon.Update(new DreamDaemon
			{
				AutoStart = true,
				SecurityLevel = DreamDaemonSecurity.Ultrasafe,
				HeartbeatSeconds = 120,
				StartupTimeout = 120
			}, default);

			Console.WriteLine("Setting API validation security level to trusted...");
			var dmUpdateTask = instanceClient.DreamMaker.Update(new DreamMaker
			{
				ApiValidationSecurityLevel = DreamDaemonSecurity.Trusted
			}, default);

			Console.WriteLine("Uploading EventScripts/PreCompile.sh...");
			var configurationTask = instanceClient.Configuration.Write(new ConfigurationFile
			{
				Path = "/EventScripts/PreCompile.sh",
				Content = File.ReadAllBytes("PreCompile.sh")
			}, default);

			Console.WriteLine("Creating GameStaticFiles/data...");
			var configTask2 = instanceClient.Configuration.CreateDirectory(new ConfigurationFile
			{
				IsDirectory = true,
				Path = "/GameStaticFiles/data"
			}, default);

			Console.WriteLine("Waiting for previous requests...");

			await Task.WhenAll(
				cloneJobTask,
				byondInstallTask,
				ddUpdateTask,
				dmUpdateTask,
				configurationTask,
				configTask2);

			Console.WriteLine("Waiting for BYOND install...");

			var installJob = await byondInstallTask;
			await WaitForJob(installJob.InstallJob, default);

			Console.WriteLine("Waiting for Repo clone...");

			var cloneJob = await cloneJobTask;
			await WaitForJob(cloneJob.ActiveJob, default);

			await CreateAdminClient();

			Console.WriteLine("Starting deployment...");
			var deployJobTask = instanceClient.DreamMaker.Compile(default);

			Console.WriteLine("Enabling auto updates every hour...");
			instance.AutoUpdateInterval = 60;
			await serverClient.Instances.Update(instance, default);

			Console.WriteLine("Waiting for deployment job...");
			var deployJob = await deployJobTask;
			await WaitForJob(deployJob, default);

			await CreateAdminClient();

			Console.WriteLine("Launching watchdog...");
			var launchJob = await instanceClient.DreamDaemon.Start(default);
			await WaitForJob(launchJob, default);

			Console.WriteLine("Complete!");
			return 0;
		}
	}
}
