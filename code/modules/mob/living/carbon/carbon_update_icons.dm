/mob/living/carbon/human/update_clothing(slot_flags)
	if(slot_flags & ITEM_SLOT_BACK)
		update_worn_back()
	if(slot_flags & ITEM_SLOT_MASK)
		update_worn_mask()
	if(slot_flags & ITEM_SLOT_NECK)
		update_worn_neck()
	if(slot_flags & ITEM_SLOT_HANDCUFFED)
		update_worn_handcuffs()
	if(slot_flags & ITEM_SLOT_LEGCUFFED)
		update_worn_legcuffs()
	if(slot_flags & ITEM_SLOT_BELT)
		update_worn_belt()
	if(slot_flags & ITEM_SLOT_ID)
		update_worn_id()
	if(slot_flags & ITEM_SLOT_EARS)
		update_inv_ears()
	if(slot_flags & ITEM_SLOT_EYES)
		update_worn_glasses()
	if(slot_flags & ITEM_SLOT_GLOVES)
		update_worn_gloves()
	if(slot_flags & ITEM_SLOT_HEAD)
		update_worn_head()
	if(slot_flags & ITEM_SLOT_FEET)
		update_worn_shoes()
	if(slot_flags & ITEM_SLOT_OCLOTHING)
		update_worn_oversuit()
	if(slot_flags & ITEM_SLOT_ICLOTHING)
		update_worn_undersuit()
	if(slot_flags & ITEM_SLOT_SUITSTORE)
		update_suit_storage()
	if(slot_flags & ITEM_SLOT_LPOCKET || slot_flags & ITEM_SLOT_RPOCKET)
		update_pockets()

//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/perform_update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying_angle != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev , lying_angle)
		if(!lying_angle) //Lying to standing
			final_pixel_y = base_pixel_y
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = base_pixel_y
				final_pixel_y = base_pixel_y + PIXEL_Y_OFFSET_LYING
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)
		animate(src, transform = ntransform, time = (lying_prev == 0 || lying_angle == 0) ? 2 : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))

/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna.species.handle_mutant_bodyparts(src)
	update_body_parts()

/mob/living/carbon/update_body(is_creating = FALSE)
	dna.species.handle_body(src) //This calls `handle_mutant_bodyparts` which calls `update_mutant_bodyparts()`. Don't double call!
	update_body_parts(is_creating)

/mob/living/carbon/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	update_z_overlays(GET_TURF_PLANE_OFFSET(new_turf), TRUE)

/mob/living/carbon/proc/refresh_loop(iter_cnt, rebuild = FALSE)
	for(var/i in 1 to iter_cnt)
		update_z_overlays(1, rebuild)
		sleep(3)
		update_z_overlays(0, rebuild)
		sleep(3)

