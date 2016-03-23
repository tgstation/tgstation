/obj/item/weapon/storage/internal
	storage_slots = 2
	max_w_class = 2
	max_combined_w_class = 4
	w_class = 4
	var/priority = 1

/*obj/item/weapon/storage/internal/pocket/New()
	..()
	if(loc) name = loc.name

/obj/item/weapon/storage/internal/pocket/big
	max_w_class = 3
	max_combined_w_class = 6

/obj/item/weapon/storage/internal/pocket/small
	storage_slots = 1
	max_combined_w_class = 2
	priority = 0

/obj/item/weapon/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = 1
	max_combined_w_class = 1
	priority = 0


/obj/item/weapon/storage/internal/pocket/small/detective
	priority = 1

/obj/item/weapon/storage/internal/pocket/small/detective/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/flask/det(src)


proc/isstorage(var/atom/A)
	if(istype(A, /obj/item/weapon/storage))
		return 1

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/C = A
		if(C.pockets) return 1*/