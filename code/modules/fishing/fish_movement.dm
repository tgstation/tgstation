/datum/fish_movement
	/// The minigame that spawned us
	var/datum/fishing_challenge/master
	/// How likely the fish is to perform a standard jump, then multiplied by difficulty
	var/short_jump_chance = 2.25
	/// How likely the fish is to perform a long jump, then multiplied by difficulty
	var/long_jump_chance = 0.0625
	/// The speed limit for the short jump
	var/short_jump_velocity_limit = 400
	/// The speed limit for the long jump
	var/long_jump_velocity_limit = 200
	/// The current speed limit used
	var/current_velocity_limit
	/// The base velocity of the fish, which may affect jump distances and falling speed.
	var/fish_idle_velocity = 0
	/// A position on the slider the fish wants to get to
	var/target_position
	/// If true, the fish can jump while a target position is set, thus overriding it
	var/can_interrupt_move = TRUE
	/// The current speed the fish is moving at
	var/fish_velocity = 0

/datum/fish_movement/New(datum/fishing_challenge/master)
	src.master = master

/**
 * Proc that adjusts movement values to the difficulty of the minigame.
 * The operations can be a tad complex, but basically it ensures that jump
 * chances with a probability higher than 1% increase in a smooth curve so that
 * they only reach 100% prob if the difficulty is also 100.
 */
/datum/fish_movement/proc/adjust_to_difficulty()
	var/square_angle_rad = TORADIANS(90)
	var/zero_one_difficulty = master.difficulty/100
	if(short_jump_chance > 1)
		short_jump_chance = (zero_one_difficulty**(square_angle_rad-TORADIANS(arctan(short_jump_chance * 1/square_angle_rad))))*100
	else
		short_jump_chance *= master.difficulty
	if(long_jump_chance > 1)
		long_jump_chance = (zero_one_difficulty**(square_angle_rad-TORADIANS(arctan(long_jump_chance * 1/square_angle_rad))))*100
	else
		long_jump_chance *= master.difficulty

///The proc that moves the fish around, just like in the old TGUI, mostly.
/datum/fish_movement/proc/move_fish(seconds_per_tick)
	var/long_chance = long_jump_chance * seconds_per_tick * 10
	var/short_chance = short_jump_chance * seconds_per_tick * 10

	// If we have the target but we're close enough, mark as target reached
	if(abs(target_position - master.fish_position) < FISH_TARGET_MIN_DISTANCE)
		target_position = null

	// Switching to new long jump target can interrupt any other
	if((can_interrupt_move || isnull(target_position)) && prob(long_chance))
		/**
		 * Move at least 0.75 to full of the availible bar in given direction,
		 * and more likely to move in the direction where there's more space
		 */
		var/distance_from_top = FISHING_MINIGAME_AREA - master.fish_position - master.fish_height
		var/distance_from_bottom = master.fish_position
		var/top_chance
		if(distance_from_top < FISH_SHORT_JUMP_MIN_DISTANCE)
			top_chance = 0
		else
			top_chance = (distance_from_top/max(distance_from_bottom, 1)) * 100
		var/new_target = master.fish_position
		if(prob(top_chance))
			new_target += distance_from_top * rand(75, 100)/100
		else
			new_target -= distance_from_bottom * rand(75, 100)/100
		target_position = round(new_target)
		current_velocity_limit = long_jump_velocity_limit

	// Move towards target
	if(!isnull(target_position))
		var/distance = target_position - master.fish_position
		// about 5 at diff 15 , 10 at diff 30, 30 at diff 100
		var/acceleration_mult = get_acceleration()
		var/target_acceleration = distance * acceleration_mult * seconds_per_tick

		fish_velocity = fish_velocity * FISH_FRICTION_MULT + target_acceleration
	else if(prob(short_chance))
		var/distance_from_top = FISHING_MINIGAME_AREA - master.fish_position - master.fish_height
		var/distance_from_bottom = master.fish_position
		var/jump_length
		if(distance_from_top >= FISH_SHORT_JUMP_MIN_DISTANCE)
			jump_length = rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		if(distance_from_bottom >= FISH_SHORT_JUMP_MIN_DISTANCE && (!jump_length || prob(50)))
			jump_length = -rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		target_position = clamp(master.fish_position + jump_length, 0, FISHING_MINIGAME_AREA - master.fish_height)
		current_velocity_limit = short_jump_velocity_limit

	fish_velocity = clamp(fish_velocity + fish_idle_velocity, -current_velocity_limit, current_velocity_limit)
	master.fish_position = clamp(master.fish_position + fish_velocity * seconds_per_tick, 0, FISHING_MINIGAME_AREA - master.fish_height)

/datum/fish_movement/proc/get_acceleration()
	return 0.3 * master.difficulty + 0.5

/datum/fish_movement/slow
	short_jump_chance = 0
	long_jump_chance = 1.5
	long_jump_velocity_limit = 150
	can_interrupt_move = FALSE

/datum/fish_movement/zippy
	short_jump_chance = parent_type::short_jump_chance * 3

///fish movement datum that progressively gets faster until the acceleration and speed are double the normal.
/datum/fish_movement/accelerando
	/// The speed limit for the short jump
	var/short_jump_velocity_limit = 350
	/// The speed limit for the long jump
	var/long_jump_velocity_limit = 175
	///What the short jump velocity was when move_fish was first called.
	var/initial_short_jump_velocity
	///What the long jump velocity was when move_fish was first called.
	var/initial_long_jump_velocity
	///time elapsed since the start of the active phase of the minigame
	var/seconds_elapsed
	///Time to reach full speed, in seconds.
	var/accel_time_cap = 30

/datum/fish_movement/accelerando/move_fish(seconds_per_tick)
	seconds_elapsed += seconds_per_tick
	if(seconds_elapsed > accel_time_cap)
		return ..()
	if(!initial_short_jump_velocity && !initial_long_jump_velocity)
		initial_short_jump_velocity = short_jump_velocity
		initial_long_jump_velocity = long_jump_velocity

	if(current_velocity_limit)
		var/current_limit = current_velocity_limit == short_jump_velocity ? initial_short_jump_vel : initial_long_jump_vel
		current_velocity_limit += current_limit/accel_time_cap * seconds_per_tick

	short_jump_velocity += initial_short_jump_vel/accel_time_cap * seconds_per_tick
	long_jump_velocity += initial_long_jump_vel/accel_time_cap * seconds_per_tick
	return ..()

/datum/fish_movement/accelerando/get_acceleration()
	var/acceleration = ..()
	return acceleration + min(acceleration, acceleration/accel_time_cap * seconds_elapsed)
