/mob/living/simple_animal/examine(mob/user)
	. = ..()
	//Temporary flavor text addition:
	if(temporary_flavor_text)
		if(length_char(temporary_flavor_text) <= 40)
			. += "<span class='notice'>[temporary_flavor_text]</span>"
		else
			. += "<span class='notice'>[copytext_char(temporary_flavor_text, 1, 37)]... <a href='?src=[REF(src)];temporary_flavor=1'>More...</a></span>"
