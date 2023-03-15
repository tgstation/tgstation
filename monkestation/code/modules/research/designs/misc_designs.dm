/datum/design/haul_gauntlet
	name = "\improper H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	id = "haul_gauntlet"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/gloves/cargo_gauntlet
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/diagnostic_hud_weld
	name = "Diagnostic Welding HUD"
	desc = "Upgraded version of the diagnostic HUD including an optional welding screen module."
	id = "diagnostic_hud_weld"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/uranium = 1000, /datum/material/plasma = 300, /datum/material/copper = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/weld
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
