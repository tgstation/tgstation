
/obj/item/storage/box/medipen
	name = "box of medipens"
	desc = "A box full medipens."
	icon = 'icons/oldschool/storage.dmi'
	icon_state = "medipen"

/obj/item/storage/box/medipen/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/hypospray/medipen(src)
