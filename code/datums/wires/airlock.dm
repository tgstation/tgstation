<<<<<<< HEAD
/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock

/datum/wires/airlock/secure
	randomize = TRUE

/datum/wires/airlock/New(atom/holder)
	wires = list(
		WIRE_POWER1, WIRE_POWER2,
		WIRE_BACKUP1, WIRE_BACKUP2,
		WIRE_OPEN, WIRE_BOLTS, WIRE_IDSCAN, WIRE_AI,
		WIRE_SHOCK, WIRE_SAFETY, WIRE_TIMING, WIRE_LIGHT,
		WIRE_ZAP1, WIRE_ZAP2
	)
	add_duds(2)
	..()

/datum/wires/airlock/interactable(mob/user)
	var/obj/machinery/door/airlock/A = holder
	if(!istype(user, /mob/living/silicon) && A.isElectrified() && A.shock(user, 100))
		return FALSE
	if(A.panel_open)
		return TRUE

/datum/wires/airlock/get_status()
	var/obj/machinery/door/airlock/A = holder
	var/list/status = list()
	status += "The door bolts [A.locked ? "have fallen!" : "look up."]"
	status += "The test light is [A.hasPower() ? "on" : "off"]."
	status += "The AI connection light is [A.aiControlDisabled || A.emagged ? "off" : "on"]."
	status += "The check wiring light is [A.safe ? "off" : "on"]."
	status += "The timer is powered [A.autoclose ? "on" : "off"]."
	status += "The speed light is [A.normalspeed ? "on" : "off"]."
	status += "The emergency light is [A.emergency ? "on" : "off"]."
	return status

