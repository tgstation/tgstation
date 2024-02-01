/**
 * MOVABLE PHYSICS COMPONENT - By ma44, bob joga and pyroshark (https://github.com/DaedalusDock/daedalusdock/pull/96/)
 *
 * Essentially, this component adds a very dodgy, very barebones simulation of pixel movement and physics for the movable.
 * Using animate here would be very expensive, so instead this processes every 1/20 seconds and adjusts pixel_x, pixel_y and pixel_z.
 * Whenever the movable crosses a tile's boundary, it will attempt to move into the appropriate tile.
 * Collisions are accounted for, but they are very simple and tile based. No complex hitboxes or anythin'.
 * All of this, of course, only works while the movable is located a turf.
 */
/datum/component/movable_physics
	/// Flags for turning on certain physic properties, see the top of the file for more information on flags
	var/physics_flags
	/// The angle of the path the object takes on the x/y plane
	var/angle
	/**
	 * Modifies the pixel_x/pixel_y of an object every process()
	 * Movables aren't Move()'d into another turf if pixel_z exceeds 16, so try not to supply a super high vertical value
	 * if you don't want the movable to clip through multiple turfs (looks dumb)
	 */
	var/horizontal_velocity
	/// Modifies the pixel_z of an object every process()
	var/vertical_velocity
	/**
	 * The horizontal_velocity is reduced by this every process()
	 * this doesn't take into account the object being in the air vs gravity pushing it against the ground
	 */
	var/horizontal_friction
	/// The vertical_velocity is reduced by this every process()
	var/vertical_friction
	/**
	 * Conservation of momentum for x/y plane
	 * horizontal_velocity gets multiplied by this when bumping on a wall
	 */
	var/horizontal_conservation_of_momentum
	/**
	 * Conservation of momentum for z plane
	 * vertical_velocity gets multiplied by this when bumping on the floor
	 */
	var/vertical_conservation_of_momentum
	/**
	 * The pixel_z that the object will no longer be influenced by gravity for a 32x32 turf
	 * Keep this value between -16 to 0 so it's visuals matches up with it physically being in the turf
	 */
	var/z_floor
	/// Visual angle velocity of the object
	var/visual_angle_velocity
	/// Visual angle friction of the object
	var/visual_angle_friction
	/// For calling spinanimation at the start of movement
	var/spin_speed
	/// For calling spinanimation at the start of movement
	var/spin_loops
	/// For calling spinanimation at the start of movement
	var/spin_clockwise
	/// For calling spinanimation when bouncing
	var/bounce_spin_speed
	/// For calling spinanimation when bouncing
	var/bounce_spin_loops
	/// For calling spinanimation when bouncing
	var/bounce_spin_clockwise
	/// The sound effect to play when bouncing off of something
	var/bounce_sound
	/// If we have this callback, it gets invoked when bouncing on the floor
	var/datum/callback/bounce_callback
	/// If we have this callback, it gets invoked when stopping movement
	var/datum/callback/stop_callback

	/**
	 * The cached animate_movement of the parent
	 * Any kind of gliding when doing Move() makes the physics look derpy, so we'll just make Move() be instant
	 */
	var/cached_animate_movement
	/// Cached transform of the parent, in case some fucking idiot decides its a good idea to make the damn movable spin forever
	var/cached_transform

// It's a BAD IDEA to use this on something that is not an item, even though you can
/datum/component/movable_physics/Initialize(
	physics_flags = NONE,
	angle = 0,
	horizontal_velocity = 0,
	vertical_velocity = 0,
	horizontal_friction = 0,
	vertical_friction = 0,
	horizontal_conservation_of_momentum = 0.8,
	vertical_conservation_of_momentum = 0.8,
	z_floor = 0,
	visual_angle_velocity = 0,
	visual_angle_friction = 0,
	spin_speed = 2 SECONDS,
	spin_loops = 0,
	spin_clockwise = TRUE,
	bounce_spin_speed = 0,
	bounce_spin_loops = 0,
	bounce_spin_clockwise = 0,
	bounce_sound,
	bounce_callback,
	stop_callback,
)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.horizontal_velocity = horizontal_velocity
	src.vertical_velocity = vertical_velocity
	src.horizontal_friction = horizontal_friction
	src.vertical_friction = vertical_friction
	src.z_floor = z_floor
	src.physics_flags = physics_flags
	src.angle = angle
	src.horizontal_conservation_of_momentum = horizontal_conservation_of_momentum
	src.vertical_conservation_of_momentum = vertical_conservation_of_momentum
	src.visual_angle_velocity = visual_angle_velocity
	src.visual_angle_friction = visual_angle_friction
	src.spin_speed = spin_speed
	src.spin_loops = spin_loops
	src.spin_clockwise = spin_clockwise
	src.bounce_spin_speed = bounce_spin_speed
	src.bounce_spin_loops = bounce_spin_loops
	src.bounce_spin_clockwise = bounce_spin_clockwise
	src.bounce_sound = bounce_sound
	src.bounce_callback = bounce_callback
	src.stop_callback = stop_callback
	set_angle(angle)

