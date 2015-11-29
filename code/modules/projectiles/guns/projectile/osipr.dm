#define OSIPR_MAX_CORES 3
#define OSIPR_PRIMARY_FIRE 1
#define OSIPR_SECONDARY_FIRE 2

/obj/item/weapon/gun/osipr
	name = "\improper Overwatch Standard Issue Pulse Rifle"
	desc = "Centuries ago those weapons striked fear in all of humanity when the Combine attacked the Earth. Nowadays these are just the best guns that the Syndicate can provide to its Elite Troops with its tight budget."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "osipr"
	item_state = "osipr"
	slot_flags = SLOT_BELT
	origin_tech = "materials=5;combat=5;magnets=4;powerstorage=3"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	fire_delay = 0
	w_class = 3.0
	fire_sound = 'sound/weapons/osipr_fire.ogg'
	var/obj/item/energy_magazine/osipr/magazine = null
	var/energy_balls = 2
	var/mode = OSIPR_PRIMARY_FIRE

/obj/item/weapon/gun/osipr/New()
	..()
	magazine = new(src)

/obj/item/weapon/gun/osipr/Destroy()
	if(magazine)
		qdel(magazine)
	..()

/obj/item/weapon/gun/osipr/examine(mob/user)
	..()
	if(magazine)
		to_chat(user, "<span class='info'>Has [magazine.bullets] pulse bullet\s remaining.</span>")
	else
		to_chat(user, "<span class='info'>It has no pulse magazine inserted!</span>")
	to_chat(user, "<span class='info'>Has [energy_balls] dark energy core\s remaining.</span>")

/obj/item/weapon/gun/osipr/process_chambered()
	if(in_chamber) return 1
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			if(!magazine || !magazine.bullets) return 0
			magazine.bullets--
			update_icon()
			in_chamber = new magazine.bullet_type()
			return 1
		if(OSIPR_SECONDARY_FIRE)
			if(!energy_balls) return 0
			energy_balls--
			in_chamber = new/obj/item/projectile/energy/osipr()
			return 1
	return 0

/obj/item/weapon/gun/osipr/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/energy_magazine/osipr))
		if(magazine)
			to_chat(user, "There is another magazine already inserted. Remove it first.")
		else
			user.u_equip(A,1)
			A.loc = src
			magazine = A
			update_icon()
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			to_chat(user, "<span class='info'>You insert a new magazine.</span>")
			user.regenerate_icons()

	else if(istype(A, /obj/item/osipr_core))
		if(energy_balls >= OSIPR_MAX_CORES)
			to_chat(user, "The OSIPR cannot receive any additional dark energy core.")
		else
			user.u_equip(A,1)
			qdel(A)
			energy_balls++
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			to_chat(user, "<span class='info'>You insert \the [A].</span>")
	else
		..()

/obj/item/weapon/gun/osipr/attack_hand(mob/user)
	if(((src == user.r_hand) || (src == user.l_hand)) && magazine)
		magazine.update_icon()
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		playsound(get_turf(src), 'sound/machines/click.ogg', 25, 1)
		to_chat(user, "<span class='info'>You remove the magazine.</span>")
		user.regenerate_icons()
	else
		..()

/obj/item/weapon/gun/osipr/attack_self(mob/user)
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			mode = OSIPR_SECONDARY_FIRE
			fire_sound = 'sound/weapons/osipr_altfire.ogg'
			fire_delay = 20
			to_chat(user, "<span class='warning'>Now set to fire dark energy orbs.</span>")
		if(OSIPR_SECONDARY_FIRE)
			mode = OSIPR_PRIMARY_FIRE
			fire_sound = 'sound/weapons/osipr_fire.ogg'
			fire_delay = 0
			to_chat(user, "<span class='warning'>Now set to fire pulse bullets.</span>")

/obj/item/weapon/gun/osipr/update_icon()
	if(!magazine)
		icon_state = "osipr-empty"
		item_state = "osipr-empty"
	else
		item_state = "osipr"
		var/bullets = round(magazine.bullets/(magazine.max_bullets/10))
		icon_state = "osipr[bullets]0"

/obj/item/energy_magazine
	name = "energy magazine"
	desc = "Can be replenished by a recharger"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-magfull"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0
	var/bullets = 10
	var/max_bullets = 10
	var/caliber = "osipr"	//base icon name
	var/bullet_type = /obj/item/projectile/bullet/osipr

/obj/item/energy_magazine/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	update_icon()

/obj/item/energy_magazine/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [bullets] bullet\s remaining.</span>")

/obj/item/energy_magazine/update_icon()
	if(bullets == max_bullets)
		icon_state = "[caliber]-magfull"
	else
		icon_state = "[caliber]-mag"

/obj/item/energy_magazine/osipr
	name = "pulse magazine"
	desc = "Primary ammo for OSIPR. Can be replenished by a recharger."
	icon_state = "osipr-magfull"
	w_class = 3.0
	bullets = 30
	max_bullets = 30
	caliber = "osipr"
	bullet_type = /obj/item/projectile/bullet/osipr

#undef OSIPR_PRIMARY_FIRE
#undef OSIPR_SECONDARY_FIRE

/obj/item/osipr_core
	name = "dark energy core"
	desc = "Secondary ammo for OSIPR."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-core"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0

/obj/item/osipr_core/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
