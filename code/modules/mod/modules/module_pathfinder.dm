#define PATHFINDER_PRE_ANIMATE_TIME (2 SECONDS)

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
	/// Are we currently travelling?
	var/in_transit = FALSE


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
		balloon_alert(mod.wearer, "tracker implanted!")
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
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_energy_cost)

/obj/item/mod/module/pathfinder/proc/recall(mob/recaller)
	if(!implant)
		balloon_alert(recaller, "no implant!")
		return FALSE
	if(recaller != implant.imp_in && !allow_suit_activation) // No pAI recalling
		balloon_alert(recaller, "invalid user!")
		return FALSE
	if(mod.open)
		balloon_alert(recaller, "cover open!")
		return FALSE
	if(in_transit)
		balloon_alert(recaller, "suit in transit!")
		return FALSE
	var/atom_on_turf = get_atom_on_turf(mod)
	if(ismob(atom_on_turf))
		if(atom_on_turf == recaller)
			balloon_alert(recaller, "already worn!")
		else
			recaller.balloon_alert(recaller, "suit is worn by somebody else!")
		return FALSE

	in_transit = TRUE
	animate(mod, 0.5 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	mod.Shake(pixelshiftx = 1, pixelshifty = 1, duration = PATHFINDER_PRE_ANIMATE_TIME)
	addtimer(CALLBACK(src, PROC_REF(do_recall), recaller), PATHFINDER_PRE_ANIMATE_TIME, TIMER_DELETE_ME)

	balloon_alert(recaller, "suit recalled")
	if(!(recaller == mod.wearer))
		balloon_alert(mod.wearer, "suit recalled")
	return TRUE

/// Pod-transport the suit to its owner
/obj/item/mod/module/pathfinder/proc/do_recall(mob/recaller)
	var/container = get_atom_on_turf(mod)
	if(ismob(container))
		balloon_alert(recaller, "launch interrupted!")
		in_transit = FALSE
		return

	if(iscloset(container))
		var/obj/structure/closet/closet = container
		if (!closet.opened)
			if (!closet.open())
				playsound(closet, 'sound/effects/bang.ogg', vol = 50, vary = TRUE)
				closet.bust_open()


	mod.add_overlay(jet_icon)
	playsound(mod, 'sound/vehicles/rocketlaunch.ogg', vol = 80, vary = FALSE)
	var/turf/land_target = get_turf(implant.imp_in)
	var/obj/structure/closet/supplypod/pod = podspawn(list(
		"target" = get_turf(mod),
		"path" = /obj/structure/closet/supplypod/transport/module_pathfinder,
		"reverse_dropoff_coords" = list(land_target.x, land_target.y, land_target.z),
	))

	pod.insert(mod, pod)
	RegisterSignal(pod, COMSIG_SUPPLYPOD_RETURNING, PROC_REF(pod_takeoff))

	if (istype(container, /obj/machinery/suit_storage_unit))
		var/obj/machinery/suit_storage_unit/storage = container
		storage.locked = FALSE
		storage.open_machine()

/// Track when pod has taken off so we don't falsely report the initial landing
/obj/item/mod/module/pathfinder/proc/pod_takeoff(datum/pod)
	SIGNAL_HANDLER
	RegisterSignal(pod, COMSIG_SUPPLYPOD_LANDED, PROC_REF(pod_landed))

/// When the pod landed, we can recall again
/obj/item/mod/module/pathfinder/proc/pod_landed()
	SIGNAL_HANDLER
	in_transit = FALSE
	mod.cut_overlay(jet_icon)
	playsound(mod, 'sound/items/handling/toolbox/toolbox_drop.ogg', vol = 80, vary = FALSE)
	if (implant?.imp_in?.Adjacent(src))
		INVOKE_ASYNC(src, PROC_REF(attach), implant.imp_in)

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
	. = ..()
	if(!istype(Target, /obj/item/implant/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/do_effect(trigger_flags)
	var/obj/item/implant/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(owner, "on cooldown!")
		return
	if(implant.module.recall(owner))
		implant.balloon_alert(owner, "suit incoming...")
		COOLDOWN_START(src, recall_cooldown, 5 SECONDS)

/// Special pod subtype we use just to make insertion check easy
/obj/structure/closet/supplypod/transport/module_pathfinder

/obj/structure/closet/supplypod/transport/module_pathfinder/insertion_allowed(atom/to_insert)
	return istype(to_insert, /obj/item/mod/control)

#undef PATHFINDER_PRE_ANIMATE_TIME
