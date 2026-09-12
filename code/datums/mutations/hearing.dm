// Deafness makes you deaf.
/datum/mutation/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to hear anything.")
	mutation_traits = list(TRAIT_DEAF)

// Advanced sense for soundwaves grants sight with hearing
/datum/mutation/echolocation
	name = "Echolocation"
	desc = "A mutation which enhances hearing, as alternative method of 'sight'."
	instability = POSITIVE_INSTABILITY_MINOR
	quality = MINOR_NEGATIVE
	locked = TRUE // abyssal Cerulean type thing
	text_gain_indication = span_danger("Your vision dims, yet vibrations in the air are suddenly trivial to pinpoint.")
	text_lose_indication = span_notice("Your eyes sting as light suddenly overwhelms. In contrast, everything sounds dull to your ears.")
	/// holder for the component that drives the mutation
	var/datum/weakref/echolocation_component

/datum/mutation/echolocation/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	echolocation_component = WEAKREF(acquirer.AddComponent(/datum/component/echolocation))

/datum/mutation/echolocation/on_losing(mob/living/carbon/human/owner)
	. = ..()
	qdel(echolocation_component)
