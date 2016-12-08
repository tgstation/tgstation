/datum/design/frame_energy
	name = "Gun Frame: Energy"
	desc = "Comes with a testing firing pin."
	id = "frame_energy"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun/energy/frame/testing
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

/datum/design/barrel_silencer
	name = "Gun Barrel: Silenced"
	desc = "A silenced barrel."
	id = "barrel_silencer"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/barrel/silencer
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
	name = "Gun Base: Stun"
	desc = "A stun base."
	id = "base_stun"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/stun
	category = list("Guncrafting Parts")

/datum/design/base_disable
	name = "Gun Base: Disable"
	desc = "A disabler base."
	id = "base_disable"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/disable
	category = list("Guncrafting Parts")

/datum/design/base_laser
	name = "Gun Base: Laser"
	desc = "A laser base."
	id = "base_laser"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/base/laser
	category = list("Guncrafting Parts")

/datum/design/base_ion
	name = "Gun Base: Ion"
	desc = "An ion base."
	id = "base_ion"
	req_tech = list("combat" = 5, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_METAL = 8000, MAT_URANIUM = 2000)
	build_path = /obj/item/weapon/gun_attachment/base/ion
	category = list("Guncrafting Parts")

/datum/design/base_xray
	name = "Gun Base: X-Ray"
	desc = "An X-Ray base."
	id = "base_xray"
	req_tech = list("combat" = 7, "magnets" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 8000, MAT_METAL = 5000, MAT_TITANIUM = 2000)
	build_path = /obj/item/weapon/gun_attachment/base/xray
	category = list("Guncrafting Parts")

/datum/design/base_tesla
	name = "Gun Base: Tesla"
	desc = "A tesla base."
	id = "base_tesla"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/weapon/gun_attachment/base/tesla
	category = list("Guncrafting Parts")

//energy bullets
/datum/design/ebullet_focus
	name = "Gun Energy Modifier: Focuser"
	desc = "A focuser mod."
	id = "ebullet_focus"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/focuser
	category = list("Guncrafting Parts")

/datum/design/ebullet_stun
	name = "Gun Energy Modifier: Stunner"
	desc = "A stun mod."
	id = "ebullet_stun"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/weapon/gun_attachment/energy_bullet/stunner
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