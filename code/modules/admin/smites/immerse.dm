/// "Fully immerses" the player, making them manually breathe and blink
/datum/smite/immerse
	name = "Fully Immerse"

/datum/smite/immerse/effect(client/user, mob/living/target)
	. = ..()
	immerse_player(target)
