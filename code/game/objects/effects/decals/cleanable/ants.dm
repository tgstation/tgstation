/obj/effect/decal/cleanable/ants
	name = "space ants"
	desc = "A small colony of space ants. They're normally used to the vacuum of space, so they can't climb too well."
	icon = 'icons/obj/debris.dmi'
	icon_state = "ants"
	beauty = -150
	plane = GAME_PLANE
	layer = LOW_OBJ_LAYER
	decal_reagent = /datum/reagent/ants
	reagent_amount = 5
	/// Sound the ants make when biting
	var/bite_sound = 'sound/items/weapons/bite.ogg'

/obj/effect/decal/cleanable/ants/Initialize(mapload)
	if(mapload && reagent_amount > 2)
		reagent_amount = rand((reagent_amount - 2), reagent_amount)
	. = ..()
	update_ant_damage()

/obj/effect/decal/cleanable/ants/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, bite_sound))
		update_ant_damage()

/obj/effect/decal/cleanable/ants/handle_merge_decal(obj/effect/decal/cleanable/merger)
	. = ..()
	var/obj/effect/decal/cleanable/ants/ants = merger
	ants.update_ant_damage()

/obj/effect/decal/cleanable/ants/proc/update_ant_damage(ant_min_damage, ant_max_damage)
	if(!ant_max_damage)
		ant_max_damage = min(10, round((reagents ? reagents.get_reagent_amount(/datum/reagent/ants) : reagent_amount) * 0.1,0.1)) // 100u ants = 10 max_damage
	if(!ant_min_damage)
		ant_min_damage = 0.1
	var/ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN) /// Small amounts of ants won't be able to bite through shoes.
	if(ant_max_damage > 1)
		ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

	var/datum/component/caltrop/caltrop_comp = GetComponent(/datum/component/caltrop)
	if(caltrop_comp)
		caltrop_comp.min_damage = ant_min_damage
		caltrop_comp.max_damage = ant_max_damage
		caltrop_comp.flags = ant_flags
		caltrop_comp.soundfile = bite_sound
	else
		AddComponent(/datum/component/caltrop, min_damage = ant_min_damage, max_damage = ant_max_damage, flags = ant_flags, soundfile = bite_sound)

	update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/ants/update_icon_state()
	if(istype(src, /obj/effect/decal/cleanable/ants/fire)) //i fucking hate this but you're forced to call parent in update_icon_state()
		return ..()
	if(!(flags_1 & INITIALIZED_1))
		return ..()

	var/datum/component/caltrop/caltrop_comp = GetComponent(/datum/component/caltrop)
	if(!caltrop_comp)
		return ..()

	switch(caltrop_comp.max_damage)
		if(0 to 1)
			icon_state = initial(icon_state)
		if(1.1 to 4)
			icon_state = "[initial(icon_state)]_2"
		if(4.1 to 7)
			icon_state = "[initial(icon_state)]_3"
		if(7.1 to INFINITY)
			icon_state = "[initial(icon_state)]_4"
	return ..()

/obj/effect/decal/cleanable/ants/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_light", src, alpha = src.alpha, effect_type = EMISSIVE_NO_BLOOM)

/obj/effect/decal/cleanable/ants/fire_act(exposed_temperature, exposed_volume)
	new /obj/effect/decal/cleanable/ants/fire(loc)
	qdel(src)

/obj/effect/decal/cleanable/ants/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user.name] starts to burn \the [src] with \the [tool]"), \
		span_notice("You start to burn \the [src]..."))
	if(!tool.use_tool(src, user, 0.2 SECONDS * reagent_amount))
		return ITEM_INTERACT_BLOCKING
	if(HAS_TRAIT(user, TRAIT_EVIL))
		to_chat(user, span_notice("You gleefully burn \the [src] to ash!"))
		user.add_mood_event("ant burning", /datum/mood_event/ants_burned_evil)
	else if(HAS_PERSONALITY(user, /datum/personality/compassionate))
		to_chat(user, span_notice("You feel a pang of guilt as you burn \the [src] to ashes."))
		user.add_mood_event("ant burning", /datum/mood_event/ants_burned_nice)
	else
		to_chat(user, span_notice("You burn \the [src] away."))
	qdel(src)

/obj/effect/decal/cleanable/ants/fire
	name = "space fire ants"
	desc = "A small colony no longer. We are the fire nation."
	decal_reagent = /datum/reagent/ants/fire
	icon_state = "fire_ants"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/ants/fire/update_ant_damage(ant_min_damage, ant_max_damage)
	return ..(15, 25)

/obj/effect/decal/cleanable/ants/fire/fire_act(exposed_temperature, exposed_volume)
	return

/obj/effect/decal/cleanable/ants/fire/welder_act(mob/living/user, obj/item/tool)
	return

/datum/mood_event/ants_burned_evil
	description = "I feel powerful having burned those pathetic ants."
	mood_change = 2
	timeout = 1 MINUTES

/datum/mood_event/ants_burned_nice
	description = "I feel awful having burned those defenseless ants."
	mood_change = -2
	timeout = 1 MINUTES
