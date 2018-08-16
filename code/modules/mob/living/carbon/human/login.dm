/mob/living/carbon/human/Login()
	..()
	if(src.martial_art == default_martial_art && mind.stored_martial_art) //If the mind has a martial art stored and the body has the default one.
		src.mind.stored_martial_art.teach(src) //Running teach so that it deals with help verbs.
	else if(src.martial_art != default_martial_art && src.martial_art != mind.stored_martial_art) //If the body has a martial art which is not the default one and is not stored in the mind.
		if(src.martial_art_owner != mind)
			src.martial_art.remove(src)
		else
			src.mind.stored_martial_art = src.martial_art
