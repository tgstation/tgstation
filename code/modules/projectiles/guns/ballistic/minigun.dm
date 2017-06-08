
//The ammo/gun is stored in a back slot item
/obj/item/weapon/minigunpack
	name = "backpack power source"
	desc = "The massive external power source for the laser gatling gun"
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "holstered"
	var/icon_state_unholstered = "notholstered"
	item_state = "backpack"
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	var/obj/item/weapon/gun/ballistic/minigun/gun
	var/armed = 0 //whether the gun is attached, 0 is attached, 1 is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 40
	var/heat_diffusion = 1
	var/gun_type = /obj/item/weapon/gun/ballistic/minigun/laser

/obj/item/weapon/minigunpack/ballistic
	name = "backpack ammo pack"
	desc = "A huge back-mounted ammo storage and power supply for a M134 minigun"
	icon_state = "minipack_gun"
	icon_state_unholstered = "minipack"
	gun_type = /obj/item/weapon/gun/ballistic/minigun/m134
	overheat_max = 100
	heat_diffusion = 7

/obj/item/weapon/minigunpack/Initialize()
	. = ..()
	gun = new gun_type(src)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/minigunpack/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/minigunpack/process()
	overheat = max(0, overheat - heat_diffusion)

/obj/item/weapon/minigunpack/attack_hand(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(slot_back) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					to_chat(user, "<span class='warning'>You need a free hand to hold the gun!</span>")
					return
				update_icon()
				gun.forceMove(user)
				user.update_inv_back()
		else
			to_chat(user, "<span class='warning'>You are already holding the gun!</span>")
	else
		..()

/obj/item/weapon/minigunpack/attackby(obj/item/weapon/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/weapon/minigunpack/dropped(mob/user)
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/weapon/minigunpack/MouseDrop(atom/over_object)
	if(armed)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.incapacitated())

			if(istype(over_object, /obj/screen/inventory/hand))
				var/obj/screen/inventory/hand/H = over_object
				M.putItemFromInventoryInHandIfPossible(src, H.held_index)


/obj/item/weapon/minigunpack/update_icon()
	if(armed)
		icon_state = icon_state_unholstered
	else
		icon_state = initial(icon_state)

/obj/item/weapon/minigunpack/proc/attach_gun(var/mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = 0
	if(user)
		to_chat(user, "<span class='notice'>You attach the [gun.name] to the [name].</span>")
	else
		src.visible_message("<span class='warning'>The [gun.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()


/obj/item/weapon/gun/ballistic/minigun
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_spin"
	item_state = "minigun"
	origin_tech = "combat=6;powerstorage=5;magnets=4"
	flags = CONDUCT
	slowdown = 1
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	materials = list()
	burst_size = 3
	automatic = 0
	fire_delay = 1
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/internal/minigun
	casing_ejector = 0
	var/obj/item/weapon/minigunpack/ammo_pack
	var/use_heat = TRUE

/obj/item/weapon/gun/ballistic/minigun/Initialize()
	SET_SECONDARY_FLAG(src, SLOWS_WHILE_IN_HAND)

	if(istype(loc, /obj/item/weapon/minigunpack)) //We should spawn inside a ammo pack so let's use that one.
		ammo_pack = loc
	else
		return INITIALIZE_HINT_QDEL //No pack, no gun

	return ..()

/obj/item/weapon/gun/ballistic/minigun/laser
	name = "laser gatling gun"
	desc = "An advanced laser cannon with an incredible rate of fire. Requires a bulky backpack power source to use."
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/weapon/gun/ballistic/minigun/m134
	name = "M134 Minigun"
	desc = "She weighs one hundred fifty kilograms and fires two hundred dollar, custom-tooled cartridges at ten rounds per second."
	burst_size = 5
	spread = 30
	mag_type = /obj/item/ammo_box/magazine/internal/minigun/m134
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	icon_state = "minigun_spin_ballistic"
	item_state = "minigun_b"

/obj/item/weapon/gun/ballistic/minigun/attack_self(mob/living/user)
	return

/obj/item/weapon/gun/ballistic/minigun/dropped(mob/user)
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/weapon/gun/ballistic/minigun/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(ammo_pack)
		if(!use_heat)
			..()
		else if(ammo_pack.overheat < ammo_pack.overheat_max)
			ammo_pack.overheat += burst_size
			..()
		else
			to_chat(user, "The gun's heat sensor locked the trigger to prevent lens damage.")

/obj/item/weapon/gun/ballistic/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "You need the backpack power source to fire the gun!")
	..()

/obj/item/weapon/gun/ballistic/minigun/dropped(mob/living/user)
	ammo_pack.attach_gun(user)


