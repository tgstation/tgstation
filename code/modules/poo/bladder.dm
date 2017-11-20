/mob/living/carbon
	var/bladder_level = 100

/mob/living/carbon/proc/set_bladder(amount)
	bladder_level = Clamp(bladder_level, 0, 100)

/mob/living/carbon/proc/adjust_bladder(amount)
	set_bladder(bladder_level+amount)

/mob/living/carbon/Life()
	. = ..()
	if(prob(1))
		adjust_bladder(rand(0.5, 2))
	if(prob(5) && bladder_level < 60)
		to_chat(src, "<span class='notice'>You kinda gotta pee.</span>")