//Speedloaders function more like boxes than mags, in that they load bullets but aren't loaded themselves into guns
//A speedloader has no fumble, though. This allows you to load guns quickly.
//TODO: Add an antag speedloader item to the ammo bundle for the revolver

/obj/item/ammo_storage/speedloader
	desc = "A speedloader, used to load a gun without any of that annoying fumbling."
	exact = 0 //load anything in the class!

/obj/item/ammo_storage/speedloader/c38
	name = "speed loader (.38)"
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_storage/speedloader/c38/empty //this is what's printed by the autolathe, since the lathe also does boxes now
	starting_ammo = 0

/obj/item/ammo_storage/speedloader/a357 //now the traitors can do it too
	name = "speed loader (.357)"
	desc = "A speedloader, used to load a gun without any of that annoying fumbling. This one appears to have a small 'S' embossed on the side."
	icon_state = "s357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_storage/speedloader/a357/empty
	starting_ammo = 0