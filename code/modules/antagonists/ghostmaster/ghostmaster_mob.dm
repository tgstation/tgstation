/mob/camera/ghostmaster
	name = "Ghostmaster"
	real_name = "Ghostmaster"
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	pass_flags = PASSBLOB
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	call_life = TRUE
	hud_type = /datum/hud/ghostmaster
	faction = list("spook")
	var/spook_points = 5 //Placing traps, casting spells 
	var/death_points = 1 //Summoning haunts
	var/list/haunts = list()
	var/free_point_rate = 300
	var/free_point_cap = 10
	var/next_free_point
	var/list/cost_table = list()
	var/datum/ghostmaster_power/active_power

	var/datum/exorcism/exorcism

/mob/camera/ghostmaster/Initialize(mapload)
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	generate_cost_table()
	RegisterSignal(src,COMSIG_EXORCISM_SUCCESS, .proc/bye)
	RegisterSignal(SSdcs,COMSIG_GLOB_MOB_DEATH, .proc/check_death)
	next_free_point = world.time + free_point_rate
	generate_corpse()
	.= ..()

/mob/camera/ghostmaster/proc/check_death(mob/M,gibbed)
	if(M.mind && !istype(M,/mob/living/simple_animal/hostile/haunt))
		death_points++

/mob/camera/ghostmaster/proc/bye()
	to_chat(src,"<span class='userdanger'>You can feel your attachement to the world disappear. Someone has purified your remains.</span>")
	qdel(src)

/mob/camera/ghostmaster/proc/generate_corpse()
	var/obj/effect/decal/remains/human/haunted/H = new(get_random_station_turf()) //That proc is nightmarish but eh
	exorcism = new
	exorcism.generate()
	exorcism.bound_spook = src
	exorcism.RegisterCorpse(H)

/mob/camera/ghostmaster/proc/generate_cost_table()
	var/list/ct = list()
	for(var/T in subtypesof(/datum/ghostmaster_power))
		ct += new T
	cost_table = ct

/mob/camera/ghostmaster/Life()
	. = ..()
	if(world.time > next_free_point)
		spook_points = max(min(spook_points+1,free_point_cap),spook_points)
		next_free_point = world.time + free_point_rate

/mob/camera/ghostmaster/ClickOn(var/atom/A, var/params) //Expand blob
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	if(active_power)
		active_power.Execute(src,A)

/mob/camera/ghostmaster/Destroy()
	//Kill all haunts?
	return ..()

/mob/camera/ghostmaster/Login()
	..()
	to_chat(src, "<span class='notice'>You are the ghostmaster!</span>")

/mob/camera/ghostmaster/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	haunt_talk(src,message,TRUE)

/proc/haunt_talk(mob/M,message,big = FALSE)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	M.log_talk(message, LOG_SAY)

	var/message_a = M.say_quote(message, M.get_spans())
	var/rendered = "<span class='[big ? "big" : ""] haunt'><b>\[Ghost Talk\] [M.name]</b> [message_a]</span>"

	for(var/mob/R in GLOB.mob_list)
		if(istype(R,/mob/living/simple_animal/hostile/haunt) || istype(R, /mob/camera/ghostmaster))
			to_chat(R, rendered)
		if(isobserver(R))
			var/link = FOLLOW_LINK(R, M)
			to_chat(R, "[link] [rendered]")

/mob/camera/ghostmaster/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Scare Points: [spook_points]")
		stat(null, "Death Points: [death_points]")
		if(active_power)
			stat(null,"Active Power : [active_power.name]")


/mob/camera/ghostmaster/Move(NewLoc, Dir = 0)
	forceMove(NewLoc)
	return TRUE

/mob/camera/ghostmaster/mind_initialize()
	. = ..()
	var/datum/antagonist/ghostmaster/G = mind.has_antag_datum(/datum/antagonist/ghostmaster)
	if(!G)
		mind.add_antag_datum(/datum/antagonist/ghostmaster)


/datum/ghostmaster_power
	var/name = "Generic Power"
	var/spook_cost = 0
	var/death_cost = 0
	var/spam_safety = FALSE

/datum/ghostmaster_power/proc/valid_target(atom/A)
	return TRUE

/datum/ghostmaster_power/proc/effect(atom/A,mob/camera/ghostmaster/G)
	return

/datum/ghostmaster_power/proc/Execute(mob/camera/ghostmaster/G, atom/A)
	if(!valid_target(A))
		return
	if(G.spook_points < spook_cost)
		to_chat(G,"<span class='warning'>Not enough spook points!</span>")
		return
	if(G.death_points < death_cost)
		to_chat(G,"<span class='warning'>Not enough death points!</span>")
	var/result = effect(A,G)
	if(!result)
		return
	G.spook_points -= spook_cost
	G.death_points -= death_cost
	if(spam_safety)
		G.active_power = null