/atom/movable/screen/proc/rogue_has_click_listener()
	return !isnull(_listen_lookup?[COMSIG_SCREEN_ELEMENT_CLICK])

/atom/movable/screen/rogue/panel_toggle
	name = "panel"
	icon_state = "template_small"
	screen_loc = rogueui_panel_toggle
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/group_key = HUD_GROUP_ROGUE_PANEL

/atom/movable/screen/rogue/panel_toggle/update_overlays()
	. = ..()
	var/datum/hud/rogue/viewer_hud = hud
	if(!istype(viewer_hud) || viewer_hud.group_shown(group_key))
		. += "corner"

/atom/movable/screen/rogue/panel_toggle/Click(location, control, params)
	var/datum/hud/rogue/viewer_hud = usr.hud_used
	if(istype(viewer_hud))
		viewer_hud.toggle_group(group_key, usr)

/atom/movable/screen/rogue/panel_toggle/doll
	name = "body"
	screen_loc = rogueui_doll_toggle
	group_key = HUD_GROUP_ROGUE_DOLL

/atom/movable/screen/rogue/panel_strip
	name = ""
	icon = ROGUE_HUD_ICON_STRIP
	icon_state = "strip"
	screen_loc = rogueui_panel_strip
	layer = ROGUE_HUD_LAYER - 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/rogue/doll_back
	name = ""
	icon = ROGUE_HUD_ICON_DOLL_BACK
	icon_state = "doll_back"
	screen_loc = rogueui_doll_back
	layer = ROGUE_HUD_LAYER - 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/rogue/build
	name = "build"
	icon = ROGUE_HUD_ICON_STRIP
	icon_state = "build"
	screen_loc = rogueui_build
	layer = ROGUE_HUD_LAYER
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/build/Click(location, control, params)
	rogue_hud_not_implemented(usr)

/atom/movable/screen/human/toggle/rogue
	name = "inventory"
	icon = ROGUE_HUD_ICON
	icon_state = "back"
	base_icon_state = "back"
	screen_loc = rogueui_inventory_toggle
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/human/toggle/rogue/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/atom/movable/screen/human/toggle/rogue/Click(location, control, params)
	var/datum/hud/rogue/viewer_hud = usr.hud_used
	if(istype(viewer_hud))
		viewer_hud.toggle_inventory(usr)

/atom/movable/screen/rogue/heatstam_overlay
	icon = ROGUE_HUD_ICON_HEAT
	icon_state = "heatstamover"
	screen_loc = rogueui_fat
	layer = ROGUE_HUD_LAYER + 0.1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/combattoggle/rogue
	name = "combat mode"
	icon = ROGUE_HUD_ICON
	icon_state = "combat0"
	screen_loc = rogueui_cmode
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/combattoggle/rogue/update_icon_state()
	. = ..()
	var/mob/living/owner = get_mob()
	icon_state = "combat[istype(owner) && owner.combat_mode ? 1 : 0]"

/atom/movable/screen/combattoggle/rogue/Click(location, control, params)
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(rogue_combat_enabled())
			INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living, rogue_yield))
		else
			user.emote("surrender")
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		user.playsound_local(user, 'sound/machines/click.ogg', 50, FALSE)
		user.rogue_toggle_compliance()
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		to_chat(user, span_info("* --- *<br>Combat mode button.<br><b>Left click:</b> toggles combat mode.<br><b>Right click:</b> surrender.<br><b>Middle click:</b> toggles compliance mode, removing your defense against grapples and tackles."))
		return
	return ..()

/atom/movable/screen/rogue/weapon_intents
	name = "intent"
	icon = ROGUE_HUD_ICON_INTENT_GRID
	icon_state = "grid"
	screen_loc = rogueui_intents
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/weapon_intents/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/owner = hud_owner?.mymob
	if(isliving(owner))
		RegisterSignals(owner, list(COMSIG_MOB_ROGUE_INTENT_CHANGED, COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_UPDATE_HELD_ITEMS), PROC_REF(on_intents_changed))
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/atom/movable/screen/rogue/weapon_intents/proc/on_intents_changed(datum/source)
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/// A hand with no intents at all shows no grid rather than its empty boxes.
/atom/movable/screen/rogue/weapon_intents/update_icon_state()
	var/mob/living/owner = get_mob()
	icon_state = (isliving(owner) && length(owner.rogue_hand_intents())) ? initial(icon_state) : ""
	return ..()

