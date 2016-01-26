//Miniguns. For all your heavy weapon needs.

//Ammo pack. Holds the minigun and resembles an ammo pack used by real miniguns!
/obj/item/weapon/minigunpack
	name = "ammo pack"
	desc = "The ammo pack for a M134 minigun" //Ironically contains 0 ammo.
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minipack_g"
	item_state = "securitypack"
	slot_flags = SLOT_BACK
	w_class = 4
	origin_tech = "combat=7;illegal=7" //Illegal as shit.
	var/obj/item/weapon/gun/projectile/minigun/gun = null //the actual minigun strapped to the side.
	var/armed = 0 //whether the gun is attached, 0 is attached, 1 is the gun is wielded.

/obj/item/weapon/minigunpack/New()
	gun = new(src)
	..()

/obj/item/weapon/minigunpack/attack_hand(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(slot_back) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					user << "<span class='warning'>You need a free hand to hold the gun!</span>"
					return
				update_icon()
				gun.forceMove(user)
		else
			user << "<span class='warning'>You are already holding the gun!</span>"
	else
		..()

/obj/item/weapon/minigunpack/attackby(obj/item/weapon/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		gun.unwield(user)
		user.unEquip(gun,1)
		attach_gun()
	else
		..()

/obj/item/weapon/minigunpack/MouseDrop(obj/over_object) //Shamelessly copied from defibs.
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		switch(over_object.name)
			if("r_hand")
				if(H.r_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_r_hand(src)
			if("l_hand")
				if(H.l_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_l_hand(src)
	return

/obj/item/weapon/minigunpack/update_icon()
	if(armed)
		icon_state = "minipack_n"
	else
		icon_state = "minipack_g"


/obj/item/weapon/minigunpack/proc/attach_gun()
	gun.forceMove(src)
	armed = 0
	update_icon()


//The gun itself!
/obj/item/weapon/gun/projectile/minigun
	name = "M134 minigun"
	desc = "She weighs one hundred fifty kilograms and fires two hundred dollar, custom-tooled cartridges at ten rounds per second."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_u"
	item_state = "riotgun"
	origin_tech = null
	flags = NODROP
	w_class = 5
	materials = list()
	burst_size = 10
	pin = /obj/item/device/firing_pin/implant/pindicate
	mag_type = /obj/item/ammo_box/magazine/internal/minigun
	var/obj/item/weapon/minigunpack/ammo_pack
	var/ready = 0

/obj/item/weapon/gun/projectile/minigun/New()
	if(!ammo_pack)
		if(istype(loc,/obj/item/weapon/minigunpack)) //We should spawn inside a ammo pack so let's use that one.
			ammo_pack = loc
		else
			qdel(src)//No pack, no gun
	..()

/obj/item/weapon/gun/projectile/minigun/can_shoot()
	if(!ready)
		return 0
	else
		return ..()

/obj/item/weapon/gun/projectile/minigun/attack_self(mob/user)
	if(ready)
		unwield(user)
	else
		wield(user)

/obj/item/weapon/gun/projectile/minigun/update_icon()
	if(ready)
		icon_state = "minigun_a"
	else
		icon_state = "minigun_u"

/obj/item/weapon/gun/projectile/minigun/proc/unwield(mob/living/carbon/user)
	if(!ready)
		return
	ready = 0
	var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		O.unwield()
	update_icon()
	return

/obj/item/weapon/gun/projectile/minigun/proc/wield(mob/living/carbon/user)
	ready = 1
	if(user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty!</span>"
		return
	var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	user.put_in_inactive_hand(O)
	update_icon()
	return

/obj/item/weapon/gun/projectile/minigun/dropped(mob/user)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		unwield(user)
	ammo_pack.attach_gun()
	return


//All the weird BS that guns need to be as modular as possible. Oh yeah, the boolets.
/obj/item/ammo_box/magazine/internal/minigun
	name = "minigun belt"
	ammo_type = /obj/item/ammo_casing/minigun
	caliber = "7.62 NANO" //Technically the same ammo as the SAW but SHHHHH.
	max_ammo = 3000

/obj/item/ammo_casing/minigun
	name = "a 7.62 NANO casing."
	desc = "You better start running!"
	icon_state = "762-casing"
	caliber = "7.62 NANO"
	projectile_type = /obj/item/projectile/bullet/minigun
	variance = 0.8

/obj/item/projectile/bullet/minigun
	damage = 10
	armour_penetration = 5

/obj/item/projectile/bullet/minigun/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, -1, 1, adminlog = 0) //The gun logs already, who needs to know about the 10 explosions per second.
	return 1