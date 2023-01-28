GLOBAL_LIST_EMPTY(lifts)

/obj/structure/industrial_lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	armor_type = /datum/armor/structure_industrial_lift
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_INDUSTRIAL_LIFT
	canSmoothWith = SMOOTH_GROUP_INDUSTRIAL_LIFT
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER //no TILE_BOUND since we're potentially multitile
	// If we don't do this, we'll build our overlays early, and fuck up how we're rendered
	blocks_emissive = NONE

	///ID used to determine what lift types we can merge with
	var/lift_id = BASIC_LIFT_ID

	///if true, the elevator works through floors
	var/pass_through_floors = FALSE

	///what movables on our platform that we are moving
	var/list/atom/movable/lift_load = list()
	///weakrefs to the contents we have when we're first created. stored so that admins can clear the tram to its initial state
	///if someone put a bunch of stuff onto it.
	var/list/datum/weakref/initial_contents = list()

	///what glide_size we set our moving contents to.
	var/glide_size_override = 8
	///movables inside lift_load who had their glide_size changed since our last movement.
	///used so that we dont have to change the glide_size of every object every movement, which scales to cost more than you'd think
	var/list/atom/movable/changed_gliders = list()

	///master datum that controls our movement. in general /industrial_lift subtypes control moving themselves, and
	/// /datum/lift_master instances control moving the entire tram and any behavior associated with that.
	var/datum/lift_master/lift_master_datum
	///what subtype of /datum/lift_master to create for itself if no other platform on this tram has created one yet.
	///very important for some behaviors since
	var/lift_master_type = /datum/lift_master

	///how many tiles this platform extends on the x axis
	var/width = 1
	///how many tiles this platform extends on the y axis (north-south not up-down, that would be the z axis)
	var/height = 1

	///if TRUE, this platform will late initialize and then expand to become a multitile object across all other linked platforms on this z level
	var/create_multitile_platform = FALSE

	/// Does our elevator warn people (with visual effects) when moving down?
	var/warns_on_down_movement = FALSE
	/// if TRUE, we will gib anyone we land on top of. if FALSE, we will just apply damage with a serious wound penalty.
	var/violent_landing = TRUE
	/// damage multiplier if a mob is hit by the lift while it is moving horizontally
	var/collision_lethality = 1
	/// How long does it take for the elevator to move vertically?
	var/elevator_vertical_speed = 2 SECONDS

	/// We use a radial to travel primarily, instead of a button / ui
	var/radial_travel = TRUE
	/// A lazylist of REFs to all mobs which have a radial open currently
	var/list/current_operators

/datum/armor/structure_industrial_lift
	melee = 50
	fire = 80
	acid = 50

/obj/structure/industrial_lift/Initialize(mapload)
	. = ..()
	GLOB.lifts.Add(src)

	// Yes if it's VV'd it won't be accurate but it probably shouldn't ever be
	if(radial_travel)
		AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Send Elevator")

	set_movement_registrations()

	//since lift_master datums find all connected platforms when an industrial lift first creates it and then
	//sets those platforms' lift_master_datum to itself, this check will only evaluate to true once per tram platform
	if(!lift_master_datum && lift_master_type)
		lift_master_datum = new lift_master_type(src)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/industrial_lift/LateInitialize()
	//after everything is initialized the lift master can order everything
	lift_master_datum.order_platforms_by_z_level()

/obj/structure/industrial_lift/Destroy()
	GLOB.lifts.Remove(src)
	lift_master_datum = null
	return ..()


///set the movement registrations to our current turf(s) so contents moving out of our tile(s) are removed from our movement lists
/obj/structure/industrial_lift/proc/set_movement_registrations(list/turfs_to_set)
	for(var/turf/turf_loc as anything in turfs_to_set || locs)
		RegisterSignal(turf_loc, COMSIG_ATOM_EXITED, PROC_REF(UncrossedRemoveItemFromLift))
		RegisterSignals(turf_loc, list(COMSIG_ATOM_ENTERED,COMSIG_ATOM_INITIALIZED_ON), PROC_REF(AddItemOnLift))

