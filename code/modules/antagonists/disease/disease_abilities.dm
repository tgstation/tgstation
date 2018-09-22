/*
Abilities that can be purchased by disease mobs. Most are just passive symptoms that will be
added to their disease, but some are active abilites that affect only the target the overmind
is currently following.
*/

GLOBAL_LIST_INIT(disease_ability_singletons, list(
	new /datum/disease_ability/action/cough(),
	new /datum/disease_ability/action/sneeze(),
	new /datum/disease_ability/action/infect(),
	new /datum/disease_ability/symptom/cough(),
	new /datum/disease_ability/symptom/sneeze(),\
	new /datum/disease_ability/symptom/hallucigen(),
	new /datum/disease_ability/symptom/choking(),
	new /datum/disease_ability/symptom/confusion(),
	new /datum/disease_ability/symptom/youth(),
	new /datum/disease_ability/symptom/vomit(),
	new /datum/disease_ability/symptom/voice_change(),
	new /datum/disease_ability/symptom/visionloss(),
	new /datum/disease_ability/symptom/viraladaptation(),
	new /datum/disease_ability/symptom/vitiligo(),
	new /datum/disease_ability/symptom/sensory_restoration(),
	new /datum/disease_ability/symptom/itching(),
	new /datum/disease_ability/symptom/weight_loss(),
	new /datum/disease_ability/symptom/metabolism_heal(),
	new /datum/disease_ability/symptom/coma_heal()
	))

/datum/disease_ability
	var/name
	var/cost = 0
	var/required_total_points = 0
	var/start_with = FALSE
	var/short_desc = ""
	var/long_desc = ""
	var/stat_block = ""
	var/threshold_block = ""
	var/category = ""

	var/list/symptoms
	var/list/actions

/datum/disease_ability/New()
	..()
	if(symptoms)
		var/stealth = 0
		var/resistance = 0
		var/stage_speed = 0
		var/transmittable = 0
		for(var/T in symptoms)
			var/datum/symptom/S = T
			stealth += initial(S.stealth)
			resistance += initial(S.resistance)
			stage_speed += initial(S.stage_speed)
			transmittable += initial(S.transmittable)
			threshold_block += "<br><br>[initial(S.threshold_desc)]"
		stat_block = "Resistance: [resistance]<br>Stealth: [stealth]<br>Stage Speed: [stage_speed]<br>Transmissibility: [transmittable]<br><br>"

/datum/disease_ability/proc/CanBuy(mob/camera/disease/D)
	if(world.time < D.next_adaptation_time)
		return FALSE
	if(!D.unpurchased_abilities[src])
		return FALSE
	return (D.points >= cost) && (D.total_points >= required_total_points)

/datum/disease_ability/proc/Buy(mob/camera/disease/D, silent = FALSE, trigger_cooldown = TRUE)
	if(!silent)
		to_chat(D, "<span class='notice'>Purchased [name].</span>")
	D.points -= cost
	D.unpurchased_abilities -= src
	if(trigger_cooldown)
		D.adapt_cooldown()
	D.purchased_abilities[src] = TRUE
	for(var/V in (D.disease_instances+D.disease_template))
		var/datum/disease/advance/sentient_disease/SD = V
		if(symptoms)
			for(var/T in symptoms)
				var/datum/symptom/S = new T()
				SD.symptoms += S
				if(SD.processing)
					S.Start(SD)
			SD.Refresh()
	for(var/T in actions)
		var/datum/action/A = new T()
		A.Grant(D)


/datum/disease_ability/proc/CanRefund(mob/camera/disease/D)
	if(world.time < D.next_adaptation_time)
		return FALSE
	return D.purchased_abilities[src]

/datum/disease_ability/proc/Refund(mob/camera/disease/D, silent = FALSE, trigger_cooldown = TRUE)
	if(!silent)
		to_chat(D, "<span class='notice'>Refunded [name].</span>")
	D.points += cost
	D.unpurchased_abilities[src] = TRUE
	if(trigger_cooldown)
		D.adapt_cooldown()
	D.purchased_abilities -= src
	for(var/V in (D.disease_instances+D.disease_template))
		var/datum/disease/advance/sentient_disease/SD = V
		if(symptoms)
			for(var/T in symptoms)
				var/datum/symptom/S = locate(T) in SD.symptoms
				if(S)
					SD.symptoms -= S
					if(SD.processing)
						S.End(SD)
					qdel(S)
			SD.Refresh()
	for(var/T in actions)
		var/datum/action/A = locate(T) in D.actions
		qdel(A)

//these sybtypes are for conveniently separating the different categories, they have no unique code.

/datum/disease_ability/action
	category = "Active"

/datum/disease_ability/symptom
	category = "Symptom"

//active abilities and their associated actions

