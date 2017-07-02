/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, used to incapacitate unruly patients from a distance."
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=2;biotech=3"
	clumsy_check = 0
	fire_sound = 'sound/items/syringeproj.ogg'
	var/list/syringes = list()
	var/max_syringes = 1

/obj/item/weapon/gun/syringe/Initialize()
	. = ..()
	chambered = new /obj/item/ammo_casing/syringegun(src)

/obj/item/weapon/gun/syringe/recharge_newshot()
	if(!syringes.len)
		return
	chambered.newshot()

/obj/item/weapon/gun/syringe/can_shoot()
	return syringes.len

/obj/item/weapon/gun/syringe/process_chamber()
	if(chambered && !chambered.BB) //we just fired
		recharge_newshot()

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	to_chat(user, "Can hold [max_syringes] syringe\s. Has [syringes.len] syringe\s remaining.")

/obj/item/weapon/gun/syringe/attack_self(mob/living/user)
	if(!syringes.len)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return 0

	var/obj/item/weapon/reagent_containers/syringe/S = syringes[syringes.len]

	if(!S) return 0
	S.loc = user.loc

	syringes.Remove(S)
	to_chat(user, "<span class='notice'>You unload [S] from \the [src].</span>")

	return 1

/obj/item/weapon/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/weapon/reagent_containers/syringe))
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(A, src))
				return FALSE
			to_chat(user, "<span class='notice'>You load [A] into \the [src].</span>")
			syringes += A
			recharge_newshot()
			return TRUE
		else
			to_chat(user, "<span class='warning'>[src] cannot hold more syringes!</span>")
	return FALSE

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 6

/obj/item/weapon/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "syringe_pistol"
	item_state = "gun" //Smaller inhand
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;syndicate=2;biotech=3"
	force = 2 //Also very weak because it's smaller
	suppressed = 1 //Softer fire sound
	can_unsuppress = 0 //Permanently silenced
	
/obj/item/weapon/gun/syringe/dna
	name = "modified syringe gun"
	desc = "A syringe gun that has been modified to fit DNA injectors instead of normal syringes."
	origin_tech = "combat=2;syndicate=2;biotech=3"
	
/obj/item/weapon/gun/syringe/dna/Initialize()
	. = ..()
	chambered = new /obj/item/ammo_casing/dnainjector(src)
	
/obj/item/weapon/gun/syringe/dna/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/weapon/dnainjector))
		var/obj/item/weapon/dnainjector/D = A
		if(D.used)
			to_chat(user, "<span class='warning'>This injector is used up!</span>")
			return
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(D, src))
				return FALSE
			to_chat(user, "<span class='notice'>You load \the [D] into \the [src].</span>")
			syringes += D
			recharge_newshot()
			return TRUE
		else
			to_chat(user, "<span class='warning'>[src] cannot hold more syringes!</span>")
	return FALSE