/atom/movable/screen/rogue/weapon_intents/update_overlays()
	. = ..()
	var/mob/living/owner = get_mob()
	if(!isliving(owner))
		return
	var/list/intents = owner.rogue_hand_intents()
	var/shown = min(length(intents), ROGUE_INTENT_SLOTS)
	if(!shown)
		return
	var/static/list/offsets_x = list(0, 32, 0, 32)
	var/static/list/offsets_y = list(16, 16, 0, 0)
	var/selected = clamp(owner.rogue_intent_slot(), 1, shown)
	var/mutable_appearance/glow = mutable_appearance(ROGUE_HUD_ICON, "intentselected")
	glow.pixel_x = offsets_x[selected]
	glow.pixel_y = offsets_y[selected]
	. += glow
	for(var/slot in 1 to shown)
		var/datum/intent/intent = rogue_intent(intents[slot])
		var/mutable_appearance/intent_icon = mutable_appearance(intent.icon, intent.icon_state)
		intent_icon.pixel_x = offsets_x[slot]
		intent_icon.pixel_y = offsets_y[slot]
		. += intent_icon

/atom/movable/screen/rogue/weapon_intents/Click(location, control, params)
	. = ..()
	var/mob/living/user = get_mob()
	if(usr != user)
		return
	var/list/modifiers = params2list(params)
	var/index = get_index_at_loc(text2num(LAZYACCESS(modifiers, ICON_X)), text2num(LAZYACCESS(modifiers, ICON_Y)))
	if(!index)
		return
	if(SEND_SIGNAL(user, COMSIG_MOB_ROGUE_HUD_INTENT_CLICK, index, modifiers) & COMPONENT_ROGUE_INTENT_HANDLED)
		return
	if(isliving(user))
		if(LAZYACCESS(modifiers, SHIFT_CLICK))
			user.rogue_examine_intent(index)
			return
		if(user.rogue_select_intent(index))
			return
	rogue_hud_not_implemented(user)

/atom/movable/screen/rogue/def_intent
	name = "defense intent"
	icon_state = "def2n"
	screen_loc = rogueui_def
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/def_intent/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/owner = hud_owner?.mymob
	if(isliving(owner))
		RegisterSignal(owner, COMSIG_MOB_ROGUE_INTENT_CHANGED, PROC_REF(on_intents_changed))
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/rogue/def_intent/proc/on_intents_changed(datum/source)
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/rogue/def_intent/update_icon_state()
	. = ..()
	var/mob/living/owner = get_mob()
	icon_state = "def[isliving(owner) ? owner.rogue_def_intent : ROGUE_INTENT_PARRY]n"

/atom/movable/screen/rogue/def_intent/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	user.rogue_toggle_def_intent()

/atom/movable/screen/rogue/weapon_intents/proc/get_index_at_loc(icon_x, icon_y)
	if(!icon_x || !icon_y)
		return null
	if(icon_x <= 32)
		return icon_y > 16 ? 1 : 3
	return icon_y > 16 ? 2 : 4

/atom/movable/screen/mood/rogue
	name = "sanity"
	icon = ROGUE_HUD_ICON
	icon_state = "mood_idle"
	screen_loc = rogueui_stress
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/mood/rogue/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	underlays += mutable_appearance(icon, "stressback")
	var/mob/owner = hud_owner?.mymob
	if(owner)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/atom/movable/screen/mood/rogue/Click(location, control, params)
	. = ..()
	if(!rogue_has_click_listener())
		rogue_hud_not_implemented(usr)

/atom/movable/screen/mood/rogue/proc/on_stat_change(datum/source)
	SIGNAL_HANDLER
	update_from_mood()

/atom/movable/screen/mood/rogue/proc/update_from_mood()
	var/mob/living/owner = get_mob()
	color = null
	if(!istype(owner))
		icon_state = "mood_idle"
		return
	var/static/list/level_states = list("stress4", "stress3", "stress2", "stress", "mood_idle", "peace", "peace2", "peace3", "mood_nirvana")
	var/state = "mood_idle"
	if(owner.mob_mood)
		state = level_states[clamp(owner.mob_mood.mood_level, 1, length(level_states))]
	if(owner.get_drunk_amount() >= 1)
		state = "mood_drunkorhigh"
	if(owner.stat == DEAD)
		state = "mood_dead"
	else if(owner.IsSleeping())
		state = "mood_sleep"
	else if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		if(carbon_owner.disgust >= DISGUST_LEVEL_DISGUSTED)
			state = "mood_sick"
	icon_state = state

