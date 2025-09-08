///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "This module, brought to you by Nakamura Engineering, has two components. \
		The first component is a series of thrusters and a computerized location subroutine installed into the \
		very control unit of the suit, allowing it flight at highway speeds using the suit's access locks \
		to navigate through the station, and to be able to locate the second part of the system; \
		a pathfinding implant installed into the base of the user's spine, \
		broadcasting their location to the suit and allowing them to recall it to their person at any time. \
		The implant is stored in the module and needs to be injected in a human to function. \
		Nakamura Engineering swears up and down there's airbrakes."
	icon_state = "pathfinder"
	complexity = 1
	module_type = MODULE_USABLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	allow_flags = list(MODULE_ALLOW_INACTIVE|MODULE_ALLOW_UNWORN)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant
	/// Whether the implant has been used or not
	var/implant_inside = TRUE
	/// The jet icon we apply to the MOD.
	var/image/jet_icon
	/// Allow suit activation - Lets this module be recalled from the MOD.
	var/allow_suit_activation = FALSE // I'm not here to argue about balance


/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)


/obj/item/mod/module/pathfinder/Destroy()
	QDEL_NULL(implant)
	return ..()

/obj/item/mod/module/pathfinder/Exited(atom/movable/gone, direction)
	if(gone == implant)
		implant_inside = FALSE
		update_icon_state()
	return ..()

/obj/item/mod/module/pathfinder/update_icon_state()
	. = ..()
	icon_state = implant_inside ? "pathfinder" : "pathfinder_empty"

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant_inside)
		. += span_notice("Use it on a human to implant them.")
	else
		. += span_warning("The implant is missing.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!ishuman(target) || !implant_inside) // Not human, or no implant in module
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		balloon_alert(user, "interrupted!")
		return
	if(!implant.implant(target, user)) // If implant fails
		balloon_alert(user, "can't implant!")
		return
	if(target == user)
		to_chat(user, span_notice("You implant yourself with [implant]."))
	else
		target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you with [implant]."))
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)

/obj/item/mod/module/pathfinder/on_use(mob/activator)
	. = ..()
	if(mod.wearer && implant_inside) // implant them
		try_implant(activator)
		return
	if(mod.wearer)
		balloon_alert(activator, "suit already worn!")
	else
		recall(activator)


/// Assuming we have a wearer, attempt to implant them.
/obj/item/mod/module/pathfinder/proc/try_implant(mob/activator)
	if(!ishuman(mod.wearer)) // Wearer isn't human
		return
	if(!implant.implant(mod.wearer, mod.wearer))
		balloon_alert(activator, "can't implant!")
		return
	balloon_alert(activator, "implanted")
	if(!(activator == mod.wearer)) // someone else implanted you
		balloon_alert(mod.wearer, "pathfinder MOD tracker implanted!")
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)

/obj/item/mod/module/pathfinder/proc/attach(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(mod.slot_flags) && !human_user.dropItemToGround(human_user.get_item_by_slot(mod.slot_flags)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	balloon_alert(human_user, "[mod] attached")
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_energy_cost)

/obj/item/mod/module/pathfinder/proc/recall(mob/recaller)
	if(!implant)
		balloon_alert(recaller, "no target implant!")
		return FALSE
	if(recaller != implant.imp_in && !allow_suit_activation) // No pAI recalling
		balloon_alert(recaller, "sector safety regulations prevent MOD-side recalling!")
		return FALSE
	if(mod.open)
		balloon_alert(recaller, "cover open!")
		return FALSE
	if(mod.ai_controller)
		balloon_alert(recaller, "already moving!")
		return FALSE
	if(ismob(get_atom_on_turf(mod)))
		balloon_alert(recaller, "already on someone!")
		return FALSE
	if(mod.z != implant.imp_in.z || get_dist(implant.imp_in, mod) > MOD_AI_RANGE)
		balloon_alert(recaller, "too far!")
		return FALSE
	var/datum/ai_controller/mod_ai = new /datum/ai_controller/mod(mod)
	mod.ai_controller = mod_ai
	mod_ai.set_movement_target(type, implant.imp_in)
	mod_ai.set_blackboard_key(BB_MOD_TARGET, implant.imp_in)
	mod_ai.set_blackboard_key(BB_MOD_MODULE, src)
	mod.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	mod.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	animate(mod, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	mod.add_overlay(jet_icon)
	RegisterSignal(mod, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	balloon_alert(recaller, "suit recalled")
	if(!(recaller == mod.wearer))
		balloon_alert(mod.wearer, "suit recalled")
	return TRUE

/obj/item/mod/module/pathfinder/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, implant.imp_in))
	source.transform = mod_matrix

/obj/item/mod/module/pathfinder/proc/end_recall(successful = TRUE)
	if(!mod)
		return
	QDEL_NULL(mod.ai_controller)
	mod.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	REMOVE_TRAIT(mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	mod.RemoveElement(/datum/element/movetype_handler)
	mod.cut_overlay(jet_icon)
	mod.transform = matrix()
	UnregisterSignal(mod, COMSIG_MOVABLE_MOVED)
	if(!successful)
		balloon_alert(implant.imp_in, "suit lost connection!")

// ###########
// THE INPLANT
// ###########


/obj/item/implant/mod
	name = "MOD pathfinder implant"
	desc = "Lets you recall a MODsuit to you at any time."
	actions_types = list(/datum/action/item_action/mod_recall)
	allow_multiple = TRUE // Surgrey is annoying if you loose your MOD
	/// The pathfinder module we are linked to.
	var/obj/item/mod/module/pathfinder/module



/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc

/obj/item/implant/mod/Destroy()
	if(module?.mod?.ai_controller)
		module.end_recall(successful = FALSE)
	module = null
	return ..()

/obj/item/implant/mod/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Nakamura Engineering Pathfinder Implant<BR> \
		<b>Implant Details:</b> Allows for the recall of a Modular Outerwear Device by the implant owner at any time.<BR>"


/datum/action/item_action/mod_recall
	name = "Recall MOD"
	desc = "Recall a MODsuit anyplace, anytime."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_mod"
	overlay_icon_state = "bg_mod_border"
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon_state = "recall"
	/// The cooldown for the recall.
	COOLDOWN_DECLARE(recall_cooldown)

/datum/action/item_action/mod_recall/New(Target)
	..()
	if(!istype(Target, /obj/item/implant/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/do_effect(trigger_flags)
	var/obj/item/implant/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(owner, "on cooldown!")
		return
	if(implant.module.recall(owner)) // change this
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)
