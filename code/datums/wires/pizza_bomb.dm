/datum/wires/pizza_bomb
	var/const/W_BOOM1 = "boomb1" // Boom.
	var/const/W_BOOM2 = "boomb2" // Boom!
	var/const/W_BOOM3 = "boomb3" // BOOM!
	var/const/W_DISARM = "disarm" // No boom!

	holder_type = /obj/item/device/pizza_bomb
	randomize = 1

/datum/wires/pizza_bomb/New(atom/holder)
	wires = list(
		W_BOOM1, W_BOOM2, W_BOOM3,
		W_DISARM
	)
	..()

/datum/wires/pizza_bomb/get_status()
	var/obj/item/device/pizza_bomb/P = holder
	var/list/status = list()
	status.Add("The red light is [P.primed ? "on" : "off"].")
	status.Add("The green light is [P.disarmed ? "on": "off"].")
	return status

/datum/wires/pizza_bomb/on_pulse(wire)
	var/obj/item/device/pizza_bomb/P = holder
	switch(wire)
		if(W_DISARM) // Rearm after a short time
			var/was_primed = P.primed
			P.disarm()
			if(was_primed)
				spawn(100)
					if(P)
						P.arm()
		else
			if(!P.disarmed)
				P.go_boom()

/datum/wires/pizza_bomb/on_cut(wire, mend)
	var/obj/item/device/pizza_bomb/P = holder
	switch(wire)
		if(W_DISARM)
			if(mend)
				P.disarmed = FALSE
			else
				P.disarm()
		else
			if(!mend && !P.disarmed)
				P.go_boom()