/datum/disease_ability/action/cough
	name = "Voluntary Coughing"
	actions = list(/datum/action/cooldown/disease_cough)
	cost = 0
	required_total_points = 0
	start_with = TRUE
	short_desc = "Force the host you are following to cough, spreading your infection to those nearby."
	long_desc = "Force the host you are following to cough with extra force, spreading your infection to those within two meters of your host even if your transmissibility is low.<br>Cooldown: 10 seconds"


/datum/action/cooldown/disease_cough
	name = "Cough"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "cough"
	desc = "Force the host you are following to cough with extra force, spreading your infection to those within two meters of your host even if your transmissibility is low.<br>Cooldown: 10 seconds"
	cooldown_time = 100

/datum/action/cooldown/disease_cough/Trigger()
	if(!..())
		return FALSE
	var/mob/camera/disease/D = owner
	var/mob/living/L = D.following_host
	if(!L)
		return FALSE
	if(L.stat != CONSCIOUS)
		to_chat(D, "<span class='warning'>Your host must be conscious to cough.</span>")
		return FALSE
	to_chat(D, "<span class='notice'>You force [L.real_name] to cough.</span>")
	L.emote("cough")
	var/datum/disease/advance/sentient_disease/SD = D.hosts[L]
	SD.spread(2)
	StartCooldown()
	return TRUE


/datum/disease_ability/action/sneeze
	name = "Voluntary Sneezing"
	actions = list(/datum/action/cooldown/disease_sneeze)
	cost = 2
	required_total_points = 3
	short_desc = "Force the host you are following to sneeze, spreading your infection to those in front of them."
	long_desc = "Force the host you are following to sneeze with extra force, spreading your infection to any victims in a 4 meter cone in front of your host.<br>Cooldown: 20 seconds"

/datum/action/cooldown/disease_sneeze
	name = "Sneeze"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "sneeze"
	desc = "Force the host you are following to sneeze with extra force, spreading your infection to any victims in a 4 meter cone in front of your host even if your transmissibility is low.<br>Cooldown: 20 seconds"
	cooldown_time = 200

/datum/action/cooldown/disease_sneeze/Trigger()
	if(!..())
		return FALSE
	var/mob/camera/disease/D = owner
	var/mob/living/L = D.following_host
	if(!L)
		return FALSE
	if(L.stat != CONSCIOUS)
		to_chat(D, "<span class='warning'>Your host must be conscious to sneeze.</span>")
		return FALSE
	to_chat(D, "<span class='notice'>You force [L.real_name] to sneeze.</span>")
	L.emote("sneeze")
	var/datum/disease/advance/sentient_disease/SD = D.hosts[L]

	for(var/mob/living/M in oview(4, SD.affected_mob))
		if(is_A_facing_B(SD.affected_mob, M) && disease_air_spread_walk(get_turf(SD.affected_mob), get_turf(M)))
			M.AirborneContractDisease(SD, TRUE)

	StartCooldown()
	return TRUE


/datum/disease_ability/action/infect
	name = "Secrete Infection"
	actions = list(/datum/action/cooldown/disease_infect)
	cost = 2
	required_total_points = 3
	short_desc = "Cause all objects your host is touching to become infectious for a limited time, spreading your infection to anyone who touches them."
	long_desc = "Cause the host you are following to excrete an infective substance from their pores, causing all objects touching their skin to transmit your infection to anyone who touches them for the next 30 seconds. This includes the floor, if they are not wearing shoes, and any items they are holding, if they are not wearing gloves.<br>Cooldown: 40 seconds"

/datum/action/cooldown/disease_infect
	name = "Secrete Infection"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "infect"
	desc = "Cause the host you are following to excrete an infective substance from their pores, causing all objects touching their skin to transmit your infection to anyone who touches them for the next 30 seconds.<br>Cooldown: 40 seconds"
	cooldown_time = 400

/datum/action/cooldown/disease_infect/Trigger()
	if(!..())
		return FALSE
	var/mob/camera/disease/D = owner
	var/mob/living/carbon/human/H = D.following_host
	if(!H)
		return FALSE
	for(var/V in H.get_equipped_items(FALSE))
		var/obj/O = V
		O.AddComponent(/datum/component/infective, D.disease_template, 300)
	//no shoes? infect the floor.
	if(!H.shoes)
		var/turf/T = get_turf(H)
		if(T && !isspaceturf(T))
			T.AddComponent(/datum/component/infective, D.disease_template, 300)
	//no gloves? infect whatever we are holding.
	if(!H.gloves)
		for(var/V in H.held_items)
			if(!V)
				continue
			var/obj/O = V
			O.AddComponent(/datum/component/infective, D.disease_template, 300)
	StartCooldown()
	return TRUE

//passive symptom abilities

/datum/disease_ability/symptom/cough
	name = "Involuntary Coughing"
	symptoms = list(/datum/symptom/cough)
	cost = 2
	required_total_points = 4
	short_desc = "Cause victims to cough intermittently."
	long_desc = "Cause victims to cough intermittently, spreading your infection if your transmissibility is high."

