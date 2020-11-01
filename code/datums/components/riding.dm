/**
  * This is the riding component, which is applied to a movable atom so that various mobs can "ride" it, meaning they are buckled to
  * it and have their icon modified along with the vehicle's icon to indicate the riding state.
  *
  * There are two ways this component is used, one at atom initialization (inanimate vehicles), and one spontaneously at time of mounting (mobs)
  *	* 1. Inanimate- The component is created on initialization and persists when nothing is buckled to the parent. Think secways and cars.
  *	* 2. Mobs- Used for humans picking up humans, riding borgs, and riding tamed animals. The component is created at the time of mounting,
  *	* 		and is deleted when there are no more riders. If there are multiple riders, one component handles all of them.
  *
  * Arguments:
  * *
  */


/datum/component/riding
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	///tick delay between movements, lower = faster, higher = slower
	var/vehicle_move_delay = 2
	/// If the driver needs a specific item in hand in order to move this vehicle
	var/keytype

	var/slowed = FALSE
	var/slowvalue = 1

	/// If the vehicle is a mob with abilities, and this is TRUE, then the rider can trigger those abilities while mounted
	var/can_use_abilities = FALSE

	/// position_of_user = list(dir = list(px, py)), or RIDING_OFFSET_ALL for a generic one.
	var/list/riding_offsets = list()
	/// ["[DIRECTION]"] = layer. Don't set it for a direction for default, set a direction to null for no change.
	var/list/directional_vehicle_layers = list()
	/// same as above but instead of layer you have a list(px, py)
	var/list/directional_vehicle_offsets = list()
	/// allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/list/allowed_turf_typecache
	/// allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/list/forbid_turf_typecache
	/// allow moving one tile away from a valid turf but not more.
	var/allow_one_away_from_valid_turf = TRUE
	/// We don't need roads where we're going if this is TRUE, allow normal movement in space tiles
	var/override_allow_spacemove = FALSE

	/// If the "vehicle" is a mob, respect MOBILITY_MOVE on said mob.
	var/respect_mob_mobility = TRUE

	var/riding_flags

	var/rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS


/datum/component/riding/Initialize(mob/living/riding_mob, force = FALSE, riding_flags = NONE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	testing("check riding start | parent [parent] | rider [riding_mob] | flags [riding_flags]")

	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/vehicle_turned)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/vehicle_mob_unbuckle)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/vehicle_moved)
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_EMOTE, .proc/check_emote)

	handle_specials()

	if(isliving(parent))
		var/mob/living/parent_living = parent
		parent_living.stop_pulling() // was only used on humans previously, may change some other behavior
		riding_mob.set_glide_size(parent_living.glide_size)
		handle_vehicle_offsets(parent_living.dir)
	riding_mob.updating_glide_size = FALSE

	if(can_use_abilities)
		setup_abilities(riding_mob)

/datum/component/riding/Destroy(force, silent)
	if(isliving(parent))
		unequip_buckle_inhands(parent)
	return ..()


/datum/component/riding/proc/handle_specials()
	return

/// If we're a cyborg or animal and we spin, we yeet whoever's on us off us
/datum/component/riding/proc/check_emote(mob/living/user, datum/emote/emote)
	if((!iscyborg(user) && !isanimal(user)) || !istype(emote, /datum/emote/spin))
		return

	for(var/mob/yeet_mob in user.buckled_mobs)
		force_dismount(yeet_mob, (user.a_intent == INTENT_HELP)) // gentle on help, byeeee if not


/datum/component/riding/proc/vehicle_mob_unbuckle(datum/source, mob/living/rider, force = FALSE)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	remove_abilities(rider)
	restore_position(rider)
	unequip_buckle_inhands(rider)
	rider.updating_glide_size = TRUE
	if(!movable_parent.has_buckled_mobs())
		qdel(src)

///Gives the rider the riding parent's abilities
/datum/component/riding/proc/setup_abilities(mob/living/M)
	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.AddAbility(proc_holder)

///Takes away the riding parent's abilities from the rider
/datum/component/riding/proc/remove_abilities(mob/living/M)
	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.RemoveAbility(proc_holder)

