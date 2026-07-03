/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Пигментация нашей кожи быстро меняется в зависимости от текущего окружения. Стоит 10 химикатов."
	helptext = "Позволяет нам становиться невидимыми после нескольких секунд неподвижности. Можно включать и выключать."
	button_icon_state = "chameleon_skin"
	category = "stealth"
	dna_cost = 1
	chemical_cost = 10
	req_human = TRUE

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/cling = user //SHOULD always be human, because req_human = TRUE
	if(!istype(cling)) // req_human could be done in can_sting stuff.
		return
	..()
	if(cling.dna.get_mutation(/datum/mutation/chameleon/changeling))
		cling.dna.remove_mutation(/datum/mutation/chameleon/changeling, MUTATION_SOURCE_CHANGELING)
	else
		cling.dna.add_mutation(/datum/mutation/chameleon/changeling, MUTATION_SOURCE_CHANGELING)
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	if(user.has_dna())
		var/mob/living/carbon/cling = user
		cling.dna.remove_mutation(/datum/mutation/chameleon/changeling, MUTATION_SOURCE_CHANGELING)
	..()
