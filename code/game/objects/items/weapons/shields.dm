/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

	IsShield()
		return 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
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

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 1
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/weapon/cloaking_device //Why the fuck is this in shields.dm?
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/cloaking_device/proc/toggle()
	active = !active
	icon_state = "shield[active]"
	if(isliving(loc))
		var/mob/living/livingloc = loc
		if(active)
			livingloc.cloak_stacks += src
		else
			livingloc.cloak_stacks -= src
		livingloc.update_transform()

/obj/item/weapon/cloaking_device/attack_self(mob/user)
	toggle()
	add_fingerprint(user)
	user << "\blue The cloaking device is now [!active ? "in" : ""]active."
	return ..()

/obj/item/weapon/cloaking_device/emp_act(severity)
	if(active)
		toggle()
	return ..()

/obj/item/weapon/cloaking_device/dropped(mob/living/user)
	if(istype(user) && active)
		user.cloak_stacks -= src
		user.update_transform()
	return ..()

/obj/item/weapon/cloaking_device/pickup(mob/living/user)
	if(istype(user) && active)
		user.cloak_stacks[src] = src //Won't add the same thing more than once
		user.update_transform()
	return ..()