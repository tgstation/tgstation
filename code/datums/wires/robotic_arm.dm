//For the automated robotic arm -- \code\game\machinery\robotic_arm.dm

//WIRE_SENSOR is the detection wire. When cut, arm will not detect objects to be moved.
//WIRE_MOTOR1 is the rotation wire. Pulsing will force the arm to attempt to move an object, even if WIRE_SENSOR is cut.
//WIRE_MOTOR2 is the claw wire. Cutting will make the arm unable to let go of an object.

/datum/wires/robotic_arm
	holder_type = /obj/machinery/robotic_arm

/datum/wires/robotic_arm/New(atom/holder)
	wires = list(WIRE_SENSOR,WIRE_MOTOR1,WIRE_MOTOR2)
	..()

/datum/wires/robotic_arm/on_pulse(wire)
	var/obj/machinery/robotic_arm/A = holder
	switch(wire)
		if(WIRE_MOTOR1)
			A.grab()
	. = ..()

/datum/wires/robotic_arm/on_cut(wire, mend)
	var/obj/machinery/robotic_arm/A = holder
	switch(wire)
		if(WIRE_SENSOR)
			if(mend)
				START_PROCESSING(SSmachines, A)
	. = ..()
