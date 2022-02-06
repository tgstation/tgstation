
/mob/living/silicon/pai/proc/fold_out(force = FALSE)
	if(emitterhealth < 0)
		to_chat(src, span_warning("Your holochassis emitters are still too unstable! Please wait for automatic repair."))
		return FALSE

	if(!canholo && !force)
		to_chat(src, span_warning("Your master or another force has disabled your holochassis emitters!"))
		return FALSE

	if(holoform)
		. = fold_in(force)
		return

	if(emittersemicd)
		to_chat(src, span_warning("Error: Holochassis emitters recycling. Please try again later."))
		return FALSE

	emittersemicd = TRUE
	addtimer(CALLBACK(src, .proc/emittercool), emittercd)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)
	set_density(TRUE)
	if(istype(card.loc, /obj/item/pda))
		var/obj/item/pda/P = card.loc
		P.pai = null
		P.visible_message(span_notice("[src] ejects itself from [P]!"))
	if(isliving(card.loc))
		var/mob/living/L = card.loc
		if(!L.temporarilyRemoveItemFromInventory(card))
			to_chat(src, span_warning("Error: Unable to expand to mobile form. Chassis is restrained by some device or person."))
			return FALSE
	forceMove(get_turf(card))
	card.forceMove(src)
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = src
	set_light(0)
	icon_state = "[chassis]"
	held_state = "[chassis]"
	visible_message(span_boldnotice("[src] folds out its holochassis emitter and forms a holoshell around itself!"))
	holoform = TRUE

/mob/living/silicon/pai/proc/emittercool()
	emittersemicd = FALSE

/mob/living/silicon/pai/proc/fold_in(force = FALSE)
	emittersemicd = TRUE
	if(!force)
		addtimer(CALLBACK(src, .proc/emittercool), emittercd)
	else
		addtimer(CALLBACK(src, .proc/emittercool), emitteroverloadcd)
	icon_state = "[chassis]"
	if(!holoform)
		. = fold_out(force)
		return
	visible_message(span_notice("[src] deactivates its holochassis emitter and folds back into a compact card!"))
	stop_pulling()
	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/MH = loc
		MH.release(display_messages = FALSE)
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = card
	var/turf/T = drop_location()
	card.forceMove(T)
	forceMove(card)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)
	set_density(FALSE)
	set_light(0)
	holoform = FALSE
	set_resting(resting)

/**
 * Sets a new holochassis skin based on a pAI's choice
 */
/mob/living/silicon/pai/proc/choose_chassis()
	var/list/skins = list()
	for(var/holochassis_option in possible_chassis)
		var/image/item_image = image(icon = src.icon, icon_state = holochassis_option)
		skins += list("[holochassis_option]" = item_image)
	sort_list(skins)

	var/atom/anchor = get_atom_on_turf(src)
	var/choice = show_radial_menu(src, anchor, skins, custom_check = CALLBACK(src, .proc/check_menu, anchor), radius = 40, require_near = TRUE)
	if(!choice)
		return FALSE
	set_holochassis(choice)
	to_chat(src, span_boldnotice("You switch your holochassis projection composite to [choice]."))
	update_resting()

/**
 * Sets the holochassis skin and updates the icons
 * * Arguments:
 * * choice The animal skin that will be used for the pAI holoform
 */
/mob/living/silicon/pai/proc/set_holochassis(choice)
	if(!choice)
		return FALSE
	chassis = choice
	icon_state = "[chassis]"
	held_state = "[chassis]"

/**
 * Polymorphs the pai into a random holoform
 */
/mob/living/silicon/pai/wabbajack()
	if(length(possible_chassis) < 2)
		return
	var/holochassis = pick(possible_chassis - chassis)
	set_holochassis(holochassis)
	to_chat(src, span_boldnotice("Your holochassis form morphs into that of a [holochassis]."))

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * * Arguments:
 * * anchor The atom that is anchoring the menu
 */
/mob/living/silicon/pai/proc/check_menu(atom/anchor)
	if(incapacitated())
		return FALSE
	if(get_turf(src) != get_turf(anchor))
		return FALSE
	if(!isturf(loc) && loc != card)
		to_chat(src, span_boldwarning("You can not change your holochassis composite while not on the ground or in your card!"))
		return FALSE
	return TRUE

/mob/living/silicon/pai/update_resting()
	. = ..()
	if(resting)
		icon_state = "[chassis]_rest"
	else
		icon_state = "[chassis]"
	if(loc != card)
		visible_message(span_notice("[src] [resting? "lays down for a moment..." : "perks up from the ground."]"))

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/silicon/pai/proc/toggle_integrated_light()
	if(!light_range)
		set_light(brightness_power)
		to_chat(src, span_notice("You enable your integrated light."))
	else
		set_light(0)
		to_chat(src, span_notice("You disable your integrated light."))

/mob/living/silicon/pai/mob_try_pickup(mob/living/user, instant=FALSE)
	if(!possible_chassis[chassis])
		to_chat(user, span_warning("[src]'s current form isn't able to be carried!"))
		return FALSE
	return ..()
