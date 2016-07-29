/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
<<<<<<< HEAD
	hasPower - 1 if the main or backup power are functioning, 0 if not.
=======
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (stat & NOPOWER) for that)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

// Wires for the airlock are located in the datum folder, inside the wires datum folder.

<<<<<<< HEAD
#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6
var/list/airlock_overlays = list()

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
=======

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_closed"
	power_channel = ENVIRON

	custom_aghost_alerts=1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
<<<<<<< HEAD
	var/lights = 1 // bolt lights show by default
=======
	var/welded = null
	var/locked = 0
	var/lights = 1 // bolt lights show by default
	var/datum/wires/airlock/wires = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
<<<<<<< HEAD
	assemblytype = /obj/structure/door_assembly/door_assembly_0
	var/justzap = 0
	normalspeed = 1
	var/obj/item/weapon/electronics/airlock/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	autoclose = 1
	var/obj/item/device/doorCharge/charge = null //If applied, causes an explosion upon opening the door
	var/detonated = 0
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/AirlockClose.ogg'
	var/doorDeni = 'sound/machines/DeniedBeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/BoltsUp.ogg'
	var/boltDown = 'sound/machines/BoltsDown.ogg'
	var/noPower = 'sound/machines/DoorClick.ogg'

	var/airlock_material = null //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'

	var/image/old_frame_overlay //keep those in order to prevent unnecessary updating
	var/image/old_filling_overlay
	var/image/old_lights_overlay
	var/image/old_panel_overlay
	var/image/old_weld_overlay
	var/image/old_sparks_overlay

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0

	explosion_block = 1

/obj/machinery/door/airlock/New()
	..()
	wires = new /datum/wires/airlock(src)
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in airlocks)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break
	if(glass)
		airlock_material = "glass"
	update_icon()

/obj/machinery/door/airlock/initialize()
	. = ..()
	if (cyclelinkeddir)
		cyclelinkairlock()

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	var/limit = world.view
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/on_varedit(varname)
	. = ..()
	switch (varname)
		if ("cyclelinkeddir")
			cyclelinkairlock()


/obj/machinery/door/airlock/lock()
	bolt()

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = 1
	playsound(src,boltDown,30,0,3)
	update_icon()

/obj/machinery/door/airlock/unlock()
	unbolt()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = 0
	playsound(src,boltUp,30,0,3)
	update_icon()

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/runed = prob(20)
	if(prob(20))
		if(glass)
			if(runed)
				new/obj/machinery/door/airlock/cult/glass(T)
			else
				new/obj/machinery/door/airlock/cult/unruned/glass(T)
		else
			if(runed)
				new/obj/machinery/door/airlock/cult(T)
			else
				new/obj/machinery/door/airlock/cult/unruned(T)
		qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	if(prob(20))
		if(glass)
			new/obj/machinery/door/airlock/clockwork/brass(get_turf(src))
		else
			new/obj/machinery/door/airlock/clockwork(get_turf(src))
		qdel(src)

/obj/machinery/door/airlock/Destroy()
	qdel(wires)
	wires = null
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if(id_tag)
		for(var/obj/machinery/doorButtons/D in machines)
			D.removeMe(src)
	return ..()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
=======
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	autoclose = 1
	var/busy = 0
	soundeffect = 'sound/machines/airlock.ogg'
	var/pitch = 30
	penetration_dampening = 10

	explosion_block = 1

	emag_cost = 1 // in MJ
	machine_flags = SCREWTOGGLE | WIREJACK

/obj/machinery/door/airlock/Destroy()
	if(wires)
		qdel(wires)
		wires = null

	..()

/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'icons/obj/doors/Doormaint.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_ext
	normalspeed = 0 //So they close fast, not letting the air to depressurize in a fucking second

/obj/machinery/door/airlock/external/cultify()
	new /obj/machinery/door/mineral/wood(loc)
	..()

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	glass = 1
	penetration_dampening = 3
	//pitch = 100

/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 0

/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = 1
	emag_cost = 2 // in MJ
	assembly_type = /obj/structure/door_assembly/door_assembly_vault

	explosion_block = 3//that's some high quality plasteel door
	penetration_dampening = 20

/obj/machinery/door/airlock/freezer
	name = "Freezer Airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = "Airtight Hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/glass_medical
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doormedglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/mining
	name = "Mining Airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	name = "Airlock"
	icon = 'icons/obj/doors/doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/research/voxresearch
	name = "Airlock"
	icon = 'icons/obj/doors/doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	var/const/AIRLOCK_WIRE_IDSCAN = 0

/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorresearchglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/glass_research/voxresearch
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorresearchglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1
	penetration_dampening = 3
	var/const/AIRLOCK_WIRE_IDSCAN = 0

/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/gold
	name = "Gold Airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = "Silver Airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = "Diamond Airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"
	penetration_dampening = 15

/obj/machinery/door/airlock/uranium
	name = "Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"
	var/last_event = 0

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.apply_effect(15,IRRADIATE,0)
	return

/obj/machinery/door/airlock/plasma
	name = "Plasma Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

	autoignition_temperature = 300
	fire_fuel = 10

/obj/machinery/door/airlock/plasma/ignite(temperature)
	PlasmaBurn(temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))
//		if(target_tile.parent && target_tile.parent.group_processing) // THESE PROBABLY DO SOMETHING IMPORTANT BUT I DON'T KNOW HOW TO FIX IT - Erthilo
//			target_tile.parent.suspend_group_processing()
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 35
		napalm.toxins = toxinsToDeduce
		napalm.temperature = 400+T0C
		target_tile.assume_air(napalm)
		spawn (0)
			target_tile.hotspot_expose(temperature, 400, surfaces=1)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until fire_act works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ChangeTurf(/turf/simulated/wall/mineral/plasma/)
		qdel (F)
		F = null
	for(var/turf/simulated/wall/mineral/plasma/W in range(3,src))
		W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	new/obj/structure/door_assembly( src.loc )
	qdel (src)

