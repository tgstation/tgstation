/obj/structure/tank_holder
	name = "tank holder"
	desc = "A metallic frame that can hold tanks and extinguishers."
	icon = 'icons/obj/tank.dmi'
	icon_state = "holder"

	custom_materials = list(/datum/material/iron = 2000)

	density = FALSE
	anchored = FALSE
	pass_flags = LETPASSTHROW
	max_integrity = 20

	resistance_flags = FIRE_PROOF

	/// The stored tank. If this is a path, it gets created into contents at Initialize.
	var/obj/item/tank

/obj/structure/tank_holder/Initialize()
	. = ..()
	if(tank)
		after_put_tank(new tank)

/obj/structure/tank_holder/Destroy()
	if(tank)
		QDEL_NULL(tank)
	return ..()

/obj/structure/tank_holder/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && mover.throwing)
		return TRUE

/obj/structure/tank_holder/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is held together by some <b>screws</b>.</span>"

/obj/structure/tank_holder/attackby(obj/item/W, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(contents.len)
		to_chat(user, "<span class='warning'>There's already something in [src].</span>")
		return

	if(!W.tank_holder_icon_state)
		to_chat(user, "<span class='warning'>[W] does not fit in [src].</span>")
		return

	if(!user.transferItemToLoc(W, src))
		return
	to_chat(user, "<span class='notice'>You put [W] into [src].</span>")
	after_put_tank(W)

/obj/structure/tank_holder/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(tank)
		return FALSE
	I.play_tool_sound(src)
	deconstruct(TRUE)
	return TRUE

/obj/structure/tank_holder/deconstruct(disassembled = TRUE)
	new /obj/item/stack/rods(get_turf(src), 2)
	if(tank)
		tank.forceMove(get_turf(src))
		tank = null
	qdel(src)

/obj/structure/tank_holder/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/tank_holder/attack_hand(mob/user)
	if(!tank)
		return ..()
	if(!Adjacent(user) || issilicon(user))
		return ..()
	to_chat(user, "<span class='notice'>You take [tank] from [src].</span>")
	add_fingerprint(user)
	user.put_in_hands(tank)
	after_remove_tank()

/obj/structure/tank_holder/handle_atom_del(atom/A)
	if(A == tank)
		after_remove_tank()
	return ..()

/obj/structure/tank_holder/contents_explosion(severity, target)
	if(tank)
		tank.ex_act(severity, target)

/// Call this after inserting the tank into contents in order to update references, icon
/// and density.
/obj/structure/tank_holder/proc/after_put_tank(obj/item/tank_)
	tank = tank_
	icon_state = tank.tank_holder_icon_state
	density = TRUE

/// Call this after taking the tank from contents in order to update references, icon
/// and density.
/obj/structure/tank_holder/proc/after_remove_tank()
	tank = null
	icon_state = "holder"
	density = FALSE

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
