//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/human/chameleon
	name = "Chameleon"
	quality = POSITIVE
	get_chance = 20
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>You feel one with your surroundings.</span>"
	text_lose_indication = "<span class='notice'>You feel oddly exposed.</span>"
	time_coeff = 5

/datum/mutation/human/chameleon/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/on_life(mob/living/carbon/human/owner)
	owner.alpha = max(0, owner.alpha - 25)

/datum/mutation/human/chameleon/on_move(mob/living/carbon/human/owner)
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity) //stops tk from breaking chameleon
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
		return

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = 255
