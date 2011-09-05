/obj/machinery/computer
	name = "computer"
	icon = 'computer.dmi'
	density = 1
	anchored = 1.0
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassemble

/*
/obj/machinery/computer/airtunnel
	name = "Air Tunnel Control"
	icon = 'airtunnelcomputer.dmi'
	icon_state = "console00"
*/

/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1.0
	icon_state = "operating"
	circuit = "/obj/item/weapon/circuitboard/operating"

	var/mob/living/carbon/human/victim = null

	var/obj/machinery/optable/table = null
	var/id = 0.0

/*
 *	Arcade -- An arcade cabinet.
 */

/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support Pin ball."
	icon = 'computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/weapon/circuitboard/arcade"
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "It is said that you can upload silly laws to AI's with this."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0

/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used for uploading responsible laws to Cyborg. Right..."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null

/obj/machinery/computer/atmosphere
	name = "atmos"
	desc = "A computer for Atmospherics."

/obj/machinery/computer/station_alert
	name = "Station Alert Computer"
	desc = "Alert. Alert. ALERT!!!"
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())

/obj/machinery/computer/atmos_alert
	name = "Atmospheric Alert Computer"
	desc = "Used to detect where they messed up this time."
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437


/obj/machinery/computer/atmosphere/siphonswitch
	name = "Area Air Control"
	desc = "Nanotrasen provided this, barely."
	icon_state = "atmos"
	var/otherarea
	var/area/area

/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"

/obj/machinery/computer/card
	name = "Identification Computer"
	desc = "You can use this to change ID's. YOU ARE GOD!"
	icon_state = "id"
	circuit = "/obj/item/weapon/circuitboard/card"
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/modify = null
	var/authenticated = 0.0
	var/mode = 0.0
	var/printing = null
	req_access = list(access_change_ids)

//ID changing computer for CentCom.
/obj/machinery/computer/card/centcom
	name = "CentCom Identification Computer"
	desc = "You are the Gods's God."
	circuit = "/obj/item/weapon/circuitboard/card/centcom"
	req_access = list(access_cent_captain)

/obj/machinery/computer/communications
	name = "Communications Console"
	desc = "This can be used for various important functions. Still under developement."
	icon_state = "comm"
	req_access = list(access_heads)
	circuit = "/obj/item/weapon/circuitboard/communications"
	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/const
		STATE_DEFAULT = 1
		STATE_CALLSHUTTLE = 2
		STATE_CANCELSHUTTLE = 3
		STATE_MESSAGELIST = 4
		STATE_VIEWMESSAGE = 5
		STATE_DELMESSAGE = 6
		STATE_STATUSDISPLAY = 7

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2

/obj/machinery/computer/data
	name = "data"
	icon_state = "aiupload"

	var/list/topics = list(  )

/obj/machinery/computer/data/weapon
	name = "weapon"

/obj/machinery/computer/data/weapon/info
	name = "Research Computer"

/obj/machinery/computer/data/weapon/log
	name = "Log Computer"

/obj/machinery/computer/dna
	name = "DNA operations computer"
	desc = "A Computer used to advanced DNA stuff."
	icon_state = "dna"
	var/obj/item/weapon/card/data/scan = null
	var/obj/item/weapon/card/data/modify = null
	var/obj/item/weapon/card/data/modify2 = null
	var/mode = null
	var/temp = null

/obj/machinery/computer/hologram_comp
	name = "Hologram Computer"
	desc = "Rumoured to control holograms."
	icon = 'stationobjs.dmi'
	icon_state = "holo_console0"
	var/obj/machinery/hologram/projector/projector = null
	var/temp = null
	var/lumens = 0.0
	var/h_r = 245.0
	var/h_g = 245.0
	var/h_b = 245.0

/obj/machinery/computer/med_data
	name = "Medical Records"
	desc = "This can be used to check medical records."
	icon_state = "medcomp"
	req_access = list(access_medical)
	circuit = "/obj/item/weapon/circuitboard/med_data"
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null

/obj/machinery/computer/med_data/laptop
	name = "Medical Laptop"
	desc = "Cheap Nanotrasen Laptop."
	icon_state = "medlaptop"

/obj/machinery/computer/pod
	name = "Pod Launch Control"
	desc = "A controll for launching pods. Some people prefer firing Mechas."
	icon_state = "computer_generic"
	var/id = 1.0
	var/obj/machinery/mass_driver/connected = null
	var/timing = 0.0
	var/time = 30.0

/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "DoorMex Control Computer"

/obj/machinery/computer/pod/old/syndicate
	name = "ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"

/*/obj/machinery/computer/scan_consolenew    //Coming Soon
	name = "DNA Modifier Access Console"
	desc = "Scand DNA."
	icon = 'computer.dmi'
	icon_state = "scanner"
	density = 1
	var/uniblock = 1.0
	var/strucblock = 1.0
	var/subblock = 1.0
	var/status = null
	var/radduration = 2.0
	var/radstrength = 1.0
	var/radacc = 1.0
	var/buffer1 = null
	var/buffer2 = null
	var/buffer3 = null
	var/buffer1owner = null
	var/buffer2owner = null
	var/buffer3owner = null
	var/buffer1label = null
	var/buffer2label = null
	var/buffer3label = null
	var/buffer1type = null
	var/buffer2type = null
	var/buffer3type = null
	var/buffer1iue = 0
	var/buffer2iue = 0
	var/buffer3iue = 0
	var/delete = 0
	var/injectorready = 1
	var/temphtml = null
	var/obj/machinery/dna_scanner/connected = null
	var/obj/item/weapon/disk/data/diskette = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400 */

/obj/machinery/computer/secure_data
	name = "Security Records"
	desc = "Beepsky. ARREST!!!"
	icon_state = "security"
	req_access = list(access_security)
	circuit = "/obj/item/weapon/circuitboard/secure_data"
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0

/obj/machinery/computer/secure_data/detective_computer
	icon = 'computer.dmi'
	icon_state = "messyfiles"

/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Better than Television."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/security"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/network = "SS13"
	var/maplevel = 1

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'stationobjs.dmi'
	icon_state = "telescreen"
	network = "thunder"
	density = 0
	circuit = null

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "Nanotrasen gave the detective this for Noir feeling."
	icon_state = "security_det"

/obj/machinery/computer/security/mining
	name = "Outpost Status Display"
	desc = "It's better than reality TV."
	icon_state = "miningcameras"
	network = "MINE"
	circuit = "/obj/item/weapon/circuitboard/mining"

/obj/machinery/computer/shuttle
	name = "Shuttle"
	desc = "For shuttle controll."
	icon_state = "shuttle"
	var/auth_need = 3.0
	var/list/authorized = list(  )

/obj/machinery/computer/teleporter
	name = "Teleporter"
	desc = "Use this to set your destination...hopefully..."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/locked = null
	var/id = null

/obj/machinery/computer/teleporter/security
	name = "Teleporter"
	desc = "Use this to set your destination...hopefully..."
	icon_state = "teleport"
	locked = null
	id = null

/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked =	list(  )

/obj/machinery/computer/robotics
	name = "Robotics Control"
	icon = 'computer.dmi'
	icon_state = "robot"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/robotics"

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text

