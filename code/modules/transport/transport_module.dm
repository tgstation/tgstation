/**
 * Base transport structure. A single tile that can form a modular set with neighbouring tiles
 * This type holds elevators and trams
 */
/obj/structure/transport/linear
	name = "linear transport module"
	desc = "A lightweight lift platform. It moves."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	armor_type = /datum/armor/transport_module
	max_integrity = 50
	layer = TRAM_FLOOR_LAYER
	plane = GAME_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_INDUSTRIAL_LIFT
	canSmoothWith = SMOOTH_GROUP_INDUSTRIAL_LIFT
	obj_flags = BLOCK_Z_OUT_DOWN
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER //no TILE_BOUND since we're potentially multitile
	// If we don't do this, we'll build our overlays early, and fuck up how we're rendered
	blocks_emissive = EMISSIVE_BLOCK_NONE

	///ID used to determine what transport types we can merge with
	var/transport_id = TRANSPORT_TYPE_ELEVATOR

	///if true, the elevator works through floors
	var/pass_through_floors = FALSE

	///what movables on our platform that we are moving
	var/list/atom/movable/transport_contents = list()
	///weakrefs to the contents we have when we're first created. stored so that admins can clear the tram to its initial state
	///if someone put a bunch of stuff onto it.
	var/list/datum/weakref/initial_contents = list()

	///what glide_size we set our moving contents to.
	var/glide_size_override = 8
	///movables inside transport_contents who had their glide_size changed since our last movement.
	///used so that we dont have to change the glide_size of every object every movement, which scales to cost more than you'd think
	var/list/atom/movable/changed_gliders = list()

	///decisecond delay between horizontal movements. cannot make the tram move faster than 1 movement per world.tick_lag. only used to give to the transport_controller
	var/speed_limiter = 0.5

	///master datum that controls our movement. in general /transport/linear subtypes control moving themselves, and
	/// /datum/transport_controller instances control moving the entire tram and any behavior associated with that.
	var/datum/transport_controller/linear/transport_controller_datum
	///what subtype of /datum/transport_controller to create for itself if no other platform on this tram has created one yet.
	///very important for some behaviors since
	var/transport_controller_type = /datum/transport_controller/linear

	///how many tiles this platform extends on the x axis
	var/width = 1
	///how many tiles this platform extends on the y axis (north-south not up-down, that would be the z axis)
	var/height = 1

	///if TRUE, this platform will late initialize and then expand to become a multitile object across all other linked platforms on this z level
	var/create_modular_set = FALSE

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

/datum/armor/transport_module
	melee = 80
	bullet = 90
	bomb = 70
	fire = 100
	acid = 100

/obj/structure/transport/linear/Initialize(mapload)
	. = ..()
	// Yes if it's VV'd it won't be accurate but it probably shouldn't ever be
	if(radial_travel)
		AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Send Transport")

	ADD_TRAIT(src, TRAIT_CHASM_STOPPER, INNATE_TRAIT)
	set_movement_registrations()

	//since transport_controller datums find all connected platforms when a transport structure first creates it and then
	//sets those platforms' transport_controller_datum to itself, this check will only evaluate to true once per tram platform
	if(!transport_controller_datum && transport_controller_type)
		transport_controller_datum = new transport_controller_type(src)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/transport/linear/LateInitialize()
	//after everything is initialized the transport controller can order everything
	transport_controller_datum.order_platforms_by_z_level()

/obj/structure/transport/linear/Destroy()
	transport_controller_datum = null
	return ..()


