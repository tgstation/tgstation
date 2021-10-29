//Most of these are just additions to allow certain cargo packs to exist. More will be on the way on additional PR's

/obj/item/storage/box/techshell
	name = "Box of Unloaded Techshell"
	desc = "A box of Technological Shells. These come unloaded and ready for custom shot loads."

/obj/item/storage/box/techshell/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/techshell(src)
