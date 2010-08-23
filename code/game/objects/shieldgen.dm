/obj/shieldgen/Del()
	for(var/obj/shield/shield_tile in deployed_shields)
		del(shield_tile)

	..()

/obj/shieldgen/var/list/obj/shield/deployed_shields

/obj/shieldgen/proc
	shields_up()
		if(active) return 0

		for(var/turf/target_tile in range(2, src))
			if (istype(target_tile,/turf/space) && !(locate(/obj/shield) in target_tile))
				if (malfunction && prob(33) || !malfunction)
					deployed_shields += new /obj/shield(target_tile)

		src.anchored = 1
		src.active = 1
		src.icon_state = malfunction ? "shieldonbr":"shieldon"

		spawn src.process()

	shields_down()
		if(!active) return 0

		for(var/obj/shield/shield_tile in deployed_shields)
			del(shield_tile)

		src.anchored = 0
		src.active = 0
		src.icon_state = malfunction ? "shieldoffbr":"shieldoff"

/obj/shieldgen/proc/process()
	if(active)
		src.icon_state = malfunction ? "shieldonbr":"shieldon"

		if(malfunction)
			while(prob(10))
				del(pick(deployed_shields))

		spawn(30)
			src.process()
	return

/obj/shieldgen/proc/checkhp()
	if(health <= 30)
		src.malfunction = 1
	if(health <= 10 && prob(75))
		del(src)
	if (active)
		src.icon_state = malfunction ? "shieldonbr":"shieldon"
	else
		src.icon_state = malfunction ? "shieldoffbr":"shieldoff"
	return

/obj/shieldgen/meteorhit(obj/O as obj)
	src.health -= 25
	if (prob(5))
		src.malfunction = 1
	src.checkhp()
	return

/obj/shield/meteorhit(obj/O as obj)
	if (prob(75))
		del(src)
	return

/obj/shieldgen/ex_act(severity)
	switch(severity)
		if(1.0)
			src.health -= 75
			src.checkhp()
		if(2.0)
			src.health -= 30
			if (prob(15))
				src.malfunction = 1
			src.checkhp()
		if(3.0)
			src.health -= 10
			src.checkhp()
	return

/obj/shield/ex_act(severity)
	switch(severity)
		if(1.0)
			if (prob(75))
				del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(25))
				del(src)
	return

/obj/shieldgen/attack_hand(mob/user as mob)
	if (active)
		for(var/mob/viwer in viewers(world.view, src.loc))
			viwer << text("<font color='blue'>\icon[] [user] deactivated the shield generator.</font>", src)

		shields_down()

	else
		for(var/mob/viwer in viewers(world.view, src.loc))
			viwer << text("<font color='blue'>\icon[] [user] activated the shield generator.</font>", src)

		shields_up()

/obj/shieldwallgen/attack_hand(mob/user as mob)
	/*
	if (!active)
		for(var/mob/O in viewers(world.view, src.loc))
			O << text("<font color='blue'>\icon[] [user] activated the shield generator.</font>", src)

		var/xa
		var/ya
		var/piece
		var/atom/A

		for(xa=(-range), xa<((range*2)+(1-range)), xa++)
			for(ya=(-range), ya<((range*2)+(1-range)), ya++)
				if ( (xa != range && xa != -range) && (ya != range && ya != -range) )
					continue
				if(xa == -range && ya == range) piece = NORTHWEST
				if(xa == range && ya == range) piece = NORTHEAST
				if(xa == -range && ya == -range) piece = SOUTHWEST
				if(xa == range && ya == -range) piece = SOUTHEAST
				if( (xa != range && xa != -range) && ya == range) piece = NORTH
				if( (xa != range && xa != -range) && ya == -range) piece = SOUTH
				if( xa == range && (ya != range && ya != -range)) piece = EAST
				if( xa == -range && (ya != range && ya != -range)) piece = WEST

				A = locate((src.x + xa),(src.y + ya),src.z)
				if (!A.density)
					var/obj/shieldwall/created = new /obj/shieldwall ( locate((src.x + xa),(src.y + ya),src.z) )
					created.dir = piece
					A:updatecell = 0
					A:buildlinks()

		src.anchored = 1
		src.active = 1
	else
		for(var/mob/O in viewers(world.view, src.loc))
			O << text("<font color='blue'>\icon[] [user] deactivated the shield generator.</font>", src)
		var/tile
		var/tilepick
		var/xa
		var/ya
		for(xa=(-range), xa<((range*2)+(1-range)), xa++)
			for(ya=(-range), ya<((range*2)+(1-range)), ya++)
				if ( (xa != range && xa != -range) && (ya != range && ya != -range) )
					continue
				tilepick = null
				tile = locate( (src.x + xa),(src.y + ya),src.z )
				tilepick = locate(/obj/shieldwall) in tile
				if(tilepick) del(tilepick)
				tile:updatecell = 1
				tile:buildlinks()
		src.anchored = 0
		src.active = 0
	*/

/obj/shieldgen/attack_paw(mob/user as mob)
	if (active)
		for(var/mob/O in viewers(world.view, src.loc))
			O << text("<font color='blue'>\icon[] [user] deactivated the shield generator.</font>", src)

		shields_down()

	else
		for(var/mob/O in viewers(world.view, src.loc))
			O << text("<font color='blue'>\icon[] [user] activated the shield generator.</font>", src)

		shields_up()

/obj/shield
	New()
		src.dir = pick(1,2,3,4)

		..()

		update_nearby_tiles(need_rebuild=1)

	Del()
		update_nearby_tiles()

		..()

	CanPass(atom/movable/mover, turf/target, height, air_group)
		if(!height || air_group) return 0
		else return ..()

	proc/update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/north = get_step(source,NORTH)
		var/turf/simulated/south = get_step(source,SOUTH)
		var/turf/simulated/east = get_step(source,EAST)
		var/turf/simulated/west = get_step(source,WEST)

		if(need_rebuild)
			if(istype(source)) //Rebuild/update nearby group geometry
				if(source.parent)
					air_master.groups_to_rebuild += source.parent
				else
					air_master.tiles_to_update += source
			if(istype(north))
				if(north.parent)
					air_master.groups_to_rebuild += north.parent
				else
					air_master.tiles_to_update += north
			if(istype(south))
				if(south.parent)
					air_master.groups_to_rebuild += south.parent
				else
					air_master.tiles_to_update += south
			if(istype(east))
				if(east.parent)
					air_master.groups_to_rebuild += east.parent
				else
					air_master.tiles_to_update += east
			if(istype(west))
				if(west.parent)
					air_master.groups_to_rebuild += west.parent
				else
					air_master.tiles_to_update += west
		else
			if(istype(source)) air_master.tiles_to_update += source
			if(istype(north)) air_master.tiles_to_update += north
			if(istype(south)) air_master.tiles_to_update += south
			if(istype(east)) air_master.tiles_to_update += east
			if(istype(west)) air_master.tiles_to_update += west

		return 1