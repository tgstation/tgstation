// Citadel-specific Neutral Traits

/datum/quirk/libido
	name = "Nymphomania"
	desc = "You're always feeling a bit in heat. Also, you get aroused faster than usual."
	value = 0
	gain_text = "<span class='notice'>You are feeling extra wild.</span>"
	lose_text = "<span class='notice'>You don't feel that burning sensation anymore.</span>"

/datum/quirk/libido/add()
	var/mob/living/M = quirk_holder
	M.min_arousal = 16
	M.arousal_rate = 3

/datum/quirk/libido/remove()
	var/mob/living/M = quirk_holder
	M.min_arousal = initial(M.min_arousal)
	M.arousal_rate = initial(M.arousal_rate)

/datum/quirk/libido/on_process()
	var/mob/living/M = quirk_holder
	if(M.canbearoused == FALSE)
		to_chat(quirk_holder, "<span class='notice'>Having high libido is useless when you can't feel arousal at all!</span>")
		qdel(src)
