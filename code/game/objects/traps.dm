/obj/effects/pressure_plate
	name = "pressure plate"
	desc = "A pressure plate that triggers a trap or a few of them."
	density = 0
	var/list/connected_traps_names = list() //mappers, edit this when you place pressure plates on the map. don't forget to make the connected traps have an UNIQUE name
	var/list/connected_traps = list() //actual references to the connected traps. leave empty, it is generated at runtime from connected_traps_names
	var/trigger_type = "mob and obj" //can be "mob", "obj" or "mob and obj", the only moveable types

/obj/effects/pressure_plate/New()
	..()
	src:visibility = 0
	refresh()

/obj/effects/pressure_plate/verb/refresh()
	set name = "Refresh Pressure Plate Links"
	set category = "Object"
	set src in view()
	connected_traps = list() //emptying the list first
	for(var/trap_name in connected_traps_names)
		for(var/obj/effects/trap/the_trap in world)
			if(the_trap.name == trap_name)
				connected_traps += the_trap //adding the trap with the matching name

/obj/effects/pressure_plate/HasEntered(atom/victim as mob|obj)
	if(victim.density && (trigger_type == "mob and obj" || (trigger_type == "mob" && istype(victim,/mob)) || (trigger_type == "obj" && istype(victim,/obj))))
		for(var/obj/effects/trap/T in connected_traps)
			T.trigger(victim)

/obj/effects/pressure_plate/Bumped(atom/victim as mob|obj)
	if(victim.density && (trigger_type == "mob and obj" || (trigger_type == "mob" && istype(victim,/mob)) || (trigger_type == "obj" && istype(victim,/obj))))
		for(var/obj/effects/trap/T in connected_traps)
			T.trigger(victim)

/obj/effects/trap //has three subtypes - /aoe, /area (ie affects an entire area), /single (only the victim is affected)
	name = "trap"
	desc = "It's a trap!"
	density = 0
	var/uses = 1 //how many times it can be triggered
	var/trigger_type = "mob and obj" //can be "mob", "obj" or "mob and obj", the only moveable types. can also be "none" to not be triggered by entering its square (needs to have a pressure plate attached in that case)
	var/target_type = "mob" //if it targets mobs, turfs or objs
	var/include_dense = 1 //if it includes dense targets in the aoe (may be important for some reason). you'll probably want to change it to 1 if you target mobs or objs

/obj/effects/trap/New()
	..()
	src:visibility = 0 //seriously, it keeps saying "undefined var" when I try to do it in the define

/obj/effects/trap/HasEntered(victim as mob|obj)
	if(trigger_type == "mob and obj" || (trigger_type == "mob" && istype(victim,/mob)) || (trigger_type == "obj" && istype(victim,/obj)))
		trigger(victim)

/obj/effects/trap/Bumped(victim as mob|obj)
	if(trigger_type == "mob and obj" || (trigger_type == "mob" && istype(victim,/mob)) || (trigger_type == "obj" && istype(victim,/obj)))
		trigger(victim)

/obj/effects/trap/proc/trigger(victim)
	if(!uses)
		return
	uses--
	activate(victim)

/obj/effects/trap/proc/activate()

/obj/effects/trap/aoe
	name = "aoe trap"
	desc = "This trap affects a number of mobs, turfs or objs in an aoe"
	var/aoe_radius = 3 //radius of aoe
	var/aoe_range_or_view = "view" //if it includes all tiles in [radius] range or view

/obj/effects/trap/aoe/proc/picktargets()

	var/list/targets = list()

	switch(target_type)
		if("turf")
			switch(aoe_range_or_view)
				if("view")
					for(var/turf/T in view(src,aoe_radius))
						if(!T.density || include_dense)
							targets += T
				if("range")
					for(var/turf/T in range(src,aoe_radius))
						if(!T.density || include_dense)
							targets += T
		if("mob")
			switch(aoe_range_or_view)
				if("view")
					for(var/mob/living/M in view(src,aoe_radius))
						if(!M.density || include_dense)
							targets += M
				if("range")
					for(var/mob/living/M in range(src,aoe_radius))
						if(!M.density || include_dense)
							targets += M
		if("obj")
			switch(aoe_range_or_view)
				if("view")
					for(var/obj/O in view(src,aoe_radius))
						if(!O.density || include_dense)
							targets += O
				if("range")
					for(var/obj/O in range(src,aoe_radius))
						if(!O.density || include_dense)
							targets += O

	return targets

