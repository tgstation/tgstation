#define GAS_TOLERANCE 5

// Lungs

/obj/item/organ/internal/lungs/icebox_adapted
	name = "hardy lungs"
	desc = "Lungs adapted to frozen environments that would be otherwise inhospitable to most races. Feels cold."
	icon_state = "hardylungs"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/organs.dmi'

/obj/item/organ/internal/lungs/icebox_adapted/Initialize(mapload)
	. = ..()

	var/datum/gas_mixture/immutable/planetary/mix = SSair.planetary[ICEMOON_DEFAULT_ATMOS]

	if(!mix?.total_moles()) // If there is no icemoon atmos then we have problems, return now
		return

	// Take a "breath" of the air
	var/datum/gas_mixture/breath = mix.remove(mix.total_moles() * BREATH_PERCENTAGE)

	var/list/breath_gases = breath.gases

	breath.assert_gases(
		/datum/gas/oxygen,
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrogen,
		/datum/gas/bz,
		/datum/gas/miasma,
	)

	var/oxygen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES])
	var/nitrogen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
	var/plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
	var/carbon_dioxide_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
	var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
	var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])

	safe_oxygen_min = max(0, oxygen_pp - GAS_TOLERANCE)
	safe_nitro_min = max(0, nitrogen_pp - GAS_TOLERANCE)
	safe_plasma_min = max(0, plasma_pp - GAS_TOLERANCE)

	// Increase plasma tolerance based on amount in base air
	safe_plasma_max += plasma_pp

	// CO2 is always a waste gas, so none is required, but ashwalkers
	// tolerate the base amount plus tolerance*2 (humans tolerate only 10 pp)

	safe_co2_max = carbon_dioxide_pp + GAS_TOLERANCE * 2

	// The lung tolerance against BZ is also increased the amount of BZ in the base air
	BZ_trip_balls_min += bz_pp
	BZ_brain_damage_min += bz_pp

	// Lungs adapted to a high miasma atmosphere do not process it, and breathe it back out
	if(miasma_pp)
		suffers_miasma = FALSE

// Eyes

/obj/item/organ/internal/eyes/low_light_adapted
	color_cutoffs = list(30, 15, 15)


// Tongue
/obj/item/organ/internal/tongue/cat/primitive
	liked_foodtypes = SEAFOOD | MEAT | GORE


#undef GAS_TOLERANCE
