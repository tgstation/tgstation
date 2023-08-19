///?
/obj/structure/tank_holder
	name = "tank holder"
	desc = "A metallic frame that can hold tanks and extinguishers."
	icon = 'icons/obj/canisters.dmi'
	icon_state = "holder"

	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT)

	density = FALSE
	anchored = FALSE
	pass_flags_self = LETPASSTHROW
	max_integrity = 20

	resistance_flags = FIRE_PROOF

	/// The stored tank. If this is a path, it gets created into contents at Initialize.
	var/obj/item/tank

/obj/structure/tank_holder/Initialize(mapload)
	. = ..()
	if(tank)
		var/obj/item/tank_ = new tank(null)
		tank = null
		SEND_SIGNAL(tank_, COMSIG_CONTAINER_TRY_ATTACH, src, null)

/obj/structure/tank_holder/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/structure/tank_holder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover) && mover.throwing)
		return TRUE

/obj/structure/tank_holder/examine(mob/user)
	. = ..()
	. += "It is [anchored ? "wrenched to the floor." : "The <i>bolts</i> on the bottom are unsecured."]<br/>"
	if(tank)
		. += "It is holding one [tank]."
	else
		. += "It is empty."
	. += span_notice("It is held together by some <b>screws</b>.")

/obj/structure/tank_holder/attackby(obj/item/W, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(W.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(W.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			set_anchored(!anchored)
	else if(!SEND_SIGNAL(W, COMSIG_CONTAINER_TRY_ATTACH, src, user))
		to_chat(user, span_warning("[W] does not fit in [src]."))
	return

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
	qdel(src)

/obj/structure/tank_holder/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/tank_holder/attack_hand(mob/user, list/modifiers)
	if(!tank)
		return ..()
	if(!Adjacent(user) || issilicon(user))
		return ..()
	to_chat(user, span_notice("You take [tank] from [src]."))
	add_fingerprint(user)
	tank.add_fingerprint(user)
	user.put_in_hands(tank)

/obj/structure/tank_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == tank)
		after_detach_tank()

/obj/structure/tank_holder/contents_explosion(severity, target)
	if(!tank)
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += tank
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += tank
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += tank

/// Call this after taking the tank from contents in order to update references, icon
/// and density.
/obj/structure/tank_holder/proc/after_detach_tank()
	tank = null
	set_density(FALSE)
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
