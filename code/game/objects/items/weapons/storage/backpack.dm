
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = 4.0
	flags = FPRINT
	slot_flags = SLOT_BACK	//ERROOOOO
	fits_max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(get_turf(src), "rustle", 50, 1, -5)
	. = ..()

/*
 * Backpack Types
 */




/obj/item/weapon/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	item_state = "holdingpack"
	icon_state = "holdingpack"
	fits_max_w_class = 4
	max_combined_w_class = 28

/obj/item/weapon/storage/backpack/holding/suicide_act(mob/user)
		to_chat(viewers(user), "<span class = 'danger'><b>[user] puts the [src.name] on \his head and stretches the bag around \himself. With a sudden snapping sound, the bag shrinks to it's original size, leaving no trace of [user] </b></span>")
		loc = get_turf(user)
		qdel(user)

/obj/item/weapon/storage/backpack/holding/New()
	..()
	return

/obj/item/weapon/storage/backpack/holding/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W == src)
		return // HOLY FUCKING SHIT WHY STORAGE CODE, WHY - pomf
	if(crit_fail)
		to_chat(user, "<span class = 'warning'>The Bluespace generator isn't working.</span>")
		return
	//BoH+BoH=Singularity, WAS commented out
	if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
		investigation_log(I_SINGULO,"has become a singularity. Caused by [user.key]")
		message_admins("[src] has become a singularity. Caused by [user.key]")
		to_chat(user, "<span class = 'danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		W = null
		new /obj/machinery/singularity (get_turf(src))
		message_admins("[key_name_admin(user)] detonated a bag of holding")
		log_game("[key_name(user)] detonated a bag of holding")
		to_chat(user, "<span class='danger'>FUCK</span>")
		user.throw_at(get_turf(src), 10, 5)
		qdel(src)
		return
	. = ..()

/obj/item/weapon/storage/backpack/holding/proc/failcheck(mob/user as mob)
	if (prob(src.reliability)) return 1 //No failure
	if (prob(src.reliability))
		to_chat(user, "<span class = 'warning'>The Bluespace portal resists your attempt to add another item.</span>")//light failure

	else
		to_chat(user, "<span class = 'danger'>The Bluespace generator malfunctions!</span>")
		for (var/obj/O in src.contents) //it broke, delete what was in it
			qdel(O)
		crit_fail = 1
		icon_state = "brokenpack"

/obj/item/weapon/storage/backpack/holding/singularity_act(var/current_size,var/obj/machinery/singularity/S)
	var/dist = max(current_size, 1)
	empulse(S.loc,(dist*2),(dist*4))
	if(S.current_size <= 3)
		investigation_log(I_SINGULO, "has been destroyed by a bag of holding.")
		qdel(S)
	else
		investigation_log(I_SINGULO, "has been weakened by a bag of holding.")
		S.energy -= (S.energy/3)*2
		S.check_energy()
	qdel(src)
	return


/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = 7
	fits_max_w_class = 4
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
		user.update_inv_l_hand()
		user.update_inv_r_hand()

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
