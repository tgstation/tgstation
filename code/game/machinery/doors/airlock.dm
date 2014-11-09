/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (stat & NOPOWER) for that)
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
	power_channel = ENVIRON

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
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	autoclose = 1
	var/busy = 0

	emag_cost = 1 // in MJ

/obj/machinery/door/airlock/Destroy()
	if(wires)
		wires.Destroy()
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

/obj/machinery/door/airlock/external/cultify()
	new /obj/structure/mineral_door/wood(loc)
	..()

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 0

/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'icons/obj/doors/vault.dmi'
	opacity = 1
	emag_cost = 2 // in MJ
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

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

/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

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

/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorresearchglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1

/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

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
		del (F)
	for(var/turf/simulated/wall/mineral/plasma/W in range(3,src))
		W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	new/obj/structure/door_assembly( src.loc )
	del (src)

/obj/machinery/door/airlock/clown
	name = "Bananium Airlock"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	mineral = "clown"

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

/obj/machinery/door/airlock/highsecurity
	name = "High Tech Security Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity
	emag_cost = 2 // in MJ

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


/obj/machinery/door/airlock/bump_open(mob/living/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
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
			user << "\red <B>You feel a powerful shock course through your body!</B>"
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
/obj/machinery/door/airlock/shock(mob/user, prb)
	if((stat & (NOPOWER)) || !src.arePowerSystemsOn())		// unpowered, no shock
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
			if(overlays) overlays.Cut()
			if(panel_open)
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays.Cut()
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
				user << "Airlock AI control has been blocked with a firewall. Unable to hack."

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
		if(src.arePowerSystemsOn())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

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
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)

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

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door


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

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (src.isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.m_amt)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(!isAdminGhost(usr))
		if(usr.stat || usr.restrained()|| usr.small)
			//testing("Returning: Not adminghost, stat=[usr.stat], restrained=[usr.restrained()], small=[usr.small]")
			return
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.machine==src)
			usr.unset_machine()
			return

	var/am_in_range=in_range(src, usr)
	var/turf_ok = istype(src.loc, /turf)
	//testing("in range: [am_in_range], turf ok: [turf_ok]")
	if(am_in_range && turf_ok)
		usr.set_machine(src)
		if(panel_open)
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
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled IDScan on"))
							usr << "\red Nope."
							return 0
						src.aiDisabledIdScanner = 1
				if(2)
					//disrupt main power
					if(src.secondsMainPowerLost == 0)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted main power on"))
							usr << "\red Nope."
							return 0
						src.loseMainPower()
					else
						usr << "Main power is already offline."
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted backup power on"))
							usr << "\red Nope."
							return 0
						src.loseBackupPower()
					else
						usr << "Backup power is already offline."
				if(4)
					//drop door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << "You can't drop the door bolts - The door bolt dropping wire has been cut."
					else if(src.locked!=1)
						if(isobserver(usr) && !canGhostWrite(usr,src,"dropped bolts on"))
							usr << "\red Nope."
							return 0
						src.locked = 1
						update_icon()
				if(5)
					//un-electrify door
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.")
					else if(src.secondsElectrified==-1)
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified"))
							usr << "\red Nope."
							return 0
						src.secondsElectrified = 0
					else if(src.secondsElectrified>0)
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified"))
							usr << "\red Nope."
							return 0
						src.secondsElectrified = 0

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (src.safe)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled safeties on"))
							usr << "\red Nope."
							return 0
						safe = 0
					else
						usr << text("Firmware reports safeties already overriden.")



				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (src.normalspeed)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disrupted timing on"))
							usr << "\red Nope."
							return 0
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
						if(isobserver(usr) && !canGhostWrite(usr,src,"closed"))
							usr << "\red Nope."
							return 0
						close()
					else
						if(isobserver(usr) && !canGhostWrite(usr,src,"opened"))
							usr << "\red Nope."
							return 0
						open()

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (src.lights)
						if(isobserver(usr) && !canGhostWrite(usr,src,"disabled door bolt lights on"))
							usr << "\red Nope."
							return 0
						lights = 0
					else
						usr << text("Door bolt lights are already disabled!")



		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "You can't enable IdScan - The IdScan wire has been cut."
					else if(src.aiDisabledIdScanner)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled ID Scan on"))
							usr << "\red Nope."
							return 0
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
						if(src.arePowerSystemsOn())
							if(isobserver(usr) && !canGhostWrite(usr,src,"raised bolts on"))
								usr << "\red Nope."
								return 0
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
						usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified (30sec)"))
							usr << "\red Nope."
							return 0
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
						usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
						if(isobserver(usr) && !canGhostWrite(usr,src,"electrified (permanent)"))
							usr << "\red Nope."
							return 0
						src.secondsElectrified = -1

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.")
					else if (!src.safe)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled safeties on"))
							usr << "\red Nope."
							return 0
						safe = 1
						src.updateUsrDialog()
					else
						usr << text("Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (!src.normalspeed)
						if(isobserver(usr) && !canGhostWrite(usr,src,"set speed to normal on"))
							usr << "\red Nope."
							return 0
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
						if(isobserver(usr) && !canGhostWrite(usr,src,"opened"))
							usr << "\red Nope."
							return 0
						open()
					else
						if(isobserver(usr) && !canGhostWrite(usr,src,"closed"))
							usr << "\red Nope."
							return 0
						close()

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (!src.lights)
						if(isobserver(usr) && !canGhostWrite(usr,src,"enabled bolt lights on"))
							usr << "\red Nope."
							return 0
						lights = 1
						src.updateUsrDialog()
					else
						usr << text("Door bolt lights are already enabled!")

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
	if (!istype(user, /mob/living/silicon) && !isobserver(user))
		if (isElectrified())
			// TODO: analyze the called proc
			if (shock(user, 100))
				return
	if (!panel_open)
		..(user)
	//else
	//	// TODO: logic for adding fingerprints when interacting with wires
	//	wires.Interact(user)

	return

// huehue you cannot screwdrive an operating door
// neither closed door ;)
/obj/machinery/door/airlock/togglePanelOpen(var/obj/toggleitem, mob/user)
	if (density && !operating)
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
				return

	if (istype(I, /obj/item/weapon/weldingtool))
		if (density && !operating)
			var/obj/item/weapon/weldingtool/WT = I

			// TODO: analyze the called proc
			if (WT.remove_fuel(0, user))
				if (!welded)
					welded = 1
				else
					welded = null

				update_icon()
	else if (istype(I, /obj/item/weapon/wirecutters))
		if (!operating && panel_open)
			wires.Interact(user)
	else if (istype(I, /obj/item/device/multitool))
		if (!operating && panel_open)
			wires.Interact(user)
			update_multitool_menu(user)
		attack_hand(user)
	// TODO: review this if
	else if (istype(I, /obj/item/weapon/pai_cable))
		if (!operating)
			var/obj/item/weapon/pai_cable/PC = I
			PC.plugin(src, user)
			PC = null
	else if(istype(I, /obj/item/weapon/crowbar) || istype(I, /obj/item/weapon/twohanded/fireaxe) )
		if(src.busy) return
		src.busy = 1
		var/beingcrowbarred = null
		if(istype(I, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && (operating == -1 || density && welded && !operating && src.panel_open && (!src.arePowerSystemsOn() || stat & NOPOWER) && !src.locked) )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			// TODO: refactor the called proc
			if (do_after(user, 40))
				user << "\blue You removed the airlock electronics!"

				var/obj/structure/door_assembly/DA = new assembly_type(loc)
				DA.anchored = 1
				DA.fingerprints += src.fingerprints
				DA.fingerprintshidden += src.fingerprintshidden
				DA.fingerprintslast = user.ckey
				if (mineral)
					DA.glass = mineral
				// TODO: check DA.glass
				else if (glass && !DA.glass)
					DA.glass = 1

				DA.state = 1
				DA.created_name = name
				DA.update_state()

				var/obj/item/weapon/circuitboard/airlock/A

				// TODO: check electronics
				if (!electronics)
					A = new/obj/item/weapon/circuitboard/airlock(loc)

					// TODO: recheck the vars
					if(req_access && req_access.len)
						A.conf_access = req_access
					else if(req_one_access && req_one_access.len)
						A.conf_access = req_one_access
						A.one_access = 1
				else
					A = electronics
					electronics = null
					A.loc = loc

				if (operating == -1)
					A.icon_state = "door_electronics_smoked"
					operating = 0

				del(src)
				return
		else if(arePowerSystemsOn() && !(stat & NOPOWER))
			user << "\blue The airlock's motors resist your efforts to force it."
		else if(locked)
			user << "\blue The airlock's bolts prevent it from being forced."
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = I
					if(F:wielded)
						spawn(0)	open(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = I
					if(F:wielded)
						spawn(0)	close(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	close(1)
		src.busy = 0
	else if (istype(I, /obj/item/weapon/card/emag) || istype(I, /obj/item/weapon/melee/energy/blade))
		if (!operating)
			if(density)
				door_animate("spark")
				open(1)
			operating = -1
	else
		..(I, user)

	return

/obj/machinery/door/airlock/plasma/attackby(C as obj, mob/user as mob)
	if(C)
		ignite(is_hot(C))
	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if(operating || locked || welded)
		return 0
	if(!forced)
		if( !arePowerSystemsOn() || (stat & NOPOWER) || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	use_power(50)
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(get_turf(src), 'sound/machines/windowdoor.ogg', 100, 1)
	if(istype(src, /obj/machinery/door/airlock/clown))
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 30, 1)
	else
		playsound(get_turf(src), 'sound/machines/airlock.ogg', 30, 1)
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
					del(S)

				L.emote("scream",,, 1)

				if (istype(loc, /turf/simulated))
					T.add_blood(L)

	if (istype(type, /obj/machinery/door/airlock/glass))
		playsound(get_turf(src), 'sound/machines/windowdoor.ogg', 30, 1)
	else if (istype(type, /obj/machinery/door/airlock/clown))
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 30, 1)
	else
		playsound(get_turf(src), 'sound/machines/airlock.ogg', 30, 1)

	for(var/turf/T in loc)
		var/obj/structure/window/W = locate(/obj/structure/window) in T
		if (W)
			W.destroy()

	..()
	return

/obj/machinery/door/airlock/New()
	. = ..()
	wires = new(src)
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in world)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break

/obj/machinery/door/airlock/proc/prison_open()
	locked = 0
	open()
	locked = 1
	return