/atom/movable/screen/healths/rogue
	name = "life"
	icon = ROGUE_HUD_ICON_HEAT
	icon_state = "dam0"
	screen_loc = rogueui_blood
	layer = ROGUE_HUD_LAYER
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/healths/rogue/Click(location, control, params)
	var/mob/living/carbon/user = usr
	if(!iscarbon(user) || user != get_mob())
		return
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		// Ratwood healths/blood handle_click(): the people one knows (jobs/known_people.dm).
		if(!user.mind)
			return
		if(length(user.mind.rogue_known_people))
			user.mind.rogue_display_known_people(user)
		else
			to_chat(user, span_warning("I don't know anyone."))
		return
	user.check_self_for_injuries()

/// The heart as Ratwood PR 2546 (trueroguan) draws it: the heart empties with the blood lost, and poison, suffocation
/// and pain show over it, bleeding or not.
/atom/movable/screen/healths/rogue/proc/update_for(mob/living/owner)
	cut_overlays()
	if(owner.stat == DEAD)
		icon_state = "damelse"
		return
	icon_state = heart_state(owner)
	for(var/layer_state in heart_layers(owner))
		add_overlay(layer_state)

/// The heart by the blood lost, in steps of ten percent.
/atom/movable/screen/healths/rogue/proc/heart_state(mob/living/owner)
	var/blood_loss = 0
	if(CAN_HAVE_BLOOD(owner))
		blood_loss = (BLOOD_VOLUME_NORMAL - owner.get_blood_volume(apply_modifiers = TRUE)) / BLOOD_VOLUME_NORMAL * 100
	if(blood_loss <= 0)
		return "dam0"
	var/rounded_loss = round(blood_loss, 10)
	return rounded_loss <= 80 ? "dam[rounded_loss]" : "damelse"

/// The poison, suffocation and pain layers over the heart (PR 2546 get_heart_indicator_state() with its steps).
/atom/movable/screen/healths/rogue/proc/heart_layers(mob/living/owner)
	. = list()
	for(var/layer_state in list(
		heart_layer_state("toxloss", owner.get_tox_loss(), 21, 50),
		heart_layer_state("oxyloss", owner.get_oxy_loss(), 21, 50),
		heart_layer_state("painloss", owner.rogue_heart_pain(), 30, 60),
	))
		if(layer_state)
			. += layer_state

/atom/movable/screen/healths/rogue/proc/heart_layer_state(prefix, value, step40, step60)
	if(value <= 0)
		return null
	if(value >= 100)
		return "[prefix]100"
	if(value >= 80)
		return "[prefix]80"
	if(value >= step60)
		return "[prefix]60"
	if(value >= step40)
		return "[prefix]40"
	return "[prefix]20"

/atom/movable/screen/stamina/rogue
	icon = ROGUE_HUD_ICON_HEAT
	icon_state = "stam100"
	screen_loc = rogueui_fat
	layer = ROGUE_HUD_LAYER
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/stamina/rogue/Click(location, control, params)
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	var/threshold = user.maxHealth - user.crit_threshold
	to_chat(user, span_info("<b>Stamina:</b> [round(max(threshold - user.get_stamina_loss(), 0), 0.1)] / [round(threshold, 0.1)]"))

/atom/movable/screen/stamina/rogue/proc/update_for(mob/living/owner, shown_stamina_loss)
	if(owner.stat == DEAD)
		return
	var/threshold = owner.maxHealth - owner.crit_threshold
	if(isnull(shown_stamina_loss))
		shown_stamina_loss = owner.get_stamina_loss()
	var/fatigue = threshold > 0 ? shown_stamina_loss / threshold : 1
	if(fatigue >= 1)
		icon_state = "stam0"
		return
	var/steps = max(ceil(fatigue * 20) - 1, 0)
	icon_state = "stam[100 - steps * 5]"

