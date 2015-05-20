// Wires for airlocks

/datum/wires/airlock/secure
	random = 1

/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	wire_count = 12
	window_y = 570

var/const/AIRLOCK_WIRE_IDSCAN = 1
var/const/AIRLOCK_WIRE_MAIN_POWER1 = 2
var/const/AIRLOCK_WIRE_MAIN_POWER2 = 4
var/const/AIRLOCK_WIRE_DOOR_BOLTS = 8
var/const/AIRLOCK_WIRE_BACKUP_POWER1 = 16
var/const/AIRLOCK_WIRE_BACKUP_POWER2 = 32
var/const/AIRLOCK_WIRE_OPEN_DOOR = 64
var/const/AIRLOCK_WIRE_AI_CONTROL = 128
var/const/AIRLOCK_WIRE_ELECTRIFY = 256
var/const/AIRLOCK_WIRE_SAFETY = 512
var/const/AIRLOCK_WIRE_SPEED = 1024
var/const/AIRLOCK_WIRE_LIGHT = 2048

/datum/wires/airlock/CanUse(var/mob/living/L)
	var/obj/machinery/door/airlock/A = holder
	if(!istype(L, /mob/living/silicon))
		if(A.isElectrified())
			if(A.shock(L, 100))
				return 0
	if(A.p_open)
		return 1
	return 0

/datum/wires/airlock/GetInteractWindow()
	var/obj/machinery/door/airlock/A = holder
	. += ..()
	. += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]", (A.locked ? "The door bolts have fallen!" : "The door bolts look up."),
	(A.lights ? "The door bolt lights are on." : "The door bolt lights are off!"),
	((A.hasPower()) ? "The test light is on." : "The test light is off!"),
	((A.aiControlDisabled==0 && !A.emagged) ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."),
	(A.safe==0 ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."),
	(A.normalspeed==0 ? "The 'Check Timing Mechanism' light is on." : "The 'Check Timing Mechanism' light is off."),
	(A.emergency==0 ? "The emergency lights are off." : "The emergency lights are on."))

/datum/wires/airlock/UpdateCut(var/index, var/mended)

	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)

			if(!mended)
				//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
				A.loseMainPower()
				A.shock(usr, 50)
			else
				if((!IsIndexCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!IsIndexCut(AIRLOCK_WIRE_MAIN_POWER2)))
					A.regainMainPower()
					A.shock(usr, 50)

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)

			if(!mended)
				//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
				A.loseBackupPower()
				A.shock(usr, 50)
			else
				if((!IsIndexCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!IsIndexCut(AIRLOCK_WIRE_BACKUP_POWER2)))
					A.regainBackupPower()
					A.shock(usr, 50)

		if(AIRLOCK_WIRE_DOOR_BOLTS)

			if(!mended)
				//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
				if(A.locked!=1)
					A.locked = 1
				A.update_icon()

		if(AIRLOCK_WIRE_AI_CONTROL)

			if(!mended)
				//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
				//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
			else
				if(A.aiControlDisabled == 1)
					A.aiControlDisabled = 0
				else if(A.aiControlDisabled == 2)
					A.aiControlDisabled = -1

		if(AIRLOCK_WIRE_ELECTRIFY)

			if(!mended)
				//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
				if(A.secondsElectrified != -1)
					A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
					add_logs(usr, A, "electrified", admin=0, addition="at [A.x],[A.y],[A.z]")
					A.secondsElectrified = -1
			else
				if(A.secondsElectrified == -1)
					A.secondsElectrified = 0
			return // Don't update the dialog.

		if (AIRLOCK_WIRE_SAFETY)
			A.safe = mended

		if(AIRLOCK_WIRE_SPEED)
			A.autoclose = mended
			if(mended)
				if(!A.density)
					A.close()

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = mended
			A.update_icon()


/datum/wires/airlock/UpdatePulsed(var/index)

	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through this disables emergency access and flashes the red light on the door (if the door has power).
			if(A.hasPower() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = 0
					A.update_icon()
		if(AIRLOCK_WIRE_MAIN_POWER1 || AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			A.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!A.locked)
				A.locked = 1
				A.audible_message("You hear a click from the bottom of the door.", null,  1)
			else
				if(A.hasPower()) //only can raise bolts if power's on
					A.locked = 0
					A.audible_message("You hear a click from the bottom of the door.", null, 1)
			A.update_icon()

		if(AIRLOCK_WIRE_BACKUP_POWER1 || AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			A.loseBackupPower()
		if(AIRLOCK_WIRE_AI_CONTROL)
			if(A.aiControlDisabled == 0)
				A.aiControlDisabled = 1
			else if(A.aiControlDisabled == -1)
				A.aiControlDisabled = 2

			spawn(10)
				if(A)
					if(A.aiControlDisabled == 1)
						A.aiControlDisabled = 0
					else if(A.aiControlDisabled == 2)
						A.aiControlDisabled = -1

		if(AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if(A.secondsElectrified==0)
				A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				add_logs(usr, A, "electrified", admin=0, addition="at [A.x],[A.y],[A.z]")
				A.secondsElectrified = 30
				spawn(10)
					if(A)
						//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
						while (A.secondsElectrified>0)
							A.secondsElectrified-=1
							if(A.secondsElectrified<0)
								A.secondsElectrified = 0
							sleep(10)
				return
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access and it's not emagged
			if(A.emagged)	return
			if(!A.requiresID() || A.check_access(null))
				if(A.density)	A.open()
				else		A.close()
		if(AIRLOCK_WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				A.close()

		if(AIRLOCK_WIRE_SPEED)
			A.normalspeed = !A.normalspeed

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = !A.lights
			A.update_icon()
