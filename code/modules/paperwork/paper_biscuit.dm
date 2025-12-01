/obj/item/folder/biscuit
	name = "biscuit card"
	desc = "A biscuit card. On the back, <b>DO NOT DIGEST</b> is printed in large lettering."
	icon_state = "paperbiscuit"
	bg_color = "#ffffff"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 130
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	contents_hidden = TRUE
	paper_overlay_state = "paperbiscuit_paper"
	folder_type_name = "biscuit"
	/// Is biscuit cracked open or not?
	var/cracked = FALSE
	/// The paper slip inside, if there is one
	var/obj/item/paper/paperslip/contained_slip

/obj/item/folder/biscuit/Initialize(mapload)
	. = ..()
	if(ispath(contained_slip, /obj/item/paper/paperslip))
		contained_slip = new contained_slip(src)

/obj/item/folder/biscuit/Destroy()
	if(isdatum(contained_slip))
		QDEL_NULL(contained_slip)
	return ..()

/obj/item/folder/biscuit/Exited(atom/movable/gone, direction)
	. = ..()
	if(contained_slip == gone)
		contained_slip = null

/obj/item/folder/biscuit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isnull(contained_slip) && istype(arrived, /obj/item/paper/paperslip))
		contained_slip = arrived

/obj/item/folder/biscuit/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] tries to eat [src]! [user.p_theyre()] trying to commit suicide!"))
	playsound(get_turf(user), 'sound/effects/wounds/crackandbleed.ogg', 40, TRUE) //Don't eat plastic cards kids, they get really sharp if you chew on them.
	return BRUTELOSS

/obj/item/folder/biscuit/get_paper_overlay()
	if(!cracked)
		return null
	return ..()

///Checks if the biscuit has been already cracked.
/obj/item/folder/biscuit/proc/crack_check(mob/user)
	if (cracked)
		return TRUE
	balloon_alert(user, "open first!")
	return FALSE

/obj/item/folder/biscuit/examine()
	. = ..()
	if(cracked)
		. += span_notice("It's been cracked open.")
	else
		. += span_notice("You'll need to crack it open to access its contents.")
		if(contained_slip)
			. += "This one contains [contained_slip.name]."

/obj/item/folder/biscuit/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if((held_item == src) && !cracked)
		context[SCREENTIP_CONTEXT_LMB] = "Crack open"
		return CONTEXTUAL_SCREENTIP_SET

//The next few checks are done to prevent you from reaching the contents or putting anything inside when it's not cracked open
/obj/item/folder/biscuit/remove_item(obj/item/item, mob/user)
	if (!crack_check(user))
		return

	return ..()

/obj/item/folder/biscuit/attack_hand(mob/user, list/modifiers)
	if (LAZYACCESS(modifiers, RIGHT_CLICK) && !crack_check(user))
		return

	return ..()

/obj/item/folder/biscuit/insertables_act(mob/living/user, obj/item/tool)
	if(!crack_check(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/folder/biscuit/interact_with_insertables(atom/interacting_with, mob/living/user)
	if(!crack_check(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/folder/biscuit/attack_self(mob/user)
	add_fingerprint(user)
	if (!cracked)
		if (tgui_alert(user, "Do you want to crack it open?", "Biscuit Cracking", list("Yes", "No")) != "Yes")
			return
		cracked = TRUE
		contents_hidden = FALSE
		playsound(get_turf(user), 'sound/effects/wounds/crack1.ogg', 60)
		icon_state = "[icon_state]_cracked"
		update_appearance()

	ui_interact(user)

//Corporate "confidential" biscuit cards
/obj/item/folder/biscuit/confidential
	name = "confidential biscuit card"
	desc = "A confidential biscuit card. The tasteful blue color and NT logo on the front makes it look a little like a chocolate bar. \
		On the back, <b>DO NOT DIGEST</b> is printed in large lettering."
	icon_state = "paperbiscuit_secret"
	bg_color = "#355e9f"

/obj/item/folder/biscuit/confidential/spare_id_safe_code
	name = "spare ID safe code biscuit card"
	contained_slip = /obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code

/obj/item/folder/biscuit/confidential/emergency_spare_id_safe_code
	name = "spare emergency ID safe code biscuit card"
	contained_slip = /obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code

//Biscuits which start open. Used for crafting, printing, and such
/obj/item/folder/biscuit/unsealed
	name = "biscuit card"
	desc = "A biscuit card. On the back, <b>DO NOT DIGEST</b> is printed in large lettering."
	icon_state = "paperbiscuit_cracked"
	contents_hidden = FALSE
	cracked = TRUE
	///Was the biscuit already sealed by players? Prevents re-sealing after use
	var/has_been_sealed = FALSE
	///What is the sprite for when it's sealed? It starts unsealed, so needs a sprite for when it's sealed.
	var/sealed_icon = "paperbiscuit"

/obj/item/folder/biscuit/unsealed/examine()
	. = ..()
	if(!has_been_sealed)
		. += span_notice("This one could be sealed <b>in hand</b>. Once sealed, the contents are inaccessible until cracked open again - but once opened this is irreversible.")

/obj/item/folder/biscuit/unsealed/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if((held_item == src) && !has_been_sealed)
		context[SCREENTIP_CONTEXT_LMB] = "Seal"
		return CONTEXTUAL_SCREENTIP_SET

//Asks if you want to seal the biscuit, after you do that it behaves like a normal paper biscuit.
/obj/item/folder/biscuit/unsealed/attack_self(mob/user)
	add_fingerprint(user)
	if(!cracked)
		return ..()
	if(tgui_alert(user, "Do you want to seal it? This can only be done once.", "Biscuit Sealing", list("Yes", "No")) != "Yes")
		return
	cracked = FALSE
	has_been_sealed = TRUE
	contents_hidden = TRUE
	playsound(get_turf(user), 'sound/items/duct_tape/duct_tape_snap.ogg', 60)
	icon_state = "[sealed_icon]"
	update_appearance()

/obj/item/folder/biscuit/unsealed/confidential
	name = "confidential biscuit card"
	desc = "A confidential biscuit card. The tasteful blue color and NT logo on the front makes it look a little like a chocolate bar. On the back, <b>DO NOT DIGEST</b> is printed in large lettering."
	icon_state = "paperbiscuit_secret_cracked"
	bg_color = "#355e9f"
	sealed_icon = "paperbiscuit_secret"
