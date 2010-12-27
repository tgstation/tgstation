//I don't even know -- Urist

//I do. -- NEOFite

/mob/living/silicon/aihologram/verb/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/aihologram/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	src.laws_sanity_check()
	src.ailaws.show_laws(who)

/mob/living/silicon/aihologram/proc/laws_sanity_check()
	if (!src.ailaws)
		src << "You are somehow an AI hologram without referencing a set of AI laws, so I got you a laws datum to prevent runtime errors."
		src.ailaws = new /datum/ai_laws/asimov