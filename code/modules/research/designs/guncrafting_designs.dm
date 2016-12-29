/datum/design/guncrafting_frame_energy
	name = "Gun Frame: Energy"
	desc = "No pin included, have fun."
	id = "guncrafting_frame_energy"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun/energy/frame/testing
	category = list("Guncrafting Parts")

/datum/design/guncrafting_frame_ballistic
	name = "Gun Frame: Ballistic"
	desc = "No pin included, have fun."
	id = "guncrafting_frame_ballistic"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun/ballistic/frame/testing
	category = list("Guncrafting Parts")


// barrels
/datum/design/barrel_short
	name = "Gun Barrel: Short"
	desc = "A short barrel."
	id = "barrel_short"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/barrel/short
	category = list("Guncrafting Parts")

/datum/design/barrel_medium
	name = "Gun Barrel: Medium"
	desc = "A medium barrel."
	id = "barrel_medium"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/barrel/medium
	category = list("Guncrafting Parts")

/datum/design/barrel_long
	name = "Gun Barrel: Long"
	desc = "A long barrel."
	id = "barrel_long"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/barrel/long
	category = list("Guncrafting Parts")

// handles
/datum/design/handle_semiauto
	name = "Gun Handle: Semi-Automatic"
	desc = "A semiauto handle."
	id = "handle_semiauto"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/handle/semiauto
	category = list("Guncrafting Parts")

/datum/design/handle_burst
	name = "Gun Handle: 3 Round Burst"
	desc = "A burst handle."
	id = "handle_burst"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/handle/burst
	category = list("Guncrafting Parts")

/datum/design/handle_auto
	name = "Gun Handle: Automatic"
	desc = "A fully automatic handle."
	id = "handle_auto"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/handle/auto
	category = list("Guncrafting Parts")

// bases
/datum/design/base_stun
	name = "Gun Energy Base: Stun"
	desc = "A stun base."
	id = "base_stun"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/stun
	category = list("Guncrafting Parts")

/datum/design/base_disable
	name = "Gun Energy Base: Disable"
	desc = "A disabler base."
	id = "base_disable"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/disable
	category = list("Guncrafting Parts")

/datum/design/base_laser
	name = "Gun Energy Base: Laser"
	desc = "A laser base."
	id = "base_laser"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/laser
	category = list("Guncrafting Parts")

/datum/design/base_ion
	name = "Gun Energy Base: Ion"
	desc = "An ion base."
	id = "base_ion"
	req_tech = list("combat" = 5, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_METAL = 8000, MAT_URANIUM = 2000)
	build_path = /obj/item/weapon/gun_attachment/base/ion
	category = list("Guncrafting Parts")

/datum/design/base_xray
	name = "Gun Energy Base: X-Ray"
	desc = "An X-Ray base."
	id = "base_xray"
	req_tech = list("combat" = 7, "magnets" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 8000, MAT_METAL = 5000, MAT_TITANIUM = 2000)
	build_path = /obj/item/weapon/gun_attachment/base/xray
	category = list("Guncrafting Parts")

/datum/design/base_tesla
	name = "Gun Energy Base: Tesla"
	desc = "A tesla base."
	id = "base_tesla"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/weapon/gun_attachment/base/tesla
	category = list("Guncrafting Parts")

/datum/design/base_ar
	name = "Gun Ballistic Base: Assault Rifle"
	desc = "An assault rifle base."
	id = "base_ar"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/assault
	category = list("Guncrafting Parts")

/datum/design/base_pistol
	name = "Gun Ballistic Base: Pistol"
	desc = "A pistol base."
	id = "base_pistol"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/pistol
	category = list("Guncrafting Parts")

//energy bullets
/datum/design/ebullet_pen
	name = "Gun Energy Modifier: Penetrator" // ;)
	desc = "A Penetrator mod."
	id = "ebullet_pen"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/armor_pen
	category = list("Guncrafting Parts")

/datum/design/ebullet_disorient
	name = "Gun Energy Modifier: Disorienter"
	desc = "A disorienter mod."
	id = "ebullet_disorient"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/disorienter
	category = list("Guncrafting Parts")

/datum/design/ebullet_decloner
	name = "Gun Energy Modifier: Decloner"
	desc = "A decloner mod."
	id = "ebullet_decloner"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/decloner
	category = list("Guncrafting Parts")

/datum/design/ebullet_speed
	name = "Gun Energy Modifier: Speed"
	desc = "A speed mod."
	id = "ebullet_speed"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/speed
	category = list("Guncrafting Parts")

/datum/design/ebullet_invert
	name = "Gun Energy Modifier: Invert"
	desc = "A invert mod."
	id = "ebullet_invert"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/invert
	category = list("Guncrafting Parts")

/datum/design/ebullet_big
	name = "Gun Energy Modifier: Size" // matters
	desc = "A big mod."
	id = "ebullet_big"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/big
	category = list("Guncrafting Parts")

/datum/design/bullet_fmj
	name = "Gun Bullet Modifier: Full Metal Jacket" // this is my rifle, this is my gun
	desc = "A FMJ mod."
	id = "bullet_fmj"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/bullet/fmj
	category = list("Guncrafting Parts")

/datum/design/bullet_rad
	name = "Gun Bullet Modifier: Polonium"
	desc = "A polonium mod."
	id = "bullet_rad"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/bullet/polonium
	category = list("Guncrafting Parts")

/datum/design/bullet_ap
	name = "Gun Bullet Modifier: Armor Piercing"
	desc = "An AP mod."
	id = "bullet_ap"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/bullet/ap
	category = list("Guncrafting Parts")

//scopes
/datum/design/scope_reflex
	name = "Gun Sight: Reflex"
	desc = "A reflex sight."
	id = "scope_reflex"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/scope/reflex
	category = list("Guncrafting Parts")

/datum/design/scope_rd
	name = "Gun Sight: Red-Dot"
	desc = "A red-dot sight."
	id = "scope_rd"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/scope/red_dot
	category = list("Guncrafting Parts")

/datum/design/scope_sniper
	name = "Gun Sight: Sniper"
	desc = "A sniper scope."
	id = "scope_sniper"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/scope/sniper
	category = list("Guncrafting Parts")

//underbarrels
/datum/design/underbarrel_bayonet
	name = "Gun Underbarrel: Bayonet"
	desc = "A bayonet."
	id = "underbarrel_bayonet"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/underbarrel/bayonet
	category = list("Guncrafting Parts")

// magazines
/datum/design/mag_ar
	name = "Gun Magazine: Assault Rifle"
	desc = "see title"
	id = "mag_ar"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_box/magazine/guncrafting_ar
	category = list("Guncrafting Parts")

/datum/design/mag_pistol
	name = "Gun Magazine: Pistol"
	desc = "see title"
	id = "mag_pistol"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_box/magazine/guncrafting_pistol
	category = list("Guncrafting Parts")