/obj/item/organ/internal/stomach/golem
	name = "silicate grinder"
	icon_state = "stomach-p"
	desc = "A rocklike organ which grinds and processes nutrition from minerals."
	organ_traits = list(TRAIT_ROCK_EATER)
	/// Multiplier for the hunger rate, golems burn fuel quickly
	var/hunger_mod = 25
	/// How slow are you when the "hungry" icon appears?
	var/min_hunger_slowdown = 0.5
	/// How slow are you if you have absolutely nothing in the tank?
	var/max_hunger_slowdown = 4

/obj/item/organ/internal/stomach/golem/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_EAT, PROC_REF(try_eating))
	if (!ishuman(organ_owner))
		return
	if (organ_owner.flags_1 & INITIALIZED_1)
		setup_physiology(organ_owner)
	else
		RegisterSignal(owner, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE, PROC_REF(setup_physiology))

/// Physiology doesn't exist yet if this is added on initialisation of a golem, so we need to wait until it does
/obj/item/organ/internal/stomach/golem/proc/setup_physiology(mob/living/carbon/human/human_owner)
	SIGNAL_HANDLER
	human_owner.physiology?.hunger_mod *= hunger_mod
	UnregisterSignal(human_owner, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)

/obj/item/organ/internal/stomach/golem/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_CARBON_ATTEMPT_EAT)
	if (!ishuman(organ_owner))
		return
	var/mob/living/carbon/human/human_owner = organ_owner
	human_owner.physiology?.hunger_mod /= hunger_mod

/// Reject food, rocks only
/obj/item/organ/internal/stomach/golem/proc/try_eating(mob/living/carbon/source, atom/eating)
	SIGNAL_HANDLER

	if (istype(eating, /obj/item/food/material))
		return
	source.balloon_alert(source, "minerals only!")
	return COMSIG_CARBON_BLOCK_EAT

/// Slow down based on how full you are
/obj/item/organ/internal/stomach/golem/handle_hunger(mob/living/carbon/human/human, delta_time, times_fired)
	if(HAS_TRAIT(human, TRAIT_NOHUNGER))
		return
	. = ..()
	var/hunger = (NUTRITION_LEVEL_HUNGRY - human.nutrition) / NUTRITION_LEVEL_HUNGRY // starving = 1, satisfied = 0
	if(hunger > 0)
		var/slowdown = LERP(min_hunger_slowdown, max_hunger_slowdown, hunger)
		human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/golem_hunger, multiplicative_slowdown = slowdown)
		// TODO: statue if too hungry
	else
		human.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)
