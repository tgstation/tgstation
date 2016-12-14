//Alien lifeforms who can alter their own bodies and appearances. They have a large, difficult set of objectives because of how powerful they are.

/datum/antagonist/changeling
	name = "Changeling"
	desc = "You are a changeling! You're an alien lifeform that's definitely not the Thing with the ability to change your body in numerous ways."
	gain_fluff = "<span class='userdanger'>We are a changeling!</span>"
	loss_fluff = "<span class='userdanger'>Our link to the hivemind severs. You are alone... and no longer a changeling!</span>"
	allegiance_priority = ANTAGONIST_PRIORITY_NONHUMAN
	constant_objective = /datum/objective/escape //Changelings can't ever be martyrs.