#define NEXT_PARENT_COMMAND "next_parent"
/// Takes a list of mutable appearances
/// Returns a list in the form:
/// 1 - a list of all mutable appearances that would need to be updated to change planes in the event of a z layer change, alnongside the commands required
/// 	to properly track parents to update
/// 2 - a list of all parents that will require updating
/proc/build_planeed_apperance_queue(list/mutable_appearance/appearances)
	var/list/queue
	if(islist(appearances))
		queue = appearances.Copy()
	else
		queue = list(appearances)
	var/queue_index = 0
	var/list/parent_queue = list()

	// We are essentially going to unroll apperance overlays into a flattened list here, so we can filter out floating planes laster
	// It will look like "overlay overlay overlay (change overlay parent), overlay overlay etc"
	// We can use this list to dynamically update these non floating planes, later
	while(queue_index < length(queue))
		queue_index++
		// If it's not a command, we assert that it's an appearance
		var/mutable_appearance/appearance = queue[queue_index]
		if(!appearance || appearance == NEXT_PARENT_COMMAND) // Who fucking adds nulls to their sublists god you people are the worst
			continue

		var/mutable_appearance/new_appearance = new /mutable_appearance()
		new_appearance.appearance = appearance
		// Now check its children
		if(length(appearance.overlays))
			queue += NEXT_PARENT_COMMAND
			parent_queue += appearance
			for(var/mutable_appearance/child_appearance as anything in appearance.overlays)
				queue += child_appearance

	// Now we have a flattened list of parents and their children
	// Setup such that walking the list backwards will allow us to properly update overlays
	// (keeping in mind that overlays only update if an apperance is removed and added, and this pattern applies in a nested fashion)

	// If we found no results, return null
	if(!length(queue))
		return null

	// ALRIGHT MOTHERFUCKER
	// SO
	// DID YOU KNOW THAT OVERLAY RENDERING BEHAVIOR DEPENDS PARTIALLY ON THE ORDER IN WHICH OVERLAYS ARE ADDED?
	// WHAT WE'RE DOING HERE ENDS UP REVERSING THE OVERLAYS ADDITION ORDER (when it's walked back to front)
	// SO GUESS WHAT I'VE GOTTA DO, I'VE GOTTA SWAP ALLLL THE MEMBERS OF THE SUBLISTS
	// I HATE IT HERE
	var/lower_parent = 0
	var/upper_parent = 0
	var/queue_size = length(queue)
	while(lower_parent <= queue_size)
		// Let's reorder our "lists" (spaces between parent changes)
		// We've got a delta index, and we're gonna essentially use it to get "swap" positions from the top and bottom
		// We only need to loop over half the deltas to swap all the entries, any more and it'd be redundant
		// We floor so as to avoid over flipping, and ending up flipping "back" a delta
		// etc etc
		var/target = FLOOR((upper_parent - lower_parent) / 2, 1)
		for(var/delta_index in 1 to target)
			var/old_lower = queue[lower_parent + delta_index]
			queue[lower_parent + delta_index] = queue[upper_parent - delta_index]
			queue[upper_parent - delta_index] = old_lower

		// lower bound moves to the old upper, upper bound finds a new home
		// Note that the end of the list is a valid upper bound
		lower_parent = upper_parent // our old upper bound is now our lower bound
		while(upper_parent <= queue_size)
			upper_parent += 1
			if(length(queue) < upper_parent) // Parent found
				break
			if(queue[upper_parent] == NEXT_PARENT_COMMAND) // We found em lads
				break

	// One more thing to do
	// It's much more convinient for the parent queue to be a list of indexes pointing at queue locations
	// Rather then a list of copied appearances
	// Let's turn what we have now into that yeah?
	// This'll require a loop over both queues
	// We're using an assoc list here rather then several find()s because I feel like that's more sane
	var/list/apperance_to_position = list()
	for(var/i in 1 to length(queue))
		apperance_to_position[queue[i]] = i

	var/list/parent_indexes = list()
	for(var/mutable_appearance/parent as anything in parent_queue)
		parent_indexes += apperance_to_position[parent]

	// Alright. We should now have two queues, a command/appearances one, and a parents queue, which contain no fluff
	// And when walked backwards allow for proper plane updating
	var/list/return_pack = list(queue, parent_indexes)
	return return_pack

// Rebuilding is a hack. We should really store a list of indexes into our existing overlay list or SOMETHING
// IDK. will work for now though, which is a lot better then not working at all
/mob/living/carbon/proc/update_z_overlays(new_offset, rebuild = FALSE)
	// Null entries will be filtered here
	for(var/i in 1 to length(overlays_standing))
		var/list/cache_grouping = overlays_standing[i]
		if(cache_grouping && !islist(cache_grouping))
			cache_grouping = list(cache_grouping)
		// Need this so we can have an index, could build index into the list if we need to tho, check
		if(!length(cache_grouping))
			continue
		overlays_standing[i] = update_appearance_planes(cache_grouping, new_offset)

