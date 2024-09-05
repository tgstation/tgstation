# INSTALLATION
First-time installation should be fairly straightforward. First, you'll need
BYOND installed. You can get it from https://www.byond.com/download. Once you've done
that, extract the game files to wherever you want to keep them. This is a
sourcecode-only release, so the next step is to compile the server files.

Double-click `BUILD.cmd` in the root directory of the source code. This'll take
a little while, and if everything's done right you'll get a message like this:

```
saving tgstation.dmb (DEBUG mode)
tgstation.dmb - 0 errors, 0 warnings
```

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong. If problems persist, ask for assistance
in irc://irc.rizon.net/coderbus

Once that's done, open up the config folder. You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round. It's recommended you don't turn on the gamemodes with probability 0,
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs. Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit config/admins.txt to remove the default admins and add
your own. "Game Master" is the highest level of access, and probably the one
you'll want to use for now. You can set up your own ranks and find out more in
config/admin_ranks.txt

The format is

```
byondkey = Rank
```

where the admin rank must be properly capitalised.

This codebase also depends on a native library called rust-g. A precompiled
Windows DLL is included in this repository, but Linux users will need to build
and install it themselves. Directions can be found at the [rust-g
repo](https://github.com/tgstation/rust-g).

Finally, to start the server, run Dream Daemon and enter the path to your
compiled tgstation.dmb file. Make sure to set the port to the one you
specified in the config.txt, and set the Security box to 'Safe'. Then press GO
and the server should start up and be ready to join. It is also recommended that
you set up the SQL backend (see below).

## UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

## HOSTING

If you'd like a more robust server hosting option for tgstation and its
derivatives. Check out our server tools suite at
https://github.com/tgstation/tgstation-server

If you decide to go this route, here are /tg/ specific details on hosting with TGS.

- We have two directories which should be setup in the instance's `Configuration/GameStaticFiles` directory:
	- `config` should be where you place your production configuration. Overwrites the default contents of the repo's [config](../../config) directory.
	- `data` should be initially created as an empty directory. The game stores persistent data here.
- You should incorporate our [custom build scripts for TGS4](../../tools/tgs4_scripts) in the instance's `Configuration/EventScripts` directory. These handle including TGUI in the build and setting up rust-g on Linux.
- Deployment security level must be set to `Trusted` or it will likely fail due to our native library usage.
- We highly recommend using the BYOND version specified in [dependencies.sh](../../dependencies.sh) to avoid potential unrecorded issues.

## SQL SETUP

The SQL backend requires a Mariadb server running 10.2 or later. Mysql is not supported but Mariadb is a drop in replacement for mysql. SQL is required for the library, stats tracking, admin notes, and job-only bans, among other features, mostly related to server administration. Your server details go in /config/dbconfig.txt, and the SQL schema is in /SQL/tgstation_schema.sql and /SQL/tgstation_schema_prefix.sql depending on if you want table prefixes.  More detailed setup instructions are located here: https://www.tgstation13.org/wiki/Downloading_the_source_code#Setting_up_the_database

If you are hosting a testing server on windows you can use a standalone version of MariaDB pre load with a blank (but initialized) tgdb database. Find them here: https://tgstation13.download/database/ Just unzip and run for a working (but insecure) database server. Includes a zipped copy of the data folder for easy resetting back to square one.

## WEB/CDN RESOURCE DELIVERY

Web delivery of game resources makes it quicker for players to join and reduces some of the stress on the game server.

1. Edit compile_options.dm to set the `PRELOAD_RSC` define to `0`
1. Add a url to config/external_rsc_urls pointing to a .zip file containing the .rsc.
    * If you keep up to date with /tg/ you could reuse /tg/'s rsc cdn at http://tgstation13.download/byond/tgstation.zip. Otherwise you can use cdn services like CDN77 or cloudflare (requires adding a page rule to enable caching of the zip), or roll your own cdn using route 53 and vps providers.
	* Regardless even offloading the rsc to a website without a CDN will be a massive improvement over the in game system for transferring files.

### All In One Amazon Web Services Hosting and Content delivery network.
**Important Note**
It is very Importat to note that since AWS is all highly integrated its "easier" than some solutions. However the Price to ***Performance Ratio is terrible***.

/tg/ Using around 7TB of bandwidth a month. These costs add up. So AWS is probly only a solution for low to mid pop servers

**Please use [AWS Cost Estimator](https://calculator.s3.amazonaws.com/index.html) to determine if this solution is right for you.**

This also may not be the best AWS set up but it works.

This guide is also assuming you are setting up a production server and not a server that you bring up and down on weekends.
It is highly recommended to reference AWS support documentation while reading this guide. This guide is not a How to AWS.

**Required AWS Services**
1. Elastic Computer 2 (EC2)
	* What size and class is up to you but 4GB of RAM is a minimum.
1. Route53
	* Domain registration and assigning "Elastic" IP addresses to said web addresses
1. S3
	* This will be your storage point and distrobution point for your .RSC file
1. Identity and Access Management (IAM)
	* Required for EC2 to S3 file transfers

**Required Software**
1. Microsoft Windows
1. MariaDB
1. TGS4
1. Notepad++ or other code editor for writing batch scripts
1. AWS Command Line V2

**Instructions**
1. After you go through setting up an AWS account you will need to create an IAM role and an IAM user. the IAM user will be made for debug testing. The IAM role will be used as an internal credential for the EC2 instance to talk with S3
	* The role and user creation are almost identical. give them names, select programatic access, then you will click atatych existing policey, Here you can use admin access or S3 full access. both can be found via search. the difference for roles is that you will on the first step declare it for use with EC2 and this one will need full admin access
1. Create your Amazon EC2 instance. There will be a config option asking for an IAM role. use the IAM role created in the previous step.
	* A blank Windows Server is recommended
	* You will also need to define a security policey. 3 are recommended. a Remote Desktop Protocol Policey, a Maria DB Policey, and an SS13 policey. the Latter will use the port(s) of your dream demon settings. Make sure the SS13 policey whitelists all IP addresses.
1. Creat your S3 bucket. this is a very simple process. only thing you need to edit is making the bucket public and making sure its in the same region as your EC2 instance.
1. In the EC2 control panel, go to Elastic IP's. get one and assign it to your EC2 instance. This will result in the server IP address not changing and is required for joining the game via url instead of ip address
1. In Route 53 you will register a domain name. The you will create a hosted zone and tell your domain to use the IP address you used for your EC2 instance.
1. Install the required software
	* AWSCL2 you will need to run the configuration using the IAM User you created above.
	* TGS4: Make sure the TGS4 scripts from /tools/ are installed per tgs 4 instructions after you have set up your repository and done your first fetch. You will need to Also install a batch file similar to what i have provided into the event scripts folder. You can manually run the batch file to test connection to your S3 bucket.
	* Copy `compile_options.dm` into code overrides preserving the directory structure and altering the code as mentioned in the above CDN instructions.
	* Filename: DeploymentComplete.bat
```Batch
@echo off
cd "C:\Program Files\Amazon\AWSCLIV2"
aws s3 cp "C:\Instance_Path\Game\Live\tgstation.rsc" s3://BucketName/tgstation.rsc --acl public-read
```

7. In your TGS4's instance's static config files edit resources.txt to point to the resource file uploaded by the batch file. it should resemble `http://BucketName.s3.AWSRegion.amazonaws.com/tgstation.rsc` You can get this url from the S3 object management page after its been uploaded for the first time. *Make sure you do not use use HTTPS. Byond can not do encryption*
7. Tell TGS4 to fetch and deploy. If everything goes according to plan, your server will be compiled and the resource uploaded automatically to amazon S3. You can verify that by checking on the file your bucket via aws web management.
7. Test your client side connection.
	* Tell TGS4 to run the compiled server
	* Attempt to log in. AWS has a stupid fast transfer speed. you should download client side data faster than you can recognize it happened.

## IRC BOT SETUP

Included in the repository is a python3 compatible IRC bot capable of relaying adminhelps to a specified
IRC channel/server, see the /tools/minibot folder for more
