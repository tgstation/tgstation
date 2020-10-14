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
  * Can have a mob buckled on or a obj/item/target attached. Uses timers to move, which is necessary because it's movespeed
  * needs to both be variable and potentially faster than SSFastProcess's tick speed, so hey this is what we got. 
  * As a note, there generally shouldn't be too many timers in existance at a time, so there will only ever be
  * one or two of these on the station.
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
	///How fast the machine moves. Cannot be higher than MAX_SPEED
	var/move_speed = 1
	///Reference to a potentially attached object, either a target, trainer toolbox, or syndicate toolbox
	var/obj/item/attached_item
	///Time between attacks when emagged
	var/attack_cooldown = 50
	///Helper for timing attacks when emagged
	var/last_attack_time = 0

/obj/structure/training_machine/Destroy()
	remove_attached_item(throwing = TRUE)
	explosion(src, 0,0,1, flame_range = 2)
	return ..()

/obj/structure/training_machine/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/training_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrainingMachine", name)
		ui.open()

/obj/structure/training_machine/ui_data(mob/user)
	var/list/data = list()
	data["range"] = range
	data["movespeed"] = move_speed
	data["moving"] = moving
	return data

/obj/structure/training_machine/ui_act(action, params)
	if(..())
		return
	if (moving && obj_flags & EMAGGED)
		visible_message("<span class='warning'>The [src]'s control panel fizzles slightly.</span>")
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

/obj/structure/training_machine/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/training_machine/attackby(obj/item/target, mob/user)
	. = ..()
	if (user.a_intent == INTENT_HARM)
		return
	if (!istype(target, /obj/item/training_toolbox) && !istype(target, /obj/item/target))
		return
	if (length(buckled_mobs))
		return
	if (obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The toolbox is somehow stuck on! It won't budge!</span>")
		return
	attach_item(target)
	to_chat(user, "<span class='notice'>You attach \the [attached_item] to the training device.</span>")
	playsound(src, "rustle", 50, TRUE)

/obj/structure/training_machine/proc/attach_item(target)
	remove_attached_item()
	attached_item = target
	attached_item.forceMove(src)
	attached_item.vis_flags |= VIS_INHERIT_ID
	vis_contents += attached_item
	handle_density()

/obj/structure/training_machine/proc/remove_attached_item(mob/user, throwing = FALSE)
	if (!attached_item)
		return
	vis_contents.Cut()
	if (istype(attached_item, /obj/item/storage/toolbox/syndicate))
		qdel(attached_item)
	else if (user)
		user.put_in_hands(attached_item)
	else
		attached_item.forceMove(drop_location())
	if (throwing && !QDELETED(attached_item)) //Fun little thing where we throw out the old attached item when emagged
		//We do a QDELETED check here because we don't want to throw the syndi toolbox, if it exists
		var/destination = get_edge_target_turf(get_turf(src), pick(GLOB.alldirs))
		attached_item.throw_at(destination, 4, 1)
	attached_item = null
	handle_density()

/obj/structure/training_machine/AltClick(mob/user)
	. = ..()
	if (!attached_item)
		return
	if (obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The toolbox is somehow stuck on! It won't budge!</span>")
		return
	to_chat(user, "<span class='notice'>You remove \the [attached_item] from the training device.</span>")
	remove_attached_item(user)
	playsound(src, "rustle", 50, TRUE)

/obj/structure/training_machine/proc/toggle()
	if (moving)
		moving = FALSE
	else
		start_moving()

/obj/structure/training_machine/proc/stop_moving(message = "Ending training simulation.")
	moving = FALSE
	starting_turf = null
	say(message)
	playsound(src,'sound/machines/synth_no.ogg',50,FALSE)

/obj/structure/training_machine/proc/start_moving()
	moving = TRUE
	starting_turf = get_turf(src)
	say("Beginning training simulation.")
	playsound(src,'sound/machines/triple_beep.ogg',50,FALSE)
	do_movement()

/obj/structure/training_machine/proc/do_movement()
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
	addtimer(CALLBACK(src, .proc/do_movement), max(MAX_SPEED - move_speed, 1)) // We want to ensure this is never <=0

/obj/structure/training_machine/proc/find_target_position()
	var/list/turfs = list()
	for(var/turf/potential_turf in view(range, starting_turf))
		if (potential_turf.is_blocked_turf() || potential_turf == target_position)
			continue
		turfs += potential_turf
	if (!length(turfs))
		return
	return pick(turfs)

/obj/structure/training_machine/proc/try_attack()
	if (!attached_item || istype(attached_item, /obj/item/target))
		return
	if (world.time < last_attack_time + attack_cooldown)
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
	playsound(src, 'sound/weapons/smash.ogg', 25, TRUE)
	last_attack_time = world.time
	attack_cooldown = rand(MIN_ATTACK_DELAY, MAX_ATTACK_DELAY)

/obj/structure/training_machine/proc/handle_density()
	if(length(buckled_mobs) || attached_item)
		density = TRUE
	else
		density = FALSE

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

/obj/structure/training_machine/emag_act(mob/user)
	. = ..()
	if (obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	remove_attached_item(throwing = TRUE) //Toss out the old attached item!
	attach_item(new /obj/item/storage/toolbox/syndicate(src))
	to_chat(user, "<span class='warning'>You override the training machine's safety protocols, and activate its realistic combat feature. A toolbox pops out of a slot on the top.</span>")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	add_overlay("evil_trainer")

/obj/structure/training_machine/examine(mob/user)
	. = ..()
	if (obj_flags & EMAGGED)
		. += "<span class='warning'>It has a dangerous-looking toolbox attached to it, and the control panel is smoking sightly...</span>"
	else if (attached_item) //Can't removed the syndicate toolbox!
		. += "<span class='notice'><b>Alt-Click to remove \the [attached_item]</b></span>"
	. += "<span class='notice'><b>Click to open control interface.</b></span>"

/**
  * Device that simply counts the number of times you've hit a mob or target with. Looks like a toolbox but isn't.
  *
  * Also has a 'Lap' function for keeping track of hits made at a certain point. Also, looks kinda like his grace for laughs and pranks.
  */
/obj/item/training_toolbox
	name = "Training Toolbox"
	desc = "AURUMILL-Brand Baby's First Training Toolbox. A digital display on the back keeps track of hits made by the user. Second toolbox sold seperately!"
	icon_state = "his_grace_ascended"
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

/obj/item/training_toolbox/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!proximity || target == user)
		return
	if (check_hit(target))
		user.changeNext_move(CLICK_CD_MELEE)

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
	..()
	check_hit(hit_atom)

/obj/item/training_toolbox/AltClick(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You push the 'Lap' button on the toolbox's display.</span>")
	lap_hits = initial(lap_hits)

/obj/item/training_toolbox/examine(mob/user)
	. = ..()
	if(!in_range(src, user) && !isobserver(user))
		. += "<span class='notice'>You can see a display on the back. You'll need to get closer to read it, though.</span>"
		return
	. += "<span class='notice'>A display on the back reads:</span>"
	. += "<span class='notice'>Total Hits: <b>[total_hits]</b></span>"
	if (lap_hits != total_hits)
		. += "<span class='notice'>Current Lap: <b>[lap_hits]</b></span>"
	. += "<span class='notice'><b>Alt-Click to 'Lap' the hit counter.</b></span>"

#undef MIN_RANGE
#undef MIN_SPEED
#undef MAX_RANGE
#undef MAX_SPEED
#undef HITS_TO_KILL
#undef MIN_ATTACK_DELAY
#undef MAX_ATTACK_DELAY