///set the movement registrations to our current turf(s) so contents moving out of our tile(s) are removed from our movement lists
/obj/structure/transport/linear/proc/set_movement_registrations(list/turfs_to_set)
	for(var/turf/turf_loc as anything in turfs_to_set || locs)
		RegisterSignal(turf_loc, COMSIG_ATOM_EXITED, PROC_REF(uncrossed_remove_item_from_transport))
		RegisterSignals(turf_loc, list(COMSIG_ATOM_ENTERED,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(add_item_on_transport))

///unset our movement registrations from turfs that no longer contain us (or every loc if turfs_to_unset is unspecified)
/obj/structure/transport/linear/proc/unset_movement_registrations(list/turfs_to_unset)
	var/static/list/registrations = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	for(var/turf/turf_loc as anything in turfs_to_unset || locs)
		UnregisterSignal(turf_loc, registrations)


/obj/structure/transport/linear/proc/uncrossed_remove_item_from_transport(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(!(gone.loc in locs))
		remove_item_from_transport(gone)

/obj/structure/transport/linear/proc/remove_item_from_transport(atom/movable/potential_rider)
	SIGNAL_HANDLER
	if(!(potential_rider in transport_contents))
		return
	if(isliving(potential_rider) && HAS_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED))
		REMOVE_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)

	transport_contents -= potential_rider
	changed_gliders -= potential_rider

	UnregisterSignal(potential_rider, list(COMSIG_QDELETING, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE))

/obj/structure/transport/linear/proc/add_item_on_transport(datum/source, atom/movable/new_transport_contents)
	SIGNAL_HANDLER
	var/static/list/blacklisted_types = typecacheof(list(/obj/structure/fluff/tram_rail, /obj/effect/decal/cleanable, /obj/structure/transport/linear, /mob/eye))
	if(is_type_in_typecache(new_transport_contents, blacklisted_types) || new_transport_contents.invisibility == INVISIBILITY_ABSTRACT || HAS_TRAIT(new_transport_contents, TRAIT_UNDERFLOOR)) //prevents the tram from stealing things like landmarks
		return FALSE
	if(new_transport_contents in transport_contents)
		return FALSE

	if(isliving(new_transport_contents) && !HAS_TRAIT(new_transport_contents, TRAIT_CANNOT_BE_UNBUCKLED))
		ADD_TRAIT(new_transport_contents, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)

	transport_contents += new_transport_contents
	RegisterSignal(new_transport_contents, COMSIG_QDELETING, PROC_REF(remove_item_from_transport))

	return TRUE

///adds everything on our tile that can be added to our transport_contents and initial_contents lists when we're created
/obj/structure/transport/linear/proc/add_initial_contents()
	for(var/turf/turf_loc in locs)
		for(var/atom/movable/movable_contents as anything in turf_loc)
			if(movable_contents == src)
				continue

			if(add_item_on_transport(src, movable_contents))

				var/datum/weakref/new_initial_contents = WEAKREF(movable_contents)
				if(!new_initial_contents)
					continue

				initial_contents += new_initial_contents

///verify the movables in our list of contents are actually on our loc
/obj/structure/transport/linear/proc/verify_transport_contents()
	for(var/atom/movable/movable_contents as anything in transport_contents)
		if(!(movable_contents.loc in locs))
			remove_item_from_transport(movable_contents)

/obj/structure/transport/linear/proc/check_for_humans()
	for(var/atom/movable/movable_contents as anything in transport_contents)
		if(ishuman(movable_contents))
			return TRUE

	return FALSE

///signal handler for COMSIG_MOVABLE_UPDATE_GLIDE_SIZE: when a movable in transport_contents changes its glide_size independently.
///adds that movable to a lazy list, movables in that list have their glide_size updated when the tram next moves
/obj/structure/transport/linear/proc/on_changed_glide_size(atom/movable/moving_contents, new_glide_size)
	SIGNAL_HANDLER
	if(new_glide_size != glide_size_override)
		changed_gliders += moving_contents


