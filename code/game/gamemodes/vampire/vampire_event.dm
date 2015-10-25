/datum/round_event_control/create_vampire_goblet
	name = "Create Blood Goblet"
	typepath = /datum/round_event/create_vampire_goblet
	weight = 7
	max_occurrences = 3
	earliest_start = 3600 //5 minutes


/datum/round_event/create_vampire_goblet


/datum/round_event/create_vampire_goblet/start()
	var/mob/living/carbon/human/H = get_vampire_candidate()
	if(!H)
		message_admins("Event attempted to spawn a vampire creation goblet, but could not find any candidates!")
		return 0
	var/obj/item/weapon/antag_spawner/vampire/G = new(get_turf(H))
	H << "<span class='userdanger'>You feel a gentle wind as an enticing goblet appears [H.put_in_hands(G) ? "in your hands" : "at your feet"]...</span>"
	H << 'sound/spookoween/ghosty_wind.ogg'


/datum/round_event/create_vampire_goblet/proc/get_vampire_candidate()
	var/list/potential_candidates = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.client && H.mind && !is_vampire(H) && !isloyal(H) && !iscultist(H) && !H.mind.changeling)
			potential_candidates.Add(H)
	if(potential_candidates.len)
		var/chosen_candidate = pick(potential_candidates)
		return chosen_candidate
	return 0