/datum/component/riding/proc/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	var/static/list/defaults = list(TEXT_NORTH = OBJ_LAYER, TEXT_SOUTH = ABOVE_MOB_LAYER, TEXT_EAST = ABOVE_MOB_LAYER, TEXT_WEST = ABOVE_MOB_LAYER)
	. = defaults["[dir]"]
	if(directional_vehicle_layers["[dir]"])
		. = directional_vehicle_layers["[dir]"]
	if(isnull(.))	//you can set it to null to not change it.
		. = AM.layer
	AM.layer = .

/datum/component/riding/proc/set_vehicle_dir_layer(dir, layer)
	directional_vehicle_layers["[dir]"] = layer

/datum/component/riding/proc/vehicle_moved(datum/source, dir)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	if (isnull(dir))
		dir = movable_parent.dir
	movable_parent.set_glide_size(DELAY_TO_GLIDE_SIZE(vehicle_move_delay))
	for (var/m in movable_parent.buckled_mobs)
		var/mob/buckled_mob = m
		ride_check(buckled_mob)
		buckled_mob.set_glide_size(movable_parent.glide_size)
	if(QDELETED(src))
		return // runtimed with piggy's without this, look into this more
	handle_vehicle_offsets(dir)
	handle_vehicle_layer(dir)

/datum/component/riding/proc/vehicle_turned(datum/source, _old_dir, new_dir)
	SIGNAL_HANDLER

	vehicle_moved(source, new_dir)

/datum/component/riding/proc/ride_check(mob/living/rider)
	var/mob/living/parent_movable = parent
	var/mob/living/parent_living = parent
	var/kick_us_off

	// for piggybacks and (redundant?) borg riding, check if the rider is stunned/restrained
	if((riding_flags & RIDER_HOLDING_ON) && (HAS_TRAIT(rider, TRAIT_RESTRAINED) || rider.incapacitated(TRUE, TRUE)))
		kick_us_off = TRUE
	else if(isliving(parent_living))
		// for fireman carries, check if the ridden is stunned/restrained
		if((riding_flags & RIDDEN_HOLDING_RIDER) && (HAS_TRAIT(parent_living, TRAIT_RESTRAINED) || parent_living.incapacitated(TRUE, TRUE)))
			kick_us_off = TRUE
		// no matter what, you can't ride something that's on the floor
		else if(parent_living.body_position != STANDING_UP)
			kick_us_off = TRUE

	if(!kick_us_off)
		return TRUE

	rider.visible_message("<span class='warning'>[rider] falls off of [parent_movable]!</span>", \
					"<span class='warning'>You fall off of [parent_movable]!</span>")
	parent_movable.unbuckle_mob(rider)

/datum/component/riding/proc/force_dismount(mob/living/rider, gentle = FALSE)
	var/atom/movable/parent_movable = parent
	parent_movable.unbuckle_mob(rider)

	if(!isanimal(parent_movable) && !iscyborg(parent_movable))
		return

	var/turf/target = get_edge_target_turf(parent_movable, parent_movable.dir)
	var/turf/targetm = get_step(get_turf(parent_movable), parent_movable.dir)
	rider.Move(targetm)
	rider.Knockdown(3 SECONDS)
	if(gentle)
		rider.visible_message("<span class='warning'>[rider] is thrown clear of [parent_movable]!</span>", \
		"<span class='warning'>You're thrown clear of [parent_movable]!</span>")
		rider.throw_at(target, 8, 3, parent_movable, gentle = TRUE)
	else
		rider.visible_message("<span class='warning'>[rider] is thrown violently from [parent_movable]!</span>", \
		"<span class='warning'>You're thrown violently from [parent_movable]!</span>")
		rider.throw_at(target, 14, 5, parent_movable, gentle = FALSE)

/datum/component/riding/proc/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	var/AM_dir = "[dir]"
	var/passindex = 0
	if(AM.has_buckled_mobs())
		for(var/m in AM.buckled_mobs)
			passindex++
			var/mob/living/buckled_mob = m
			var/list/offsets = get_offsets(passindex)
			buckled_mob.setDir(dir)
			dir_loop:
				for(var/offsetdir in offsets)
					if(offsetdir == AM_dir)
						var/list/diroffsets = offsets[offsetdir]
						buckled_mob.pixel_x = diroffsets[1]
						if(diroffsets.len >= 2)
							buckled_mob.pixel_y = diroffsets[2]
						if(diroffsets.len == 3)
							buckled_mob.layer = diroffsets[3]
						break dir_loop
	var/list/static/default_vehicle_pixel_offsets = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	var/px = default_vehicle_pixel_offsets[AM_dir]
	var/py = default_vehicle_pixel_offsets[AM_dir]
	if(directional_vehicle_offsets[AM_dir])
		if(isnull(directional_vehicle_offsets[AM_dir]))
			px = AM.pixel_x
			py = AM.pixel_y
		else
			px = directional_vehicle_offsets[AM_dir][1]
			py = directional_vehicle_offsets[AM_dir][2]
	AM.pixel_x = px
	AM.pixel_y = py