///make this tram platform multitile, expanding to cover all the tram platforms adjacent to us and deleting them. makes movement more efficient.
///the platform becoming multitile should be in the lower left corner since thats assumed to be the loc of multitile objects
/obj/structure/transport/linear/proc/create_modular_set(min_x, min_y, max_x, max_y, z)

	if(!(min_x && min_y && max_x && max_y && z))
		for(var/obj/structure/transport/linear/other_transport as anything in transport_controller_datum.transport_modules)
			if(other_transport.z != z)
				continue

			min_x = min(min_x, other_transport.x)
			max_x = max(max_x, other_transport.x)

			min_y = min(min_y, other_transport.y)
			max_y = max(max_y, other_transport.y)

	var/turf/lower_left_corner = locate(min_x, min_y, z)
	var/obj/structure/transport/linear/primary_module = locate() in lower_left_corner

	if(!primary_module)
		stack_trace("no lift in the lower left corner of a lift level!")
		return FALSE

	if(primary_module != src)
		//the loc of a multitile object must always be the lower left corner
		return primary_module.create_modular_set()

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

		var/y_pixel_offset = ICON_SIZE_Y * y

		for(var/x in first_x to last_x)

			var/x_pixel_offset = ICON_SIZE_X * x

			var/turf/set_turf = locate(x + min_x, y + min_y, z)

			if(!set_turf)
				continue

			if(set_turf in locs_to_skip)
				continue

			var/obj/structure/transport/linear/other_transport = locate() in set_turf

			if(!other_transport)
				continue

			locs_to_skip += other_transport.locs.Copy()//make sure we never go over multitile platforms multiple times

			other_transport.pixel_x = x_pixel_offset
			other_transport.pixel_y = y_pixel_offset

			overlays += other_transport

	//now we vore all the other lifts connected to us on our z level
	for(var/obj/structure/transport/linear/other_transport in transport_controller_datum.transport_modules)
		if(other_transport == src || other_transport.z != z)
			continue

		transport_controller_datum.transport_modules -= other_transport
		if(other_transport.transport_contents)
			transport_contents |= other_transport.transport_contents
		if(other_transport.initial_contents)
			initial_contents |= other_transport.initial_contents

		qdel(other_transport)

	transport_controller_datum.create_modular_set = TRUE

	var/turf/old_loc = loc

	forceMove(locate(min_x, min_y, z))//move to the lower left corner
	set_movement_registrations(locs - old_loc)
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	update_appearance()
	return TRUE

///returns an unordered list of all lift platforms adjacent to us. used so our transport_controller_datum can control all connected platforms.
///includes platforms directly above or below us as well. only includes platforms with an identical transport_id to our own.
/obj/structure/transport/linear/proc/module_adjacency(datum/transport_controller/transport_controller_datum)
	. = list()
	for(var/direction in GLOB.cardinals_multiz)
		var/obj/structure/transport/linear/neighbor = locate() in get_step_multiz(src, direction)
		if(!neighbor || neighbor.transport_id != transport_id)
			continue
		. += neighbor

