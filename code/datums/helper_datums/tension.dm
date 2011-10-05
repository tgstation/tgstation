#define PLAYER_WEIGHT 1
#define HUMAN_DEATH -500
#define OTHER_DEATH -500
#define EXPLO_SCORE -1000 //boum

//estimated stats
//80 minute round
//60 player server
//48k player-ticks

//60 deaths (ideally)
//20 explosions


var/global/datum/tension/tension_master

/datum/tension
	var/score

	var/deaths
	var/human_deaths
	var/explosions



	proc/process()
		score += get_num_players()*PLAYER_WEIGHT

	proc/get_num_players()
		var/peeps = 0
		for (var/mob/M in world)
			if (!M.client)
				continue
			peeps += 1

		return peeps

	proc/death(var/mob/M)
		if (!M) return
		deaths++

		if (istype(M,/mob/living/carbon/human))
			score += HUMAN_DEATH
			human_deaths++
		else
			score += OTHER_DEATH


	proc/explosion()
		score += EXPLO_SCORE
		explosions++

	New()
		score = 0
		deaths=0
		human_deaths=0
		explosions=0