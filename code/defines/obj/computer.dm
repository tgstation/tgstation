/obj/machinery/computer
	name = "computer"
	icon = 'computer.dmi'
	density = 1
	anchored = 1.0
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassemble


/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support Pinball."
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


/obj/machinery/computer/aistatus
	name = "AI Status Panel"
	desc = "This shows the status of the AI."
	icon = 'mainframe.dmi'
	icon_state = "left"
//	brightnessred = 0
//	brightnessgreen = 2
//	brightnessblue = 0

/obj/machinery/computer/aistatus/attack_hand(mob/user as mob)
	if(stat & NOPOWER)
		user << "\red The status panel has no power!"
		return
	if(stat & BROKEN)
		user << "\red The status panel is broken!"
		return
	if(!issilicon(user))
		user << "\red You don't understand any of this!"
	else
		user << "\blue You know all of this already, why are you messing with it?"
	return

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0

/obj/machinery/computer/aiupload/mainframe
	name = "AI Mainframe Upload"
	icon = 'mainframe.dmi'
	icon_state = "aimainframe"

/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null

/obj/machinery/computer/borgupload/mainframe
	name = "Borg Mainframe Upload"
	icon = 'mainframe.dmi'
	icon_state = "aimainframe"


/obj/machinery/computer/station_alert
	name = "Station Alert Computer"
	desc = "Used to access the station's automated alert system."
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())


/obj/machinery/computer/atmos_alert
	name = "Atmospheric Alert Computer"
	desc = "Used to access the station's atmospheric sensors."
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437


/obj/machinery/computer/atmosphere
	name = "atmos"
	desc = "A computer for Atmospherics."


/obj/machinery/computer/atmosphere/siphonswitch
	name = "Area Air Control"
	desc = "Nanotrasen provided this, barely."
	icon_state = "atmos"
	var/otherarea
	var/area/area


/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"
	desc = "Emergancy global overrides for the entire atmospherics system."

/obj/machinery/computer/dna
	name = "DNA operations computer"
	desc = "A computer used for advanced DNA operations."
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
	var/obj/item/weapon/disk/records/disk = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/list/Perp
	var/tempname = null


/obj/machinery/computer/med_data/laptop
	name = "Medical Laptop"
	desc = "Cheap Nanotrasen Laptop."
	icon_state = "medlaptop"


/obj/machinery/computer/pod
	name = "Pod Launch Control"
	desc = "A control for launching pods."
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


/obj/machinery/computer/secure_data
	name = "Security Records"
	desc = "Used to view and edit personnel's security records"
	icon_state = "security"
	req_access = list(access_security)
	circuit = "/obj/item/weapon/circuitboard/secure_data"
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/disk/records/disk = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null


/obj/machinery/computer/secure_data/detective_computer
	icon = 'computer.dmi'
	icon_state = "messyfiles"


/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/securitycam"
	var/department = "Security"
	var/network = ""
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/networks
	var/maplevel = 1

/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	department = "Mining"
	circuit = "/obj/item/weapon/circuitboard/miningcam"

/obj/machinery/computer/security/cargo
	name = "Cargo Cameras"
	desc = "Used to access the cargo department cameras."
	icon_state = "miningcameras"
	department = "Cargo"
	circuit = "/obj/item/weapon/circuitboard/cargocam"

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to access the various cameras in engineering."
	icon_state = "engineeringcameras"
	department = "Engineering"
	circuit = "/obj/item/weapon/circuitboard/engineeringcam"

/obj/machinery/computer/security/research
	name = "Research Cameras"
	desc = "Used to access the various cameras in the research division."
	icon_state = "researchcameras"
	department = "Research"
	circuit = "/obj/item/weapon/circuitboard/researchcam"

/obj/machinery/computer/security/medbay
	name = "Medbay Cameras"
	desc = "Used to access the various cameras in the research division."
	icon_state = "medbaycameras"
	department = "Medbay"
	circuit = "/obj/item/weapon/circuitboard/medbaycam"


/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'stationobjs.dmi'
	icon_state = "telescreen"
	department = ""
	network = "Thunderdome"
	density = 0
	circuit = null


/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"

/obj/machinery/computer/lockdown
	/*
	name = "Lockdown Control"
	desc = "Used to control blast doors."
	icon_state = "lockdown"
	circuit = "/obj/item/weapon/circuitboard/lockdown"
	var/connectedDoorIds[0]
	var/department = ""
	var/connected_doors[0][0]
	*/

/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked =	list(  )

/*/obj/machinery/computer/scan_consolenew    //Coming Soon, I highly doubt this but Ill leave it here anyways
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
