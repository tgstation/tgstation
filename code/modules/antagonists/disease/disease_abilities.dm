/*
Abilities that can be purchased by disease mobs. Most are just passive symptoms that will be
added to their disease, but some are active abilites that affect only the target the overmind
is currently following.
*/

GLOBAL_LIST_INIT(disease_ability_singletons, list(
new /datum/disease_ability/action/cough,
new /datum/disease_ability/action/sneeze,
new /datum/disease_ability/action/infect,
new /datum/disease_ability/symptom/mild/cough,
new /datum/disease_ability/symptom/mild/sneeze,
new /datum/disease_ability/symptom/medium/shedding,
new /datum/disease_ability/symptom/medium/beard,
new /datum/disease_ability/symptom/medium/hallucigen,
new /datum/disease_ability/symptom/medium/choking,
new /datum/disease_ability/symptom/medium/confusion,
new /datum/disease_ability/symptom/medium/vomit,
new /datum/disease_ability/symptom/medium/voice_change,
new /datum/disease_ability/symptom/medium/visionloss,
new /datum/disease_ability/symptom/medium/deafness,
new /datum/disease_ability/symptom/medium/fever,
new /datum/disease_ability/symptom/medium/chills,
new /datum/disease_ability/symptom/medium/headache,
new /datum/disease_ability/symptom/medium/viraladaptation,
new /datum/disease_ability/symptom/medium/viralevolution,
new /datum/disease_ability/symptom/medium/disfiguration,
new /datum/disease_ability/symptom/medium/polyvitiligo,
new /datum/disease_ability/symptom/medium/itching,
new /datum/disease_ability/symptom/medium/heal/weight_loss,
new /datum/disease_ability/symptom/medium/heal/sensory_restoration,
new /datum/disease_ability/symptom/medium/heal/mind_restoration,
new /datum/disease_ability/symptom/powerful/fire,
new /datum/disease_ability/symptom/powerful/flesh_eating,
new /datum/disease_ability/symptom/powerful/genetic_mutation,
new /datum/disease_ability/symptom/powerful/narcolepsy,
new /datum/disease_ability/symptom/powerful/inorganic_adaptation,
new /datum/disease_ability/symptom/powerful/heal/starlight,
new /datum/disease_ability/symptom/powerful/heal/oxygen,
new /datum/disease_ability/symptom/powerful/heal/chem,
new /datum/disease_ability/symptom/powerful/heal/metabolism,
new /datum/disease_ability/symptom/powerful/heal/dark,
new /datum/disease_ability/symptom/powerful/heal/water,
new /datum/disease_ability/symptom/powerful/heal/plasma,
new /datum/disease_ability/symptom/powerful/heal/radiation,
new /datum/disease_ability/symptom/powerful/heal/coma,
new /datum/disease_ability/symptom/powerful/heal/youth
))

/datum/disease_ability
	var/name
	var/cost = 0
	var/required_total_points = 0
	var/start_with = FALSE
	var/desc = ""
	var/stealth = 0
	var/resistance = 0
	var/stage_speed = 0
	var/transmittable = 0
	var/threshold_block = list()
	var/category = ""

	var/list/symptoms
	var/list/actions

/datum/disease_ability/New()
	..()
	if(symptoms)

		for(var/T in symptoms)
			var/datum/symptom/S = T
			stealth += initial(S.stealth)
			resistance += initial(S.resistance)
			stage_speed += initial(S.stage_speed)
			transmittable += initial(S.transmittable)
			threshold_block += initial(S.threshold_descs)
			if(symptoms.len == 1) //lazy boy's dream
				name = initial(S.name)
				if(desc == "")
					desc = initial(S.desc)

/datum/disease_ability/proc/CanBuy(mob/camera/disease/D)
	if(world.time < D.next_adaptation_time)
		return FALSE
	if(!D.unpurchased_abilities[src])
		return FALSE
	return (D.points >= cost) && (D.total_points >= required_total_points)

