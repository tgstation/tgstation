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
	if (!exclusive)
		return TRUE
	var/datum/status_effect/golem/existing = consumer.has_status_effect(/datum/status_effect/golem)
	return !existing || istype(existing, status_effect)

/// Called when someone actually eats this
/datum/golem_food_buff/proc/on_consumption(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if (!HAS_TRAIT(consumer, TRAIT_ROCK_METAMORPHIC))
		return
	apply_effects(consumer, consumed, multiplier)

/// Apply our desired effects to the eater
/datum/golem_food_buff/proc/apply_effects(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if (status_effect)
		consumer.apply_status_effect(status_effect, multiplier)

/// Can eat at any time, but isn't very nutritious
/datum/golem_food_buff/glass
	exclusive = FALSE
	nutrition = 0.5
	added_info = "This mineral can be consumed at any time, but it's mostly empty calories."

/// More filling, and heals you
/datum/golem_food_buff/iron
	nutrition = 3
	added_info = "This mineral is filling and even heals you a little."
	/// Amount by which you heal from eating some iron
	var/healed_amount = 3
	/// Order in which to heal damage types
	var/list/damage_heal_order = list(BRUTE, BURN, TOX, OXY)

/datum/golem_food_buff/iron/apply_effects(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if (consumer.health == consumer.maxHealth)
		return
	consumer.heal_ordered_damage(healed_amount * multiplier, damage_heal_order)
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
	added_info = "If consumed this mineral will reflact light around you, making you faster and harder to see."

/datum/golem_food_buff/titanium
	status_effect = /datum/status_effect/golem/titanium
	added_info = "If consumed this mineral will make you tougher and punch harder."

/datum/golem_food_buff/bananium
	status_effect = /datum/status_effect/golem/bananium
	added_info = "If consumed this mineral will make you funnier."

/datum/golem_food_buff/lightbulb
	nutrition = 0
	exclusive = FALSE
	status_effect = /datum/status_effect/golem_lightbulb
	added_info = "Not nutritious, but gives you a healthy glow if eaten."

/datum/golem_food_buff/gibtonite
	exclusive = FALSE
	added_info = "After consumption, you can launch this mineral like a rocket. It's a little hard to keep down."

/datum/golem_food_buff/gibtonite/apply_effects(mob/living/carbon/human/consumer, atom/movable/consumed, multiplier = 1)
	var/obj/item/gibtonite_hand/new_hand = new(null, /* held_gibtonite = */ consumed)

	if(consumer.put_in_hands(new_hand))
		return
	consumer.drop_all_held_items()
	if(consumer.put_in_hands(new_hand))
		return

	consumed.forceMove(get_turf(consumer))
	new_hand.held_gibtonite = null
	qdel(new_hand)
	consumer.visible_message(span_warning("[consumer] can't keep [consumed] down, and coughs it onto the ground!"))

/datum/golem_food_buff/bluespace
	exclusive = FALSE
	added_info = "After consumption, you can use the stored power to teleport yourself."

/datum/golem_food_buff/bluespace/apply_effects(mob/living/carbon/human/consumer, atom/movable/consumed, multiplier = 1)
	if(multiplier <= 0.2)
		return
	var/obj/item/bluespace_finger/new_hand = new
	if (isstack(consumed))
		var/obj/item/stack/stack = consumed
		if(stack.amount == 1)
			consumer.dropItemToGround(stack)
	if (consumer.put_in_hands(new_hand, del_on_fail = TRUE))
		return
	consumer.balloon_alert(consumer, "no free hands!")
