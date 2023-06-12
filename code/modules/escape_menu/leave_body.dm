/datum/escape_menu/proc/show_leave_body_page()
	PRIVATE_PROC(TRUE)

	var/static/dead_clown
	if (isnull(dead_clown))
		if (MC_RUNNING(SSatoms.init_stage)) // We're about to create a bunch of atoms for a human
			dead_clown = create_dead_clown()
		else
			stack_trace("The leave body menu was opened before the atoms SS. This shouldn't be possible, as the leave body menu should only be accessible when you have a body.")

	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/leave_body_button(
		src,
		"Suicide",
		"Perform a dramatic suicide in game",
		/* pixel_offset = */ -105,
		CALLBACK(src, PROC_REF(leave_suicide)),
		/* button_overlay = */ dead_clown,
	))

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/leave_body_button(
			src,
			"Ghost",
			"Exit quietly, leaving your body",
			/* pixel_offset = */ 0,
			CALLBACK(src, PROC_REF(leave_ghost)),
			/* button_overlay = */ "ghost",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/leave_body_button(
			src,
			"Back",
			/* tooltip_text = */ null,
			/* pixel_offset = */ 105,
			CALLBACK(src, PROC_REF(open_home_page)),
			/* button_overlay = */ "back",
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

/atom/movable/screen/escape_menu/leave_body_button
	icon = 'icons/hud/escape_menu_leave_body.dmi'
	icon_state = "template"
	maptext_width = 96
	maptext_y = -32

	VAR_PRIVATE
		datum/callback/on_click_callback
		hovered = FALSE
		tooltip_text

/atom/movable/screen/escape_menu/leave_body_button/Initialize(
	mapload,
	button_text,
	tooltip_text,
	pixel_offset,
	on_click_callback,
	button_overlay,
)
	. = ..()

	src.on_click_callback = on_click_callback
	src.tooltip_text = tooltip_text

	add_overlay(button_overlay)

	maptext = MAPTEXT_VCR_OSD_MONO("<b style='font-size: 16px; text-align: center'>[button_text]</b>")
	screen_loc = "CENTER:[pixel_offset],CENTER-1"

/atom/movable/screen/escape_menu/leave_body_button/Destroy()
	QDEL_NULL(on_click_callback)

	return ..()

/atom/movable/screen/escape_menu/leave_body_button/Click(location, control, params)
	on_click_callback?.InvokeAsync()

/atom/movable/screen/escape_menu/leave_body_button/MouseEntered(location, control, params)
	if (hovered)
		return

	hovered = TRUE

	// The UX on this is pretty shit, but it's okay enough for now.
	// Regularly goes way too far from your cursor. Not designed for large icons.
	openToolTip(usr, src, params, content = tooltip_text)

/atom/movable/screen/escape_menu/leave_body_button/MouseExited(location, control, params)
	if (!hovered)
		return

	hovered = FALSE
	closeToolTip(usr)
