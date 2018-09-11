//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "god delusion"
	gain_text = "<span class='notice'>You feel a higher power inside your mind...</span>"
	lose_text = "<span class='warning'>The divine presence leaves your head, no longer interested.</span>"

/datum/brain_trauma/special/godwoken/on_life()
	..()
	if(prob(4))
		if(prob(33) && (owner.IsStun() || owner.IsKnockdown() || owner.IsUnconscious()))
			speak("unstun", TRUE)
		else if(prob(60) && owner.health <= owner.crit_threshold)
			speak("heal", TRUE)
		else if(prob(30) && owner.a_intent == INTENT_HARM)
			speak("aggressive")
		else
			speak("neutral", prob(25))

/datum/brain_trauma/special/godwoken/proc/speak(type, include_owner = FALSE)
	var/message
	switch(type)
		if("unstun")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_unstun")
		if("heal")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_heal")
		if("neutral")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")
		if("aggressive")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_aggressive")
		else
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")

	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 5)
	voice_of_god(message, owner, list("colossus","yell"), 2.5, include_owner, FALSE)

/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "bluespace attunement"
	gain_text = "<span class='notice'>You feel the bluespace pulsing around you...</span>"
	lose_text = "<span class='warning'>The faint pulsing of bluespace fades into silence.</span>"
	var/next_portal = 0

/datum/brain_trauma/special/bluespace_prophet/on_life()
	if(world.time > next_portal)
		next_portal = world.time + 100
		var/list/turf/possible_turfs = list()
		for(var/turf/T in range(owner, 8))
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					possible_turfs += T

		if(!LAZYLEN(possible_turfs))
			return

		var/turf/first_turf = pick(possible_turfs)
		if(!first_turf)
			return

		possible_turfs -= (possible_turfs & range(first_turf, 3))

		var/turf/second_turf = pick(possible_turfs)
		if(!second_turf)
			return

		var/obj/effect/hallucination/simple/bluespace_stream/first = new(first_turf, owner)
		var/obj/effect/hallucination/simple/bluespace_stream/second = new(second_turf, owner)

		first.linked_to = second
		second.linked_to = first
		first.seer = owner
		second.seer = owner

/obj/effect/hallucination/simple/bluespace_stream
	name = "bluespace stream"
	desc = "You see a hidden pathway through bluespace..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	var/obj/effect/hallucination/simple/bluespace_stream/linked_to
	var/mob/living/carbon/seer

/obj/effect/hallucination/simple/bluespace_stream/Initialize()
	. = ..()
	QDEL_IN(src, 300)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/hallucination/simple/bluespace_stream/attack_hand(mob/user)
	if(user != seer || !linked_to)
		return
	var/slip_in_message = pick("slides sideways in an odd way, and disappears", "jumps into an unseen dimension",\
		"sticks one leg straight out, wiggles [user.p_their()] foot, and is suddenly gone", "stops, then blinks out of reality", \
		"is pulled into an invisible vortex, vanishing from sight")
	var/slip_out_message = pick("silently fades in", "leaps out of thin air","appears", "walks out of an invisible doorway",\
		"slides out of a fold in spacetime")
	to_chat(user, "<span class='notice'>You try to align with the bluespace stream...</span>")
	if(do_after(user, 20, target = src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(linked_to))
		user.forceMove(get_turf(linked_to))
		user.visible_message("<span class='warning'>[user] [slip_in_message].</span>", null, null, null, user)
		user.visible_message("<span class='warning'>[user] [slip_out_message].</span>", "<span class='notice'>...and find your way to the other side.</span>")

/datum/brain_trauma/special/psychotic_brawling
	name = "Violent Psychosis"
	desc = "Patient fights in unpredictable ways, ranging from helping his target to hitting them with brutal strength."
	scan_desc = "violent psychosis"
	gain_text = "<span class='warning'>You feel unhinged...</span>"
	lose_text = "<span class='notice'>You feel more balanced.</span>"
	var/datum/martial_art/psychotic_brawling/psychotic_brawling

/datum/brain_trauma/special/psychotic_brawling/on_gain()
	..()
	psychotic_brawling = new(null)
	if(!psychotic_brawling.teach(owner, TRUE))
		to_chat(owner, "<span class='notice'>But your martial knowledge keeps you grounded.</span>")
		qdel(src)

/datum/brain_trauma/special/psychotic_brawling/on_lose()
	..()
	psychotic_brawling.remove(owner)
	QDEL_NULL(psychotic_brawling)

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	name = "Chemical Violent Psychosis"
