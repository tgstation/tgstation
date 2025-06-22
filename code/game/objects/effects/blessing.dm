/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/blessing/Initialize(mapload)
	. = ..()
	var/image/blessing_icon = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = ABOVE_NORMAL_TURF_LAYER, loc = src)
	blessing_icon.alpha = 64
	blessing_icon.appearance_flags = RESET_ALPHA
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessed_aware, "blessing", blessing_icon)

	RegisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORTING, PROC_REF(block_cult_teleport))

/obj/effect/blessing/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORTING)
	return ..()

///Called from intercept teleport signal, blocks cult teleporting from being able to teleport on us.
/obj/effect/blessing/proc/block_cult_teleport(datum/source, channel, turf/origin)
	SIGNAL_HANDLER

	if(channel == TELEPORT_CHANNEL_CULT)
		return TRUE
