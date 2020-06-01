This is @Cyberboss rage code

The goal is a one stop solution for hosting /tg/station on linux via Docker. Will not work with Docker on Windows.

This requires Docker with the `docker-compose` command to be installed on your system. See ubuntu instructions [here](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository). If you fail to find the `docker-ce` package refer to [this StackOverflow answer](https://unix.stackexchange.com/a/363058).

Some basic configuration options in `docker-compose.yml` before starting:
- Change TGS_ADMIN_CKEY to your ckey so you may have initial control over the server.
- Change TGS_SCHEMA_MAJOR_VERSION to your repo's latest schema major version.
- Change TGS_SCHEMA_MINOR_VERSION to your repo's latest schema minor version.
- If you want to change the MariaDB password, there are three locations in the file it must be changed from its default value of `ChangeThisInBothMariaDBAndTgsConnectionString`.
- Change TGS_BYOND to set the initial BYOND version.
- Ports are mapped in the form `<external>:<internal>` NEVER change the internal port. If you want to prevent a service from being exposed, delete/comment out the entire line.
	- The first (3306) is the exposed mariadb port. Do not expose this over the internet without changing the password. In general it's a bad idea.
	- The second (1337) is the exposed DreamDaemon port
	- The third (5000) is the exposed TGS API port. Do not expose this over the internet. Setup an HTTPS reverse proxy instead.
- Change TGS_REPO to set the repository used. Note, this must be a /tg/ derivative from at least 2019 that implements the latest TGS [DreamMaker API](https://github.com/tgstation/tgstation-server#integrating). Repositories that follow tgstation/tgstation will have this automatically. It also must contain a prefixed SQL schema setup file.

To launch, change to this directory and run `docker-compose up`. The initial setup will take a long time. If that fails, Ctrl+C out, run `docker-compose down`, remove `./TGS_Instances` and `./Database`, and try again. Once setup is complete, you can either leave the terminal running, or `Ctrl+C` out (this will stop DreamDaemon) and run `docker-compose -d` to run it in the background.

What it does:

- Starts mariadb with the data files in `./Database` on port 3306
- Installs and starts Tgs4 (using latest stable docker tag, no HTTPS) on port 5000. Configuration in `./TGS_Config`, logs in `./TGS_Logs`.
- Configures a TGS instance for tgstation in `./TGS_Instances` (SetupProgram)
	- The instance is configured to autostart
	- Repo is cloned from the origin specified in the `docker-compose.yml`
	- BYOND version is set to the latest one specified in the `docker-compose.yml`
	- A script will be run to setup dependencies. This does the following every time the game is built:
		- Reads dependency information from `dependencies.sh` in the root of the repository
		- Installs the following necessary packages into the TGS image
			- Rust/cargo
			- git
			- cmake
			- grep
			- g++-6
			- g++-6-multilib
			- mysql-client
			- libmariadb-dev:i386
			- libssl-dev:i386
		- Builds rust-g in `./TGS_Instances/main/Configuration/EventScripts/rust-g` and copies the artifact to the game directory.
		- Builds BSQL in `./TGS_Instances/main/Configuration/EventScripts/BSQL` and copies the artifact to the game directory.
		- Sets up `./TGS_Instances/main/Configuration/GameStaticFiles/config` with the initial repository config.
		- Sets up `./TGS_Instances/main/Configuration/GameStaticFiles/data`.
		- If it doesn't exist, create the `ss13_db` database on the mariadb server and populate it with the repository's.
	- Start DreamDaemon and configure it to autostart and keep it running via TGS.
	- Updates will be pulled from the default repository branch and deployed every hour

What it DOESN'T do:

- Configure sane MariaDB security
- TGS Test merging
- TGS Chat bots
- Handle updating BYOND versions
- Handle updating the database schema
- Manage TGS users, permissions, or change the default admin password
- Provide HTTPS for TGS
- Expose the DB to the internet UNLESS you have port 3306 forwarded for some ungodly reason
- Port forward or setup firewall rules for DreamDaemon or TGS
- Notify you of TGS errors past initial setup
- Keep MariaDB logs
- Backup ANYTHING
- Pretend like it's a long term solution

This is enough to host a production level server !!!IN THEORY!!! This script guarantees nothing and comes with no warranty

You can change the TGS_BYOND and TGS_REPO variables when setting up the first time. But further configuration must be done with TGS itself.

You can connect to TGS with [Tgstation.Server.ControlPanel](https://github.com/tgstation/Tgstation.Server.ControlPanel/releases) (Binaries provided for windows, must be compiled manually on Linux).
- Connect to `http://localhost:5000`. Be sure to `Use Plain HTTP` and `Default Credentials`

You should learn how to manually setup TGS if you truly want control over what your server does.

You have been warned.
