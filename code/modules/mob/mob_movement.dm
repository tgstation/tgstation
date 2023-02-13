/**
 * If your mob is concious, drop the item in the active hand
 *
 * This is a hidden verb, likely for binding with winset for hotkeys
 */
/client/verb/drop_item()
	set hidden = TRUE
	if(!iscyborg(mob) && mob.stat == CONSCIOUS)
		mob.dropItemToGround(mob.get_active_held_item())
	return

/**
 * force move the control_object of your client mob
 *
 * Used in admin possession and called from the client Move proc
 * ensures the possessed object moves and not the admin mob
 *
 * Has no sanity other than checking density
 */
/client/proc/Move_object(direct)
	if(mob?.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)
				return
			mob.control_object.setDir(direct)
		else
			mob.control_object.forceMove(get_step(mob.control_object,direct))

/**
 * Move a client in a direction
 *
 * Huge proc, has a lot of functionality
 *
 * Mostly it will despatch to the mob that you are the owner of to actually move
 * in the physical realm
 *
 * Things that stop you moving as a mob:
 * * world time being less than your next move_delay
 * * not being in a mob, or that mob not having a loc
 * * missing the n and direction parameters
 * * being in remote control of an object (calls Moveobject instead)
 * * being dead (it ghosts you instead)
 *
 * Things that stop you moving as a mob living (why even have OO if you're just shoving it all
 * in the parent proc with istype checks right?):
 * * having incorporeal_move set (calls Process_Incorpmove() instead)
 * * being grabbed
 * * being buckled  (relaymove() is called to the buckled atom instead)
 * * having your loc be some other mob (relaymove() is called on that mob instead)
 * * Not having MOBILITY_MOVE
 * * Failing Process_Spacemove() call
 *
 * At this point, if the mob is is confused, then a random direction and target turf will be calculated for you to travel to instead
 *
 * Now the parent call is made (to the byond builtin move), which moves you
 *
 * Some final move delay calculations (doubling if you moved diagonally successfully)
 *
 * if mob throwing is set I believe it's unset at this point via a call to finalize
 *
 * Finally if you're pulling an object and it's dense, you are turned 180 after the move
 * (if you ask me, this should be at the top of the move so you don't dance around)
 *
 */
/client/Move(new_loc, direct)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return FALSE
	next_move_dir_add = 0
	next_move_dir_sub = 0
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	if(!direct || !new_loc)
		return FALSE
	if(!mob?.loc)
		return FALSE
	if(mob.notransform)
		return FALSE //This is sota the goto stop mobs from moving var
	if(mob.control_object)
		return Move_object(direct)
	if(!isliving(mob))
		return mob.Move(new_loc, direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE
	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
		return FALSE

	var/mob/living/L = mob //Already checked for isliving earlier
	if(L.incorporeal_move && !is_secret_level(mob.z)) //Move though walls
		Process_Incorpmove(direct)
		return FALSE

	if(mob.remote_control) //we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(new_loc,direct,mob)

	if(Process_Grab()) //are we restrained by someone's grip?
		return

	if(mob.buckled) //if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(!(L.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(ismovable(mob.loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = mob.loc
		return loc_atom.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE, args) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	//We are now going to move
	var/add_delay = mob.cached_multiplicative_slowdown
	var/new_glide_size = DELAY_TO_GLIDE_SIZE(add_delay * ( (NSCOMPONENT(direct) && EWCOMPONENT(direct)) ? sqrt(2) : 1 ) )
	mob.set_glide_size(new_glide_size) // set it now in case of pulled objects
	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	//Basically an optional override for our glide size
	//Sometimes you want to look like you're moving with a delay you don't actually have yet
	visual_delay = 0

	. = ..()

	if((direct & (direct - 1)) && mob.loc == new_loc) //moved diagonally successfully
		add_delay *= sqrt(2)

	var/after_glide = 0
	if(visual_delay)
		after_glide = visual_delay
	else
		after_glide = DELAY_TO_GLIDE_SIZE(add_delay)

	mob.set_glide_size(after_glide)

	move_delay += add_delay
	if(.) // If mob is null here, we deserve the runtime
		if(mob.throwing)
			mob.throwing.finalize(FALSE)

		// At this point we've moved the client's attached mob. This is one of the only ways to guess that a move was done
		// as a result of player input and not because they were pulled or any other magic.
		SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED)

	var/atom/movable/P = mob.pulling
	if(P && !ismob(P) && P.density)
		mob.setDir(turn(mob.dir, 180))

/**
 * Checks to see if you're being grabbed and if so attempts to break it
 *
 * Called by client/Move()
 */
/client/proc/Process_Grab()
	if(!mob.pulledby)
		return FALSE
	if(mob.pulledby == mob.pulling && mob.pulledby.grab_state == GRAB_PASSIVE) //Don't autoresist passive grabs if we're grabbing them too.
		return FALSE
	if(HAS_TRAIT(mob, TRAIT_INCAPACITATED))
		COOLDOWN_START(src, move_delay, 1 SECONDS)
		return TRUE
	else if(HAS_TRAIT(mob, TRAIT_RESTRAINED))
		COOLDOWN_START(src, move_delay, 1 SECONDS)
		to_chat(src, span_warning("You're restrained! You can't move!"))
		return TRUE
	return mob.resist_grab(TRUE)


