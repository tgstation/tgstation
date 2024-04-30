/datum/species/abductor
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_QUICKER_CARRY,
		TRAIT_TRUE_NIGHT_VISION,
		TRAIT_VIRUSIMMUNE,
		TRAIT_CHUNKYFINGERS_IGNORE_BATON
	)
	species_language_holder = /datum/language_holder/universal
	coldmod = 0.5
	heatmod = 0.5
	siemens_coeff = 0.5
	var/datum/component/sign_language/signer

/datum/species/abductor/on_species_gain(mob/living/carbon/user, datum/species/old_species)
	. = ..()
	user.update_sight()
	if(!user.GetComponent(/datum/component/sign_language)) // if they're already capable of signing, don't clobber that
		signer = user.AddComponent(/datum/component/sign_language)

/datum/species/abductor/on_species_loss(mob/living/carbon/user)
	. = ..()
	user.update_sight()
	if(!QDELETED(signer))
		QDEL_NULL(signer)

/datum/species/abductor/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/weather/ashstorm/inside/weak_end.ogg'

/datum/species/abductor/get_laugh_sound(mob/living/carbon/human/human)
	return 'sound/weather/ashstorm/inside/weak_end.ogg'
