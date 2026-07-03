/datum/action/changeling/transform
	name = "Transform"
	desc = "Мы принимаем облик и голос того, кого поглотили. Стоит 5 химикатов."
	button_icon_state = "transform"
	chemical_cost = 5
	dna_cost = CHANGELING_POWER_INNATE
	req_dna = 1
	req_human = TRUE

/obj/item/clothing/glasses/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/glasses/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/glasses/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/under/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/under/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/under/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/suit/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	allowed = list(/obj/item/changeling)
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/suit/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/suit/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/head/changeling
	name = "flesh"
	icon_state = null
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/head/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/head/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/shoes/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/shoes/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/shoes/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/gloves/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/gloves/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/gloves/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/clothing/mask/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/mask/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/mask/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/changeling
	name = "flesh"
	spawn_blacklisted = TRUE
	slot_flags = ALL
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && IS_CHANGELING(user))
		to_chat(user, span_notice("Вы возвращаете [declent_ru(ACCUSATIVE)] в свое тело."))
		qdel(src)
		return
	. = ..()

/obj/item/changeling/attack_paw(mob/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/item/changeling/id
	slot_flags = ITEM_SLOT_ID
	/// Cached flat icon of the ID
	var/icon/cached_flat_icon
	/// HUD job icon of the ID
	var/hud_icon

/obj/item/changeling/id/equipped(mob/user, slot, initial)
	. = ..()
	if(!hud_icon)
		return
	user.set_hud_image_state(ID_HUD, hud_icon)

/**
 * Returns cached flat icon of the ID, creates one if there is not one already cached
 */
/obj/item/changeling/id/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
		cached_flat_icon.Crop(ID_ICON_BORDERS)
	return cached_flat_icon

/obj/item/changeling/id/get_id_examine_strings(mob/user)
	. = ..()
	. += list("[icon2html(get_cached_flat_icon(), user, extra_classes = "hugeicon")]")

/obj/item/changeling/id/get_examine_icon(mob/user)
	return icon2html(get_cached_flat_icon(), user)

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	var/datum/changeling_profile/chosen_prof = changeling.select_dna()

	if(!chosen_prof)
		return
	..()
	changeling.transform(user, chosen_prof)
	SEND_SIGNAL(user, COMSIG_CHANGELING_TRANSFORM)
	return TRUE

/**
 * Gives a changeling a list of all possible dnas in their profiles to choose from and returns profile containing their chosen dna
 */
/datum/antagonist/changeling/proc/select_dna()
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return

	var/list/disguises = list("Сбросить маскировку из плоти" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_drop"))
	for(var/datum/changeling_profile/current_profile as anything in stored_profiles)
		var/datum/icon_snapshot/snap = current_profile.profile_snapshot
		var/image/disguise_image = image(icon = snap.icon, icon_state = snap.icon_state)
		disguise_image.overlays = snap.overlays
		disguises[current_profile.name] = disguise_image

	var/chosen_name = show_radial_menu(user, user, disguises, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 40, require_near = TRUE, tooltips = TRUE)
	if(!chosen_name)
		return

	if(chosen_name == "Сбросить маскировку из плоти")
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
	var/datum/antagonist/changeling/changeling_datum = IS_CHANGELING(user)
	if(!changeling_datum)
		return FALSE
	return TRUE