///main proc for moving the lift in the direction [travel_direction]. handles horizontal and/or vertical movement for multi platformed lifts and multitile lifts.
/obj/structure/transport/linear/proc/travel(travel_direction)
	var/list/things_to_move = transport_contents
	var/turf/destination
	if(!isturf(travel_direction))
		destination = get_step_multiz(src, travel_direction)
	else
		destination = travel_direction
		travel_direction = get_dir_multiz(loc, travel_direction)

	var/x_offset = ROUND_UP(bound_width / ICON_SIZE_X) - 1 //how many tiles our horizontally farthest edge is from us
	var/y_offset = ROUND_UP(bound_height / ICON_SIZE_Y) - 1 //how many tiles our vertically farthest edge is from us

	var/destination_x = destination.x
	var/destination_y = destination.y
	var/destination_z = destination.z
	//the x coordinate of the edge furthest from our future destination, which would be our right hand side
	var/back_edge_x = destination_x + x_offset//if we arent multitile this should just be destination.x
	var/upper_edge_y = destination_y + y_offset

	var/list/dest_locs = block(
		destination_x, destination_y, destination_z,
		back_edge_x, upper_edge_y, destination_z
	)

	var/list/entering_locs = dest_locs - locs
	var/list/exited_locs = locs - dest_locs

	if(travel_direction == DOWN)
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
					crushed.gib(DROP_ALL_REMAINS)
				else
					// Less violent landing simply crushes every bone in your body.
					crushed.Paralyze(30 SECONDS, ignore_canstun = TRUE)
					crushed.apply_damage(30, BRUTE, BODY_ZONE_CHEST, wound_bonus = 30)
					crushed.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = 25)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_L_LEG, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_R_LEG, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_L_ARM, wound_bonus = 15)
					crushed.apply_damage(15, BRUTE, BODY_ZONE_R_ARM, wound_bonus = 15)

	else if(travel_direction == UP)
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
				dest_mineral_turf.gets_drilled()

			for(var/obj/structure/victim_structure in dest_turf.contents)
				if(QDELING(victim_structure))
					continue
				if(!is_type_in_typecache(victim_structure, transport_controller_datum.ignored_smashthroughs))
					if((PLANE_TO_TRUE(victim_structure.plane) == FLOOR_PLANE && victim_structure.layer > TRAM_RAIL_LAYER) || (PLANE_TO_TRUE(victim_structure.plane) == GAME_PLANE && victim_structure.layer > LOW_OBJ_LAYER) )
						if(victim_structure.anchored && initial(victim_structure.anchored) == TRUE)
							visible_message(span_danger("[src] smashes through [victim_structure]!"))
							victim_structure.deconstruct(FALSE)

						else
							if(!throw_target)
								throw_target = get_edge_target_turf(src, turn(travel_direction, pick(45, -45)))
							visible_message(span_danger("[src] violently rams [victim_structure] out of the way!"))
							victim_structure.anchored = FALSE
							victim_structure.take_damage(rand(20, 25) * collision_lethality)
							victim_structure.throw_at(throw_target, 200 * collision_lethality, 4 * collision_lethality)

			for(var/obj/machinery/victim_machine in dest_turf.contents)
				if(QDELING(victim_machine))
					continue
				if(is_type_in_typecache(victim_machine, transport_controller_datum.ignored_smashthroughs))
					continue
				if(istype(victim_machine, /obj/machinery/field)) //graceful break handles this scenario
					continue
				if(victim_machine.layer >= LOW_OBJ_LAYER) //avoids stuff that is probably flush with the ground
					playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
					visible_message(span_danger("[src] smashes through [victim_machine]!"))
					qdel(victim_machine)

			for(var/mob/living/victim_living in dest_turf.contents)
				var/damage_multiplier = victim_living.maxHealth * 0.01
				var/extra_ouch = FALSE // if emagged you're gonna have a really bad time
				if(speed_limiter == 0.5) // slow trams don't cause extra damage
					for(var/obj/structure/tram/spoiler/my_spoiler in transport_contents)
						if(istype(victim_living.buckled, /obj/structure/fluff/tram_rail))
							extra_ouch = TRUE
							break
						if(get_dist(my_spoiler, victim_living) != 1)
							continue
						if(my_spoiler.deployed)
							extra_ouch = TRUE
							break

				if(transport_controller_datum.ignored_smashthroughs[victim_living.type])
					continue
				to_chat(victim_living, span_userdanger("[src] collides into you!"))
				SEND_SIGNAL(victim_living, COMSIG_LIVING_HIT_BY_TRAM, src)
				playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
				var/damage = 0

				log_combat(src, victim_living, "collided with")
				if(prob(15)) //sorry buddy, luck wasn't on your side
					damage = 29 * collision_lethality * damage_multiplier
				else
					damage = rand(7, 21) * collision_lethality * damage_multiplier
				victim_living.apply_damage(2 * damage, BRUTE, BODY_ZONE_HEAD, wound_bonus = 7)
				victim_living.apply_damage(3 * damage, BRUTE, BODY_ZONE_CHEST, wound_bonus = 21)
				victim_living.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG, wound_bonus = 14)
				victim_living.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG, wound_bonus = 14)
				victim_living.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM, wound_bonus = 14)
				victim_living.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM, wound_bonus = 14)

				if (extra_ouch)
					playsound(src, 'sound/effects/grillehit.ogg', 50, TRUE)
					var/obj/item/bodypart/head/head = victim_living.get_bodypart("head")
					if(head)
						log_combat(src, victim_living, "beheaded")
						head.dismember()
						victim_living.regenerate_icons()
						add_overlay(mutable_appearance(icon, "blood_overlay"))
						register_collision(points = 3)

				if(QDELETED(victim_living)) //in case it was a mob that dels on death
					continue
				if(!throw_target)
					throw_target = get_edge_target_turf(src, turn(travel_direction, pick(45, -45)))

				var/turf/turf_to_bloody = get_turf(victim_living)
				turf_to_bloody.add_mob_blood(victim_living)

				victim_living.throw_at()
				//if travel_direction EAST, will turn to the NORTHEAST or SOUTHEAST and throw the ran over guy away
				var/datum/callback/land_slam = new(victim_living, TYPE_PROC_REF(/mob/living/, tram_slam_land))
				victim_living.throw_at(throw_target, 200 * collision_lethality, 4 * collision_lethality, callback = land_slam)

				//increment the hit counters
				if(ismob(victim_living) && victim_living.client && istype(transport_controller_datum, /datum/transport_controller/linear/tram))
					register_collision(points = 1)

	unset_movement_registrations(exited_locs)
	group_move(things_to_move, travel_direction)
	set_movement_registrations(entering_locs)

