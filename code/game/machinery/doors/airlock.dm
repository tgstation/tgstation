/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

// Wires for the airlock are located in the datum folder, inside the wires datum folder.


/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_closed"

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/lights = 1 // bolt lights show by default
	var/datum/wires/airlock/wires = null
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
	var/doortype = /obj/structure/door_assembly/door_assembly_0
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/autoclose = 1
	var/obj/item/device/doorCharge/charge = null //If applied, causes an explosion upon opening the door
	var/detonated = 0

	explosion_block = 1

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/Doorcom.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/Doorsec.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/Dooreng.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/Doormed.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/Doormaint.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_ext

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_glass
	glass = 1

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 1
	doortype = null //(centcom) there's no door assembly sprites for this one.

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = 1
	doortype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2

/obj/machinery/door/airlock/glass_large
	name = "glass airlock"
	icon = 'icons/obj/doors/Door2x1glassfull.dmi'
	opacity = 0
	doortype = null //(double glass door) there's no door assembly sprites for this one.
	glass = 1
	bound_width = 64 // 2x1

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	opacity = 1
	doortype = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	opacity = 1
	doortype = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	opacity = 1
	doortype = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_com/glass
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_eng/glass
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_sec/glass
	glass = 1

/obj/machinery/door/airlock/glass_medical
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doormedglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_med/glass
	glass = 1

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/Doorresearch.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/glass_research
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_research/glass
	glass = 1

/obj/machinery/door/airlock/glass_mining
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_min/glass
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_atmo/glass
	glass = 1

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	var/mineral = "gold"
	doortype = /obj/structure/door_assembly/door_assembly_gold

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	var/mineral = "silver"
	doortype = /obj/structure/door_assembly/door_assembly_silver

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	var/mineral = "diamond"
	doortype = /obj/structure/door_assembly/door_assembly_diamond

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	var/mineral = "uranium"
	doortype = /obj/structure/door_assembly/door_assembly_uranium
	var/last_event = 0

/obj/machinery/door/airlock/uranium/process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.irradiate(15)
	return

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	var/mineral = "plasma"
	doortype = /obj/structure/door_assembly/door_assembly_plasma

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 500)
	new/obj/structure/door_assembly/door_assembly_0( src.loc )
	qdel(src)

/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/clown
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	var/mineral = "bananium"
	doortype = /obj/structure/door_assembly/door_assembly_clown

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	var/mineral = "sandstone"
	doortype = /obj/structure/door_assembly/door_assembly_sandstone

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/Doorsci.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_science/glass
	glass = 1

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/doorshuttle.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_shuttle

/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/Doorwood.dmi'
	var/mineral = "wood"
	doortype = /obj/structure/door_assembly/door_assembly_wood

/obj/machinery/door/airlock/virology
	icon = 'icons/obj/doors/Doorviro.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_viro

/obj/machinery/door/airlock/glass_virology
	icon = 'icons/obj/doors/Doorviroglass.dmi'
	opacity = 0
	doortype = /obj/structure/door_assembly/door_assembly_viro/glass
	glass = 1

/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/
// You can find code for the airlock wires in the wire datum folder.

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = 1
	update_icon()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = 0
	update_icon()

/obj/machinery/door/airlock/Destroy()
	if(id_tag)
		for(var/obj/machinery/doorButtons/D in world)
			D.removeMe(src)
	..()