/datum/disease_ability/proc/Buy(mob/camera/disease/D, silent = FALSE, trigger_cooldown = TRUE)
	if(!silent)
		to_chat(D, span_notice("Purchased [name]."))
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
				S.OnAdd(SD)
				if(SD.processing)
					if(S.Start(SD))
						S.next_activation = world.time + rand(S.symptom_delay_min * 10, S.symptom_delay_max * 10)
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
		to_chat(D, span_notice("Refunded [name]."))
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
					S.OnRemove(SD)
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
	desc = "Force the host you are following to sneeze, spreading your infection to those in front of them."

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
		to_chat(D, span_warning("Your host must be conscious to cough."))
		return FALSE
	to_chat(D, span_notice("You force [L.real_name] to cough."))
	L.emote("cough")
	if(L.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
		var/datum/disease/advance/sentient_disease/SD = D.hosts[L]
		SD.spread(2)
	StartCooldown()
	return TRUE


/datum/disease_ability/action/sneeze
	name = "Voluntary Sneezing"
	actions = list(/datum/action/cooldown/disease_sneeze)
	cost = 2
	required_total_points = 3
	desc = "Force the host you are following to sneeze, spreading your infection to those in front of them."

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
		to_chat(D, span_warning("Your host must be conscious to sneeze."))
		return FALSE
	to_chat(D, span_notice("You force [L.real_name] to sneeze."))
	L.emote("sneeze")
	if(L.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
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
	desc = "For a while, objects your host touches becomes contagious. Contagious objects infect whomever handles them."

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

/*******************BASE SYMPTOM TYPES*******************/
// cost is for convenience and can be changed. If you're changing req_tot_points then don't use the subtype...
//healing costs more so you have to techswitch from naughty disease otherwise we'd have friendly disease for easy greentext (no fun!)

/datum/disease_ability/symptom/mild
	cost = 2
	required_total_points = 4
	category = "Minor"

/datum/disease_ability/symptom/medium
	cost = 4
	required_total_points = 8
	category = "Intermediate"

/datum/disease_ability/symptom/medium/heal
	cost = 5
	category = "Heal"

/datum/disease_ability/symptom/powerful
	cost = 4
	required_total_points = 16
	category = "Major"

/datum/disease_ability/symptom/powerful/heal
	cost = 8
	category = "Major Heal"

/******MILD******/

/datum/disease_ability/symptom/mild/cough
	name = "Involuntary Coughing"
	symptoms = list(/datum/symptom/cough)
	desc = "Cause victims to cough intermittently, spreading your infection. Good starting point."

/datum/disease_ability/symptom/mild/sneeze
	name = "Involuntary Sneezing"
	symptoms = list(/datum/symptom/sneeze)
	desc = "Cause victims to sneeze intermittently, spreading your infection. Another good starting point."

/******MEDIUM******/

/datum/disease_ability/symptom/medium/shedding
	symptoms = list(/datum/symptom/shedding)
	desc = "The virus causes rapid shedding of head and body hair. Great for stats, but you may get cured by a baldie."

/datum/disease_ability/symptom/medium/beard
	symptoms = list(/datum/symptom/beard)
	desc = "Cause all victims to grow a luscious beard. Ineffective against Santa Claus."

/datum/disease_ability/symptom/medium/hallucigen
	symptoms = list(/datum/symptom/hallucigen)
	desc = "Cause victims to hallucinate. Decreases stats, especially resistance, but is otherwise very strong."

/datum/disease_ability/symptom/medium/choking
	symptoms = list(/datum/symptom/choking)
	desc = "Cause victims to choke, threatening asphyxiation. Decreases stats, especially transmissibility."

/datum/disease_ability/symptom/medium/confusion
	symptoms = list(/datum/symptom/confusion)
	desc = "Cause victims to become confused intermittently. Very annoying, will make people try to cure you."

/datum/disease_ability/symptom/medium/vomit
	symptoms = list(/datum/symptom/vomit)
	desc = "Cause victims to vomit. Vomiting also also causes the victims to lose nutrition and removes some toxin damage."

/datum/disease_ability/symptom/medium/voice_change
	symptoms = list(/datum/symptom/voice_change)
	desc = "Change the voice of victims, causing confusion in communications, and a headache for security."

/datum/disease_ability/symptom/medium/visionloss
	symptoms = list(/datum/symptom/visionloss)
	desc = "Damage the eyes of victims, eventually causing blindness. Decreases all stats."

/datum/disease_ability/symptom/medium/deafness
	desc = "The virus causes inflammation of the eardrums, causing intermittent deafness."
	symptoms = list(/datum/symptom/deafness)

/datum/disease_ability/symptom/medium/fever
	desc = "The virus causes a febrile response from the host, raising its body temperature."
	symptoms = list(/datum/symptom/fever)

/datum/disease_ability/symptom/medium/chills
	desc = "The virus inhibits the body's thermoregulation, cooling the body down."
	symptoms = list(/datum/symptom/chills)

/datum/disease_ability/symptom/medium/headache
	desc = "The virus causes inflammation inside the brain, causing constant headaches."
	symptoms = list(/datum/symptom/headache)

/datum/disease_ability/symptom/medium/viraladaptation
	symptoms = list(/datum/symptom/viraladaptation)
	desc = "Cause your infection to become more resistant to detection and eradication."

/datum/disease_ability/symptom/medium/viralevolution
	desc = "The virus sets stage speed and transmission to overdrive, at the cost of lowering defensive stats. Burn bright, burn out!"
	symptoms = list(/datum/symptom/viralevolution)

/datum/disease_ability/symptom/medium/polyvitiligo
	symptoms = list(/datum/symptom/polyvitiligo)

/datum/disease_ability/symptom/medium/disfiguration
	symptoms = list(/datum/symptom/disfiguration)

/datum/disease_ability/symptom/medium/itching
	symptoms = list(/datum/symptom/itching)
	desc = "Cause victims to itch, increasing all stats except stealth. You monster."

/datum/disease_ability/symptom/medium/heal/weight_loss
	symptoms = list(/datum/symptom/weight_loss)
	desc = "Cause victims to lose weight, and struggle with gaining it. Helps your infection spread, especially by sneezing."

/datum/disease_ability/symptom/medium/heal/sensory_restoration
	symptoms = list(/datum/symptom/sensory_restoration)
	desc = "The virus restores sensory cells that the body cannot normally regenerate."

/datum/disease_ability/symptom/medium/heal/mind_restoration
	symptoms = list(/datum/symptom/mind_restoration)

/******POWERFUL******/

/datum/disease_ability/symptom/powerful/fire
	symptoms = list(/datum/symptom/fire)
	desc = "The virus turns fat into an extremely flammable compound, and spikes the body's temperature. Result? COMBUSTION!"

/datum/disease_ability/symptom/powerful/flesh_eating
	symptoms = list(/datum/symptom/flesh_eating)

/datum/disease_ability/symptom/powerful/genetic_mutation
	symptoms = list(/datum/symptom/genetic_mutation)
		desc = "The virus activates dormant mutations in the victim. Almost always incredibly debilitating, if not lethal."
	cost = 8

/datum/disease_ability/symptom/powerful/inorganic_adaptation
	symptoms = list(/datum/symptom/inorganic_adaptation)

/datum/disease_ability/symptom/powerful/narcolepsy
	symptoms = list(/datum/symptom/narcolepsy)

/****HEALING SUBTYPE****/

/datum/disease_ability/symptom/powerful/heal/starlight
	symptoms = list(/datum/symptom/heal/starlight)

/datum/disease_ability/symptom/powerful/heal/oxygen
	symptoms = list(/datum/symptom/oxygen)

/datum/disease_ability/symptom/powerful/heal/chem
	symptoms = list(/datum/symptom/heal/chem)

/datum/disease_ability/symptom/powerful/heal/metabolism
	symptoms = list(/datum/symptom/heal/metabolism)
	desc = "Increase the metabolism of victims, causing them to process chemicals twice as fast and grow hungry more quickly."

/datum/disease_ability/symptom/powerful/heal/dark
	symptoms = list(/datum/symptom/heal/darkness)
	desc = "The virus mends the host in low light conditions. Most effective against brute damage."

/datum/disease_ability/symptom/powerful/heal/water
	symptoms = list(/datum/symptom/heal/water)
	desc = "The virus uses water it comes into contact with to heal the host. Better with holy water and against burns."

/datum/disease_ability/symptom/powerful/heal/plasma
	symptoms = list(/datum/symptom/heal/plasma)

/datum/disease_ability/symptom/powerful/heal/radiation
	symptoms = list(/datum/symptom/heal/radiation)
	desc = "The virus uses radiation to fix damage through dna mutations. I told you supermatter parties are good for you!"

/datum/disease_ability/symptom/powerful/heal/coma
	symptoms = list(/datum/symptom/heal/coma)
	desc = "Cause victims to fall into a healing coma when hurt. Despite being helpful, this will piss some people off."

/datum/disease_ability/symptom/powerful/heal/youth
	symptoms = list(/datum/symptom/youth)
	desc = "Cause victims to become eternally young. Provides boosts to all stats except transmissibility."