///unset our movement registrations from turfs that no longer contain us (or every loc if turfs_to_unset is unspecified)
/obj/structure/industrial_lift/proc/unset_movement_registrations(list/turfs_to_unset)
	var/static/list/registrations = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_INITIALIZED_ON)
	for(var/turf/turf_loc as anything in turfs_to_unset || locs)
		UnregisterSignal(turf_loc, registrations)


/obj/structure/industrial_lift/proc/UncrossedRemoveItemFromLift(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(!(gone.loc in locs))
		RemoveItemFromLift(gone)

/obj/structure/industrial_lift/proc/RemoveItemFromLift(atom/movable/potential_rider)
	SIGNAL_HANDLER
	if(!(potential_rider in lift_load))
		return
	if(isliving(potential_rider) && HAS_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED))
		REMOVE_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)

	lift_load -= potential_rider
	changed_gliders -= potential_rider

	UnregisterSignal(potential_rider, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE))

/obj/structure/industrial_lift/proc/AddItemOnLift(datum/source, atom/movable/new_lift_contents)
	SIGNAL_HANDLER
	var/static/list/blacklisted_types = typecacheof(list(/obj/structure/fluff/tram_rail, /obj/effect/decal/cleanable, /obj/structure/industrial_lift, /mob/camera))
	if(is_type_in_typecache(new_lift_contents, blacklisted_types) || new_lift_contents.invisibility == INVISIBILITY_ABSTRACT) //prevents the tram from stealing things like landmarks
		return FALSE
	if(new_lift_contents in lift_load)
		return FALSE

	if(isliving(new_lift_contents) && !HAS_TRAIT(new_lift_contents, TRAIT_CANNOT_BE_UNBUCKLED))
		ADD_TRAIT(new_lift_contents, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)

	lift_load += new_lift_contents
	RegisterSignal(new_lift_contents, COMSIG_PARENT_QDELETING, PROC_REF(RemoveItemFromLift))

	return TRUE

///adds everything on our tile that can be added to our lift_load and initial_contents lists when we're created
/obj/structure/industrial_lift/proc/add_initial_contents()
	for(var/turf/turf_loc in locs)
		for(var/atom/movable/movable_contents as anything in turf_loc)
			if(movable_contents == src)
				continue

			if(AddItemOnLift(src, movable_contents))

				var/datum/weakref/new_initial_contents = WEAKREF(movable_contents)
				if(!new_initial_contents)
					continue

				initial_contents += new_initial_contents

///signal handler for COMSIG_MOVABLE_UPDATE_GLIDE_SIZE: when a movable in lift_load changes its glide_size independently.
///adds that movable to a lazy list, movables in that list have their glide_size updated when the tram next moves
/obj/structure/industrial_lift/proc/on_changed_glide_size(atom/movable/moving_contents, new_glide_size)
	SIGNAL_HANDLER
	if(new_glide_size != glide_size_override)
		changed_gliders += moving_contents


