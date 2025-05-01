// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vine"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/mob/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	/// What growth stage is this vine at?
	var/growth_stage = 0
	/// Can this kudzu spread?
	var/can_spread = TRUE
	/// Can this kudzu buckle mobs in?
	var/can_tangle = TRUE
	/// Our associated spacevine_controller, for managing expansion/mutation
	var/datum/spacevine_controller/master
	/// List of mutations for a specific vine
	var/list/mutations = list()
	/// The traits associated with a specific mutation of vines
	var/trait_flags = NONE
	/// Should atmos always process this tile
	var/always_atmos_process = FALSE
	/// The kudzu blocks light on default once it grows
	var/light_state = BLOCK_LIGHT

/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CHASM_DESTROYED, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_INVERTED_DEMOLITION, INNATE_TRAIT)
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddComponent(/datum/component/storm_hating)

/obj/structure/spacevine/examine(mob/user)
	. = ..()
	if(!length(mutations))
		. += "This vine has no mutations."
		return
	var/text = "This vine has the following mutations:\n"
	for(var/datum/spacevine_mutation/mutation as anything in mutations)
		if(mutation.name == "transparent") /// Transparent has no hue
			text += "<font color='#346751'>Transparent</font> "
		else
			text += "<font color='[mutation.hue]'>[mutation.name]</font> "
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(PASS_LIGHT)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/chem)
	var/override = FALSE
	for(var/datum/spacevine_mutation/mutation in mutations)
		override += mutation.on_chem(src, chem)
	if(!override && prob(75) && istype(chem, /datum/reagent/toxin/plantbgone))
		qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = FALSE
	for(var/datum/spacevine_mutation/mutation in mutations)
		override += mutation.on_eat(src, eater)
	if(!override)
		qdel(src)

/obj/structure/spacevine/attacked_by(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	LAZYSET(attack_modifiers, SILENCE_DEFAULT_MESSAGES, TRUE)
	LAZYSET(attack_modifiers, FORCE_MULTIPLIER, 1)
	if(item.damtype == BURN)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 4)
	if(item.get_sharpness())
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 4)
	return ..()

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/items/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(!isliving(movable))
		return
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_cross(src, movable)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user, list/modifiers)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_hit(src, user)
	user_unbuckle_mob(user, user)
	return ..()

/obj/structure/spacevine/attack_paw(mob/living/user, list/modifiers)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user, list/modifiers)
	eat(user)

/// Updates the icon as the space vine grows
/obj/structure/spacevine/proc/grow()
	if(!growth_stage)
		src.icon_state = pick("Med1", "Med2", "Med3")
		growth_stage = 1
		set_opacity(light_state)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		growth_stage = 2

	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_grow(src)

/// Buckles mobs trying to pass through it
/obj/structure/spacevine/proc/entangle_mob()
	if(has_buckled_mobs() || prob(75))
		return

	for(var/mob/living/victim in src.loc)
		entangle(victim)
		if(has_buckled_mobs())
			break //only capture one mob at a time

/obj/structure/spacevine/proc/entangle(mob/living/victim)
	if(isnull(victim) || isvineimmune(victim))
		return
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_buckle(src, victim)
	if((victim.stat != DEAD) && (victim.buckled != src) && can_tangle) //not dead and not captured and can tangle
		to_chat(victim, span_userdanger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(victim, force = TRUE)

/// Finds a target tile to spread to. If checks pass it will spread to it and also proc on_spread on target.
/obj/structure/spacevine/proc/spread()
	if(isnull(master)) //If we've lost our controller, something has gone terribly wrong.
		return

	var/direction = pick(GLOB.cardinals)
	var/turf/stepturf = get_step(src, direction)
	if(!istype(stepturf))
		return

	if(is_space_or_openspace(stepturf) || !stepturf.Enter(src))
		return
	if(ischasm(stepturf) && !HAS_TRAIT(stepturf, TRAIT_CHASM_STOPPED))
		return
	if(islava(stepturf) && !HAS_TRAIT(stepturf, TRAIT_LAVA_STOPPED))
		return
	var/obj/structure/spacevine/spot_taken = locate() in stepturf
	var/datum/spacevine_mutation/vine_eating/eating = locate() in mutations
	if(!isnull(spot_taken)) //Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't.
		if (isnull(eating))
			return
		if (spot_taken.mutations?.Find(eating))
			return
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_spread(src, stepturf)
		stepturf = get_step(src, direction)
	var/obj/structure/spacevine/spawning_vine = master.spawn_spacevine_piece(stepturf, src)
	if(NSCOMPONENT(direction))
		spawning_vine.pixel_y = direction == NORTH ? -32 : 32
		animate(spawning_vine, pixel_y = 0, time = 1 SECONDS)
	else
		spawning_vine.pixel_x = direction == EAST ? -32 : 32
		animate(spawning_vine, pixel_x = 0, time = 1 SECONDS)

/// Destroying an explosive vine sets off a chain reaction
/obj/structure/spacevine/ex_act(severity, target)
	var/index
	for(var/datum/spacevine_mutation/mutation in mutations)
		index += mutation.on_explosion(severity, target, src)
	if(!index && prob(34 * severity))
		qdel(src)

	return TRUE

/obj/structure/spacevine/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (always_atmos_process || exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD || exposed_temperature < VINE_FREEZING_POINT || !can_spread)//if you're room temperature you're safe

/obj/structure/spacevine/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.additional_atmos_processes(src, air)
	if(!can_spread && (exposed_temperature >= VINE_FREEZING_POINT || (trait_flags & SPACEVINE_COLD_RESISTANT)))
		can_spread = TRUE // not returning here just in case its now a plasmafire and the kudzu should be deleted
	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD && !(trait_flags & SPACEVINE_HEAT_RESISTANT))
		qdel(src)
	else if (exposed_temperature < VINE_FREEZING_POINT && !(trait_flags & SPACEVINE_COLD_RESISTANT))
		can_spread = FALSE

/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isvineimmune(mover))
		return TRUE
