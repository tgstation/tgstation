
/// Makes a carbon mob resist the elements, have no blood etc.
/datum/element/digital_carbon_mob

/datum/element/digital_carbon_mob/Attach(datum/target)
	. = ..()

	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	target.add_traits(list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_WEATHER_IMMUNE,
		), TRAIT_GENERIC,
	)

/datum/element/digital_carbon_mob/Detach(datum/source)
	. = ..()

	source.remove_traits(list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_WEATHER_IMMUNE,
		), TRAIT_GENERIC,
	)