///make this tram platform multitile, expanding to cover all the tram platforms adjacent to us and deleting them. makes movement more efficient.
///the platform becoming multitile should be in the bottom left corner since thats assumed to be the loc of multitile objects
/obj/structure/industrial_lift/proc/create_multitile_platform(min_x, min_y, max_x, max_y, z)

	if(!(min_x && min_y && max_x && max_y && z))
		for(var/obj/structure/industrial_lift/other_lift as anything in lift_master_datum.lift_platforms)
			if(other_lift.z != z)
				continue

			min_x = min(min_x, other_lift.x)
			max_x = max(max_x, other_lift.x)

			min_y = min(min_y, other_lift.y)
			max_y = max(max_y, other_lift.y)

	var/turf/bottom_left_loc = locate(min_x, min_y, z)
	var/obj/structure/industrial_lift/loc_corner_lift = locate() in bottom_left_loc

	if(!loc_corner_lift)
		stack_trace("no lift in the bottom left corner of a lift level!")
		return FALSE

	if(loc_corner_lift != src)
		//the loc of a multitile object must always be the lower left corner
		return loc_corner_lift.create_multitile_platform()

	width = (max_x - min_x) + 1
	height = (max_y - min_y) + 1

	///list of turfs we dont go over. if for whatever reason we encounter an already multitile lift platform
	///we add all of its locs to this list so we dont add that lift platform multiple times as we iterate through its locs
	var/list/locs_to_skip = locs.Copy()

	bound_width = bound_width * width
	bound_height = bound_height * height

	//multitile movement code assumes our loc is on the lower left corner of our bounding box

	var/first_x = 0
	var/first_y = 0

	var/last_x = max(max_x - min_x, 0)
	var/last_y = max(max_y - min_y, 0)

	for(var/y in first_y to last_y)

		var/y_pixel_offset = world.icon_size * y

		for(var/x in first_x to last_x)

			var/x_pixel_offset = world.icon_size * x

			var/turf/lift_turf = locate(x + min_x, y + min_y, z)

			if(!lift_turf)
				continue

			if(lift_turf in locs_to_skip)
				continue

			var/obj/structure/industrial_lift/other_lift = locate() in lift_turf

			if(!other_lift)
				continue

			locs_to_skip += other_lift.locs.Copy()//make sure we never go over multitile platforms multiple times

			other_lift.pixel_x = x_pixel_offset
			other_lift.pixel_y = y_pixel_offset

			overlays += other_lift

	//now we vore all the other lifts connected to us on our z level
	for(var/obj/structure/industrial_lift/other_lift in lift_master_datum.lift_platforms)
		if(other_lift == src || other_lift.z != z)
			continue

		lift_master_datum.lift_platforms -= other_lift
		if(other_lift.lift_load)
			lift_load |= other_lift.lift_load
		if(other_lift.initial_contents)
			initial_contents |= other_lift.initial_contents

		qdel(other_lift)

	lift_master_datum.multitile_platform = TRUE

	var/turf/old_loc = loc

	forceMove(locate(min_x, min_y, z))//move to the lower left corner
	set_movement_registrations(locs - old_loc)
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	update_appearance()
	return TRUE

///returns an unordered list of all lift platforms adjacent to us. used so our lift_master_datum can control all connected platforms.
///includes platforms directly above or below us as well. only includes platforms with an identical lift_id to our own.
/obj/structure/industrial_lift/proc/lift_platform_expansion(datum/lift_master/lift_master_datum)
	. = list()
	for(var/direction in GLOB.cardinals_multiz)
		var/obj/structure/industrial_lift/neighbor = locate() in get_step_multiz(src, direction)
		if(!neighbor || neighbor.lift_id != lift_id)
			continue
		. += neighbor

