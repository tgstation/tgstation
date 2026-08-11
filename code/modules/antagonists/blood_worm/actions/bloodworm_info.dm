/atom/movable/screen/alert/bloodworm_info
	name = "Buckled"
	desc = "You've been buckled to something. Click the alert to unbuckle unless you're handcuffed."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "buckled"
	click_master = FALSE
	clickable_glow = TRUE
	has_tooltip = FALSE

	///Ref to the worm we're giving info about
	var/mob/living/basic/blood_worm/worm_owner

/atom/movable/screen/alert/bloodworm_info/Destroy()
	worm_owner = null
	return ..()

/atom/movable/screen/alert/bloodworm_info/Click()
	. = ..()
	if(!.)
		return

	if(!worm_owner.can_resist())
		return
	worm_owner.changeNext_move(CLICK_CD_RESIST)
	if(worm_owner.last_special <= world.time)
		return worm_owner.resist_buckle()
