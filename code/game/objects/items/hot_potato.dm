//CREATOR'S NOTE: DO NOT FUCKING GIVE THIS TO BOTANY!
/obj/item/hot_potato
	name = "hot potato"
	desc = "A label on the side of this potato reads \"Product of Donk Co. Service Wing. Activate far away from populated areas. Device will only attach to sapient creatures.\" <span class='boldnotice'>You can attack anyone with it to force it on them instead of yourself!</span>"
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "potato"
	item_flags = NOBLUDGEON
	force = 0
	var/icon_off = "potato"
	var/icon_on = "potato_active"
	var/detonation_timerid
	var/activation_time = 0
	var/timer = 600 //deciseconds
	var/show_timer = FALSE
	var/reusable = FALSE //absolute madman
	var/sticky = TRUE
	var/forceful_attachment = TRUE
	var/stimulant = TRUE
	var/detonate_explosion = TRUE
	var/detonate_dev_range = 0
	var/detonate_heavy_range = 0
	var/detonate_light_range = 2
	var/detonate_flash_range = 5
	var/detonate_fire_range = 5

	var/active = FALSE

	var/color_val = FALSE

	var/datum/weakref/current

/obj/item/hot_potato/Destroy()
	if(active)
		deactivate()
	return ..()

/obj/item/hot_potato/proc/colorize(mob/target)
	//Clear color from old target
	if(current)
		var/mob/M = current.resolve()
		if(istype(M))
			M.remove_atom_colour(FIXED_COLOUR_PRIORITY)
	//Give to new target
	current = null
	//Swap colors
	color_val = !color_val
	if(istype(target))
		current = WEAKREF(target)
		target.add_atom_colour(color_val? "#ffff00" : "#00ffff", FIXED_COLOUR_PRIORITY)

/obj/item/hot_potato/proc/detonate()
	var/atom/location = loc
	location.visible_message(span_userdanger("[src] [detonate_explosion? "explodes" : "activates"]!"), span_userdanger("[src] activates! You've ran out of time!"))
	if(detonate_explosion)
		explosion(src, detonate_dev_range, detonate_heavy_range, detonate_light_range, detonate_fire_range, detonate_flash_range)
	deactivate()
	if(!reusable)
		var/mob/M = loc
		if(istype(M))
			M.dropItemToGround(src, TRUE)
		qdel(src)

/obj/item/hot_potato/attack_self(mob/user)
	if(activate(timer, user))
		user.visible_message(span_boldwarning("[user] squeezes [src], which promptly starts to flash red-hot colors!"), span_boldwarning("You squeeze [src], activating its countdown and attachment mechanism!"),
		span_boldwarning("You hear a mechanical click and a loud beeping!"))
		return
	return ..()

/obj/item/hot_potato/process()
	if(!isliving(loc))
		return
	var/mob/living/L = loc
	colorize(L)
	if(!stimulant)
		return
	L.SetStun(0)
	L.SetKnockdown(0)
	L.SetSleeping(0)
	L.SetImmobilized(0)
	L.SetParalyzed(0)
	L.SetUnconscious(0)
	L.reagents.add_reagent(/datum/reagent/medicine/muscle_stimulant, clamp(5 - L.reagents.get_reagent_amount(/datum/reagent/medicine/muscle_stimulant), 0, 5)) //If you don't have legs or get bola'd, tough luck!


/obj/item/hot_potato/examine(mob/user)
	. = ..()
	if(active)
		. += span_warning("[src] is flashing red-hot! You should probably get rid of it!")
		if(show_timer)
			. += span_warning("[src]'s timer looks to be at [DisplayTimeText(activation_time - world.time)]!")

/obj/item/hot_potato/equipped(mob/user)
	. = ..()
	if(active)
		to_chat(user, span_userdanger("You have a really bad feeling about [src]!"))

/obj/item/hot_potato/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(.)
		return .

	return force_onto(target_mob, user)

