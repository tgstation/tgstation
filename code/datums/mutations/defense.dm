/datum/mutation/human/metallineskin
	name = "Metalline Skin"
	desc = "A rare mutation that allows the user to sustain far more Brute damage than normal."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You suddenly feel like your enclosed in a metal box...</span>"
	text_lose_indication = "<span class='notice'>You feel like you can breath again as your body no longer feels like a metal box.</span>"
	locked = TRUE
	difficulty = 18
	instability = 20
	energy_coeff = 1

/datum/mutation/human/metallineskin/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return
	acquirer.physiology.brute_mod *= 0.75

/datum/mutation/human/metallineskin/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.brute_mod *= 1.25


/datum/mutation/human/reflectiveskin
	name = "Reflective Skin"
	desc = "A rare mutation that allows the user to sustain far more Burn damage than normal."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin looks rather reflective!</span>"
	text_lose_indication = "<span class='notice'>The pigments in your skin turn dull.</span>"
	locked = TRUE
	difficulty = 18
	instability = 20
	energy_coeff = 1

/datum/mutation/human/reflectiveskin/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return
	acquirer.physiology.burn_mod *= 0.75

/datum/mutation/human/reflectiveskin/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 1.25
