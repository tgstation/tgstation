// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/silicon = 5, /datum/reagent/nitrogen = 10) //Nitrogen is used as a cheaper alternative to argon in incandescent lighbulbs
	///How much light it gives off
	var/brightness = 2
	///LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/status = LIGHT_OK
	///Base icon state for each bulb types
	var/base_state
	///Number of times switched on and off
	var/switchcount = 0

/obj/item/light/Initialize(mapload)
	. = ..()
	create_reagents(LIGHT_REAGENT_CAPACITY, INJECTABLE | DRAINABLE | SEALED_CONTAINER | TRANSPARENT)
	AddComponent(/datum/component/caltrop, min_damage = force)
	update_icon_state()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/golem_food, golem_food_key = /obj/item/light, extra_validation = CALLBACK(src, PROC_REF(is_intact)))

/obj/item/light/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	. = ..()

	if(istype(attacking_item, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/lightreplacer = attacking_item
		lightreplacer.attackby(src, user)

/// Returns true if bulb is intact
/obj/item/light/proc/is_intact()
	return status == LIGHT_OK

/obj/item/light/suicide_act(mob/living/carbon/user)
	if (status == LIGHT_BROKEN)
		user.visible_message(span_suicide("[user] begins to stab [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] begins to eat \the [src]! It looks like [user.p_theyre()] not very bright!"))
		shatter()
	return BRUTELOSS

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	inhand_icon_state = "ltube"
	icon_angle = -45
	brightness = 8
	custom_price = PAYCHECK_CREW * 0.5

/obj/item/light/tube/update_icon_state()
	. = ..()
	switch(status)
		if(LIGHT_BURNED)
			inhand_icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			inhand_icon_state = "[base_state]-broken"

/obj/item/light/tube/broken
	status = LIGHT_BROKEN
	sharpness = SHARP_POINTY

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	icon_angle = -90
	inhand_icon_state = "contvapour"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	brightness = 4
	custom_price = PAYCHECK_CREW * 0.4

/obj/item/light/bulb/broken
	status = LIGHT_BROKEN
	sharpness = SHARP_POINTY

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //not caught by a mob
		shatter()

// update the icon state and description of the light

/obj/item/light/update_icon_state()
	. = ..()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"

/obj/item/light/update_desc()
	. = ..()
	switch(status)
		if(LIGHT_OK)
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			desc = "A broken [name]."

/obj/item/light/proc/on_entered(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	if(!isliving(moving_atom))
		return
	var/mob/living/moving_mob = moving_atom
	if(!(moving_mob.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || moving_mob.buckled)
		playsound(src, 'sound/effects/footstep/glass_step.ogg', HAS_TRAIT(moving_mob, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)
		if(status == LIGHT_BURNED || status == LIGHT_OK)
			shatter(moving_mob)

/obj/item/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter(M)

/obj/item/light/attack_atom(obj/O, mob/living/user, list/modifiers)
	..()
	shatter(O)

/obj/item/light/proc/shatter(target)
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message(span_danger("[src] shatters."),span_hear("You hear a small glass object shatter."))
		status = LIGHT_BROKEN
		force = 5
		sharpness = SHARP_POINTY
		playsound(loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(length(reagents.reagent_list))
			visible_message(span_danger("The contents of [src] splash onto you as you step on it!"),span_hear("You feel the contents of [src] splash onto you as you step on it!."))
			reagents.expose(target, TOUCH)
		update_appearance(UPDATE_DESC | UPDATE_ICON)
