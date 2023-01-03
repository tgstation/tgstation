/obj/item/heavy_ass_man
	name = "distraction dummy"
	desc = "An inflatable distraction dummy that repeats lines to anyone who can hear it."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "syndicate_sword"
	var/quote_url = "https://file.house/-98z.mp3"

/obj/item/heavy_ass_man/Initialize()
	..()
	addtimer(CALLBACK(src, PROC_REF(my_ass_is_heavy), TRUE, TRUE), 8 SECONDS, TIMER_LOOP)
	SShtml_audio.register_player(src, requires_LOS = TRUE)

/obj/item/heavy_ass_man/proc/my_ass_is_heavy()
	say("My ass is heavy. MY ASS IS HEAVY!")
	SShtml_audio.play_audio(src, quote_url)
