/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	storage_slots = 4
	icon_state = "wallet"
	w_class = 2
	can_hold = list(
		"/obj/item/money/cash",
		"/obj/item/security/card",
		"/obj/item/clothing/mask/cigarette",
		"/obj/item/tool/flashlight/pen",
		"/obj/item/botany/seeds",
		"/obj/item/part/stack/medical",
		"/obj/item/toy/crayon",
		"/obj/item/money/coin",
		"/obj/item/toy/dice",
		"/obj/item/office/disk",
		"/obj/item/medical/implanter",
		"/obj/item/tool/lighter",
		"/obj/item/tool/match",
		"/obj/item/office/paper",
		"/obj/item/office/pen",
		"/obj/item/office/photo",
		"/obj/item/chem/dropper",
		"/obj/item/tool/screwdriver",
		"/obj/item/office/stamp")
	slot_flags = SLOT_ID

	var/obj/item/security/card/id/front_id = null


/obj/item/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
			update_icon()

/obj/item/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		if(!front_id && istype(W, /obj/item/security/card/id))
			front_id = W
			update_icon()

/obj/item/storage/wallet/update_icon()

	if(front_id)
		switch(front_id.icon_state)
			if("id")
				icon_state = "walletid"
				return
			if("silver")
				icon_state = "walletid_silver"
				return
			if("gold")
				icon_state = "walletid_gold"
				return
			if("centcom")
				icon_state = "walletid_centcom"
				return
	icon_state = "wallet"


/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()

/obj/item/storage/wallet/random/New()
	..()
	var/item1_type = pick( /obj/item/money/cash/c10,/obj/item/money/cash/c100,/obj/item/money/cash/c1000,/obj/item/money/cash/c20,/obj/item/money/cash/c200,/obj/item/money/cash/c50, /obj/item/money/cash/c500)
	var/item2_type
	if(prob(50))
		item2_type = pick( /obj/item/money/cash/c10,/obj/item/money/cash/c100,/obj/item/money/cash/c1000,/obj/item/money/cash/c20,/obj/item/money/cash/c200,/obj/item/money/cash/c50, /obj/item/money/cash/c500)
	var/item3_type = pick( /obj/item/money/coin/silver, /obj/item/money/coin/silver, /obj/item/money/coin/gold, /obj/item/money/coin/iron, /obj/item/money/coin/iron, /obj/item/money/coin/iron )

	spawn(2)
		if(item1_type)
			new item1_type(src)
		if(item2_type)
			new item2_type(src)
		if(item3_type)
			new item3_type(src)