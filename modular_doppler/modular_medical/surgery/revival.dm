/datum/surgery/revival/carbon/mechanic
	name = "Full System Reboot"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	possible_locs = list(BODY_ZONE_HEAD)
	target_mobtypes = list(/mob/living/carbon)
	surgery_flags = parent_type::surgery_flags | SURGERY_REQUIRE_LIMB
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/revive/carbon/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/revival/carbon/mechanic/is_valid_target(mob/living/carbon/patient)
	if (!(patient.mob_biotypes & (MOB_ROBOTIC|MOB_HUMANOID)))
		return FALSE
	var/obj/item/organ/brain/target_brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	return !isnull(target_brain)

/datum/surgery_step/revive/carbon/mechanic

/datum/surgery_step/revive/carbon/mechanic/on_revived(mob/surgeon, mob/living/patient)
	. = ..()
	var/mob/living/carbon/robotic_patient = patient
	var/datum/species/android/energy_holder = robotic_patient.dna.species
	energy_holder.core_energy += 1 MEGA JOULES // from the defibb :)
