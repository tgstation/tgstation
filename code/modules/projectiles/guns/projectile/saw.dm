/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.62 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m762
	heavy_weapon = 1
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
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"]"


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
	if(!cover_open)
		user << "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>"
		return
	..()


//ammo//


/obj/item/projectile/bullet/saw
	damage = 35
	armour_penetration = 5

/obj/item/projectile/bullet/saw/bleeding
	damage = 15
	armour_penetration = 0

/obj/item/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.drip(25)

/obj/item/projectile/bullet/saw/hollow
	damage = 45
	armour_penetration = 0

/obj/item/projectile/bullet/saw/ap
	damage = 30
	armour_penetration = 35

/obj/item/projectile/bullet/saw/incen
	damage = 5
	armour_penetration = 0

/obj/item/projectile/bullet/saw/incen/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()


//magazines//


/obj/item/ammo_box/magazine/m762
	name = "box magazine (7.62mm)"
	icon_state = "a762-50"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 50

/obj/item/ammo_box/magazine/m762/bleeding
	name = "box magazine (Bleeding 7.62mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762/bleeding

/obj/item/ammo_box/magazine/m762/hollow
	name = "box magazine (Hollow-Point 7.62mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762/hollow

/obj/item/ammo_box/magazine/m762/ap
	name = "box magazine (Armor Penetrating 7.62mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762/ap

/obj/item/ammo_box/magazine/m762/incen
	name = "box magazine (Incendiary 7.62mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762/incen

/obj/item/ammo_box/magazine/m762/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"


//casings//


/obj/item/ammo_casing/a762
	desc = "A 7.62mm bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet/saw

/obj/item/ammo_casing/a762/bleeding
	desc = "A 7.62mm bullet casing with specialized inner-casing, that when it makes contact with a target, release tiny shrapnel to induce internal bleeding."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/a762/hollow
	desc = "A 7.62mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/a762/ap
	desc = "A 7.62mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/a762/incen
	desc = "A 7.62mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/item/projectile/bullet/saw/incen


