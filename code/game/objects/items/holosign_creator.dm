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

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)
	RegisterSignal(src, COMSIG_OBJ_PAINTED, TYPE_PROC_REF(/obj/item/holosign_creator, on_color_change))

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag, click_parameters)

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	if(!signs)
		return
	. += span_notice("It is currently maintaining <b>[signs.len]/[max_signs]</b> projections.")

/obj/item/holosign_creator/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!check_allowed_items(target, not_inside = TRUE))
		return .
	var/turf/target_turf = get_turf(target)
	var/obj/structure/holosign/target_holosign = locate(holosign_type) in target_turf
	if(target_holosign)
		qdel(target_holosign)
		return .
	if(target_turf.is_blocked_turf(TRUE)) //can't put holograms on a tile that has dense stuff
		return .
	if(holocreator_busy)
		to_chat(user, span_notice("[src] is busy creating a hologram."))
		return .
	if(LAZYLEN(signs) >= max_signs)
		balloon_alert(user, "max capacity!")
		return .
	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = target))
			holocreator_busy = FALSE
			return .
		holocreator_busy = FALSE
		if(LAZYLEN(signs) >= max_signs)
			return .
		if(target_turf.is_blocked_turf(TRUE)) //don't try to sneak dense stuff on our tile during the wait.
			return .
	target_holosign = new holosign_type(get_turf(target), src)
	target_holosign.add_hiddenprint(user)
	if(color)
		target_holosign.color = color
	return .

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

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
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 3 SECONDS
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
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
