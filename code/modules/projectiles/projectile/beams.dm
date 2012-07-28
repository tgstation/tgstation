var/list/beam_master = list()
//Use: Caches beam state images and holds turfs that had these images overlaid.
//Structure:
//beam_master
//    icon_states/dirs of beams
//        image for that beam
//    references for fired beams
//        icon_states/dirs for each placed beam image
//            turfs that have that icon_state/dir

/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	var/frequency = 1

	fired()
		var/reference = "\ref[src]" //So we do not have to recalculate it a ton
		var/first = 1 //So we don't make the overlay in the same tile as the firer

		spawn(0)
			while(!bumped) //Move until we hit something
				step_towards(src, current) //Move~

				for(var/mob/living/M in loc)
					Bump(M) //Bump anyone we touch

				if((!( current ) || loc == current)) //If we pass our target
					current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)

				if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
					del(src) //Delete if it passes the world edge
					return

				if(!first) //Add the overlay as we pass over tiles
					var/target_dir = get_dir(src, current) //So we don't call this too much

					//If the icon has not been added yet
					if( !("[icon_state][target_dir]" in beam_master) )
						var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
						beam_master["[icon_state][target_dir]"] = I //And cache it!

					//Finally add the overlay
					src.loc.overlays += beam_master["[icon_state][target_dir]"]

					//Add the turf to a list in the beam master so they can be cleaned up easily.
					if(reference in beam_master)
						var/list/turf_master = beam_master[reference]
						if("[icon_state][target_dir]" in turf_master)
							var/list/turfs = turf_master["[icon_state][target_dir]"]
							turfs += loc
						else
							turf_master["[icon_state][target_dir]"] = list(loc)
					else
						var/list/turfs = list()
						turfs["[icon_state][target_dir]"] = list(loc)
						beam_master[reference] = turfs
				else
					first = 0

		cleanup(reference)
		return

	proc/cleanup(reference) //Waits .3 seconds then removes the overlay.
		src = null
		sleep(3)
		var/list/turf_master = beam_master[reference]
		for(var/laser_state in turf_master)
			var/list/turfs = turf_master[laser_state]
			for(var/turf/T in turfs)
				T.overlays -= beam_master[laser_state]
		return

/obj/item/projectile/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2


/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 40


/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"



/obj/item/projectile/bluetag
	name = "lasertag beam"
	icon_state = "ice_2"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/redtag
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1