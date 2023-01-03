/obj/item/fm_radio
	name = "portable FM radio"
	desc = "Someone's portable FM radio they brought in with them this shift. Unfortunately, the frequency dial is jammed..."
	icon = 'icons/obj/radio.dmi'
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon_state = "radio"
	inhand_icon_state = "radio"
	worn_icon_state = "radio"
	var/music_to_play_url = "https://file.house/MI58.mp3"
	var/active = FALSE

/obj/item/fm_radio/Initialize()
	..()
	RegisterSignal(SSdcs, COMSIG_GLOB_ROUND_STARTED, PROC_REF(start_music))

/obj/item/fm_radio/proc/start_music()
	SIGNAL_HANDLER
	active = TRUE
	SShtml_audio.register_player(src)
	SShtml_audio.play_audio(src, music_to_play_url)
	SShtml_audio.start_looping_audio(src)

/obj/item/fm_radio/attack_self(mob/user, modifiers)
	. = ..()
	if(active)
		user.balloon_alert(user, "turned off")
		SShtml_audio.deregister_player(src)
		active = FALSE
	else
		user.balloon_alert(user, "turned on")
		SShtml_audio.register_player(src)
		SShtml_audio.play_audio(src, music_to_play_url)
		SShtml_audio.start_looping_audio(src)
		active = TRUE
