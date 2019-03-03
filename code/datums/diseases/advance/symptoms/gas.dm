/*
//////////////////////////////////////

Gas release

//////////////////////////////////////
*/

/datum/symptom/gas
	name = "Flatulence"
	desc = "The virus affects intestinal biota causing flatulence."
	base_message_chance = 20
	symptom_delay_min = 15
	symptom_delay_max = 40
	naturally_occuring = FALSE

	var/infective = FALSE
	var/gas_type = /datum/gas/carbon_dioxide
	var/base_moles = 1
	var/emote = "fart"
	var/oral = FALSE

/datum/symptom/gas/Activate(datum/disease/advance/A)
	if(!..())
		return

	var/mob/living/M = A.affected_mob

	if(A.stage < 3 && prob(base_message_chance) && !suppress_warning)
		to_chat(M, "<span class='warning'>You feel bloated.</span>")
		return

	var/turf/open/T = get_turf(M)
	if(!istype(T))
		return

	var/datum/gas_mixture/air = T.return_air()
	var/list/cached_gases = air.gases

	ASSERT_GAS(gas_type, air)
	cached_gases[gas_type][MOLES] += base_moles * power * A.stage
	T.air_update_turf()

	if(infective && (!oral || M.CanSpreadAirborneDisease()))
		A.spread(4)

	M.emote(emote)

/datum/symptom/gas/plasma_flatulence
	name = "Plasma Flatulence"
	desc = "The virus affects intestinal biota causing flatulence of plasma."
	stealth = -2
	resistance = -2
	stage_speed = -3
	transmittable = 1
	level = 5
	severity = 5
	threshold_desc = "<b>Stage Speed 4:</b> Increases the amount of gas.<br>\
					  <b>Stage Speed 8:</b> Increases the amount of gas.<br>\
					  <b>Transmission 6:</b> Host will spread the virus when farting."
	naturally_occuring = TRUE
	gas_type = /datum/gas/plasma
	base_moles = 3

/datum/symptom/gas/plasma_flatulence/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 4)
		power = 1.5
	if(A.properties["stage_rate"] >= 8)
		power = 2
	if(A.properties["transmittable"] >= 6)
		infective = TRUE

/datum/symptom/gas/belch
	name = "Belching"
	desc = "The virus affects the stomach lining, causing burps."
	stealth = -1
	resistance = 0
	stage_speed = -1
	transmittable = 2
	level = 4
	severity = 1
	threshold_desc = "<b>Stage Speed 8:</b> Increases the amount of gas.<br>\
					  <b>Resistance 8:</b> Host will belch water vapor.<br>\
					  <b>Transmission 6:</b> Host will spread the virus when belching."
	naturally_occuring = TRUE
	gas_type = /datum/gas/carbon_dioxide
	emote = "burp"
	oral = TRUE

/datum/symptom/gas/belch/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
		base_moles = 3
	if(A.properties["resistance"] >= 8)
		gas_type = /datum/gas/water_vapor
	if(A.properties["transmittable"] >= 6)
		infective = TRUE
