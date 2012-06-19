#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_SAFETY 10
#define AIRLOCK_WIRE_SPEED 11

/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	isWireColorCut - returns 1 if that color wire is cut, or 0 if not
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
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

//This generates the randomized airlock wire assignments for the game.
/proc/RandomAirlockWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockWireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<2048, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 11)
			if(wires[colorIndex]==0)
				valid = 1
				wires[colorIndex] = flag
				airlockIndexToFlag[flagIndex] = flag
				airlockIndexToWireColor[flagIndex] = colorIndex
				airlockWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return wires

/* Example:
Airlock wires color -> flag are { 64, 128, 256, 2, 16, 4, 8, 32, 1 }.
Airlock wires color -> index are { 7, 8, 9, 2, 5, 3, 4, 6, 1 }.
Airlock index -> flag are { 1, 2, 4, 8, 16, 32, 64, 128, 256 }.
Airlock index -> wire color are { 9, 4, 6, 7, 5, 8, 1, 2, 3 }.
*/

/obj/machinery/door/airlock
	name = "Airlock"
	icon = 'doorint.dmi'
	icon_state = "door_closed"

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/wires = 2047
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/list/signalers[11]
	var/lockdownbyai = 0
	autoclose = 1
	var/doortype = 0
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening

/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'Doorcom.dmi'
	doortype = 1

/obj/machinery/door/airlock/security
	name = "Airlock"
	icon = 'Doorsec.dmi'
	doortype = 2

/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'Dooreng.dmi'
	doortype = 3

/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'Doormed.dmi'
	doortype = 4

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'Doormaint.dmi'
	doortype = 5

/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'Doorext.dmi'
	doortype = 6

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'Doorglass.dmi'
	opacity = 0
	doortype = 7
	glass = 1

/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'Doorele.dmi'
	opacity = 0
	doortype = 8

/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'vault.dmi'
	opacity = 1
	doortype = 9

/obj/machinery/door/airlock/glass_large
	name = "Glass Airlock"
	icon = 'Door2x1glassfull.dmi'
	opacity = 0
	doortype = 10
	glass = 1

/obj/machinery/door/airlock/freezer
	name = "Freezer Airlock"
	icon = 'Doorfreezer.dmi'
	opacity = 1
	doortype = 11

/obj/machinery/door/airlock/hatch
	name = "Airtight Hatch"
	icon = 'Doorhatchele.dmi'
	opacity = 1
	doortype = 12

/obj/machinery/door/airlock/maintenance_hatch
	name = "Maintenance Hatch"
	icon = 'Doorhatchmaint2.dmi'
	opacity = 1
	doortype = 13

/obj/machinery/door/airlock/glass_command
	name = "Maintenance Hatch"
	icon = 'Doorcomglass.dmi'
	opacity = 0
	doortype = 14
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'Doorengglass.dmi'
	opacity = 0
	doortype = 15
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'Doorsecglass.dmi'
	opacity = 0
	doortype = 16
	glass = 1

/obj/machinery/door/airlock/glass_medical
	name = "Maintenance Hatch"
	icon = 'doormedglass.dmi'
	opacity = 0
	doortype = 17
	glass = 1

/obj/machinery/door/airlock/mining
	name = "Mining Airlock"
	icon = 'Doormining.dmi'
	doortype = 18

/obj/machinery/door/airlock/atmos
	name = "Atmospherics Airlock"
	icon = 'Dooratmo.dmi'
	doortype = 19

/obj/machinery/door/airlock/research
	name = "Airlock"
	icon = 'Doorresearch.dmi'
	doortype = 20

/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'doorresearchglass.dmi'
	opacity = 0
	doortype = 21
	glass = 1

/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'doorminingglass.dmi'
	opacity = 0
	doortype = 22
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'dooratmoglass.dmi'
	opacity = 0
	doortype = 23
	glass = 1

/obj/machinery/door/airlock/gold
	name = "Gold Airlock"
	icon = 'Doorgold.dmi'
	var/mineral = "gold"
	doortype = 24

/obj/machinery/door/airlock/silver
	name = "Silver Airlock"
	icon = 'Doorsilver.dmi'
	var/mineral = "silver"
	doortype = 25

