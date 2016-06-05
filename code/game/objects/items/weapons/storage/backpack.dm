
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	slot_flags = SLOT_BACK	//ERROOOOO
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 21

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(get_turf(src), "rustle", 50, 1, -5)
	. = ..()

/*
 * Backpack Types
 */


/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = W_CLASS_LARGE
	storage_slots = 7
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/weapon/storage/backpack/santabag/attack_hand(user)
	if(contents.len < storage_slots)
		var/empty_slots = Clamp((storage_slots - contents.len),0,storage_slots)
		to_chat(user,"<span class='notice'>You look into the bag, and find it filled with [empty_slots] new presents!</span>")
		for(var/i = 1,i <= empty_slots,i++)
			var/gift = pick(/obj/item/weapon/winter_gift/cloth,/obj/item/weapon/winter_gift/regular,/obj/item/weapon/winter_gift/food)
			if(prob(1))
				gift = /obj/item/weapon/winter_gift/special
			new gift(src)
	. = ..()

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack_0skull"
	item_state = "cultpack_0skull"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	var/skulls = 0

/obj/item/weapon/storage/backpack/cultpack/attack_self(mob/user as mob)
	..()
	if(skulls)
		for(,skulls > 0,skulls--)
			new/obj/item/weapon/skull(get_turf(src))
		update_icon(user)

/obj/item/weapon/storage/backpack/cultpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W == src)
		return
	if(istype(W, /obj/item/weapon/skull) && (skulls < 3))
		user.u_equip(W,1)
		qdel(W)
		skulls++
		update_icon(user)
		to_chat(user,"<span class='warning'>You plant the skull on the trophy rack.</span>")
		return
	. = ..()

/obj/item/weapon/storage/backpack/cultpack/update_icon(var/mob/living/carbon/user)
	icon_state = "cultpack_[skulls]skull"
	item_state = "cultpack_[skulls]skull"
	if(istype(user))
		user.update_inv_back()
		user.update_inv_hands()

/obj/item/weapon/storage/backpack/cultify()
	new /obj/item/weapon/storage/backpack/cultpack(loc)
	..()

/obj/item/weapon/storage/backpack/cultpack/cultify()
	return

/obj/item/weapon/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"

/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"

/obj/item/weapon/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/weapon/storage/wallet/random( src )

/obj/item/weapon/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"

/obj/item/weapon/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	item_state = "engiepack"

/obj/item/weapon/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/weapon/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/weapon/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	item_state = "captainpack"
