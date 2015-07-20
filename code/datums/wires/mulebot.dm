/datum/wires/mulebot
	random = 1
	holder_type = /obj/machinery/bot/mulebot
	wire_count = 10

var/const/WIRE_POWER1 = 1			// power connections
var/const/WIRE_POWER2 = 2
var/const/WIRE_AVOIDANCE = 4		// mob avoidance
var/const/WIRE_LOADCHECK = 8		// load checking (non-crate)
var/const/WIRE_MOTOR1 = 16		// motor wires
var/const/WIRE_MOTOR2 = 32		//
var/const/WIRE_REMOTE_RX = 64		// remote recv functions
var/const/WIRE_REMOTE_TX = 128	// remote trans status
var/const/WIRE_BEACON_RX = 256	// beacon ping recv

/datum/wires/mulebot/CanUse(var/mob/living/L)
	var/obj/machinery/bot/mulebot/M = holder
	if(M.open)
		return 1
	return 0

// So the wires do not open a new window, handle the interaction ourselves.
/datum/wires/mulebot/Interact(var/mob/living/user)
	if(CanUse(user))
		var/obj/machinery/bot/mulebot/M = holder
		M.interact(user)

/datum/wires/mulebot/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_POWER1, WIRE_POWER2)
			holder.visible_message("<span class='notice'>\icon[holder] The charge light flickers.</span>")
		if(WIRE_AVOIDANCE)
			holder.visible_message("<span class='notice'>\icon[holder] The external warning lights flash briefly.</span>")
		if(WIRE_LOADCHECK)
			holder.visible_message("<span class='notice'>\icon[holder] The load platform clunks.</span>")
		if(WIRE_MOTOR1, WIRE_MOTOR2)
			holder.visible_message("<span class='notice'>\icon[holder] The drive motor whines briefly.</span>")
		else
			holder.visible_message("<span class='notice'>\icon[holder] You hear a radio crackle.</span>")

// HELPER PROCS

/datum/wires/mulebot/proc/Motor1()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/Motor1() called tick#: [world.time]")
	return !(wires_status & WIRE_MOTOR1)

/datum/wires/mulebot/proc/Motor2()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/Motor2() called tick#: [world.time]")
	return !(wires_status & WIRE_MOTOR2)

/datum/wires/mulebot/proc/HasPower()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/HasPower() called tick#: [world.time]")
	return !(wires_status & WIRE_POWER1) && !(wires_status & WIRE_POWER2)

/datum/wires/mulebot/proc/LoadCheck()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/LoadCheck() called tick#: [world.time]")
	return !(wires_status & WIRE_LOADCHECK)

/datum/wires/mulebot/proc/MobAvoid()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/MobAvoid() called tick#: [world.time]")
	return !(wires_status & WIRE_AVOIDANCE)

/datum/wires/mulebot/proc/RemoteTX()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/RemoteTX() called tick#: [world.time]")
	return !(wires_status & WIRE_REMOTE_TX)

/datum/wires/mulebot/proc/RemoteRX()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/RemoteRX() called tick#: [world.time]")
	return !(wires_status & WIRE_REMOTE_RX)

/datum/wires/mulebot/proc/BeaconRX()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/wires/mulebot/proc/BeaconRX() called tick#: [world.time]")
	return !(wires_status & WIRE_BEACON_RX)