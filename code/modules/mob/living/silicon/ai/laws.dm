
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	if(usr.stat == 2) //won't work if dead
		return
	src.show_laws()

/mob/living/silicon/ai/show_laws(everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
	who << "<b>Obey these laws:</b>"

	src.laws_sanity_check()
	src.laws.show_laws(who)
