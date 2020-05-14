This is @Cyberboss rage code

The goal is a one stop solution for hosting /tg/station on linux via docker

Requires docker to be installed. Launch with `docker-compose up`. If that fails, Ctrl+C out, run `docker-compose down`, remove `./TGS_Instances` and `./Database`, and try again.

What it does:

- Starts mariadb with the data files in `./Database` on port 3306
- Installs and starts Tgs4 (using latest stable docker tag, no HTTPS) on port 5000. Configuration in `./TGS_Config`, logs in `./TGS_Logs`.
- Configures a TGS instance for tgstation in `./TGS_Instances` (SetupProgram)
	- The instance is configured to autostart
	- Repo is cloned from the origin specified in the `docker-compose.yml`
	- BYOND version is set to the latest one specified in the `docker-compose.yml`
	- A script similar to `../tgs4_scripts/PostCompile.sh` is used to setup BSQL, rust-g, and the non-prefixed database schema
		- The database will be created on the same mariadb instance and is named `ss13_db`
	- `config` and `data` folders live in `./Instances/main/Configuration/GameStaticFiles`
	- DreamDaemon will be exposed on port 1337
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
