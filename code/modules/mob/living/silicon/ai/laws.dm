
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	if(usr.stat == DEAD)
		return //won't work if dead
	src.show_laws()

/mob/living/silicon/ai/show_laws(everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
	to_chat(who, "<b>Obey these laws:</b>")

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/post_lawchange(announce = TRUE)
	. = ..()

	if(!.)
		return

	addtimer(CALLBACK(src, .proc/lawsync), 0)

/mob/living/silicon/ai/lawsync()
	for(var/r in connected_robots)
		var/mob/living/silicon/robot/connected_robot = r
		connected_robot.lawsync()
