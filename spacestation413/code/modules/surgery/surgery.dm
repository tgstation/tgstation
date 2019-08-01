/datum/surgery
	self_operable = TRUE //makes self surgery by default

//i'm just gonna consolidate all the surgeries i'm opting out of self-surgery in here

/datum/surgery/advanced
	self_operable = FALSE //most advanced ones are pretty strong, but i can change them on a case-by-case basis
	//giving a traitor roboticist or MD access to whatever surgeries is a bit much.

/datum/surgery/advanced/lobotomy
	self_operable = TRUE

/datum/surgery/advanced/bioware/ligament_hook
	self_operable = TRUE // these two have trade-offs so they're fine

/datum/surgery/advanced/bioware/ligament_reinforcement
	self_operable = TRUE

