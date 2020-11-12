/**
  * This is the riding component, which is applied to a movable atom by the [ridable element][/datum/element/ridable] when a mob is successfully buckled to said movable.
  *
  * This component lives for as long as at least one mob is buckled to the parent. Once all mobs are unbuckled, the component is deleted, until another mob is buckled in
  * and we make a new riding component, so on and so forth until the sun explodes.
  */


/datum/component/riding
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	///tick delay between movements, lower = faster, higher = slower
	var/vehicle_move_delay = 2

	/**
	  * If the driver needs a certain item in hand (or inserted, for vehicles) to drive this. For vehicles, this must be duplicated on the actual vehicle object in their
	  * [/obj/vehicle/var/key_type] variable because the vehicle objects still have a few special checks/functions of their own I'm not porting over to the riding component
	  * quite yet. Make sure if you define it on the vehicle, you define it here too.
	  */
	var/keytype

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
	/// We don't need roads where we're going if this is TRUE, allow normal movement in space tiles
	var/override_allow_spacemove = FALSE

	/**
	  * Ride check flags defined for the specific riding component types, so we know if we need arms, legs, or whatever.
	  * Takes additional flags from the ridable element and the buckle proc (addl_ride_flags) for riding cyborgs/humans in case we need to reserve arms
	  */
	var/ride_check_flags = NONE
	/// For telling someone they can't drive
	COOLDOWN_DECLARE(message_cooldown)


/datum/component/riding/Initialize(mob/living/riding_mob, force = FALSE, addl_ride_flags = NONE, potion_boost = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	handle_specials()
	riding_mob.updating_glide_size = FALSE
	ride_check_flags |= addl_ride_flags

	if(potion_boost)
		vehicle_move_delay = round(CONFIG_GET(number/movedelay/run_delay) * 0.85, 0.01)


/datum/component/riding/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/vehicle_turned)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/vehicle_mob_unbuckle)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/vehicle_moved)

/**
  * This proc handles all of the proc calls to things like set_vehicle_dir_layer() that a type of riding datum needs to call on creation
  *
  * The original riding component had these procs all called from the ridden object itself through the use of GetComponent() and LoadComponent()
  * This was obviously problematic for componentization, but while lots of the variables being set were able to be moved to component variables,
  * the proc calls couldn't be. Thus, anything that has to do an initial proc call should be handled here.
  */
/datum/component/riding/proc/handle_specials()
	return

/// This proc is called when a rider unbuckles, whether they chose to or not. If there's no more riders, this will be the riding component's death knell.
/datum/component/riding/proc/vehicle_mob_unbuckle(datum/source, mob/living/rider, force = FALSE)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	remove_abilities(rider)
	restore_position(rider)
	unequip_buckle_inhands(rider)
	rider.updating_glide_size = TRUE
	if(!movable_parent.has_buckled_mobs())
		qdel(src)

/// If the ridden atom is a creature with abilities, and some var yet to be made is set to TRUE, the rider will be able to control those abilities
/datum/component/riding/proc/setup_abilities(mob/living/M)
	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.AddAbility(proc_holder)

/// Takes away the riding parent's abilities from the rider
/datum/component/riding/proc/remove_abilities(mob/living/M)
	if(!istype(parent, /mob/living))
		return

	var/mob/living/ridden_creature = parent

	for(var/i in ridden_creature.abilities)
		var/obj/effect/proc_holder/proc_holder = i
		M.RemoveAbility(proc_holder)

/// Some ridable atoms may want to only show on top of the rider in certain directions, like wheelchairs
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

/// This is called after the ridden atom is successfully moved and is used to handle icon stuff
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

/// Turning is like moving
/datum/component/riding/proc/vehicle_turned(datum/source, _old_dir, new_dir)
	SIGNAL_HANDLER

	vehicle_moved(source, new_dir)

/// Check to see if we have all of the necessary bodyparts and not-falling-over statuses we need to stay onboard
/datum/component/riding/proc/ride_check(mob/living/rider)
	return

/datum/component/riding/proc/handle_vehicle_offsets(dir)
	var/atom/movable/AM = parent
	var/AM_dir = "[dir]"
	var/passindex = 0
	if(!AM.has_buckled_mobs())
		return

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

/**
  * This proc is used to see if we have the appropriate key to drive this atom, if such a key is needed. Returns FALSE if we don't have what we need to drive.
  *
  * Still needs to be neatened up and spruced up with proper OOP, as a result of vehicles having their own key handling from other ridable atoms
  */
/datum/component/riding/proc/keycheck(mob/user)
	if(!keytype)
		return TRUE

	if(isvehicle(parent))
		var/obj/vehicle/vehicle_parent = parent
		return istype(vehicle_parent.inserted_key, keytype)

	return user.is_holding_item_of_type(keytype)

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
		return allowed_turf_typecache[current.type]
	else if(forbid_turf_typecache && forbid_turf_typecache[next.type])
		return !forbid_turf_typecache[current.type]
	return TRUE



/// This proc is only used for cars so that they can play an engine rumble on movement. If we run this, we successfully moved a tile thru driving.
/datum/component/riding/proc/moved_successfully()
	return

/datum/component/riding/proc/Unbuckle(atom/movable/M)
	addtimer(CALLBACK(parent, /atom/movable/.proc/unbuckle_mob, M), 0, TIMER_UNIQUE)

/datum/component/riding/proc/Process_Spacemove(direction)
	var/atom/movable/AM = parent
	return override_allow_spacemove || AM.has_gravity()









/// currently replicated from ridable because we need this behavior here too, see if we can deal with that
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