///main proc for moving the lift in the direction [going]. handles horizontal and/or vertical movement for multi platformed lifts and multitile lifts.
/obj/structure/industrial_lift/proc/travel(going)
	var/list/things_to_move = lift_load
	var/turf/destination
	if(!isturf(going))
		destination = get_step_multiz(src, going)
	else
		destination = going
		going = get_dir_multiz(loc, going)

	var/x_offset = ROUND_UP(bound_width / 32) - 1 //how many tiles our horizontally farthest edge is from us
	var/y_offset = ROUND_UP(bound_height / 32) - 1 //how many tiles our vertically farthest edge is from us

	//the x coordinate of the edge furthest from our future destination, which would be our right hand side
	var/back_edge_x = destination.x + x_offset//if we arent multitile this should just be destination.x
	var/top_edge_y = destination.y + y_offset

	var/turf/top_right_corner = locate(min(world.maxx, back_edge_x), min(world.maxy, top_edge_y), destination.z)

	var/list/dest_locs = block(
		destination,
		top_right_corner
	)

	var/list/entering_locs = dest_locs - locs
	var/list/exited_locs = locs - dest_locs

	if(going == DOWN)
		for(var/turf/dest_turf as anything in entering_locs)
			SEND_SIGNAL(dest_turf, COMSIG_TURF_INDUSTRIAL_LIFT_ENTER, things_to_move)

			if(iswallturf(dest_turf))
				var/turf/closed/wall/hit_wall = dest_turf
				do_sparks(2, FALSE, hit_wall)
				hit_wall.dismantle_wall(devastated = TRUE)
				for(var/mob/nearby_witness in urange(8, src))
					shake_camera(nearby_witness, 2, 3)
				playsound(hit_wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)

			for(var/mob/living/crushed in dest_turf.contents)
				to_chat(crushed, span_userdanger("You are crushed by [src]!"))
				if(violent_landing)
					// Violent landing = gibbed. But the nicest kind of gibbing, keeping everything intact.
					crushed.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
					crushed.gib(FALSE, FALSE, FALSE)
				else
					// Less violent landing simply crushes every bone in your body.
					crushed.Paralyze(30 SECONDS, ignore_canstun = TRUE)
					crushed.apply_damage(30, BRUTE, BODY_ZONE_CHEST, wound_bonus = 30)
					crushed.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 25)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_L_LEG, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_R_LEG, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_L_ARM, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_R_ARM, wound_bonus = 15)

	else if(going == UP)
		for(var/turf/dest_turf as anything in entering_locs)
			///handles any special interactions objects could have with the lift/tram, handled on the item itself
			SEND_SIGNAL(dest_turf, COMSIG_TURF_INDUSTRIAL_LIFT_ENTER, things_to_move)

			if(iswallturf(dest_turf))
				var/turf/closed/wall/hit_wall = dest_turf
				do_sparks(2, FALSE, hit_wall)
				hit_wall.dismantle_wall(devastated = TRUE)
				for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(src, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
					shake_camera(client_mob, 2, 3)
				playsound(hit_wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	else
		///potentially finds a spot to throw the victim at for daring to be hit by a tram. is null if we havent found anything to throw
		var/atom/throw_target

		for(var/turf/dest_turf as anything in entering_locs)
			///handles any special interactions objects could have with the lift/tram, handled on the item itself
			SEND_SIGNAL(dest_turf, COMSIG_TURF_INDUSTRIAL_LIFT_ENTER, things_to_move)

			if(iswallturf(dest_turf))
				var/turf/closed/wall/collided_wall = dest_turf
				do_sparks(2, FALSE, collided_wall)
				collided_wall.dismantle_wall(devastated = TRUE)
				for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(collided_wall, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
					shake_camera(client_mob, duration = 2, strength = 3)

				playsound(collided_wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)

			if(ismineralturf(dest_turf))
				var/turf/closed/mineral/dest_mineral_turf = dest_turf
				for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(dest_mineral_turf, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
					shake_camera(client_mob, duration = 2, strength = 3)
				dest_mineral_turf.gets_drilled(give_exp = FALSE)

			for(var/obj/structure/victim_structure in dest_turf.contents)
				if(QDELING(victim_structure))
					continue
				if(!is_type_in_typecache(victim_structure, lift_master_datum.ignored_smashthroughs) && victim_structure.layer >= LOW_OBJ_LAYER)

					if(victim_structure.anchored && initial(victim_structure.anchored) == TRUE)
						visible_message(span_danger("[src] smashes through [victim_structure]!"))
						victim_structure.deconstruct(FALSE)

					else
						if(!throw_target)
							throw_target = get_edge_target_turf(src, turn(going, pick(45, -45)))
						visible_message(span_danger("[src] violently rams [victim_structure] out of the way!"))
						victim_structure.anchored = FALSE
						victim_structure.take_damage(rand(20, 25) * collision_lethality)
						victim_structure.throw_at(throw_target, 200 * collision_lethality, 4 * collision_lethality)

			for(var/obj/machinery/victim_machine in dest_turf.contents)
				if(QDELING(victim_machine))
					continue
				if(is_type_in_typecache(victim_machine, lift_master_datum.ignored_smashthroughs))
					continue
				if(istype(victim_machine, /obj/machinery/field)) //graceful break handles this scenario
					continue
				if(victim_machine.layer >= LOW_OBJ_LAYER) //avoids stuff that is probably flush with the ground
					playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
					visible_message(span_danger("[src] smashes through [victim_machine]!"))
					qdel(victim_machine)

			for(var/mob/living/collided in dest_turf.contents)
				if(lift_master_datum.ignored_smashthroughs[collided.type])
					continue
				to_chat(collided, span_userdanger("[src] collides into you!"))
				playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
				var/damage = rand(9, 28) * collision_lethality
				collided.apply_damage(2 * damage, BRUTE, BODY_ZONE_HEAD)
				collided.apply_damage(2 * damage, BRUTE, BODY_ZONE_CHEST)
				collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG)
				collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG)
				collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM)
				collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM)

				if(QDELETED(collided)) //in case it was a mob that dels on death
					continue
				if(!throw_target)
					throw_target = get_edge_target_turf(src, turn(going, pick(45, -45)))

				var/turf/T = get_turf(collided)
				T.add_mob_blood(collided)

				collided.throw_at()
				//if going EAST, will turn to the NORTHEAST or SOUTHEAST and throw the ran over guy away
				var/datum/callback/land_slam = new(collided, TYPE_PROC_REF(/mob/living/, tram_slam_land))
				collided.throw_at(throw_target, 200 * collision_lethality, 4 * collision_lethality, callback = land_slam)

				SEND_SIGNAL(src, COMSIG_TRAM_COLLISION, collided)

	unset_movement_registrations(exited_locs)
	group_move(things_to_move, going)
	set_movement_registrations(entering_locs)