/datum/component/movable_physics/Destroy(force, silent)
	. = ..()
	if(bounce_callback)
		QDEL_NULL(bounce_callback)
	if(stop_callback)
		QDEL_NULL(stop_callback)
	cached_transform = null

/datum/component/movable_physics/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_item_pickup))
	if(has_movement())
		start_movement()
	else if(physics_flags & MPHYSICS_QDEL_WHEN_NO_MOVEMENT)
		qdel(src)

/datum/component/movable_physics/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_IMPACT)
	if(isitem(parent))
		UnregisterSignal(parent, COMSIG_ITEM_PICKUP)
	stop_movement()

// NOTE: This component will work very poorly at anything less than ticking 10 times per second
/datum/component/movable_physics/process(seconds_per_tick)
	var/atom/movable/moving_atom = parent
	if(!isturf(moving_atom.loc) || !has_movement())
		stop_movement()
		return PROCESS_KILL

	// We will not process when paused
	if(physics_flags & MPHYSICS_PAUSED)
		return

	// this component was designed to tick every 1/20 seconds, so we have to always account for that
	var/tick_amount = 20 * seconds_per_tick
	//this code basically only makes sense if we only move at most a single tile per tick, it is absolutely fucked otherwise
	while(tick_amount > 0)
		tick_amount--
		moving_atom.pixel_x = round(moving_atom.pixel_x + (horizontal_velocity * sin(angle)), MOVABLE_PHYSICS_PRECISION)
		moving_atom.pixel_y = round(moving_atom.pixel_y + (horizontal_velocity * cos(angle)), MOVABLE_PHYSICS_PRECISION)

		moving_atom.pixel_z = round(max(z_floor, moving_atom.pixel_z + vertical_velocity), MOVABLE_PHYSICS_PRECISION)

		moving_atom.adjust_visual_angle(round(visual_angle_velocity, 1))

		horizontal_velocity = max(0, horizontal_velocity - horizontal_friction)
		// we are not on the floor, apply friction
		if(moving_atom.pixel_z > z_floor)
			vertical_velocity -= vertical_friction
		// we are on the floor, try to bounce if we have any vertical velocity
		else if(moving_atom.pixel_z <= z_floor && vertical_velocity)
			z_floor_bounce(moving_atom)

		visual_angle_velocity = max(0, visual_angle_velocity - visual_angle_friction)

		var/move_direction = NONE
		var/effective_pixel_x = moving_atom.pixel_x - moving_atom.base_pixel_x
		var/effective_pixel_y = moving_atom.pixel_y - moving_atom.base_pixel_y
		//crossed east boundary
		if(effective_pixel_x > world.icon_size/2)
			move_direction |= EAST
		//crossed west boundary
		else if(effective_pixel_x < -world.icon_size/2)
			move_direction |= WEST

		//crossed north boundary
		if(effective_pixel_y > world.icon_size/2)
			move_direction |= NORTH
		//crossed south boundary
		else if(effective_pixel_y < -world.icon_size/2)
			move_direction |= SOUTH

		//check if we need to move, continue otherwise
		if(!move_direction)
			continue
		//get the tile we should move towards
		var/step = get_step(moving_atom, move_direction)
		//attempt to move to that tile, if successful we reset the pixel_x and pixel_y to be on the edge of appropriate boundaries
		//if unsuccessful, bump signal will be called and newton's third law comes into play
		if(moving_atom.Move(step, move_direction, world.icon_size))
			if(move_direction & EAST)
				moving_atom.pixel_x -= world.icon_size
			else if(move_direction & WEST)
				moving_atom.pixel_x += world.icon_size

			if(move_direction & NORTH)
				moving_atom.pixel_y -= world.icon_size
			else if(move_direction & SOUTH)
				moving_atom.pixel_y += world.icon_size

/// Checks if we still have any movement going on
/datum/component/movable_physics/proc/has_movement()
	var/atom/movable/moving_atom = parent
	// horizontal velocity and visual_angle_velocity should NEVER be negative
	if(horizontal_velocity < MOVABLE_PHYSICS_MINIMAL_VELOCITY && \
		abs(vertical_velocity) < MOVABLE_PHYSICS_MINIMAL_VELOCITY && \
		moving_atom.pixel_z <= z_floor && \
		visual_angle_velocity < MOVABLE_PHYSICS_MINIMAL_VELOCITY)
		return FALSE
	return TRUE

