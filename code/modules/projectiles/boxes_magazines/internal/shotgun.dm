/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = CALIBER_SHOTGUN
	max_ammo = 4
	// this inherits regular magazines' AMMO_BOX_MULTILOAD_IN, which means that regular shotguns shouldn't be multiloading from Bulldog magazines
	// if someone has the bright idea to add shotgun speedloaders, i certainly hope they know what they're inviting by doing so

/obj/item/ammo_box/magazine/internal/shot/tube
	name = "dual feed shotgun internal tube"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/tube/fire
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/no_trail

/obj/item/ammo_box/magazine/internal/shot/tube/buckshot
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/tube/slug
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/com/compact
	name = "compact shotgun internal magazine"
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/dual/slugs
	name = "double-barrel shotgun internal magazine (slugs)"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/internal/shot/dual/breacherslug
	name = "double-barrel shotgun internal magazine (breacher)"
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/bounty
	name = "triple-barrel shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/incapacitate
	max_ammo = 3

/obj/item/ammo_box/magazine/internal/shot/single
	name = "single-barrel shotgun internal magazine"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/single/musket
	name = "\improper Donk Co. musket internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette/donk
