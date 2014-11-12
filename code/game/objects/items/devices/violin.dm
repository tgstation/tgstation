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
//I have copy pasted the violin which is copy pasta of the space piano. Derp... -BartNixon

/obj/item/device/guitar
	name = "guitar"
	desc = "It's made of wood and has steel strings.<br>The leather belt is folded behind it and the letters J.C. are engraved on the headstock."
	icon = 'icons/obj/musician.dmi'
	icon_state = "guitar"
	item_state = "guitar"
	hitsound = 'sound/guitar/1hit.ogg'
	force = 10
	attack_verb = list("played metal", "made concert", "crashed", "smashed")
var/datum/song/handheld/song

/obj/item/device/guitar/New()
	song = new("guitar", src)
	song.instrumentExt = "ogg"

/obj/item/device/guitar/Destroy()
	qdel(song)
	song = null
	..()

/obj/item/device/guitar/attack_self(mob/user as mob)
	interact(user)

/obj/item/device/guitar/interact(mob/user as mob)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	song.interact(user)