// a potent coolant that treats synthetic burns at decent efficiency. compared to hercuri it's worse, but without
// the lethal side effects, opting for a movement speed decrease instead
/datum/reagent/dinitrogen_plasmide
	name = "Dinitrogen Plasmide"
	description = "A compound of nitrogen and stabilized plasma, this substance has the ability to flash-cool overheated metals \
	while avoiding excessive damage. Being a heavy compound, it has the effect of slowing anything that metabolizes it."
	ph = 4.8
	specific_heat = SPECIFIC_HEAT_PLASMA * 1.2
	color = "#b779cc"
	taste_description = "dull plasma"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC
	overdose_threshold = 60 // it takes a lot, if youre really messed up you CAN hit this but it's unlikely
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/dinitrogen_plasmide/on_mob_metabolize(mob/living/affected_mob)
	. = ..()

	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide)
	to_chat(affected_mob, span_warning("Your joints suddenly feel stiff."))

/datum/reagent/dinitrogen_plasmide/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()

	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide_overdose)
	to_chat(affected_mob, span_warning("Your joints no longer feel stiff!"))

/datum/reagent/dinitrogen_plasmide/overdose_start(mob/living/affected_mob)
	. = ..()

	to_chat(affected_mob, span_danger("You feel like your joints are filling with some viscous fluid!"))
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide_overdose)

/datum/reagent/dinitrogen_plasmide/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	holder.remove_reagent(type, 1.2 * seconds_per_tick) // decays
	holder.add_reagent(/datum/reagent/stable_plasma, 0.4 * seconds_per_tick)
	holder.add_reagent(/datum/reagent/nitrogen, 0.8 * seconds_per_tick)

/datum/movespeed_modifier/dinitrogen_plasmide
	multiplicative_slowdown = 0.3

/datum/movespeed_modifier/dinitrogen_plasmide_overdose
	multiplicative_slowdown = 1.3

/datum/chemical_reaction/dinitrogen_plasmide_formation
	results = list(/datum/reagent/dinitrogen_plasmide = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/nitrogen = 2)
	required_catalysts = list(/datum/reagent/acetone = 0.1)
	required_temp = 400
	optimal_temp = 550
	overheat_temp = 590

	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_HEALING

/obj/item/reagent_containers/spray/dinitrogen_plasmide
	name = "coolant spray"
	desc = "A medical spray bottle. This one contains dinitrogen plasmide, a potent coolant commonly used to treat synthetic burns. \
	Has the side effect of causing movement slowdown."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "sprayer_med_yellow"
	list_reagents = list(/datum/reagent/dinitrogen_plasmide = 100)
