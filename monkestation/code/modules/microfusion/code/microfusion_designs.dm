#define RND_CATEGORY_MICROFUSION_WEAPONS "/Weaponry (Microfusion)"
#define RND_MICROFUSION_CELLS "/Cells"
#define RND_MICROFUSION_CELL_ATTACHMENTS "/Cell Attachments"
#define RND_MICROFUSION_EMITTERS "/Phase Emitters"
// god forgive me
#define RND_MICROFUSION_ATTACHMENT "/Attachments"
#define RND_MICROFUSION_ATTACHMENT_BARREL " (Barrel)"
#define RND_MICROFUSION_ATTACHMENT_UNDERBARREL " (Underbarrel)"
#define RND_MICROFUSION_ATTACHMENT_RAIL " (Rail)"
#define RND_MICROFUSION_ATTACHMENT_UNIQUE " (Cosmetic)"

// BASE FOR MCR DESIGNS
/datum/design/microfusion
	name = "Microfusion Part"
	build_type = PROTOLATHE | AWAY_LATHE
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
	construction_time = 10 SECONDS //dunno if this is for mechfabs or what but I'll keep this anyway
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS,
	)

// EMITTERS

/datum/design/microfusion/phase_emitter
	name = "Placeholder Microfusion Phase Emitter"
	desc = "You shouldn't see this. Still, odd how there's no basic phase emitter design, despite how redundant it'd be."
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_EMITTERS,
	)

/datum/design/microfusion/phase_emitter/enhanced
	name = "Enhanced Microfusion Phase Emitter"
	desc = "The core of a microfusion projection weapon, produces the laser."
	id = "enhanced_microfusion_phase_emitter"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_phase_emitter/enhanced

/datum/design/microfusion/phase_emitter/advanced
	name = "Advanced Microfusion Phase Emitter"
	id = "advanced_microfusion_phase_emitter"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_phase_emitter/advanced

/datum/design/microfusion/phase_emitter/bluespace
	name = "Bluespace Microfusion Phase Emitter"
	id = "bluespace_microfusion_phase_emitter"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_phase_emitter/bluespace

// CELLS

/datum/design/microfusion/cell
	name = "Microfusion Cell"
	desc = "A microfusion cell. There's a basic type defined next to this, right?"
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_CELLS,
	)

/datum/design/microfusion/cell/basic
	name = "Basic Microfusion Cell"
	desc = "A basic microfusion cell with a capacity of 1200 MF and and 1 attachment point."
	id = "basic_microfusion_cell"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/stock_parts/cell/microfusion
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_CELLS,
	)

/datum/design/microfusion/cell/enhanced
	name = "Enhanced Microfusion Cell"
	desc = "An enhanced microfusion cell with a capacity of 1500 MF and 1 attachment point."
	id = "enhanced_microfusion_cell"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/stock_parts/cell/microfusion/enhanced

/datum/design/microfusion/cell/advanced
	name = "Advanced Microfusion Cell"
	desc = "An advanced microfusion cell with a capacity of 1700 MF and 3 attachment points."
	id = "advanced_microfusion_cell"
	materials =  list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/stock_parts/cell/microfusion/advanced

/datum/design/microfusion/cell/bluespace
	name = "Bluespace Microfusion Cell"
	desc = "A bluespace microfusion cell with a capacity of 2000 MF and 3 attachment points."
	id = "bluespace_microfusion_cell"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/stock_parts/cell/microfusion/bluespace

// CELL UPGRADES

/datum/design/microfusion/cell_attachment
	name = "Placeholder Cell Attachment"
	desc = "You shouldn't be seeing this."
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_CELL_ATTACHMENTS,
	)

/datum/design/microfusion/cell_attachment/stabilising
	name = "Stabilising Microfusion Cell Attachment"
	desc = "Stabilises the internal fusion reaction of microfusion cells, preventing sparks during firing and occasional radiation pulses when used in tandem with a self-charging attachment."
	id = "microfusion_cell_attachment_stabiliser"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_cell_attachment/stabiliser

/datum/design/microfusion/cell_attachment/overcapacity
	name = "Overcapacity Microfusion Cell Attachment"
	desc = "An attachment for microfusion cells that increases MF capacity."
	id = "microfusion_cell_attachment_overcapacity"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 4,
	)
	build_path = /obj/item/microfusion_cell_attachment/overcapacity

/datum/design/microfusion/cell_attachment/selfcharging
	name = "Self-Charging Microfusion Cell Attachment"
	desc = "Contains a small amount of infinitely decaying nuclear material, causing the fusion reaction to be self sustaining. WARNING: May cause radiation burns if not stabilised."
	id = "microfusion_cell_attachment_selfcharging"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_cell_attachment/selfcharging

/datum/design/microfusion/attachment
	name = "Placeholder MCR Attachment"
	desc = "You *really* shouldn't be seeing this. Now in different attachment flavors! The Req line will hate you."
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_ATTACHMENT,
	)

// RAIL MODS

/datum/design/microfusion/attachment/rail_slot
	name = "Placeholder Microfusion Rail Slot Attachment"
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_ATTACHMENT + RND_MICROFUSION_ATTACHMENT_RAIL,
	)

/datum/design/microfusion/attachment/rail_slot/rail
	name = "Microfusion Weapon Rail"
	desc = "A carrying handle/rail system for any additional attachments, such as a seclite and/or bayonet."
	id = "microfusion_gun_attachment_rail"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/rail

/datum/design/microfusion/attachment/rail_slot/scope
	name = "Microfusion Weapon Scope"
	desc = "A scope. For microfusion weapon platforms, probably."
	id = "microfusion_gun_attachment_scope"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/scope

