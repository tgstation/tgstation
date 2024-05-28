/obj/item/book/granter/action/origami
	granted_action = /datum/action/innate/origami
	name = "The Art of Origami"
	desc = "A meticulously in-depth manual explaining the art of paper folding."
	icon_state = "origamibook"
	action_name = "origami"
	remarks = list(
		"Dead-stick stability...",
		"Symmetry seems to play a rather large factor...",
		"Accounting for crosswinds... really?",
		"Drag coefficients of various paper types...",
		"Thrust to weight ratios?",
		"Positive dihedral angle?",
		"Center of gravity forward of the center of lift...",
	)

/datum/action/innate/origami
	name = "Origami Folding"
	desc = "Toggles your ability to fold and catch robust paper airplanes."
	button_icon_state = "origami_off"
	check_flags = NONE

/datum/action/innate/origami/Activate()
	ADD_TRAIT(owner, TRAIT_PAPER_MASTER, ACTION_TRAIT)
	to_chat(owner, span_notice("You will now fold origami planes."))
	active = TRUE
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/innate/origami/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_PAPER_MASTER, ACTION_TRAIT)
	to_chat(owner, span_notice("You will no longer fold origami planes."))
	active = FALSE
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/innate/origami/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = "origami_[active ? "on":"off"]"
	return ..()