/atom/proc/update_appearance_planes(list/mutable_appearance/appearances, new_offset)
	var/list/build_list = build_planeed_apperance_queue(appearances)

	if(!length(build_list))
		return appearances

	// hand_back contains a new copy of the passed in list, with updated values
	var/list/hand_back = list()

	var/list/processing_queue = build_list[1]
	var/list/parents_queue = build_list[2]
	// Now that we have our queues, we're going to walk them forwards to remove, and backwards to add
	// Note, we need to do this separately because you can only remove a mutable appearance when it
	// Exactly matches the appearance it had when it was first "made static" (by being added to the overlays list)
	var/parents_index = 0
	for(var/item in processing_queue)
		if(item == NEXT_PARENT_COMMAND)
			parents_index++
			continue
		var/mutable_appearance/iter_apper = item
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays -= iter_apper.appearance
		else // Otherwise, we're at the end of the list, and our parent is the mob
			cut_overlay(iter_apper)

	// Now the back to front stuff, to readd the updated appearances
	var/queue_index = length(processing_queue)
	parents_index = length(parents_queue)
	while(queue_index >= 1)
		var/item = processing_queue[queue_index]
		if(item == NEXT_PARENT_COMMAND)
			parents_index--
			queue_index--
			continue
		var/mutable_appearance/new_iter = new /mutable_appearance()
		new_iter.appearance = item
		if(new_iter.plane != FLOAT_PLANE)
			// Here, finally, is where we actually update the plane offsets
			SET_PLANE_W_SCALAR(new_iter, PLANE_TO_TRUE(new_iter.plane), new_offset)
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays += new_iter.appearance
		else
			add_overlay(new_iter)
			// chant a protective overlays.Copy to prevent appearance theft and overlay sticking
			// I'm not joking without this overlays can corrupt and be replaced by other appearances
			// the compiler might call it useless but I swear it works
			// we conjure the spirits of the computer with our spells, we conjur- (Hey lemon make a damn issue report already)
			var/list/does_nothing = new_iter.overlays.Copy()
			pass(does_nothing)
			hand_back += new_iter

		queue_index--
	return hand_back

#undef NEXT_PARENT_COMMAND

/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	icon_render_keys = list() //Clear this bad larry out
	update_held_items()
	update_worn_handcuffs()
	update_worn_legcuffs()
	update_fire()
	update_body()

/mob/living/carbon/update_held_items()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(length(observers))
				for(var/mob/dead/observe as anything in observers)
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/icon_file = I.lefthand_file
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file

		hands += I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)

/mob/living/carbon/update_fire_overlay(stacks, on_fire, last_icon_state, suffix = "")
	var/fire_icon = "[dna?.species.fire_overlay || "human"]_[stacks > MOB_BIG_FIRE_STACK_THRESHOLD ? "big_fire" : "small_fire"][suffix]"

	if(!GLOB.fire_appearances[fire_icon])
		GLOB.fire_appearances[fire_icon] = mutable_appearance('icons/mob/effects/onfire.dmi', fire_icon, -FIRE_LAYER, appearance_flags = RESET_COLOR)

	if((stacks > 0 && on_fire) || HAS_TRAIT(src, TRAIT_PERMANENTLY_ONFIRE))
		if(fire_icon == last_icon_state)
			return last_icon_state

		remove_overlay(FIRE_LAYER)
		overlays_standing[FIRE_LAYER] = GLOB.fire_appearances[fire_icon]
		apply_overlay(FIRE_LAYER)
		return fire_icon

	if(!last_icon_state)
		return last_icon_state

	remove_overlay(FIRE_LAYER)
	apply_overlay(FIRE_LAYER)
	return null

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/effects/dam_mob.dmi', "blank", -DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		if(iter_part.dmg_overlay_type)
			if(iter_part.brutestate)
				damage_overlay.add_overlay("[iter_part.dmg_overlay_type]_[iter_part.body_zone]_[iter_part.brutestate]0") //we're adding icon_states of the base image as overlays
			if(iter_part.burnstate)
				damage_overlay.add_overlay("[iter_part.dmg_overlay_type]_[iter_part.body_zone]_0[iter_part.burnstate]")

	apply_overlay(DAMAGE_LAYER)

/mob/living/carbon/update_wound_overlays()
	remove_overlay(WOUND_LAYER)

	var/mutable_appearance/wound_overlay = mutable_appearance('icons/mob/effects/bleed_overlays.dmi', "blank", -WOUND_LAYER)
	overlays_standing[WOUND_LAYER] = wound_overlay

	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		if(iter_part.bleed_overlay_icon)
			wound_overlay.add_overlay(iter_part.bleed_overlay_icon)

	apply_overlay(WOUND_LAYER)

