/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = "blob"

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100

/mob/camera/blob/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	..()

/mob/camera/blob/Login()
	..()
	sync_mind()

	src << "<span class='notice'>You are the overmind!</span>"
	src << "You are the overmind and can control the blob by placing new blob pieces such as..."
	src << "<b>Normal Blob</b> will expand your reach and allow you to upgrade into special blobs that perform certain functions."
	src << "<b>Shield Blob</b> is a strong and expensive blob which can take more damage. It is fireproof and can block air, use this to protect yourself from station fires."
	src << "<b>Resource Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income. It will benefit from being near your core or multiple nodes, by having an increased resource rate; put it alone and it won't create resources at all."
	src << "<b>Node Blob</b> is a blob which will grow, like the core. Unlike the core it won't give you a small income but it can power resource and factory blobs to increase their rate."
	src << "<b>Factory Blob</b> is a blob which will spawn blob spores which will attack nearby food. Putting this nearby nodes and your core will increase the spawn rate; put it alone and it will not spawn any spores."


mob/camera/blob/Life()
	hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#82ed00'>[src.blob_points]</font></div>"
	hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#e36600'>[blob_core.health]</font></div>"
	return

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
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
	return

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0
