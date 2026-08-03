/obj/item/boombox
	name = "Boombox"
	desc = "Never quit making all that racket."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "boombox"
	/// Is the boombox actively playing anything?
	var/active = FALSE
	/// Reference to the tapedeck that's inserted into the boombox.
	var/obj/tapedeck = null
	/// Soundloop that's managing our boombox.
	var/datum/looping_sound/boombox_audio = null

/obj/item/boombox/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(/obj/item/tape/music))
		var/obj/item/tape/music/tunes = tool
		forceMove(tunes, src)
		tapedeck = tunes
		balloon_alert(user, "tape inserted")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		return ITEM_INTERACT_SUCCESS
	if(istype(/obj/item/tape))
		balloon_alert(user, "can't play!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/boombox/attack_hand(mob/user, list/modifiers)
	. = ..()

