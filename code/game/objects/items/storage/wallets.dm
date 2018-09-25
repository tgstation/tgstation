/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	icon_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_ID

	var/obj/item/card/id/front_id = null
	var/list/combined_access

/obj/item/storage/wallet/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 4
	STR.can_hold = typecacheof(list(
		/obj/item/stack/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/lipstick,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/screwdriver,
		/obj/item/stamp))

/obj/item/storage/wallet/Exited(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/proc/refreshID()
	LAZYCLEARLIST(combined_access)
	if(!(front_id in src))
		front_id = null
	for(var/obj/item/card/id/I in contents)
		if(!front_id)
			front_id = I
		LAZYINITLIST(combined_access)
		combined_access |= I.access
	update_icon()

/obj/item/storage/wallet/Entered(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/update_icon()
	var/new_state = "wallet"
	if(front_id)
		new_state = "wallet_[front_id.icon_state]"
	if(new_state != icon_state)		//avoid so many icon state changes.
		icon_state = new_state

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/GetAccess()
	if(LAZYLEN(combined_access))
		return combined_access
	else
		return ..()

/obj/item/storage/wallet/random
	icon_state = "random_wallet"

/obj/item/storage/wallet/random/PopulateContents()
	var/obj/item/stack/spacecash/c10/cash = new /obj/item/stack/spacecash/c10(src)
	cash.amount = rand(1,5)
	update_icon()