/mob/living/carbon/update_worn_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_appearance()

	if(wear_mask)
		if(!(check_obscured_slots() & ITEM_SLOT_MASK))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_worn_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_appearance()

	if(wear_neck)
		if(!(check_obscured_slots() & ITEM_SLOT_NECK))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck.dmi')
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_worn_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_appearance()

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/mob/clothing/back.dmi')
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_worn_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_appearance()

	if(head)
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_worn_handcuffs()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		var/mutable_appearance/handcuff_overlay = mutable_appearance('icons/mob/simple/mob.dmi', "handcuff1", -HANDCUFF_LAYER)
		if(handcuffed.blocks_emissive)
			handcuff_overlay.overlays += emissive_blocker(handcuff_overlay.icon, handcuff_overlay.icon_state, src, alpha = handcuff_overlay.alpha)

		overlays_standing[HANDCUFF_LAYER] = handcuff_overlay
		apply_overlay(HANDCUFF_LAYER)


//mob HUD updates for items in our inventory

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		for(var/hand in hud_used.hand_slots)
			var/atom/movable/screen/inventory/hand/H = hud_used.hand_slots[hand]
			if(H)
				H.update_appearance()

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our neck item appears on our hud.
/mob/living/carbon/proc/update_hud_neck(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return



//Overlays for the worn overlay so you can overlay while you overlay
//eg: ammo counters, primed grenade flashing, etc.
//"icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	if(!blocks_emissive)
		return

	. += emissive_blocker(standing.icon, standing.icon_state, src, alpha = standing.alpha)

///Checks to see if any bodyparts need to be redrawn, then does so. update_limb_data = TRUE redraws the limbs to conform to the owner.
/mob/living/carbon/proc/update_body_parts(update_limb_data)
	update_damage_overlays()
	update_wound_overlays()
	var/list/needs_update = list()
	var/limb_count_update = FALSE
	var/obj/item/bodypart/l_leg/left_leg
	var/obj/item/bodypart/r_leg/right_leg
	var/old_left_leg_key
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.update_limb(is_creating = update_limb_data) //Update limb actually doesn't do much, get_limb_icon is the cpu eater.

		if(limb.body_zone == BODY_ZONE_R_LEG)
			right_leg = limb
			continue // Legs are handled separately

		var/old_key = icon_render_keys?[limb.body_zone] //Checks the mob's icon render key list for the bodypart
		icon_render_keys[limb.body_zone] = (limb.is_husked) ? limb.generate_husk_key().Join() : limb.generate_icon_key().Join() //Generates a key for the current bodypart

		if(limb.body_zone == BODY_ZONE_L_LEG)
			left_leg = limb
			old_left_leg_key = old_key
			continue // Legs are handled separately

		if(icon_render_keys[limb.body_zone] != old_key) //If the keys match, that means the limb doesn't need to be redrawn
			needs_update += limb


	// Here we handle legs differently, because legs are a mess due to layering code. So we got to process the left leg first. Thanks BYOND.
	var/legs_need_redrawn = update_legs(right_leg, left_leg, old_left_leg_key)

	var/list/missing_bodyparts = get_missing_limbs()
	if(((dna ? dna.species.max_bodypart_count : BODYPARTS_DEFAULT_MAXIMUM) - icon_render_keys.len) != missing_bodyparts.len) //Checks to see if the target gained or lost any limbs.
		limb_count_update = TRUE
		for(var/missing_limb in missing_bodyparts)
			icon_render_keys -= missing_limb //Removes dismembered limbs from the key list

	if(!needs_update.len && !limb_count_update && !legs_need_redrawn)
		return


	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb in needs_update) //Checks to see if the limb needs to be redrawn
			var/bodypart_icon = limb.get_limb_icon()
			new_limbs += bodypart_icon
			limb_icon_cache[icon_render_keys[limb.body_zone]] = bodypart_icon //Caches the icon with the bodypart key, as it is new
		else
			new_limbs += limb_icon_cache[icon_render_keys[limb.body_zone]] //Pulls existing sprites from the cache

	remove_overlay(BODYPARTS_LAYER)

	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs

	apply_overlay(BODYPARTS_LAYER)


/**
 * Here we update the legs separately from the other bodyparts. Thanks BYOND for so little support for dir layering.
 *
 * Arguments:
 * * right_leg - Right leg that we might need to update. Can be null.
 * * left_leg - Left leg that we might need to update. Can be null.
 * * old_left_leg_key - The icon_key of the left_leg, passed here to avoid having to re-generate it in this proc.
 *
 * Returns a boolean, TRUE if the legs need to be redrawn, FALSE if they do not need to be redrawn.
 * Necessary so that we can ensure that modifications of legs cause overlay updates.
 */
/mob/living/carbon/proc/update_legs(obj/item/bodypart/r_leg/right_leg, obj/item/bodypart/l_leg/left_leg, old_left_leg_key)
	var/list/left_leg_icons // yes it's actually a list, bet you didn't expect that, now did you?
	var/legs_need_redrawn = FALSE
	if(left_leg)
		// We regenerate the look of the left leg if it isn't already cached, we don't if not.
		if(icon_render_keys[left_leg.body_zone] != old_left_leg_key)
			limb_icon_cache[icon_render_keys[left_leg.body_zone]] = left_leg.get_limb_icon()
			legs_need_redrawn = TRUE

		left_leg_icons = limb_icon_cache[icon_render_keys[left_leg.body_zone]]

	if(right_leg)
		var/old_right_leg_key = icon_render_keys?[right_leg.body_zone]
		right_leg.left_leg_mask_key = left_leg?.generate_mask_key().Join() // We generate a new mask key, to see if it changed.
		// We regenerate the left_leg_mask in case that it doesn't exist yet.
		if(right_leg.left_leg_mask_key && !right_leg.left_leg_mask_cache[right_leg.left_leg_mask_key] && left_leg_icons)
			right_leg.left_leg_mask_cache[right_leg.left_leg_mask_key] = generate_left_leg_mask(left_leg_icons[1], right_leg.left_leg_mask_key)
		// We generate a new icon_render_key, which also takes into account the left_leg_mask_key so we cache the masked versions of the limbs too.
		icon_render_keys[right_leg.body_zone] = right_leg.is_husked ? right_leg.generate_husk_key().Join("-") : right_leg.generate_icon_key().Join()

		if(icon_render_keys[right_leg.body_zone] != old_right_leg_key)
			limb_icon_cache[icon_render_keys[right_leg.body_zone]] = right_leg.get_limb_icon()
			legs_need_redrawn = TRUE

	return legs_need_redrawn


/////////////////////////
// Limb Icon Cache 2.0 //
/////////////////////////
/**
 * Called from update_body_parts() these procs handle the limb icon cache.
 * the limb icon cache adds an icon_render_key to a human mob, it represents:
 * - Gender, if applicable
 * - The ID of the limb
 * - Draw color, if applicable
 * These procs only store limbs as to increase the number of matching icon_render_keys
 * This cache exists because drawing 6/7 icons for humans constantly is quite a waste
 * See RemieRichards on irc.rizon.net #coderbus (RIP remie :sob:)
**/
/obj/item/bodypart/proc/generate_icon_key()
	RETURN_TYPE(/list)
	. = list()
	if(is_dimorphic)
		. += "[limb_gender]-"
	. += "[limb_id]"
	. += "-[body_zone]"
	if(should_draw_greyscale && draw_color)
		. += "-[draw_color]"
	if(is_invisible)
		. += "-invisible"
	for(var/obj/item/organ/external/external_organ as anything in external_organs)
		if(!external_organ.can_draw_on_bodypart(owner))
			continue
		. += "-[jointext(external_organ.generate_icon_cache(), "-")]"

	return .

/**
 * Generates a cache key for masks (mainly only used for right legs now, but perhaps in the future...).
 *
 * This is exactly like generate_icon_key(), except that it doesn't add `"-[draw_color]"`
 * to the returned list under any circumstance. Why? Because it (generate_icon_key()) is
 * a proc that gets called a ton and I don't want this to affect its performance.
 *
 * Returns a list of strings.
 */
/obj/item/bodypart/proc/generate_mask_key()
	RETURN_TYPE(/list)
	. = list()
	if(is_dimorphic)
		. += "[limb_gender]"
	. += "[limb_id]"
	. += "[body_zone]"
	for(var/obj/item/organ/external/external_organ as anything in external_organs)
		if(!external_organ.can_draw_on_bodypart(owner))
			continue
		. += "[external_organ.generate_icon_cache()]"

	return .

///Generates a cache key specifically for husks
/obj/item/bodypart/proc/generate_husk_key()
	RETURN_TYPE(/list)
	. = list()
	. += "[husk_type]"
	. += "-husk"
	. += "-[body_zone]"
	return .

/obj/item/bodypart/head/generate_icon_key()
	. = ..()
	. += "-[facial_hairstyle]"
	. += "-[facial_hair_color]"
	if(facial_hair_gradient_style)
		. += "-[facial_hair_gradient_style]"
		if(hair_gradient_color)
			. += "-[facial_hair_gradient_color]"
	if(facial_hair_hidden)
		. += "-FACIAL_HAIR_HIDDEN"
	if(is_blushing)
		. += "-IS_BLUSHING"
	if(show_debrained)
		. += "-SHOW_DEBRAINED"
		return .

	. += "-[hair_style]"
	. += "-[fixed_hair_color || override_hair_color || hair_color]"
	if(hair_gradient_style)
		. += "-[hair_gradient_style]"
		if(hair_gradient_color)
			. += "-[hair_gradient_color]"
	if(hair_hidden)
		. += "-HAIR_HIDDEN"

	return .

/obj/item/bodypart/r_leg/generate_icon_key()
	RETURN_TYPE(/list)
	. = ..()
	if(left_leg_mask_key) // We do this so we can cache the versions with and without a mask, for when there's no left leg.
		. += "-[left_leg_mask_key]"

	return .

/**
 * This proc serves as a way to ensure that right legs don't overlap above left legs when their dir is WEST on a mob.
 *
 * It's using the `left_leg_mask_cache` to avoid generating a new mask when unnecessary, which means that there needs to be one
 * for the proc to return anything.
 *
 * Arguments:
 * * right_leg_icon_file - The icon file of the right leg overlay we're trying to apply a mask to.
 * * right_leg_icon_state - The icon_state of the right leg overlay we're trying to apply a mask to.
 * * image_dir - The direction applied to the icon, only meant for when the leg is dropped, so it remains
 * facing SOUTH all the time.
 *
 * Returns the `/image` of the right leg that was masked, or `null` if the mask didn't exist.
 */
/obj/item/bodypart/r_leg/proc/generate_masked_right_leg(right_leg_icon_file, right_leg_icon_state, image_dir)
	RETURN_TYPE(/image)
	if(!left_leg_mask_cache[left_leg_mask_key] || !right_leg_icon_file || !right_leg_icon_state)
		return

	var/icon/right_leg_icon = icon(right_leg_icon_file, right_leg_icon_state)
	right_leg_icon.Blend(left_leg_mask_cache[left_leg_mask_key], ICON_MULTIPLY)
	return image(right_leg_icon, right_leg_icon_state, layer = -BODYPARTS_LAYER, dir = image_dir)


/**
 * The proc that handles generating left leg masks at runtime.
 * It basically creates an icon that are all white on all dirs except WEST, where there's a cutout
 * of the left leg that needed to be masked.
 *
 * It does /not/ cache the mask itself, and as such, the caching must be done manually (which it is, look up in update_body_parts()).
 *
 * Arguments:
 * * image/left_leg_image - `image` of the left leg that we need to create a mask out of.
 *
 * Returns the generated left leg mask as an `/icon`, or `null` if no left_leg_image is provided.
 */
/proc/generate_left_leg_mask(image/left_leg_image)
	RETURN_TYPE(/icon)
	if(!left_leg_image)
		return
	var/icon/left_leg_alpha_mask = generate_icon_alpha_mask(left_leg_image.icon, left_leg_image.icon_state)
	// Right here, we use the crop_mask_icon to single out the WEST sprite of the mask we just created above.
	var/icon/crop_mask_icon = icon(icon = 'icons/mob/left_leg_mask_base.dmi', icon_state = "mask_base")
	crop_mask_icon.Blend(left_leg_alpha_mask, ICON_MULTIPLY)
	// Then, we add (with ICON_OR) that singled-out WEST mask to a template mask that has the NORTH,
	// SOUTH and EAST dirs as full white squares, to finish our WEST-directional mask.
	var/icon/new_mask_icon = icon(icon = 'icons/mob/left_leg_mask_base.dmi', icon_state = "mask_rest")
	new_mask_icon.Blend(crop_mask_icon, ICON_OR)
	return new_mask_icon
