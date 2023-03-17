/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
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
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

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
	return .

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "holograms cleared")

/obj/item/holosign_creator/Destroy()
	. = ..()
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)


/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	creation_time = 20
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30
	max_signs = 6

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
	creation_time = 30
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, span_notice("You clear all active holograms, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			for(var/sign in signs)
				qdel(sign)
			shock = 0
			return
		if(R.emagged && !shock)
			to_chat(user, span_warning("You clear all active holograms, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			for(var/sign in signs)
				qdel(sign)
			shock = 1
			return
	for(var/sign in signs)
		qdel(sign)
	balloon_alert(user, "holograms cleared")
