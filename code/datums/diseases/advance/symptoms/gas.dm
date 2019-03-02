/*
//////////////////////////////////////

Farts

//////////////////////////////////////
*/

/datum/symptom/fart
	name = "Flatulence"
	desc = "The virus affects intestinal biota causing flatulence."
	base_message_chance = 20
	symptom_delay_min = 15
	symptom_delay_max = 40
	var/infective = FALSE
	threshold_desc = "<b>Stage Speed 4:</b> Increases the amount of gas.<br>\
					  <b>Stage Speed 7:</b> Increases the amount of gas.<br>\
					  <b>Transmission 7:</b> Host will spread the virus when farting."
	naturally_occuring = FALSE

	var/gas_type = /datum/gas/carbon_dioxide
	var/base_moles = 1

/datum/symptom/fart/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 4)
		power = 1.5
	if(A.properties["stage_rate"] >= 7)
		power = 2
	if(A.properties["transmittable"] >= 7)
		infective = TRUE

/datum/symptom/fart/Activate(datum/disease/advance/A)
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

	if(infective)
		A.spread(4)

	M.emote("fart")

/datum/symptom/fart/plasma
	name = "Plasma Flatulence"
	desc = "The virus affects intestinal biota causing flatulence of plasma."
	stealth = -2
	resistance = -2
	stage_speed = -3
	transmittable = 1
	level = 5
	severity = 5
	naturally_occuring = TRUE
	gas_type = /datum/gas/plasma
	base_moles = 3

/datum/symptom/fart/water
	name = "Wet Flatulence"
	desc = "The virus affects intestinal biota causing flatulence of water vapor."
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = 2
	level = 4
	severity = 1
	naturally_occuring = TRUE
	gas_type = /datum/gas/water_vapor
