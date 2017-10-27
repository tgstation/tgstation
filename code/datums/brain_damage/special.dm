//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "god delusion"
	gain_text = "<span class='notice'>You feel a higher power inside your mind...</span>"
	lose_text = "<span class='warning'>The divinity leaves your head, no longer interested.</span>"
	var/next_speech = 0

/datum/brain_trauma/special/godwoken/on_say(message)
	if(world.time > next_speech && prob(10))
		playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)
		var/cooldown = voice_of_god(message, owner, list("colossus","yell"), 2)
		cooldown *= 0.33
		next_speech = world.time + cooldown
		return ""
	else
		return message

/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "bluespace attunement"
	gain_text = "<span class='notice'>You feel the bluespace pulsing around you...</span>"
	lose_text = "<span class='warning'>The faint pulsing of bluespace fades into silence.</span>"

/datum/brain_trauma/special/bluespace_prophet/on_life()
	if(prob(4))
		var/list/turf/possible_turfs
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

		var/obj/effect/hallucination/simple/bluespace_stream/first = new(first_turf)
		var/obj/effect/hallucination/simple/bluespace_stream/second = new(second_turf)

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

/obj/effect/hallucination/simple/bluespace_stream/attack_hand(mob/user)
	if(user != seer || !linked_to)
		return
	var/slip_in_message = pick("slides sideways in an odd way, and disappears", "jumps into an unseen dimension",\
		"sticks one leg straight out, wiggles [user.p_their()] foot, and is suddenly gone", "stops, then blinks out of reality", \
		"is pulled into an invisible vortex, vanishing from sight")
	var/slip_out_message = pick("silently fades in", "leaps out of thin air","appears", "walks out of an invisible doorway",\
		"slides out of a fold in spacetime")
	user.visible_message("<span class='warning'>[user] [slip_in_message].</span>", "<span class='notice'>You slip into the bluespace stream...</span>")
	user.forceMove(get_turf(linked_to))
	user.visible_message("<span class='warning'>[user] [slip_out_message].</span>", "<span class='notice'>...and find your way to the other side.</span>")