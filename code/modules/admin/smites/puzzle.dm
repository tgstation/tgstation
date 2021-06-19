/// Turns the user into a sliding puzzle
/datum/smite/puzzle
	name = "Puzzle"

/datum/smite/puzzle/effect(client/user, mob/living/target)
	. = ..()
	if(!puzzle_imprison(target))
		to_chat(user, "<span class='warning'>Imprisonment failed!</span>", confidential = TRUE)