/obj/machinery/door/airlock/bumpopen(mob/living/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = 1
					spawn (10)
						src.justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(user.hallucination > 50 && prob(10) && src.operating == 0)
			user << "<span class='userdanger'>You feel a powerful shock course through your body!</span>"
			user.staminaloss += 50
			user.stunned += 5
			return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user as mob)
	..(user)

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	return ((src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	var/retval=0
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			retval=1
	return retval

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

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if(electrocute_mob(user, get_area(src), src))
		hasShocked = 1
		spawn(10)
			hasShocked = 0
		return 1
	else
		return 0


/obj/machinery/door/airlock/update_icon()
	if(overlays) overlays.Cut()
	if(density)
		if(locked && lights)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if(p_open || welded || emergency)
			overlays = list()
			if(p_open)
				overlays += image(icon, "panel_open")
			if(welded)
				overlays += image(icon, "welded")
			if(emergency && !locked)
				overlays += image(icon, "elights")
	else
		icon_state = "door_open"

	return

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(overlays) overlays.Cut()
			if(p_open)
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays.Cut()
			if(p_open)
				flick("o_door_closing", src)
			else
				flick("door_closing", src)
		if("spark")
			flick("door_spark", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(charge && !p_open && in_range(user, src))
		user << "The maintenance panel is bulging slightly."

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	if(!src.canAIControl())
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
		if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(src.emergency)
		t1 += text("Emergency Access Override is enabled. <A href='?src=\ref[];aiDisable=11'>Disable?</a><br>\n", src)
	else
		t1 += text("Emergency Access Override is disabled. <A href='?src=\ref[];aiEnable=11'>Enable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(src.secondsMainPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(src.secondsBackupPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(src.hasPower())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door bolt lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door bolt lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		t1 += text("Electrification wire is cut.<br>\n")
	if(src.secondsElectrified==-1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(src.secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

	if(src.isWireCut(AIRLOCK_WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'>Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'>Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'>Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'>Restore?</a><br>\n",src)




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

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 11 lift access override
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 11 enable access override


/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(src.aiHacking==0)
		src.aiHacking=1
		spawn(20)
			//TODO: Make this take a minute
			user << "Airlock AI control has been blocked. Beginning fault-detection."
			sleep(50)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Fault confirmed: airlock control wire disabled or cut."
			sleep(20)
			user << "Attempting to hack into airlock. This may take some time."
			sleep(200)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Upload access confirmed. Loading control program into airlock software."
			sleep(170)
			if(src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
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
			if (user)
				src.attack_ai(user)


/obj/machinery/door/airlock/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if(!istype(user, /mob/living/silicon))
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
				var/obj/item/organ/limb/affecting = H.get_organ("head")
				H.Stun(5)
				H.Weaken(5)
				if(affecting.take_damage(10, 0))
					H.update_damage_overlays(0)
			else
				visible_message("<span class='danger'>[user] headbutts the airlock. Good thing they're wearing a helmet.</span>")
			return

	if(src.p_open)
		wires.Interact(user)
	else
		..(user)
	return


/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(usr.stat || usr.restrained())
		return
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.machine==src)
			usr.unset_machine()
			return

	if((in_range(src, usr) && istype(src.loc, /turf)) && src.p_open)
		usr.set_machine(src)



	if(istype(usr, /mob/living/silicon) && src.canAIControl())
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed, 11 emergency access
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed, 11 emergency access
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways."
					else if(src.aiDisabledIdScanner)
						usr << "You've already disabled the IdScan feature."
					else
						src.aiDisabledIdScanner = 1
				if(2)
					//disrupt main power
					if(src.secondsMainPowerLost == 0)
						src.loseMainPower()
					else
						usr << "Main power is already offline."
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						src.loseBackupPower()
					else
						usr << "Backup power is already offline."
				if(4)
					//drop door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << "You can't drop the door bolts - The door bolt dropping wire has been cut."
					else if(src.locked!=1)
						src.locked = 1
						update_icon()
				if(5)
					//un-electrify door
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.")
					else if(src.secondsElectrified==-1)
						src.secondsElectrified = 0
					else if(src.secondsElectrified>0)
						src.secondsElectrified = 0

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (src.safe)
						safe = 0
					else
						usr << text("Firmware reports safeties already overriden.")



				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (src.normalspeed)
						normalspeed = 0
					else
						usr << text("Door timing circurity already accellerated.")

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
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (src.lights)
						lights = 0
					else
						usr << text("Door bolt lights are already disabled!")

				if(11)
					// Emergency access
					if (src.emergency)
						emergency = 0
					else
						usr << text("Emergency access is already disabled!")


		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "You can't enable IdScan - The IdScan wire has been cut."
					else if(src.aiDisabledIdScanner)
						src.aiDisabledIdScanner = 0
					else
						usr << "The IdScan feature is not disabled."
				if(4)
					//raise door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if(!src.locked)
						usr << text("The door bolts are already up.<br>\n")
					else
						if(src.hasPower())
							src.locked = 0
							update_icon()
						else
							usr << text("Cannot raise door bolts due to power failure.<br>\n")

				if(5)
					//electrify door for 30 seconds
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						add_logs(usr, src, "electrified", admin=0, addition="at [x],[y],[z]")
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
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						add_logs(usr, src, "electrified", admin=0, addition="at [x],[y],[z]")
						src.secondsElectrified = -1

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (!src.safe)
						safe = 1
						src.updateUsrDialog()
					else
						usr << text("Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (!src.normalspeed)
						normalspeed = 1
						src.updateUsrDialog()
					else
						usr << text("Door timing circurity currently operating normally.")

				if(7)
					//open door
					if(src.welded)
						usr << text("The airlock has been welded shut!")
					else if(src.locked)
						usr << text("The door bolts are down!")
					else if(src.density)
						open()
					else
						close()

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (!src.lights)
						lights = 1
						src.updateUsrDialog()
					else
						usr << text("Door bolt lights are already enabled!")

				if(11)
					// Emergency access
					if (!src.emergency)
						emergency = 1
					else
						usr << text("Emergency access is already enabled!")

	add_fingerprint(usr)
	update_icon()
	if(!nowindow)
		updateUsrDialog()
	return

/obj/machinery/door/airlock/attackby(C as obj, mob/user as mob, params)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner))
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
							"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")
			playsound(loc, 'sound/items/Welder.ogg', 40, 1)
			if(do_after(user,40,5,1))
				if(density && !operating)//Door must be closed to weld.
					if( !istype(src, /obj/machinery/door/airlock) || !user || !W || !W.isOn() || !user.loc )
						return
					playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
					welded = !welded
					user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
										"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
					update_icon()
		return
	else if(istype(C, /obj/item/weapon/screwdriver))
		if(p_open && detonated)
			user << "<span class='warning'>[src] has no maintenance panel!</span>"
			return
		src.p_open = !( src.p_open )
		user << "<span class='notice'>You [p_open ? "open":"close"] the maintenance panel of the airlock.</span>"
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if(p_open && charge)
			user << "<span class='notice'>You carefully start removing [charge] from [src]...</span>"
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 150))
				user << "<span class='warning'>You slip and [charge] detonates!</span>"
				charge.ex_act(1)
				user.Weaken(3)
				return
			user.visible_message("<span class='notice'>[user] removes [charge] from [src].</span>", \
								 "<span class='notice'>You gently pry out [charge] from [src] and unhook its wires.</span>")
			charge.loc = get_turf(user)
			if(prob(25))
				charge.ex_act(1)
				return
			charge = null
			return
		if( beingcrowbarred && (density && welded && !operating && src.p_open && (!hasPower()) && !src.locked) )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", \
								 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
			if(do_after(user,40))
				if(src.loc)
					if(src.doortype)
						var/obj/structure/door_assembly/A = new src.doortype(src.loc)
						A.heat_proof_finished = src.heat_proof //tracks whether there's rglass in

					if(emagged)
						user << "<span class='warning'>You discard the damaged electronics.</span>"
						qdel(src)
						return
					user << "<span class='notice'>You remove the airlock electronics.</span>"

					var/obj/item/weapon/airlock_electronics/ae
					if(!electronics)
						ae = new/obj/item/weapon/airlock_electronics( src.loc )
						if(req_one_access)
							ae.use_one_access = 1
							ae.conf_access = src.req_one_access
						else
							ae.conf_access = src.req_access
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
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	open(2)
					else
						user << "<span class='warning'>You need to be wielding the fire axe to do that!</span>"
				else
					spawn(0)	open(2)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	close(2)
					else
						user << "<span class='warning'>You need to be wielding the fire axe to do that!</span>"
				else
					spawn(0)	close(2)

	else if(istype(C, /obj/item/weapon/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/device/doorCharge) && p_open)
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
		p_open = 0
		update_icon()
		var/obj/item/device/doorCharge/newCharge = C //This is necessary, for some reason
		newCharge.loc = src
		charge = newCharge
		return
	else
		..()
	return

/obj/machinery/door/airlock/plasma/attackby(C as obj, mob/user as mob, params)
	if(is_hot(C) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma wall ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		log_game("Plasma wall ignited by [user.ckey]([user]) in ([x],[y],[z])")
		ignite(is_hot(C))
		return
	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if( operating || welded || locked )
		return 0
	if(!forced)
		if( !hasPower() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	if(charge && !detonated)
		p_open = 1
		update_icon()
		visible_message("<span class='warning'>[src]'s panel is blown off in a spray of deadly shrapnel!</span>")
		charge.ex_act(1)
		detonated = 1
		charge = null
		for(var/mob/living/carbon/human/H in orange(1,src))
			H.Paralyse(8)
			H.adjust_fire_stacks(1)
			H.IgniteMob() //Guaranteed knockout and ignition for nearby people
		return
	if(forced < 2)
		if(emagged)
			return 0
		use_power(50)
		if(istype(src, /obj/machinery/door/airlock/glass))
			playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
		if(istype(src, /obj/machinery/door/airlock/clown))
			playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
		else
			playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
		if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
			src.closeOther.close()
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	if(autoclose  && normalspeed)
		spawn(150)
			autoclose()
	else if(autoclose && !normalspeed)
		spawn(5)
			autoclose()

	return ..()


/obj/machinery/door/airlock/close(var/forced=0)
	if(operating || welded || locked)
		return
	if(!forced)
		if( !hasPower() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) )
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				spawn (60)
					autoclose()
				return

	if(forced < 2)
		if(emagged)
			return
		use_power(50)
		if(istype(src, /obj/machinery/door/airlock/glass))
			playsound(src.loc, 'sound/machines/windowdoor.ogg', 30, 1)
		if(istype(src, /obj/machinery/door/airlock/clown))
			playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
		else
			playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(2)//Smashin windows

	if(density)
		return 1
	operating = 1
	do_animate("closing")
	src.layer = 3.1
	sleep(5)
	src.density = 1
	if(!safe)
		crush()
	sleep(5)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	if(locate(/mob/living) in get_turf(src))
		open()
	return 1

/obj/machinery/door/airlock/New()
	..()
	wires = new(src)
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in world)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break


/obj/machinery/door/airlock/proc/prison_open()
	if(emagged)	return
	src.locked = 0
	src.open()
	src.locked = 1
	return


/obj/machinery/door/airlock/proc/autoclose()
	if(!density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/airlock/proc/change_paintjob(obj/item/C as obj, mob/user as mob)
	var/obj/item/weapon/airlock_painter/W
	if(istype(C, /obj/item/weapon/airlock_painter))
		W = C
	else
		user << "If you see this, it means airlock/change_paintjob() was called with something other than an airlock painter. Check your code!"
		return

	if(!W.can_use(user))
		return

	if(glass == 1)
		//These airlocks have a glass version.
		var optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
		var paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
		if((!in_range(src, usr) && src.loc != usr) || !W.use(user))	return
		switch(paintjob)
			if("Default")
				icon = 'icons/obj/doors/Doorglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_glass
			if("Engineering")
				icon = 'icons/obj/doors/Doorengglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_eng/glass
			if("Atmospherics")
				icon = 'icons/obj/doors/Dooratmoglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_atmo/glass
			if("Security")
				icon = 'icons/obj/doors/Doorsecglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_sec/glass
			if("Command")
				icon = 'icons/obj/doors/Doorcomglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_com/glass
			if("Medical")
				icon = 'icons/obj/doors/Doormedglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_med/glass
			if("Research")
				icon = 'icons/obj/doors/Doorresearchglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_research/glass
			if("Mining")
				icon = 'icons/obj/doors/Doorminingglass.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_min/glass
	else
		//These airlocks have a regular version.
		var optionlist = list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")
		var paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
		if((!in_range(src, usr) && src.loc != usr) || !W.use(user))	return
		switch(paintjob)
			if("Default")
				icon = 'icons/obj/doors/Doorint.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_0
			if("Engineering")
				icon = 'icons/obj/doors/Dooreng.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_eng
			if("Atmospherics")
				icon = 'icons/obj/doors/Dooratmo.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_atmo
			if("Security")
				icon = 'icons/obj/doors/Doorsec.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_sec
			if("Command")
				icon = 'icons/obj/doors/Doorcom.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_com
			if("Medical")
				icon = 'icons/obj/doors/Doormed.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_med
			if("Research")
				icon = 'icons/obj/doors/Doorresearch.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_research
			if("Mining")
				icon = 'icons/obj/doors/Doormining.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_min
			if("Maintenance")
				icon = 'icons/obj/doors/Doormaint.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_mai
			if("External")
				icon = 'icons/obj/doors/Doorext.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_ext
			if("High Security")
				icon = 'icons/obj/doors/hightechsecurity.dmi'
				doortype = /obj/structure/door_assembly/door_assembly_highsecurity
	update_icon()

/obj/machinery/door/airlock/CanAStarPass(var/obj/item/weapon/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut)
	return !density || (check_access(ID) && !locked)

/obj/machinery/door/airlock/HasProximity(atom/movable/AM as mob|obj)
	for (var/obj/A in contents)
		A.HasProximity(AM)
	return