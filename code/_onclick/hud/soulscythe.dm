/datum/hud/soulscythe
	needs_health_indicator = FALSE //we use blood level instead.

/datum/hud/soulscythe/New(mob/living/basic/soulscythe/owner)
	. = ..()
	var/atom/movable/screen/using = new /atom/movable/screen/blood_level(null, src)
	infodisplay += using

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_zonesel
	static_inventory += action_intent
