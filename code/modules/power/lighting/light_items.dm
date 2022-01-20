// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass=100)
	grind_results = list(/datum/reagent/silicon = 5, /datum/reagent/nitrogen = 10) //Nitrogen is used as a cheaper alternative to argon in incandescent lighbulbs
	///True if rigged to explode
	var/rigged = FALSE
	///How much light it gives off
	var/brightness = 2
	///LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/status = LIGHT_OK
	///Base icon state for each bulb types
	var/base_state
	///Number of times switched on and off
	var/switchcount = 0

/obj/item/light/suicide_act(mob/living/carbon/user)
	if (status == LIGHT_BROKEN)
		user.visible_message(span_suicide("[user] begins to stab [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] begins to eat \the [src]! It looks like [user.p_theyre()] not very bright!"))
		shatter()
		return BRUTELOSS

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	inhand_icon_state = "c_tube"
	brightness = 8
	custom_price = PAYCHECK_CREW * 0.5

/obj/item/light/tube/broken
	status = LIGHT_BROKEN

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	inhand_icon_state = "contvapour"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	brightness = 4
	custom_price = PAYCHECK_CREW * 0.4

/obj/item/light/bulb/broken
	status = LIGHT_BROKEN

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //not caught by a mob
		shatter()

// update the icon state and description of the light

/obj/item/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."

/obj/item/light/Initialize(mapload)
	. = ..()
	create_reagents(LIGHT_REAGENT_CAPACITY, INJECTABLE | DRAINABLE)
	AddComponent(/datum/component/caltrop, min_damage = force)
	update()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/light/proc/on_entered(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	if(!isliving(moving_atom))
		return
	var/mob/living/moving_mob = moving_atom
	if(!(moving_mob.movement_type & (FLYING|FLOATING)) || moving_mob.buckled)
		playsound(src, 'sound/effects/glass_step.ogg', HAS_TRAIT(moving_mob, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)
		if(status == LIGHT_BURNED || status == LIGHT_OK)
			shatter()

/obj/item/light/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/**
 * Handles rigging the cell if it contains enough plasma.
 */
/obj/item/light/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	rigged = (reagents.has_reagent(/datum/reagent/toxin/plasma, LIGHT_REAGENT_CAPACITY)) ? TRUE : FALSE //has_reagent returns the reagent datum, we don't want to hold a reference to prevent hard dels
	return NONE

/**
 * Handles the reagent holder datum being deleted for some reason. Probably someone making pizza lights.
 */
/obj/item/light/proc/on_reagents_del(datum/reagents/holder)
	SIGNAL_HANDLER
	UnregisterSignal(holder, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_REAGENTS_NEW_REAGENT,
		COMSIG_REAGENTS_ADD_REAGENT,
		COMSIG_REAGENTS_REM_REAGENT,
		COMSIG_REAGENTS_DEL_REAGENT,
	))
	return NONE

/obj/item/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/light/attack_atom(obj/O, mob/living/user, params)
	..()
	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message(span_danger("[src] shatters."),span_hear("You hear a small glass object shatter."))
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(rigged)
			atmos_spawn_air("plasma=5") //5u of plasma are required to rig a light bulb/tube
		update()
