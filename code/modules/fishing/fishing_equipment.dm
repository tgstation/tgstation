// Reels

/obj/item/fishing_line
	name = "fishing line reel"
	desc = "simple fishing line"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "reel_blue"
	var/fishing_line_traits = NONE
	/// Color of the fishing line
	var/line_color = "#808080"

/obj/item/fishing_line/reinforced
	name = "reinforced fishing line reel"
	desc = "essential for fishing in extreme environments"
	icon_state = "reel_green"
	fishing_line_traits = FISHING_LINE_REINFORCED
	line_color = "#2b9c2b"

/obj/item/fishing_line/cloaked
	name = "cloaked fishing line reel"
	desc = "even harder to notice than the common variety"
	icon_state = "reel_white"
	fishing_line_traits = FISHING_LINE_CLOAKED
	line_color = "#82cfdd"

/obj/item/fishing_line/bouncy
	name = "flexible fishing line reel"
	desc = "this specialized line is much harder to snap"
	icon_state = "reel_red"
	fishing_line_traits = FISHING_LINE_BOUNCY
	line_color = "#99313f"

// Hooks

/obj/item/fishing_hook
	name = "simple fishing hook"
	desc = "a simple fishing hook."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "hook"
	w_class = WEIGHT_CLASS_TINY

	var/fishing_hook_traits = NONE
	// icon state added to main rod icon when this hook is equipped
	var/rod_overlay_icon_state = "hook_overlay"

/obj/item/fishing_hook/magnet
	name = "magnetic hook"
	desc = "won't make catching fish any easier but might help with looking for other things"
	icon_state = "treasure"
	fishing_hook_traits = FISHING_HOOK_MAGNETIC
	rod_overlay_icon_state = "hook_treasure_overlay"

/obj/item/fishing_hook/shiny
	name = "shiny lure hook"
	icon_state = "gold_shiny"
	fishing_hook_traits = FISHING_HOOK_SHINY
	rod_overlay_icon_state = "hook_shiny_overlay"

/obj/item/fishing_hook/weighted
	name = "weighted hook"
	icon_state = "weighted"
	fishing_hook_traits = FISHING_HOOK_WEIGHTED
	rod_overlay_icon_state = "hook_weighted_overlay"


/obj/item/storage/toolbox/fishing
	name = "fishing toolbox"
	desc = "contains everything you need for your fishing trip"
	icon_state = "fishing"
	inhand_icon_state = "artistic_toolbox"
	material_flags = NONE

/obj/item/storage/toolbox/ComponentInitialize()
	. = ..()
	// Can hold fishing rod despite the size
	var/static/list/exception_cache = typecacheof(/obj/item/fishing_rod)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.exception_hold = exception_cache

/obj/item/storage/toolbox/fishing/PopulateContents()
	new /obj/item/bait_can/worm(src)
	new /obj/item/fishing_rod(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)

/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"

/obj/item/storage/box/fishing_hooks/PopulateContents()
	. = ..()
	new /obj/item/fishing_hook/magnet(src)
	new /obj/item/fishing_hook/shiny(src)
	new /obj/item/fishing_hook/weighted(src)

/obj/item/storage/box/fishing_lines
	name = "fishing line set"

/obj/item/storage/box/fishing_lines/PopulateContents()
	. = ..()
	new /obj/item/fishing_line/bouncy(src)
	new /obj/item/fishing_line/reinforced(src)
	new /obj/item/fishing_line/cloaked(src)
