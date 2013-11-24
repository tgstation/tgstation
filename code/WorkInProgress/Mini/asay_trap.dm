/obj/effect/admin_log_trap
	name = "Herprpr"
	desc = "Stepping on this is good."
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1
	invisibility = 101

/obj/effect/admin_log_trap/HasEntered(AM as mob|obj)
	if(istype(AM,/mob))
		message_admins("[AM] ([AM:ckey]) stepped on an alerted tile in [get_area(src)]. <a href=\"byond://?src=%admin_ref%;teleto=\ref[src.loc]\">Jump</a>", admin_ref = 1)
