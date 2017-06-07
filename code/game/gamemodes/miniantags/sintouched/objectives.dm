/datum/objective/sintouched
	dangerrating = 5
	completed = 1

/*  NO ERP OBJECTIVE FOR YOU.
/datum/objective/sintouched/lust
	dangerrating = 3 // it's not AS dangerous.

/datum/objective/sintouched/lust/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(prob(50) && D)
		explanation_text = "You know that [D] has perished.... and you think [D] is kinda cute.  Make sure everyone knows how HOT [D]'s lifeless body is."
	else
		explanation_text = "Go get married, then immediately cheat on your new spouse." */

/datum/objective/sintouched/gluttony
	explanation_text = "Everything is so delicious. Go eat everything."

/datum/objective/sintouched/greed
	explanation_text = "You want MORE, more money, more wealth, more riches.  Go get it, but don't hurt people for it."

/datum/objective/sintouched/sloth
	explanation_text = "You just get tired randomly.  Go take a nap at a time that would inconvenience other people."

/datum/objective/sintouched/wrath
	explanation_text = "What have your coworkers ever done for you? Don't offer to help them in any matter, and refuse if asked."

/datum/objective/sintouched/envy
	explanation_text = "Why should you be stuck with your rank? Show everyone you can do other jobs too, and don't let anyone stop you, least of all because you have no training"

/datum/objective/sintouched/pride
	explanation_text = "You are the BEST thing on the station.  Make sure everyone knows it."

/datum/objective/sintouched/acedia
	explanation_text = "Angels, devils, good, evil... who cares?  Just ignore any hellish threats and do your job."

/datum/objective/sintouched/engine
	explanation_text = "Go have a good conversation with the Singularity/Tesla/Supermatter crystal. Bonus points if it responds."
	
/datum/objective/sintouched/teamredisbetterthangreen
	explanation_text = "Tell the AI (or a borg/pAI/drone if there is no AI) some corny technology jokes until it cries for help."
	
/datum/objective/sintouched/time/New()
	..()
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult))
		explanation_text = "Go bug a bronze worshipper to give you a clock."
	else
		explanation_text = "You must know what time it is, all the time."
		
/datum/objective/sintouched/licky
	explanation_text = "You must lick anything that you find interesting."
	
/datum/objective/sintouched/music
	explanation_text = "Start playing music, you're the best musician ever. If anyone hates it, beat them on the head with your instrument!"
	
