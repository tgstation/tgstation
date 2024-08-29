/obj/bitrunning/hungry_customer
	name = "hungry customer"
	desc = "Help this customer get to their meal!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "boulder"
	icon_state = "boulder"
	density = 1
	move_force = MOVE_FORCE_WEAK
	flags_1 = INDESTRUCTIBLE
	var/mob/living/carbon/human/sisyphus
	var/arrived = FALSE
	var/speech_sound = 'sound/creatures/tourist/tourist_talk.ogg'
	var/list/mad_lines = list("NO TIP FOR YOU. GOODBYE!", "At least at SpaceDonalds they serve their food FAST!", "This venue is horrendous!", "I will speak to your manager!", "I'll be sure to leave a bad Yelp review.")
	var/list/push_lines = list("I hope there's a seat that supports my weight.", "I hope I can bring my gun in here.", "I hope they have the triple deluxe fatty burger.", "I just love the culture here.")

/obj/bitrunning/hungry_customer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)
	STOP_PROCESSING(SSobj, src)
	START_PROCESSING(SSfastprocess, src)
	RegisterSignal(src, COMSIG_ATOM_BUMPED, PROC_REF(bumped_hit))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_crossed_special))

/obj/bitrunning/hungry_customer/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(src, COMSIG_ATOM_BUMPED)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	if(sisyphus)
		UnregisterSignal(sisyphus, COMSIG_MOB_CLIENT_PRE_MOVE)
		sisyphus.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/shoving_customer)
		sisyphus = null
	. = ..()

/obj/bitrunning/hungry_customer/can_be_pulled(user, grab_state, force)
	return FALSE

/obj/bitrunning/hungry_customer/process(seconds_per_tick)
	var/turf/behind_boulder = get_step(src, SOUTH)
	if(behind_boulder == get_turf(src))
		return // Can't fall any further.
	for(var/atom/atom_found in behind_boulder)
		if(istype(atom_found, /obj/bitrunning/boulder_checkpoint))
			return // Can't fall past a checkpoint.
		if(sisyphus == atom_found)
			if(sisyphus.mobility_flags & MOBILITY_STAND) // Fall if we're being pushed and sisyphus falls over.
				return // Don't fall if we're being pushed.
	// We are falling at this point, if someone was pushing us, stop pushing.
	if(sisyphus)
		UnregisterSignal(sisyphus, COMSIG_MOB_CLIENT_PRE_MOVE)
		sisyphus.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/shoving_customer)
		sisyphus = null
		say(pick(mad_lines))
		playsound(src, speech_sound, 100, FALSE)

	step(src, SOUTH)

/obj/bitrunning/hungry_customer/proc/bumped_hit(datum/source, atom/movable/hit_object)
	SIGNAL_HANDLER
	if(sisyphus)
		return // we already have a pusher
	if(ishuman(hit_object) && get_dir(src, hit_object) == SOUTH)
		balloon_alert(hit_object, "pushing customer")
		sisyphus = hit_object
		RegisterSignal(sisyphus, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(sisyphus_movement))
		say(pick(push_lines))
		playsound(src, speech_sound, 100, FALSE)
		sisyphus.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/shoving_customer, update=TRUE)

/obj/bitrunning/hungry_customer/proc/sisyphus_movement(mob/living/source, move_args)
	SIGNAL_HANDLER
	var/move_direction = move_args[MOVE_ARG_DIRECTION]
	var/turf/boulder_destination = get_step(src, move_direction)
	if(boulder_destination == get_turf(src))
		switch(move_direction)
			if(NORTH)
				return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE // can't push the boulder this far
			if(SOUTH)
				UnregisterSignal(sisyphus, COMSIG_MOB_CLIENT_PRE_MOVE)
				sisyphus.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/shoving_customer)
				sisyphus = null
				say(pick(mad_lines))
				playsound(src, speech_sound, 100, FALSE)
	else
		step(src, move_direction)
		if(sisyphus)
			sisyphus.adjustStaminaLoss(rand(5, 15))

/obj/bitrunning/hungry_customer/proc/check_crossed_special(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	for(var/atom/possible_cross in src.loc)
		if(istype(possible_cross, /obj/bitrunning/customer_destination))
			var/obj/bitrunning/customer_destination/found = possible_cross
			playsound(src, speech_sound, 100, FALSE)
			say(found.victory_line)
			anchored = TRUE
			move_resist = MOVE_FORCE_EXTREMELY_STRONG // once this tourist has sat down, he will not move
			STOP_PROCESSING(SSfastprocess, src)
			UnregisterSignal(src, COMSIG_ATOM_BUMPED)
			UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
			if(sisyphus)
				UnregisterSignal(sisyphus, COMSIG_MOB_CLIENT_PRE_MOVE)
				sisyphus.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/shoving_customer)
				sisyphus = null

			new /obj/structure/closet/crate/secure/bitrunning/encrypted(get_turf(src))
			qdel(possible_cross)
			return
		if(istype(possible_cross, /obj/bitrunning/customer_speech))
			var/obj/bitrunning/customer_speech/found = possible_cross
			if(found.fired)
				continue
			found.fired = TRUE
			playsound(src, speech_sound, 100, FALSE)
			say(pick(found.possible_lines))

/obj/bitrunning/boulder_checkpoint
	name = "checkpoint"
	desc = "The customer can't fall past this."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "boulder_checkpoint"
	icon_state = "boulder_checkpoint"
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE

/obj/bitrunning/customer_destination
	name = "customer destination"
	desc = "If you can see this, file a bug report!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "boulder_destination"
	icon_state = "boulder_destination"
	alpha = 0
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/victory_line = "Finally! I'll give you a five star review on Lift! Here's a tip!"

/obj/bitrunning/customer_speech
	name = "customer speech"
	desc = "If you can see this, file a bug report!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "customer_speech"
	icon_state = "customer_speech"
	alpha = 0
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/list/possible_lines = list(
		"I'm so tired from standing...",
		"I have chronic back pain, please hurry up and get me a seat!",
		"I'm not going to tip if I don't get a seat."
	)
	var/fired = FALSE


/obj/bitrunning/customer_waiter
	name = "busy waiter"
	desc = "They look incredibly busy, better not get in their way."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "boulder_blocker"
	icon_state = "boulder_blocker"
	density = 1
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	flags_1 = INDESTRUCTIBLE
	var/starting_dir = EAST
	var/current_dir = EAST
	var/speed = 3
	var/speech_sound = 'sound/creatures/tourist/tourist_talk_french.ogg'
	var/list/bumped_lines = list(
		"Out of the way!",
		"Order for table seven!",
		"Make way!",
		"Behind!",
	)
	var/said_blocked_line = FALSE
	var/datum/move_loop/loop

/obj/bitrunning/customer_waiter/east
	starting_dir = EAST

/obj/bitrunning/customer_waiter/east/slow
	speed = 5

/obj/bitrunning/customer_waiter/east/fast
	speed = 1

/obj/bitrunning/customer_waiter/west
	starting_dir = WEST

/obj/bitrunning/customer_waiter/west/slow
	speed = 5

/obj/bitrunning/customer_waiter/west/fast
	speed = 1

/obj/bitrunning/customer_waiter/Initialize(mapload)
	. = ..()
	current_dir = starting_dir
	loop = GLOB.move_manager.move(src, starting_dir, delay = speed, flags = MOVEMENT_LOOP_START_FAST|MOVEMENT_LOOP_IGNORE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(check_bump))

/obj/bitrunning/customer_waiter/proc/check_bump(datum/move_loop/source, result)
	SIGNAL_HANDLER
	if(result == MOVELOOP_FAILURE) // if we can't move, go the other direction
		var/turf/possible_obstacle = get_step(src, current_dir)
		var/blocked_by_idiot = FALSE
		for(var/atom/idiot in possible_obstacle)
			if(istype(idiot, /obj/bitrunning/hungry_customer))
				var/obj/bitrunning/hungry_customer/american = idiot
				if(american.sisyphus)
					american.sisyphus.Knockdown(3 SECONDS)
					if(!said_blocked_line)
						say(pick(bumped_lines))
						playsound(src, speech_sound, 100, FALSE)
						said_blocked_line = TRUE
						step(american, current_dir)
					break
		if(!blocked_by_idiot)
			UnregisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS)
			GLOB.move_manager.stop_looping(src)
			current_dir = REVERSE_DIR(current_dir)
			loop = GLOB.move_manager.move(src, current_dir, delay = speed, flags = MOVEMENT_LOOP_START_FAST|MOVEMENT_LOOP_IGNORE_PRIORITY)
			RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(check_bump))
			return
	else
		said_blocked_line = FALSE

/obj/bitrunning/hungry_customer/supermatter
	name = "engineering enjoyer"
	desc = "Help this tourist see their favorite thing, the supermatter!"
	mad_lines = list("Ugh, this is what I get for a premium Lift?", "I'm absolutely giving you a bad review.", "This is coming out of your tip!!!")
	push_lines = list("I'm so excited to see the Supermatter!", "Do you think they'll let me touch the crystal?", "I've been saving for this trip for years!")

/obj/bitrunning/customer_speech/supermatter
	possible_lines = list(
		"I wonder if my healthcare covers radiation.",
		"You're not very fast, you know?",
		"You're not really earning that tip. Ever heard of customer service?",
		"This is taking FOREVER. Can't you push faster?"
	)
