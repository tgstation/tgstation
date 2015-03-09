//copy pasta of the space piano, don't hurt me -Pete

/obj/item/device/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon = 'icons/obj/musician.dmi'
	icon_state = "violin"
	item_state = "violin"
	force = 10
	var/datum/song/handheld/song

/obj/item/device/violin/New()
	song = new("violin", src)
	song.instrumentExt = "ogg"

/obj/item/device/violin/Destroy()
	qdel(song)
	song = null
	..()

/obj/item/device/violin/attack_self(mob/user as mob)
	interact(user)

/obj/item/device/violin/interact(mob/user as mob)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	song.interact(user)
