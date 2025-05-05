/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = FA_ICON_TINT
	value = -8
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	hardcore_value = 8
	mail_goodies = list(/obj/item/reagent_containers/blood/o_minus) // universal blood type that is safe for all
	/// Minimum amount of blood the paint is set to
	var/min_blood = BLOOD_VOLUME_SAFE - 25 // just barely survivable without treatment

/datum/quirk/blooddeficiency/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(lose_blood))

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder))
		return
	update_mail(human_quirk_holder = human_holder, new_blood_type = human_holder.dna.blood_type) // matches the mail goodies blood bag to our blood type
	RegisterSignal(quirk_holder, COMSIG_LIVING_CHANGED_BLOOD_TYPE, PROC_REF(update_mail))

/datum/quirk/blooddeficiency/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_HUMAN_ON_HANDLE_BLOOD, COMSIG_LIVING_CHANGED_BLOOD_TYPE))

/datum/quirk/blooddeficiency/is_species_appropriate(datum/species/mob_species)
	var/datum/species_traits = GLOB.species_prototypes[mob_species].inherent_traits
	if(TRAIT_NOBLOOD in species_traits)
		return FALSE
	if(TRAIT_NOBREATH in species_traits)
		return FALSE
	return ..()

/datum/quirk/blooddeficiency/proc/lose_blood(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(human_holder.stat == DEAD || human_holder.blood_volume <= min_blood)
		return
	// This exotic blood check is solely to snowflake slimepeople into working with this quirk
	if(HAS_TRAIT(quirk_holder, TRAIT_NOBLOOD) && isnull(human_holder.dna.species.exotic_blood))
		return

	human_holder.blood_volume = max(min_blood, human_holder.blood_volume - human_holder.dna.species.blood_deficiency_drain_rate * seconds_per_tick)

/// Try to update the mail goodies to match the quirk holder's blood type. If we fail for whatever reason then it will just default to the initial O- blood pack that we start with.
/datum/quirk/blooddeficiency/proc/update_mail(mob/living/carbon/human/human_quirk_holder, datum/blood_type/new_blood_type, update_cached_blood_dna_info)
	SIGNAL_HANDLER

	if(isnull(human_quirk_holder.dna.species.exotic_blood) && isnull(human_quirk_holder.dna.species.exotic_bloodtype))
		if(TRAIT_NOBLOOD in human_quirk_holder.dna.species.inherent_traits) // jellypeople have both exotic_blood and TRAIT_NOBLOOD
			mail_goodies.Cut()
			return

	if(isnull(new_blood_type))
		return

	for(var/obj/item/reagent_containers/blood/blood_bag as anything in typesof(/obj/item/reagent_containers/blood))
		if(blood_bag::blood_type == new_blood_type.name)
			mail_goodies = list(blood_bag)
			return
