/mob/camera/blob
	name = "blob overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	pass_flags = PASSBLOB
	var/creating_blob = 0
	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	faction = "blob"

	var/blob_points = 0
	var/max_blob_points = 100

/mob/camera/blob/say(var/message)
	return//No talking for you

/mob/camera/blob/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()

	statpanel("Status")
	..()
	if (client.statpanel == "Status")
		stat(null, "Blob Points Stored: [blob_points]/[max_blob_points]")
	return

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0
