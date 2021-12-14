#define MIN_RANGE 1
#define MIN_SPEED 1
#define MAX_RANGE 7
#define MAX_SPEED 10
#define HITS_TO_KILL 9
#define MIN_ATTACK_DELAY 10
#define MAX_ATTACK_DELAY 15

/**
 * Machine that runs around wildly so people can practice clickin on things
 *
 * Can have a mob buckled on or a obj/item/target attached. Movement controlled by SSFastProcess,
 * movespeed controlled by cooldown macros. Can attach obj/item/target, obj/item/training_toolbox, and can buckle mobs to this.
 */
/obj/structure/training_machine
	name = "AURUMILL-Brand MkII. Personnel Training Machine"
	desc = "Used for combat training simulations. Accepts standard training targets. A pair of buckling straps are attached."
	icon = 'icons/obj/objects.dmi'
	icon_state = "training_machine"
	can_buckle = TRUE
	buckle_lying = 0
	max_integrity = 200
	///Is the machine moving? Setting this to FALSE will automatically call stop_moving()
	var/moving = FALSE
	///The distance the machine is allowed to roam from its starting point
	var/range = 1
	///A random spot within range that the trainer is trying to reach
	var/turf/target_position
	///The turf the machine was on when it was activated
	var/turf/starting_turf
	///Delay between process() calls. Cannot be higher than MAX_SPEED. Smaller value represents faster movement.
	var/move_speed = 1
	///Reference to a potentially attached object, either a target, trainer toolbox, or syndicate toolbox
	var/obj/attached_item
	///Helper for timing attacks when emagged
	COOLDOWN_DECLARE(attack_cooldown)
	///Cooldown macro to control how fast this will move. Used in process()
	COOLDOWN_DECLARE(move_cooldown)

/**
 * Called on qdel(), so we don't want a cool explosion to happen
 */
/obj/structure/training_machine/Destroy()
	remove_attached_item()
	return ..()

/**
 * Called on a normal destruction, so we have a cool explosion and toss whatever's attached
 */
/obj/structure/training_machine/atom_destruction(damage_flag)
	remove_attached_item(throwing = TRUE)
	explosion(src, light_impact_range = 1, flash_range = 2)
	return ..()

/obj/structure/training_machine/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/training_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrainingMachine", name)
		ui.open()

/**
 * Send data to the UI
 *
 * Include's the machine's movement range, speed, and whether or not it's active
 */
/obj/structure/training_machine/ui_data(mob/user)
	var/list/data = list()
	data["range"] = range
	data["movespeed"] = move_speed
	data["moving"] = moving
	return data

/**
 * Control the attached variables.
 *
 * Will not respond if moving and emagged, so once you set it to go it can't be stopped!
 */
/obj/structure/training_machine/ui_act(action, params)
	. = ..()
	if(.)
		return
	if (moving && obj_flags & EMAGGED)
		visible_message(span_warning("The [src]'s control panel fizzles slightly."))
		return
	switch(action)
		if("toggle")
			toggle()
			. = TRUE
		if("range")
			var/range_input = params["range"]
			range = clamp(range_input, MIN_RANGE, MAX_RANGE)
			. = TRUE
		if("movespeed")
			var/range_input = params["movespeed"]
			move_speed = clamp(range_input, MIN_SPEED, MAX_SPEED)
			. = TRUE

/obj/structure/training_machine/attack_hand(mob/user, list/modifiers)
	ui_interact(user)

/**
 * Called when the machien is attacked by something
 *
 * Meant for attaching an item to the machine, should only be a training toolbox or target. If emagged, the
 * machine will gain an auto-attached syndicate toolbox, so in that case we shouldn't be able to swap it out
 */
/obj/structure/training_machine/attackby(obj/item/target, mob/living/user)
	if (user.combat_mode)
		return ..()
	if (!istype(target, /obj/item/training_toolbox) && !istype(target, /obj/item/target))
		return ..()
	if (obj_flags & EMAGGED)
		to_chat(user, span_warning("The toolbox is somehow stuck on! It won't budge!"))
		return
	attach_item(target)
	to_chat(user, span_notice("You attach \the [attached_item] to the training device."))
	playsound(src, "rustle", 50, TRUE)

/**
 * Attach an item to the machine
 *
 * This proc technically works with any obj. Currently is only used for objects of type item/target and item/training_toolbox
 * Will make the attached item appear visually on the machine
 * Arguments
 * * target - The object to attach
 */
/obj/structure/training_machine/proc/attach_item(obj/target)
	remove_attached_item()
	attached_item = target
	attached_item.forceMove(src)
	attached_item.vis_flags |= VIS_INHERIT_ID
	vis_contents += attached_item
	RegisterSignal(attached_item, COMSIG_PARENT_QDELETING, .proc/on_attached_delete)
	handle_density()

/**
 * Called when the attached item is deleted.
 *
 * Cleans up behavior for when the attached item is deleted or removed.
 */
