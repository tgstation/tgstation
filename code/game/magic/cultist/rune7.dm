/obj/rune/proc/seer()
	if(usr.loc==src.loc)
		usr.say("Rash'tla sektath mal'zua. Zasan therium vivira. Itonis al'ra matum!")
		if(usr.see_invisible!=0 && usr.see_invisible!=15)
			usr << "\red The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision."
		if(usr.see_invisible==15)
			return fizzle()
		else
			usr << "\red The world beyond opens to your eyes."
		usr.see_invisible = 15
		return
	return fizzle()