/datum/component/riding/proc/set_vehicle_dir_offsets(dir, x, y)
	directional_vehicle_offsets["[dir]"] = list(x, y)

//Override this to set your vehicle's various pixel offsets
/datum/component/riding/proc/get_offsets(pass_index) // list(dir = x, y, layer)
	. = list(TEXT_NORTH = list(0, 0), TEXT_SOUTH = list(0, 0), TEXT_EAST = list(0, 0), TEXT_WEST = list(0, 0))
	if(riding_offsets["[pass_index]"])
		. = riding_offsets["[pass_index]"]
	else if(riding_offsets["[RIDING_OFFSET_ALL]"])
		. = riding_offsets["[RIDING_OFFSET_ALL]"]

/datum/component/riding/proc/set_riding_offsets(index, list/offsets)
	if(!islist(offsets))
		return FALSE
	riding_offsets["[index]"] = offsets

//KEYS
/datum/component/riding/proc/keycheck(mob/user)
	return !keytype || user.is_holding_item_of_type(keytype)

//BUCKLE HOOKS
/datum/component/riding/proc/restore_position(mob/living/buckled_mob)
	if(buckled_mob)
		buckled_mob.pixel_x = buckled_mob.base_pixel_x
		buckled_mob.pixel_y = buckled_mob.base_pixel_y
		if(buckled_mob.client)
			buckled_mob.client.view_size.resetToDefault()

//MOVEMENT
/datum/component/riding/proc/turf_check(turf/next, turf/current)
	if(allowed_turf_typecache && !allowed_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && allowed_turf_typecache[current.type])
	else if(forbid_turf_typecache && forbid_turf_typecache[next.type])
		return (allow_one_away_from_valid_turf && !forbid_turf_typecache[current.type])
	return TRUE

/datum/component/riding/proc/handle_ride(mob/user, direction)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		Unbuckle(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal? 2 : 1) * vehicle_move_delay))
		return
	last_vehicle_move = world.time

	if(!keycheck(user))
		to_chat(user, "<span class='warning'>You'll need a special item in one of your hands to operate [AM].</span>")
		return

	var/turf/next = get_step(AM, direction)
	var/turf/current = get_turf(AM)
	if(!istype(next) || !istype(current))
		return	//not happening.
	if(!turf_check(next, current))
		to_chat(user, "<span class='warning'>Your \the [AM] can not go onto [next]!</span>")
		return
	if(!Process_Spacemove(direction) || !isturf(AM.loc))
		return
	if(isliving(AM) && respect_mob_mobility)
		var/mob/living/M = AM
		if(!(M.mobility_flags & MOBILITY_MOVE))
			return
	step(AM, direction)

	if((direction & (direction - 1)) && (AM.loc == next))		//moved diagonally
		last_move_diagonal = TRUE
	else
		last_move_diagonal = FALSE

	handle_vehicle_layer(AM.dir)
	handle_vehicle_offsets(AM.dir)


/datum/component/riding/proc/Unbuckle(atom/movable/M)
	addtimer(CALLBACK(parent, /atom/movable/.proc/unbuckle_mob, M), 0, TIMER_UNIQUE)

/datum/component/riding/proc/Process_Spacemove(direction)
	var/atom/movable/AM = parent
	return override_allow_spacemove || AM.has_gravity()

/datum/component/riding/proc/account_limbs(mob/living/M)
	if(M.usable_legs < 2 && !slowed)
		vehicle_move_delay = vehicle_move_delay + slowvalue
		slowed = TRUE
	else if(slowed)
		vehicle_move_delay = vehicle_move_delay - slowvalue
		slowed = FALSE

///////Yes, I said humans. No, this won't end well...//////////
/datum/component/riding/human