/datum/wires/airlock/on_pulse(wire)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Pulse to loose power.
			A.loseMainPower()
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Pulse to loose backup power.
			A.loseBackupPower()
		if(WIRE_OPEN) // Pulse to open door (only works not emagged and ID wire is cut or no access is required).
			if(A.emagged)
				return
			if(!A.requiresID() || A.check_access(null))
				if(A.density)
					A.open()
				else
					A.close()
		if(WIRE_BOLTS) // Pulse to toggle bolts (but only raise if power is on).
			if(!A.locked)
				A.bolt()
				A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
			else
				if(A.hasPower())
					A.unbolt()
					A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null, 1)
			A.update_icon()
		if(WIRE_IDSCAN) // Pulse to disable emergency access and flash red lights.
			if(A.hasPower() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = FALSE
					A.update_icon()
		if(WIRE_AI) // Pulse to disable WIRE_AI control for 10 ticks (follows same rules as cutting).
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
		if(WIRE_SHOCK) // Pulse to shock the door for 10 ticks.
			if(!A.secondsElectrified)
				A.secondsElectrified = 30
				A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				add_logs(usr, A, "electrified")
				spawn(10)
					if(A)
						while (A.secondsElectrified > 0)
							A.secondsElectrified -= 1
							if(A.secondsElectrified < 0)
								A.secondsElectrified = 0
							sleep(10)
		if(WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				A.close()
		if(WIRE_TIMING)
			A.normalspeed = !A.normalspeed
		if(WIRE_LIGHT)
			A.lights = !A.lights
			A.update_icon()

/datum/wires/airlock/on_cut(wire, mend)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Cut to loose power, repair all to gain power.
			if(mend && !is_cut(WIRE_POWER1) && !is_cut(WIRE_POWER2))
				A.regainMainPower()
				A.shock(usr, 50)
			else
				A.loseMainPower()
				A.shock(usr, 50)
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Cut to loose backup power, repair all to gain backup power.
			if(mend && !is_cut(WIRE_BACKUP1) && !is_cut(WIRE_BACKUP2))
				A.regainBackupPower()
				A.shock(usr, 50)
			else
				A.loseBackupPower()
				A.shock(usr, 50)
		if(WIRE_BOLTS) // Cut to drop bolts, mend does nothing.
			if(!mend)
				A.bolt()
		if(WIRE_AI) // Cut to disable WIRE_AI control, mend to re-enable.
			if(mend)
				if(A.aiControlDisabled == 1) // 0 = normal, 1 = locked out, 2 = overridden by WIRE_AI, -1 = previously overridden by WIRE_AI
					A.aiControlDisabled = 0
				else if(A.aiControlDisabled == 2)
					A.aiControlDisabled = -1
			else
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
		if(WIRE_SHOCK) // Cut to shock the door, mend to unshock.
			if(mend)
				if(A.secondsElectrified)
					A.secondsElectrified = 0
			else
				if(A.secondsElectrified != -1)
					A.secondsElectrified = -1
					A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
					add_logs(usr, A, "electrified")
		if(WIRE_SAFETY) // Cut to disable safeties, mend to re-enable.
			A.safe = mend
		if(WIRE_TIMING) // Cut to disable auto-close, mend to re-enable.
			A.autoclose = mend
			if(A.autoclose && !A.density)
				A.close()
		if(WIRE_LIGHT) // Cut to disable lights, mend to re-enable.
			A.lights = mend
			A.update_icon()
		if(WIRE_ZAP1, WIRE_ZAP2) // Ouch.
			A.shock(usr, 50)
=======
// Wires for airlocks


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

/datum/wires/airlock/secure
	random = 1

/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	wire_count = 12
	window_y = 570

	New()
		wire_names=list(
			"[AIRLOCK_WIRE_IDSCAN]"        = "ID Scan",
			"[AIRLOCK_WIRE_MAIN_POWER1]"   = "Main Power 1",
			"[AIRLOCK_WIRE_MAIN_POWER2]"   = "Main Power 2",
			"[AIRLOCK_WIRE_DOOR_BOLTS]"    = "Bolts",
			"[AIRLOCK_WIRE_BACKUP_POWER1]" = "Backup Power 1",
			"[AIRLOCK_WIRE_BACKUP_POWER2]" = "Backup Power 2",
			"[AIRLOCK_WIRE_OPEN_DOOR]"     = "Open",
			"[AIRLOCK_WIRE_AI_CONTROL]"    = "AI Control",
			"[AIRLOCK_WIRE_ELECTRIFY]"     = "Electrify",
			"[AIRLOCK_WIRE_SAFETY]"        = "Safety",
			"[AIRLOCK_WIRE_SPEED]"         = "Speed",
			"[AIRLOCK_WIRE_LIGHT]"         = "Lights",
		)
		..()

/datum/wires/airlock/CanUse(var/mob/living/L)
	var/obj/machinery/door/airlock/A = holder
	if(!istype(L, /mob/living/silicon))
		if(A.isElectrified())
			if(A.shock(L, 100))
				return 0
	if(A.panel_open)
		return 1
	return 0

/datum/wires/airlock/GetInteractWindow()
	var/obj/machinery/door/airlock/A = holder
	. += ..()
	. += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]", (A.locked ? "The door bolts have fallen!" : "The door bolts look up."),
	(A.lights ? "The door bolt lights are on." : "The door bolt lights are off!"),
	((A.arePowerSystemsOn() && !(A.stat & NOPOWER)) ? "The test light is on." : "The test light is off!"),
	(A.aiControlDisabled==0 ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."),
	(A.safe==0 ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."),
	(A.normalspeed==0 ? "The 'Check Timing Mechanism' light is on." : "The 'Check Timing Mechanism' light is off."))


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
			//Sending a pulse through this flashes the red light on the door (if the door has power).
			if((A.arePowerSystemsOn()) && (!(A.stat & NOPOWER)) && A.density)
				A.door_animate("deny")
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			A.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!A.locked)
				A.locked = 1
				for(var/mob/M in range(1, A))
					to_chat(M, "You hear a click from the bottom of the door.")
			else
				if(A.arePowerSystemsOn()) //only can raise bolts if power's on
					A.locked = 0
					for(var/mob/M in range(1, A))
						to_chat(M, "You hear a click from the bottom of the door.")
			A.update_icon()

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
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
			//will succeed only if the ID wire is cut or the door requires no access
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
