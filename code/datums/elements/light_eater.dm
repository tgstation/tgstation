/**
 * Makes anything it attaches to capable of permanently removing something's ability to produce light.
 *
 * The temporary equivalent is [/datum/component/light_eater]
 */
/datum/element/light_eater
	var/static/list/blacklisted_areas = typecacheof(list(
		/turf/open/space,
		/turf/open/lava,
	))

/datum/element/light_eater/Attach(datum/target)
	if(isatom(target))
		if(ismovable(target))
			if(ismachinery(target) || isstructure(target))
				RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
			RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
			if(isitem(target))
				if(isgun(target))
					RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
				RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interacting_with))
				RegisterSignal(target, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_reaction))
			else if(isprojectile(target))
				RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_self_hit))
	else if(istype(target, /datum/reagent))
		RegisterSignal(target, COMSIG_REAGENT_EXPOSE_ATOM, PROC_REF(on_expose_atom))
	else if(isprojectilespell(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	else
		return ELEMENT_INCOMPATIBLE

	return ..()

/datum/element/light_eater/Detach(datum/source)
	UnregisterSignal(source, list(
		COMSIG_MOVABLE_IMPACT,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_ITEM_HIT_REACT,
		COMSIG_PROJECTILE_ON_HIT,
		COMSIG_REAGENT_EXPOSE_ATOM,
	))
	return ..()

/**
 * Makes the light eater consume all of the lights attached to the target atom.
 *
 * Arguments:
 * - [food][/atom]: The atom to start the search for lights at.
 * - [eater][/datum]: The light eater being used in this case.
 */
/datum/element/light_eater/proc/eat_lights(atom/food, datum/eater)
	var/list/buffet = table_buffet(food)
	if(!LAZYLEN(buffet))
		return 0

	. = 0
	for(var/morsel in buffet)
		. += devour(morsel, eater)

	if(!.)
		return

	food.visible_message(
		span_danger("Something dark in [eater] lashes out at [food] and [food.p_their()] light goes out in an instant!"),
		span_userdanger("You feel something dark in [eater] lash out and gnaw through your light in an instant! It recedes just as fast, but you can feel that [eater.p_theyve()] left something hungry behind."),
		span_danger("You feel a gnawing pulse eat at your sight.")
	)

/**
 * Aggregates a list of the light sources attached to the target atom.
 *
 * Arguments:
 * - [comissary][/atom]: The origin node of all of the light sources to search through.
 * - [devourer][/datum]: The light eater this element is attached to. Since the element is compatible with reagents this needs to be a datum.
 */
/datum/element/light_eater/proc/table_buffet(atom/commisary, datum/devourer)
	. = list()
	SEND_SIGNAL(commisary, COMSIG_LIGHT_EATER_QUEUE, ., devourer)
	for(var/datum/light_source/morsel as anything in commisary.light_sources)
		.[morsel.source_atom] = TRUE

/**
 * Consumes the light on the target, permanently rendering it incapable of producing light
 *
 * Arguments:
 * - [morsel][/atom]: The light-producing thing we are eating
 * - [eater][/datum]: The light eater eating the morsel. This is the datum that the element is attached to that started this chain.
 */
/datum/element/light_eater/proc/devour(atom/morsel, datum/eater)
	if(is_type_in_typecache(morsel, blacklisted_areas))
		return FALSE
	if(istransparentturf(morsel))
		return FALSE
	if(morsel.light_power <= 0 || morsel.light_range <= 0 || !morsel.light_on)
		return FALSE
	if(SEND_SIGNAL(morsel, COMSIG_LIGHT_EATER_ACT, eater) & COMPONENT_BLOCK_LIGHT_EATER)
		return FALSE // Either the light eater can't eat it or it had special behaviors.

	morsel.AddElement(/datum/element/light_eaten)
	SEND_SIGNAL(src, COMSIG_LIGHT_EATER_DEVOUR, morsel)
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
 * Called when a target is interacted with by a source item
 *
 * Arguments:
 * - [source][/obj/item]: The item what was used to strike the target
 * - [user][/mob/living]: The mob using the source to strike the target
 * - [target][/atom]: The atom being struck by the user with the source
 */
/datum/element/light_eater/proc/on_interacting_with(obj/item/source, mob/living/user, atom/target)
	SIGNAL_HANDLER
	if(eat_lights(target, source))
		// do a "pretend" attack if we're hitting something that can't normally be
		if(isobj(target))
			var/obj/smacking = target
			if(smacking.obj_flags & CAN_BE_HIT)
				return NONE
		else if(!isturf(target))
			return NONE
		user.do_attack_animation(target)
		user.changeNext_move(CLICK_CD_RAPID)
		target.play_attack_sound()
	// not particularly picky about what happens afterwards in the attack chain
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
/datum/element/light_eater/proc/on_hit_reaction(obj/item/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	SIGNAL_HANDLER
	if(prob(final_block_chance))
		eat_lights(hitby, source)
	return NONE

/**
 * Called when a produced projectile strikes a target atom
 *
 * Arguments:
 * - [source][/datum]: The thing that created the projectile
 * - [firer][/atom/movable]: The movable atom that fired the projectile
 * - [target][/atom]: The atom that was struck by the projectile
 * - angle: The angle the target was struck at
 */
/datum/element/light_eater/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE

/**
 * Called when a source projectile strikes a target atom
 *
 * Arguments:
 * - [source][/obj/projectile]: The projectile striking the target atom
 * - [firer][/atom/movable]: The movable atom that fired the projectile
 * - [target][/atom]: The atom that was struck by the projectile
 * - angle: The angle the target was struck at
 * - hit_limb: The limb that was hit, if the target was a carbon
 */
/datum/element/light_eater/proc/on_projectile_self_hit(obj/projectile/source, atom/movable/firer, atom/target, angle, hit_limb)
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
/datum/element/light_eater/proc/on_expose_atom(datum/reagent/source, atom/target, reac_volume, methods)
	SIGNAL_HANDLER
	eat_lights(target, source)
	return NONE
