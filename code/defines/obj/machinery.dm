//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	var/stat = 0
	var/emagged = 0
	var/use_power = 0
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/global/gl_uid = 1

/obj/machinery/autolathe
	name = "\improper Autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/operating = 0.0
	var/opened = 0.0
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	var/network = "SS13"
	layer = 5
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/invuln = null
	var/bugged = 0
	var/hardened = 0
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10

/obj/machinery/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky one-way storage device for gas tanks. Holds 10 plasma and 10 oxygen tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	var/o2tanks = 10.0
	var/pltanks = 10.0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 10

/obj/machinery/dna_scanner
	name = "\improper DNA scanner/implanter"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	var/locked = 0.0
	var/mob/occupant = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300

/obj/machinery/dna_scannernew
	name = "\improper DNA modifier"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	var/locked = 0.0
	var/mob/occupant = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"<i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

	New()
		if(z == 1)
			if(security_level)
				src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
			else
				src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

/obj/machinery/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6


/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	var/id = null
	var/on = 1.0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/injector
	name = "injector"
	desc = "It injects gas into a chamber."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "injector"
	density = 1
	anchored = 1.0
	flags = ON_BORDER
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	layer = TURF_LAYER

/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	var/frequency = 0
	var/id
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/restruct
	name = "\improper DNA physical restructurization accelerator"
	desc = "It looks ridiculously complex."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "restruct_0"
	density = 1
	var/locked = 0.0
	var/mob/occupant = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 600

/obj/machinery/scan_console
	name = "\improper DNA Scanner Access Console"
	desc = "It scans DNA structures."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = 1
	var/obj/item/weapon/card/data/scan = null
	var/func = ""
	var/data = ""
	var/special = ""
	var/status = null
	var/prog_p1 = null
	var/prog_p2 = null
	var/prog_p3 = null
	var/prog_p4 = null
	var/temp = null
	var/obj/machinery/dna_scanner/connected = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400

/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	var/id = null
	var/range = 10
	var/normaldoorcontrol = 0
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0
	var/lockeddown = 0

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000

/obj/machinery/teleport/station
	name = "station"
	desc = "It's the station thingy of a teleport thingy." //seriously, wtf.
	icon_state = "controller"
	var/active = 0
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
/*
/obj/machinery/wire
	name = "wire"
	icon = 'icons/obj/power_cond_red.dmi'
	use_power = 1
	idle_power_usage = 0
	active_power_usage = 1
*/

/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/on = 1
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(access_crematorium)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1

/obj/machinery/hologram
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/obj/effect/overlay/hologram//The projection itself. If there is one, the instrument is on, off otherwise.

/obj/machinery/hologram/holopad
	name = "\improper AI holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	var/mob/living/silicon/ai/master//Which AI, if any, is controlling the object? Only one AI may control a hologram at any time.
	var/last_request = 0 //to prevent request spam. ~Carn

/obj/machinery/hologram/projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hologram0"

/obj/machinery/hologram/proj_ai
	name = "hologram projector platform"
	desc = "It's used by the AI for fooling around."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hologram0"
	var/temp = null
	var/lumens = 0.0
	var/h_r = 245.0
	var/h_g = 245.0
	var/h_b = 245.0
