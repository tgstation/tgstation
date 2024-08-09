/datum/objective/evil_clone/murder // The existance of the murderbone objective makes evil clones properly feared, so even when they aren't murderboning they will still be shunned and persecuted.
	name = "clone supremacy"
	explanation_text = "Make sure clones of yourself are the only ones alive. Do not spare the original."

/datum/objective/evil_clone/sole
	name = "real one"
	explanation_text = "All other versions of you are imposters, eliminate them."

/datum/objective/evil_clone/rule
	name = "rightful rule"
	explanation_text = "You and your fellow clones of yourself are the rightful rulers of the station, take control."

/datum/objective/evil_clone/minion
	name = "minion"
	explanation_text = "Find the most evil being you can, and become their minion."

/datum/objective/evil_clone/dud // Relies on more destructive objectives, to create conflict from crew hating evil clones because they MIGHT have a more evil objective.
	name = "peaceful clone"
	explanation_text = "You find it really mean that some people don't like you because of your red eyes."

/datum/objective/evil_clone/tide
	name = "tider"
	explanation_text = "Crime is your religion, commit as much crime as possible. Only seriously injure people if they try to stop crime."

/datum/objective/evil_clone/fake_cult
	name = "fake cultist"
	explanation_text = "Praise"

/datum/objective/evil_clone/fake_cult/New()
	var/god = pick(list("Rat'var", "Nar'sie")) //So clones with different gods will fight eachother.
	explanation_text+=" [god]! They haven't answered your prayers yet, but surely if you pray enough and make elaborate enough rituals they will inevitably come. Make sure no heretical religions prosper."

/datum/objective/evil_clone/territorial
	name = "territorial"
	explanation_text = "The clonepod which created you is a holy site only you and your fellow clones of yourself are worthy to be in the presence of. Secure the area around the clonepod and ensure no non-clones threaten it."

/datum/objective/evil_clone/check_completion()
	return TRUE