/atom/movable/screen/throw_catch/rogue
	icon = ROGUE_HUD_ICON
	icon_state = "catch0"
	screen_loc = rogueui_throw
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/throw_catch/rogue/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/owner = hud_owner?.mymob
	if(owner)
		RegisterSignals(owner, list(COMSIG_LIVING_THROW_MODE_TOGGLE, COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(on_owner_hands_changed))
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/throw_catch/rogue/proc/on_owner_hands_changed(datum/source)
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/throw_catch/rogue/update_icon_state()
	var/mob/living/owner = get_mob()
	var/throwing = istype(owner) && owner.throw_mode ? 1 : 0
	icon_state = "[owner?.get_active_held_item() ? "throw" : "catch"][throwing]"
	return ..()

/atom/movable/screen/rogue/give
	name = "give/take"
	icon_state = "take0"
	screen_loc = rogueui_give
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/give/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/owner = hud_owner?.mymob
	if(owner)
		RegisterSignals(owner, list(COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(on_owner_hands_changed))
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/rogue/give/proc/on_owner_hands_changed(datum/source)
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/rogue/give/update_icon_state()
	var/mob/living/owner = get_mob()
	var/giving = istype(owner) && owner.has_status_effect(/datum/status_effect/offering) ? 1 : 0
	icon_state = "[owner?.get_active_held_item() ? "give" : "take"][giving]"
	return ..()

/atom/movable/screen/rogue/give/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	if(!user.get_active_held_item())
		user.rogue_take_offered()
		return
	user.give()
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/drop/rogue
	icon = ROGUE_HUD_ICON
	icon_state = "act_drop"
	screen_loc = rogueui_drop
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/rest/rogue
	name = "lay down"
	icon = ROGUE_HUD_ICON
	icon_state = "act_rest_down"
	base_icon_state = "act_rest_down"
	screen_loc = rogueui_stance
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/rest/rogue/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/atom/movable/screen/rest/rogue/Click(location, control, params)
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		if(user.looking_vertically == DOWN)
			user.end_look()
		else
			user.look_down()
		return
	user.set_resting(TRUE, silent = FALSE)

/atom/movable/screen/rogue/stand_up
	name = "stand up"
	icon_state = "act_rest_up"
	screen_loc = rogueui_stance
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/stand_up/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		if(user.looking_vertically == UP)
			user.end_look()
		else
			user.look_up()
		return
	user.set_resting(FALSE, silent = FALSE)

/atom/movable/screen/mov_intent/rogue
	name = "sprint mode"
	icon = ROGUE_HUD_ICON
	icon_state = "sprint0"
	screen_loc = rogueui_moves
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/mov_intent/rogue/update_icon_state()
	. = ..()
	var/mob/living/owner = get_mob()
	icon_state = "sprint[istype(owner) && owner.move_intent == MOVE_INTENT_RUN ? 1 : 0]"

/atom/movable/screen/rogue/skills
	name = "skills"
	icon_state = "skills"
	screen_loc = rogueui_skills
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/skills/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		user.rogue_print_traits()
		return
	user.rogue_open_attributes(user)

/atom/movable/screen/craft/rogue
	icon = ROGUE_HUD_ICON
	icon_state = "craft"
	screen_loc = rogueui_craft
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/craft/rogue/Click(location, control, params)
	. = ..()
	if(!rogue_has_click_listener())
		rogue_hud_not_implemented(usr)

/atom/movable/screen/rogue/eye
	name = "eye intent"
	icon_state = "eye"
	screen_loc = rogueui_eye
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rogue/eye/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/owner = hud_owner?.mymob
	if(owner)
		RegisterSignal(owner, COMSIG_MOB_ROGUE_EYE_CHANGED, PROC_REF(refresh))
	update_appearance()

/atom/movable/screen/rogue/eye/proc/refresh()
	SIGNAL_HANDLER
	update_appearance()

/atom/movable/screen/rogue/eye/update_icon_state()
	var/mob/living/owner = get_mob()
	if(!isliving(owner))
		icon_state = "eye"
	else if(owner.rogue_eyes_closed)
		icon_state = "eye_closed"
	else if(owner.rogue_fixed_eye)
		icon_state = "eye_fixed"
	else
		icon_state = "eye"
	return ..()

/atom/movable/screen/rogue/eye/update_overlays()
	. = ..()
	var/mob/living/carbon/human/owner = get_mob()
	if(!istype(owner) || owner.rogue_eyes_closed)
		return
	var/mutable_appearance/iris = mutable_appearance(icon, "o[icon_state]")
	iris.color = owner.eye_color_left
	. += iris

/atom/movable/screen/rogue/eye/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user) || user != get_mob())
		return
	var/list/modifiers = params2list(params)
	user.playsound_local(user, 'sound/machines/click.ogg', 50, FALSE)
	var/was_closed = user.rogue_eyes_closed
	user.rogue_set_eyes_closed(FALSE)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		if(user.looking_vertically == UP)
			user.end_look()
		else
			user.look_up()
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living, rogue_look_around))
		return
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(icon_y >= ROGUE_EYELID_TOP || icon_y <= ROGUE_EYELID_BOTTOM)
		if(!was_closed)
			user.rogue_set_eyes_closed(TRUE)
		return
	user.rogue_toggle_fixed_eye()

