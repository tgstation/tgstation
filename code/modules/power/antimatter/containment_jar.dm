/obj/item/am_containment
	name = "antimatter containment jar"
	desc = "Holds antimatter. A few of these could blow an entire 21st-century lunar installation."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "jar"
	density = FALSE
	anchored = FALSE
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	var/fuel = 1000
	var/fuel_max = 1000
	var/stability = 100 //TODO: add all the stability things to this so its not very safe if you keep hitting in on things
	var/explodified = FALSE

/obj/item/am_containment/proc/boom()
	var/percent = 0
	if(fuel)
		percent = (fuel / fuel_max) * 100
	if(!explodified && percent >= 10)
		explosion(get_turf(src), 1, 2, 3, 5)//Should likely be larger but this works fine for now I guess
		explodified = TRUE
	if(src) // just incase we got deleted in the explosion
		qdel(src)

/obj/item/am_containment/ex_act(severity, target)
	switch(severity)
		if(1)
			explosion(get_turf(src), 1, 2, 3, 5)//Should likely be larger but this works fine for now I guess
			if(src)
				qdel(src)
		if(2)
			if(prob((fuel/10)-stability))
				explosion(get_turf(src), 1, 2, 3, 5)
				if(prob((fuel/10)-stability))
					boom()
				return
			stability -= 40
		if(3)
			stability -= 20
	//check_stability()
	return

/obj/item/am_containment/proc/usefuel(wanted)
	if(fuel < wanted)
		wanted = fuel
	fuel -= wanted
	return wanted