/obj/machinery/door/airlock/clown
	name = "Bananium Airlock"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	mineral = "clown"
	soundeffect = 'sound/items/bikehorn.ogg'

/obj/machinery/door/airlock/sandstone
	name = "Sandstone Airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

/obj/machinery/door/airlock/science
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = "Glass Airlocks"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = 1
	penetration_dampening = 3

/obj/machinery/door/airlock/highsecurity
	name = "High Tech Security Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity
	emag_cost = 2 // in MJ

/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be <span class='warning'>open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/
// You can find code for the airlock wires in the wire datum folder.


/obj/machinery/door/airlock/bump_open(mob/living/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!istype(user)) return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = 1
<<<<<<< HEAD
=======
					user.delayNextMove(10)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
					spawn (10)
						src.justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(user.hallucination > 50 && prob(10) && src.operating == 0)
<<<<<<< HEAD
			user << "<span class='userdanger'>You feel a powerful shock course through your body!</span>"
			user.staminaloss += 50
			user.stunned += 5
			return
	if (cyclelinkedairlock)
		if (!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency && allowed(user))
			addtimer(cyclelinkedairlock, "close", ( cyclelinkedairlock.operating ? 2 : 0 ))
	..()

=======
			to_chat(user, "<span class='danger'>You feel a powerful shock course through your body!</span>")
			user.halloss += 10
			user.stunned += 10
			return
	..(user)

/obj/machinery/door/Bumped(atom/AM)
	if (panel_open)
		return

	..(AM)

	return

/obj/machinery/door/airlock/bump_open(mob/living/simple_animal/user as mob)
	..(user)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != 0)
		return 1
	return 0

