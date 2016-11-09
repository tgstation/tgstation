//returns a list of scriptures and if they're unlocked or not
/proc/scripture_unlock_check()
	var/servants = 0
	var/unconverted_ai_exists = FALSE
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
		else if(isAI(M))
			unconverted_ai_exists = TRUE
	. = list(SCRIPTURE_DRIVER = TRUE, SCRIPTURE_SCRIPT = FALSE, SCRIPTURE_APPLICATION = FALSE, SCRIPTURE_REVENANT = FALSE, SCRIPTURE_JUDGEMENT = FALSE)
	//Drivers: always unlocked
	.[SCRIPTURE_SCRIPT] = (servants >= 5 && clockwork_caches >= 1)
	//Script: 5 or more non-brain servants and 1+ clockwork caches
	.[SCRIPTURE_APPLICATION] = (servants >= 8 && clockwork_caches >= 3 && clockwork_construction_value >= 100)
	//Application: 8 or more non-brain servants, 3+ clockwork caches, and at least 100 CV
	.[SCRIPTURE_REVENANT] = (servants >= 10 && clockwork_caches >= 4 && clockwork_construction_value >= 200)
	//Revenant: 10 or more non-brain servants, 4+ clockwork caches, and at least 200 CV
	.[SCRIPTURE_JUDGEMENT] = (servants >= 12 && clockwork_caches >= 5 && clockwork_construction_value >= 300 && !unconverted_ai_exists)
	//Judgement: 12 or more non-brain servants, 5+ clockwork caches, at least 300 CV, and there are no living, non-servant ais

//reports to servants when scripture is locked or unlocked
/proc/scripture_unlock_alert(list/previous_states)
	. = scripture_unlock_check()
	for(var/i in .)
		if(.[i] != previous_states[i])
			hierophant_message("<span class='large_brass'><i>Hierophant Network:</i> <b>[i] Scripture has been [.[i] ? "un":""]locked.</b></span>")

//changes construction value
/proc/change_construction_value(amount)
	clockwork_construction_value += amount

//throws the no cache alert if there are no caches and clears it otherwise
/proc/cache_check(mob/M)
	if(!clockwork_caches)
		M.throw_alert("nocache", /obj/screen/alert/clockwork/nocache)
	else
		M.clear_alert("nocache")