// UNDERBARREL MODS

/datum/design/microfusion/attachment/underbarrel
	name = "Placeholder Microfusion Underbarrel Slot Attachment"
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_ATTACHMENT + RND_MICROFUSION_ATTACHMENT_UNDERBARREL,
	)

/datum/design/microfusion/attachment/underbarrel/grip
	name = "Microfusion Weapon Grip"
	desc = "A grip. For microfusion weapon platforms, ostensibly."
	id = "microfusion_gun_attachment_grip"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/grip

/datum/design/microfusion/attachment/underbarrel/heatsink
	name = "Phase Emitter Heatsink"
	desc = "A heatsink attachment for your microfusion weapon. Massively increases cooling potential."
	id = "microfusion_gun_attachment_heatsink"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/heatsink

// BARREL MODS (there's a lot)

/datum/design/microfusion/attachment/barrel
	name = "Placeholder Microfusion Barrel Slot Attachment"
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_ATTACHMENT + RND_MICROFUSION_ATTACHMENT_BARREL,
	)

/datum/design/microfusion/attachment/barrel/suppressor
	name = "Suppressor Lens Attachment"
	desc = "An experimental barrel attachment that dampens the soundwave of the emitter, suppressing the report. Does not make the lasers themselves more stealthy, as they are lasers."
	id = "microfusion_gun_attachment_suppressor"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/suppressor

/datum/design/microfusion/attachment/barrel/honk
	name = "Bananium Phase Emitter \"Upgrade\""
	desc = "Makes your lasers into the greatest clowning tool ever made. HONK!"
	id = "microfusion_gun_attachment_honk"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bananium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/honk

/datum/design/microfusion/attachment/barrel/lance
	name = "Lance Induction Carriage"
	desc = "Turns the gun into a designated marksman rifle."
	id = "microfusion_gun_attachment_lance"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/lance

// EMITTER UPGRADES (they're still barrel upgrades, though)

/datum/design/microfusion/attachment/barrel/scatter
	name = "Diffuser Microfusion Lens Attachment"
	desc = "Splits the microfusion laser beam entering the lens."
	id = "microfusion_gun_attachment_scatter"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/scatter

/datum/design/microfusion/attachment/barrel/scatter/max
	name = "Crystalline Diffuser Microfusion Lens Attachment"
	desc = "Splits the microfusion laser beam entering the lens even more."
	id = "microfusion_gun_attachment_scattermax"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/scatter/max

/datum/design/microfusion/attachment/barrel/superheat
	name = "Superheating Phase Emitter Upgrade"
	desc = "Superheats the beam, causing targets to ignite."
	id = "microfusion_gun_attachment_superheat"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/superheat

/datum/design/microfusion/attachment/barrel/hellfire
	name = "Hellfire Phase Emitter Upgrade"
	desc = "Overheats the beam, causing nastier wounds and higher damage."
	id = "microfusion_gun_attachment_hellfire"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/hellfire

/datum/design/microfusion/attachment/barrel/repeater
	name = "Repeating Phase Emitter Upgrade"
	desc = "Upgrades the central phase emitter to repeat twice."
	id = "microfusion_gun_attachment_repeater"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/repeater

/datum/design/microfusion/attachment/barrel/repeater/penetrator
	name = "Focused Repeating Phase Emitter Upgrade"
	desc = "Upgrades the central phase emitter to repeat twice and penetrate armor."
	id = "microfusion_gun_attachment_penetrator"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/repeater/penetrator

/datum/design/microfusion/attachment/barrel/xray
	name = "Phase Inverter Emitter Array"
	desc = "Experimental technology that inverts the central phase emitter causing the wave frequency to shift into X-rays that pierce solid objects. CAUTION: Phase emitter heats up very quickly."
	id = "microfusion_gun_attachment_xray"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/barrel/xray

// COSMETICS

/datum/design/microfusion/attachment/unique
	name = "Placeholder Microfusion Unique/Cosmetic Attachment"
	category = list(
		RND_CATEGORY_MICROFUSION_WEAPONS + RND_MICROFUSION_ATTACHMENT + RND_MICROFUSION_ATTACHMENT_UNIQUE,
	)

/datum/design/microfusion/attachment/unique/rgb
	name = "Phase Emitter Spectrograph"
	desc = "An attachment hooked up to the phase emitter, allowing the user to adjust the color of the beam outputted. This has seen widespread use by various factions capable of getting their hands on microfusion weapons, whether as a calling card or simply for entertainment."
	id = "microfusion_gun_attachment_rgb"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/rgb

/datum/design/microfusion/attachment/unique/camo_black
	name = "Black Camo Microfusion Frame"
	desc = "A frame modification for the MCR-10, changing the color of the gun to black."
	id = "microfusion_gun_attachment_black_camo"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/camo

/datum/design/microfusion/attachment/unique/camo_nanotrasen
	name = "Nanotrasen Camo Microfusion Frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to blue."
	id = "microfusion_gun_attachment_nt_camo"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/camo/nanotrasen

/datum/design/microfusion/attachment/unique/camo_syndicate
	name = "Blood Red Camo Microfusion Frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to a slick blood red."
	id = "microfusion_gun_attachment_syndi_camo"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/camo/syndicate

/datum/design/microfusion/attachment/unique/camo_bananium
	name = "Bananium Microfusion Frame"
	desc = "A frame modification for the MCR-01, plating the gun in bananium."
	id = "microfusion_gun_attachment_honk_camo"
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bananium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/microfusion_gun_attachment/camo/honk
