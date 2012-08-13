atom/movable/var/list/adjacent_z_levels
atom/movable/var/archived_z_level

atom/movable/Move() //Hackish

	if(adjacent_z_levels && adjacent_z_levels["up"])
		var/turf/above_me = locate(x,y,adjacent_z_levels["up"])
		if(istype(above_me, /turf/simulated/floor/open))
			above_me:RemoveImage(src)

	. = ..()

	if(archived_z_level != z)
		archived_z_level = z
		if(z in levels_3d)
			adjacent_z_levels = global_adjacent_z_levels["[z]"]
		else
			adjacent_z_levels = null

	if(adjacent_z_levels && adjacent_z_levels["up"])
		var/turf/above_me = locate(x,y,adjacent_z_levels["up"])
		if(istype(above_me, /turf/simulated/floor/open))
			above_me:AddImage(src)

/turf/simulated/floor/open
	name = "open space"
	intact = 0
	density = 0
	icon_state = "black"
	pathweight = 100000 //Seriously, don't try and path over this one numbnuts
	var/icon/darkoverlays = null
	var/turf/floorbelow
	var/list/overlay_references
	mouse_opacity = 2

	New()
		..()
		spawn(1)
			if(!(z in levels_3d))
				ReplaceWithSpace()
			var/list/adjacent_to_me = global_adjacent_z_levels["[z]"]
			if(!("down" in adjacent_to_me))
				ReplaceWithSpace()

			floorbelow = locate(x, y, adjacent_to_me["down"])
			if(floorbelow)
				if(!istype(floorbelow,/turf))
					del src
				else if(floorbelow.density)
					ReplaceWithPlating()
				else
					set_up()
			else
				ReplaceWithSpace()


	Enter(var/atom/movable/AM)
		if (..()) //TODO make this check if gravity is active (future use) - Sukasa
			spawn(1)
				if(AM)
					AM.Move(floorbelow)
					if (istype(AM, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = AM
						var/damage = rand(5,15)
						H.apply_damage(2*damage, BRUTE, "head")
						H.apply_damage(2*damage, BRUTE, "chest")
						H.apply_damage(0.5*damage, BRUTE, "l_leg")
						H.apply_damage(0.5*damage, BRUTE, "r_leg")
						H.apply_damage(0.5*damage, BRUTE, "l_arm")
						H.apply_damage(0.5*damage, BRUTE, "r_arm")
						H:weakened = max(H:weakened,2)
						H:updatehealth()
		return ..()

	attackby()
		return //nothing

	proc/set_up() //Update the overlays to make the openspace turf show what's down a level
		if(!overlay_references)
			overlay_references = list()
		if(!floorbelow) return
		overlays += floorbelow
		for(var/obj/o in floorbelow)
			var/image/o_img = image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer)
			overlays += o_img
			overlay_references[o] = o_img

	proc/AddImage(var/atom/movable/o)
		var/o_img = image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer)
		overlays += o_img
		overlay_references[o] = o_img

	proc/RemoveImage(var/atom/movable/o)
		var/o_img = overlay_references[o]
		overlays -= o_img
		overlay_references -= o