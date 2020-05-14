using System;
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

			Console.WriteLine("Uploading EventScripts/PostCompile.sh...");
			var configurationTask = instanceClient.Configuration.Write(new ConfigurationFile
			{
				Path = "/EventScripts/PreCompile.sh",
				Content = Encoding.UTF8.GetBytes(@"#!/bin/sh

set -e

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd ""$1""
. dependencies.sh
cd ""$original_dir""

#find out what we have (+e is important for this)
set +e
has_git=""$(command - v git)""
has_cargo=""$(command -v ~/.cargo/bin/cargo)""
has_sudo=""$(command -v sudo)""
has_cmake=""$(command -v cmake)""
has_gpp=""$(command -v g++-6)""
has_grep=""$(command -v grep)""
set - e

# install cargo if needful
if ! [ -x ""$has_cargo"" ]; then
	echo ""Installing rust...""
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
	. ~/.profile
fi

# apt packages
if ! { [ -x ""$has_git"" ] && [ -x ""$has_cmake"" ] && [ -x ""$has_gpp"" ] && [ -x ""$has_grep"" ] && [ -f ""/usr/lib/i386-linux-gnu/libmariadb.so.2"" ] && [ -f ""/usr/lib/i386-linux-gnu/libssl.so"" ] && [ -d ""/usr/share/doc/g++-6-multilib"" ] && [ -f ""/usr/bin/mysql"" ] && [ -d ""/usr/include/mysql"" ]; }; then
	echo ""Installing apt dependencies...""
	if ! [ -x ""$has_sudo"" ]; then
		dpkg --add-architecture i386
		apt-get update
		apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client
		ln -s /usr/include/mariadb /usr/include/mysql
		rm -rf /var/lib/apt/lists/*
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client
		sudo ln -s /usr/include/mariadb /usr/include/mysql
		sudo rm -rf /var/lib/apt/lists/*
	fi
fi

#update rust-g
if [ ! -d ""rust-g"" ]; then
	echo ""Cloning rust-g...""
	git clone https://github.com/tgstation/rust-g
else
	echo ""Fetching rust-g...""
	cd rust-g
	git fetch
	cd ..
fi

#update BSQL
if [ ! -d ""BSQL"" ]; then
	echo ""Cloning BSQL...""
	git clone https://github.com/tgstation/BSQL
else
	echo ""Fetching BSQL...""
	cd BSQL
	git fetch
	cd ..
fi

echo ""Deploying rust-g...""
cd rust-g
git checkout ""$RUST_G_VERSION""
~/.cargo/bin/cargo build --release
mv target/release/librust_g.so ""$1/rust_g""
cd ..

echo ""Deploying BSQL...""
cd BSQL
git checkout ""$BSQL_VERSION""
mkdir -p mysql
mkdir -p artifacts
cd artifacts
cmake .. -DCMAKE_CXX_COMPILER=g++-6 -DMARIA_LIBRARY=/usr/lib/i386-linux-gnu/libmariadb.so.2
make
mv src/BSQL/libBSQL.so ""$1/""

if [ ! -d ""$1/../../../Configuration/GameStaticFiles/config"" ]; then
	echo ""Creating initial config...""
	cp -r ""$1/config"" ""$1/../../../Configuration/GameStaticFiles/config""
	echo -e ""SQL_ENABLED\nADDRESS mariadb\nPORT 3306\nFEEDBACK_DATABASE ss13\nFEEDBACK_LOGIN root\nFEEDBACK_PASSWORD YouDefinitelyShouldNOTChangeThis\nASYNC_QUERY_TIMEOUT 10\nBLOCKING_QUERY_TIMEOUT 5\nBSQL_THREAD_LIMIT 50"" > ""$1/../../../Configuration/GameStaticFiles/config/dbconfig.txt""
fi

DATABASE_EXISTS=""$(mysqlshow --user=root --password=YouDefinitelyShouldNOTChangeThis ss13_db| grep -v Wildcard | grep -o ss13_db)""
if [ ""$DATABASE_EXISTS"" != ""ss13_db"" ]; then
	echo ""Creating initial SS13 database...""
    mysql -u root -p YouDefinitelyShouldNOTChangeThis -h mariadb -P 3306 -e 'CREATE DATABASE ss13_db;'
    mysql -u root -p YouDefinitelyShouldNOTChangeThis -h mariadb -P 3306 -e ss13_db < ""$1/SQL/tgstation_schema.sql""
fi
".Replace("\r", String.Empty))
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
