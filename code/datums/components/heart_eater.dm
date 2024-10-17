/datum/component/heart_eater
	/// Check if we fully ate whole heart and reset when we start eat new one.
	var/bites_taken = 0
	/// Remember the number of species damage_modifier.
	var/remember_modifier = 0
	/// Remember last heart we ate and reset bites_taken counter if we start eat new one
	var/datum/weakref/last_heart_we_ate
	/// List of all mutations allowed to get.
	var/static/list/datum/mutation/human/mutations_list = list(
		/datum/mutation/human/adaptation/cold,
		/datum/mutation/human/adaptation/heat,
		/datum/mutation/human/adaptation/pressure,
		/datum/mutation/human/adaptation/thermal,
		/datum/mutation/human/chameleon,
		/datum/mutation/human/cryokinesis,
		/datum/mutation/human/pyrokinesis,
		/datum/mutation/human/dwarfism,
		/datum/mutation/human/cindikinesis,
		/datum/mutation/human/insulated,
		/datum/mutation/human/telekinesis,
		/datum/mutation/human/telepathy,
		/datum/mutation/human/thermal,
		/datum/mutation/human/tongue_spike,
		/datum/mutation/human/webbing,
		/datum/mutation/human/xray,
	)

/datum/component/heart_eater/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	prepare_species(parent)

/datum/component/heart_eater/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(on_species_change))
	RegisterSignal(parent, COMSIG_LIVING_FINISH_EAT, PROC_REF(eat_eat_eat))

/datum/component/heart_eater/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_FINISH_EAT)
	UnregisterSignal(parent, COMSIG_SPECIES_GAIN)

/datum/component/heart_eater/proc/prepare_species(mob/living/carbon/human/eater)
	if(eater.get_liked_foodtypes() & GORE)
		return
	var/obj/item/organ/internal/tongue/eater_tongue = eater.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!eater_tongue)
		return
	eater_tongue.disliked_foodtypes &= ~GORE
	eater_tongue.liked_foodtypes |= GORE

/datum/component/heart_eater/proc/on_species_change(mob/living/carbon/human/eater, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	eater.dna?.species?.damage_modifier += remember_modifier
	prepare_species(eater)

/// Proc called when we finish eat somthing.
/datum/component/heart_eater/proc/eat_eat_eat(mob/living/carbon/human/eater, datum/what_we_ate)
	SIGNAL_HANDLER

	if(get_area(eater) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	if(!istype(what_we_ate, /obj/item/organ/internal/heart))
		return
	var/obj/item/organ/internal/heart/we_ate_heart = what_we_ate
	var/obj/item/organ/internal/heart/previous_heart = last_heart_we_ate?.resolve()
	if(we_ate_heart == previous_heart)
		return
	if (!HAS_TRAIT(we_ate_heart, TRAIT_USED_ORGAN))
		to_chat(eater, span_warning("This heart is utterly lifeless, you won't receive any boons from consuming it!"))
		return
	bites_taken = 0

	last_heart_we_ate = WEAKREF(we_ate_heart)
	bites_taken++
	if(bites_taken < (we_ate_heart.reagents.total_volume/2))
		return
	if(prob(50))
		perfect_heart(eater)
		return
	not_perfect_heart(eater)

///Perfect heart give our +10 damage modifier(Max. 80).
/datum/component/heart_eater/proc/perfect_heart(mob/living/carbon/human/eater)
	if(eater.dna?.species?.damage_modifier >= 80)
		healing_heart(eater)
		return
	eater.dna?.species?.damage_modifier += 10
	remember_modifier += 10
	healing_heart(eater)
	to_chat(eater, span_warning("This heart is perfect. You feel a surge of vital energy."))

///Not Perfect heart give random mutation.
/datum/component/heart_eater/proc/not_perfect_heart(mob/living/carbon/human/eater)
	var/datum/mutation/human/new_mutation
	var/list/datum/mutation/human/shuffle_mutation_list = shuffle(mutations_list)
	for(var/mutation_in_list in shuffle_mutation_list)
		if(is_type_in_list(mutation_in_list, eater.dna.mutations))
			continue
		new_mutation = mutation_in_list
		break
	if(isnull(new_mutation))
		healing_heart(eater)
		return
	eater.dna.add_mutation(new_mutation)
	healing_heart(eater)
	to_chat(eater, span_warning("This heart is not right for you. You now have [new_mutation.name] mutation."))

///Heart eater give also strong healing from hearts.
/datum/component/heart_eater/proc/healing_heart(mob/living/carbon/human/eater)
	for(var/heal_organ in eater.organs)
		eater.adjustOrganLoss(heal_organ, -50)
	for(var/datum/wound/heal_wound in eater.all_wounds)
		heal_wound.remove_wound()
	eater.adjustBruteLoss(-50)
	eater.adjustFireLoss(-50)
	eater.adjustToxLoss(-50)
	eater.adjustOxyLoss(-50)
	eater.adjustStaminaLoss(-50)
