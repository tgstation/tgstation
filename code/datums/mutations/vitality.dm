/datum/mutation/human/vitality
	name = "Vitality"
	desc = "A rare mutation that allows the user to sustain far more damage than normal."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your muscles bulk up for a moment and your heart skips a beat!</span>"
	text_lose_indication = "<span class='notice'>You feel your muscles receed for a moment as your heart sinks within your chest.</span>"
	locked = TRUE
	difficulty = 20
	instability = 25
	energy_coeff = 1

/datum/mutation/human/vitality/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return
	acquirer.maxHealth += 50

/datum/mutation/human/vitality/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.maxHealth -= 50
