#define MECHWEAPON_PIN_ADD_DELAY 3 SECONDS
#define MECHWEAPON_PIN_REMOVAL_DELAY 5 SECONDS

/obj/item/mecha_parts/mecha_equipment/weapon/Initialize()
	. = ..()
	if(pin)
		pin = new pin(src)

/obj/item/mecha_parts/mecha_equipment/weapon/Destroy()
	. = ..()
	if(isobj(pin))
		QDEL_NULL(pin)

/obj/item/mecha_parts/mecha_equipment/weapon/handle_atom_del(atom/A)
	if(A == pin)
		pin = null
	return ..()


/obj/item/mecha_parts/mecha_equipment/weapon/examine(mob/user)
	. = ..()
	if(pin)
		. += "It has \a [pin] installed."
	else
		. += "It doesn't have a <b>firing pin</b> installed, and won't fire."


/obj/item/mecha_parts/mecha_equipment/weapon/proc/handle_pins()

	var/mob/user = chassis.occupant
	if(!user) //Sanity check
		return FALSE

	if(!pin)
		to_chat(user, "<span class='warning'>[src]'s trigger is locked. This weapon doesn't have a firing pin installed!</span>")
		return FALSE

	if(chassis.silicon_pilot) //We just need any kind of firing pin for AI/MMIs/Positronic Brains; they are always authorized.
		return TRUE

	if(pin.pin_auth(user) || (pin.obj_flags & EMAGGED))
		return TRUE

	pin.auth_fail(user)
	return FALSE


/obj/item/mecha_parts/mecha_equipment/weapon/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(I.tool_behaviour == TOOL_SCREWDRIVER && pin)
		visible_message("<span class='notice'>[user] begins to remove [src]'s firing pin...</span>",  \
				"<span class='notice'>You begin to remove [src]'s firing pin...</span>", null, 3)
		if(!do_after(user, MECHWEAPON_PIN_REMOVAL_DELAY, target = src))
			return
		QDEL_NULL(pin)
		visible_message("<span class='warning'>[user] removes [src]'s firing pin. It can now fit a new pin, but the old one was destroyed in the process.</span>",  \
				"<span class='warning'>You remove [src]'s firing pin, destroying it in the process.</span>",  \
				null, 3)
		playsound(src, pick('sound/items/screwdriver.ogg','sound/items/screwdriver2.ogg'), 30, TRUE)
		return

	if(istype(I, /obj/item/firing_pin))
		var/obj/item/firing_pin/P = I
		if(pin)
			to_chat(user, "<span class='warning'>[src] already has a firing pin installed. You'll need to remove it with a <b>screwdriver</b>.</span>")
			return
		visible_message("<span class='notice'>[user] begins to install [P] into [src]...</span>",  \
				"<span class='notice'>You begin to install [P] into [src]...</span>", null, 3)
		if(!do_after(user, MECHWEAPON_PIN_ADD_DELAY, target = src))
			return
		visible_message("<span class='notice'>[user] installs [P] into [src]...</span>",  \
				"<span class='notice'>You install [P] into [src]...</span>", null, 3)
		playsound(src, 'sound/items/equip/toolbelt_equip.ogg', 30, TRUE)
		P.mechgun_insert(user, src)


/obj/item/firing_pin/proc/mechgun_insert(mob/living/user, obj/item/mecha_parts/mecha_equipment/weapon/G)
	gun = G
	forceMove(gun)
	gun.pin = src
	return

/obj/mecha/combat/proc/unlock_mech_weapons() //Unlock all mech weapons
	for(var/obj/item/I in equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/))
			var/obj/item/mecha_parts/mecha_equipment/weapon/gun = I
			gun.unlock_weapon()


/obj/item/mecha_parts/mecha_equipment/weapon/proc/unlock_weapon() //For admin convenience/spawning unlocked weapons
	if(pin)
		qdel(pin)
	pin = new /obj/item/firing_pin


/obj/item/mecha_parts/mecha_equipment/weapon/Initialize()
	. = ..()
	if(!initial_firing_pin)
		return
	if(!ispath(initial_firing_pin, /obj/item/firing_pin))
		log_mapping("[src] at [AREACOORD(src)] had an invalid firing pin type: [initial_firing_pin].")
	else
		pin = new initial_firing_pin(src)

/obj/item/firing_pin/mech
	name = "electronic mech firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one. This one is specifically designed to be installed into mech and exosuit weaponry only."

/obj/item/firing_pin/mech/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(istype(target, /obj/item/gun))
		to_chat(user, "<span class='warning'>This firing pin is incompatible with guns and only be installed into mech weaponry!</span>")