/datum/design/cyberimp_razorwire
	name = "Razorwire Spool Implant"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble. \
		Results against anything more durable will heavily vary, however."
	id = "combat_implant_razorwire"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/razorwire
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_COMBAT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/arm_surgery_computer
	name = "Implanted Wrist Surgical Processor"
	desc = "An integrated surgical processor implanted within the user's wrist. \
		Allows mobile operation of more advanced medical surgery."
	id = "combat_implant_surgery"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/arm_surgery_computer
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_HEALTH
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/cyberimp_shell_launcher
	name = "Shell Launch System Implant"
	desc = "A mounted cannon seated comfortably in a forearm compartment. Comes with a seemingly endless stock of \
		proprietary shells within that the user can switch between with some concentration."
	id = "combat_implant_shell_launcher"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/arm/shell_launcher
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_COMBAT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/cyberimp_sandy
	name = "Qani-Laaca Sensory Computer Implant"
	desc = "An experimental implant replacing the spine of organics. When activated, it can give a temporary boost to mental processing speed, \
		Which many users percieve as a slowing of time and quickening of their ability to act. Due to its nature, it is incompatible with \
		system that heavily influence the user's nervous system, like the central nervous system rebooter."
	id = "combat_implant_sandy"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/sensory_enhancer
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_COMBAT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/cyberimp_hackerman
	name = "Hogelun Micromanipulator Computer"
	desc = "A powerful neural computer interface that allows significantly faster processing of actions, and \
		sending nervous instructions to the fingers to do those actions at a similar speed. Finally, you can \
		work your hands as fast you think of things to do with them."
	id = "combat_implant_hackerman"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/interaction_speeder
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/cyberimp_trickshot
	name = "RICOCHOT 9000 Combat Computer"
	desc = "A neural computer with terrible branding, allowing the user to perform precise ballistic calculations \
		in real time. Doesn't do too much to improve hand-eye coordination of course, but it can make you a pretty nice shot."
	id = "combat_implant_trickshot"
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 30 SECONDS
	build_path = /obj/item/organ/cyberimp/trickshotter
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_COMBAT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/cyber/cyber_implants/New()
	design_ids += list(
		"combat_implant_sandy",
		"combat_implant_hackerman",
		"combat_implant_razorwire",
		"combat_implant_shell_launcher",
		"combat_implant_surgery",
		"combat_implant_trickshot",
	)
	return ..()