/// Does a bunch of setup, then starts the movement sequence
/datum/component/movable_physics/proc/start_movement()
	if(physics_flags & MPHYSICS_MOVING)
		stack_trace("[type] attempted to start_movement() while already moving")
		return
	START_PROCESSING(SSmovable_physics, src)
	physics_flags |= MPHYSICS_MOVING
	var/atom/movable/moving_atom = parent
	cached_animate_movement = moving_atom.animate_movement
	moving_atom.animate_movement = NO_STEPS
	if(!spin_speed || visual_angle_velocity || visual_angle_friction)
		return
	moving_atom.SpinAnimation(speed = spin_speed, loops = spin_loops)
	if(spin_loops == INFINITE)
		cached_transform = matrix(moving_atom.transform)

/// Stops movement sequence, and deletes component if we have the MPHYSICS_QDEL_WHEN_NO_MOVEMENT flag
/datum/component/movable_physics/proc/stop_movement()
	STOP_PROCESSING(SSmovable_physics, src)
	physics_flags &= ~MPHYSICS_MOVING
	var/atom/movable/moving_atom = parent
	if(cached_animate_movement)
		moving_atom.animate_movement = cached_animate_movement
	// this will probably bite my ass later
	moving_atom.pixel_z = z_floor
	if(cached_transform)
		animate(moving_atom, transform = cached_transform, time = 0, loop = 0)
	if(stop_callback)
		stop_callback.Invoke()
	if((physics_flags & MPHYSICS_QDEL_WHEN_NO_MOVEMENT) && !QDELING(src))
		qdel(src)

/// Helper to set angle, futureproofing in case new behavior like altering the transform of the movable based on angle is needed
/datum/component/movable_physics/proc/set_angle(new_angle)
	angle = SIMPLIFY_DEGREES(new_angle)

/// Proc for bouncing, aka object reached z_floor on pixel_z and needs a dose of Newton's third law
/datum/component/movable_physics/proc/z_floor_bounce(atom/movable/moving_atom)
	moving_atom.pixel_z = round(z_floor, MOVABLE_PHYSICS_PRECISION)
	if(bounce_spin_speed && !visual_angle_velocity && !visual_angle_friction)
		moving_atom.SpinAnimation(speed = bounce_spin_speed, loops = max(0, bounce_spin_loops))
	vertical_velocity = abs(vertical_velocity * vertical_conservation_of_momentum)
	if(bounce_callback)
		bounce_callback.Invoke()

/// Basically handles bumping on a solid object and ricocheting away according to a dose of Newton's third law
/datum/component/movable_physics/proc/on_bump(atom/movable/source, atom/bumped_atom)
	SIGNAL_HANDLER

	horizontal_velocity = horizontal_velocity * horizontal_conservation_of_momentum
	var/face_direction = get_dir(bumped_atom, source)
	var/face_angle = dir2angle(face_direction)
	var/incidence = GET_ANGLE_OF_INCIDENCE(face_angle, angle + 180)
	var/new_angle = SIMPLIFY_DEGREES(face_angle + incidence)
	set_angle(new_angle)
	if(!visual_angle_velocity)
		return
	incidence = GET_ANGLE_OF_INCIDENCE(face_angle, source.visual_angle + 180)
	new_angle = SIMPLIFY_DEGREES(face_angle + incidence)
	source.set_visual_angle(new_angle)
	bumped_atom.hitby(source, FALSE)

/// Stops movement for pesky items when they get picked up, as that essentially invalidates this component
/datum/component/movable_physics/proc/on_item_pickup(obj/item/source)
	SIGNAL_HANDLER

	stop_movement()

/**
 * DEBUG PROC
 *
 * Basically, loosely throws src towards target. For simple, no-nonsense testing of the component.
 * Deviation is just the amount of degrees the angle can deviate.
 */
/atom/movable/proc/physics_chungus_deluxe(atom/movable/target, deviation = rand(-10, 10))
	var/angle_to_target = get_angle(src, target)
	var/angle_of_movement = angle_to_target
	if(deviation)
		angle_of_movement += SIMPLIFY_DEGREES(rand(-deviation * 100, deviation * 100) * 0.01)
	AddComponent(/datum/component/movable_physics, \
		angle = angle_of_movement, \
		horizontal_velocity = rand(4.5 * 100, 5.5 * 100) * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * 0.01, \
		horizontal_friction = rand(0.2 * 100, 0.24 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		z_floor = 0, \
		visual_angle_velocity = rand(1 * 100, 3 * 100) * 0.01, \
		visual_angle_friction = 0.1, \
	)