///move the movers list of movables on our tile to destination if we successfully move there first.
///this is like calling forceMove() on everything in movers and ourselves, except nothing in movers
///has destination.Entered() and origin.Exited() called on them, as only our movement can be perceived.
///none of the movers are able to react to the movement of any other mover, saving a lot of needless processing cost
///and is more sensible. without this, if you and a banana are on the same platform, when that platform moves you will slip
///on the banana even if youre not moving relative to it.
/obj/structure/industrial_lift/proc/group_move(list/atom/movable/movers, movement_direction)
	if(movement_direction == NONE)
		stack_trace("an industrial lift was told to move to somewhere it already is!")
		return FALSE

	var/turf/our_dest = get_step(src, movement_direction)

	//vars updated per mover
	var/turf/mover_old_loc
	var/turf/mover_old_area

	var/turf/mover_new_loc
	var/turf/mover_new_area

	if(glide_size != glide_size_override)
		set_glide_size(glide_size_override)

	forceMove(our_dest)
	if(loc != our_dest || QDELETED(src))//check if our movement succeeded, if it didnt then the movers cant be moved
		return FALSE

	for(var/atom/movable/mover as anything in changed_gliders)
		if(QDELETED(mover))
			movers -= mover
			continue

		if(mover.glide_size != glide_size_override)
			mover.set_glide_size(glide_size_override)

	changed_gliders.Cut()

	for(var/atom/movable/mover as anything in movers)
		if(QDELETED(mover))
			movers -= mover
			continue

		//another O(n) set of read operations, not ideal given datum var read times.
		//ideally we would only need to do this check once per tile with contents (which is constant per tram, while contents can scale infinitely)
		//and then the only O(n) process is calling these procs for each contents that actually changes areas
		//but that approach is probably a lot buggier. itd be nice to have it figured out though
		mover_old_loc = mover.loc
		mover_old_area = mover_old_loc.loc

		mover.loc = (mover_new_loc = get_step(mover, movement_direction))
		mover_new_area = mover_new_loc.loc


		if(mover_old_area != mover_new_area)
			mover_old_area.Exited(mover, movement_direction)
			mover_new_area.Entered(mover, mover_new_area)

		mover.Moved(mover_old_loc, movement_direction, TRUE, null, FALSE)


	return TRUE

/**
 * reset the contents of this lift platform to its original state in case someone put too much shit on it.
 * everything that is considered foreign is deleted, you can configure what is considered foreign.
 *
 * used by an admin via calling reset_lift_contents() on our lift_master_datum.
 *
 * Arguments:
 * * consider_anything_past - number. if > 0 this platform will only handle foreign contents that exceed this number on each of our locs
 * * foreign_objects - bool. if true this platform will consider /atom/movable's that arent mobs as part of foreign contents
 * * foreign_non_player_mobs - bool. if true we consider mobs that dont have a mind to be foreign
 * * consider_player_mobs - bool. if true we consider player mobs to be foreign. only works if foreign_non_player_mobs is true as well
 */
