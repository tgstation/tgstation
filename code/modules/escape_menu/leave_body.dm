/datum/escape_menu/proc/show_leave_body_page()
	PRIVATE_PROC(TRUE)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/lobby_button/small(
			null,
			/* hud_owner = */ null,
			"Назад",
			/* tooltip_text = */ null,
			/* button_screen_loc = */ "TOP:-30,LEFT:30",
			CALLBACK(src, PROC_REF(open_home_page)),
			/* button_overlay = */ "back",
		)
	)

	var/static/dead_clown
	if (isnull(dead_clown))
		if (MC_RUNNING(SSatoms.init_stage)) // We're about to create a bunch of atoms for a human
			dead_clown = create_dead_clown()
		else
			stack_trace("The leave body menu was opened before the atoms SS. This shouldn't be possible, as the leave body menu should only be accessible when you have a body.")

	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button(
		null,
		/* hud_owner = */ null,
		"Откиснуть",
		"Покинуть тело драматичным образом",
		/* button_screen_loc = */ "CENTER:-55,CENTER:-1",
		CALLBACK(src, PROC_REF(leave_suicide)),
		/* button_overlay = */ dead_clown,
	))

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/lobby_button(
			null,
			/* hud_owner = */ null,
			"Призрак",
			"Тихо выйти из тела в призраки",
			/* button_screen_loc = */ "CENTER:55,CENTER:-1",
			CALLBACK(src, PROC_REF(leave_ghost)),
			/* button_overlay = */ "ghost",
		)
	)

/datum/escape_menu/proc/create_dead_clown()
	PRIVATE_PROC(TRUE)

	var/mob/living/carbon/human/consistent/human = new
	human.equipOutfit(/datum/outfit/job/clown)

	var/mutable_appearance/appearance = new(human.appearance)
	appearance.plane = ESCAPE_MENU_PLANE

	// SpacemanDMM bug prevents us from just chain applying these :(
	appearance.transform = appearance.transform.Scale(2.5, 2.5)
	appearance.transform = appearance.transform.Turn(90)
	appearance.transform = appearance.transform.Translate(34, 24)

	qdel(human)

	return appearance

/datum/escape_menu/proc/leave_ghost()
	PRIVATE_PROC(TRUE)

	// Not guaranteed to be living. Everything defines verb/ghost separately. Fuck you.
	var/mob/living/living_user = client?.mob
	living_user?.ghost()

/datum/escape_menu/proc/leave_suicide()
	PRIVATE_PROC(TRUE)

	// Not guaranteed to be human. Everything defines verb/suicide separately. Fuck you, still.
	var/mob/living/carbon/human/human_user = client?.mob
	human_user?.suicide()
