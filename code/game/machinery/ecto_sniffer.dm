/obj/machinery/ecto_sniffer
	name = "ectoscopic sniffer"
	desc = "A highly sensitive parascientific instrument calibrated to detect the slightest whiff of ectoplasm."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_sniffer"
	density = FALSE
	anchored = FALSE
	wires = /datum/wires/ecto_sniffer
	///determines if the device if the power switch is turned on or off. Useful if the ghosts are too annoying.
	var/on = TRUE
	///If this var set to false the ghosts will not be able interact with the machine, say if the machine is silently disabled by cutting the internal wire.
	var/sensor_enabled = TRUE
	///List of ghost who have recently activated the device, ghosts on this list are prohibited from activating the device untill their residue decays.
	var/list/ghosts_sampled = list()

/obj/machinery/ecto_sniffer/attack_ghost(mob/user)
	. = ..()
	if(user in ghosts_sampled) //anti-spam protection, also helps limit the bitrate.
		return ..()

	if(!is_operational || !on || !sensor_enabled)
		return ..()

	activate(user)

/obj/machinery/ecto_sniffer/proc/activate(mob/activator)
	flick("ecto_sniffer_flick", src)
	playsound(loc, 'sound/machines/ping.ogg', 20)
	use_power(10)
	if(activator)
		ghosts_sampled += activator
		addtimer(CALLBACK(src, .proc/clear_residue, activator), 15 SECONDS)

/obj/machinery/ecto_sniffer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	add_fingerprint(user)
	to_chat(user, "<span class ='notice'>You turn the sniffer [on ? "off" : "on"].")
	on = !on
	update_appearance()

/obj/machinery/ecto_sniffer/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][(is_operational && on) ? null : "-p"]"

/obj/machinery/ecto_sniffer/update_overlays()
	. = ..()
	if(is_operational && on)
		. += emissive_appearance(icon, "[initial(icon_state)]-light-mask")

/obj/machinery/ecto_sniffer/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if (W.tool_behaviour == TOOL_WRENCH)
		W.play_tool_sound(src, 15)
		to_chat(user, "<span class ='notice'>You [anchored ? "unanchor" : "anchor"] [src].")
		set_anchored(!anchored)

///Removes the ghost from the ghosts_sampled list and lets them know they are free to activate the sniffer again.
/obj/machinery/ecto_sniffer/proc/clear_residue(mob/user)
	ghosts_sampled -= user
	to_chat(user, "<span class='nicegreen'>The coating of ectoplasmic residue you left on [src]'s sensors has decayed.</span>")
