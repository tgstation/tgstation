///?
/obj/structure/tank_holder
	name = "tank holder"
	desc = "A metallic frame that can hold tanks and extinguishers."
	icon = 'icons/obj/tank.dmi'
	icon_state = "holder"

	custom_materials = list(/datum/material/iron = 2000)

	density = FALSE
	anchored = FALSE
	pass_flags_self = LETPASSTHROW
	max_integrity = 20

	resistance_flags = FIRE_PROOF

	/// The stored tank. If this is a path, it gets created into contents at Initialize.
	var/obj/item/tank

/obj/structure/tank_holder/Initialize()
	. = ..()
	if(tank)
		var/obj/item/tank_ = new tank(null)
		tank = null
		SEND_SIGNAL(tank_, COMSIG_CONTAINER_TRY_ATTACH, src, null)

/obj/structure/tank_holder/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/structure/tank_holder/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && mover.throwing)
		return TRUE

/obj/structure/tank_holder/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is held together by some <b>screws</b>.</span>"

/obj/structure/tank_holder/attackby(obj/item/W, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(!SEND_SIGNAL(W, COMSIG_CONTAINER_TRY_ATTACH, src, user))
		to_chat(user, "<span class='warning'>[W] does not fit in [src].</span>")

/obj/structure/tank_holder/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(tank)
		return FALSE
	I.play_tool_sound(src)
	deconstruct(TRUE)
	return TRUE

/obj/structure/tank_holder/deconstruct(disassembled = TRUE)
	var/atom/Tsec = drop_location()
	new /obj/item/stack/rods(Tsec, 2)
	if(tank)
		tank.forceMove(Tsec)
		after_detach_tank()
	qdel(src)

/obj/structure/tank_holder/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/tank_holder/attack_hand(mob/user, list/modifiers)
	if(!tank)
		return ..()
	if(!Adjacent(user) || issilicon(user))
		return ..()
	to_chat(user, "<span class='notice'>You take [tank] from [src].</span>")
	add_fingerprint(user)
	tank.add_fingerprint(user)
	user.put_in_hands(tank)
	after_detach_tank()

/obj/structure/tank_holder/handle_atom_del(atom/A)
	if(A == tank)
		after_detach_tank()
	return ..()

/obj/structure/tank_holder/contents_explosion(severity, target)
	if(tank)
		tank.ex_act(severity, target)

/// Call this after taking the tank from contents in order to update references, icon
/// and density.
/obj/structure/tank_holder/proc/after_detach_tank()
	tank = null
	density = FALSE
	icon_state = "holder"

/obj/structure/tank_holder/oxygen
	icon_state = "holder_oxygen"
	tank = /obj/item/tank/internals/oxygen

/obj/structure/tank_holder/anesthetic
	icon_state = "holder_anesthetic"
	tank = /obj/item/tank/internals/anesthetic

/obj/structure/tank_holder/oxygen/yellow
	icon_state = "holder_oxygen_f"
	tank = /obj/item/tank/internals/oxygen/yellow

/obj/structure/tank_holder/oxygen/red
	icon_state = "holder_oxygen_fr"
	tank = /obj/item/tank/internals/oxygen/red

/obj/structure/tank_holder/emergency_oxygen
	icon_state = "holder_emergency"
	tank = /obj/item/tank/internals/emergency_oxygen

/obj/structure/tank_holder/emergency_oxygen/engi
	icon_state = "holder_emergency_engi"
	tank = /obj/item/tank/internals/emergency_oxygen/engi

/obj/structure/tank_holder/generic
	icon_state = "holder_generic"
	tank = /obj/item/tank/internals/generic

/obj/structure/tank_holder/extinguisher
	icon_state = "holder_extinguisher"
	tank = /obj/item/extinguisher

/obj/structure/tank_holder/extinguisher/advanced
	icon_state = "holder_foam_extinguisher"
	tank = /obj/item/extinguisher/advanced