/obj/structure/industrial_lift/proc/reset_contents(consider_anything_past = 0, foreign_objects = TRUE, foreign_non_player_mobs = TRUE, consider_player_mobs = FALSE)
	if(!foreign_objects && !foreign_non_player_mobs && !consider_player_mobs)
		return FALSE

	consider_anything_past = isnum(consider_anything_past) ? max(consider_anything_past, 0) : 0
	//just in case someone fucks up the arguments

	if(consider_anything_past && length(lift_load) <= consider_anything_past)
		return FALSE

	///list of resolve()'d initial_contents that are still in lift_load
	var/list/atom/movable/original_contents = list(src)

	///list of objects we consider foreign according to the given arguments
	var/list/atom/movable/foreign_contents = list()


	for(var/datum/weakref/initial_contents_ref as anything in initial_contents)
		if(!initial_contents_ref)
			continue

		var/atom/movable/resolved_contents = initial_contents_ref.resolve()

		if(!resolved_contents)
			continue

		if(!(resolved_contents in lift_load))
			continue

		original_contents += resolved_contents

	for(var/turf/turf_loc as anything in locs)
		var/list/atom/movable/foreign_contents_in_loc = list()

		for(var/atom/movable/foreign_movable as anything in (turf_loc.contents - original_contents))
			if(foreign_objects && ismovable(foreign_movable) && !ismob(foreign_movable))
				foreign_contents_in_loc += foreign_movable
				continue

			if(foreign_non_player_mobs && ismob(foreign_movable))
				var/mob/foreign_mob = foreign_movable
				if(consider_player_mobs || !foreign_mob.mind)
					foreign_contents_in_loc += foreign_mob
					continue

		if(consider_anything_past)
			foreign_contents_in_loc.len -= consider_anything_past
			//hey cool this works, neat. this takes from the opposite side of the list that youd expect but its easy so idc
			//also this means that if you use consider_anything_past then foreign mobs are less likely to be deleted than foreign objects
			//because internally the contents list is 2 linked lists of obj contents - mob contents, thus mobs are always last in the order
			//when you iterate it.

		foreign_contents += foreign_contents_in_loc

	for(var/atom/movable/contents_to_delete as anything in foreign_contents)
		qdel(contents_to_delete)

	return TRUE

/// Callback / general proc to check if the lift is usable by the passed mob.
/obj/structure/industrial_lift/proc/can_open_lift_radial(mob/living/user, starting_position)
	// Gotta be a living mob
	if(!isliving(user))
		return FALSE
	// Gotta be awake and aware
	if(user.incapacitated())
		return FALSE
	// Maintain the god given right to fight an elevator
	if(user.combat_mode)
		return FALSE
	// Gotta be by the lift
	if(!user.Adjacent(src))
		return FALSE
	// If the lift moves while the radial is open close that shit
	if(starting_position != loc)
		return FALSE

	return TRUE

/// Opens the radial for the lift, allowing the user to move it around.
/obj/structure/industrial_lift/proc/open_lift_radial(mob/living/user)
	var/starting_position = loc
	if(!can_open_lift_radial(user, starting_position))
		return
	// One radial per person
	for(var/obj/structure/industrial_lift/other_platform as anything in lift_master_datum.lift_platforms)
		if(REF(user) in other_platform.current_operators)
			return


	var/list/possible_directions = list()
	if(lift_master_datum.Check_lift_move(UP))
		var/static/image/up_arrow
		if(!up_arrow)
			up_arrow = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)

		possible_directions["Up"] = up_arrow

	if(lift_master_datum.Check_lift_move(DOWN))
		var/static/image/down_arrow
		if(!down_arrow)
			down_arrow = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)

		possible_directions["Down"] = down_arrow

	add_fingerprint(user)
	if(!length(possible_directions))
		balloon_alert(user, "elevator out of service!")
		return

	LAZYADD(current_operators, REF(user))
	var/result = show_radial_menu(
		user = user,
		anchor = src,
		choices = possible_directions,
		custom_check = CALLBACK(src, PROC_REF(can_open_lift_radial), user, starting_position),
		require_near = TRUE,
		tooltips = TRUE,
	)

	LAZYREMOVE(current_operators, REF(user))
	if(!can_open_lift_radial(user, starting_position))
		return //nice try
	if(!isnull(result) && result != "Cancel" && lift_master_datum.controls_locked)
		// Only show this message if they actually wanted to move
		balloon_alert(user, "elevator controls locked!")
		return
	switch(result)
		if("Up")
			// We have to make sure that they don't do illegal actions
			// by not having their radial menu refresh from someone else moving the lift.
			if(!lift_master_datum.simple_move_wrapper(UP, elevator_vertical_speed, user))
				return

			show_fluff_message(UP, user)
			open_lift_radial(user)

		if("Down")
			if(!lift_master_datum.simple_move_wrapper(DOWN, elevator_vertical_speed, user))
				return

			show_fluff_message(DOWN, user)
			open_lift_radial(user)

		if("Cancel")
			return