/obj/item/hot_potato/proc/force_onto(mob/living/victim, mob/user)
	if(!istype(victim) || user != loc || victim == user)
		return FALSE
	if(!victim.client)
		to_chat(user, span_boldwarning("[src] refuses to attach to a non-sapient creature!"))
	if(victim.stat != CONSCIOUS || !victim.usable_legs)
		to_chat(user, span_boldwarning("[src] refuses to attach to someone incapable of using it!"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	. = FALSE
	if(!victim.put_in_hands(src))
		if(forceful_attachment)
			victim.dropItemToGround(victim.get_inactive_held_item())
			if(!victim.put_in_hands(src))
				victim.dropItemToGround(victim.get_active_held_item())
				if(victim.put_in_hands(src))
					. = TRUE
			else
				. = TRUE
	else
		. = TRUE
	if(.)
		log_combat(user, victim, "forced a hot potato with explosive variables ([detonate_explosion]-[detonate_dev_range]/[detonate_heavy_range]/[detonate_light_range]/[detonate_flash_range]/[detonate_fire_range]) onto")
		user.visible_message(span_userdanger("[user] forces [src] onto [victim]!"), span_userdanger("You force [src] onto [victim]!"), span_boldwarning("You hear a mechanical click and a beep."))
		colorize(null)
	else
		log_combat(user, victim, "tried to force a hot potato with explosive variables ([detonate_explosion]-[detonate_dev_range]/[detonate_heavy_range]/[detonate_light_range]/[detonate_flash_range]/[detonate_fire_range]) onto")
		user.visible_message(span_boldwarning("[user] tried to force [src] onto [victim], but it could not attach!"), span_boldwarning("You try to force [src] onto [victim], but it is unable to attach!"), span_boldwarning("You hear a mechanical click and two buzzes."))
		user.put_in_hands(src)

/obj/item/hot_potato/dropped(mob/user)
	. = ..()
	colorize(null)

/obj/item/hot_potato/proc/activate(delay, mob/user)
	if(active)
		return
	update_appearance()
	if(sticky)
		ADD_TRAIT(src, TRAIT_NODROP, HOT_POTATO_TRAIT)
	name = "primed [name]"
	activation_time = timer + world.time
	detonation_timerid = addtimer(CALLBACK(src, PROC_REF(detonate)), delay, TIMER_STOPPABLE)
	START_PROCESSING(SSfastprocess, src)
	if(user)
		log_bomber(user, "has primed a", src, "for detonation (Timer:[delay],Explosive:[detonate_explosion],Range:[detonate_dev_range]/[detonate_heavy_range]/[detonate_light_range]/[detonate_fire_range])")
	else
		log_bomber(null, null, src, "was primed for detonation (Timer:[delay],Explosive:[detonate_explosion],Range:[detonate_dev_range]/[detonate_heavy_range]/[detonate_light_range]/[detonate_fire_range])")
	active = TRUE
	if(detonate_explosion) //doesn't send a notification unless it's a genuine, exploding hot potato.
		notify_ghosts(
			"[user] has primed a Hot Potato!",
			source = src,
			header = "Hot Hot Hot!",
		)

/obj/item/hot_potato/proc/deactivate()
	update_appearance()
	name = initial(name)
	REMOVE_TRAIT(src, TRAIT_NODROP, HOT_POTATO_TRAIT)
	deltimer(detonation_timerid)
	STOP_PROCESSING(SSfastprocess, src)
	detonation_timerid = null
	colorize(null)
	active = FALSE

/obj/item/hot_potato/update_icon_state()
	icon_state = active ? icon_on : icon_off
	return ..()

/obj/item/hot_potato/syndicate
	detonate_light_range = 4
	detonate_fire_range = 5

/obj/item/hot_potato/harmless
	detonate_explosion = FALSE

/obj/item/hot_potato/harmless/toy
	desc = "A label on the side of this potato reads \"Product of Donk Co. Toys and Recreation department.\" <span class='boldnotice'>You can attack anyone with it to put it on them instead, if they have a free hand to take it!</span>"
	sticky = FALSE
	reusable = TRUE
	forceful_attachment = FALSE
	stimulant = FALSE
