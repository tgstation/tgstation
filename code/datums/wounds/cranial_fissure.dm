/datum/wound_pregen_data/cranial_fissure
	wound_path_to_generate = /datum/wound/cranial_fissure
	required_limb_biostate = BIO_BONE

	required_wounding_types = list(WOUND_ALL)

	wound_series = WOUND_SERIES_CRANIAL_FISSURE

	threshold_minimum = 150
	weight = 10

	viable_zones = list(BODY_ZONE_HEAD)

/datum/wound_pregen_data/cranial_fissure/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	if (limb.owner?.stat < HARD_CRIT)
		return 0

	return ..()

/datum/wound/cranial_fissure
	name = "Cranial Fissure"
	desc = "Patient's crown is agape, revealing severe damage to the skull."
	treat_text = "Immediate surgical reconstruction of the skull."
	examine_desc = "is split open"
	occur_text = "is split into two separated chunks"

	simple_desc = "Patient's skull is split open."
	threshold_penalty = 40

	severity = WOUND_SEVERITY_CRITICAL
	sound_effect = 'sound/effects/dismember.ogg'

#define CRANIAL_FISSURE_FILTER_DISPLACEMENT "cranial_fissure_displacement"

/datum/wound/cranial_fissure/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	ADD_TRAIT(limb, TRAIT_IMMUNE_TO_CRANIAL_FISSURE, type)

	victim.add_filter(CRANIAL_FISSURE_FILTER_DISPLACEMENT, 2, displacement_map_filter(icon('icons/effects/cranial_fissure.dmi', "displacement"), size = 3))

	RegisterSignal(victim, COMSIG_MOB_SLIPPED, PROC_REF(on_owner_slipped))

/datum/wound/cranial_fissure/remove_wound(ignore_limb, replaced)
	REMOVE_TRAIT(limb, TRAIT_IMMUNE_TO_CRANIAL_FISSURE, type)

	victim.remove_filter(CRANIAL_FISSURE_FILTER_DISPLACEMENT)

	UnregisterSignal(victim, COMSIG_MOB_SLIPPED)

	return ..()

/datum/wound/cranial_fissure/proc/on_owner_slipped(mob/source)
	SIGNAL_HANDLER

	if (source.stat == DEAD)
		return

	var/obj/item/organ/internal/brain/brain = source.get_organ_by_type(/obj/item/organ/internal/brain)
	if (isnull(brain))
		return

	brain.Remove(source)

	var/turf/source_turf = get_turf(source)
	brain.forceMove(source_turf)
	brain.throw_at(get_step(source_turf, source.dir), 1, 1)

	source.visible_message(
		span_boldwarning("[source]'s brain spills right out of [source.p_their()] head!"),
		span_userdanger("Your brain spills right out of your head!"),
	)

#undef CRANIAL_FISSURE_FILTER_ALPHA
#undef CRANIAL_FISSURE_FILTER_DISPLACEMENT
