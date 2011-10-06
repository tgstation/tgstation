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
	var/adminhelps
	var/air_alarms

	New()
		score = 0
		deaths=0
		human_deaths=0
		explosions=0
		adminhelps=0
		air_alarms=0

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

	proc/new_adminhelp()
		adminhelps++

	proc/new_air_alarm()
		air_alarms++