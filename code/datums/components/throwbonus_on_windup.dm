/datum/component/throwbonus_on_windup
	///the maximum windup bonus
	var/maximum_bonus = 20
	///additional behavior if we exceed the maximum bonus
	var/datum/callback/pass_maximum_callback
	///the player currently winding up their throw
	var/datum/weakref/holder
	///the current bonus we are at
	var/throwforce_bonus = 0
	///the bar relaying feedback to the player
	var/obj/effect/overlay/windup_bar/our_bar
	///any additional behavior we should look for before applying the bonus
	var/datum/callback/apply_bonus_callback
	///sound we play after successfully damaging the enemy with a bonus
	var/sound_on_success
	///effect we play after successfully damaging the enemy with a bonus
	var/effect_on_success
	///how fast we increase the wind up counter on process
	var/windup_increment_speed
	///text we display when we start winding up
	var/throw_text

/datum/component/throwbonus_on_windup/Initialize(maximum_bonus = 20, windup_increment_speed = 1, pass_maximum_callback, apply_bonus_callback, sound_on_success, effect_on_success, throw_text)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.maximum_bonus = maximum_bonus
	src.pass_maximum_callback = pass_maximum_callback
	src.apply_bonus_callback = apply_bonus_callback
	src.sound_on_success = sound_on_success
	src.effect_on_success = effect_on_success
	src.windup_increment_speed = windup_increment_speed
	src.throw_text = throw_text

/datum/component/throwbonus_on_windup/proc/on_equip(datum/source, mob/living/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS) || holder?.resolve())
		return
	holder = WEAKREF(equipper)
	RegisterSignal(equipper, COMSIG_LIVING_THROW_MODE_TOGGLE, PROC_REF(throw_change))
	RegisterSignal(equipper, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hands_swap))
	if(equipper.throw_mode)
		start_windup()

/datum/component/throwbonus_on_windup/proc/start_windup()

	throwforce_bonus = initial(throwforce_bonus)
	var/mob/living/our_holder = holder?.resolve()
	if(isnull(holder))
		return
	if(throw_text)
		to_chat(our_holder, span_warning(throw_text))
	var/x_position = CEILING(our_holder.get_visual_width() * 0.5, 1)
	our_bar = new()
	our_bar.maximum_count = maximum_bonus
	our_bar.pixel_x = x_position
	our_holder.vis_contents += our_bar
	START_PROCESSING(SSfastprocess, src)

/datum/component/throwbonus_on_windup/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_IMPACT, PROC_REF(on_thrown))

/datum/component/throwbonus_on_windup/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_PRE_IMPACT))
	var/atom/our_holder = holder?.resolve()
	if(!isnull(our_holder))
		UnregisterSignal(our_holder, list(COMSIG_LIVING_THROW_MODE_TOGGLE, COMSIG_MOB_SWAP_HANDS))

/datum/component/throwbonus_on_windup/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(our_bar)
	holder = null
	return ..()

/datum/component/throwbonus_on_windup/proc/throw_change(datum/source, throw_mode)
	SIGNAL_HANDLER

	if(throw_mode)
		start_windup()
	else
		end_windup()

/datum/component/throwbonus_on_windup/proc/on_hands_swap(mob/living/source)
	SIGNAL_HANDLER

	if(source.get_active_held_item() != parent)
		end_windup()
		return

	if(source.throw_mode)
		start_windup()

/datum/component/throwbonus_on_windup/process(seconds_per_tick)
	if(throwforce_bonus > maximum_bonus)
		var/mob/living/our_holder = holder?.resolve()
		pass_maximum_callback?.Invoke(our_holder)
		end_windup()
		return PROCESS_KILL

	our_bar.recalculate_position(min(throwforce_bonus, maximum_bonus))
	throwforce_bonus += windup_increment_speed

/datum/component/throwbonus_on_windup/proc/on_move(obj/item/source, atom/entering_loc)
	SIGNAL_HANDLER
	end_windup()
	var/mob/living/our_holder = holder?.resolve()
	if(isnull(our_holder))
		return
	holder = null
	UnregisterSignal(our_holder, list(COMSIG_LIVING_THROW_MODE_TOGGLE, COMSIG_MOB_SWAP_HANDS))

/datum/component/throwbonus_on_windup/proc/end_windup()
	QDEL_NULL(our_bar)
	STOP_PROCESSING(SSfastprocess, src)

/datum/component/throwbonus_on_windup/proc/on_thrown(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	var/damage_to_apply = throwforce_bonus
	throwforce_bonus = initial(throwforce_bonus)
	if(!isliving(hit_atom))
		return

	if(apply_bonus_callback && !apply_bonus_callback.Invoke(hit_atom, damage_to_apply))
		return

	if(effect_on_success)
		new effect_on_success(get_turf(hit_atom))
	if(sound_on_success)
		playsound(hit_atom, sound_on_success, 50, TRUE)

	var/mob/living/living_target = hit_atom
	living_target.apply_damage(damage_to_apply)

/obj/effect/overlay/windup_bar
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "windup_bar"
	layer = ABOVE_ALL_MOB_LAYER
	///the maximum windup bonus
	var/maximum_count = INFINITY
	///the current count we are at
	var/current_count = 0

/obj/effect/overlay/windup_bar/proc/recalculate_position(input_count)
	current_count = input_count
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/overlay/windup_bar/update_overlays()
	. = ..()
	var/static/list/bar_positions = list(0, 2, 4, 6, 8)
	var/current_percentage = current_count / maximum_count
	var/bars_to_add = CEILING(length(bar_positions) * current_percentage, 1)
	for(var/curr_number in 1 to bars_to_add)
		var/bar_color
		switch(curr_number)
			if(1 to 2)
				bar_color = "windup_red"
			if(2 to 4)
				bar_color = "windup_green"
			if(4 to 5)
				bar_color = "windup_purple"
		var/mutable_appearance/bar_overlay =  mutable_appearance(icon = icon, icon_state = bar_color, layer = ABOVE_HUD_PLANE)
		bar_overlay.pixel_z = bar_positions[curr_number]
		. += bar_overlay
