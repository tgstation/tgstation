/obj/item/weapon/storage/internal
	storage_slots = 2
	max_w_class = 2
	max_combined_w_class = 4
	w_class = 4


/obj/item/weapon/storage/internal/ClickAccesible(mob/user, depth=1)
	if(loc)
		return loc.ClickAccesible(user, depth)

/obj/item/weapon/storage/internal/pocket
	var/priority = TRUE
	// TRUE if opens when clicked, like a backpack.
	// FALSE if opens only when dragged on mob's icon (hidden pocket)

/obj/item/weapon/storage/internal/pocket/New()
	..()
	if(loc)
		name = loc.name

/obj/item/weapon/storage/internal/pocket/big
	max_w_class = 3
	max_combined_w_class = 6

/obj/item/weapon/storage/internal/pocket/small
	storage_slots = 1
	max_combined_w_class = 2
	priority = FALSE

/obj/item/weapon/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = 1
	max_combined_w_class = 1
	priority = FALSE


/obj/item/weapon/storage/internal/pocket/small/detective
	priority = TRUE // so the detectives would discover pockets in their hats

/obj/item/weapon/storage/internal/pocket/small/detective/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/flask/det(src)

/*
/proc/isstorage(var/atom/A)
	if(istype(A, /obj/item/weapon/storage))
		return 1

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/C = A
		if(C.pockets) return 1*/