/**
 * Allows mobs to ignore density and phase through objects
 *
 * Called by client/Move()
 *
 * The behaviour depends on the incorporeal_move value of the mob
 *
 * * INCORPOREAL_MOVE_BASIC - forceMoved to the next tile with no stop
 * * INCORPOREAL_MOVE_SHADOW  - the same but leaves a cool effect path
 * * INCORPOREAL_MOVE_JAUNT - the same but blocked by holy tiles
 *
 * You'll note this is another mob living level proc living at the client level
 */
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(INCORPOREAL_MOVE_BASIC)
			var/T = get_step(L,direct)
			if(T)
				L.forceMove(T)
			L.setDir(direct)
		if(INCORPOREAL_MOVE_SHADOW)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				var/target = locate(locx,locy,mobloc.z)
				if(target)
					L.forceMove(target)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in get_line(mobloc, L.loc))
						new /obj/effect/temp_visual/dir_setting/ninja/shadow(T, L.dir)
						limit--
						if(limit <= 0)
							break
			else
				new /obj/effect/temp_visual/dir_setting/ninja/shadow(mobloc, L.dir)
				var/T = get_step(L,direct)
				if(T)
					L.forceMove(T)
			L.setDir(direct)
		if(INCORPOREAL_MOVE_JAUNT) //Incorporeal move, but blocked by holy-watered tiles and salt piles.
			var/turf/open/floor/stepTurf = get_step(L, direct)
			if(stepTurf)
				var/obj/effect/decal/cleanable/food/salt/salt = locate() in stepTurf
				if(salt)
					to_chat(L, span_warning("[salt] bars your passage!"))
					if(isrevenant(L))
						var/mob/living/simple_animal/revenant/R = L
						R.reveal(20)
						R.stun(20)
					return
				if(stepTurf.turf_flags & NOJAUNT)
					to_chat(L, span_warning("Some strange aura is blocking the way."))
					return
				if(locate(/obj/effect/blessing) in stepTurf)
					to_chat(L, span_warning("Holy energies block your path!"))
					return

				L.forceMove(stepTurf)
			L.setDir(direct)
	return TRUE

/**
 * Handles mob/living movement in space (or no gravity)
 *
 * Called by /client/Move()
 *
 * return TRUE for movement or FALSE for none
 *
 * You can move in space if you have a spacewalk ability
 */
/mob/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	. = ..()
	if(. || HAS_TRAIT(src, TRAIT_SPACEWALK))
		return TRUE

	// FUCK OFF
	if(buckled)
		return TRUE

	var/atom/movable/backup = get_spacemove_backup(movement_dir, continuous_move)
	if(!backup)
		return FALSE
	if(continuous_move || !istype(backup) || !movement_dir || backup.anchored)
		return TRUE
	// last pushoff exists for one reason
	// to ensure pushing a mob doesn't just lead to it considering us as backup, and failing
	last_pushoff = world.time
	if(backup.newtonian_move(turn(movement_dir, 180), instant = TRUE)) //You're pushing off something movable, so it moves
		// We set it down here so future calls to Process_Spacemove by the same pair in the same tick don't lead to fucky
		backup.last_pushoff = world.time
		to_chat(src, span_info("You push off of [backup] to propel yourself."))
	return TRUE

/**
 * Finds a target near a mob that is viable for pushing off when moving.
 * Takes the intended movement direction as input, alongside if the context is checking if we're allowed to continue drifting
 */
/mob/get_spacemove_backup(moving_direction, continuous_move)
	for(var/atom/pushover as anything in range(1, get_turf(src)))
		if(pushover == src)
			continue
		if(isarea(pushover))
			continue
		if(isturf(pushover))
			var/turf/turf = pushover
			if(isspaceturf(turf))
				continue
			if(!turf.density && !mob_negates_gravity())
				continue
			return pushover

		var/atom/movable/rebound = pushover
		if(rebound == buckled)
			continue
		if(ismob(rebound))
			var/mob/lover = rebound
			if(lover.buckled)
				continue

		var/pass_allowed = rebound.CanPass(src, get_dir(rebound, src))
		if(!rebound.density && pass_allowed)
			continue
		//Sometime this tick, this pushed off something. Doesn't count as a valid pushoff target
		if(rebound.last_pushoff == world.time)
			continue
		if(continuous_move && !pass_allowed)
			var/datum/move_loop/move/rebound_engine = SSmove_manager.processing_on(rebound, SSspacedrift)
			// If you're moving toward it and you're both going the same direction, stop
			if(moving_direction == get_dir(src, pushover) && rebound_engine && moving_direction == rebound_engine.direction)
				continue
		else if(!pass_allowed)
			if(moving_direction == get_dir(src, pushover)) // Can't push "off" of something that you're walking into
				continue
		if(rebound.anchored)
			return rebound
		if(pulling == rebound)
			continue
		return rebound

