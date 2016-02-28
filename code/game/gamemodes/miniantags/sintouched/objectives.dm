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
	explanation_text = "You are on edge and just want to PUNCH somebody.  Make sure people know this, through either your words or your fists."

/datum/objective/sintouched/envy
	explanation_text = "You want something, but can't have it.  Break it instead."

/datum/objective/sintouched/envy/New()
	var/list/jobs = SSjob.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text = "Those [target.title]s are always showing off their newest work.  Go knock them down a peg or two, without physically harming them."

/datum/objective/sintouched/pride
	explanation_text = "You are the BEST thing on the station.  Make sure everyone knows it."

/datum/objective/sintouched/acedia
	explanation_text = "Angels, demons, good, evil... who cares?  Just ignore any demonic threats and do your job."