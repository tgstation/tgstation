/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(GLOB.access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


/obj/item/weapon/storage/lockbox/attackby(obj/item/weapon/W, mob/user, params)
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

/obj/item/weapon/storage/lockbox/MouseDrop(over_object, src_location, over_location)
	if (locked)
		src.add_fingerprint(usr)
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return 0
	..()

/obj/item/weapon/storage/lockbox/emag_act(mob/user)
	if(!broken)
		broken = 1
		locked = 0
		desc += "It appears to be broken."
		icon_state = src.icon_broken
		if(user)
			visible_message("<span class='warning'>\The [src] has been broken by [user] with an electromagnetic card!</span>")
			return
/obj/item/weapon/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return

//Check the destination item type for contentto.
/obj/item/weapon/storage/lockbox/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
		return 0
	return ..()

/obj/item/weapon/storage/lockbox/can_be_inserted(obj/item/W, stop_messages = 0)
	if(locked)
		return 0
	return ..()

/obj/item/weapon/storage/lockbox/loyalty
	name = "lockbox of mindshield implants"
	req_access = list(GLOB.access_security)

/obj/item/weapon/storage/lockbox/loyalty/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/implantcase/mindshield(src)
	new /obj/item/weapon/implanter/mindshield(src)


/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(GLOB.access_security)

/obj/item/weapon/storage/lockbox/clusterbang/PopulateContents()
	new /obj/item/weapon/grenade/clusterbuster(src)

/obj/item/weapon/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 10
	max_combined_w_class = 20
	req_access = list(GLOB.access_captain)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"
	can_hold = list(/obj/item/clothing/accessory/medal)

/obj/item/weapon/storage/lockbox/medal/PopulateContents()
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/bronze_heart(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/conduct(src)
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/security(src)
	new /obj/item/clothing/accessory/medal/plasma(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	new /obj/item/clothing/accessory/medal/gold/heroism(src)
