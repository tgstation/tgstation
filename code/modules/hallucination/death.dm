/datum/hallucination/death

/datum/hallucination/death/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	target.set_screwyhud(SCREWYHUD_DEAD)
	target.Paralyze(300)
	target.silent += 10
	to_chat(target, span_deadsay("<b>[target.real_name]</b> has died at <b>[get_area_name(target)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/fakemob
		var/list/dead_people = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			dead_people += G
		if(LAZYLEN(dead_people))
			fakemob = pick(dead_people)
		else
			fakemob = target //ever been so lonely you had to haunt yourself?
		if(fakemob)
			delay = rand(20, 50)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, target, "<span class='deadsay'><b>DEAD: [fakemob.name]</b> says, \"[pick("rip","why did i just drop dead?","hey [target.first_name()]","git gud","you too?","is the AI rogue?",\
				"i[prob(50)?" fucking":""] hate [pick("blood cult", "clock cult", "revenants", "this round","this","myself","admins","you")]")]\"</span>"), delay)

	addtimer(CALLBACK(src, .proc/cleanup), delay + rand(70, 90))

/datum/hallucination/death/proc/cleanup()
	if (target)
		target.set_screwyhud(SCREWYHUD_NONE)
		target.SetParalyzed(0)
		target.silent = FALSE
	qdel(src)
