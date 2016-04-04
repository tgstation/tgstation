/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 5.56x45mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/mm556x45
	weapon_weight = WEAPON_MEDIUM
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/cover_open = 0
	can_suppress = 0
	burst_size = 3
	fire_delay = 1
	pin = /obj/item/device/firing_pin/implant/pindicate

/obj/item/weapon/gun/projectile/automatic/l6_saw/unrestricted
	pin = /obj/item/device/firing_pin


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"][suppressed ? "-suppressed" : ""]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"


/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='warning'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(!cover_open)
		user << "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>"
		return
	..()


//ammo//


/obj/item/projectile/bullet/saw
	damage = 45
	armour_penetration = 5

/obj/item/projectile/bullet/saw/bleeding
	damage = 20
	armour_penetration = 0

/obj/item/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.drip(35)

/obj/item/projectile/bullet/saw/hollow
	damage = 60
	armour_penetration = -10

/obj/item/projectile/bullet/saw/ap
	damage = 40
	armour_penetration = 75

/obj/item/projectile/bullet/saw/incen
	damage = 7
	armour_penetration = 0

obj/item/projectile/bullet/saw/incen/Move()
	..()
	var/turf/location = get_turf(src)
	if(location)
		PoolOrNew(/obj/effect/hotspot, location)
		location.hotspot_expose(700, 50, 1)

/obj/item/projectile/bullet/saw/incen/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(3)
		M.IgniteMob()


//magazines//


/obj/item/ammo_box/magazine/mm556x45
	name = "box magazine (5.56x45mm)"
	icon_state = "a762-50"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/mm556x45
	caliber = "mm55645"
	max_ammo = 50

/obj/item/ammo_box/magazine/mm556x45/bleeding
	name = "box magazine (Bleeding 5.56x45mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm556x45/bleeding

/obj/item/ammo_box/magazine/mm556x45/hollow
	name = "box magazine (Hollow-Point 5.56x45mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm556x45/hollow

/obj/item/ammo_box/magazine/mm556x45/ap
	name = "box magazine (Armor Penetrating 5.56x45mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm556x45/ap

/obj/item/ammo_box/magazine/mm556x45/incen
	name = "box magazine (Incendiary 5.56x45mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm556x45/incen

/obj/item/ammo_box/magazine/mm556x45/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"


//casings//


/obj/item/ammo_casing/mm556x45
	desc = "A 556x45mm bullet casing."
	icon_state = "762-casing"
	caliber = "mm55645"
	projectile_type = /obj/item/projectile/bullet/saw

/obj/item/ammo_casing/mm556x45/bleeding
	desc = "A 556x45mm bullet casing with specialized inner-casing, that when it makes contact with a target, release tiny shrapnel to induce internal bleeding."
	icon_state = "762-casing"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/mm556x45/hollow
	desc = "A 556x45mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/mm556x45/ap
	desc = "A 556x45mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/mm556x45/incen
	desc = "A 556x45mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/item/projectile/bullet/saw/incen


