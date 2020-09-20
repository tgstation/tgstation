/obj/item/melee/transforming/energy/nanotrasen
	name = "living metal sword"
	desc = "Living metal developed by nanotrasen scientists designed to remember the form of a sharp blade. It's never perfect at it's imitation, but it's always razor sharp."
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state = "living0"
	icon_state_on = "living1"

	force = 3
	throwforce = 5
	hitsound = "swing_hit" //it starts deactivated
	attack_verb_off = list("taps", "pokes")
	throw_speed = 3
	throw_range = 5
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 75, "impact_pain_mult" = 10)
	armour_penetration = 35
	block_chance = 50

/obj/item/melee/transforming/energy/nanotrasen/transform_messages(mob/living/user, supress_message_text)
	playsound(user, 'sound/effects/blobattack.ogg', 35, TRUE)  //changed it from 50% volume to 35% because deafness
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now shaped into a weapon":"can now be concealed"].</span>")

/obj/item/shield/riot/tele/living
	name = "living metal shield"
	desc = "Living metal developed by nanotrasen scientists designed to remember the form of a sharp blade. It's never perfect at it's imitation, but it's always nigh unbreakable."
	icon_state = "living0"

/obj/item/shield/riot/tele/living/attack_self(mob/living/user)
	active = !active
	icon_state = "living[active]"
	playsound(user, 'sound/effects/blobattack.ogg', 35, TRUE)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		to_chat(user, "<span class='notice'>[src] is now shaped into a shield.</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)

/obj/item/gun/ballistic/revolver/nanotrasen
	name = "laser revolver"
	desc = "A heavily modified nanotrasen revolver. Uses overcharged batteries instead of recharging because of the intense power cost." //usually used by NANOTRASEN
	icon_state = "laserolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/battery

/obj/item/ammo_box/magazine/internal/cylinder/battery
	name = "nanotrasen revolver cylinder"
	ammo_type = /obj/item/ammo_casing/battery
	caliber = "microcharge"
	max_ammo = 7

//nt revolver casing
/obj/item/ammo_casing/battery
	name = "microcharge battery casing"
	desc = "A microcharge battery casing."
	caliber = "microcharge"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	projectile_type = /obj/projectile/beam/laser/heavylaser/revolver

/obj/projectile/beam/laser/heavylaser/revolver
	name = "overcharged laser"
	damage = 60
