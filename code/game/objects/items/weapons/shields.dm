/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	slot_flags = SLOT_BACK
	force = 8
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = 4
	materials = list(MAT_GLASS=7500, MAT_METAL=1000)
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/IsShield()
	return 1

/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"

/obj/item/weapon/shield/energy
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
	var/active = 0

/obj/item/weapon/shield/energy/IsShield()
	return (active)

/obj/item/weapon/shield/energy/IsReflect()
	return (active)

/obj/item/weapon/shield/energy/attack_self(mob/living/carbon/human/user)
	if(user.disabilities & CLUMSY && prob(50))
		user << "<span class='warning'>You beat yourself in the head with [src].</span>"
		user.take_organ_damage(5)
	active = !active
	icon_state = "eshield[active]"

	if(active)
		force = 10
		throwforce = 8
		throw_speed = 2
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		user << "<span class='notice'>[src] is now active.</span>"
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = 1
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		user << "<span class='notice'>[src] can now be concealed.</span>"
	add_fingerprint(user)

/obj/item/weapon/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "teleriot0"
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = 3
	var/active = 0

/obj/item/weapon/shield/riot/tele/IsShield()
	return (active)

/obj/item/weapon/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = 4
		slot_flags = SLOT_BACK
		user << "<span class='notice'>You extend \the [src].</span>"
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = 3
		slot_flags = null
		user << "<span class='notice'>[src] can now be concealed.</span>"
	add_fingerprint(user)
