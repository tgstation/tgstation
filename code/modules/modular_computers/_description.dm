/*
Program-based computers, designed to replace computer3 project and eventually most consoles on station


1. Basic information
Program based computers will allow you to do multiple things from single computer. Each computer will have programs, with more being downloadable from NTNet (stationwide network with wireless coverage)
if user has apropriate ID card access. It will be possible to hack the computer by using an emag on it - the emag will have to be completely new and will be consumed on use, but it will
lift ALL locks on ALL installed programs, and allow download of programs even if your ID doesn't have access to them. Computers will have hard drives that can store files.
Files can be programs (datum/computer_file/program/ subtype) or data files (datum/computer_file/data/ subtypes). Program for sending files will be available that will allow transfer via NTNet.
NTNet coverage will be limited to station's Z level, but better network card (=more expensive and higher power use) will allow usage everywhere. Hard drives will have limited capacity for files
which will be related to how good hard drive you buy when purchasing the laptop. For storing more files USB-style drives will be buildable with Protolathe in research.

2. Available devices
CONSOLES
Consoles will come in various pre-fabricated loadouts, each loadout starting with certain set of programs (aka Engineering console, Medical console, etc.), of course, more software may be downloaded.
Consoles won't usually have integrated battery, but the possibility to install one will exist for critical applications. Consoles are considered hardwired into NTNet network which means they
will have working coverage on higher speed (Ethernet is faster than Wi-Fi) and won't require wireless coverage to exist.
LAPTOPS
Laptops are middle ground between actual portable devices and full consoles. They offer certain level of mobility, as they can be closed, moved somewhere else and then opened again.
Laptops will by default have internal battery to power them, and may be recharged with rechargers. However, laptops rely on wireless NTNet coverage. Laptop HDDs are also designed with power efficiency
in mind, which means they sacrifice some storage space for higher battery life. Laptops may be dispensed from computer vendor machine, and may be customised before vending. For people which don't
want to rely on internal battery, tesla link exists that connects to APC, if one exists.
TABLETS
Tablets are smallest available devices, designed with full mobility in mind. Tablets have only weak CPU which means the software they can run is somewhat limited. They are also designed with high
battery life in mind, which means the hardware focuses on power efficiency rather than high performance. This is most visible with hard drives which have quite small storage capacity.
Tablets can't be equipped with tesla link, which means they have to be recharged manually.


3. Computer Hardware
Computers will come with basic hardware installed, with upgrades being selectable when purchasing the device.
Hard Drive: Stores data, mandatory for the computer to work
Network Card: Connects to NTNet
Battery: Internal power source that ensures the computer operates when not connected to APC.
Extras (those won't be installed by default, but can be bought)
ID Card Slot: Required for HoP-style programs to work. Access for security record-style programs is read from ID of user [RFID?] without requiring this
APC Tesla Relay: Wirelessly powers the device from APC. Consoles have it by default. Laptops can buy it.
Disk Drive: Allows usage of portable data disks.
Nano Printer: Allows the computer to scan paper contents and save them to file, as well as recycle papers and print stuff on it.

4. NTNet
NTNet is stationwide network that allows users to download programs needed for their work. It will be possible to send any files to other active computers using relevant program (NTN Transfer).
NTNet is under jurisdiction of both Engineering and Research. Engineering is responsible for any repairs if necessary and research is responsible for monitoring. It is similar to PDA messaging.
Operation requires functional "NTNet Relay" which is by default placed on tcommsat. If the relay is damaged NTNet will be offline until it is replaced. Multiple relays bring extra redundancy,
if one is destroyed the second will take over. If all relays are gone it stops working, simple as that. NTNet may be altered via administration console available to Research Director. It is
possible to enable/disable Software Downloading, P2P file transfers and Communication (IC version of IRC, PDA messages for more than two people)

5. Software
Software would almost exclusively use NanoUI modules. Few exceptions are text editor (uses similar screen as TCS IDE used for editing and classic HTML for previewing as Nano looks differently)
and similar programs which for some reason require HTML UI. Most software will be highly dependent on NTNet to work as laptops are not physically connected to the station's network.
What i plan to add:

Note: XXXXDB programs will use ingame_manuals to display basic help for players, similar to how books, etc. do

Basic - Software in this bundle is automagically preinstalled in every new computer
	NTN Transfer - Allows P2P transfer of files to other computers that run this.
	Configurator - Allows configuration of computer's hardware, basically status screen.
	File Browser - Allows you to browse all files stored on the computer. Allows renaming/deleting of files.
	TXT Editor - Allows you editing data files in text editor mode.
	NanoPrint - Allows you to operate NanoPrinter hardware to print text files.
	NTNRC Chat - NTNet Relay Chat client. Allows PDA-messaging style messaging for more than two users. Person which created the conversation is Host and has administrative privilegies (kicking, etc.)
	NTNet News - Allows reading news from newscaster network.

Engineering - Requires "Engineering" access on ID card (ie. CE, Atmostech, Engineer)
	Alarm Monitor - Allows monitoring alarms, same as the stationbound one.
	Power Monitor - Power monitoring computer, connects to sensors in same way as regular one does.
	Atmospheric Control - Allows access to the Atmospherics Monitor Console that operates air alarms. Requires extra access: "Atmospherics"
	RCON Remote Control Console - Allows access to the RCON Remote Control Console. Requires extra access: "Power Equipment"
	EngiDB - Allows accessing NTNet information repository for information about engineering-related things.

Medical - Requires "Medbay" access on ID card (ie. CMO, Doctor,..)
	Medical Records Uplink - Allows editing/reading of medical records. Printing requires NanoPrinter hardware.
	MediDB - Allows accessing NTNet information repository for information about medical procedures
	ChemDB - Requires extra access: "Chemistry" - Downloads basic information about recipes from NTNet

Research - Requires "Research and Development" access on ID card (ie. RD, Roboticist, etc.)
	Research Server Monitor - Allows monitoring of research levels on RnD servers. (read only)
	Robotics Monitor Console - Allows monitoring of robots and exosuits. Lockdown/Self-Destruct options are unavailable [balance reasons for malf/traitor AIs]. Requires extra access: "Robotics"
	NTNRC Administration Console - Allows administrative access to NTNRC. This includes bypassing any channel passwords and enabling "invisible" mode for spying on conversations. Requires extra access: "Research Director"
	NTNet Administration Console - Allows remote configuration of NTNet Relay - CAUTION: If NTNet is turned off it won't be possible to turn it on again from the computer, as operation requires NTNet to work! Requires extra access: "Research Director"
	NTNet Monitor - Allows monitoring of NTNet and it's various components, including simplified network logs and system status.

Security - Requires "Security" access on ID card (ie. HOS, Security officer, Detective)
	Security Records Uplink - Allows editing/reading of security records. Printing requires Nanoprinter hardware.
	LawDB - Allows accessing NTNet information repository for security information (corporate regulations)
	Camera Uplink - Allows viewing cameras around the station.

Command - Requires "Bridge" access on ID card (all heads)
	Alertcon Access - Allows changing of alert levels. Red requires activation from two computers with two IDs similar to how those wall mounted devices do.
	Employment Records Access - Allows reading of employment records. Printing requires NanoPrinter hardware.
	Communication Console - Allows sending emergency messages to Central.
	Emergency Shuttle Control Console - Allows calling/recalling the emergency shuttle.
	Shuttle Control Console - Allows control of various shuttles around the station (mining, research, engineering)

*REDACTED* - Can be downloaded from SyndiCorp servers, only via emagged devices. These files are very large and limited to laptops/consoles only.
	SYSCRACK - Allows cracking of secure network terminals, such as, NTNet administration. The sysadmin will probably notice this.
	SYSOVERRIDE - Allows hacking into any device connected to NTNet. User will notice this and may stop the hack by disconnecting from NTNet first. After hacking various options exist, such as stealing/deleting files.
	SYSKILL - Tricks NTNet to force-disconnect a device. The sysadmin will probably notice this.
	SYSDOS - Launches a Denial of Service attack on NTNet relay. Can DoS only one relay at once. Requires NTNet connection. After some time the relay crashes until attack stops. The sysadmin will probably notice this.
	AIHACK - Hacks an AI, allowing you to upload/remove/modify a law even without relevant circuit board. The AI is alerted once the hack starts, and it takes a while for it to complete. Does not work on AIs with zeroth law.
	COREPURGE - Deletes all files on the hard drive, including the undeletable ones. Something like software self-destruct for computer.

6. Security
Laptops will be password-lockable. If password is set a MD5 hash of it is stored and password is required every time you turn on the laptop.
Passwords may be decrypted by using special Decrypter (protolathable, RDs office starts with one) device that will slowly decrypt the password.
Decryption time would be length_of_password * 30 seconds, with maximum being 9 minutes (due to battery life limitations, which is 10+ min).
If decrypted the password is cleared, so you can keep using your favorite password without people ever actually revealing it (for meta prevention reasons mostly).
Emagged laptops will have option to enable "Safe Encryption". If safely encrypted laptop is decrypted it loses it's emag status and 50% of files is deleted (randomly selected).

7. System Administrator
System Administrator will be new job under Research. It's main specifics will be maintaining of computer systems on station, espicially from software side.
From IC perspective they'd probably know how to build a console or something given they work with computers, but they are mostly programmers/network experts.
They will have office in research, which will probably replace (and contain) the server room and part of the toxins storage which is currently oversized.
They will have access to DOWNLOAD (not run) all programs that exist on NTNet. They'll have fairly good amount of available programs, most of them being
administrative consoles and other very useful things. They'll also be able to monitor NTNet. There will probably be one or two job slots.

8. IDS
With addition of various antag programs, IDS(Intrusion Detection System) will be added to NTNet. This system can be turned on/off via administration console.
If enabled, this system automatically detects any abnormality and triggers a warning that's visible on the NTNet status screen, as well as generating a security log.
IDS can be disabled by simple on/off switch in the configuration.

*/