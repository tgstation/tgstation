/**
 * Makes anything it attaches to capable of removing something's ability to produce light until it is destroyed
 *
 * The permanent version of this is [/datum/element/light_eater]
 */
/datum/component/light_eater
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Tracks things this light eater has eaten
	var/list/eaten_lights

/datum/component/light_eater/Initialize(list/_eaten)
	if(!isatom(parent) && !istype(parent, /datum/reagent))
		return COMPONENT_INCOMPATIBLE

	if(length(_eaten))
		var/datum/cached_parent = parent
		eaten_lights = list()
		var/list/cached_eaten_lights = eaten_lights
		for(var/food in _eaten)
			RegisterSignal(food, COMSIG_ATOM_UPDATE_LIGHT, .proc/block_light_update)
			RegisterSignal(food, COMSIG_PARENT_QDELETING, .proc/deref_eaten_light)
			RegisterSignal(food, COMSIG_PARENT_EXAMINE, .proc/on_eaten_light_examine)
			cached_eaten_lights += food
	return ..()

/datum/component/light_eater/Destroy(force, silent)
	var/list/signals_to_unregister = list(
		COMSIG_ATOM_UPDATE_LIGHT,
		COMSIG_PARENT_QDELETING,
	)
	for(var/light in lights_eaten)
		UnregisterSignal(light, signals_to_unregister)
	lights_eaten = null
	return ..()

/datum/component/light_eater/RegisterWithParent()
	. = ..()
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

/datum/component/light_eater/UnregisterFromParent()
	. = ..()
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

/datum/component/light_eater/InheritComponent(datum/component/C, i_am_original, list/_eater)
	. = ..()
	if(length(_eaten))
		var/datum/cached_parent = parent
		LAZYINITLIST(eaten_lights)
		var/list/cached_eaten_lights = eaten_lights
		for(var/food in _eaten)
			RegisterSignal(food, COMSIG_ATOM_UPDATE_LIGHT, .proc/block_light_update)
			RegisterSignal(food, COMSIG_PARENT_QDELETING, .proc/deref_eaten_light)
			RegisterSignal(food, COMSIG_PARENT_EXAMINE, .proc/on_eaten_light_examine)
			cached_eaten_lights += food

/// Handles queuing lights to eat
/datum/component/light_eater/proc/eat_lights(atom/food, datum/eater)
	var/list/buffet = light_eater_table_buffet(food, eater)
	for(var/morsel in buffet)
		devour(morsel, eater)

/// Handles eating lights
/datum/component/light_eater/proc/devour(atom/morsel, datum/eater)
	if(!light_eater_devour(morsel, eater))
		return FALSE

	var/has_eyes
	morsel.visible_message(
		"<span class='danger'>Something dark and hungry swarms out of \the [eater] and over \the [morsel]!</span>",
		"<span class='userdanger'>Something dark and hungry swarms out of \the [eater] and burrows into you!</span>",
		"<span class='danger'>You can feel a dark hum gnaw at your sight.</span>"
	)
	morsel.set_light(0, 0, null, FALSE)
	RegisterSignal(morsel, COMSIG_PARENT_QDELETING, .proc/deref_eaten_light)
	RegisterSignal(morsel, COMSIG_ATOM_UPDATE_LIGHT, .proc/block_light_update)
	RegisterSignal(morsel, COMSIG_PARENT_EXAMINE, .proc/on_eaten_light_examine)
	LAZYADD(eaten_lights, morsel)
	return TRUE


/////////////////////
// SIGNAL HANDLERS //
/////////////////////

/**
 * Called when a movable source is thrown and strikes a target
 *
 * Arugments:
 * - [source][/atom/movable]: The movable atom that was thrown
 * - [hit_atom][/atom]: The target atom that was struck by the source in flight
 * - [thrownthing][/datum/thrownthing]: A datum containing the information for the throw
 */
/datum/element/light_eater/proc/on_throw_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER
	eat_lights(hit_atom, source)
	return NONE

/**
 * Called when a target is attacked with a source item
 *
 * Arguments:
 * - [source][/obj/item]: The item what was used to strike the target
 * - [target][/atom]: The atom being struck by the user with the source
 * - [user][/mob/living]: The mob using the source to strike the target
 * - proximity: Whether the strike was in melee range so you can't eat lights from cameras
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
 * - [source][/obj/item]: The item what was used to block the target
 * - [owner][/mob/living/carbon/human]: The mob that blocked the target with the source
 * - [hitby][/atom/movable]: The movable that was blocked by the owner with the source
 * - attack_text: The text tring that will be used to report that the target was blocked
 * - final_block_chance: The probability of blocking the target with the source
 * - attack_type: The type of attack that was blocked
 */
/datum/element/light_eater/proc/on_hit_reaction(obj/item/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	SIGNAL_HANDLER
	if(prob(final_block_chance))
		eat_lights(hitby, source)
	return NONE

/**
 * Called when a source projectile strikes a target atom
 *
 * Arguments:
 * - [source][/obj/projectile]: The projectile striking the target atom
 * - [firer][/atom/movable]: The movable atom that fired the projectile
 * - [target][/atom]: The atom that was struck by the projectile
 * - angle: The angle the target was struck at
 */
/datum/element/light_eater/proc/on_projectile_hit(obj/projectile/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE

/**
 * Called when a source reagent exposes a target atom
 *
 * Arguments:
 * - [source][/datum/reagent]: The reagents that exposed the target atom
 * - [target][/atom]: The atom that was exposed to the light reater reagents
 * - reac_volume: The volume of the reagents the target was exposed to
 */
/datum/element/light_eater/proc/on_expose_atom(datum/reagent/source, atom/target, reac_volume)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE

/// Signal handler for preventing flashlights from being turned back on
/datum/component/light_eater/proc/block_light_update(atom/eaten_light)
	SIGNAL_HANDLER
	light_eater_block_light_update(source)
	return NONE

/// Signal handler for light eater flavortext
/datum/component/light_eater/proc/on_eaten_light_examine(atom/eaten_light, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='warning'>You can feel something you can't see swarming over [eaten_light.p_them()]. Something dark and hungry.</span>"
	return NONE

/// Signal handler for dereferencing eaten lights
/datum/component/light_eater/proc/deref_eaten_light(atom/eaten_light)
	SIGNAL_HANDLER
	UnregisterSignal(eaten_light, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_UPDATE_LIGHT,
	))
	LAZYREMOVE(eaten_lights, eaten_light)
	return NONE