/obj/structure/training_machine/proc/on_attached_delete()
	SIGNAL_HANDLER
	UnregisterSignal(attached_item, COMSIG_PARENT_QDELETING)
	vis_contents -= attached_item
	attached_item = null
	handle_density()

/**
 * Remove the attached item from the machine
 *
 * Called when a user removes the item by hand or by swapping it out with another, when the machine breaks, or
 * when the machine is emagged.
 * Arguments
 * * user - The peson , if any, removing the attached item
 * * throwing - If we should make the item fly off the machine
 */
/obj/structure/training_machine/proc/remove_attached_item(mob/user, throwing = FALSE)
	if (!attached_item)
		return
	if (istype(attached_item, /obj/item/storage/toolbox/syndicate))
		UnregisterSignal(attached_item, COMSIG_PARENT_QDELETING)
		qdel(attached_item)
	else if (user)
		INVOKE_ASYNC(user, /mob/proc/put_in_hands, attached_item)
	else
		attached_item.forceMove(drop_location())
	if (throwing && !QDELETED(attached_item)) //Fun little thing where we throw out the old attached item when emagged
		//We do a QDELETED check here because we don't want to throw the syndi toolbox, if it exists
		var/destination = get_edge_target_turf(get_turf(src), pick(GLOB.alldirs))
		attached_item.throw_at(destination, 4, 1)
	on_attached_delete()

/obj/structure/training_machine/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, FLOOR_OKAY))
		return
	if(has_buckled_mobs())
		user_unbuckle_mob(buckled_mobs[1], user)
		return
	if (!attached_item)
		return
	if (obj_flags & EMAGGED)
		to_chat(user, span_warning("The toolbox is somehow stuck on! It won't budge!"))
		return
	to_chat(user, span_notice("You remove \the [attached_item] from the training device."))
	remove_attached_item(user)
	playsound(src, "rustle", 50, TRUE)

/**
 * Toggle the machine's movement
 */
/obj/structure/training_machine/proc/toggle()
	if (moving)
		stop_moving()
	else
		start_moving()

/**
 * Stop the machine's movement
 *
 * Will call STOP_PROCESSING, play a sound, and say an appropriate message
 * Arguments
 * * Message - the message the machine says when stopping
 */
/obj/structure/training_machine/proc/stop_moving(message = "Ending training simulation.")
	moving = FALSE
	starting_turf = null
	say(message)
	playsound(src,'sound/machines/synth_no.ogg',50,FALSE)
	STOP_PROCESSING(SSfastprocess, src)

/**
 * Start the machine's movement
 *
 * Says a message, plays a sound, then starts processing
 */
/obj/structure/training_machine/proc/start_moving()
	moving = TRUE
	starting_turf = get_turf(src)
	say("Beginning training simulation.")
	playsound(src,'sound/machines/triple_beep.ogg',50,FALSE)
	START_PROCESSING(SSfastprocess, src)

/**
 * Main movement method for the machine
 *
 * Handles movement using SSFastProcess. Moves randomly, point-to-point, in an area centered around wherever it started.
 * Will only move if the move_cooldown cooldown macro is finished.
 * If it can't find a place to go, it will stop moving.
 */
/obj/structure/training_machine/process()
	if(!COOLDOWN_FINISHED(src, move_cooldown))
		return
	var/turf/current_turf = get_turf(src)
	if (!moving || !starting_turf || isspaceturf(current_turf))
		stop_moving()
		return
	if (current_turf == target_position) //We've reached our target turf, now find a new one
		target_position = null
	if (!target_position)
		target_position = find_target_position()
		if (!target_position)
			stop_moving("ERROR! Cannot calculate suitable movement path.")
	var/turf/nextStep = get_step_towards(src, target_position)
	if (!Move(nextStep, get_dir(src, nextStep)))
		target_position = null //We couldn't move towards the target turf, so find a new target turf
	try_attack()
	COOLDOWN_START(src, move_cooldown, max(MAX_SPEED - move_speed, 1))

/**
 * Find a suitable turf to move towards
 */
/obj/structure/training_machine/proc/find_target_position()
	var/list/turfs = list()
	for(var/turf/potential_turf in view(range, starting_turf))
		if (potential_turf.is_blocked_turf() || potential_turf == target_position)
			continue
		turfs += potential_turf
	if (!length(turfs))
		return
	return pick(turfs)

/**
 * Try to attack a nearby mob
 *
 * Called whenever the machine moves, this will look for mobs adjacent to the machine to attack.
 * Will attack with either a training toolbox (if attached), or a much more deadly syndicate toolbox (if emagged).
 * A cooldown macro (attack_cooldown) ensures it doesn't attack too quickly
 */
