#undef WILDCARD_LIMIT_ADMIN
#define WILDCARD_LIMIT_ADMIN list(WILDCARD_NAME_ALL = list(limit = -1, usage = list()))

/obj/item/card/id/advanced/debug/bst
	name = "\improper Bluespace ID"
	desc = "A Bluespace ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	trim = /datum/id_trim/admin/bst
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/datum/id_trim/admin/bst
	assignment = "Bluespace Technician"
	trim_state = "trim_stationengineer"
	department_color = COLOR_BLACK
	subdepartment_color = COLOR_BLACK
	sechud_icon_state = "hudcentcom"

/obj/item/modular_computer/pda/heads/captain/bst
	name = "tech PDA"
	greyscale_colors = "#3F3F3F#AAFF00#AAFF00#FFFF0000"
