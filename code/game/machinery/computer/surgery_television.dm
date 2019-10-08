#define SURGERY_EXP_LEVEL_1 3
#define SURGERY_EXP_LEVEL_2 7
#define SURGERY_EXP_LEVEL_3 12

#define SURGERY_UNTRAINED 0
#define SURGERY_FAMILIAR 1
#define SURGERY_TRAINED 2
#define SURGERY_EXPERT 3

/obj/machinery/computer/surgery_television
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	name = "surgery tape monitor"
	desc = "An old Juked Micronics CRT screen hooked up to the research network that plays back recordings of dissections for educational value. Despite the attached tape player, it only displays videos of graphic dismemberment from the server, making it a poor choice for movie nights."
	circuit = /obj/item/circuitboard/computer/surgery_television
	var/stored_exp = 0
	var/operating_time = 200 // how long it takes to view the surgeries
	var/playing = FALSE
	var/list/cur_viewers = list()
	var/sound_vol = 60
	var/list/play_sounds = list('sound/weapons/bladeslice.ogg', 'sound/effects/blobattack.ogg', 'sound/weapons/drill.ogg', 'sound/effects/splat.ogg', 'sound/weapons/sear.ogg')
	var/list/play_by_play_descs = list("What fascinating technique...", "Are you allowed to do that like that?", "Hahaha, ewwwwwwww...", "You won\'t see THAT in the textbooks...")
	var/list/skill_titles = list("unskilled in", "familiar with", "trained in", "an expert in")

/obj/machinery/computer/surgery_television/examine(mob/user)
	. = ..()
	var/level = get_level()

	if(level == SURGERY_UNTRAINED)
		. += "<span class='danger'>The screen reads \"NO MEDIA\".</span>"
	else
		. += "<span class='notice'>The screen indicates it has enough material to teach to level [level].</span>"


/obj/machinery/computer/surgery_television/proc/get_level()
	switch(stored_exp)
		if(-INFINITY to SURGERY_EXP_LEVEL_1 - 1)
			return SURGERY_UNTRAINED
		if(SURGERY_EXP_LEVEL_1 to SURGERY_EXP_LEVEL_2 - 1)
			return SURGERY_FAMILIAR
		if(SURGERY_EXP_LEVEL_2 to SURGERY_EXP_LEVEL_3 - 1)
			return SURGERY_TRAINED
		if(SURGERY_EXP_LEVEL_3 to INFINITY)
			return SURGERY_EXPERT

/obj/machinery/computer/surgery_television/interact(mob/user)
	if(playing)
		finish(FALSE)
		return

	var/choice = alert(user, "What would you like to do?", "Choose action", "Update tapes", "Play tapes", "Cancel")

	switch(choice)
		if("Update tapes")
			var/old_level = get_level()
			stored_exp = SSresearch.surgery_exp
			var/level = get_level()
			if(!level > old_level)
				to_chat(user, "<span class='danger'>\The [src] doesn\'t have enough new material to be worth updating.</span>")
			else
				visible_message("<span class='notice'>You update the tape archive on \the [src]. It is now capable of teaching to level [level].</span>", \
					"<span class='notice'>[user] updates the tape archive on \the [src].</span>", \
					"<span class='hear'>You hear the sound of a click and the rapid rewinding of tapes.</span>")
		if("Play tapes")
			play(user)

/obj/machinery/computer/surgery_television/proc/isViewing(mob/user)
	if(playing)
		if(cur_viewers)
			if(user in cur_viewers)
				return TRUE
	return FALSE


/obj/machinery/computer/surgery_television/proc/play(mob/user)
	if(playing)
		to_chat(user, "<span class='danger'>\The [src] is already playing!</span>")
		return

	if(get_level() == SURGERY_UNTRAINED)
		to_chat(user, "<span class='danger'>\The [src] doesn\'t have enough material to learn from.</span>")
		return

	playing = TRUE

	visible_message("<span class='notice'>You hit 'play' on \the [src].</span>", \
		"<span class='notice'>[user] presses 'play' on \the [src].</span>", \
		"<span class='hear'>You hear the sound of a tape whirring.</span>")

	START_PROCESSING(SSmachines, src)


	var/in_view = get_hearers_in_view(3, get_turf(src))
	for(var/mob/living/L in in_view)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			//if(C.mind)
			testing(C.name)
			cur_viewers += C
			//var/datum/progressbar/progress = new(C, operating_time / 10, src)
			//while (do_after(C, 10, FALSE, src, FALSE, CALLBACK(src, isViewing(C)))
			to_chat(C, "<span class='notice'>Your attention is turned towards the grotesque dissections on \the [src].</span>")


	addtimer(CALLBACK(src, .proc/finish, TRUE), operating_time)


/obj/machinery/computer/surgery_television/proc/finish(var/success, mob/user)
	if(success)
		visible_message("<span class='notice'>\The [src] clicks once, then goes black as the tape finishes.</span>", \
		"<span class='hear'>You hear a click.</span>")
		for(var/mob/living/carbon/C in cur_viewers)
			testing(C.name)
			if(C.mind)
				if(C.mind.surgery_skill < level)
					to_chat(C, "<span class='notice'>You have gained proficiency in surgery! You are now [skill_titles[level + 1]] surgery!</span>")
					C.mind.surgery_skill = level
				else
					to_chat(C, "<span class='danger'>You don\'t feel like you learned anything from those tapes.</span>")
	else
		if(user)
			visible_message("<span class='notice'>You hit 'stop' on \the [src].</span>", \
				"<span class='notice'>[user] halts the playback on \the [src].</span>", \
				"<span class='hear'>You hear a click.</span>")
		else
			visible_message("<span class='notice'>\The [src] clicks, then goes black.</span>", \
				"<span class='hear'>You hear a click.</span>")

	cur_viewers = list()
	playing = FALSE

/obj/machinery/computer/surgery_television/process()
	if(playing)
		var/in_view = get_hearers_in_view(3, get_turf(src))

		for(var/mob/living/carbon/C in cur_viewers)
			if(!(C in in_view))
				cur_viewers -= C
				to_chat(C, "<span class='danger'>You turn your attention away from \the [src].</span>")
				continue

			if(prob(15))
				to_chat(C, "<span class='notice'><i>[pick(play_by_play_descs)]</i></span>")

		if(prob(33))
			playsound(src, pick(play_sounds), sound_vol)


//obj/machinery/computer/surgery_television/proc/update()

#undef SURGERY_EXP_LEVEL_1
#undef SURGERY_EXP_LEVEL_2
#undef SURGERY_EXP_LEVEL_3

#undef SURGERY_UNTRAINED
#undef SURGERY_FAMILIAR
#undef SURGERY_TRAINED
#undef SURGERY_EXPERT