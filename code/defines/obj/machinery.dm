/obj/machinery
	name = "machinery"
	icon = 'stationobjs.dmi'
	var
		stat = 0
		emagged = 0
		use_power = 0
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
		idle_power_usage = 0
		active_power_usage = 0
		power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
		list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
		uid
		manual = 0
		global
			gl_uid = 1

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
	icon = 'monitors.dmi'
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
	icon = 'objects.dmi'
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
	icon = 'Cryogenic2.dmi'
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
	icon = 'Cryogenic2.dmi'
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
	desc = "Pull this in case of emergency."
	icon = 'monitors.dmi'
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
				src.overlays += image('monitors.dmi', "overlay_[get_security_level()]")
			else
				src.overlays += image('monitors.dmi', "overlay_green")

/obj/machinery/partyalarm
	name = "\improper Party Button"
	desc = "Cuban Pete is in the house!"
	icon = 'monitors.dmi'
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
	icon = 'stationobjs.dmi'
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
	icon = 'stationobjs.dmi'
	icon_state = "injector"
	density = 1
	anchored = 1.0
	flags = ON_BORDER
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	layer = TURF_LAYER

/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'stationobjs.dmi'
	icon_state = "mass_driver"
	var/power = 1.0
	var/code = 1.0
	var/id = 1.0
	anchored = 1.0
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 50

/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'meter.dmi'
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
	icon = 'Cryogenic2.dmi'
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
	icon = 'computer.dmi'
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

/obj/machinery/scan_consolenew
	name = "DNA Modifier Access Console"
	desc = "Scans DNA."
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
	var/list/message = list()
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400

/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'stationobjs.dmi'
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
	desc = "FIRE AWAY!"
	icon = 'objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a Mass Driver."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch
	name = "ignition switch"
	desc = "It activates an igniter."
	icon = 'objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/teleport
	name = "teleport"
	icon = 'stationobjs.dmi'
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
	desc = "The station's hub of a teleport system."
	icon_state = "controller"
	var/active = 0
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
/*
/obj/machinery/wire
	name = "wire"
	icon = 'power_cond_red.dmi'
	use_power = 1
	idle_power_usage = 0
	active_power_usage = 1
*/
/obj/machinery/power
	name = null
	icon = 'power.dmi'
	anchored = 1.0
	var/datum/powernet/powernet = null
	var/netnum = 0
	var/directwired = 1		// by default, power machines are connected by a cable in a neighbouring turf
							// if set to 0, requires a 0-X cable on this turf
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	layer = TURF_LAYER
	var/obj/machinery/power/master = null
	anchored = 1
	directwired = 0		// must have a cable on same turf connecting to terminal
	layer = 2.6 // a bit above wires

/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator_type2
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1

	var/obj/machinery/atmospherics/unary/generator_input/input1
	var/obj/machinery/atmospherics/unary/generator_input/input2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/monitor
    name = "power monitoring computer"
    desc = "It monitors power levels across the station, and can remotely toggle main breakers."
    icon = 'computer.dmi'
    icon_state = "power"
    density = 1
    anchored = 1
    use_power = 2
    idle_power_usage = 20
    active_power_usage = 80
    var/control = 0
    req_access = list(access_engine_equip)

/obj/machinery/cell_charger
	name = "cell charger"
	desc = "A charging unit for power cells."
	icon = 'power.dmi'
	icon_state = "ccharger0"
	var/obj/item/weapon/cell/charging = null
	var/chargelevel = -1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 60

/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/on = 1
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'power.dmi'
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
	var
		obj/effect/overlay/hologram//The projection itself. If there is one, the instrument is on, off otherwise.

/obj/machinery/hologram/holopad
	name = "\improper AI holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	var
		mob/living/silicon/ai/master//Which AI, if any, is controlling the object? Only one AI may control a hologram at any time.
		last_request = 0 //to prevent request spam. ~Carn

/obj/machinery/hologram/projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon = 'stationobjs.dmi'
	icon_state = "hologram0"

/obj/machinery/hologram/proj_ai
	name = "hologram projector platform"
	desc = "It's used by the AI for fooling around."
	icon = 'stationobjs.dmi'
	icon_state = "hologram0"
	var
		temp = null
		lumens = 0.0
		h_r = 245.0
		h_g = 245.0
		h_b = 245.0

/obj/machinery/coatrack
	name = "coat rack"
	desc = "A fancy stand for the Detective's coat and hat."
	icon_state = "coatrack0"
	icon = 'coatrack.dmi'
	density = 1
	anchored = 1.0
	var/obj/item/clothing/suit/storage/det_suit/coat
	var/obj/item/clothing/head/det_hat/hat
