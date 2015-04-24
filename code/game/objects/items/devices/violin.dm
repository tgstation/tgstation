//copy pasta of the space piano, don't hurt me -Pete

/obj/item/device/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon = 'icons/obj/musician.dmi'
	icon_state = "violin"
	item_state = "violin"
	force = 10
	var/datum/song/handheld/song
	hitsound = "swing_hit"

/obj/item/device/violin/New()
	song = new("violin", src)
	song.instrumentExt = "ogg"

/obj/item/device/violin/Destroy()
	qdel(song)
	song = null
	..()

/obj/item/device/violin/initialize()
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/item/device/violin/attack_self(mob/user as mob)
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 1
	interact(user)

/obj/item/device/violin/interact(mob/user as mob)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	song.interact(user)
