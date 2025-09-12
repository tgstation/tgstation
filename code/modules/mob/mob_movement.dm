/**
 * If your mob is conscious, drop the item in the active hand
 *
 * This is a hidden verb, likely for binding with winset for hotkeys
 */
/client/verb/drop_item()
	set hidden = TRUE
	if(!iscyborg(mob) && mob.stat == CONSCIOUS)
		mob.dropItemToGround(mob.get_active_held_item())
	return
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
	next_move_dir_add = NONE
	next_move_dir_sub = NONE
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	if(!direct || !new_loc)
		return FALSE
	if(!mob?.loc)
		return FALSE
	if(HAS_TRAIT(mob, TRAIT_NO_TRANSFORM))
		return FALSE //This is sorta the goto stop mobs from moving trait
	if(!isliving(mob))
		if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE, new_loc, direct) & COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE)
			return FALSE
		return mob.Move(new_loc, direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE
	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, new_loc, direct) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
		return FALSE

	var/mob/living/L = mob //Already checked for isliving earlier
	if(L.incorporeal_move && !is_secret_level(mob.z)) //Move though walls
		Process_Incorpmove(direct)
		return FALSE

	if(mob.remote_control) //we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		var/mob/living/silicon/ai/smoovin_ai = mob
		return smoovin_ai.AIMove(direct)

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
		SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVE_NOGRAV, args)
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE, args) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	//We are now going to move
	var/add_delay = mob.cached_multiplicative_slowdown
	var/glide_delay = add_delay
	if(NSCOMPONENT(direct) && EWCOMPONENT(direct))
		glide_delay = FLOOR(glide_delay * sqrt(2), world.tick_lag)
	mob.set_glide_size(DELAY_TO_GLIDE_SIZE(glide_delay)) // set it now in case of pulled objects
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
	var/old_dir = mob.dir

	. = ..()

	if((direct & (direct - 1)) && mob.loc == new_loc) //moved diagonally successfully
		add_delay = FLOOR(add_delay * sqrt(2), world.tick_lag)

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
		SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED, direct, old_dir)

	var/atom/movable/P = mob.pulling
	if(P && !ismob(P) && P.density)
		mob.setDir(REVERSE_DIR(mob.dir))

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
						var/mob/living/basic/revenant/ghostie = L
						ghostie.apply_status_effect(/datum/status_effect/revenant/revealed, 2 SECONDS)
						ghostie.apply_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant, 2 SECONDS)
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

	if(buckled)
		return TRUE

	if(movement_type & FLYING || HAS_TRAIT(src, TRAIT_FREE_FLOAT_MOVEMENT))
		return TRUE

	if (HAS_TRAIT(src, TRAIT_NOGRAV_ALWAYS_DRIFT))
		return FALSE

	var/atom/movable/backup = get_spacemove_backup(movement_dir, continuous_move)
	if(!backup)
		return FALSE

	if (SEND_SIGNAL(src, COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE, movement_dir, continuous_move, backup) & COMPONENT_PREVENT_SPACEMOVE_HALT)
		return FALSE

	if (drift_handler?.attempt_halt(movement_dir, continuous_move, backup))
		return FALSE

	if(continuous_move || !istype(backup) || !movement_dir || backup.anchored)
		return TRUE

	// last pushoff exists for one reason
	// to ensure pushing a mob doesn't just lead to it considering us as backup, and failing
	last_pushoff = world.time
	if(backup.newtonian_move(dir2angle(REVERSE_DIR(movement_dir)), instant = TRUE)) //You're pushing off something movable, so it moves
		// We set it down here so future calls to Process_Spacemove by the same pair in the same tick don't lead to fucky
		backup.last_pushoff = world.time
		to_chat(src, span_info("You push off of [backup] to propel yourself."))
	return TRUE

/// We handle lattices via backups
/mob/handle_spacemove_grabbing()
	return

/**
 * Finds a target near a mob that is viable for pushing off when moving.
 * Takes the intended movement direction as input, alongside if the context is checking if we're allowed to continue drifting
 * If include_floors is TRUE, includes floors *with gravity*
 */
/mob/get_spacemove_backup(moving_direction, continuous_move, include_floors = FALSE)
	var/atom/secondary_backup
	var/list/priority_dirs = (moving_direction in GLOB.cardinals) ? GLOB.cardinals : GLOB.diagonals
	for(var/atom/pushover as anything in range(1, get_turf(src)))
		if(pushover == src)
			continue
		if(isarea(pushover))
			continue
		var/is_priority = pushover.loc == loc || (get_dir(src, pushover) in priority_dirs)
		if(isturf(pushover))
			var/turf/turf = pushover
			if(isspaceturf(turf))
				continue
			if(!turf.density && !mob_negates_gravity())
				if (!include_floors || !turf.has_gravity())
					continue
			if (is_priority)
				return pushover
			secondary_backup = pushover
			continue

		var/atom/movable/rebound = pushover
		if(rebound == buckled)
			continue
		if(ismob(rebound))
			var/mob/lover = rebound
			if(lover.buckled)
				continue

		var/pass_allowed = rebound.CanPass(src, get_dir(rebound, src))
		if(!rebound.density && pass_allowed && !istype(rebound, /obj/structure/lattice))
			continue
		//Sometime this tick, this pushed off something. Doesn't count as a valid pushoff target
		if(rebound.last_pushoff == world.time)
			continue
		if(continuous_move && !pass_allowed)
			var/datum/move_loop/smooth_move/rebound_engine = GLOB.move_manager.processing_on(rebound, SSnewtonian_movement)
			// If you're moving toward it and you're both going the same direction, stop
			if(moving_direction == get_dir(src, pushover) && rebound_engine && moving_direction == angle2dir(rebound_engine.angle))
				continue
		else if(!pass_allowed)
			if(moving_direction == get_dir(src, pushover)) // Can't push "off" of something that you're walking into
				continue
		if(rebound.anchored)
			if (is_priority)
				return rebound
			secondary_backup = rebound
			continue
		if(pulling == rebound)
			continue
		if (is_priority)
			return rebound
		secondary_backup = rebound
	return secondary_backup

