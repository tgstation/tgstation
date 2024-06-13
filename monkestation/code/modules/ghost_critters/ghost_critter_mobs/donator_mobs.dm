/mob/living/basic/var/list/ckeywhitelist = list()

/client/proc/return_donator_mobs()
	var/list/mobs = list(
		/mob/living/basic/pet/gumball_goblin,
		/mob/living/basic/pet/cirno,
		/mob/living/basic/pet/blahaj,
		/mob/living/basic/crab/spycrab,
		/mob/living/basic/mothroach/void,
		/mob/living/basic/pet/dog/germanshepherd,
		/mob/living/basic/pet/slime/talkative,
		/mob/living/basic/pet/spider/dancing,
		/mob/living/basic/butterfly/void,
		/mob/living/basic/crab/plant,
		/mob/living/basic/pet/quilmaid,
	)

	if(is_admin(src))
		return mobs
	var/list/valid_mobs = list()

	for(var/mob/living/basic/mob as anything in mobs)
		if(ckey in initial(mob.ckeywhitelist))
			valid_mobs |= mob
	return valid_mobs
