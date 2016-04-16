/obj/item/weapon/storage/internal
	storage_slots = 2
	max_w_class = 2
	max_combined_w_class = 4
	w_class = 4
	var/priority = 1

/obj/item/weapon/storage/internal/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	if(silent)
		return ..(W, 1, user) // no warning
	else
		return ..()


/obj/item/weapon/storage/internal/pocket/New()
	..()
	if(loc) name = loc.name

/obj/item/weapon/storage/internal/pocket/big
	max_w_class = 3
	max_combined_w_class = 6

/obj/item/weapon/storage/internal/pocket/razgruzka
	max_w_class = 2
	storage_slots = 5
	max_combined_w_class = 15

/obj/item/weapon/storage/internal/pocket/small
	storage_slots = 2
	max_combined_w_class = 2
	priority = 0

/obj/item/weapon/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = 1
	max_combined_w_class = 1
	priority = 0

proc/isstorage(var/atom/A)
	if(istype(A, /obj/item/weapon/storage))
		return 1

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/C = A
		if(C.) return 1
