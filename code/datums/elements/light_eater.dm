/**
 *
 */
/datum/element/light_eater
	element_flags = ELEMENT_DETACH

/datum/element/light_eater/Attach(datum/target)
	if(isatom(target))
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/on_throw_impact)
			if(isitem(target))
				RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/on_afterattack)
				RegisterSignal(target, COMSIG_ITEM_HIT_REACT, .proc/on_hit_reaction)
			else if(isprojectile(target))
				RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, .proc/on_projectile_hit)
	else if(istype(target, /datum/reagent))
		RegisterSignal(target, COMSIG_REAGENT_EXPOSE_ATOM, .proc/on_expose_atom)
	else
		return ELEMENT_INCOMPATIBLE

	return ..()


/datum/element/light_eater/Detach(datum/source, force)
	if(isatom(source))
		if(ismovable(source))
			UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
			if(isitem(source))
				UnregisterSignal(source, list(
					COMSIG_ITEM_AFTERATTACK,
					COMSIG_ITEM_HIT_REACT,
				))
			else if(isprojectile(source))
				UnregisterSignal(source, COMSIG_PROJECTILE_ON_HIT)
	else if(istype(source, /datum/reagent))
		UnregisterSignal(source, COMSIG_REAGENT_EXPOSE_ATOM)
	return ..()


/**
 *
 */
/datum/element/light_eater/proc/eat_lights(atom/target, datum/source)
	var/list/light_queue = list()
	SEND_SIGNAL(target, COMSIG_LIGHT_EATER_QUEUE, light_queue, source)
	for(var/light in target.light_sources)
		var/datum/light_source/light_source = light
		light_queue += light_source.source_atom

	if(!length(light_queue))
		return

	for(var/light_to_eat in light_queue)
		eat_light(light_to_eat, source)


/**
 *
 */
/datum/element/light_eater/proc/eat_light(atom/target, datum/source)
	if(target.light_power <= 0 || target.light_range <= 0 || !target.light_on)
		return
	if(SEND_SIGNAL(target, COMSIG_LIGHT_EATER_ACT, source) & COMPONENT_BLOCK_LIGHT_EATER)
		return

	target.set_light(0, 0, null, FALSE)
	target.AddElement(/datum/element/light_eaten)




/////////////////////
// SIGNAL HANDLERS //
/////////////////////

/**
 *
 */
/datum/element/light_eater/proc/on_throw_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER
	eat_lights(hit_atom, source)
	return NONE

/**
 *
 */
/datum/element/light_eater/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, proximity)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE
	if(isopenturf(target))
		return NONE
	eat_lights(target, source)
	return NONE

/**
 * Called when a source object is used to block a thrown object, projectile, or attack
 *
 * Arguments:
 * - [source][/obj/item]:
 * - [owner][/mob/living/carbon/human]:
 * - [hitby][/atom/movable]:
 * - attack_text:
 * - final_block_chance:
 * - attack_type:
 */
/datum/element/light_eater/proc/on_hit_reaction(obj/item/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	SIGNAL_HANDLER
	if(prob(final_block_chance))
		eat_lights(hitby, source)
	return NONE

/**
 *
 */
/datum/element/light_eater/proc/on_projectile_hit(obj/projectile/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE

/**
 * Called when a source reagent exposes a target atom
 *
 * Arguments:
 * - [source][/datum/reagent]:
 * - [target][/atom]:
 * - reac_volume:
 */
/datum/element/light_eater/proc/on_expose_atom(datum/reagent/source, atom/target, reac_volume)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE
