/datum/round_event_control/fake_virus
	name = "Fake Virus"
	typepath = /datum/round_event/fake_virus
	weight = 20

/datum/round_event/fake_virus/start()
	var/list/fake_virus_victims = list()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || H.stat == DEAD || H.InCritical())
			continue
		fake_virus_victims += H

	var/defacto_min = min(3, LAZYLEN(fake_virus_victims))
	if(defacto_min)// event will hit 1-3 people by default, but will do 1-2 or just 1 if only those many candidates are available
		for(var/i=1; i<=rand(1,defacto_min); i++)
			var/mob/living/carbon/human/hypochondriac = pick(fake_virus_victims)
			hypochondriac.apply_status_effect(STATUS_EFFECT_FAKE_VIRUS)
			fake_virus_victims -= hypochondriac
			announce_to_ghosts(hypochondriac)
