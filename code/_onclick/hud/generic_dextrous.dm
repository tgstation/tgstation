/datum/hud/dextrous
	///Boolean on whether to give the generic combat indicator
	var/give_generic_combat = TRUE
	///Boolean on whether to give a health doll.
	var/give_health_doll = TRUE

//Used for normal mobs that have hands.
/datum/hud/dextrous/initialize_screen_objects()
	. = ..()
	var/atom/movable/screen/using
	add_screen_object(/atom/movable/screen/drop, HUD_MOB_DROP, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 1))
	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_2, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 2))
	using.icon_state = "act_swap"

	mymob.canon_client?.clear_screen()

	build_hand_slots()

	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_below_throw)
	if(give_generic_combat)
		add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_INFO, ui_style, ui_movi)
	if(give_health_doll)
		add_screen_object(/atom/movable/screen/healthdoll/living, HUD_MOB_HEALTHDOLL, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_above_movement)
	add_screen_object(/atom/movable/screen/zone_sel, HUD_MOB_ZONE_SELECTOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/area_creator, HUD_MOB_AREA_CREATOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/memories, HUD_MOB_MEMORIES, HUD_GROUP_STATIC, ui_style)

	if(HAS_TRAIT(mymob, TRAIT_CAN_THROW_ITEMS))
		add_screen_object(/atom/movable/screen/throw_catch, HUD_MOB_THROW, HUD_GROUP_HOTKEYS, ui_style, ui_drop_throw)