/obj/machinery/door/airlock/diamond
	name = "Diamond Airlock"
	icon = 'Doordiamond.dmi'
	var/mineral = "diamond"
	doortype = 26

/obj/machinery/door/airlock/uranium
	name = "Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'Dooruranium.dmi'
	var/mineral = "uranium"
	doortype = 27
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
	icon = 'Doorplasma.dmi'
	var/mineral = "plasma"
	doortype = 28

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))
		if(target_tile.parent && target_tile.parent.group_processing)
			target_tile.parent.suspend_group_processing()
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 35
		napalm.toxins = toxinsToDeduce
		napalm.temperature = 400+T0C
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
		new/obj/structure/door_assembly/door_assembly_0( src.loc )
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until temperature_expose works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ReplaceWithMineralWall("plasma")
		del (F)
	for(var/turf/simulated/wall/mineral/W in range(3,src))
		if(mineral == "plasma")
			W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	del (src)

/obj/machinery/door/airlock/clown
	name = "Bananium Airlock"
	desc = "Honkhonkhonk"
	icon = 'Doorbananium.dmi'
	var/mineral = "clown"
	doortype = 29

/obj/machinery/door/airlock/sandstone
	name = "Sandstone Airlock"
	icon = 'Doorsand.dmi'
	var/mineral = "sandstone"
	doortype = 30

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



/obj/machinery/door/airlock/bumpopen(mob/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!istype(usr, /mob/living/silicon))
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


/obj/machinery/door/airlock/proc/pulse(var/wireColor)
	//var/wireFlag = airlockWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = airlockWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through this flashes the red light on the door (if the door has power).
			if((src.arePowerSystemsOn()) && (!(stat & NOPOWER)))
				animate("deny")
		if(AIRLOCK_WIRE_MAIN_POWER1 || AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			src.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!src.locked)
				src.locked = 1
				usr << "You hear a click from the bottom of the door."
				src.updateUsrDialog()
			else
				if(src.arePowerSystemsOn()) //only can raise bolts if power's on
					src.locked = 0
					usr << "You hear a click from inside the door."
					src.updateUsrDialog()
			update_icon()

		if(AIRLOCK_WIRE_BACKUP_POWER1 || AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			src.loseBackupPower()
		if(AIRLOCK_WIRE_AI_CONTROL)
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateDialog()
			spawn(10)
				if(src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if(src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if(src.secondsElectrified==0)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				src.secondsElectrified = 30
				spawn(10)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if(src.secondsElectrified<0)
							src.secondsElectrified = 0
//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
						sleep(10)
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access
			if(!src.requiresID() || src.check_access(null))
				if(src.density)
					open()
				else
					close()
		if(AIRLOCK_WIRE_SAFETY)
			safe = !safe
			if(!src.density)
				close()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			normalspeed = !normalspeed
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/cut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor]
	wires &= ~wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1 || AIRLOCK_WIRE_MAIN_POWER2)
			//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
			src.loseMainPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
			if(src.locked!=1)
				src.locked = 1
			update_icon()
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1 || AIRLOCK_WIRE_BACKUP_POWER2)
			//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
			src.loseBackupPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
			if(src.secondsElectrified != -1)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				src.secondsElectrified = -1
		if (AIRLOCK_WIRE_SAFETY)
			safe = 0
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 0
			src.updateUsrDialog()

/obj/machinery/door/airlock/proc/mend(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor] //not used in this function
	wires |= wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1 || AIRLOCK_WIRE_MAIN_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
				src.regainMainPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1 || AIRLOCK_WIRE_BACKUP_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				src.regainBackupPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if(src.aiControlDisabled == 1)
				src.aiControlDisabled = 0
			else if(src.aiControlDisabled == 2)
				src.aiControlDisabled = -1
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			if(src.secondsElectrified == -1)
				src.secondsElectrified = 0

		if (AIRLOCK_WIRE_SAFETY)
			safe = 1
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 1
			if(!src.density)
				close()
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireColorCut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	var/wireFlag = airlockIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

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
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
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
		sleep(10)
		hasShocked = 0
		return 1
	else
		return 0


