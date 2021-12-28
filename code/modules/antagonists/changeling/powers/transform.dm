/datum/action/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed. Costs 5 chemicals."
	button_icon_state = "transform"
	chemical_cost = 5
	dna_cost = 0
	req_dna = 1
	req_human = 1

/obj/item/clothing/glasses/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/glasses/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/under/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/under/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/suit/changeling
	name = "flesh"
	allowed = list(/obj/item/changeling)
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/suit/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/head/changeling
	name = "flesh"
	icon_state = null
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/head/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/shoes/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/shoes/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/gloves/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/gloves/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/mask/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/mask/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/changeling
	name = "flesh"
	slot_flags = ALL
	allowed = list(/obj/item/changeling)
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/changeling/id
	slot_flags = ITEM_SLOT_ID
	/// Cached flat icon of the ID
	var/icon/cached_flat_icon
	/// HUD job icon of the ID
	var/hud_icon

/obj/item/changeling/id/equipped(mob/user, slot, initial)
	. = ..()
	if(hud_icon)
		var/image/holder = user.hud_list[ID_HUD]
		var/icon/I = icon(user.icon, user.icon_state, user.dir)
		holder.pixel_y = I.Height() - world.icon_size
		holder.icon_state = hud_icon

/**
 * Returns cached flat icon of the ID, creates one if there is not one already cached
 */
/obj/item/changeling/id/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

/obj/item/changeling/id/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]" //displays all overlays in chat

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/chosen_prof = changeling.select_dna()

	if(!chosen_prof)
		return
	..()
	changeling.transform(user, chosen_prof)
	return TRUE

/**
 * Gives a changeling a list of all possible dnas in their profiles to choose from and returns profile containing their chosen dna
 */
/datum/antagonist/changeling/proc/select_dna()
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return

	var/list/disguises = list("Drop Flesh Disguise" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_drop"))
	for(var/datum/changeling_profile/current_profile as anything in stored_profiles)
		var/datum/icon_snapshot/snap = current_profile.profile_snapshot
		var/image/disguise_image = image(icon = snap.icon, icon_state = snap.icon_state)
		disguise_image.overlays = snap.overlays
		disguises[current_profile.name] = disguise_image

	var/chosen_name = show_radial_menu(user, user, disguises, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 40, require_near = TRUE, tooltips = TRUE)
	if(!chosen_name)
		return

	if(chosen_name == "Drop Flesh Disguise")
		for(var/slot in slot2type)
			if(istype(user.vars[slot], slot2type[slot]))
				qdel(user.vars[slot])
		for(var/i in user.all_scars)
			var/datum/scar/iter_scar = i
			if(iter_scar.fake)
				qdel(iter_scar)
		return

	var/datum/changeling_profile/prof = get_dna(chosen_name)
	return prof

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The carbon mob interacting with the menu
 */
/datum/antagonist/changeling/proc/check_menu(mob/living/carbon/user)
	if(!istype(user))
		return FALSE
	var/datum/antagonist/changeling/changeling_datum = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling_datum)
		return FALSE
	return TRUE
