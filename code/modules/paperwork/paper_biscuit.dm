/obj/item/folder/biscuit
	name = "A biscuit card"
	desc = "An biscuit card"
	icon_state = "paperbiscuit"
	bg_color = "#b88f3d"
	var/cracked = FALSE //Is biscuit cracked open or not?

/obj/item/folder/biscuit/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] tries to eat the 'biscuit'! [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/folder/biscuit/update_overlays()
	. = ..()
	if(contents.len && cracked) //Shows overlay only when it has content and is cracked open
		. += "paperbiscuit_paper"
		. -= "folder_paper"

/obj/item/folder/biscuit/examine()
	. = ..()
	if(length(contents))
		. += span_notice("To reach contents you need to crack it open.")

/obj/item/folder/biscuit/proc/crack_check(mob/user)
    if (cracked)
        return TRUE
    balloon_alert(user, "need to crack it open first!")
    return FALSE

//All next is done so you can't reach contents, or put any new contents when its not cracked open
/obj/item/folder/biscuit/remove_item(obj/item/Item, mob/user)
    if (crack_check(user))
        return ..()

/obj/item/folder/biscuit/attack_hand(mob/user, list/modifiers)
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		if (crack_check(user))
			return ..()
	else ..()

/obj/item/folder/biscuit/attackby(obj/item/weapon, mob/user, params)
	if(is_type_in_typecache(weapon, folder_insertables))
		if (crack_check(user))
			return ..()
	else ..()

/obj/item/folder/biscuit/attack_self(mob/user)
	add_fingerprint(usr)
	if (!cracked)
		if (tgui_alert(user, "Do you want to crack it open?", "Biscuit card", list("Yes", "No")) == "Yes")
			cracked = TRUE
			playsound(get_turf(user), 'sound/effects/wounds/crack1.ogg', 70, TRUE)
			icon_state = "[icon_state]_cracked"
			update_appearance()
		return
	if (cracked)
		ui_interact(user)
	return

/obj/item/folder/biscuit/confidental
	name = "A biscuit card"
	desc = "An confidental biscuit card. Has a CentCom stamp on it with NT logo."
	icon_state = "paperbiscuit_secret"

/obj/item/folder/biscuit/confidental/spare_id_safe_code
	name = "A spare ID safe code biscuit card"
	desc = "An biscuit card containing confidental spare ID safe code. Has a CentCom stamp on it with NT logo."

/obj/item/folder/biscuit/confidental/spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code(src)
	update_overlays()

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code
	name = "A spare emergency ID safe code biscuit card"
	desc = "An biscuit card containing <i>not so confidental</i> emergency spare ID safe code. Has a CentCom stamp on it with NT logo."

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code(src)
	update_overlays()