/atom/movable/screen/rogue/clickdelay
	name = "click delay"
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ROGUE_HUD_LAYER + 1
	alpha = 230

/atom/movable/screen/rogue/clickdelay/proc/show_delay(delay)
	if(delay <= 0)
		return
	icon_state = "resiswait"
	addtimer(CALLBACK(src, PROC_REF(clear_delay)), delay, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

/atom/movable/screen/rogue/clickdelay/proc/clear_delay()
	icon_state = ""

/atom/movable/screen/rogue/clickdelay/next_move
	screen_loc = rogueui_clickdelay_mid

/atom/movable/screen/rogue/clickdelay/next_move/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/owner = hud_owner?.mymob
	if(owner)
		RegisterSignal(owner, COMSIG_LIVING_CHANGENEXT_MOVE, PROC_REF(on_next_move_changed))

/atom/movable/screen/rogue/clickdelay/next_move/proc/on_next_move_changed(datum/source, next_move)
	SIGNAL_HANDLER
	show_delay(next_move - world.time)

/atom/movable/screen/rogue/clickdelay/left
	screen_loc = rogueui_clickdelay_left

/atom/movable/screen/rogue/clickdelay/right
	screen_loc = rogueui_clickdelay_right

/atom/movable/screen/inventory/hand/rogue
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/inventory/hand/rogue/update_overlays()
	. = ..()
	. -= list("lhandactive", "rhandactive")
	if(held_index && held_index == get_mob()?.active_hand_index)
		. += "hand_active"

/// As Ratwood, a worn thing dragged onto an empty hand goes into it: the only way to take off what a click uses instead (a
/// scabbard draws its blade when clicked, so the sheathed sword's scabbard would never leave the belt).
/atom/movable/screen/inventory/hand/rogue/mouse_drop_receive(atom/dropped, mob/user, params)
	if(!isitem(dropped) || user != get_mob() || !held_index)
		return
	var/obj/item/worn = dropped
	if(worn.loc != user || user.is_holding(worn) || user.get_item_for_held_index(held_index))
		return
	if(!user.can_perform_action(worn, FORBID_TELEKINESIS_REACH))
		return
	user.putItemFromInventoryInHandIfPossible(worn, held_index)

/atom/movable/screen/inventory/rogue
	layer = ROGUE_HUD_LAYER

/atom/movable/screen/inventory/rogue/proc/get_worn_item()
	return get_mob()?.get_item_by_slot(slot_id)

/atom/movable/screen/inventory/rogue/update_icon_state()
	. = ..()
	if(!get_mob() || !slot_id)
		return
	var/obj/item/worn = get_worn_item()
	icon_state = worn ? icon_full : icon_empty
	if(!worn?.uses_integrity || !worn.max_integrity || worn.get_integrity() >= worn.max_integrity)
		return
	icon_state = "slotdmg"
	if(worn.integrity_failure && worn.get_integrity_percentage() <= worn.integrity_failure)
		icon_state = "slotbroke"

/atom/movable/screen/inventory/rogue/add_overlays()
	var/mob/user = get_mob()
	if(!user || !slot_id)
		return
	var/obj/item/holding = user.get_active_held_item()
	if(!holding || get_worn_item())
		return
	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92
	item_overlay.color = holding.mob_can_equip(user, slot_id, disable_warning = TRUE, bypass_equip_delay_self = TRUE) ? "#c5c5c5" : "#fd0279"
	cut_overlay(object_overlay)
	object_overlay = item_overlay
	add_overlay(object_overlay)

/atom/movable/screen/inventory/rogue/indexed
	var/slot_index = 0

/atom/movable/screen/inventory/rogue/indexed/get_worn_item()
	var/mob/living/carbon/human/owner = get_mob()
	return istype(owner) ? owner.get_rogue_indexed(slot_id, slot_index) : null

/atom/movable/screen/inventory/rogue/indexed/Click(location, control, params)
	var/mob/living/carbon/human/owner = get_mob()
	if(!istype(owner))
		return ..()
	owner.aim_rogue_slot(slot_id, slot_index)
	. = ..()
	owner.aim_rogue_slot(slot_id, null)

/atom/movable/screen/inventory/rogue/indexed/add_overlays()
	var/mob/living/carbon/human/owner = get_mob()
	if(!istype(owner))
		return ..()
	owner.aim_rogue_slot(slot_id, slot_index)
	. = ..()
	owner.aim_rogue_slot(slot_id, null)

/atom/movable/screen/inventory/rogue/indexed/ring
	transform = matrix(0.5, 0, 0, 0, 0.5, 0)

GLOBAL_LIST_INIT(rogue_precise_zone_map, list(
	"head" = BODY_ZONE_HEAD,
	"skull" = BODY_ZONE_HEAD,
	"nose" = BODY_ZONE_HEAD,
	"ears" = BODY_ZONE_HEAD,
	"neck" = BODY_ZONE_HEAD,
	"r_eye" = BODY_ZONE_PRECISE_EYES,
	"l_eye" = BODY_ZONE_PRECISE_EYES,
	"mouth" = BODY_ZONE_PRECISE_MOUTH,
	"chest" = BODY_ZONE_CHEST,
	"stomach" = BODY_ZONE_CHEST,
	"groin" = BODY_ZONE_PRECISE_GROIN,
	"r_arm" = BODY_ZONE_R_ARM,
	"r_hand" = BODY_ZONE_R_ARM,
	"l_arm" = BODY_ZONE_L_ARM,
	"l_hand" = BODY_ZONE_L_ARM,
	"r_leg" = BODY_ZONE_R_LEG,
	"r_foot" = BODY_ZONE_R_LEG,
	"l_leg" = BODY_ZONE_L_LEG,
	"l_foot" = BODY_ZONE_L_LEG,
))

/mob
	var/rogue_zone_precise

/mob/proc/rogue_precise_zone()
	if(rogue_zone_precise && GLOB.rogue_precise_zone_map[rogue_zone_precise] == zone_selected)
		return rogue_zone_precise
	return zone_selected

/atom/movable/screen/zone_sel/rogue
	icon = ROGUE_HUD_ICON_64
	icon_state = "m-zone_sel"
	screen_loc = rogueui_targetdoll
	layer = ROGUE_HUD_LAYER
	overlay_icon = null
	var/static/list/rogue_hover_cache = list()
	var/static/list/zone_parts
	var/limb_state_key

/atom/movable/screen/zone_sel/rogue/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/mob/living/carbon/user = usr
		if(iscarbon(user) && user == get_mob())
			user.check_self_for_injuries()
		return
	if(isobserver(usr))
		return
	var/part = get_rogue_zone_at(text2num(LAZYACCESS(modifiers, ICON_X)), text2num(LAZYACCESS(modifiers, ICON_Y)))
	var/mob/owner = get_mob()
	if(!part || usr != owner)
		return TRUE
	owner.rogue_zone_precise = part
	set_selected_zone(GLOB.rogue_precise_zone_map[part], usr)
	update_appearance()
	return TRUE

/atom/movable/screen/zone_sel/rogue/MouseMove(location, control, params)
	if(isobserver(usr))
		return
	var/list/modifiers = params2list(params)
	var/part = get_rogue_zone_at(text2num(LAZYACCESS(modifiers, ICON_X)), text2num(LAZYACCESS(modifiers, ICON_Y)))
	var/choice = part ? "[body_prefix()]_[part]" : null
	if(hovering == choice)
		return
	vis_contents -= rogue_hover_cache[hovering]
	hovering = choice
	if(!choice)
		return
	var/obj/effect/overlay/zone_sel/rogue/overlay_object = rogue_hover_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = choice
		rogue_hover_cache[choice] = overlay_object
	vis_contents += overlay_object

/atom/movable/screen/zone_sel/rogue/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= rogue_hover_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/rogue/get_zone_at(icon_x, icon_y)
	return GLOB.rogue_precise_zone_map[get_rogue_zone_at(icon_x, icon_y)]

/atom/movable/screen/zone_sel/rogue/proc/get_zone_parts(zone)
	if(!zone_parts)
		zone_parts = list()
		for(var/part in GLOB.rogue_precise_zone_map)
			LAZYADDASSOCLIST(zone_parts, GLOB.rogue_precise_zone_map[part], part)
	return zone_parts[zone] || list(zone)

/atom/movable/screen/zone_sel/rogue/proc/body_prefix()
	var/mob/owner = get_mob()
	var/body_type = owner?.gender
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		body_type = human_owner.physique
	return body_type == FEMALE ? "f" : "m"

/atom/movable/screen/zone_sel/rogue/update_icon_state()
	icon_state = "[body_prefix()]-zone_sel"
	return ..()

/atom/movable/screen/zone_sel/rogue/update_overlays()
	. = ..()
	var/mob/owner = get_mob()
	if(!owner)
		return
	var/prefix = body_prefix()
	. += limb_overlays(owner, prefix)
	var/list/selected_parts = GLOB.rogue_precise_zone_map[owner.rogue_zone_precise] == owner.zone_selected ? list(owner.rogue_zone_precise) : get_zone_parts(owner.zone_selected)
	for(var/part in selected_parts)
		var/mutable_appearance/selection = mutable_appearance(icon, "[prefix]_[part]")
		selection.layer = layer + 0.2
		. += selection

/atom/movable/screen/zone_sel/rogue/proc/limb_overlays(mob/owner, prefix)
	. = list()
	if(!ishuman(owner) || owner.stat == DEAD)
		return
	var/mob/living/carbon/human/human_owner = owner
	var/no_pain = HAS_TRAIT(human_owner, TRAIT_ANALGESIA)
	for(var/zone in GLOB.all_body_zones)
		var/obj/item/bodypart/limb = human_owner.get_bodypart(zone)
		var/mutable_appearance/limb_layer = mutable_appearance(icon, "[prefix]-[zone]")
		limb_layer.layer = layer + 0.1
		if(!limb)
			limb_layer.color = "#2f002f"
			. += limb_layer
			continue
		var/damage = min(limb.get_damage(), limb.max_damage)
		var/bleeding = limb.cached_bleed_rate > 0
		if(no_pain && (damage || bleeding))
			limb_layer.color = "#78a8ba"
		. += limb_layer
		if(!no_pain && damage)
			var/mutable_appearance/wound_layer = mutable_appearance(icon, "[prefix]w-[zone]")
			wound_layer.layer = layer + 0.11
			wound_layer.alpha = clamp(round(damage / limb.max_damage * 510), 0, 255)
			. += wound_layer
		if(bleeding)
			var/mutable_appearance/bleed_layer = mutable_appearance(icon, "[prefix]-[zone]-bleed")
			bleed_layer.layer = layer + 0.12
			. += bleed_layer

/atom/movable/screen/zone_sel/rogue/proc/refresh_limbs()
	var/mob/living/carbon/human/owner = get_mob()
	if(!istype(owner))
		return
	var/list/state = list(owner.stat, body_prefix(), HAS_TRAIT(owner, TRAIT_ANALGESIA))
	for(var/zone in GLOB.all_body_zones)
		var/obj/item/bodypart/limb = owner.get_bodypart(zone)
		state += limb ? "[round(limb.get_damage())]:[limb.cached_bleed_rate > 0]" : "missing"
	var/new_key = jointext(state, "|")
	if(new_key == limb_state_key)
		return
	limb_state_key = new_key
	update_appearance()

/atom/movable/screen/zone_sel/rogue/proc/get_rogue_zone_at(icon_x, icon_y)
	if(body_prefix() == "f")
		return get_female_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 5)
			switch(icon_x)
				if(17 to 28)
					return "r_foot"
				if(38 to 49)
					return "l_foot"
		if(6 to 15)
			switch(icon_x)
				if(20 to 29)
					return "r_leg"
				if(37 to 46)
					return "l_leg"
		if(16 to 21)
			switch(icon_x)
				if(12 to 18)
					return "r_hand"
				if(20 to 29)
					return "r_leg"
				if(37 to 46)
					return "l_leg"
				if(48 to 54)
					return "l_hand"
		if(22 to 24)
			switch(icon_x)
				if(12 to 18)
					return "r_hand"
				if(20 to 29)
					return "r_leg"
				if(30 to 36)
					return "groin"
				if(37 to 46)
					return "l_leg"
				if(48 to 54)
					return "l_hand"
		if(25 to 29)
			switch(icon_x)
				if(16 to 22)
					return "r_arm"
				if(27 to 39)
					return "stomach"
				if(44 to 50)
					return "l_arm"
		if(30 to 38)
			switch(icon_x)
				if(16 to 22)
					return "r_arm"
				if(24 to 42)
					return "chest"
				if(44 to 50)
					return "l_arm"
		if(39)
			if(icon_x in 29 to 37)
				return "neck"
		if(40 to 46)
			if(icon_x in 27 to 39)
				if((icon_y in 40 to 41) && (icon_x in 29 to 37))
					return "neck"
				if((icon_y in 42 to 44) && (icon_x in 32 to 34))
					return "mouth"
				if(icon_y == 46 && (icon_x in 32 to 34))
					return "nose"
				return "head"
		if(47 to 50)
			switch(icon_x)
				if(24 to 26)
					return "ears"
				if(27 to 39)
					if(icon_y in 49 to 50)
						if(icon_x in 30 to 32)
							return "r_eye"
						if(icon_x in 34 to 36)
							return "l_eye"
					if((icon_y in 47 to 48) && (icon_x in 32 to 34))
						return "nose"
					return "head"
				if(40 to 42)
					return "ears"
		if(51 to 55)
			if(icon_x in 27 to 39)
				if(icon_y == 51)
					if(icon_x in 30 to 32)
						return "r_eye"
					if(icon_x in 34 to 36)
						return "l_eye"
				if((icon_y in 53 to 55) && (icon_x in 29 to 37))
					return "skull"
				return "head"