/obj/structure/transport/linear/proc/register_collision(points = 1)
	SSpersistence.tram_hits_this_round += points
	SSblackbox.record_feedback("amount", "tram_collision", points)
	var/datum/transport_controller/linear/tram/tram_controller = transport_controller_datum
	ASSERT(istype(tram_controller))
	tram_controller.register_collision(points)

///move the movers list of movables on our tile to destination if we successfully move there first.
///this is like calling forceMove() on everything in movers and ourselves, except nothing in movers
///has destination.Entered() and origin.Exited() called on them, as only our movement can be perceived.
///none of the movers are able to react to the movement of any other mover, saving a lot of needless processing cost
///and is more sensible. without this, if you and a banana are on the same platform, when that platform moves you will slip
///on the banana even if youre not moving relative to it.
/obj/structure/transport/linear/proc/group_move(list/atom/movable/movers, movement_direction)
	if(movement_direction == NONE)
		stack_trace("a transport was told to move to somewhere it already is!")
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
 * used by an admin via calling reset_lift_contents() on our transport_controller_datum.
 *
 * Arguments:
 * * consider_anything_past - number. if > 0 this platform will only handle foreign contents that exceed this number on each of our locs
 * * foreign_objects - bool. if true this platform will consider /atom/movable's that arent mobs as part of foreign contents
 * * foreign_non_player_mobs - bool. if true we consider mobs that dont have a mind to be foreign
 * * consider_player_mobs - bool. if true we consider player mobs to be foreign. only works if foreign_non_player_mobs is true as well
 */
/obj/structure/transport/linear/proc/reset_contents(consider_anything_past = 0, foreign_objects = TRUE, foreign_non_player_mobs = TRUE, consider_player_mobs = FALSE)
	if(!foreign_objects && !foreign_non_player_mobs && !consider_player_mobs)
		return FALSE

	consider_anything_past = isnum(consider_anything_past) ? max(consider_anything_past, 0) : 0
	//just in case someone fucks up the arguments

	if(consider_anything_past && length(transport_contents) <= consider_anything_past)
		return FALSE

	///list of resolve()'d initial_contents that are still in transport_contents
	var/list/atom/movable/original_contents = list(src)

	///list of objects we consider foreign according to the given arguments
	var/list/atom/movable/foreign_contents = list()


	for(var/datum/weakref/initial_contents_ref as anything in initial_contents)
		if(!initial_contents_ref)
			continue

		var/atom/movable/resolved_contents = initial_contents_ref.resolve()

		if(!resolved_contents)
			continue

		if(!(resolved_contents in transport_contents))
			continue

		original_contents += resolved_contents

	for(var/turf/turf_loc as anything in locs)
		var/list/atom/movable/foreign_contents_in_loc = list()

		for(var/atom/movable/foreign_movable as anything in (turf_loc.contents - original_contents))
			if(foreign_objects && ismovable(foreign_movable) && !ismob(foreign_movable) && !istype(foreign_movable, /obj/effect/landmark/transport/nav_beacon))
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
/obj/structure/transport/linear/proc/can_open_lift_radial(mob/living/user, starting_position)
	// Gotta be a living mob
	if(!isliving(user))
		return FALSE
	// Gotta be awake and aware
	if(user.incapacitated)
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
/obj/structure/transport/linear/proc/open_lift_radial(mob/living/user)
	var/starting_position = loc
	if(!can_open_lift_radial(user, starting_position))
		return
	// One radial per person
	for(var/obj/structure/transport/linear/other_platform as anything in transport_controller_datum.transport_modules)
		if(REF(user) in other_platform.current_operators)
			return


	var/list/possible_directions = list()
	if(transport_controller_datum.Check_lift_move(UP))
		var/static/image/up_arrow
		if(!up_arrow)
			up_arrow = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)

		possible_directions["Up"] = up_arrow

	if(transport_controller_datum.Check_lift_move(DOWN))
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
	if(!isnull(result) && result != "Cancel" && transport_controller_datum.controller_status & CONTROLS_LOCKED)
		// Only show this message if they actually wanted to move
		balloon_alert(user, "elevator controls locked!")
		return
	switch(result)
		if("Up")
			// We have to make sure that they don't do illegal actions
			// by not having their radial menu refresh from someone else moving the lift.
			if(!transport_controller_datum.simple_move_wrapper(UP, elevator_vertical_speed, user))
				return

			show_fluff_message(UP, user)
			open_lift_radial(user)

		if("Down")
			if(!transport_controller_datum.simple_move_wrapper(DOWN, elevator_vertical_speed, user))
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
/obj/structure/transport/linear/proc/check_menu(mob/user, starting_loc)
	if(user.incapacitated || !user.Adjacent(src) || starting_loc != src.loc)
		return FALSE
	return TRUE

