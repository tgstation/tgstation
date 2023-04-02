/obj/item/folder/biscuit
	name = "\proper biscuit card"
	desc = "An biscuit card. Has label which says <b>DO NOT DIGEST</b>."
	icon_state = "paperbiscuit"
	bg_color = "#ffffff"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 130
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	/// Is biscuit cracked open or not?
	var/cracked = FALSE

/obj/item/folder/biscuit/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] tries to eat the paper biscuit! [user.p_theyre()] trying to commit suicide!"))
	playsound(get_turf(user), 'sound/effects/wounds/crackandbleed.ogg', 40, TRUE) //Don't eat plastic cards kids, they get really sharp if you chew on them.
	return BRUTELOSS

/obj/item/folder/biscuit/update_overlays()
	. = ..()
	if(contents.len) //This is to prevent the not-sealed biscuit to have the folder_paper overlay when it gets sealed
		. -= "folder_paper"
		if(cracked) //Shows overlay only when it has content and is cracked open
			. += "paperbiscuit_paper"

///Checks if the biscuit has been already cracked. If its not then it dipsplays "unopened!" ballon alert. If it is cracked then it lets the code continue.
/obj/item/folder/biscuit/proc/crack_check(mob/user)
	if (cracked)
		return TRUE
	balloon_alert(user, "unopened!")
	return FALSE

/obj/item/folder/biscuit/examine()
	. = ..()
	if(!cracked)
		. += span_notice("To reach contents you need to crack it open.")

//All next is done so you can't reach contents, or put any new contents when its not cracked open
/obj/item/folder/biscuit/remove_item(obj/item/item, mob/user)
	if (!crack_check(user))
		return

	return ..()

/obj/item/folder/biscuit/attack_hand(mob/user, list/modifiers)
	if (LAZYACCESS(modifiers, RIGHT_CLICK) && !crack_check(user))
		return

	return ..()

/obj/item/folder/biscuit/attackby(obj/item/weapon, mob/user, params)
	if (is_type_in_typecache(weapon, folder_insertables) && !crack_check(user))
		return

	return ..()

/obj/item/folder/biscuit/attack_self(mob/user)
	add_fingerprint(user)
	if (!cracked)
		if (tgui_alert(user, "Do you want to crack it open?", "Biscuit Cracking", list("Yes", "No")) != "Yes")
			return
		cracked = TRUE
		playsound(get_turf(user), 'sound/effects/wounds/crack1.ogg', 60)
		icon_state = "[icon_state]_cracked"
		update_appearance()

	ui_interact(user)
//Corporate "confidental" biscuit cards
/obj/item/folder/biscuit/confidental
	name = "\proper confidental biscuit card"
	desc = "An confidental biscuit card. In a tasteful blue color with NT logo, looks like a chocolate bar. Has label which says <b>DO NOT DIGEST</b>."
	icon_state = "paperbiscuit_secret"
	bg_color = "#355e9f"

/obj/item/folder/biscuit/confidental/spare_id_safe_code
	name = "\proper spare ID safe code biscuit card"
	desc = "An biscuit card containing confidental spare ID safe code. In a tasteful blue color with NT logo, looks like a chocolate bar. Has label which says <b>DO NOT DIGEST</b>."

/obj/item/folder/biscuit/confidental/spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code(src)

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code
	name = "\proper spare emergency ID safe code biscuit card"
	desc = "An biscuit card containing <i>not so confidental</i> emergency spare ID safe code. In a tasteful blue color with NT logo, looks like a chocolate bar. Has label which says <b>DO NOT DIGEST</b>."

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code(src)

//Biscuits which start not-sealed/cracked initially for the crafting, printing and such
/obj/item/folder/biscuit/unsealed
	name = "\proper biscuit card"
	desc = "An biscuit card. Has label which says <b>DO NOT DIGEST</b>."
	icon_state = "paperbiscuit_cracked"
	cracked = TRUE
	///Was the biscuit already sealed by players? To prevent several tgui alerts
	var/sealed = FALSE
	///What is the sprite for when its not cracked? As it starts already cracked, and for re-sealing needs to have a sprite
	var/not_cracked_icon = "paperbiscuit"

/obj/item/folder/biscuit/unsealed/examine()
	. = ..()
	if(!sealed)
		. += span_notice("This one have not been sealed yet. You many insert anything to seal it by pressing it in hand. Once sealed, the contents are inaccessible until cracked open (irreversible).")

//Asks if you want to seal the biscuit, after you do that it behaves like normal paper biscuit.
/obj/item/folder/biscuit/unsealed/attack_self(mob/user)
	add_fingerprint(user)
	if (!sealed)
		if (tgui_alert(user, "Do you want to seal it? You must crack it open to reach the contents again!", "Biscuit Sealing", list("Yes", "No")) != "Yes")
			return
		cracked = FALSE
		sealed = TRUE
		playsound(get_turf(user), 'sound/items/duct_tape_snap.ogg', 60)
		icon_state = "[not_cracked_icon]"
		update_appearance()

	return ..()

/obj/item/folder/biscuit/unsealed/confidental
	name = "\proper confidental biscuit card"
	desc = "An confidental biscuit card. In a tasteful blue color with NT logo, looks like a chocolate bar. To reach contents you need to crack it open. Has label which says <b>DO NOT DIGEST</b>."
	icon_state = "paperbiscuit_secret_cracked"
	bg_color = "#355e9f"
	not_cracked_icon = "paperbiscuit_secret"