<<<<<<< HEAD
/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	return ((aiControlDisabled != 1) && (!isAllPowerCut()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	return ((secondsMainPowerLost == 0 || secondsBackupPowerLost == 0) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE
=======
/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	// You can find the wires in the datum folder.
	if(!wires)
		return 1
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	return (src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	var/retval=0
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			retval=1
	return retval
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/door/airlock/proc/regainMainPower()
	if(src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if(src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if(src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if(!src.spawnPowerRestoreRunning)
		src.spawnPowerRestoreRunning = 1
		spawn(0)
			var/cont = 1
			while (cont)
				sleep(10)
<<<<<<< HEAD
				if(qdeleted(src))
					return
				cont = 0
				if(secondsMainPowerLost>0)
					if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
						secondsMainPowerLost -= 1
						updateDialog()
					cont = 1

				if(secondsBackupPowerLost>0)
					if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
						secondsBackupPowerLost -= 1
						updateDialog()
					cont = 1
			spawnPowerRestoreRunning = 0
			updateDialog()
=======
				cont = 0
				if(src.secondsMainPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.secondsMainPowerLost -= 1
						src.updateDialog()
					cont = 1

				if(src.secondsBackupPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.secondsBackupPowerLost -= 1
						src.updateDialog()
					cont = 1
			src.spawnPowerRestoreRunning = 0
			src.updateDialog()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
<<<<<<< HEAD
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
=======
/obj/machinery/door/airlock/shock(mob/user, prb)
	if((stat & (NOPOWER)) || !src.arePowerSystemsOn())		// unpowered, no shock
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
<<<<<<< HEAD
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
=======
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if(electrocute_mob(user, get_area(src), src))
		hasShocked = 1
		spawn(10)
			hasShocked = 0
		return 1
	else
		return 0

<<<<<<< HEAD
/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/image/frame_overlay
	var/image/filling_overlay
	var/image/lights_overlay
	var/image/panel_overlay
	var/image/weld_overlay
	var/image/sparks_overlay

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_closing", overlays_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_open", overlays_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				panel_overlay = get_airlock_overlay("panel_opening", overlays_file)

	//doesn't use cut_overlays() for performance reasons
	if(frame_overlay != old_frame_overlay)
		overlays -= old_frame_overlay
		add_overlay(frame_overlay)
		old_frame_overlay = frame_overlay
	if(filling_overlay != old_filling_overlay)
		overlays -= old_filling_overlay
		add_overlay(filling_overlay)
		old_filling_overlay = filling_overlay
	if(lights_overlay != old_lights_overlay)
		overlays -= old_lights_overlay
		add_overlay(lights_overlay)
		old_lights_overlay = lights_overlay
	if(panel_overlay != old_panel_overlay)
		overlays -= old_panel_overlay
		add_overlay(panel_overlay)
		old_panel_overlay = panel_overlay
	if(weld_overlay != old_weld_overlay)
		overlays -= old_weld_overlay
		add_overlay(weld_overlay)
		old_weld_overlay = weld_overlay
	if(sparks_overlay != old_sparks_overlay)
		overlays -= old_sparks_overlay
		add_overlay(sparks_overlay)
		old_sparks_overlay = sparks_overlay

/proc/get_airlock_overlay(icon_state, icon_file)
	var/iconkey = "[icon_state][icon_file]"
	if(airlock_overlays[iconkey])
		return airlock_overlays[iconkey]
	airlock_overlays[iconkey] = image(icon_file, icon_state)
	return airlock_overlays[iconkey]

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(charge && !panel_open && in_range(user, src))
		user << "<span class='warning'>The maintenance panel seems haphazardly fastened.</span>"
	if(charge && panel_open)
		user << "<span class='warning'>Something is wired up to the airlock's electronics!</span>"

/obj/machinery/door/airlock/attack_ai(mob/user)
	if(!src.canAIControl(user))
		if(src.canAIHack())
			src.hack(user)
			return
		else
			user << "<span class='warning'>Airlock AI control has been blocked with a firewall. Unable to hack.</span>"
	if(emagged)
		user << "<span class='warning'>Unable to interface: Airlock is unresponsive.</span>"
		return
	if(detonated)
		user << "<span class='warning'>Unable to interface. Airlock control panel damaged.</span>"
		return

	//Separate interface for the AI.
	user.set_machine(src)
	var/t1 = text("<B>Airlock Control</B><br>\n")
	if(src.secondsMainPowerLost > 0)
		if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
=======

/obj/machinery/door/airlock/update_icon()
	overlays = 0

	if(density)
		if(locked && lights)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if (panel_open || welded)
			var/L[0]
			if (panel_open)
				L += "panel_open"

			if (welded)
				L += "welded"

			overlays = L
			L = null
	else
		icon_state = "door_open"

	return

/obj/machinery/door/airlock/door_animate(var/animation)
	switch(animation)
		if("opening")
			if(overlays) overlays.len = 0
			if(panel_open)
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays.len = 0
			if(panel_open)
				flick("o_door_closing", src)
			else
				flick("door_closing", src)
		if("spark")
			flick("door_spark", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	if(isAI(user))
		if(!src.canAIControl())
			if(src.canAIHack())
				src.hack(user)
				return
			else
				to_chat(user, "Airlock AI control has been blocked with a firewall. Unable to hack.")

	//separate interface for the AI.
	user.set_machine(src)
	var/t1 = text("<B>Airlock Control</B><br>\n")
	if(src.secondsMainPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
<<<<<<< HEAD
		if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
=======
		if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

<<<<<<< HEAD
	if(wires.is_cut(WIRE_IDSCAN))
=======
	if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

<<<<<<< HEAD
	if(src.emergency)
		t1 += text("Emergency Access Override is enabled. <A href='?src=\ref[];aiDisable=11'>Disable?</a><br>\n", src)
	else
		t1 += text("Emergency Access Override is disabled. <A href='?src=\ref[];aiEnable=11'>Enable?</a><br>\n", src)

	if(wires.is_cut(WIRE_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(wires.is_cut(WIRE_POWER2))
=======
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(src.secondsMainPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(src.secondsBackupPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

<<<<<<< HEAD
	if(wires.is_cut(WIRE_BACKUP1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(wires.is_cut(WIRE_BACKUP2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(wires.is_cut(WIRE_BOLTS))
=======
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
<<<<<<< HEAD
		if(src.hasPower())
=======
		if(src.arePowerSystemsOn())
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

<<<<<<< HEAD
	if(wires.is_cut(WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door bolt lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door bolt lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(wires.is_cut(WIRE_SHOCK))
=======
	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		t1 += text("Electrification wire is cut.<br>\n")
	if(src.secondsElectrified==-1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(src.secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

<<<<<<< HEAD
	if(wires.is_cut(WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'>Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'>Restore?</a><br>\n",src)

	if(wires.is_cut(WIRE_TIMING))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'>Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'>Restore?</a><br>\n",src)
=======
	if(src.isWireCut(AIRLOCK_WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(src.welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!src.locked)
		if(src.density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)
	user << browse(t1, "window=airlock")
	onclose(user, "airlock")

<<<<<<< HEAD
//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 11 lift access override
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 11 enable access override


/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(src.aiHacking == 0)
		src.aiHacking = 1
		user << "Airlock AI control has been blocked. Beginning fault-detection."
		sleep(50)
		if(src.canAIControl(user))
			user << "Alert cancelled. Airlock control has been restored without our assistance."
			src.aiHacking=0
			return
		else if(!src.canAIHack())
			user << "Connection lost! Unable to hack airlock."
			src.aiHacking=0
			return
		user << "Fault confirmed: airlock control wire disabled or cut."
		sleep(20)
		user << "Attempting to hack into airlock. This may take some time."
		sleep(200)
		if(src.canAIControl(user))
			user << "Alert cancelled. Airlock control has been restored without our assistance."
			src.aiHacking=0
			return
		else if(!src.canAIHack())
			user << "Connection lost! Unable to hack airlock."
			src.aiHacking=0
			return
		user << "Upload access confirmed. Loading control program into airlock software."
		sleep(170)
		if(src.canAIControl(user))
			user << "Alert cancelled. Airlock control has been restored without our assistance."
			src.aiHacking=0
			return
		else if(!src.canAIHack())
			user << "Connection lost! Unable to hack airlock."
			src.aiHacking=0
			return
		user << "Transfer complete. Forcing airlock to execute program."
		sleep(50)
		//disable blocked control
		src.aiControlDisabled = 2
		user << "Receiving control information from airlock."
		sleep(10)
		//bring up airlock dialog
		src.aiHacking = 0
		if(user)
			src.attack_ai(user)

/obj/machinery/door/airlock/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(!(istype(user, /mob/living/silicon) || IsAdminGhost(user)))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.visible_message("<span class='danger'>[user] headbutts the airlock.</span>", \
									"<span class='userdanger'>You headbutt the airlock!</span>")
				var/obj/item/bodypart/affecting = H.get_bodypart("head")
				H.Stun(5)
				H.Weaken(5)
				if(affecting && affecting.take_damage(10, 0))
					H.update_damage_overlays(0)
			else
				visible_message("<span class='danger'>[user] headbutts the airlock. Good thing they're wearing a helmet.</span>")
			return

	if(panel_open)
		wires.interact(user)
	else
		..()
	return

=======
//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door


/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(src.aiHacking==0)
		src.aiHacking=1
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
			src.aiControlDisabled = 2
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			src.aiHacking = 0
			if (user)
				src.attack_ai(user)

/obj/machinery/door/airlock/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.materials && (i.materials.getAmount(MAT_IRON) > 0))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
<<<<<<< HEAD
	if(!nowindow)
		..()
	if(usr.incapacitated() && !IsAdminGhost(usr))
		return
=======
	var/turf/T = get_turf(usr)
	if(!isAI(usr) && T.z != z) return 1
	if(!nowindow)
		..()
	if(!isAdminGhost(usr))
		if(usr.stat || usr.restrained() || (usr.size < SIZE_SMALL))
			//testing("Returning: Not adminghost, stat=[usr.stat], restrained=[usr.restrained()], small=[usr.small]")
			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.machine==src)
			usr.unset_machine()
			return

<<<<<<< HEAD
	if((in_range(src, usr) && istype(src.loc, /turf)) && panel_open)
		usr.set_machine(src)



	if((istype(usr, /mob/living/silicon) && src.canAIControl(usr)) || IsAdminGhost(usr))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed, 11 emergency access
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed, 11 emergency access
=======
	var/am_in_range=in_range(src, usr)
	var/turf_ok = istype(src.loc, /turf)
	//testing("in range: [am_in_range], turf ok: [turf_ok]")
	if(am_in_range && turf_ok)
		usr.set_machine(src)
		if(!panel_open)
			var/obj/item/device/multitool/P = get_multitool(usr)
			if(P && istype(P))
				if("set_id" in href_list)
					var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text),1,MAX_MESSAGE_LEN)
					if(newid)
						id_tag = newid
						initialize()
				if("set_freq" in href_list)
					var/newfreq=frequency
					if(href_list["set_freq"]!="-1")
						newfreq=text2num(href_list["set_freq"])
					else
						newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, frequency) as null|num
					if(newfreq)
						if(findtext(num2text(newfreq), "."))
							newfreq *= 10 // shift the decimal one place
						if(newfreq < 10000)
							frequency = newfreq
							initialize()

				usr.set_machine(src)
				update_multitool_menu(usr)


	if(isAdminGhost(usr) || (istype(usr, /mob/living/silicon) && src.canAIControl()))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
<<<<<<< HEAD
					if(wires.is_cut(WIRE_IDSCAN))
						usr << "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways."
					else if(src.aiDisabledIdScanner)
						usr << "You've already disabled the IdScan feature."
					else
=======
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
					else if(src.aiDisabledIdScanner)
						to_chat(usr, "You've already disabled the IdScan feature.")
					else
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled IDScan on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
						src.aiDisabledIdScanner = 1
				if(2)
					//disrupt main power
					if(src.secondsMainPowerLost == 0)
<<<<<<< HEAD
						src.loseMainPower()
						update_icon()
					else
						usr << "Main power is already offline."
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						src.loseBackupPower()
						update_icon()
					else
						usr << "Backup power is already offline."
				if(4)
					//drop door bolts
					if(wires.is_cut(WIRE_BOLTS))
						usr << "You can't drop the door bolts - The door bolt dropping wire has been cut."
					else
						bolt()
				if(5)
					//un-electrify door
					if(wires.is_cut(WIRE_SHOCK))
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.")
					else if(src.secondsElectrified==-1)
						src.secondsElectrified = 0
					else if(src.secondsElectrified>0)
						src.secondsElectrified = 0

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if(wires.is_cut(WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (src.safe)
						safe = 0
					else
						usr << text("Firmware reports safeties already overriden.")

				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						usr << text("Control to door timing circuitry has been severed.")
					else if (src.normalspeed)
						normalspeed = 0
					else
						usr << text("Door timing circuitry already accelerated.")
				if(7)
					//close door
					if(src.welded)
						usr << text("The airlock has been welded shut!")
					else if(src.locked)
						usr << text("The door bolts are down!")
					else if(!src.density)
						close()
					else
						open()

				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (src.lights)
						lights = 0
						update_icon()
					else
						usr << text("Door bolt lights are already disabled!")

				if(11)
					// Emergency access
					if (src.emergency)
						emergency = 0
						update_icon()
					else
						usr << text("Emergency access is already disabled!")
=======
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted main power on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.loseMainPower()
					else
						to_chat(usr, "Main power is already offline.")
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted backup power on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.loseBackupPower()
					else
						to_chat(usr, "Backup power is already offline.")
				if(4)
					//drop door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "You can't drop the door bolts - The door bolt dropping wire has been cut.")
					else if(src.locked!=1)
						if(isobserver(usr) && !canGhostWrite(usr,src,"dropped bolts on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.locked = 1
						to_chat(usr, "The door is now bolted.")
						investigation_log(I_WIRES, "|| bolted via robot interface by [key_name(usr)]")
						update_icon()
				if(5)
					//un-electrify door
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("Can't un-electrify the airlock - The electrification wire is cut."))
					else if(src.secondsElectrified==-1)
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.secondsElectrified = 0
						to_chat(usr, "The door is now un-electrified.")
						investigation_log(I_WIRES, "|| un-electrified via robot interface by [key_name(usr)]")
					else if(src.secondsElectrified>0)
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.secondsElectrified = 0
						to_chat(usr, "The door is now un-electrified.")
						investigation_log(I_WIRES, "|| un-electrified via robot interface by [key_name(usr)]")

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (src.safe)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled safeties on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						safe = 0
						investigation_log(I_WIRES, "|| safeties removed via robot interface by [key_name(usr)]")
					else
						to_chat(usr, text("Firmware reports safeties already overriden."))



				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (src.normalspeed)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted timing on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						normalspeed = 0
						investigation_log(I_WIRES, "|| door timing disrupted via robot interface by [key_name(usr)]")
					else
						to_chat(usr, text("Door timing circurity already accellerated."))

				if(7)
					//close door
					if(src.welded)
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(!src.density)
						if(isobserver(usr) && !canGhostWrite(usr,src,"closed"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						close()
						investigation_log(I_WIRES, "|| closed via robot interface by [key_name(usr)]")
					else
						if(isobserver(usr) && !canGhostWrite(usr,src,"opened"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						open()
						investigation_log(I_WIRES, "|| opened via robot interface by [key_name(usr)]")

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, text("Control to door bolt lights has been severed.</a>"))
					else if (src.lights)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled door bolt lights on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						lights = 0
					else
						to_chat(usr, text("Door bolt lights are already disabled!"))

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
<<<<<<< HEAD
					if(wires.is_cut(WIRE_IDSCAN))
						usr << "You can't enable IdScan - The IdScan wire has been cut."
					else if(src.aiDisabledIdScanner)
						src.aiDisabledIdScanner = 0
					else
						usr << "The IdScan feature is not disabled."
				if(4)
					//raise door bolts
					if(wires.is_cut(WIRE_BOLTS))
						usr << text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if(!src.locked)
						usr << text("The door bolts are already up.<br>\n")
					else
						if(src.hasPower())
							unbolt()
						else
							usr << text("Cannot raise door bolts due to power failure.<br>\n")

				if(5)
					//electrify door for 30 seconds
					if(wires.is_cut(WIRE_SHOCK))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						add_logs(usr, src, "electrified")
=======
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "You can't enable IdScan - The IdScan wire has been cut.")
					else if(src.aiDisabledIdScanner)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled ID Scan on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						src.aiDisabledIdScanner = 0
					else
						to_chat(usr, "The IdScan feature is not disabled.")
				if(4)
					//raise door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n"))
					else if(!src.locked)
						to_chat(usr, text("The door bolts are already up.<br>\n"))
					else
						if(src.arePowerSystemsOn())
							if(isobserver(usr) && !canGhostWrite(usr,src,"raised bolts on"))
								to_chat(usr, "<span class='warning'>Nope.</span>")
								return 0
							src.locked = 0
							to_chat(usr, "The door is now unbolted.")
							update_icon()
						else
							to_chat(usr, text("Cannot raise door bolts due to power failure.<br>\n"))

				if(5)
					//electrify door for 30 seconds
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(src.secondsElectrified==-1)
						to_chat(usr, text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n"))
					else if(src.secondsElectrified!=0)
						to_chat(usr, text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
						investigation_log(I_WIRES, "|| temporarily electrified via robot interface by [key_name(usr)]")
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified (30sec)"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
						src.secondsElectrified = 30
						spawn(10)
							while (src.secondsElectrified>0)
								src.secondsElectrified-=1
								if(src.secondsElectrified<0)
									src.secondsElectrified = 0
								src.updateUsrDialog()
								sleep(10)
				if(6)
					//electrify door indefinitely
<<<<<<< HEAD
					if(wires.is_cut(WIRE_SHOCK))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						add_logs(usr, src, "electrified")
=======
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(src.secondsElectrified==-1)
						to_chat(usr, text("The door is already indefinitely electrified.<br>\n"))
					else if(src.secondsElectrified!=0)
						to_chat(usr, text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
						investigation_log(I_WIRES, "|| electrified via robot interface by [key_name(usr)]")
						to_chat(usr, "The door is now electrified indefinitely.")
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified (permanent)"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
						src.secondsElectrified = -1

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
<<<<<<< HEAD
					if(wires.is_cut(WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (!src.safe)
						safe = 1
						src.updateUsrDialog()
					else
						usr << text("Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						usr << text("Control to door timing circuitry has been severed.")
					else if (!src.normalspeed)
						normalspeed = 1
						src.updateUsrDialog()
					else
						usr << text("Door timing circuitry currently operating normally.")
=======
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (!src.safe)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled safeties on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						safe = 1
						src.updateUsrDialog()
					else
						to_chat(usr, text("Firmware reports safeties already in place."))

				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (!src.normalspeed)
						if(isobserver(usr) && !canGhostWrite(usr,src,"set speed to normal on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						normalspeed = 1
						src.updateUsrDialog()
					else
						to_chat(usr, text("Door timing circurity currently operating normally."))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

				if(7)
					//open door
					if(src.welded)
<<<<<<< HEAD
						usr << text("The airlock has been welded shut!")
					else if(src.locked)
						usr << text("The door bolts are down!")
					else if(src.density)
						open()
					else
						close()
				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (!src.lights)
						lights = 1
						update_icon()
						src.updateUsrDialog()
					else
						usr << text("Door bolt lights are already enabled!")
				if(11)
					// Emergency access
					if (!src.emergency)
						emergency = 1
						update_icon()
					else
						usr << text("Emergency access is already enabled!")

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user, params)
	if(!issilicon(user) && !IsAdminGhost(user))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	add_fingerprint(user)
	if(istype(C, /obj/item/weapon/screwdriver))
		if(panel_open && detonated)
			user << "<span class='warning'>[src] has no maintenance panel!</span>"
			return
		panel_open = !panel_open
		user << "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the airlock.</span>"
		src.update_icon()
	else if(is_wire_tool(C))
		return attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/device/doorCharge))
		if(!panel_open)
			user << "<span class='warning'>The maintenance panel must be open to apply [C]!</span>"
			return
		if(emagged)
			return
		if(charge && !detonated)
			user << "<span class='warning'>There's already a charge hooked up to this door!</span>"
			return
		if(detonated)
			user << "<span class='warning'>The maintenance panel is destroyed!</span>"
			return
		user << "<span class='warning'>You apply [C]. Next time someone opens the door, it will explode.</span>"
		user.drop_item()
		panel_open = 0
		update_icon()
		C.loc = src
		charge = C
	else
		return ..()


/obj/machinery/door/airlock/try_to_weld(obj/item/weapon/weldingtool/W, mob/user)
	if(!operating && density)
		if(W.remove_fuel(0,user))
			user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
							"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")
			playsound(loc, 'sound/items/Welder.ogg', 40, 1)
			if(do_after(user,40/W.toolspeed, 1, target = src))
				if(density && !operating)//Door must be closed to weld.
					if(!user || !W || !W.isOn() || !user.loc )
						return
					playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
					welded = !welded
					user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
										"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
					update_icon()

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/user)
	var/beingcrowbarred = null
	if(istype(I, /obj/item/weapon/crowbar) )
		beingcrowbarred = 1
	else
		beingcrowbarred = 0
	if(panel_open && charge)
		user << "<span class='notice'>You carefully start removing [charge] from [src]...</span>"
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		if(!do_after(user, 150/I.toolspeed, target = src))
			user << "<span class='warning'>You slip and [charge] detonates!</span>"
			charge.ex_act(1)
			user.Weaken(3)
			return
		user.visible_message("<span class='notice'>[user] removes [charge] from [src].</span>", \
							 "<span class='notice'>You gently pry out [charge] from [src] and unhook its wires.</span>")
		charge.loc = get_turf(user)
		charge = null
		return
	if( beingcrowbarred && (density && welded && !operating && src.panel_open && (!hasPower()) && !src.locked) )
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
							 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
		if(do_after(user,40/I.toolspeed, target = src))
			if(src.loc)
				if(assemblytype)
					var/obj/structure/door_assembly/A = new assemblytype(src.loc)
					A.heat_proof_finished = src.heat_proof //tracks whether there's rglass in
				else
					new /obj/structure/door_assembly/door_assembly_0(src.loc)
					//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.

				if(emagged)
					user << "<span class='warning'>You discard the damaged electronics.</span>"
					qdel(src)
					return
				user << "<span class='notice'>You remove the airlock electronics.</span>"

				var/obj/item/weapon/electronics/airlock/ae
				if(!electronics)
					ae = new/obj/item/weapon/electronics/airlock( src.loc )
					if(req_one_access)
						ae.one_access = 1
						ae.accesses = src.req_one_access
					else
						ae.accesses = src.req_access
				else
					ae = electronics
					electronics = null
					ae.loc = src.loc

				qdel(src)
				return
	else if(hasPower())
		user << "<span class='warning'>The airlock's motors resist your efforts to force it!</span>"
	else if(locked)
		user << "<span class='warning'>The airlock's bolts prevent it from being forced!</span>"
	else if( !welded && !operating)
		if(beingcrowbarred == 0) //being fireaxe'd
			var/obj/item/weapon/twohanded/fireaxe/F = I
			if(F.wielded)
				spawn(0)
					if(density)
						open(2)
					else
						close(2)
			else
				user << "<span class='warning'>You need to be wielding the fire axe to do that!</span>"
		else
			spawn(0)
				if(density)
					open(2)
				else
					close(2)

/obj/machinery/door/airlock/plasma/attackby(obj/item/C, mob/user, params)
	if(C.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma airlock ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(src)]")
		log_game("Plasma wall ignited by [key_name(user)] in [COORD(src)]")
		ignite(C.is_hot())
	else
		return ..()

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked )
		return 0
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_OPEN))
			return 0
	if(charge && !detonated)
		panel_open = 1
		update_icon(AIRLOCK_OPENING)
		visible_message("<span class='warning'>[src]'s panel is blown off in a spray of deadly shrapnel!</span>")
		charge.loc = get_turf(src)
		charge.ex_act(1)
		detonated = 1
		charge = null
		for(var/mob/living/carbon/human/H in orange(2,src))
			H.Paralyse(8)
			H.adjust_fire_stacks(20)
			H.IgniteMob() //Guaranteed knockout and ignition for nearby people
			H.apply_damage(40, BRUTE, "chest")
		return
	if(forced < 2)
		if(emagged)
			return 0
		use_power(50)
		playsound(src.loc, doorOpen, 30, 1)
		if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
			src.closeOther.close()
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	if(autoclose && normalspeed)
		addtimer(src, "autoclose", 150)
	else if(autoclose && !normalspeed)
		addtimer(src, "autoclose", 10)

	if(!density)
		return 1
	if(!ticker || !ticker.mode)
		return 0
	operating = 1
	update_icon(AIRLOCK_OPENING, 1)
	src.SetOpacity(0)
	sleep(5)
	src.density = 0
	sleep(9)
	src.layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	SetOpacity(0)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	return 1


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				addtimer(src, "autoclose", 60)
				return

	if(forced < 2)
		if(emagged)
			return
		use_power(50)
		playsound(src.loc, doorClose, 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(2)//Smashin windows

	if(density)
		return 1
	operating = 1
	update_icon(AIRLOCK_CLOSING, 1)
	src.layer = CLOSED_DOOR_LAYER
	sleep(5)
	src.density = 1
	if(!safe)
		crush()
	sleep(9)
	update_icon(AIRLOCK_CLOSED, 1)
	if(visible && !glass)
		SetOpacity(1)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	if(safe)
		CheckForMobs()
	return 1

/obj/machinery/door/airlock/proc/prison_open()
	if(emagged)
		return
	src.locked = 0
	src.open()
	src.locked = 1
	return


/obj/machinery/door/airlock/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!W.can_use(user))
		return

	var/list/optionlist
	if(airlock_material == "glass")
		optionlist = list("Public", "Public2", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance")
	else
		optionlist = list("Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")

	var/paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
	if((!in_range(src, usr) && src.loc != usr) || !W.use(user))
		return
	switch(paintjob)
		if("Public")
			icon = 'icons/obj/doors/airlocks/station/public.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_0
		if("Public2")
			icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_glass
		if("Engineering")
			icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_eng
		if("Atmospherics")
			icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_atmo
		if("Security")
			icon = 'icons/obj/doors/airlocks/station/security.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_sec
		if("Command")
			icon = 'icons/obj/doors/airlocks/station/command.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_com
		if("Medical")
			icon = 'icons/obj/doors/airlocks/station/medical.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_med
		if("Research")
			icon = 'icons/obj/doors/airlocks/station/research.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_research
		if("Mining")
			icon = 'icons/obj/doors/airlocks/station/mining.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_min
		if("Maintenance")
			icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_mai
		if("External")
			icon = 'icons/obj/doors/airlocks/external/external.dmi'
			overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_ext
		if("High Security")
			icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
			overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	update_icon()

/obj/machinery/door/airlock/CanAStarPass(obj/item/weapon/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut or powered off)
	return !density || (check_access(ID) && !locked && hasPower())

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && hasPower() && !emagged)
		operating = 1
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(qdeleted(src))
			return
		operating = 0
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		emagged = 1
		desc = "<span class='warning'>Its access panel is smoking slightly.</span>"
		lights = 0
		locked = 1
		loseMainPower()
		loseBackupPower()

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified())
		shock(user, 100) //Mmm, fried xeno!
		return
	if(!density) //Already open
		return
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		user << "<span class='warning'>[src] refuses to budge!</span>"
		return
	user.visible_message("<span class='warning'>[user] begins prying open [src].</span>",\
						"<span class='noticealien'>You begin digging your claws into [src] with all your might!</span>",\
						"<span class='warning'>You hear groaning metal...</span>")
	var/time_to_open = 5
	if(hasPower())
		time_to_open = 50 //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)


	if(do_after(user, time_to_open, target = src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			user << "<span class='warning'>Despite your efforts, [src] managed to resist your attempts to open it!</span>"

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		bolt() //Bolt it!
		secondsElectrified = -1  //Shock it!
		if(origin)
			shockedby += "\[[time_stamp()]\][origin](ckey:[origin.ckey])"


/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		unbolt()
		secondsElectrified = 0
		open()
		safe = TRUE
=======
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(src.density)
						if(isobserver(usr) && !canGhostWrite(usr,src,"opened"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						open()
						investigation_log(I_WIRES, "|| opened via robot interface by [key_name(usr)]")
					else
						if(isobserver(usr) && !canGhostWrite(usr,src,"closed"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						close()
						investigation_log(I_WIRES, "|| closed via robot interface by [key_name(usr)]")

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, text("Control to door bolt lights has been severed.</a>"))
					else if (!src.lights)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled bolt lights on"))
							to_chat(usr, "<span class='warning'>Nope.</span>")
							return 0
						lights = 1
						src.updateUsrDialog()
					else
						to_chat(usr, text("Door bolt lights are already enabled!"))

	add_fingerprint(usr)
	update_icon()
	if(!nowindow)
		updateUsrDialog()
	return

/obj/machinery/door/airlock/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	var/dat=""
	if(src.requiresID() && !allowed(user))
		return {"<b>Access Denied.</b>"}
	else
		var/dis_id_tag="-----"
		if(id_tag!=null && id_tag!="")
			dis_id_tag=id_tag
		dat += {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[0]">Reset</a>)</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>
		</ul>"}

	return dat

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if (!istype(user, /mob/living/silicon) && !isobserver(user) && Adjacent(user))
		if (isElectrified())
			// TODO: analyze the called proc
			if (shock(user, 100))
				user.delayNextAttack(10)
				return
	//Basically no open panel, not opening already, door has power, area has power, door isn't bolted
	if (!panel_open && !operating && arePowerSystemsOn() && !(stat & (NOPOWER|BROKEN)) && !locked)
		..(user)
	//else
	//	// TODO: logic for adding fingerprints when interacting with wires
	//	wires.Interact(user)

	return

//You can ALWAYS screwdriver a door. Period. Well, at least you can even if it's open
/obj/machinery/door/airlock/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(!operating)
		panel_open = !panel_open
		update_icon()
		return 1
	return

/obj/machinery/door/airlock/attackby(obj/item/I as obj, mob/user as mob)
	if(isAI(user) || isobserver(user))
		return attack_ai(user)

	if (!istype(user, /mob/living/silicon))
		if (isElectrified())
			// TODO: analyze the called proc
			if (shock(user, 75))
				user.delayNextAttack(10)
				return

	if(istype(I, /obj/item/weapon/batteringram))
		user.delayNextAttack(30)
		var/breaktime = 60 //Same amount of time as drilling a wall, then a girder
		if(welded)
			breaktime += 30 //Welding buys you a little time
		src.visible_message("<span class='warning'>[user] is battering down [src]!</span>", "<span class='warning'>You begin to batter [src].</span>")
		playsound(get_turf(src), 'sound/effects/shieldbash.ogg', 50, 1)
		if(do_after(user,src, breaktime))
			//Calculate bolts separtely, in case they dropped in the last 6-9 seconds.
			if(src.locked == 1)
				playsound(get_turf(src), 'sound/effects/shieldbash.ogg', 50, 1)
				src.visible_message("<span class='warning'>[user] is battering the bolts!</span>", "<span class='warning'>You begin to smash the bolts...</span>")
				if(!do_after(user, src,190)) //Same amount as drilling an R-wall, longer if it was welded
					return //If they moved, cancel us out
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			src.visible_message("<span class='warning'>[user] broke down the door!</span>", "<span class='warning'>You broke the door!</span>")
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			operating = -1
			var/obj/structure/door_assembly/DA = revert(user,user.dir)
			DA.anchored = 0
			DA.state = 0 //Completely smash the door here; reduce it to its lowest state, eject electronics smoked
			DA.update_state()
			qdel(src)
		return

	if (iswelder(I))
		if (density && !operating)
			var/obj/item/weapon/weldingtool/WT = I

			// TODO: analyze the called proc
			if (WT.remove_fuel(0, user))
				if (!welded)
					welded = 1
				else
					welded = null

				update_icon()
	else if (ismultitool(I))
		if (!operating)
			if(panel_open) wires.Interact(user)
			else update_multitool_menu(user)
		attack_hand(user)
	else if (iswiretool(I))
		if (!operating && panel_open)
			wires.Interact(user)
	else if(iscrowbar(I) || istype(I, /obj/item/weapon/fireaxe) )
		if(src.busy) return
		src.busy = 1
		var/beingcrowbarred = null
		if(iscrowbar(I) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && (operating == -1 || density && welded && !operating && src.panel_open && (!src.arePowerSystemsOn() || stat & NOPOWER) && !src.locked) )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			// TODO: refactor the called proc
			if (do_after(user, src, 40))
				to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")
				revert(user,null)
				qdel(src)
				return
		else if(arePowerSystemsOn() && !(stat & NOPOWER))
			to_chat(user, "<span class='notice'>The airlock's motors resist your efforts to force it.</span>")
		else if(locked)
			to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/fireaxe/F = I
					if(F.wielded)
						spawn(0)	open(1)
					else
						to_chat(user, "<span class='warning'>You need to be wielding the Fire axe to do that.</span>")
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/fireaxe/F = I
					if(F.wielded)
						spawn(0)	close(1)
					else
						to_chat(user, "<span class='warning'>You need to be wielding the Fire axe to do that.</span>")
				else
					spawn(0)	close(1)
		src.busy = 0
	else if (istype(I, /obj/item/weapon/card/emag))
		if (!operating)
			operating = -1
			if(density)
				door_animate("spark")
				sleep(6)
				open(1)
			operating = -1
	else
		..(I, user)

	return

/obj/machinery/door/airlock/proc/revert(mob/user as mob, var/direction)
	var/obj/structure/door_assembly/DA = new assembly_type(loc)
	DA.anchored = 1
	DA.fingerprints += src.fingerprints
	DA.fingerprintshidden += src.fingerprintshidden
	DA.fingerprintslast = user.ckey
	if (mineral)
		DA.glass = mineral
	else if (glass && !DA.glass)
		DA.glass = 1

	DA.state = 1
	DA.created_name = name
	DA.update_state()

	var/obj/item/weapon/circuitboard/airlock/A

	if (!electronics)
		A = new/obj/item/weapon/circuitboard/airlock(loc)
		if(req_access && req_access.len)
			A.conf_access = req_access
		else if(req_one_access && req_one_access.len)
			A.conf_access = req_one_access
			A.one_access = 1
	else
		A = electronics
		electronics = null
		A.loc = loc
		A.installed = 0

	if (operating == -1)
		A.icon_state = "door_electronics_smoked"
		operating = 0
	if(direction)
		A.throw_at(get_edge_target_turf(src, direction),10,4)
	return DA //Returns the new assembly

/obj/machinery/door/airlock/plasma/attackby(obj/C, mob/user)
	var/heat = C.is_hot()
	if(heat > 300)
		ignite(heat)
	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if((operating && !forced) || locked || welded)
		return 0
	if(!forced)
		if( !arePowerSystemsOn() || (stat & NOPOWER) || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	use_power(50)
	playsound(get_turf(src), soundeffect, pitch, 1)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()
	// This worries me - N3X
	if(!forced)
		if(autoclose  && normalspeed)
			spawn(150)
				autoclose()
		else if(autoclose && !normalspeed)
			spawn(20)
				autoclose()
	// </worry>
	return ..()

/obj/machinery/door/airlock/close(var/forced = 0 as num)
	if (operating || locked || welded)
		return
	if(!forced)
		if( !arePowerSystemsOn() || (stat & NOPOWER) || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) )
			return

	use_power(50)

	if (safe)
		for (var/turf/T in locs)
			// sticky web has jammed door open
			if (locate(/obj/effect/spider/stickyweb) in T)
				return

			if (locate(/mob/living) in T)
				playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 0)
				if(autoclose  && normalspeed)
					spawn(150)
						autoclose()
				else if(autoclose && !normalspeed)
					spawn(20)
						autoclose()
				return

	else
		for (var/turf/T in locs)
			for(var/mob/living/L in T)
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)

				if (isrobot(L))
					continue

				L.SetStunned(5)
				L.SetWeakened(5)
				var/obj/effect/stop/S = new()
				S.loc = loc
				S.victim = L

				spawn (20)
					qdel(S)
					S = null

				L.emote("scream",,, 1)

				if (istype(loc, /turf/simulated))
					T.add_blood(L)

	playsound(get_turf(src),soundeffect, 30, 1)

	for(var/turf/T in loc)
		var/obj/structure/window/W = locate(/obj/structure/window) in T
		if (W)
			W.Destroy(brokenup = 1)

	..()
	return

/obj/machinery/door/airlock/New()
	. = ..()
	wires = new(src)
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in all_doors)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break

/obj/machinery/door/airlock/proc/prison_open()
	locked = 0
	open()
	locked = 1
	return

/obj/machinery/door/airlock/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		//attack_ai(P)
		open(1)
		return 1
	return 0

/obj/machinery/door/airlock/shake()
	return //Kinda snowflakish, to stop airlocks from shaking when kicked. I'll be refactorfing the whole thing anyways
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
