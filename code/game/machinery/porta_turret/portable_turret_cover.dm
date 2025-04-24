
/************************
* PORTABLE TURRET COVER *
************************/

/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "turretCover"
	layer = HIGH_OBJ_LAYER
	density = FALSE
	max_integrity = 80
	use_power = NO_POWER_USE
	var/obj/machinery/porta_turret/parent_turret = null

/obj/machinery/porta_turret_cover/Destroy()
	if(parent_turret)
		parent_turret.cover = null
		parent_turret.RemoveInvisibility(type)
		parent_turret = null
	return ..()

//The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!
//>necessary
//I'm not fixing it because i'm fucking bored of this code already, but someone should just reroute these to the parent turret's procs.

/obj/machinery/porta_turret_cover/attack_ai(mob/user)
	return ..() || parent_turret.attack_ai(user)

/obj/machinery/porta_turret_cover/attack_robot(mob/user)
	return ..() || parent_turret.attack_robot(user)

/obj/machinery/porta_turret_cover/attack_hand(mob/user, list/modifiers)
	return ..() || parent_turret.attack_hand(user, modifiers)

/obj/machinery/porta_turret_cover/attack_ghost(mob/user)
	return ..() || parent_turret.attack_ghost(user)

/obj/machinery/porta_turret_cover/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = NONE
	if(parent_turret.locked)
		return

	multi_tool.set_buffer(parent_turret)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/porta_turret_cover/attackby(obj/item/I, mob/user, list/modifiers)
	if(I.tool_behaviour == TOOL_WRENCH && !parent_turret.on)
		if(parent_turret.raised)
			return
		if(!parent_turret.anchored)
			parent_turret.set_anchored(TRUE)
			to_chat(user, span_notice("You secure the exterior bolts on the turret."))
			parent_turret.SetInvisibility(INVISIBILITY_MAXIMUM, id=parent_turret.type, priority=INVISIBILITY_PRIORITY_TURRET_COVER)
			parent_turret.update_appearance()
		else
			parent_turret.set_anchored(FALSE)
			to_chat(user, span_notice("You unsecure the exterior bolts on the turret."))
			parent_turret.SetInvisibility(INVISIBILITY_NONE, id=parent_turret.type, priority=INVISIBILITY_PRIORITY_TURRET_COVER)
			parent_turret.update_appearance()
			qdel(src)
		return

	if(I.GetID())
		if(parent_turret.allowed(user))
			parent_turret.locked = !parent_turret.locked
			to_chat(user, span_notice("Controls are now [parent_turret.locked ? "locked" : "unlocked"]."))
		else
			to_chat(user, span_notice("Access denied."))
		return

	return ..()

/obj/machinery/porta_turret_cover/attacked_by(obj/item/I, mob/user)
	parent_turret.attacked_by(I, user)

/obj/machinery/porta_turret_cover/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	parent_turret.attack_alien(user, modifiers)

/obj/machinery/porta_turret_cover/attack_animal(mob/living/simple_animal/user, list/modifiers)
	parent_turret.attack_animal(user, modifiers)

/obj/machinery/porta_turret_cover/attack_hulk(mob/living/carbon/human/user)
	return parent_turret.attack_hulk(user)

/obj/machinery/porta_turret_cover/emag_act(mob/user, obj/item/card/emag/emag_card)

	if((parent_turret.obj_flags & EMAGGED))
		return FALSE

	balloon_alert(user, "threat assessment circuits shorted")
	audible_message(span_hear("[parent_turret] hums oddly..."))
	parent_turret.obj_flags |= EMAGGED
	parent_turret.on = FALSE
	addtimer(VARSET_CALLBACK(parent_turret, on, TRUE), 4 SECONDS)
	return TRUE