/**
 * Proc to ensure that the radial menu closes when it should.
 * Arguments:
 * * user - The person that opened the menu.
 * * starting_loc - The location of the lift when the menu was opened, used to prevent the menu from being interacted with after the lift was moved by someone else.
 *
 * Returns:
 * * boolean, FALSE if the menu should be closed, TRUE if the menu is clear to stay opened.
 */
/obj/structure/industrial_lift/proc/check_menu(mob/user, starting_loc)
	if(user.incapacitated() || !user.Adjacent(src) || starting_loc != src.loc)
		return FALSE
	return TRUE

/obj/structure/industrial_lift/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

//ai probably shouldn't get to use lifts but they sure are great for admins to crush people with
/obj/structure/industrial_lift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	if(!radial_travel)
		return
	if(!isAdminGhostAI(user))
		return

	return open_lift_radial(user)

/obj/structure/industrial_lift/attack_paw(mob/user, list/modifiers)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/obj/structure/industrial_lift/attackby(obj/item/attacking_item, mob/user, params)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/obj/structure/industrial_lift/attack_robot(mob/living/user)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/**
 * Shows a message indicating that the lift has moved up or down.
 * Arguments:
 * * direction - What direction are we going
 * * user - The mob that caused the lift to move, for the visible message.
 */
/obj/structure/industrial_lift/proc/show_fluff_message(direction, mob/user)
	if(direction == UP)
		user.visible_message(span_notice("[user] moves the lift upwards."), span_notice("You move the lift upwards."))

	if(direction == DOWN)
		user.visible_message(span_notice("[user] moves the lift downwards."), span_notice("You move the lift downwards."))

// A subtype intended for "public use"
/obj/structure/industrial_lift/public
	icon = 'icons/turf/floors.dmi'
	icon_state = "rockvault"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	warns_on_down_movement = TRUE
	violent_landing = FALSE
	elevator_vertical_speed = 3 SECONDS
	radial_travel = FALSE

/obj/structure/industrial_lift/debug
	name = "transport platform"
	desc = "A lightweight platform. It moves in any direction, except up and down."
	color = "#5286b9ff"
	lift_id = DEBUG_LIFT_ID
	radial_travel = TRUE

/obj/structure/industrial_lift/debug/open_lift_radial(mob/living/user)
	var/starting_position = loc
	if (!can_open_lift_radial(user,starting_position))
		return
//NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST
	var/static/list/tool_list = list(
		"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
		"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
		"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
		"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
		"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
		"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST)
		)

	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(can_open_lift_radial), user, starting_position), require_near = TRUE, tooltips = FALSE)
	if (!can_open_lift_radial(user,starting_position))
		return	// nice try
	if(!isnull(result) && result != "Cancel" && lift_master_datum.controls_locked)
		// Only show this message if they actually wanted to move
		balloon_alert(user, "elevator controls locked!")
		return

	switch(result)
		if("NORTH")
			lift_master_datum.move_lift_horizontally(NORTH)
			open_lift_radial(user)
		if("NORTHEAST")
			lift_master_datum.move_lift_horizontally(NORTHEAST)
			open_lift_radial(user)
		if("EAST")
			lift_master_datum.move_lift_horizontally(EAST)
			open_lift_radial(user)
		if("SOUTHEAST")
			lift_master_datum.move_lift_horizontally(SOUTHEAST)
			open_lift_radial(user)
		if("SOUTH")
			lift_master_datum.move_lift_horizontally(SOUTH)
			open_lift_radial(user)
		if("SOUTHWEST")
			lift_master_datum.move_lift_horizontally(SOUTHWEST)
			open_lift_radial(user)
		if("WEST")
			lift_master_datum.move_lift_horizontally(WEST)
			open_lift_radial(user)
		if("NORTHWEST")
			lift_master_datum.move_lift_horizontally(NORTHWEST)
			open_lift_radial(user)
		if("Cancel")
			return

	add_fingerprint(user)

