////////////////////////
//ID: MODULAR_WEAPONS //
////////////////////////

////////////////////////
//        AMMO        //
////////////////////////

// .32 - 15 damage pistol round.

/datum/design/c32
	name = ".32 Bullet"
	id = "c32"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c32
	category = list("hacked", "Security")

/datum/design/c32/rubber
	name = ".32 Rubber Bullet"
	id = "c32/rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c32/rubber
	category = list("initial", "Security")

/datum/design/a762
	name = "7.62 Bullet"
	id = "a762"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/ammo_casing/a762
	category = list("hacked", "Security")

/datum/design/a762_rubber
	name = "7.62 Rubber Bullet"
	id = "a762_rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/ammo_casing/a762/rubber
	category = list("hacked", "Security")

// 4.6x30mm - SMG round, used in the WT550 and in numerous modular guns as a weaker alternative to 9mm.

/datum/design/c46x30mm
	name = "4.6x30mm Bullet"
	id = "c46x30mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c46x30mm
	category = list("hacked", "Security")

/datum/design/c46x30mm_rubber
	name = "4.6x30mm Rubber Bullet"
	id = "c46x30mm_rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c46x30mm/rubber
	category = list("initial", "Security")

// .45

/datum/design/c45_lethal
	name = ".45 Bullet"
	id = "c45_lethal"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c45
	category = list("hacked", "Security")

/datum/design/c45_rubber
	name = ".45 Bouncy Rubber Ball"
	id = "c45_rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c45/rubber
	category = list("initial", "Security")

// .460 Rowland magnum, for the M45A5

/datum/design/b460
	name = ".460 Rowland magnum"
	id = "b460"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/ammo_casing/b460
	category = list("hacked", "Security")

// 10mm Magnum
/datum/design/c10mm_lethal
	name = "10mm Magnum bullet"
	id = "c10mm_lethal"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c10mm
	category = list("hacked", "Security")

/datum/design/c10mm_rubber
	name = "10mm Magnum rubber bullet"
	id = "c10mm_rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/ammo_casing/c10mm/rubber
	category = list("initial", "Security")

/datum/design/shotgun_slug
	name = "Shotgun Slug"
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 6000)
	build_path = /obj/item/ammo_casing/shotgun
	category = list("hacked", "Security")

/datum/design/buckshot_shell
	name = "Buckshot Shell"
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list("hacked", "Security")
