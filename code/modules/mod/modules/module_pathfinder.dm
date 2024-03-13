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
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	QDEL_NULL(implant)
	return ..()

/obj/item/mod/module/pathfinder/Exited(atom/movable/gone, direction)
	if(gone == implant)
		implant = null
		update_icon_state()
	return ..()

/obj/item/mod/module/pathfinder/update_icon_state()
	. = ..()
	icon_state = implant ? "pathfinder" : "pathfinder_empty"

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Use it on a human to implant them.")
	else
		. += span_warning("The implant is missing.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		balloon_alert(user, "interrupted!")
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "can't implant!")
		return
	if(target == user)
		to_chat(user, span_notice("You implant yourself with [implant]."))
	else
		target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you with [implant]."))
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
	drain_power(use_power_cost)

/obj/item/implant/mod
	name = "MOD pathfinder implant"
	desc = "Lets you recall a MODsuit to you at any time."
	actions_types = list(/datum/action/item_action/mod_recall)
	/// The pathfinder module we are linked to.
	var/obj/item/mod/module/pathfinder/module
	/// The jet icon we apply to the MOD.
	var/image/jet_icon
	/// Are we currently travelling?
	var/in_transit = FALSE

/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/implant/mod/Destroy()
	module = null
	jet_icon = null
	return ..()

/obj/item/implant/mod/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Nakamura Engineering Pathfinder Implant<BR> \
		<b>Implant Details:</b> Allows for the recall of a Modular Outerwear Device by the implant owner at any time.<BR>"

/obj/item/implant/mod/proc/recall()
	if(!module?.mod)
		balloon_alert(imp_in, "no connected suit!")
		return FALSE
	if(module.mod.open)
		balloon_alert(imp_in, "suit is open!")
		return FALSE
	if(in_transit)
		balloon_alert(imp_in, "already in transit!")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		balloon_alert(imp_in, "already on someone!")
		return FALSE
	in_transit = TRUE
	animate(module.mod, 0.2, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	module.mod.Shake(pixelshiftx = 1, pixelshifty = 1, duration = PATHFINDER_PRE_ANIMATE_TIME)
	addtimer(CALLBACK(src, PROC_REF(do_recall)), PATHFINDER_PRE_ANIMATE_TIME, TIMER_DELETE_ME)
	return TRUE

/// Pod-transport the suit to its owner
/obj/item/implant/mod/proc/do_recall()
	playsound(module.mod, 'sound/vehicles/rocketlaunch.ogg', vol = 80, vary = FALSE)
	var/turf/land_target = get_turf(imp_in)
	var/obj/structure/closet/supplypod/pod = podspawn(list(
		"target" = get_turf(module.mod),
		"path" = /obj/structure/closet/supplypod/transport/module_pathfinder,
		"reverse_dropoff_coords" = list(land_target.x, land_target.y, land_target.z),
	))
	pod.insert(module.mod, pod)
	RegisterSignal(pod, COMSIG_SUPPLYPOD_RETURNING, PROC_REF(pod_takeoff))

/// Track when pod has taken off so we don't falsely report the initial landing
/obj/item/implant/mod/proc/pod_takeoff(datum/pod)
	SIGNAL_HANDLER
	RegisterSignal(pod, COMSIG_SUPPLYPOD_LANDED, PROC_REF(pod_landed))

/// When the pod landed, we can recall again
/obj/item/implant/mod/proc/pod_landed()
	SIGNAL_HANDLER
	in_transit = FALSE
	playsound(module.mod, 'sound/items/handling/toolbox_drop.ogg', vol = 80, vary = FALSE)

/// Special pod subtype we use just to make insertion check easy
/obj/structure/closet/supplypod/transport/module_pathfinder

/obj/structure/closet/supplypod/transport/module_pathfinder/insertion_allowed(atom/to_insert)
	return istype(to_insert, /obj/item/mod/control)

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

/datum/action/item_action/mod_recall/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/implant/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(implant.imp_in, "on cooldown!")
		return
	if(!implant.recall())
		return
	COOLDOWN_START(src, recall_cooldown, 5 SECONDS)

#undef PATHFINDER_PRE_ANIMATE_TIME