/mob/has_gravity()
	return mob_negates_gravity() || ..()

/**
 * Does this mob ignore gravity
 */
/mob/proc/mob_negates_gravity()
	var/turf/turf = get_turf(src)
	return !isgroundlessturf(turf) && HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY)

/// Called when this mob slips over, override as needed
/mob/proc/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	add_mob_memory(/datum/memory/was_slipped, antagonist = O)

/// Update the gravity status of this mob
/mob/proc/update_gravity(has_gravity, override=FALSE)
	var/speed_change = max(0, has_gravity - STANDARD_GRAVITY)
	if(!speed_change && gravity_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/gravity)
		gravity_slowdown = 0
	else if(gravity_slowdown != speed_change)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/gravity, multiplicative_slowdown=speed_change)
		gravity_slowdown = speed_change

//bodypart selection verbs - Cyberboss
//8: repeated presses toggles through head - eyes - mouth
//9: eyes 8: head 7: mouth
//4: r-arm 5: chest 6: l-arm
//1: r-leg 2: groin 3: l-leg

///Validate the client's mob has a valid zone selected
/client/proc/check_has_body_select()
	return mob && mob.hud_used && mob.hud_used.zone_select && istype(mob.hud_used.zone_select, /atom/movable/screen/zone_sel)

/**
 * Hidden verb to set the target zone of a mob to the head
 *
 * (bound to 8) - repeated presses toggles through head - eyes - mouth
 */

///Hidden verb to target the head, bound to 8
/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_HEAD)
			next_in_line = BODY_ZONE_PRECISE_EYES
		if(BODY_ZONE_PRECISE_EYES)
			next_in_line = BODY_ZONE_PRECISE_MOUTH
		else
			next_in_line = BODY_ZONE_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(next_in_line, mob)

///Hidden verb to target the eyes, bound to 7
/client/verb/body_eyes()
	set name = "body-eyes"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_PRECISE_EYES, mob)

///Hidden verb to target the mouth, bound to 9
/client/verb/body_mouth()
	set name = "body-mouth"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_PRECISE_MOUTH, mob)

///Hidden verb to target the right arm, bound to 4
/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_R_ARM, mob)

///Hidden verb to target the chest, bound to 5
/client/verb/body_chest()
	set name = "body-chest"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_CHEST, mob)

///Hidden verb to target the left arm, bound to 6
/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_L_ARM, mob)

///Hidden verb to target the right leg, bound to 1
/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_R_LEG, mob)

///Hidden verb to target the groin, bound to 2
/client/verb/body_groin()
	set name = "body-groin"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_PRECISE_GROIN, mob)

///Hidden verb to target the left leg, bound to 3
/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_L_LEG, mob)

///Verb to toggle the walk or run status
/client/verb/toggle_walk_run()
	set name = "toggle-walk-run"
	set hidden = TRUE
	set instant = TRUE
	if(mob)
		mob.toggle_move_intent(usr)

/**
 * Toggle the move intent of the mob
 *
 * triggers an update the move intent hud as well
 */
/mob/proc/toggle_move_intent(mob/user)
	if(m_intent == MOVE_INTENT_RUN)
		m_intent = MOVE_INTENT_WALK
	else
		m_intent = MOVE_INTENT_RUN
	if(hud_used?.static_inventory)
		for(var/atom/movable/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_appearance()

///Moves a mob upwards in z level
/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	var/turf/current_turf = get_turf(src)
	var/turf/above_turf = SSmapping.get_turf_above(current_turf)

	var/ventcrawling_flag = HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) ? ZMOVE_VENTCRAWLING : 0
	if(!above_turf)
		to_chat(src, span_warning("There's nowhere to go in that direction!"))
		return

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, UP)

	if(can_z_move(DOWN, above_turf, current_turf, ZMOVE_FALL_FLAGS|ventcrawling_flag)) //Will we fall down if we go up?
		if(buckled)
			to_chat(src, span_warning("[buckled] is is not capable of flight."))
		else
			to_chat(src, span_warning("You are not Superman."))
		return

	if(zMove(UP, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK|ventcrawling_flag))
		to_chat(src, span_notice("You move upwards."))

///Moves a mob down a z level
/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	var/turf/current_turf = get_turf(src)
	var/turf/below_turf = SSmapping.get_turf_below(current_turf)
	if(!below_turf)
		to_chat(src, span_warning("There's nowhere to go in that direction!"))
		return

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, DOWN)

	var/ventcrawling_flag = HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) ? ZMOVE_VENTCRAWLING : 0
	if(zMove(DOWN, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK|ventcrawling_flag))
		to_chat(src, span_notice("You move down."))
	return FALSE

/mob/abstract_move(atom/destination)
	var/turf/new_turf = get_turf(destination)
	if(new_turf && (istype(new_turf, /turf/cordon/secret) || is_secret_level(new_turf.z)) && !client?.holder)
		return
	return ..()
