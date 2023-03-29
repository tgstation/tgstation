/obj/item/folder/biscuit
	name = "\proper biscuit card"
	desc = "An biscuit card. To reach contents you need to crack it open."
	icon_state = "paperbiscuit"
	bg_color = "#b88f3d"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	/// Is biscuit cracked open or not?
	var/cracked = FALSE

/obj/item/folder/biscuit/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] tries to eat the 'biscuit'! [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/folder/biscuit/update_overlays()
	. = ..()
	if(contents.len) //Shows overlay only when it has content and is cracked open
		. -= "folder_paper"
		if(cracked) //This is to prevent the not-sealed biscuit to have the folder_paper overlay when it gets sealed
			. += "paperbiscuit_paper"

///Checks if the biscuit has been already cracked. If its not then it dipsplays "unopened!" ballon alert. If it is cracked then it lets the code continue.
/obj/item/folder/biscuit/proc/crack_check(mob/user)
    if (cracked)
        return TRUE
    balloon_alert(user, "unopened!")
    return FALSE

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
		if (tgui_alert(user, "Do you want to crack it open? You cannot close it back.", "Biscuit card", list("Yes", "No")) == "Yes")
			cracked = TRUE
			playsound(get_turf(user), 'sound/effects/wounds/crack1.ogg', 60)
			icon_state = "[icon_state]_cracked"
			update_appearance()
			return
		else
			return
	if (cracked)
		ui_interact(user)
		return

//Corporate "confidental" biscuit cards
/obj/item/folder/biscuit/confidental
	name = "\proper confidental biscuit card"
	desc = "An confidental biscuit card. In a tasteful blue color with NT logo, looks like a chocolate bar. To reach contents you need to crack it open."
	icon_state = "paperbiscuit_secret"
	bg_color = "#355e9f"

/obj/item/folder/biscuit/confidental/spare_id_safe_code
	name = "\proper spare ID safe code biscuit card"
	desc = "An biscuit card containing confidental spare ID safe code. In a tasteful blue color with NT logo, looks like a chocolate bar. To reach contents you need to crack it open."

/obj/item/folder/biscuit/confidental/spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code(src)

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code
	name = "\proper spare emergency ID safe code biscuit card"
	desc = "An biscuit card containing <i>not so confidental</i> emergency spare ID safe code. In a tasteful blue color with NT logo, looks like a chocolate bar. To reach contents you need to crack it open."

/obj/item/folder/biscuit/confidental/emergency_spare_id_safe_code/Initialize(mapload)
	. = ..()
	new /obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code(src)

//Biscuits which start not-sealed/cracked initially for the crafting, printing and such
/obj/item/folder/biscuit/not_sealed
	name = "\proper biscuit card"
	desc = "An biscuit card. To reach contents you need to crack it open."
	icon_state = "paperbiscuit_cracked"
	cracked = TRUE
	///Was the biscuit already sealed by players? To prevent several tgui alerts
	var/sealed = FALSE

/obj/item/folder/biscuit/not_sealed/examine()
	. = ..()
	if(!sealed)
		. += span_notice("This one have never been sealed yet. Put in any contents to seal it by pressing it in hand. After sealing the only way to reach contents is by cracking it which is irreversible.")

/obj/item/folder/biscuit/not_sealed/attack_self(mob/user)
	add_fingerprint(user)
	if (!sealed)
		if (tgui_alert(user, "Do you want to seal it? After sealing the only way to reach the contents is by cracking the biscuit, you cannot re-seal it again after that.", "Biscuit card", list("Yes", "No")) == "Yes")
			cracked = FALSE
			sealed = TRUE
			playsound(get_turf(user), 'sound/items/duct_tape_snap.ogg', 60)
			icon_state = "paperbiscuit"
			update_appearance()
			return
		else
			return
	if (sealed)
		return ..()