/mob/has_gravity(turf/gravity_turf)
	return mob_negates_gravity() || ..()

/**
 * Does this mob ignore gravity
 */
/mob/proc/mob_negates_gravity()
	return FALSE

/**
 * Called when this mob slips over, override as needed
 *
 * knockdown_amount - time (in deciseconds) the slip leaves them on the ground
 * slipped_on - optional, what'd we slip on? if not set, we assume they just fell over
 * lube - bitflag of "lube flags", see [mobs.dm] for more information
 * paralyze - time (in deciseconds) the slip leaves them paralyzed / unable to move
 * daze - time (in deciseconds) the slip leaves them vulnerable to shove stuns
 * force_drop = the slip forces them to drop held items
 */
/mob/proc/slip(knockdown_amount, obj/slipped_on, lube_flags, paralyze, daze, force_drop = FALSE)
	add_mob_memory(/datum/memory/was_slipped, antagonist = slipped_on)

	SEND_SIGNAL(src, COMSIG_MOB_SLIPPED, knockdown_amount, slipped_on, lube_flags, paralyze, daze, force_drop)

//bodypart selection verbs - Cyberboss
//8: repeated presses toggles through head - eyes - mouth
//7: mouth 8: head  9: eyes
//4: r-arm 5: chest 6: l-arm
//1: r-leg 2: groin 3: l-leg

///Validate the client's mob has a valid zone selected
/client/proc/check_has_body_select()
	return mob && mob.hud_used && mob.hud_used.zone_select && istype(mob.hud_used.zone_select, /atom/movable/screen/zone_sel)

/**
 * Hidden verbs to set desired body target zone
 *
 * Uses numpad keys 1-9
 */

///Hidden verb to cycle through head zone with repeated presses, head - eyes - mouth. Bound to 8
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

///Hidden verb to target the head, unbound by default.
/client/verb/body_head()
	set name = "body-head"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_HEAD, mob)

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
	if(isliving(mob))
		var/mob/living/user_mob = mob
		user_mob.toggle_move_intent()

/**
 * Toggle the move intent of the mob
 *
 * triggers an update the move intent hud as well
 */
/mob/living/proc/toggle_move_intent()
	if(move_intent == MOVE_INTENT_RUN)
		move_intent = MOVE_INTENT_WALK
	else
		move_intent = MOVE_INTENT_RUN
	if(hud_used?.static_inventory)
		for(var/atom/movable/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_appearance()
	update_move_intent_slowdown()

	SEND_SIGNAL(src, COMSIG_MOVE_INTENT_TOGGLED)

///Moves a mob upwards in z level
/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(remote_control)
		return remote_control.relaymove(src, UP)

	var/turf/current_turf = get_turf(src)

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, UP)

	var/obj/structure/ladder/current_ladder = locate() in current_turf
	if(current_ladder)
		current_ladder.use(src, TRUE)
		return

	if(!can_z_move(UP, current_turf, null, ZMOVE_CAN_FLY_CHECKS|ZMOVE_FEEDBACK))
		return
	balloon_alert(src, "moving up...")
	if(!do_after(src, 1 SECONDS, hidden = TRUE))
		return
	if(zMove(UP, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

///Moves a mob down a z level
/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	if(remote_control)
		return remote_control.relaymove(src, DOWN)

	var/turf/current_turf = get_turf(src)

	if(ismovable(loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, DOWN)

	var/obj/structure/ladder/current_ladder = locate() in current_turf
	if(current_ladder)
		current_ladder.use(src, FALSE)
		return

	if(!can_z_move(DOWN, current_turf, null, ZMOVE_CAN_FLY_CHECKS|ZMOVE_FEEDBACK))
		return
	balloon_alert(src, "moving down...")
	if(!do_after(src, 1 SECONDS, hidden = TRUE))
		return
	if(zMove(DOWN, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))
	return FALSE

/mob/abstract_move(atom/destination)
	var/turf/new_turf = get_turf(destination)
	if(new_turf && (istype(new_turf, /turf/cordon/secret) || is_secret_level(new_turf.z)) && !client?.holder)
		return
	return ..()
