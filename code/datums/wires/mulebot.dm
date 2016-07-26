/datum/wires/mulebot
	random = 1
	holder_type = /obj/machinery/bot/mulebot
	wire_count = 10

/datum/wires/mulebot/New()
	wire_names=list(
		"[WIRE_POWER1]" 	= "Power 1",
		"[WIRE_POWER2]" 	= "Power 2",
		"[WIRE_AVOIDANCE]" 	= "Avoidance",
		"[WIRE_LOADCHECK]" 	= "Load Check",
		"[WIRE_MOTOR1]" 	= "Motor 1",
		"[WIRE_MOTOR2]" 	= "Motor 2",
		"[WIRE_REMOTE_RX]" 	= "Remote RX",
		"[WIRE_REMOTE_TX]" 	= "Remote TX",
		"[WIRE_BEACON_RX]" 	= "Beacon RX"
	)
	..()

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

/datum/wires/mulebot/GetInteractWindow()
	. += ..()
	. += {"<BR>The charge light is [IsIndexCut(WIRE_POWER1) || IsIndexCut(WIRE_POWER2) ? "off" : "on"].<BR>
	The warning light is [IsIndexCut(WIRE_AVOIDANCE) ? "gleaming ominously" : "off"].<BR>
	The platform is [IsIndexCut(WIRE_LOADCHECK) ? "riding low" : "elevated"].<BR>
	The regulator light is [getRegulatorColor()].<BR>"}

/datum/wires/mulebot/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_REMOTE_RX,WIRE_REMOTE_TX,WIRE_BEACON_RX)
			holder.visible_message("<span class='notice'>[bicon(holder)] You hear a radio crackle.</span>")

// HELPER PROCS

/datum/wires/mulebot/proc/getRegulatorColor()
	if(IsIndexCut(WIRE_MOTOR1) && IsIndexCut(WIRE_MOTOR2))
		return "red"
	else if(IsIndexCut(WIRE_MOTOR1)||IsIndexCut(WIRE_MOTOR2))
		return "yellow"
	else
		return "green"

/datum/wires/mulebot/proc/Motor1()
	return !(wires_status & WIRE_MOTOR1)

/datum/wires/mulebot/proc/Motor2()
	return !(wires_status & WIRE_MOTOR2)

/datum/wires/mulebot/proc/HasPower()
	return !(wires_status & WIRE_POWER1) && !(wires_status & WIRE_POWER2)

/datum/wires/mulebot/proc/LoadCheck()
	return !(wires_status & WIRE_LOADCHECK)

/datum/wires/mulebot/proc/MobAvoid()
	return !(wires_status & WIRE_AVOIDANCE)

/datum/wires/mulebot/proc/RemoteTX()
	return !(wires_status & WIRE_REMOTE_TX)

/datum/wires/mulebot/proc/RemoteRX()
	return !(wires_status & WIRE_REMOTE_RX)

/datum/wires/mulebot/proc/BeaconRX()
	return !(wires_status & WIRE_BEACON_RX)
