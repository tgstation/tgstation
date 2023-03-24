/// Associated list of stack types to a golem food
GLOBAL_LIST_INIT(golem_stack_food_directory, list(
	/obj/item/stack/sheet/iron = new /datum/golem_food_buff/iron(),
	/obj/item/stack/ore/iron = new /datum/golem_food_buff/iron(),
	/obj/item/stack/sheet/glass = new /datum/golem_food_buff/glass(),
	/obj/item/stack/sheet/mineral/uranium = new /datum/golem_food_buff/uranium(),
	/obj/item/stack/ore/uranium = new /datum/golem_food_buff/uranium(),
	/obj/item/stack/sheet/mineral/silver = new /datum/golem_food_buff/silver(),
	/obj/item/stack/ore/silver = new /datum/golem_food_buff/silver(),
	/obj/item/stack/sheet/mineral/plasma = new /datum/golem_food_buff/plasma(),
	/obj/item/stack/ore/plasma = new /datum/golem_food_buff/plasma(),
	/obj/item/stack/sheet/mineral/gold = new /datum/golem_food_buff/gold(),
	/obj/item/stack/ore/gold = new /datum/golem_food_buff/gold(),
	/obj/item/stack/sheet/mineral/diamond = new /datum/golem_food_buff/diamond(),
	/obj/item/stack/ore/diamond = new /datum/golem_food_buff/diamond(),
	/obj/item/stack/sheet/mineral/titanium = new /datum/golem_food_buff/titanium(),
	/obj/item/stack/ore/titanium = new /datum/golem_food_buff/titanium(),
	/obj/item/stack/sheet/plasteel = new /datum/golem_food_buff/plasteel(),
))

/// An effect you gain from eating minerals
/datum/golem_food_buff
	/// If we can apply this while you already have a different status effect
	var/exclusive = TRUE
	/// Nutrition to grant per stack consumed
	var/nutrition = 2
	/// Typepath of status effect to apply
	var/status_effect
	/// Extra information to display when a valid food is examined
	var/added_info = ""

/// Returns true if the passed mob can currently gain this buff
/datum/golem_food_buff/proc/can_consume(mob/living/consumer)
	if (!exclusive || !status_effect)
		return TRUE
	var/datum/status_effect/golem/existing = consumer.has_status_effect(/datum/status_effect/golem)
	return !existing || istype(existing, status_effect)

/// Called when someone actually eats this
/datum/golem_food_buff/proc/on_consumption(mob/living/carbon/consumer)
	if (!HAS_TRAIT(consumer, TRAIT_ROCK_METAMORPHIC))
		return
	apply_effects(consumer)

/// Apply our desired effects to the eater
/datum/golem_food_buff/proc/apply_effects(mob/living/carbon/consumer)
	if (status_effect)
		consumer.apply_status_effect(status_effect)

/// Can eat at any time, but isn't very nutritious
/datum/golem_food_buff/glass
	exclusive = FALSE
	nutrition = 0.5
	added_info = "This mineral can be consumed at any time, but it's mostly empty calories."

/// More filling, and heals you
/datum/golem_food_buff/iron
	exclusive = FALSE
	nutrition = 3
	added_info = "This mineral can be consumed at any time. It's filling and even heals you a little."
	/// Amount by which you heal from eating some iron
	var/healed_amount = 3
	/// Order in which to heal damage types
	var/static/list/damage_heal_order = list(BRUTE, BURN, TOX, OXY)

/datum/golem_food_buff/iron/apply_effects(mob/living/carbon/consumer)
	if (consumer.health == consumer.maxHealth)
		return
	consumer.heal_ordered_damage(healed_amount, damage_heal_order)
	new /obj/effect/temp_visual/heal(get_turf(consumer), COLOR_HEALING_CYAN)

/datum/golem_food_buff/uranium
	status_effect = /datum/status_effect/golem/uranium
	added_info = "If consumed this mineral will power you in place of food, pausing your digestion for five minutes."

/datum/golem_food_buff/silver
	status_effect = /datum/status_effect/golem/silver
	added_info = "If consumed this mineral will repel the supernatural, affording you resistance to mystical effects."

/datum/golem_food_buff/plasma
	status_effect = /datum/status_effect/golem/plasma
	added_info = "If consumed this mineral will allow you to absorb heat and convert it into power."

/datum/golem_food_buff/plasteel
	status_effect = /datum/status_effect/golem/plasteel
	added_info = "If consumed this mineral will harden you against the hazards of space."

/datum/golem_food_buff/gold
	status_effect = /datum/status_effect/golem/gold
	added_info = "If consumed this mineral will grant you a shiny coating which reflects projectiles."

/datum/golem_food_buff/diamond
	status_effect = /datum/status_effect/golem/diamond
	added_info = "If consumed this mineral will reflact light around you, making you harder to see."

/datum/golem_food_buff/titanium
	status_effect = /datum/status_effect/golem/titanium
	added_info = "If consumed this mineral will make you tougher and punch harder."
