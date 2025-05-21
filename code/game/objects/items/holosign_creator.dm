/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "signmaker"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/list/signs
	var/max_signs = 10
	//time to create a holosign in deciseconds.
	var/creation_time = 0
	//holosign image that is projected
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once
	/// List of special things we can project holofans under/through.
	var/list/projectable_through = list(
		/obj/machinery/door,
		/obj/structure/mineral_door,
	)

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)
	RegisterSignal(src, COMSIG_OBJ_PAINTED, TYPE_PROC_REF(/obj/item/holosign_creator, on_color_change))

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, list/modifiers)
	interact_with_atom(target, user, modifiers)

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	if(!signs)
		return
	. += span_notice("It is currently maintaining <b>[signs.len]/[max_signs]</b> projections.")

/obj/item/holosign_creator/check_allowed_items(atom/target, not_inside, target_self)
	if(HAS_TRAIT(target, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return FALSE
	return ..()

/obj/item/holosign_creator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!check_allowed_items(interacting_with, not_inside = TRUE))
		return NONE

	var/turf/target_turf = get_turf(interacting_with)
	var/obj/structure/holosign/target_holosign = locate(holosign_type) in target_turf

	if(target_holosign)
		return ITEM_INTERACT_BLOCKING
	if(target_turf.is_blocked_turf(TRUE, ignore_atoms = projectable_through, type_list = TRUE)) //can't put holograms on a tile that has dense stuff
		return ITEM_INTERACT_BLOCKING
	if(holocreator_busy)
		balloon_alert(user, "busy making a hologram!")
		return ITEM_INTERACT_BLOCKING
	if(LAZYLEN(signs) >= max_signs)
		balloon_alert(user, "max capacity!")
		return ITEM_INTERACT_BLOCKING

	playsound(src, 'sound/machines/click.ogg', 20, TRUE)

	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = interacting_with))
			holocreator_busy = FALSE
			return ITEM_INTERACT_BLOCKING
		holocreator_busy = FALSE
		if(LAZYLEN(signs) >= max_signs)
			return ITEM_INTERACT_BLOCKING
		if(target_turf.is_blocked_turf(TRUE, ignore_atoms = projectable_through, type_list = TRUE)) //don't try to sneak dense stuff on our tile during the wait.
			return ITEM_INTERACT_BLOCKING

	target_holosign = create_holosign(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/proc/create_holosign(atom/target, mob/user)
	var/atom/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	return new_holosign

/obj/item/holosign_creator/attack_self(mob/user)
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			qdel(hologram)
		balloon_alert(user, "holograms cleared")

/obj/item/holosign_creator/Destroy()
	. = ..()
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			qdel(hologram)

/obj/item/holosign_creator/proc/on_color_change(obj/item/holosign_creator, mob/user, obj/item/toy/crayon/spraycan/spraycan, is_dark_color)
	SIGNAL_HANDLER
	if(!spraycan.actually_paints)
		return

	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			hologram.color = color

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	creation_time = 1 SECONDS
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers. You can remotely open barriers with it."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 2 SECONDS
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers. You can remotely open barriers with it."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 1 SECONDS
	max_signs = 12

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0
	max_signs = 6
	projectable_through = list(
		/obj/machinery/door,
		/obj/structure/mineral_door,
		/obj/structure/window,
		/obj/structure/grille,
	)
	/// Clearview holograms don't catch clicks and are more transparent
	var/clearview = FALSE
	/// Timer for auto-turning off clearview
	var/clearview_timer

/obj/item/holosign_creator/atmos/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/holosign_creator/atmos/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(LAZYLEN(signs))
		context[SCREENTIP_CONTEXT_RMB] = "[clearview ? "Turn off" : "Temporarily activate"] clearview"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/holosign_creator/atmos/create_holosign(atom/target, mob/user)
	var/obj/structure/holosign/barrier/atmos/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	if(clearview)
		new_holosign.clearview_transparency()
	return new_holosign

/obj/item/holosign_creator/atmos/attack_self_secondary(mob/user, modifiers)
	if(clearview)
		reset_hologram_transparency()
		balloon_alert(user, "turned off clearview")
		return
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.clearview_transparency()
		clearview = TRUE
		balloon_alert(user, "turned on clearview")
		clearview_timer = addtimer(CALLBACK(src, PROC_REF(reset_hologram_transparency)), 40 SECONDS, TIMER_STOPPABLE)
	return ..()

/obj/item/holosign_creator/atmos/proc/reset_hologram_transparency()
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.reset_transparency()
		clearview = FALSE
		deltimer(clearview_timer)

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	creation_time = 1 SECONDS
	max_signs = 6

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 1.5 SECONDS
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = FALSE

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/borg = user

		if(shock)
			to_chat(user, span_notice("You clear all active holograms, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 0.5 SECONDS
			for(var/obj/structure/holosign/hologram as anything in signs)
				qdel(hologram)
			shock = FALSE
			return
		if(borg.emagged && !shock)
			to_chat(user, span_warning("You clear all active holograms, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 3 SECONDS
			for(var/obj/structure/holosign/hologram as anything in signs)
				qdel(hologram)
			shock = TRUE
			return
	for(var/obj/structure/holosign/hologram as anything in signs)
		qdel(hologram)
	balloon_alert(user, "holograms cleared")
