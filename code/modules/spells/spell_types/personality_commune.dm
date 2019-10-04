/obj/effect/proc_holder/spell/targeted/personality_commune
	name = "Personality Commune"
	desc = "Sends thoughts to your alternate consciousness."
	charge_max = 0
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "telepathy"
	action_background_icon_state = "bg_spell"
	var/datum/brain_trauma/severe/split_personality/trauma
	var/ishost = FALSE
	var/flufftext = "You hear an echoing voice in the back of your head..."
	var/boldnotice = "boldnotice"
	var/notice = "notice"

/obj/effect/proc_holder/spell/targeted/personality_commune/New(datum/brain_trauma/severe/split_personality/T, host)
	. = ..()
	trauma = T
	ishost = host

// Pillaged and adapted from telepathy code
/obj/effect/proc_holder/spell/targeted/personality_commune/cast(list/targets, mob/user)
	if(!istype(trauma))
		to_chat(user, "<span class='warning'>Something is wrong; Either due a bug or admemes, you are trying to cast this spell without a split personality!</span>")
		return
	var/msg = stripped_input(usr, "What would you like to tell your other self?", null , "")
	if(!msg)
		charge_counter = charge_max
		return
	to_chat(user, "<span class='[boldnotice]'>You concentrate and send thoughts to your other self:</span> <span class='[notice]'>[msg]</span>")
	if(ishost)
		if(trauma.current_controller == 1) // Stranger in control, send to owner backseat
			to_chat(trauma.owner_backseat, "<span class='[boldnotice]'>[flufftext]</span> <span class='[notice]'>[msg]</span>")
			log_directed_talk(user, trauma.owner_backseat, msg, LOG_SAY ,"[name]")
		else // Owner in control, send to stranger backseat
			to_chat(trauma.stranger_backseat, "<span class='[boldnotice]'>[flufftext]</span> <span class='[notice]'>[msg]</span>")
			log_directed_talk(user, trauma.stranger_backseat, msg, LOG_SAY ,"[name]")
	else //  We're in the backseat, send to body
		to_chat(trauma.owner, "<span class='[boldnotice]'>[flufftext]</span> <span class='[notice]'>[msg]</span>")
		log_directed_talk(user, trauma.owner, msg, LOG_SAY ,"[name]")
	for(var/ded in GLOB.dead_mob_list)
		if(!isobserver(ded))
			continue
		var/follow = FOLLOW_LINK(ded, user)
		to_chat(ded, "[follow] <span class='[boldnotice]'>[user] [name]:</span> <span class='[notice]'>\"[msg]\" to</span><span class='name'>[trauma]</span>")
