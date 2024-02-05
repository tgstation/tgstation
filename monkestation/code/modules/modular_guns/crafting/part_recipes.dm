/datum/crafting_recipe/wood_mk58_stock
	name = "Wooden MK58 Stock"
	tool_paths = list(/obj/item/hatchet)
	result = /obj/item/attachment/stock/mk58/wood
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 8,
		/obj/item/stack/sticky_tape = 1,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/metal_mk58_stock
	name = "Wooden MK58 Stock"
	tool_behaviors = list(TOOL_WELDER)
	result = /obj/item/attachment/stock/mk58/metal
	reqs = list(
		/obj/item/stack/sheet/mineral/titanium = 8,
		/obj/item/stack/sticky_tape = 1,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_frame_makeshift
	name = "Makeshift MK58 Frame"
	result = /obj/item/attachment/frame/mk_58/makeshift
	reqs = list(
		/obj/item/stack/sheet/cardboard = 10,
		/obj/item/stack/sticky_tape = 2,
		/obj/item/stack/sheet/mineral/iron = 2,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_welrod
	name = "MK58 Welrod".
	tool_behaviors = list(TOOL_WELDER)
	result = /obj/item/attachment/welrod/mk_58
	reqs = list(
		/obj/item/stack/sheet/mineral/iron = 6,
	)
	time = 7.5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_grip_makeshift
	name = "Makeshift MK58 Grip"
	result = /obj/item/attachment/grip/mk_58/makeshift
	reqs = list(
		/obj/item/stack/sheet/cardboard = 8,
		/obj/item/stack/sticky_tape = 2,
		/obj/item/stack/sheet/mineral/iron = 2,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_grip_colorable
	name = "Colorable MK58 Grip"
	tool_behaviors = list(TOOL_WELDER)
	result = /obj/item/attachment/grip/mk_58/colorable
	reqs = list(
		/obj/item/stack/sheet/plastic = 12,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_frame_colorable
	name = "Colorable MK58 Frame"
	tool_behaviors = list(TOOL_WELDER)
	result = /obj/item/attachment/frame/mk_58/colorable
	reqs = list(
		/obj/item/stack/sheet/plastic = 6,
		/obj/item/stack/sheet/mineral/iron = 12,
	)
	time = 5 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_m10mm_mag
	name = "MK58 10mm Magslot"
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
	result = /obj/item/attachment/mag/mk58/m10mm
	reqs = list(
		/obj/item/stack/sheet/mineral/iron = 5,
	)
	time = 4 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_m50_mag
	name = "MK58 .50ae Magslot"
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
	result = /obj/item/attachment/mag/mk58/m50
	reqs = list(
		/obj/item/stack/sheet/mineral/iron = 5,
	)
	time = 4 SECONDS
	category = CAT_GUNPARTS

/datum/crafting_recipe/mk58_flashlight
	name = "MK58 Flashlight Attachment"
	tool_behaviors = list(TOOL_WELDER)
	result = /obj/item/attachment/mag/mk58/m50
	reqs = list(
		/obj/item/stack/sheet/mineral/iron = 2,
		/obj/item/flashlight/seclite = 1,
	)
	time = 4 SECONDS
	category = CAT_GUNPARTS