/obj/effects/trap/aoe/rocksfall
	name = "rocks fall trap"
	desc = "Your DM must really hate you."
	target_type = "turf"
	include_dense = 0
	var/rocks_amt = 10 //amount of rocks falling
	var/rocks_min_dmg = 50  //min damage per rock
	var/rocks_max_dmg = 100 //max damage per rock
	var/rocks_hit_chance = 100 //the chance for a rock to hit you
	var/list/rocks_type = list() //what rocks might it drop on the target. with var editing, not even limited to rocks.

/obj/effects/trap/aoe/rocksfall/New()

	..()

	rocks_type = pick_rock_types()

/obj/effects/trap/aoe/rocksfall/proc/pick_rock_types() //since we may want subtypes of the trap with completely different rock types, which is best done this way

	var/list/varieties = list()

	varieties = typesof(/obj/item/weapon/ore)
	varieties -= /obj/item/weapon/ore/diamond  //don't want easily available rare ores, hmm?
	varieties -= /obj/item/weapon/ore/uranium
	varieties -= /obj/item/weapon/ore/slag     //that'd be just stupid

	return varieties

/obj/effects/trap/aoe/rocksfall/activate()

	var/list/targets = list()
	targets = picktargets()

	if(target_type == "turf")
		for(var/i=0,i<rocks_amt,i++)
			var/turf/hit_loc = pick(targets)
			var/rock_type = pick(rocks_type)
			var/obj/item/weapon/ore/rock = new rock_type(hit_loc)
			for(var/mob/living/M in hit_loc)
				if(prob(rocks_hit_chance))
					M.take_organ_damage(rand(rocks_min_dmg,rocks_max_dmg))
					M << "A chunk of [lowertext(rock.name)] hits you in the head!"

	if(target_type == "mob")
		for(var/i=0,i<rocks_amt,i++)
			var/mob/living/hit_loc = pick(targets)
			var/rock_type = pick(rocks_type)
			var/obj/item/weapon/ore/rock = new rock_type(hit_loc.loc)
			if(prob(rocks_hit_chance))
				hit_loc.take_organ_damage(rand(rocks_min_dmg,rocks_max_dmg))
				hit_loc << "A chunk of [lowertext(rock.name)] hits you in the head!"

/obj/effects/trap/single
	name = "single-target trap"
	desc = "This trap targets a single movable atom, usually the one who triggered it" //usually as in I will code only those ones. if you want to add a different type of targeting, go ahead.

/obj/effects/trap/single/rockfalls
	name = "rock falls trap"
	desc = "Your DM must really hate <b>YOU</b>."
	trigger_type = "mob"
	var/rock_min_dmg = 100 //min damage of the rock
	var/rock_max_dmg = 200 //max damage of the rock
	var/rock_hit_chance = 100 //the chance for the rock to hit you
	var/list/rocks_type = list() //what rocks might it drop on the target. with var editing, not even limited to rocks.

/obj/effects/trap/single/rockfalls/New()

	..()

	rocks_type = pick_rock_types()

/obj/effects/trap/single/rockfalls/proc/pick_rock_types() //since we may want subtypes of the trap with completely different rock types, which is best done this way

	var/list/varieties = list()

	varieties = typesof(/obj/item/weapon/ore)
	varieties -= /obj/item/weapon/ore/diamond  //don't want easily available rare ores, hmm?
	varieties -= /obj/item/weapon/ore/uranium
	varieties -= /obj/item/weapon/ore/slag     //that'd be just stupid

	return varieties

/obj/effects/trap/single/rockfalls/activate(mob/living/victim)
	var/rock_type = pick(rocks_type)
	var/obj/item/weapon/ore/rock = new rock_type(victim:loc)
	if (istype(victim) && prob(rock_hit_chance))
		var/dmg = rand(rock_min_dmg,rock_max_dmg)
		if(istype(victim, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			var/datum/organ/external/affecting = H.organs["head"]
			affecting.take_damage(dmg)
			H.updatehealth()
		else
			victim.take_organ_damage(dmg)
		victim << "A chunk of [lowertext(rock.name)] hits you in the head!"

/obj/effects/trap/area
	name = "area trap"
	desc = "This trap targets all atoms of the target_type in its area"

/obj/effects/trap/area/proc/pick_targets() //src.loc.loc should be the area

	var/list/targets = list()

	switch(target_type)
		if("turf")
			for(var/turf/T in src.loc.loc)
				if(!T.density || include_dense)
					targets += T
		if("mob")
			for(var/mob/living/M in src.loc.loc)
				if(!M.density || include_dense)
					targets += M
		if("obj")
			for(var/obj/O in src.loc.loc)
				if(!O.density || include_dense)
					targets += O

	return targets