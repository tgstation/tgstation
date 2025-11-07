/// Element which influences raptor children upon owner's consumption as food
/datum/element/raptor_food
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Flat damage modifier
	var/attack_modifier = null
	/// Flat health modifier
	var/health_modifier = null
	/// Speed modifier
	var/speed_modifier = null
	/// Primary ability stat modifier
	/// Multiplier equates to 1 + this
	var/ability_modifier = null
	/// Growth rate modifier
	/// Multiplier equates to 1 + this
	var/growth_modifier = null
	/// Personality traits the child may get
	var/list/personality_traits = null
	/// Offspring color probability modifiers
	var/list/color_chances = null

/datum/element/raptor_food/Attach(obj/item/target, attack_modifier, health_modifier, speed_modifier, ability_modifier, growth_modifier, list/personality_traits, list/color_chances)
	. = ..()
	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.attack_modifier = attack_modifier
	src.health_modifier = health_modifier
	src.speed_modifier = speed_modifier
	src.ability_modifier = ability_modifier
	src.growth_modifier = growth_modifier
	src.personality_traits = personality_traits
	src.color_chances = color_chances
	RegisterSignal(target, COMSIG_ITEM_EATEN_BY_BASIC_MOB, PROC_REF(on_eaten))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))

/datum/element/raptor_food/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ITEM_EATEN_BY_BASIC_MOB, COMSIG_ATOM_EXAMINE_MORE))
	return ..()

/datum/element/raptor_food/proc/on_examine_more(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if (!istype(examiner.buckled, /mob/living/basic/raptor))
		return

	// Just to check for priority
	var/strognest_effect = max(attack_modifier, health_modifier, speed_modifier, ability_modifier, growth_modifier, 0)

	// Only personality or color probability effects, or just pure negatives
	if (strognest_effect == 0)
		examine_list += span_notice("You reckon this would have unique effects on your raptor's offspring if you fed it to them...")
		return

	if (strognest_effect == attack_modifier)
		examine_list += span_notice("You reckon this would have make your raptor's offspring stronger if you fed it to them...")
	else if (strognest_effect == health_modifier)
		examine_list += span_notice("You reckon this would have make your raptor's offspring tougher if you fed it to them...")
	else if (strognest_effect == speed_modifier)
		examine_list += span_notice("You reckon this would have make your raptor's offspring faster if you fed it to them...")
	else if (strognest_effect == ability_modifier)
		examine_list += span_notice("You reckon this would have make your raptor's offspring more capable if you fed it to them...")
	else if (strognest_effect == growth_modifier)
		examine_list += span_notice("You reckon this would have make your raptor's offspring grow faster if you fed it to them...")

/datum/element/raptor_food/proc/on_eaten(obj/item/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	if (!istype(eater, /mob/living/basic/raptor))
		return

	var/mob/living/basic/raptor/raptor = eater
	var/list/our_food = raptor.inherited_stats.foods_eaten[source.type]
	if (our_food)
		our_food["amount"] += 1
		return

	raptor.inherited_stats.foods_eaten[source.type] = list(
		"amount" = 1,
		"attack" = attack_modifier,
		"health" = health_modifier,
		"speed" = speed_modifier,
		"ability" = ability_modifier,
		"growth" = growth_modifier,
		"traits" = personality_traits?.Copy(),
		"color_chances" = color_chances?.Copy(),
	)