/atom/movable/screen/zone_sel/rogue/proc/get_female_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 7)
			switch(icon_x)
				if(26 to 32)
					return "r_foot"
				if(34 to 40)
					return "l_foot"
		if(8 to 16)
			switch(icon_x)
				if(24 to 31)
					return "r_leg"
				if(35 to 42)
					return "l_leg"
		if(17 to 20)
			switch(icon_x)
				if(20 to 23)
					return "r_hand"
				if(24 to 31)
					return "r_leg"
				if(35 to 42)
					return "l_leg"
				if(43 to 46)
					return "l_hand"
		if(21)
			switch(icon_x)
				if(20 to 23)
					return "r_hand"
				if(30 to 36)
					return "groin"
				if(43 to 46)
					return "l_hand"
		if(22 to 23)
			switch(icon_x)
				if(20 to 25)
					return "r_arm"
				if(30 to 36)
					return "groin"
				if(41 to 46)
					return "l_arm"
		if(24 to 29)
			switch(icon_x)
				if(20 to 25)
					return "r_arm"
				if(28 to 38)
					return "stomach"
				if(41 to 46)
					return "l_arm"
		if(30 to 37)
			switch(icon_x)
				if(20 to 25)
					return "r_arm"
				if(27 to 39)
					return "chest"
				if(41 to 46)
					return "l_arm"
		if(38 to 39)
			if(icon_x in 30 to 36)
				return "neck"
		if(40 to 43)
			if(icon_x in 28 to 38)
				if(icon_y == 40 && (icon_x in 30 to 36))
					return "neck"
				if((icon_y in 41 to 43) && (icon_x in 32 to 34))
					return "mouth"
				return "head"
		if(44 to 47)
			switch(icon_x)
				if(26 to 27)
					return "ears"
				if(28 to 38)
					if((icon_y in 44 to 46) && (icon_x in 32 to 34))
						return "nose"
					if(icon_y == 47)
						if(icon_x in 30 to 32)
							return "r_eye"
						if(icon_x in 34 to 36)
							return "l_eye"
					return "head"
				if(39 to 40)
					return "ears"
		if(48 to 51)
			if(icon_x in 28 to 38)
				if(icon_y in 48 to 49)
					if(icon_x in 30 to 32)
						return "r_eye"
					if(icon_x in 34 to 36)
						return "l_eye"
				if((icon_y in 50 to 51) && (icon_x in 30 to 36))
					return "skull"
				return "head"
		if(52)
			if(icon_x in 30 to 36)
				return "skull"

/obj/effect/overlay/zone_sel/rogue
	icon = ROGUE_HUD_ICON_64
	plane = HUD_PLANE
	layer = ROGUE_HUD_LAYER + 0.15
