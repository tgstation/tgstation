/datum/design/nifsoft_remover
	name = "Lopland 'Wrangler' NIF-Cutter"
	desc = "A small device that lets the user remove NIFSofts from a NIF user."
	id = "nifsoft_remover"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/nifsoft_remover
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/nifsoft_money_sense
	name = "Automatic Appraisal NIFSoft"
	desc = "A NIFSoft datadisk containing the Automatic Appraisal NIFsoft."
	id = "nifsoft_money_sense"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/disk/nifsoft_uploader/money_sense
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/soulcatcher_device
	name = "Evoker-Type RSD"
	desc = "An RSD instrument that lets the user pull the consciousness from a body and store it virtually."
	id = "soulcatcher_device"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/handheld_soulcatcher
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mini_soulcatcher
	name = "Poltergeist-Type RSD"
	desc = "A miniature version of a Soulcatcher that can be attached to various objects."
	id = "mini_soulcatcher"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/attachable_soulcatcher
	materials = list(
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/nifsoft_hud
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_EQUIPMENT,
	)

/datum/design/nifsoft_hud/medical
	name = "Medical HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Medical HUD NIFsoft."
	id = "nifsoft_hud_medical"
	build_path = /obj/item/disk/nifsoft_uploader/med_hud
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/nifsoft_hud/security
	name = "Security HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Security HUD NIFsoft."
	id = "nifsoft_hud_security"
	build_path = /obj/item/disk/nifsoft_uploader/sec_hud
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/nifsoft_hud/cargo
	name = "Permit HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Permit HUD NIFsoft."
	id = "nifsoft_hud_cargo"
	build_path = /obj/item/disk/nifsoft_uploader/permit_hud
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/nifsoft_hud/diagnostic
	name = "Diagnostic HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Diagnostic HUD NIFsoft."
	id = "nifsoft_hud_diagnostic"
	build_path = /obj/item/disk/nifsoft_uploader/diag_hud
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/nifsoft_hud/science
	name = "Science HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Science HUD NIFsoft."
	id = "nifsoft_hud_science"
	build_path = /obj/item/disk/nifsoft_uploader/sci_hud
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/nifsoft_hud/meson
	name = "Meson HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Meson HUD NIFsoft."
	id = "nifsoft_hud_meson"
	build_path = /obj/item/disk/nifsoft_uploader/meson_hud
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/nif_hud_kit
	name = "NIF HUD Retrofitter"
	desc = "A kit that modifies select glasses to display HUDs for NIFs."
	id = "nifsoft_hud_kit"
	build_type = PROTOLATHE | AWAY_LATHE
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SECURITY
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_EQUIPMENT,
	)
	build_path = /obj/item/nif_hud_adapter

