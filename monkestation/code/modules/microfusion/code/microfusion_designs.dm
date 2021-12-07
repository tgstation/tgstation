// CELLS AND EMITTERS
/datum/design/basic_microfusion_cell
	name = "Basic Microfusion Cell"
	desc = "A basic microfusion cell with a capacity of 1200 MF and and 1 attachment points."
	id = "basic_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	construction_time = 10 SECONDS
	build_path = /obj/item/stock_parts/cell/microfusion
	category = list("Misc", "Power Designs", "Machinery", "initial")

/datum/design/microfusion_phase_emitter_undercharger
	name = "Microfusion Phase Emitter Undercharger"
	desc = "Inverts the output beam of the phase emitter, popular amongst law enforcement as a non-lethal upgrade."
	id = "microfusion_phase_emitter_undercharger"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	construction_time = 10 SECONDS
	build_path = /obj/item/microfusion_gun_attachment/undercharger
	category = list("Misc", "Power Designs", "Machinery", "initial")

/datum/design/enhanced_microfusion_cell
	name = "Enhanced Microfusion Cell"
	desc = "An enhanced microfusion cell with a capacity of 1500 MF and 2 attachment points."
	id = "enhanced_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200, /datum/material/uranium = 200)
	construction_time = 10 SECONDS
	build_path = /obj/item/stock_parts/cell/microfusion/enhanced
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/enhanced_microfusion_phase_emitter
	name = "Enhanced Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "enhanced_microfusion_phase_emitter"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	construction_time = 10 SECONDS
	build_path = /obj/item/microfusion_phase_emitter/enhanced
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/advanced_microfusion_cell
	name = "Advanced Microfusion Cell"
	desc = "An advanced microfusion cell with a capacity of 1700 MF and 3 attachment points."
	id = "advanced_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials =  list(/datum/material/iron = 1000, /datum/material/gold = 300, /datum/material/silver = 300, /datum/material/glass = 300, /datum/material/uranium = 300)
	construction_time = 10 SECONDS
	build_path = /obj/item/stock_parts/cell/microfusion/advanced
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/advanced_microfusion_phase_emitter
	name = "Advanced Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "advanced_microfusion_phase_emitter"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	construction_time = 10 SECONDS
	build_path = /obj/item/microfusion_phase_emitter/advanced
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespace_microfusion_cell
	name = "Bluespace Microfusion Cell"
	desc = "A bluespace microfusion cell with a capacity of 2000 MF and 4 attachment points."
	id = "bluespace_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 300, /datum/material/glass = 300, /datum/material/diamond = 300, /datum/material/uranium = 300, /datum/material/titanium = 300, /datum/material/bluespace = 300)
	construction_time = 10 SECONDS
	build_path = /obj/item/stock_parts/cell/microfusion/bluespace
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespace_microfusion_phase_emitter
	name = "Bluespace Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "bluespace_microfusion_phase_emitter"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/diamond = 500)
	construction_time = 10 SECONDS
	build_path = /obj/item/microfusion_phase_emitter/bluespace
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

// CELL UPGRADES
/datum/design/microfusion_cell_attachment_rechargeable
	name = "Rechargeable Microfusion Cell Attachment"
	desc = "An attachment for microfusion cells that allows conversion of KJ to MF in standard chargers."
	id = "microfusion_cell_attachment_rechargeable"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/microfusion_cell_attachment/rechargeable
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_cell_attachment_stabiliser
	name = "Stabilising Microfusion Cell Attachment"
	desc = "Stabilises the internal fusion reaction of microfusion cells."
	id = "microfusion_cell_attachment_stabiliser"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/microfusion_cell_attachment/stabiliser
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_cell_attachment_overcapacity
	name = "Overcapacity Microfusion Cell Attachment"
	desc = "An attachment for microfusion cells that increases MF capacity."
	id = "microfusion_cell_attachment_overcapacity"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plasma = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_cell_attachment/overcapacity
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_cell_attachment_selfcharging
	name = "Self-Charging Microfusion Cell Attachment"
	desc = "Contains a small amount of infinitely decaying nuclear material, causing the fusion reaction to be self sustaining. WARNING: May cause radiation burns if not stabilised."
	id = "microfusion_cell_attachment_selfcharging"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/uranium = 1000)
	build_path = /obj/item/microfusion_cell_attachment/selfcharging
	category = list("Misc", "Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

// GUN UPGRADES
/datum/design/microfusion_gun_attachment_grip
	name = "Microfusion Weapon Grip"
	desc = "A grip... for microfusion weapon platforms."
	id = "microfusion_gun_attachment_grip"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/grip
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_scope
	name = "Microfusion Weapon Scope"
	desc = "A scope... for microfusion weapon platforms."
	id = "microfusion_gun_attachment_scope"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/scope
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_black_camo
	name = "Black Camo Microfusion Frame"
	desc = "A frame modification for the MCR-10, changing the color of the gun to black."
	id = "microfusion_gun_attachment_black_camo"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/black_camo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_rail
	name = "Microfusion Weapon Rail"
	desc = "A rail system for any additional attachments, such as a torch."
	id = "microfusion_gun_attachment_rail"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/rail
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_heatsink
	name = "Phase Emitter Heatsink"
	desc = "A heatsink attachment for your microfusion weapon. Massively increases cooling potential."
	id = "microfusion_gun_attachment_heatsink"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/heatsink
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_scatter
	name = "Diffuser Microfusion Lens Attachment"
	desc = "Splits the microfusion laser beam entering the lens!"
	id = "microfusion_gun_attachment_scatter"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/silver = 500)
	build_path = /obj/item/microfusion_gun_attachment/scatter
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_superheat
	name = "Superheating Phase Emitter Upgrade"
	desc = "Superheats the beam, causing targets to ignite!"
	id = "microfusion_gun_attachment_superheat"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/plasma = 500)
	build_path = /obj/item/microfusion_gun_attachment/superheat
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_repeater
	name = "Repeating Phase Emitter Upgrade"
	desc = "Upgrades the central phase emitter to repeat twice."
	id = "microfusion_gun_attachment_repeater"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/microfusion_gun_attachment/repeater
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_xray
	name = "Phase Inverter Emitter Array"
	desc = "Experimental technology that inverts the central phase emitter causing the wave frequency to shift into X-ray. CAUTION: Phase emitter heats up very quickly."
	id = "microfusion_gun_attachment_xray"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/uranium = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/microfusion_gun_attachment/xray
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/microfusion_gun_attachment_rgb
	name = "Phase Emitter Spectrograph"
	desc = "An attachment hooked up to the phase emitter, allowing the user to adjust the color of the beam outputted. This has seen widespread use by various factions capable of getting their hands on microfusion weapons, whether as a calling card or simply for entertainment."
	id = "microfusion_gun_attachment_rgb"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/microfusion_gun_attachment/rgb
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
