/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(ACCESS_ARMORY)
	var/locked = TRUE
	var/broken = FALSE
	var/open = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


/obj/item/storage/lockbox/attackby(obj/item/W, mob/user, params)
	if(W.GetID())
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(allowed(user))
			locked = !locked
			if(locked)
				icon_state = icon_locked
				to_chat(user, "<span class='danger'>You lock the [src.name]!</span>")
				close_all()
				return
			else
				icon_state = icon_closed
				to_chat(user, "<span class='danger'>You unlock the [src.name]!</span>")
				return
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
			return
	if(!locked)
		return ..()
	else
		to_chat(user, "<span class='danger'>It's locked!</span>")

/obj/item/storage/lockbox/MouseDrop(over_object, src_location, over_location)
	if (locked)
		src.add_fingerprint(usr)
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return 0
	..()

/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		locked = FALSE
		desc += "It appears to be broken."
		icon_state = src.icon_broken
		if(user)
			visible_message("<span class='warning'>\The [src] has been broken by [user] with an electromagnetic card!</span>")
			return

/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return

//Check the destination item type for contentto.
/obj/item/storage/lockbox/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
		return null
	open = TRUE
	return ..()

/obj/item/storage/lockbox/can_be_inserted(obj/item/W, stop_messages = 0)
	if(locked)
		return 0
	return ..()

/obj/item/storage/lockbox/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	open = TRUE
	update_icon()
	return ..()
/obj/item/storage/lockbox/remove_from_storage(obj/item/W, atom/new_location, burn = 0)
	open = TRUE
	update_icon()
	return ..()

/obj/item/storage/lockbox/loyalty
	name = "lockbox of mindshield implants"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/loyalty/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)


/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/PopulateContents()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 10
	max_combined_w_class = 20
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"
	can_hold = list(/obj/item/clothing/accessory/medal)

/obj/item/storage/lockbox/medal/AltClick()
	if(!locked)
		open = (open ? FALSE : TRUE)
		update_icon()
	..()

/obj/item/storage/lockbox/medal/PopulateContents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/security(src)
	new /obj/item/clothing/accessory/medal/bronze_heart(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/conduct(src)

/obj/item/storage/lockbox/medal/update_icon()
	cut_overlays()
	if(locked)
		icon_state = "medalbox+l"
		open = FALSE
	else
		icon_state = "medalbox"
		if(open)
			icon_state += "open"
		if(broken)
			icon_state += "+b"
		if(contents && open)
			for (var/i in 1 to contents.len)
				var/obj/item/clothing/accessory/medal/M = contents[i]
				var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
				if(i > 1 && i <= 5)
					medalicon.pixel_x += ((i-1)*3)
				else if(i > 5)
					medalicon.pixel_y -= 7
					medalicon.pixel_x -= 2
					medalicon.pixel_x += ((i-6)*3)
				add_overlay(medalicon)

/obj/item/storage/lockbox/medal/sec
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/medal/sec/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/security(src)

/obj/item/storage/lockbox/medal/sci
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/medal/sci/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)