/obj/structure/transport/linear/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

//ai probably shouldn't get to use lifts but they sure are great for admins to crush people with
/obj/structure/transport/linear/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	if(!radial_travel)
		return
	if(!isAdminGhostAI(user))
		return

	return open_lift_radial(user)

/obj/structure/transport/linear/attack_paw(mob/user, list/modifiers)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/obj/structure/transport/linear/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/obj/structure/transport/linear/attack_robot(mob/living/user)
	if(!radial_travel)
		return ..()

	return open_lift_radial(user)

/**
 * Shows a message indicating that the lift has moved up or down.
 * Arguments:
 * * direction - What direction are we going
 * * user - The mob that caused the lift to move, for the visible message.
 */
/obj/structure/transport/linear/proc/show_fluff_message(direction, mob/user)
	if(direction == UP)
		user.visible_message(span_notice("[user] moves the lift upwards."), span_notice("You move the lift upwards."))

	if(direction == DOWN)
		user.visible_message(span_notice("[user] moves the lift downwards."), span_notice("You move the lift downwards."))

/obj/machinery/door/poddoor/lift
	name = "elevator door"
	desc = "Keeps idiots like you from walking into an open elevator shaft."
	icon = 'icons/obj/doors/liftdoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/poddoor/lift/Initialize(mapload)
	if(!isnull(transport_linked_id)) //linter and stuff
		elevator_mode = TRUE
	return ..()

/obj/machinery/door/poddoor/lift/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

// A subtype intended for "public use"
/obj/structure/transport/linear/public
	icon = 'icons/turf/floors.dmi'
	icon_state = "rockvault"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	warns_on_down_movement = TRUE
	violent_landing = FALSE
	elevator_vertical_speed = 3 SECONDS
	radial_travel = FALSE

/obj/structure/transport/linear/debug
	name = "transport platform"
	desc = "A lightweight platform. It moves in any direction, except up and down."
	color = "#5286b9ff"
	transport_id = TRANSPORT_TYPE_DEBUG
	radial_travel = TRUE

/obj/structure/transport/linear/debug/open_lift_radial(mob/living/user)
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
	if(!isnull(result) && result != "Cancel" && transport_controller_datum.controller_status & CONTROLS_LOCKED)
		// Only show this message if they actually wanted to move
		balloon_alert(user, "elevator controls locked!")
		return

	switch(result)
		if("NORTH")
			transport_controller_datum.move_transport_horizontally(NORTH)
			open_lift_radial(user)
		if("NORTHEAST")
			transport_controller_datum.move_transport_horizontally(NORTHEAST)
			open_lift_radial(user)
		if("EAST")
			transport_controller_datum.move_transport_horizontally(EAST)
			open_lift_radial(user)
		if("SOUTHEAST")
			transport_controller_datum.move_transport_horizontally(SOUTHEAST)
			open_lift_radial(user)
		if("SOUTH")
			transport_controller_datum.move_transport_horizontally(SOUTH)
			open_lift_radial(user)
		if("SOUTHWEST")
			transport_controller_datum.move_transport_horizontally(SOUTHWEST)
			open_lift_radial(user)
		if("WEST")
			transport_controller_datum.move_transport_horizontally(WEST)
			open_lift_radial(user)
		if("NORTHWEST")
			transport_controller_datum.move_transport_horizontally(NORTHWEST)
			open_lift_radial(user)
		if("Cancel")
			return

	add_fingerprint(user)

