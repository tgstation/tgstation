/// An info button that, when clicked, puts some text in the user's chat
/obj/effect/abstract/info
	name = "info"
	icon = 'icons/effects/effects.dmi'
	icon_state = "info"

	/// What should the info button display when clicked?
	var/info_text

/obj/effect/abstract/info/Initialize(mapload, info_text)
	. = ..()

	if (!isnull(info_text))
		src.info_text = info_text

/obj/effect/abstract/info/Click()
	. = ..()
	to_chat(usr, info_text)

/obj/effect/abstract/info/MouseEntered()
	. = ..()
	icon_state = "info_hovered"

/obj/effect/abstract/info/MouseExited()
	. = ..()
	icon_state = initial(icon_state)
