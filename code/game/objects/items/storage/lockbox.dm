/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	req_access = list(ACCESS_ARMORY)
	var/broken = FALSE
	var/open = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"

/obj/item/storage/lockbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 14
	STR.max_items = 4
	STR.locked = TRUE

/obj/item/storage/lockbox/attackby(obj/item/W, mob/user, params)
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(W.GetID())
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(allowed(user))
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, !locked)
			locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
			if(locked)
				icon_state = icon_locked
				to_chat(user, "<span class='danger'>You lock the [src.name]!</span>")
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_ALL)
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

/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
		desc += "It appears to be broken."
		icon_state = src.icon_broken
		if(user)
			visible_message("<span class='warning'>\The [src] is broken by [user] with an electromagnetic card!</span>")
			return

/obj/item/storage/lockbox/Entered()
	. = ..()
	open = TRUE
	update_icon()

/obj/item/storage/lockbox/Exited()
	. = ..()
	open = TRUE
	update_icon()

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
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_items = 10
	STR.max_combined_w_class = 20
	STR.set_holdable(list(/obj/item/clothing/accessory/medal))

/obj/item/storage/lockbox/medal/examine(mob/user)
	. = ..()
	if(!SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
		. += "<span class='notice'>Alt-click to [open ? "close":"open"] it.</span>"

/obj/item/storage/lockbox/medal/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(!SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
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

/obj/item/storage/lockbox/medal/update_icon_state()
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(locked)
		icon_state = "medalbox+l"
	else
		icon_state = "medalbox"
		if(open)
			icon_state += "open"
		if(broken)
			icon_state += "+b"

/obj/item/storage/lockbox/medal/update_overlays()
	. = ..()
	if(!contents || !open)
		return
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(locked)
		return
	for(var/i in 1 to contents.len)
		var/obj/item/clothing/accessory/medal/M = contents[i]
		var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
		if(i > 1 && i <= 5)
			medalicon.pixel_x += ((i-1)*3)
		else if(i > 5)
			medalicon.pixel_y -= 7
			medalicon.pixel_x -= 2
			medalicon.pixel_x += ((i-6)*3)
		. += medalicon

/obj/item/storage/lockbox/medal/sec
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/medal/sec/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/security(src)

/obj/item/storage/lockbox/medal/cargo
	name = "cargo award box"
	desc = "A locked box used to store awards to be given to members of the cargo department."
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/medal/cargo/PopulateContents()
		new /obj/item/clothing/accessory/medal/ribbon/cargo(src)

/obj/item/storage/lockbox/medal/service
	name = "service award box"
	desc = "A locked box used to store awards to be given to members of the service department."
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/medal/service/PopulateContents()
		new /obj/item/clothing/accessory/medal/silver/excellence(src)

/obj/item/storage/lockbox/medal/sci
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/medal/sci/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)

/obj/item/storage/lockbox/order
	name = "order lockbox"
	desc = "A box used to secure small cargo orders from being looted by those who didn't order it. Yeah, cargo tech, that means you."
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	inhand_icon_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	var/datum/bank_account/buyer_account
	var/privacy_lock = TRUE

/obj/item/storage/lockbox/order/Initialize(datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account

/obj/item/storage/lockbox/order/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/card/id))
		return ..()

	var/obj/item/card/id/id_card = W
	if(iscarbon(user))
		add_fingerprint(user)

	if(id_card.registered_account != buyer_account)
		to_chat(user, "<span class='notice'>Bank account does not match with buyer!</span")
		return

	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, !privacy_lock)
	privacy_lock = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	user.visible_message("<span class='notice'>[user] [privacy_lock ? "" : "un"]locks [src]'s privacy lock.</span>",
					"<span class='notice'>You [privacy_lock ? "" : "un"]lock [src]'s privacy lock.</span>")

