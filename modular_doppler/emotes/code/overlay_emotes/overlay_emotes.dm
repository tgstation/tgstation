#define MOB_OVERLAY_FILE 'modular_doppler/emotes/icons/mob_overlay.dmi'

/datum/emote/living/sweatdrop
	key = "sweatdrop"
	key_third_person = "sweatdrops"
	cant_muffle = TRUE

/datum/emote/living/sweatdrop/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/mutable_appearance/overlay = mutable_appearance(MOB_OVERLAY_FILE, "sweatdrop", ABOVE_MOB_LAYER)
	overlay.pixel_x = 10
	overlay.pixel_y = 10
	user.flick_overlay_static(overlay, 50)
	playsound(get_turf(user), 'modular_doppler/emotes/sound/sweatdrop.ogg', 25, TRUE)

/datum/emote/living/exclaim
	key = "exclaim"
	key_third_person = "exclaims"
	cant_muffle = TRUE

/datum/emote/living/exclaim/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/mutable_appearance/overlay = mutable_appearance(MOB_OVERLAY_FILE, "exclamation", ABOVE_MOB_LAYER)
	overlay.pixel_x = 10
	overlay.pixel_y = 28
	user.flick_overlay_static(overlay, 50)
	playsound(get_turf(user), 'sound/machines/chime.ogg', 25, TRUE)

/datum/emote/living/question
	key = "question"
	key_third_person = "questions"
	cant_muffle = TRUE

/datum/emote/living/question/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/mutable_appearance/overlay = mutable_appearance(MOB_OVERLAY_FILE, "question", ABOVE_MOB_LAYER)
	overlay.pixel_x = 10
	overlay.pixel_y = 28
	user.flick_overlay_static(overlay, 50)
	playsound(get_turf(user), 'modular_doppler/emotes/sound/question.ogg', 25, TRUE)

/datum/emote/living/realize
	key = "realize"
	key_third_person = "realizes"
	cant_muffle = TRUE

/datum/emote/living/realize/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/mutable_appearance/overlay = mutable_appearance(MOB_OVERLAY_FILE, "realize", ABOVE_MOB_LAYER)
	overlay.pixel_y = 15
	user.flick_overlay_static(overlay, 50)
	playsound(get_turf(user), 'modular_doppler/emotes/sound/realize.ogg', 25, TRUE)

/datum/emote/living/annoyed
	key = "annoyed"
	key_third_person = "is annoyed"
	cant_muffle = TRUE

/datum/emote/living/annoyed/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/mutable_appearance/overlay = mutable_appearance(MOB_OVERLAY_FILE, "annoyed", ABOVE_MOB_LAYER)
	overlay.pixel_x = 10
	overlay.pixel_y = 10
	user.flick_overlay_static(overlay, 50)
	playsound(get_turf(user), 'modular_doppler/emotes/sound/annoyed.ogg', 25, TRUE)

#undef MOB_OVERLAY_FILE
