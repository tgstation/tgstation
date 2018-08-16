/obj/item/boombox
	name = "boombox"
	desc = "A dusty, gray, bulky, battery-powered, auto-looping stereo cassette player. An ancient relic from prehistoric times on that one planet with humans and stuff. Yeah, that one."
	icon = 'modular_citadel/icons/obj/boombox.dmi'
	icon_state = "raiqbawks_off"//PLACEHOLDER UNTIL SOMEONE SPRITES PLAIN NON-FANCY BOOMBOXES
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	var/baseiconstate = "raiqbawks"
	var/boomingandboxing = FALSE
	var/list/availabletrackids

/obj/item/boombox/attack_self(mob/user)
	. = ..()
	if(boomingandboxing)
		SSjukeboxes.removejukebox(SSjukeboxes.findjukeboxindex(src))
		boomingandboxing = FALSE
		to_chat(user, "<span class='notice'>You flip a switch on [src], and the music immediately stops.")
		update_icon()
		return
	if(!availabletrackids || !availabletrackids.len)
		to_chat(user, "<span class='notice'>[src] flashes as you prod it senselessly. It doesn't have any songs stored on it.</span>")
		return
	if(!boomingandboxing)
		var/list/tracklist = list()
		for(var/datum/track/S in SSjukeboxes.songs)
			if(istype(S) && S.song_associated_id in availabletrackids)
				tracklist[S.song_name] = S
		var/selected = input(user, "Play song", "Track:") as null|anything in tracklist
		if(QDELETED(src) || !selected || !istype(tracklist[selected], /datum/track))
			return
		var/jukeboxslottotake = SSjukeboxes.addjukebox(src, tracklist[selected])
		if(jukeboxslottotake)
			boomingandboxing = TRUE
			update_icon()

/obj/item/boombox/Destroy(mob/user)
	SSjukeboxes.removejukebox(SSjukeboxes.findjukeboxindex(src))
	. = ..()

/obj/item/boombox/update_icon()
	icon_state = "[baseiconstate]_[boomingandboxing ? "on" : "off"]"
	return

/obj/item/boombox/raiq
	name = "Miami Boomer"
	desc = "A shiny, fashionable boombox filled to the brim with neon lights, synthesizers, gang violence, and broken R keys. A worn-out sticker on the back states \"Includes three kickin' beats!\""
	icon_state = "raiqbawks_off"
	baseiconstate = "raiqbawks"
	availabletrackids = list("hotline.ogg","chiptune.ogg","genesis.ogg")

/obj/item/boombox/raiq/update_icon()
	. = ..()
	if(boomingandboxing)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
		set_light(0)

/obj/item/boombox/raiq/process()
	set_light(5,0.95,pick("#d87aff","#7a7aff","#89ecff","#b88eff","#ff59ad"))
	return
