/datum/curse/necropolis
	curse_name = "necropolis curse"
	curse_desc = "random necropolis curse"
	var/ncurse_type = 0

/datum/curse/necropolis/trigger(mob/user)
	if(!isliving(user))
		return
	var/mob/living/L = user
	L.apply_necropolis_curse(ncurse_type)
	. = ..()

/datum/curse/necropolis/blindness
	curse_name = "necropolis blindness curse"
	curse_desc = "kinda blinds it's victim for long time"
	ncurse_type = CURSE_BLINDING

/datum/curse/necropolis/spawning
	curse_name = "necropolis spawning curse"
	curse_desc = "continiously summons hostile ghosts that only attack curse victim"
	ncurse_type = CURSE_SPAWNING

/datum/curse/necropolis/wasting
	curse_name = "necropolis wasing curse"
	curse_desc = "continiously burns it's victim"
	ncurse_type = CURSE_WASTING

/datum/curse/necropolis/grasping
	curse_name = "necropolis grasping curse"
	curse_desc = "continiously summons ghost hands that try to grasp curse victim only"
	ncurse_type = CURSE_GRASPING

/datum/curse/necropolis/mixed
	curse_name = "mixed necropolis curse"
	curse_desc = "combines some effects of necropolis curses"
	var/cprob = 50

/datum/curse/necropolis/mixed/New()
	if(prob(cprob))
		ncurse_type |= CURSE_BLINDING
	if(prob(cprob))
		ncurse_type |= CURSE_SPAWNING
	if(prob(cprob))
		ncurse_type |= CURSE_WASTING
	if(prob(cprob))
		ncurse_type |= CURSE_GRASPING

/datum/curse/necropolis/mixed/all
	cprob = 100