/obj/item/organ/stomach/golem
	name = "silicate grinder"
	icon_state = "stomach-p"
	desc = "A rocklike organ which grinds and processes nutrition from minerals."
	color = COLOR_GOLEM_GRAY
	organ_flags = ORGAN_MINERAL
	organ_traits = list(TRAIT_ROCK_EATER)
	hunger_modifier = 10 // golems burn fuel quickly
	/// How slow are you when the "hungry" icon appears?
	var/min_hunger_slowdown = 0.5
	/// How slow are you if you have absolutely nothing in the tank?
	var/max_hunger_slowdown = 4

/obj/item/organ/stomach/golem/on_mob_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_EAT, PROC_REF(try_eating))

/obj/item/organ/stomach/golem/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_CARBON_ATTEMPT_EAT)
	organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)
	organ_owner.remove_status_effect(/datum/status_effect/golem_statued)

/// Reject food, rocks only
/obj/item/organ/stomach/golem/proc/try_eating(mob/living/carbon/source, atom/eating)
	SIGNAL_HANDLER
	if(istype(eating, /obj/item/food/golem_food))
		return
	source.balloon_alert(source, "minerals only!")
	return COMSIG_CARBON_BLOCK_EAT

/// Golem stomach cannot process nutriment except from minerals
/obj/item/organ/stomach/golem/on_life(delta_time, times_fired)
	for(var/datum/reagent/consumable/food in reagents.reagent_list)
		if (istype(food, /datum/reagent/consumable/nutriment/mineral))
			continue
		food.nutriment_factor = 0
	return ..()

/// Slow down based on how full you are
/obj/item/organ/stomach/golem/handle_hunger(mob/living/carbon/human/human, delta_time, times_fired)
	// the effects are all negative, so just don't run them if you have the trait
	. = ..()
	if(HAS_TRAIT(human, TRAIT_NOHUNGER))
		return
	var/hunger = (NUTRITION_LEVEL_HUNGRY - human.nutrition) / NUTRITION_LEVEL_HUNGRY // starving = 1, satisfied = 0
	if(hunger > 0)
		var/slowdown = LERP(min_hunger_slowdown, max_hunger_slowdown, hunger)
		human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/golem_hunger, multiplicative_slowdown = slowdown)
	else
		human.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)

	if (hunger >= 1)
		human.apply_status_effect(/datum/status_effect/golem_statued)
	else
		human.remove_status_effect(/datum/status_effect/golem_statued)

/// Uh oh, you can't move, yell for help
/datum/status_effect/golem_statued
	id = "golem_statued"
	alert_type = /atom/movable/screen/alert/status_effect/golem_statued

/atom/movable/screen/alert/status_effect/golem_statued
	name = "Statued"
	desc = "You no longer have the energy to move your body!"
	icon_state = "golem_statued"

/datum/status_effect/golem_statued/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.visible_message(span_warning("[owner] siezes up and becomes as rigid as a statue!"), span_warning("Your limbs fall still. You no longer have enough energy to move!"))
	owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_FORCED_STANDING, TRAIT_HANDS_BLOCKED, TRAIT_INCAPACITATED), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem_statued/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] as still as a statue!")

/datum/status_effect/golem_statued/on_remove()
	owner.visible_message(span_notice("[owner] slowly stirs back into motion!"), span_notice("You have gathered enough strength to move your body once more."))
	owner.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FORCED_STANDING, TRAIT_HANDS_BLOCKED, TRAIT_INCAPACITATED), TRAIT_STATUS_EFFECT(id))
	return ..()
