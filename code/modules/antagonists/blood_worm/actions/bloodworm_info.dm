/atom/movable/screen/alert/bloodworm_info
	name = "Bloodworm Info"
	desc = "Shows you stats on all Bloodworm-related activities when hovering over."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "highbloodpressure"
	click_master = FALSE

	///Ref to the worm we're giving info about
	var/mob/living/basic/blood_worm/worm_owner

/atom/movable/screen/alert/bloodworm_info/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	underlays += mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_demon", layer = layer, offset_spokesman = src, plane = plane)

/atom/movable/screen/alert/bloodworm_info/Destroy()
	worm_owner = null
	return ..()

/atom/movable/screen/alert/bloodworm_info/MouseEntered(location, control, params)
	name = "Worm Health: [round((worm_owner.health / worm_owner.maxHealth) * 100)]%"
	desc = worm_owner.get_special_status_tab_items()
	return ..()