/obj/machinery/door/airlock/update_icon()
	if(overlays) overlays = null
	if(density)
		if(locked)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if(p_open || welded)
			overlays = list()
			if(p_open)
				overlays += image(icon, "panel_open")
			if(welded)
				overlays += image(icon, "welded")
	else
		icon_state = "door_open"

	return

/obj/machinery/door/airlock/animate(animation)
	switch(animation)
		if("opening")
			if(overlays) overlays = null
			if(p_open)
				icon_state = "o_door_opening" //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays = null
			if(p_open)
				flick("o_door_closing", src)
			else
				flick("door_closing", src)
		if("spark")
			flick("door_spark", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	if(!src.canAIControl())
		if(src.canAIHack())
			src.hack(user)
			return
		else
			user << "Airlock AI control has been blocked with a firewall. Unable to hack."

	//Separate interface for the AI.
	user.machine = src
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
			src.attack_ai(user)


/obj/machinery/door/airlock/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(src.loc, 'bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				for(var/mob/M in viewers(src, null))
					M << "\red [user] headbutts the airlock."
				var/datum/organ/external/affecting = H.get_organ("head")
				H.Stun(8)
				H.Weaken(5)
				if(affecting.take_damage(10, 0))
					H.UpdateDamageIcon()
			else
				for(var/mob/M in viewers(src, null))
					M << "\red [user] headbutts the airlock. Good thing they're wearing a helmet."
			return

	if(src.p_open)
		user.machine = src
		var/t1 = text("<B>Access Panel</B><br>\n")

		//t1 += text("[]: ", airlockFeatureNames[airlockWireColorToIndex[9]])
		var/list/wires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Red" = 5,
			"Blue" = 6,
			"Green" = 7,
			"Grey" = 8,
			"Black" = 9,
			"Gold" = 10,
			"Aqua" = 11
		)
		for(var/wiredesc in wires)
			var/is_uncut = src.wires & airlockWireColorToFlag[wires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[wires[wiredesc]]'>Pulse</a> "
				if(src.signalers[wires[wiredesc]])
					t1 += "<a href='?src=\ref[src];remove-signaler=[wires[wiredesc]]'>Detach signaler</a>"
				else
					t1 += "<a href='?src=\ref[src];signaler=[wires[wiredesc]]'>Attach signaler</a>"
			t1 += "<br>"

		t1 += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]", (src.locked ? "The door bolts have fallen!" : "The door bolts look up."), ((src.arePowerSystemsOn() && !(stat & NOPOWER)) ? "The test light is on." : "The test light is off!"), (src.aiControlDisabled==0 ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."),  (src.safe==0 ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."))

		t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

		user << browse(t1, "window=airlock")
		onclose(user, "airlock")

	else
		..(user)
	return


/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	if(!nowindow)
		..()
	if(usr.stat || usr.restrained())
		return
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.machine==src)
			usr.machine = null
			return

	if((in_range(src, usr) && istype(src.loc, /turf)) && src.p_open)
		usr.machine = src
		if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if(src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if(href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if(!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if(src.isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(t1)
		else if(href_list["signaler"])
			var/wirenum = text2num(href_list["signaler"])
			if(!istype(usr.equipped(), /obj/item/device/assembly/signaler))
				usr << "You need a signaller!"
				return
			if(src.isWireColorCut(wirenum))
				usr << "You can't attach a signaller to a cut wire."
				return
			var/obj/item/device/assembly/signaler/R = usr.equipped()
			if(R.secured)
				usr << "This radio can't be attached!"
				return
			var/mob/M = usr
			M.drop_item()
			R.loc = src
			R.airlock_wire = wirenum
			src.signalers[wirenum] = R
		else if(href_list["remove-signaler"])
			var/wirenum = text2num(href_list["remove-signaler"])
			if(!(src.signalers[wirenum]))
				usr << "There's no signaller attached to that wire!"
				return
			var/obj/item/device/assembly/signaler/R = src.signalers[wirenum]
			R.loc = usr.loc
			R.airlock_wire = null
			src.signalers[wirenum] = null


	if(istype(usr, /mob/living/silicon) && src.canAIControl())
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
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.<br>\n")
					else if(src.secondsElectrified==-1)
						src.secondsElectrified = 0
					else if(src.secondsElectrified>0)
						src.secondsElectrified = 0

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.</a><br>\n")
					else if (src.safe)
						safe = 0
					else
						usr << text("Firmware reports safeties already overriden.</a><br>\n")



				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.</a><br>\n")
					else if (src.normalspeed)
						normalspeed = 0
					else
						usr << text("Door timing circurity already accellerated.")

				if(7)
					//close door
					if(src.welded)
						usr << text("The airlock has been welded shut!<br>\n")
					else if(src.locked)
						usr << text("The door bolts are down!<br>\n")
					else if(!src.density)
						close()
					else
						usr << text("The airlock is already closed.<br>\n")



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
						if(src.arePowerSystemsOn())
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
						src.secondsElectrified = -1

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						usr << text("Control to door sensors is disabled.<br>\n")
					else if (!src.safe)
						safe = 1
						src.updateUsrDialog()
					else
						usr << text("Firmware reports safeties already in place.<br>\n")

				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.</a><br>\n")
					else if (!src.normalspeed)
						normalspeed = 1
						src.updateUsrDialog()
					else
						usr << text("Door timing circurity currently operating normally.")

				if(7)
					//open door
					if(src.welded)
						usr << text("The airlock has been welded shut!<br>\n")
					else if(src.locked)
						usr << text("The door bolts are down!<br>\n")
					else if(src.density)
						open()
	//					close()
					else
						usr << text("The airlock is already opened.<br>\n")
	add_fingerprint(usr)
	update_icon()
	if(!nowindow)
		updateUsrDialog()
	return

/obj/machinery/door/airlock/attackby(C as obj, mob/user as mob)
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
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
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return
	else if(istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !( src.p_open )
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && (density && welded && !operating && src.p_open && (!src.arePowerSystemsOn() || stat & NOPOWER) && !src.locked) )
			playsound(src.loc, 'Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user,40))
				user << "\blue You removed the airlock electronics!"
				switch(src.doortype)
					if(0) new/obj/structure/door_assembly/door_assembly_0( src.loc )
					if(1) new/obj/structure/door_assembly/door_assembly_com( src.loc )
					if(2) new/obj/structure/door_assembly/door_assembly_sec( src.loc )
					if(3) new/obj/structure/door_assembly/door_assembly_eng( src.loc )
					if(4) new/obj/structure/door_assembly/door_assembly_med( src.loc )
					if(5) new/obj/structure/door_assembly/door_assembly_mai( src.loc )
					if(6) new/obj/structure/door_assembly/door_assembly_ext( src.loc )
					if(7) new/obj/structure/door_assembly/door_assembly_glass( src.loc )
					if(14) new/obj/structure/door_assembly/door_assembly_com/glass( src.loc )
					if(15) new/obj/structure/door_assembly/door_assembly_eng/glass( src.loc )
					if(16) new/obj/structure/door_assembly/door_assembly_sec/glass( src.loc )
					if(17) new/obj/structure/door_assembly/door_assembly_med/glass( src.loc )
					if(18) new/obj/structure/door_assembly/door_assembly_min( src.loc )
					if(19) new/obj/structure/door_assembly/door_assembly_atmo( src.loc )
					if(20) new/obj/structure/door_assembly/door_assembly_research( src.loc )
					if(21) new/obj/structure/door_assembly/door_assembly_research/glass( src.loc )
					if(22) new/obj/structure/door_assembly/door_assembly_min/glass( src.loc )
					if(23) new/obj/structure/door_assembly/door_assembly_atmo/glass( src.loc )
					if(24) new/obj/structure/door_assembly/door_assembly_gold( src.loc )
					if(25) new/obj/structure/door_assembly/door_assembly_silver( src.loc )
					if(26) new/obj/structure/door_assembly/door_assembly_diamond( src.loc )
					if(27) new/obj/structure/door_assembly/door_assembly_uranium( src.loc )
					if(28) new/obj/structure/door_assembly/door_assembly_plasma( src.loc )
					if(29) new/obj/structure/door_assembly/door_assembly_clown( src.loc )
					if(30) new/obj/structure/door_assembly/door_assembly_sandstone( src.loc )

				var/obj/item/weapon/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/weapon/airlock_electronics( src.loc )
					ae.conf_access = src.req_access
				else
					ae = electronics
					electronics = null
					ae.loc = src.loc

				del(src)
				return
		else if(src.arePowerSystemsOn() && !(stat & NOPOWER))
			user << "\blue The airlock's motors resist your efforts to pry it open."
		else if(src.locked)
			user << "\blue The airlock's bolts prevent it from being pried open."
		if((src.density) && (!( src.welded ) && !( src.operating ) && ((!src.arePowerSystemsOn()) || (stat & NOPOWER)) && !( src.locked )))

			if(beingcrowbarred == 0) //being fireaxe'd
				var/obj/item/weapon/twohanded/fireaxe/F = C
				if(F:wielded)
					spawn( 0 )
						src.operating = 1
						animate("opening")

						sleep(15)

						layer = 2.7
						src.density = 0
						update_icon()

						if(!istype(src, /obj/machinery/door/airlock/glass))
							src.sd_SetOpacity(0)
						src.operating = 0
					return
				user << "\red You need to be wielding the Fire axe to do that."
				return
			else
				spawn( 0 )
					src.operating = 1
					animate("opening")

					sleep(15)

					layer = 2.7
					src.density = 0
					update_icon()

					if(!istype(src, /obj/machinery/door/airlock/glass))
						src.sd_SetOpacity(0)
					src.operating = 0
					return

		else
			if((!src.density) && (!( src.welded ) && !( src.operating ) && !( src.locked )))
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn( 0 )
							src.operating = 1
							animate("closing")

							layer = 3.1
							src.density = 1
							sleep(15)
							update_icon()

							if((src.visible) && (!istype(src, /obj/machinery/door/airlock/glass)))
								src.sd_SetOpacity(1)
							src.operating = 0
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn( 0 )
						src.operating = 1
						animate("closing")

						layer = 3.1
						src.density = 1
						sleep(15)
						update_icon()

						if((src.visible) && (!istype(src, /obj/machinery/door/airlock/glass)))
							src.sd_SetOpacity(1)
						src.operating = 0

	else
		..()
	return

/obj/machinery/door/airlock/plasma/attackby(C as obj, mob/user as mob)
	if(C)
		ignite(is_hot(C))
	..()

/obj/machinery/door/airlock/open()
	if(src.welded || src.locked || (!src.arePowerSystemsOn()) || (stat & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR) || src.operating)
		return 0
	use_power(50)
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'windowdoor.ogg', 100, 1)
	if(istype(src, /obj/machinery/door/airlock/clown))
		playsound(src.loc, 'bikehorn.ogg', 30, 1)
	else
		playsound(src.loc, 'airlock.ogg', 30, 1)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()
	return ..()

/obj/machinery/door/airlock/close()
	if(src.welded || src.locked || (!src.arePowerSystemsOn()) || (stat & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) || src.operating)
		return
	if(safe)
		if(locate(/mob/living) in get_turf(src))
		//	playsound(src.loc, 'buzz-two.ogg', 50, 0)	//THE BUZZING IT NEVER STOPS	-Pete
			spawn (60)
				close()
			return

	for(var/mob/M in get_turf(src))
		if(isrobot(M))
			M.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
		else
			M.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			M.SetStunned(5)
			M.SetWeakened(5)
			var/obj/effect/stop/S
			S = new /obj/effect/stop
			S.victim = M
			S.loc = src.loc
			spawn(20)
				del(S)
			M.emote("scream")
		var/turf/location = src.loc
		if(istype(location, /turf/simulated))
			location.add_blood(M)

	use_power(50)
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'windowdoor.ogg', 30, 1)
	if(istype(src, /obj/machinery/door/airlock/clown))
		playsound(src.loc, 'bikehorn.ogg', 30, 1)
	else
		playsound(src.loc, 'airlock.ogg', 30, 1)
	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(2)//Smashin windows
	..()
	return

/obj/machinery/door/airlock/New()
	..()
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in world)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break


/obj/machinery/door/airlock/proc/prison_open()
	src.locked = 0
	src.open()
	src.locked = 1
	return
