/// If a borer learns this amount of chemicals from blood, it will count for their objective
#define BLOOD_CHEM_OBJECTIVE 3

/// How many chemicals does a borer need to count for the objective. We use this exclusivelly for text on the end-round-panel
GLOBAL_VAR_INIT(objective_blood_chem, 3)

/// Whats the borers progress on getting the chemical objective done?
GLOBAL_VAR_INIT(successful_blood_chem, 0)

/// How many borers should have to learn "objective_blood_chem" amount of chemicals before we count the objective as complete
GLOBAL_VAR_INIT(objective_blood_borer, 3)

/**
 * Lets borers learn pre-coded chemicals in the "potential_chemicals" list
 */
/datum/action/cooldown/borer/upgrade_chemical
	name = "Learn New Chemical"
	button_icon_state = "bloodlevel"
	chemical_evo_points = 1
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to learn various unlocked chemicals\n\
	To expand the chemical choice you need to use the evolution ability\n\
	"

/datum/action/cooldown/borer/upgrade_chemical/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	if(!length(cortical_owner.potential_chemicals))
		owner.balloon_alert(owner, "all chemicals learned")
		return

	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in cortical_owner.potential_chemicals)
		named_chemicals += initial(learnable_chemical.name)

	var/reagent_choice = tgui_input_list(
		cortical_owner,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	// We only know the chosen chemicals name at this point, so we gotta check what chemical do we actually give them
	var/datum/reagent/learned_reagent
	for(var/datum/reagent/chemical as anything in cortical_owner.potential_chemicals)
		if(initial(chemical.name) == reagent_choice)
			learned_reagent = chemical

	cortical_owner.known_chemicals += learned_reagent
	cortical_owner.chemical_evolution -= chemical_evo_points
	cortical_owner.potential_chemicals -= learned_reagent

	owner.balloon_alert(owner, "[reagent_choice] learned")
	if(!HAS_TRAIT(cortical_owner.human_host, TRAIT_AGEUSIA))
		to_chat(cortical_owner.human_host, span_notice("You get a strange aftertaste of [initial(learned_reagent.taste_description)]!"))

	cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)

	StartCooldown()

/**
 * Lets borers learn chemicals that the host they reside in currently possess unless its in the "blacklisted_chemicals" list
 * This ability is required for one of the borer's objectives
 */
/datum/action/cooldown/borer/learn_bloodchemical
	name = "Learn Chemical from Blood"
	button_icon_state = "bloodchem"
	chemical_evo_points = 5
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to learn chemicals from blood at a much steeper price\n\
	Does not work on certain chemicals whose mollecular complexity is too high\n\
	"

/datum/action/cooldown/borer/learn_bloodchemical/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	if(length(cortical_owner.human_host.reagents.reagent_list) <= 0)
		owner.balloon_alert(owner, "no reagents in host")
		return

	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in cortical_owner.human_host.reagents.reagent_list)
		named_chemicals += initial(learnable_chemical.name)

	var/reagent_choice = tgui_input_list(
		cortical_owner,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	// We only know the chosen chemicals name at this point, so we gotta check what chemical do we actually give them
	var/datum/reagent/learned_reagent
	for(var/datum/reagent/chemical as anything in cortical_owner.human_host.reagents.reagent_list)
		if(initial(chemical.name) == reagent_choice)
			learned_reagent = chemical

	if(locate(learned_reagent) in cortical_owner.known_chemicals)
		owner.balloon_alert(owner, "chemical already known")
		return
	if(locate(learned_reagent) in cortical_owner.blacklisted_chemicals)
		owner.balloon_alert(owner, "chemical blacklisted")
		return
	if(!(learned_reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
		owner.balloon_alert(owner, "cannot learn [reagent_choice]")
		return

	cortical_owner.chemical_evolution -= chemical_evo_points
	cortical_owner.known_chemicals += learned_reagent.type
	cortical_owner.blood_chems_learned++

	cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)

	if(cortical_owner.blood_chems_learned == BLOOD_CHEM_OBJECTIVE)
		GLOB.successful_blood_chem += 1

	owner.balloon_alert(owner, "[reagent_choice] learned")
	if(!HAS_TRAIT(cortical_owner.human_host, TRAIT_AGEUSIA))
		to_chat(cortical_owner.human_host, span_notice("You get a strange aftertaste of [initial(learned_reagent.taste_description)]!"))

	StartCooldown()

#undef BLOOD_CHEM_OBJECTIVE