/obj/structure/training_machine/proc/try_attack()
	if (!attached_item || istype(attached_item, /obj/item/target))
		return
	if (!COOLDOWN_FINISHED(src, attack_cooldown))
		return
	var/list/targets
	for(var/mob/living/carbon/target in oview(1, get_turf(src))) //Find adjacent target
		if (target.stat == CONSCIOUS && target.Adjacent(src))
			LAZYADD(targets, target)
	var/mob/living/carbon/target = pick(targets)
	if (!target)
		return
	do_attack_animation(target, null, attached_item)
	if (obj_flags & EMAGGED)
		target.apply_damage(attached_item.force, BRUTE, BODY_ZONE_CHEST)
	playsound(src, 'sound/weapons/smash.ogg', 15, TRUE)
	COOLDOWN_START(src, attack_cooldown, rand(MIN_ATTACK_DELAY, MAX_ATTACK_DELAY))

/**
 * Make sure the machine can't be walked through if something is attached
 */
/obj/structure/training_machine/proc/handle_density()
	if(length(buckled_mobs) || attached_item)
		set_density(TRUE)
	else
		set_density(FALSE)

/obj/structure/training_machine/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if (istype(attached_item, /obj/item/target))
		return FALSE

/obj/structure/training_machine/post_buckle_mob()
	handle_density()
	return ..()

/obj/structure/training_machine/post_unbuckle_mob()
	handle_density()
	return ..()

/**
 * Emagging causes a deadly, unremovable syndicate toolbox to be attached to the machine
 */
/obj/structure/training_machine/emag_act(mob/user)
	. = ..()
	if (obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	remove_attached_item(throwing = TRUE) //Toss out the old attached item!
	attach_item(new /obj/item/storage/toolbox/syndicate(src))
	to_chat(user, span_warning("You override the training machine's safety protocols, and activate its realistic combat feature. A toolbox pops out of a slot on the top."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	add_overlay("evil_trainer")

/obj/structure/training_machine/examine(mob/user)
	. = ..()
	var/has_buckled_mob = has_buckled_mobs()
	if(has_buckled_mob)
		. += span_notice("<b>Alt-Click to unbuckle \the [buckled_mobs[1]]</b>")
	if (obj_flags & EMAGGED)
		. += span_warning("It has a dangerous-looking toolbox attached to it, and the control panel is smoking sightly...")
	else if (!has_buckled_mob && attached_item) //Can't removed the syndicate toolbox!
		. += span_notice("<b>Alt-Click to remove \the [attached_item]</b>")
	. += span_notice("<b>Click to open control interface.</b>")

/**
 * Device that simply counts the number of times you've hit a mob or target with. Looks like a toolbox but isn't.
 *
 * Also has a 'Lap' function for keeping track of hits made at a certain point. Also, looks kinda like his grace for laughs and pranks.
 */
/obj/item/training_toolbox
	name = "Training Toolbox"
	desc = "AURUMILL-Brand Baby's First Training Toolbox. A digital display on the back keeps track of hits made by the user. Second toolbox sold separately!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "gold"
	inhand_icon_state = "toolbox_gold"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	///Total number of hits made against a valid target
	var/total_hits = 0
	///Number of hits made since the Lap button (alt-click) was last pushed
	var/lap_hits = 0

/obj/item/training_toolbox/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if (!proximity || target == user || !user.combat_mode)
		return
	if (check_hit(target))
		user.changeNext_move(CLICK_CD_MELEE)

/**
 * Check if we should increment the hit counter
 *
 * Increments the 'hit' counter if the target we're attacking is a mob, target, or training machine with an attached item.
 * Will beep every 9 hits, as 9 hits usually signifies a KO with a normal toolbox
 * Arguments
 * * target - the atom we're hitting
 */
/obj/item/training_toolbox/proc/check_hit(atom/target)
	var/target_is_machine = istype(target, /obj/structure/training_machine)
	if (!ismob(target) && !istype(target, /obj/item/target) && !target_is_machine)
		return FALSE
	if (target_is_machine)
		var/obj/structure/training_machine/trainer = target
		if (!trainer.attached_item)
			return FALSE
	total_hits++
	lap_hits++
	playsound(src,'sound/weapons/smash.ogg',50,FALSE)
	if (lap_hits % HITS_TO_KILL == 0)
		playsound(src,'sound/machines/twobeep.ogg',25,FALSE)
	return TRUE

/obj/item/training_toolbox/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if (!.)
		check_hit(hit_atom)

/obj/item/training_toolbox/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	to_chat(user, span_notice("You push the 'Lap' button on the toolbox's display."))
	lap_hits = initial(lap_hits)

/obj/item/training_toolbox/examine(mob/user)
	. = ..()
	if(!in_range(src, user) && !isobserver(user))
		. += span_notice("You can see a display on the back. You'll need to get closer to read it, though.")
		return
	. += span_notice("A display on the back reads:")
	. += span_notice("Total Hits: <b>[total_hits]</b>")
	if (lap_hits != total_hits)
		. += span_notice("Current Lap: <b>[lap_hits]</b>")
	. += span_notice("<b>Alt-Click to 'Lap' the hit counter.</b>")

#undef MIN_RANGE
#undef MIN_SPEED
#undef MAX_RANGE
#undef MAX_SPEED
#undef HITS_TO_KILL
#undef MIN_ATTACK_DELAY
#undef MAX_ATTACK_DELAY