/obj/structure/transport/linear/tram
	name = "tram subfloor"
	desc = "The subfloor lattice of the tram. You can build a tram wall frame by using <b>titanium sheets,</b> or place down <b>thermoplastic tram floor tiles.</b>"
	icon = 'icons/obj/tram/tram_structure.dmi'
	icon_state = "subfloor"
	base_icon_state = null
	density = FALSE
	layer = TRAM_STRUCTURE_LAYER
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	//the modular structure is pain to work with, damage is done to the floor on top
	transport_id = TRANSPORT_TYPE_TRAM
	transport_controller_type = /datum/transport_controller/linear/tram
	radial_travel = FALSE
	/// Set by the tram control console in late initialize
	var/travelling = FALSE

	/// Do we want this transport to link with nearby modules to make a multi-tile platform
	create_modular_set = TRUE

/obj/structure/transport/linear/tram/corner/northwest
	icon_state = "subfloor-corner-nw"

/obj/structure/transport/linear/tram/corner/southwest
	icon_state = "subfloor-corner-sw"

/obj/structure/transport/linear/tram/corner/northeast
	icon_state = "subfloor-corner-ne"

/obj/structure/transport/linear/tram/corner/southeast
	icon_state = "subfloor-corner-se"

/obj/structure/transport/linear/tram/add_item_on_transport(datum/source, atom/movable/item)
	. = ..()
	if(travelling)
		on_changed_glide_size(item, item.glide_size)

/obj/structure/transport/linear/tram/proc/set_travelling(travelling)
	if (src.travelling == travelling)
		return

	for(var/atom/movable/glider as anything in transport_contents)
		if(travelling)
			glider.set_glide_size(glide_size_override)
			RegisterSignal(glider, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_changed_glide_size))
		else
			changed_gliders -= glider
			UnregisterSignal(glider, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE)

	src.travelling = travelling
	SEND_SIGNAL(src, COMSIG_TRANSPORT_ACTIVE, travelling)

/obj/structure/transport/linear/tram/set_currently_z_moving()
	return FALSE //trams can never z fall and shouldnt waste any processing time trying to do so

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/obj/structure/transport/linear/tram/proc/unlock_controls()
	for(var/obj/structure/transport/linear/tram/tram_part as anything in transport_controller_datum.transport_modules) //only thing everyone needs to know is the new location.
		tram_part.set_travelling(FALSE)
		transport_controller_datum.controls_lock(FALSE)

///debug proc to highlight the locs of the tram platform
/obj/structure/transport/linear/tram/proc/find_dimensions(iterations = 100)
	message_admins("num turfs: [length(locs)]")

	var/overlay = /obj/effect/overlay/ai_detect_hud
	var/list/turfs = list()

	for(var/turf/our_turf as anything in locs)
		new overlay(our_turf)
		turfs += our_turf

	addtimer(CALLBACK(src, PROC_REF(clear_turfs), turfs, iterations), 0.1 SECONDS)

/obj/structure/transport/linear/tram/proc/clear_turfs(list/turfs_to_clear, iterations)
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
		addtimer(CALLBACK(src, PROC_REF(clear_turfs), turfs, iterations), 0.1 SECONDS)

/obj/structure/transport/linear/tram/proc/estop_throw(throw_direction)
	for(var/mob/living/passenger in transport_contents)
		var/mob_throw_chance = transport_controller_datum.throw_chance
		if(prob(mob_throw_chance || 17.5) || HAS_TRAIT(passenger, TRAIT_CURSED)) // sometimes you go through a window, especially with bad luck
			passenger.AddElement(/datum/element/window_smashing, duration = 1.5 SECONDS)
		var/throw_target = get_edge_target_turf(src, throw_direction)
		passenger.throw_at(throw_target, 30, 7, force = MOVE_FORCE_OVERPOWERING)

/obj/structure/transport/linear/tram/slow
	transport_controller_type = /datum/transport_controller/linear/tram/slow
	speed_limiter = /datum/transport_controller/linear/tram/slow::speed_limiter