/datum/component/riding/human/Initialize(mob/living/riding_mob, force = FALSE, riding_flags = NONE)
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_host_unarmed_melee)
	var/mob/living/carbon/human/H = parent
	H.add_movespeed_modifier(/datum/movespeed_modifier/human_carry)

/datum/component/riding/human/vehicle_mob_unbuckle(datum/source, mob/living/M, force = FALSE)
	unequip_buckle_inhands(parent)
	var/mob/living/carbon/human/H = parent
	H.remove_movespeed_modifier(/datum/movespeed_modifier/human_carry)
	. = ..()

/// If the carrier gets shoved, drop our load
/datum/component/riding/human/proc/on_host_unarmed_melee(atom/target)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = parent
	if(H.a_intent == INTENT_DISARM && (target in H.buckled_mobs))
		force_dismount(target)

/datum/component/riding/human/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(!AM.buckled_mobs || !AM.buckled_mobs.len)
		AM.layer = MOB_LAYER
		return

	for(var/mob/M in AM.buckled_mobs) //ensure proper layering of piggyback and carry, sometimes weird offsets get applied
		M.layer = MOB_LAYER
	if(!AM.buckle_lying)
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else
		if(dir == NORTH)
			AM.layer = OBJ_LAYER
		else
			AM.layer = ABOVE_MOB_LAYER


/datum/component/riding/human/get_offsets(pass_index)
	var/mob/living/carbon/human/H = parent
	if(H.buckle_lying)
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(0, 6), TEXT_WEST = list(0, 6))
	else
		return list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-6, 4), TEXT_WEST = list( 6, 4))


/datum/component/riding/human/force_dismount(mob/living/user)
	var/atom/movable/AM = parent
	AM.unbuckle_mob(user)
	user.Paralyze(60)
	user.visible_message("<span class='warning'>[AM] pushes [user] off of [AM.p_them()]!</span>", \
						"<span class='warning'>[AM] pushes you off of [AM.p_them()]!</span>")

/datum/component/riding/cyborg

/datum/component/riding/cyborg/ride_check(mob/user)
	if(!iscyborg(parent))
		return

	var/mob/living/silicon/robot/robot_parent = parent
	if(user.incapacitated() && !(robot_parent.module?.ride_allow_incapacitated))
		to_chat(user, "<span class='userdanger'>You fall off of [robot_parent]!</span>")
		Unbuckle(user)
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbonuser = user
		if(!carbonuser.usable_hands)
			Unbuckle(user)
			to_chat(user, "<span class='warning'>You can't grab onto [robot_parent] with no hands!</span>")
			return

/datum/component/riding/cyborg/handle_vehicle_layer(dir)
	var/atom/movable/AM = parent
	if(AM.buckled_mobs && AM.buckled_mobs.len)
		if(dir == SOUTH)
			AM.layer = ABOVE_MOB_LAYER
		else
			AM.layer = OBJ_LAYER
	else
		AM.layer = MOB_LAYER

/datum/component/riding/cyborg/get_offsets(pass_index) // list(dir = x, y, layer)
	return list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-6, 3), TEXT_WEST = list( 6, 3))

/datum/component/riding/cyborg/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	if(AM.has_buckled_mobs())
		for(var/mob/living/M in AM.buckled_mobs)
			M.setDir(dir)
			if(iscyborg(AM))
				var/mob/living/silicon/robot/R = AM
				if(istype(R.module))
					M.pixel_x = R.module.ride_offset_x[dir2text(dir)]
					M.pixel_y = R.module.ride_offset_y[dir2text(dir)]
			else
				..()

/datum/component/riding/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, riding_target_override = null)
	var/atom/movable/AM = parent
	var/amount_equipped = 0
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		if(!riding_target_override)
			inhand.rider = user
		else
			inhand.rider = riding_target_override
		inhand.parent = AM
		for(var/obj/item/I in user.held_items) // delete any hand items like slappers that could still totally be used to grab on
			if((I.obj_flags & HAND_ITEM))
				qdel(I)
		if(user.put_in_hands(inhand, TRUE))
			amount_equipped++
		else
			break

	if(amount_equipped >= amount_required)
		return TRUE
	else
		unequip_buckle_inhands(user)
		return FALSE

/datum/component/riding/proc/unequip_buckle_inhands(mob/living/carbon/user)
	var/atom/movable/AM = parent
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE
