// BASE FOR MCR DESIGNS
/datum/design/microfusion
	name = "Microfusion Part"
	build_type = PROTOLATHE | AWAY_LATHE
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	construction_time = 10 SECONDS //dunno if this is for mechfabs or what but I'll keep this anyway
	category = list(RND_CATEGORY_WEAPONS)

// EMITTERS
/datum/design/microfusion/enhanced_phase_emitter
	name = "Enhanced Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "enhanced_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_phase_emitter/enhanced

/datum/design/microfusion/advanced_phase_emitter
	name = "Advanced Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "advanced_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_phase_emitter/advanced

/datum/design/microfusion/bluespace_phase_emitter
	name = "Bluespace Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "bluespace_microfusion_phase_emitter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/diamond = 500)
	build_path = /obj/item/microfusion_phase_emitter/bluespace

// CELLS
/datum/design/microfusion/cell
	name = "Microfusion Cell"
	desc = "A microfusion cell."
	category = list(RND_CATEGORY_AMMO)

/datum/design/microfusion/cell/basic
	name = "Basic Microfusion Cell"
	desc = "A basic microfusion cell with a capacity of 1200 MF and and 1 attachment points."
	id = "basic_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	build_path = /obj/item/stock_parts/cell/microfusion
	category = list(RND_CATEGORY_AMMO, RND_CATEGORY_SECURITY, "initial")

/datum/design/microfusion/cell/enhanced
	name = "Enhanced Microfusion Cell"
	desc = "An enhanced microfusion cell with a capacity of 1500 MF and 1 attachment points."
	id = "enhanced_microfusion_cell"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200, /datum/material/uranium = 200)
	build_path = /obj/item/stock_parts/cell/microfusion/enhanced

/datum/design/microfusion/cell/advanced
	name = "Advanced Microfusion Cell"
	desc = "An advanced microfusion cell with a capacity of 1700 MF and 2 attachment points."
	id = "advanced_microfusion_cell"
	materials =  list(/datum/material/iron = 1000, /datum/material/gold = 300, /datum/material/silver = 300, /datum/material/glass = 300, /datum/material/uranium = 300)
	build_path = /obj/item/stock_parts/cell/microfusion/advanced

/datum/design/microfusion/cell/bluespace
	name = "Bluespace Microfusion Cell"
	desc = "A bluespace microfusion cell with a capacity of 2000 MF and 3 attachment points."
	id = "bluespace_microfusion_cell"
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 300, /datum/material/glass = 300, /datum/material/diamond = 300, /datum/material/uranium = 300, /datum/material/titanium = 300, /datum/material/bluespace = 300)
	build_path = /obj/item/stock_parts/cell/microfusion/bluespace

// CELL UPGRADES

/datum/design/microfusion/cell_attachment_stabiliser
	name = "Stabilising Microfusion Cell Attachment"
	desc = "Stabilises the internal fusion reaction of microfusion cells."
	id = "microfusion_cell_attachment_stabiliser"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_cell_attachment/stabiliser

/datum/design/microfusion/cell_attachment_overcapacity
	name = "Overcapacity Microfusion Cell Attachment"
	desc = "An attachment for microfusion cells that increases MF capacity."
	id = "microfusion_cell_attachment_overcapacity"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/microfusion_cell_attachment/overcapacity

/datum/design/microfusion/cell_attachment_selfcharging
	name = "Self-Charging Microfusion Cell Attachment"
	desc = "Contains a small amount of infinitely decaying nuclear material, causing the fusion reaction to be self sustaining. WARNING: May cause radiation burns if not stabilised."
	id = "microfusion_cell_attachment_selfcharging"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/uranium = 5000, /datum/material/titanium = 5000, /datum/material/bluespace = 2500) // Makes it almost in-line with Advanced Egun pricing
	build_path = /obj/item/microfusion_cell_attachment/selfcharging

// RAIL MODS
/datum/design/microfusion/gun_attachment_scope
	name = "Microfusion Weapon Scope"
	desc = "A scope... for microfusion weapon platforms."
	id = "microfusion_gun_attachment_scope"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/scope

/datum/design/microfusion/gun_attachment_rail
	name = "Microfusion Weapon Rail"
	desc = "A rail system for any additional attachments, such as a torch."
	id = "microfusion_gun_attachment_rail"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/rail

// BARREL MODS
/datum/design/microfusion/gun_attachment_grip
	name = "Microfusion Weapon Grip"
	desc = "A grip... for microfusion weapon platforms."
	id = "microfusion_gun_attachment_grip"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/grip

/datum/design/microfusion/gun_attachment_heatsink
	name = "Phase Emitter Heatsink"
	desc = "A heatsink attachment for your microfusion weapon. Massively increases cooling potential."
	id = "microfusion_gun_attachment_heatsink"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/heatsink

/datum/design/microfusion/gun_attachment_suppressor
	name = "Suppressor Lens Attachment"
	desc = "An experimental barrel attachment that dampens the soundwave of the emitter, making the laser shots far more stealthy!"
	id = "microfusion_gun_attachment_suppressor"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/suppressor

/datum/design/microfusion/gun_attachment_honk
	name = "Bananium Phase Emitter Upgrade"
	desc = "Makes your lasers into the greatest clowning tool ever made. HONK!"
	id = "microfusion_gun_attachment_honk"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/bananium = 1000)
	build_path = /obj/item/microfusion_gun_attachment/honk

/datum/design/microfusion/gun_attachment_lance
	name = "Lance Induction Carriage"
	desc = "Turns the gun into a designated marksman rifle."
	id = "microfusion_gun_attachment_lance"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/plasma = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/microfusion_gun_attachment/lance

// EMITTER UPGRADES
/datum/design/microfusion/gun_attachment_scatter
	name = "Diffuser Microfusion Lens Attachment"
	desc = "Splits the microfusion laser beam entering the lens!"
	id = "microfusion_gun_attachment_scatter"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/scatter

/datum/design/microfusion/gun_attachment_superheat
	name = "Superheating Phase Emitter Upgrade"
	desc = "Superheats the beam, causing targets to ignite!"
	id = "microfusion_gun_attachment_superheat"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/plasma = 1000)
	build_path = /obj/item/microfusion_gun_attachment/superheat

/datum/design/microfusion/gun_attachment_hellfire
	name = "Hellfire Phase Emitter Upgrade"
	desc = "Overheats the beam, causing nastier wounds and higher damage!"
	id = "microfusion_gun_attachment_hellfire"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/plasma = 500)
	build_path = /obj/item/microfusion_gun_attachment/hellfire

/datum/design/microfusion/gun_attachment_penetrator
	name = "Focused Repeating Phase Emitter Upgrade"
	desc = "Upgrades the central phase emitter to repeat twice and penetrate armor."
	id = "microfusion_gun_attachment_penetrator"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/penetrator

/datum/design/microfusion/gun_attachment_scattermax
	name = "Crystalline Diffuser Microfusion Lens Attachment"
	desc = "Splits the microfusion laser beam entering the lens even more!"
	id = "microfusion_gun_attachment_scattermax"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/silver = 1000)
	build_path = /obj/item/microfusion_gun_attachment/scattermax

/datum/design/microfusion/gun_attachment_repeater
	name = "Repeating Phase Emitter Upgrade"
	desc = "Upgrades the central phase emitter to repeat twice."
	id = "microfusion_gun_attachment_repeater"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 1000)
	build_path = /obj/item/microfusion_gun_attachment/repeater

/datum/design/microfusion/gun_attachment_xray
	name = "Phase Inverter Emitter Array"
	desc = "Experimental technology that inverts the central phase emitter causing the wave frequency to shift into X-ray. CAUTION: Phase emitter heats up very quickly."
	id = "microfusion_gun_attachment_xray"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/uranium = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/microfusion_gun_attachment/xray

// COSMETICS
/datum/design/microfusion/gun_attachment_rgb
	name = "Phase Emitter Spectrograph"
	desc = "An attachment hooked up to the phase emitter, allowing the user to adjust the color of the beam outputted. This has seen widespread use by various factions capable of getting their hands on microfusion weapons, whether as a calling card or simply for entertainment."
	id = "microfusion_gun_attachment_rgb"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/rgb

/datum/design/microfusion/gun_attachment_black_camo
	name = "Black Camo Microfusion Frame"
	desc = "A frame modification for the MCR-10, changing the color of the gun to black."
	id = "microfusion_gun_attachment_black_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/black_camo

/datum/design/microfusion/gun_attachment_nt_camo
	name = "Nanotrasen Camo Microfusion Frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to blue."
	id = "microfusion_gun_attachment_nt_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 500)
	build_path = /obj/item/microfusion_gun_attachment/nt_camo

/datum/design/microfusion/gun_attachment_syndi_camo
	name = "Blood Red Camo Microfusion Frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to a slick blood red."
	id = "microfusion_gun_attachment_syndi_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/microfusion_gun_attachment/syndi_camo

/datum/design/microfusion/gun_attachment_honk_camo
	name = "Bananium Microfusion Frame"
	desc = "A frame modification for the MCR-01, plating the gun in bananium."
	id = "microfusion_gun_attachment_honk_camo"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/bananium = 500)
	build_path = /obj/item/microfusion_gun_attachment/honk_camo
