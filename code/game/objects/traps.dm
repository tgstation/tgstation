/obj/trap
	name = "trap"
	desc = "It's a trap!"
	density = 0
	var/uses = 1 //how many times it can be triggered

/obj/trap/New()
	..()
	src:visibility = 0 //seriously, it keeps saying "undefined var" when I try to do it in the define

/obj/trap/HasEntered(victim as mob|obj)
	trigger(victim)

/obj/trap/Bumped(victim as mob|obj)
	trigger(victim)

/obj/trap/proc/trigger(victim)
	if(!uses)
		return
	uses--

/obj/trap/rocksfall
	name = "rocks fall trap"
	desc = "Your DM must really hate you."
	var/aoe_radius = 3 //radius of rocks falling
	var/aoe_include_dense = 0 //if it includes dense tiles in the aoe
	var/aoe_range_or_view = "view" //if it includes all tiles in [radius] range or view
	var/rocks_amt = 10 //amount of rocks falling
	var/rocks_seeking = 0 //if 1, rocks fall only on mobs, otherwise it picks the turfs in the area at random
	var/rocks_min_dmg = 50  //min damage per rock
	var/rocks_max_dmg = 100 //max damage per rock
	var/rocks_hit_chance = 100 //the chance for a rock to hit you

/obj/trap/rocksfall/trigger()

	..()

	var/list/targets = list()

	if(!rocks_seeking)
		switch(aoe_range_or_view)
			if("view")
				for(var/turf/T in view(src,aoe_radius))
					if(!T.density || aoe_include_dense)
						targets += T
			if("range")
				for(var/turf/T in range(src,aoe_radius))
					if(!T.density || aoe_include_dense)
						targets += T

		for(var/i=0,i<rocks_amt,i++)
			var/turf/hit_loc = pick(targets)
			var/rock_type = pick(typesof(/obj/item/weapon/ore))
			var/obj/item/weapon/ore/rock = new rock_type(hit_loc)
			for(var/mob/M in hit_loc)
				if(prob(rocks_hit_chance))
					M.bruteloss += rand(rocks_min_dmg,rocks_max_dmg)
					M << "A chunk of [rock.name] hits you in the head!"

	else
		switch(aoe_range_or_view)
			if("view")
				for(var/mob/M in view(src,aoe_radius))
					targets += M
			if("range")
				for(var/mob/M in range(src,aoe_radius))
					targets += M

		for(var/i=0,i<rocks_amt,i++)
			var/mob/hit_loc = pick(targets)
			var/rock_type = pick(typesof(/obj/item/weapon/ore))
			var/obj/item/weapon/ore/rock = new rock_type(hit_loc.loc)
			if(prob(rocks_hit_chance))
				hit_loc.bruteloss += rand(rocks_min_dmg,rocks_max_dmg)
				hit_loc << "A chunk of [rock.name] hits you in the head!"