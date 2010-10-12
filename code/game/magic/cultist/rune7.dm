/obj/rune/proc/seer()
	if(usr.loc==src.loc)
		usr.say("Rash'tla sektath mal'zua. Zasan therium vivira. Itonis al'ra matum!")
		usr << "\red The world beyond opens to your eyes."
		usr.see_invisible = 15
		return
	return fizzle()