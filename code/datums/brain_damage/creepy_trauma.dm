/datum/brain_trauma/special/creep
	name = "Erotomania"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "severe erotomaniac delusions"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = "<span class='warning'>You no longer feel so attached.</span>"
	can_gain = TRUE
	resilience = TRAUMA_RESILIENCE_SURGERY
	var/mob/living/obsession
	var/datum/objective/spendtime/attachedcreepobj
	var/datum/antagonist/creep/antagonist
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs

	var/total_time_creeping = 0 //just for roundend fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/creep/on_gain()

	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
	gain_text = "<span class='warning'>You feel a strange attachment to [obsession].</span>"
	owner.apply_status_effect(STATUS_EFFECT_INLOVE, obsession)
	owner.mind.add_antag_datum(/datum/antagonist/creep)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/creep)
	antagonist.trauma = src
	..()
	//antag stuff//
	antagonist.forge_objectives(obsession.mind)
	antagonist.greet()

/datum/brain_trauma/special/creep/on_life()
	if(!obsession || obsession.stat == DEAD)
		viewing = FALSE//important, makes sure you no longer stutter when happy if you murdered them while viewing
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our viewrange they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	if(obsession in view(7, owner))
		viewing = TRUE
	else
		viewing = FALSE
	if(viewing)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += 20
		time_spent_away = 0
		if(attachedcreepobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedcreepobj.timer -= 20 //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/creep/proc/out_of_view()
	time_spent_away += 20
	if(time_spent_away > 1800) //3 minutes
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreeping, obsession.name)
/datum/brain_trauma/special/creep/on_lose()
	..()
	owner.remove_status_effect(STATUS_EFFECT_INLOVE)
	owner.mind.remove_antag_datum(/datum/antagonist/creep)

/datum/brain_trauma/special/creep/on_say(message)
	if(!viewing)
		return message
	var/choked_up
	GET_COMPONENT_FROM(mood, /datum/component/mood, owner)
	if(mood)
		if(mood.sanity >= SANITY_GREAT)
			choked_up = social_interaction()
	if(choked_up)
		return ""
	return message

/datum/brain_trauma/special/creep/on_hug(mob/living/hugger, mob/living/hugged)
	if(hugged == obsession)
		obsession_hug_count++

/datum/brain_trauma/special/creep/proc/social_interaction()
	var/fail = FALSE //whether you can finish a sentence while doing it
	owner.stuttering = max(3, owner.stuttering)
	owner.blur_eyes(10)
	switch(rand(1,4))
		if(1)
			shake_camera(owner, 15, 1)
			owner.vomit()
			fail = TRUE
		if(2)
			owner.emote("cough")
			owner.dizziness += 10
			fail = TRUE
		if(3)
			to_chat(owner, "<span class='userdanger'>You feel your heart lurching in your chest...</span>")
			owner.Stun(20)
			shake_camera(owner, 15, 1)
		if(4)
			to_chat(owner, "<span class='warning'>You faint.</span>")
			owner.Unconscious(80)
			fail = TRUE
	return fail


/datum/brain_trauma/special/creep/proc/find_obsession()
	var/chosen_victim
	var/list/possible_targets = list()
	var/list/viable_minds = list()
	for(var/mob/Player in GLOB.player_list)//prevents crewmembers falling in love with nuke ops they never met
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client && Player != owner && !(Player.mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL] || Player.mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_ANTAG]))
			viable_minds += Player.mind
	for(var/datum/mind/possible_target in viable_minds)
		if(possible_target != owner && ishuman(possible_target.current))
			possible_targets += possible_target.current
	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim