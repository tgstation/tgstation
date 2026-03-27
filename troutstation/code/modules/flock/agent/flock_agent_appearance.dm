// mostly stolen from drones like the rest of this
/mob/living/basic/flock/agent/proc/apply_overlay(cache_index)
	if((. = agent_overlays[cache_index]))
		add_overlay(.)

/mob/living/basic/flock/agent/proc/remove_overlay(cache_index)
	var/overlay = agent_overlays[cache_index]
	if(overlay)
		cut_overlay(overlay)
		agent_overlays[cache_index] = null

/mob/living/basic/flock/agent/update_clothing(slot_flags)
	if(slot_flags & ITEM_SLOT_HEAD)
		update_worn_head()
	if(slot_flags & ITEM_SLOT_HANDS)
		update_held_items()
	if(slot_flags & (ITEM_SLOT_HANDS|ITEM_SLOT_DEX_STORAGE))
		update_inv_internal_storage()

/mob/living/basic/flock/agent/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used?.hud_shown)
		internal_storage.screen_loc = ui_flock_storage
		client.screen += internal_storage

/mob/living/basic/flock/agent/update_worn_head()
	remove_overlay(FLOCK_AGENT_HEAD_LAYER)

	if(head)
		if(client && hud_used?.hud_shown)
			head.screen_loc = ui_flock_head
			client.screen += head
		var/used_head_icon = 'icons/mob/clothing/head/utility.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = FLOCK_AGENT_HEAD_LAYER, default_icon_file = used_head_icon)
		var/hat_offset = gear_offsets["hat"]
		head_overlay.pixel_w = hat_offset[1]
		head_overlay.pixel_z = hat_offset[2] + head.worn_y_offset

		agent_overlays[FLOCK_AGENT_HEAD_LAYER] = head_overlay

	apply_overlay(FLOCK_AGENT_HEAD_LAYER)

/mob/living/basic/flock/agent/update_held_items()
	. = ..()
	remove_overlay(FLOCK_AGENT_HANDS_LAYER)

	// the hand gui stuff is handled by the dextrous component. christ this is spaghetti
	// this code itself is stolen from the basic_inhands component, which only supports a fixed offset for all directions
	var/list/held_overlays = list()
	var/left_hand_offset = gear_offsets["left_hand"]
	var/right_hand_offset = gear_offsets["right_hand"]
	for(var/obj/item/held in held_items)
		var/is_right = IS_RIGHT_INDEX(get_held_index_of_item(held))
		var/icon_file = is_right ? held.righthand_file : held.lefthand_file
		var/mutable_appearance/held_overlay = held.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
		held_overlay.pixel_w = is_right ? right_hand_offset[1] : left_hand_offset[1]
		held_overlay.pixel_z = is_right ? right_hand_offset[2] : left_hand_offset[2]
		held_overlays += held_overlay

	agent_overlays[FLOCK_AGENT_HANDS_LAYER] = held_overlays
	apply_overlay(FLOCK_AGENT_HANDS_LAYER)

/mob/living/basic/flock/agent/update_damage_overlays()
	remove_overlay(FLOCK_AGENT_DAMAGE_LAYER)

	// TODO: make sure to return early if we're in crit/repair mode
	if(stat)
		return

	var/mutable_appearance/damage_overlay
	if(health <= maxHealth/2)
		damage_overlay = mutable_appearance('troutstation/icons/mob/simple/flock.dmi', "agent_damage", layer = -DAMAGE_LAYER, appearance_flags = KEEP_TOGETHER)

	if(isnull(damage_overlay))
		return

	agent_overlays[FLOCK_AGENT_DAMAGE_LAYER] = damage_overlay
	apply_overlay(FLOCK_AGENT_DAMAGE_LAYER)

/mob/living/basic/flock/agent/regenerate_icons()
	update_held_items()
	update_worn_head()
	update_inv_internal_storage()
	update_damage_overlays()
