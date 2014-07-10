/obj/item/weapon/am_containment
	name = "antimatter containment jar"
	desc = "Holds antimatter."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "jar"
	density = 0
	anchored = 0
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	var/fuel = 1000 // WAS ORIGINALLY 10000
	var/fuel_max = 1000//Lets try this for now
	var/stability = 100//TODO: add all the stability things to this so its not very safe if you keep hitting in on things
	var/exploded = 0

/obj/item/weapon/am_containment/proc/boom()
	var/percent = 0
	if(fuel)
		percent = (fuel / fuel_max) * 100
	if(!exploded && percent >= 10)
		explosion(get_turf(src), 1, 2, 3, 5)//Should likely be larger but this works fine for now I guess
		exploded=1
	if(src) qdel(src)

/obj/item/weapon/am_containment/ex_act(severity)
	switch(severity)
		if(1.0)
			boom()
		if(2.0)
			if(prob((fuel/10)-stability))
				boom()
			stability -= 40
		if(3.0)
			stability -= 20
	//check_stability()
	return

/obj/item/weapon/am_containment/proc/usefuel(var/wanted)
	if(fuel < wanted)
		wanted = fuel
	fuel -= wanted
	return wanted