/obj/structure/industrial_lift/tram
	name = "tram"
	desc = "A tram for tramversing the station."
	icon = 'icons/turf/floors.dmi'
	icon_state = "titanium"
	layer = TRAM_FLOOR_LAYER
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	//kind of a centerpiece of the station, so pretty tough to destroy
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	lift_id = TRAM_LIFT_ID
	lift_master_type = /datum/lift_master/tram
	radial_travel = FALSE

	/// Set by the tram control console in late initialize
	var/travelling = FALSE

	//the following are only used to give to the lift_master datum when it's first created

	///decisecond delay between horizontal movements. cannot make the tram move faster than 1 movement per world.tick_lag. only used to give to the lift_master
	var/horizontal_speed = 0.5

	create_multitile_platform = TRUE

/obj/structure/industrial_lift/tram/white
	icon_state = "titanium_white"

/obj/structure/industrial_lift/tram/subfloor
	name = "tram"
	desc = "A tram for tramversing the station."
	icon_state = "tram_subfloor"

/datum/armor/structure_industrial_lift
	melee = 50
	fire = 80
	acid = 50

/obj/structure/industrial_lift/tram/accessible
	icon_state = "titanium_accessible_north"

/obj/structure/industrial_lift/tram/accessible/north
	icon_state = "titanium_accessible_north"

/obj/structure/industrial_lift/tram/accessible/south
	icon_state = "titanium_accessible_south"


/obj/structure/industrial_lift/tram/AddItemOnLift(datum/source, atom/movable/AM)
	. = ..()
	if(travelling)
		on_changed_glide_size(AM, AM.glide_size)

/obj/structure/industrial_lift/tram/proc/set_travelling(travelling)
	if (src.travelling == travelling)
		return

	for(var/atom/movable/glider as anything in lift_load)
		if(travelling)
			glider.set_glide_size(glide_size_override)
			RegisterSignal(glider, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_changed_glide_size))
		else
			changed_gliders -= glider
			UnregisterSignal(glider, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE)

	src.travelling = travelling
	SEND_SIGNAL(src, COMSIG_TRAM_SET_TRAVELLING, travelling)

/obj/structure/industrial_lift/tram/set_currently_z_moving()
	return FALSE //trams can never z fall and shouldnt waste any processing time trying to do so

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/obj/structure/industrial_lift/tram/proc/unlock_controls()
	visible_message(span_notice("[src]'s controls are now unlocked."))
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_master_datum.lift_platforms) //only thing everyone needs to know is the new location.
		tram_part.set_travelling(FALSE)
		lift_master_datum.set_controls(LIFT_PLATFORM_UNLOCKED)

///debug proc to highlight the locs of the tram platform
/obj/structure/industrial_lift/tram/proc/find_dimensions(iterations = 100)
	message_admins("num turfs: [length(locs)]")

	var/overlay = /obj/effect/overlay/ai_detect_hud
	var/list/turfs = list()

	for(var/turf/our_turf as anything in locs)
		new overlay(our_turf)
		turfs += our_turf

	addtimer(CALLBACK(src, PROC_REF(clear_turfs), turfs, iterations), 1)

/obj/structure/industrial_lift/tram/proc/clear_turfs(list/turfs_to_clear, iterations)
	for(var/turf/our_old_turf as anything in turfs_to_clear)
		var/obj/effect/overlay/ai_detect_hud/hud = locate() in our_old_turf
		if(hud)
			qdel(hud)

	var/overlay = /obj/effect/overlay/ai_detect_hud

	for(var/turf/our_turf as anything in locs)
		new overlay(our_turf)

	iterations--

	var/list/turfs = list()
	for(var/turf/our_turf as anything in locs)
		turfs += our_turf

	if(iterations)
		addtimer(CALLBACK(src, PROC_REF(clear_turfs), turfs, iterations), 1)