/datum/disease_ability/symptom/sneeze
	name = "Involuntary Sneezing"
	symptoms = list(/datum/symptom/sneeze)
	cost = 2
	required_total_points = 4
	short_desc = "Cause victims to sneeze intermittently."
	long_desc = "Cause victims to sneeze intermittently, spreading your infection and also increasing transmissibility and resistance, at the cost of stealth."

/datum/disease_ability/symptom/beard
	//I don't think I need to justify the fact that this is the best symptom
	name = "Beard Growth"
	symptoms = list(/datum/symptom/beard)
	cost = 1
	required_total_points = 8
	short_desc = "Cause all victims to grow a luscious beard."
	long_desc = "Cause all victims to grow a luscious beard. Decreases stats slightly. Ineffective against Santa Claus."

/datum/disease_ability/symptom/hallucigen
	name = "Hallucinations"
	symptoms = list(/datum/symptom/hallucigen)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to hallucinate."
	long_desc = "Cause victims to hallucinate. Decreases stats, especially resistance."


/datum/disease_ability/symptom/choking
	name = "Choking"
	symptoms = list(/datum/symptom/choking)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to choke."
	long_desc = "Cause victims to choke, threatening asphyxiation. Decreases stats, especially transmissibility."


/datum/disease_ability/symptom/confusion
	name = "Confusion"
	symptoms = list(/datum/symptom/confusion)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to become confused."
	long_desc = "Cause victims to become confused intermittently."


/datum/disease_ability/symptom/youth
	name = "Eternal Youth"
	symptoms = list(/datum/symptom/youth)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to become eternally young."
	long_desc = "Cause victims to become eternally young. Provides boosts to all stats except transmissibility."


/datum/disease_ability/symptom/vomit
	name = "Vomiting"
	symptoms = list(/datum/symptom/vomit)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to vomit."
	long_desc = "Cause victims to vomit. Slightly increases transmissibility. Vomiting also also causes the victims to lose nutrition and removes some toxin damage."


/datum/disease_ability/symptom/voice_change
	name = "Voice Changing"
	symptoms = list(/datum/symptom/voice_change)
	cost = 4
	required_total_points = 8
	short_desc = "Change the voice of victims."
	long_desc = "Change the voice of victims, causing confusion in communications."


/datum/disease_ability/symptom/visionloss
	name = "Vision Loss"
	symptoms = list(/datum/symptom/visionloss)
	cost = 4
	required_total_points = 8
	short_desc = "Damage the eyes of victims, eventually causing blindness."
	long_desc = "Damage the eyes of victims, eventually causing blindness. Decreases all stats."


/datum/disease_ability/symptom/viraladaptation
	name = "Self-Adaptation"
	symptoms = list(/datum/symptom/viraladaptation)
	cost = 4
	required_total_points = 8
	short_desc = "Cause your infection to become more resistant to detection and eradication."
	long_desc = "Cause your infection to mimic the function of normal body cells, becoming much harder to spot and to eradicate, but reducing its speed."


/datum/disease_ability/symptom/vitiligo
	name = "Skin Paleness"
	symptoms = list(/datum/symptom/vitiligo)
	cost = 1
	required_total_points = 8
	short_desc = "Cause victims to become pale."
	long_desc = "Cause victims to become pale. Decreases all stats."


/datum/disease_ability/symptom/sensory_restoration
	name = "Sensory Restoration"
	symptoms = list(/datum/symptom/sensory_restoration)
	cost = 4
	required_total_points = 8
	short_desc = "Regenerate eye and ear damage of victims."
	long_desc = "Regenerate eye and ear damage of victims."


/datum/disease_ability/symptom/itching
	name = "Itching"
	symptoms = list(/datum/symptom/itching)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to itch."
	long_desc = "Cause victims to itch, increasing all stats except stealth."


/datum/disease_ability/symptom/weight_loss
	name = "Weight Loss"
	symptoms = list(/datum/symptom/weight_loss)
	cost = 4
	required_total_points = 8
	short_desc = "Cause victims to lose weight."
	long_desc = "Cause victims to lose weight, and make it almost impossible for them to gain nutrition from food. Reduced nutrition allows your infection to spread more easily from hosts, especially by sneezing."


/datum/disease_ability/symptom/metabolism_heal
	name = "Metabolic Boost"
	symptoms = list(/datum/symptom/heal/metabolism)
	cost = 4
	required_total_points = 16
	short_desc = "Increase the metabolism of victims, causing them to process chemicals and grow hungry faster."
	long_desc = "Increase the metabolism of victims, causing them to process chemicals twice as fast and grow hungry more quickly."


/datum/disease_ability/symptom/coma_heal
	name = "Regenerative Coma"
	symptoms = list(/datum/symptom/heal/coma)
	cost = 8
	required_total_points = 16
	short_desc = "Cause victims to fall into a healing coma when hurt."
	long_desc = "Cause victims to fall into a healing coma when hurt."
