/obj/item/weapon/shield
	name = "shield"
	block_chance = 50

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	slot_flags = SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = 4
	materials = list(MAT_GLASS=7500, MAT_METAL=1000)
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time


/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	return ..()

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"

/obj/item/weapon/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	materials = list()
	burn_state = FLAMMABLE
	block_chance = 30

/obj/item/weapon/toggle/energy_shield
	name = "energy combat shield"
	desc = "A shield capable of stopping most melee attacks. Protects user from almost all energy projectiles. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	w_class = 1
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	force_on = 10
	throwforce_on = 8
	icon_state_on = "eshield1"
	w_class_on = 4
	activation_sound = 'sound/weapons/saberon.ogg'

/obj/item/weapon/toggle/energy_shield/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	return 0

/obj/item/weapon/toggle/energy_shield/IsReflect()
	return (active)

/obj/item/weapon/toggle/energy_shield/attack_self(mob/living/carbon/human/user)
	..()
	if(!active)
		user << "<span class='notice'>[src] can now be concealed.</span>"
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)

/obj/item/weapon/toggle/tele_shield
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "teleriot0"
	slot_flags = null
	force = 3
	block_chance = 50
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = 3
	force_on = 8
	throwforce_on = 5
	icon_state_on = "teleriot1"
	w_class_on = 4

/obj/item/weapon/toggle/tele_shield/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(active)
		return ..()
	return 0

/obj/item/weapon/toggle/tele_shield/attack_self(mob/living/user)
	..()
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)