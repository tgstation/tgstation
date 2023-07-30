/obj/machinery/button/windowtint
	icon = 'modular_bandastation/aesthetics/windowtint/icons/polarizer.dmi'
	icon_state = "polarizer-0"
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/button/windowtint/attack_hand(mob/user)
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("polarizer-denied",src)
		playsound(src, pick('modular_bandastation/aesthetics/windowtint/sound/button.ogg', 'modular_bandastation/aesthetics/windowtint/sound/button_alternate.ogg', 'modular_bandastation/aesthetics/windowtint/sound/button_meloboom.ogg'), 20)
		return 1

	toggle_tint()
	icon_state= "polarizer-turning_on"
	addtimer(CALLBACK(src, PROC_REF(update_windowtint_icon)), 0.5 SECONDS)

	if(!active)
		icon_state= "polarizer-turning_off"
		addtimer(CALLBACK(src, PROC_REF(update_windowtint_icon)), 0.5 SECONDS)

/obj/machinery/button/windowtint/proc/update_windowtint_icon()
	icon_state = "polarizer-[active]"
