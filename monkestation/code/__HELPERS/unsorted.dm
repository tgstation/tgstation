//Used to get a random closed and non-secure locker on the station z-level, created for the Stowaway trait.
/proc/get_unlocked_closed_locker() //I've seen worse proc names
	var/list/picked_lockers = list()
	var/turf/object_location
	for(var/obj/structure/closet/find_closet in world)
		if(!find_closet.locked)
			object_location = get_turf(find_closet)
			if(object_location) //If it can't read a Z on the next step, it will error out. Needs a separate check.
				if(is_station_level(object_location.z) && !find_closet.opened) //On the station and closed.
					picked_lockers += find_closet
	if(picked_lockers)
		return pick(picked_lockers)
	return FALSE

//For all your moth grabbing needs.
/proc/Grab_Moths(turf/T, range = 6, speed = 0.5)
	for(var/mob/living/carbon/human/H in oview(range, T))
		if(ismoth(H) && isliving(H))
			pick(H.emote("scream"), H.visible_message("<span class='boldwarning'>[H] lunges for the light!</span>"))
			H.throw_at(T, range, speed)

//For vaulting over stuff!
/proc/vault_over_object(mob/user, object, range = 3, speed = 0.5)
	var/dir = get_dir(user, object)
	var/turf/target = get_ranged_target_turf(user, dir, range)
	var/obj/machinery/machine_target = locate() in target
	var/mob/living/carbon/human/H = user
	if(machine_target)
		user.throw_at(machine_target, range, speed)
		if(prob(70))
			H.Knockdown(10)
	else
		user.throw_at(target, range, speed)
		if(prob(25))
			H.Knockdown(10)

/proc/monkeyfriend_check(mob/living/user)
	var/obj/item/clothing/suit/monkeysuit/S
	var/obj/item/clothing/mask/gas/monkeymask/M
	var/list/equipped = user.get_equipped_items(FALSE)
	if(issimian(user))
		ADD_TRAIT(user, TRAIT_MONKEYFRIEND, SPECIES_TRAIT)
	if(((M in equipped) && (S in equipped)))
		ADD_TRAIT(user, TRAIT_MONKEYFRIEND, CLOTHING_TRAIT)

// Takes an input direction and then outputs the opposite direction.
/proc/getOppositeDir(var/direction, var/always_return_cardinal = 0) // always_return_cardinal is for conveyors and anything else that uses their style of turning.
	switch(direction)
		if(NORTH)
			return SOUTH
		if(SOUTH)
			return NORTH
		if(EAST)
			return WEST
		if(WEST)
			return EAST
		if(NORTHEAST)
			if(always_return_cardinal == 1)
				return SOUTH
			else
				return SOUTHWEST
		if(NORTHWEST)
			if(always_return_cardinal == 1)
				return EAST
			else
				return SOUTHEAST
		if(SOUTHEAST)
			if(always_return_cardinal == 1)
				return WEST
			else
				return NORTHWEST
		if(SOUTHWEST)
			if(always_return_cardinal == 1)
				return NORTH
			else
				return NORTHEAST
