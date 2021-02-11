/datum/addiction/opiods
	name = "opiod"

/datum/addiction/stimulants
	name = "stimulant"
	addiction_stages = list("You feel a bit tired...You could really use a pick me up.", "You are getting a bit woozy...", "So...Tired...")

/datum/addiction/stimulants/withdrawal_stage_1(var/mob/living/carbon/affected_carbon)
	master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)

/datum/addiction/stimulants/withdrawal_stage_2(var/mob/living/carbon/affected_carbon)


/datum/addiction/stimulants/withdrawal_stage_3(var/mob/living/carbon/affected_carbon)
/datum/addiction/alcohol
	name = "alcohol"

/datum/addiction/hallucinogens
	name = "hallucinogen"

/datum/addiction/maintenance_drugs
	name = "maintenance drug"
