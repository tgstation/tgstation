/// Updates features and clothing attached to a specific limb with limb-specific offsets
/mob/living/carbon/proc/update_features(feature_key)
	switch(feature_key)
		if(OFFSET_UNIFORM)
			update_worn_undersuit()
		if(OFFSET_ID)
			update_worn_id()
		if(OFFSET_GLOVES)
			update_worn_gloves()
		if(OFFSET_GLASSES)
			update_worn_glasses()
		if(OFFSET_EARS)
			update_worn_ears()
		if(OFFSET_SHOES)
			update_worn_shoes()
		if(OFFSET_S_STORE)
			update_suit_storage()
		if(OFFSET_FACEMASK)
			update_worn_mask()
		if(OFFSET_HEAD)
			update_worn_head()
		if(OFFSET_FACE)
			dna?.species?.update_face_offset(src) // updates eye and lipstick icon
			update_worn_mask()
		if(OFFSET_BELT)
			update_worn_belt()
		if(OFFSET_BACK)
			update_worn_back()
		if(OFFSET_SUIT)
			update_worn_oversuit()
		if(OFFSET_NECK)
			update_worn_neck()
		if(OFFSET_HELD)
			update_held_items()

/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)
	SEND_SIGNAL(src, COMSIG_CARBON_APPLY_OVERLAY, cache_index, .)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null
	SEND_SIGNAL(src, COMSIG_CARBON_REMOVE_OVERLAY, cache_index, I)

/mob/living/carbon/update_body(is_creating = FALSE)
	dna?.species.handle_body(src)
	update_body_parts(is_creating)

/mob/living/carbon/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	update_z_overlays(GET_TURF_PLANE_OFFSET(new_turf), TRUE)

/mob/living/carbon/proc/refresh_loop(iter_cnt, rebuild = FALSE)
	for(var/i in 1 to iter_cnt)
		update_z_overlays(1, rebuild)
		sleep(0.3 SECONDS)
		update_z_overlays(0, rebuild)
		sleep(0.3 SECONDS)

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
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	icon_render_keys = list() //Clear this bad larry out
	update_held_items()
	update_worn_handcuffs()
	update_worn_legcuffs()
	update_body()
	update_appearance(UPDATE_OVERLAYS)

/mob/living/carbon/update_held_items()
	. = ..()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	overlays_standing[HANDS_LAYER] = get_held_overlays()
	apply_overlay(HANDS_LAYER)

/// Generate held item overlays
/mob/living/carbon/proc/get_held_overlays()
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
		if(IS_RIGHT_INDEX(get_held_index_of_item(I)))
			icon_file = I.righthand_file

		hands += I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
	return hands

/mob/living/carbon/get_fire_overlay(stacks, on_fire)
	var/fire_icon = "[dna?.species.fire_overlay || "human"]_[stacks > MOB_BIG_FIRE_STACK_THRESHOLD ? "big_fire" : "small_fire"]"

	if(!GLOB.fire_appearances[fire_icon])
		GLOB.fire_appearances[fire_icon] = mutable_appearance(
			'icons/mob/effects/onfire.dmi',
			fire_icon,
			-HIGHEST_LAYER,
			appearance_flags = RESET_COLOR|KEEP_APART,
		)

	return GLOB.fire_appearances[fire_icon]

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		if(!iter_part.dmg_overlay_type)
			continue
		if(isnull(damage_overlay) && (iter_part.brutestate || iter_part.burnstate))
			damage_overlay = mutable_appearance('icons/mob/effects/dam_mob.dmi', "blank", -DAMAGE_LAYER, appearance_flags = KEEP_TOGETHER)
			damage_overlay.color = iter_part.damage_overlay_color
		if(iter_part.brutestate)
			var/mutable_appearance/blood_damage_overlay = mutable_appearance('icons/mob/effects/dam_mob.dmi', "[iter_part.dmg_overlay_type]_[iter_part.body_zone]_[iter_part.brutestate]0", appearance_flags = RESET_COLOR) //we're adding icon_states of the base image as overlays
			blood_damage_overlay.color = get_bloodtype()?.get_damage_color(src)
			var/mutable_appearance/brute_damage_overlay = mutable_appearance('icons/mob/effects/dam_mob.dmi', "[iter_part.dmg_overlay_type]_[iter_part.body_zone]_[iter_part.brutestate]0_overlay", appearance_flags = RESET_COLOR)
			blood_damage_overlay.overlays += brute_damage_overlay
			damage_overlay.add_overlay(blood_damage_overlay)
		if(iter_part.burnstate)
			damage_overlay.add_overlay("[iter_part.dmg_overlay_type]_[iter_part.body_zone]_0[iter_part.burnstate]")

	if(isnull(damage_overlay))
		return

	overlays_standing[DAMAGE_LAYER] = damage_overlay
	apply_overlay(DAMAGE_LAYER)

/// Handles bleeding overlays
/mob/living/carbon/proc/update_wound_overlays()
	remove_overlay(WOUND_LAYER)

	var/datum/blood_type/blood_type = get_bloodtype()
	if(!blood_type || !can_bleed())
		return

	var/mutable_appearance/wound_overlay
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		if(iter_part.bleed_overlay_icon)
			var/mutable_appearance/blood_overlay = mutable_appearance('icons/mob/effects/bleed_overlays.dmi', "blank", -WOUND_LAYER, appearance_flags = KEEP_TOGETHER)
			blood_overlay.color = blood_type.get_wound_color(src)
			wound_overlay ||= blood_overlay
			wound_overlay.add_overlay(iter_part.bleed_overlay_icon)

	if(isnull(wound_overlay))
		return

	overlays_standing[WOUND_LAYER] = wound_overlay
	apply_overlay(WOUND_LAYER)

/mob/living/carbon/update_worn_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_appearance()

	if(wear_mask)
		if(!(obscured_slots & HIDEMASK))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_worn_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_appearance()

	if(wear_neck)
		if(!(obscured_slots & HIDENECK))
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

/mob/living/carbon/update_worn_legcuffs()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = mutable_appearance('icons/mob/simple/mob.dmi', "legcuff1", -LEGCUFF_LAYER)
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /atom/movable/screen/alert/restrained/legcuffed, new_master = src.legcuffed)

/mob/living/carbon/update_worn_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_appearance()

	if(head)
		if(!(obscured_slots & HIDEHEADGEAR))
			overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_worn_handcuffs()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		var/mutable_appearance/handcuff_overlay = mutable_appearance('icons/mob/simple/mob.dmi', "handcuff1", -HANDCUFF_LAYER)
		if(handcuffed.blocks_emissive != EMISSIVE_BLOCK_NONE)
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

/// Overlays for the worn overlay so you can overlay while you overlay
/// eg: ammo counters, primed grenade flashing, etc.
/// "icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	if(blocks_emissive != EMISSIVE_BLOCK_NONE)
		. += emissive_blocker(standing.icon, standing.icon_state, src)
	SEND_SIGNAL(src, COMSIG_ITEM_GET_WORN_OVERLAYS, ., standing, isinhands, icon_file)

/// worn_overlays to use when you'd want to use KEEP_APART. Don't use KEEP_APART neither there nor here, as it would break floating overlays
/obj/item/proc/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()
	SEND_SIGNAL(src, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, ., standing, draw_target, isinhands, icon_file)

///Checks to see if any bodyparts need to be redrawn, then does so. update_limb_data = TRUE redraws the limbs to conform to the owner.
///Returns an integer representing the number of limbs that were updated.
/mob/living/carbon/proc/update_body_parts(update_limb_data)
	update_damage_overlays()
	update_wound_overlays()
	var/list/needs_update = list()
	var/limb_count_update = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.update_limb(is_creating = update_limb_data) //Update limb actually doesn't do much, get_limb_icon is the cpu eater.

		var/old_key = icon_render_keys?[limb.body_zone] //Checks the mob's icon render key list for the bodypart
		icon_render_keys[limb.body_zone] = (limb.is_husked) ? limb.generate_husk_key().Join() : limb.generate_icon_key().Join() //Generates a key for the current bodypart

		if(icon_render_keys[limb.body_zone] != old_key) //If the keys match, that means the limb doesn't need to be redrawn
			needs_update += limb

	limb_count_update += length(needs_update)
	var/list/missing_bodyparts = get_missing_limbs()
	if(((dna ? dna.species.max_bodypart_count : BODYPARTS_DEFAULT_MAXIMUM) - icon_render_keys.len) != missing_bodyparts.len) //Checks to see if the target gained or lost any limbs.
		limb_count_update += 1
		for(var/missing_limb in missing_bodyparts)
			icon_render_keys -= missing_limb //Removes dismembered limbs from the key list

	. = limb_count_update
	if(!.)
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb in needs_update)
			var/bodypart_icon = limb.get_limb_icon(dropped = FALSE, update_on = src)
			new_limbs += bodypart_icon
			limb_icon_cache[icon_render_keys[limb.body_zone]] = bodypart_icon //Caches the icon with the bodypart key, as it is new
		else
			new_limbs += limb_icon_cache[icon_render_keys[limb.body_zone]] //Pulls existing sprites from the cache

	remove_overlay(BODYPARTS_LAYER)

	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs

	apply_overlay(BODYPARTS_LAYER)

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
	for(var/datum/bodypart_overlay/overlay as anything in bodypart_overlays)
		if(!overlay.can_draw_on_bodypart(src, owner))
			continue
		. += "-[jointext(overlay.generate_icon_cache(), "-")]"
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		. += "-[human_owner.mob_height]"
	return .

///Generates a cache key specifically for husks
/obj/item/bodypart/proc/generate_husk_key()
	RETURN_TYPE(/list)
	. = list()
	. += "[limb_id]-"
	. += "[husk_type]"
	. += "-husk"
	. += "-[body_zone]"
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		. += "-[human_owner.mob_height]"
	return .

/obj/item/bodypart/head/generate_icon_key()
	. = ..()
	if(lip_style)
		. += "-[lip_style]"
		. += "-[lip_color]"

	if(facial_hair_hidden)
		. += "-FACIAL_HAIR_HIDDEN"
	else
		. += "-[facial_hairstyle]"
		. += "-[override_hair_color || fixed_hair_color || facial_hair_color]"
		. += "-[facial_hair_alpha]"
		if(gradient_styles?[GRADIENT_FACIAL_HAIR_KEY])
			. += "-[gradient_styles[GRADIENT_FACIAL_HAIR_KEY]]"
			. += "-[gradient_colors[GRADIENT_FACIAL_HAIR_KEY]]"

	if(show_eyeless)
		. += "-SHOW_EYELESS"
	if(show_debrained)
		. += "-SHOW_DEBRAINED"
		return .

	if(hair_hidden)
		. += "-HAIR_HIDDEN"
	else
		. += "-[hairstyle]"
		. += "-[override_hair_color || fixed_hair_color || hair_color]"
		. += "-[hair_alpha]"
		if(gradient_styles?[GRADIENT_HAIR_KEY])
			. += "-[gradient_styles[GRADIENT_HAIR_KEY]]"
			. += "-[gradient_colors[GRADIENT_HAIR_KEY]]"
		if(LAZYLEN(hair_masks))
			. += "-[jointext(hair_masks, "-")]"

	return .

GLOBAL_LIST_EMPTY(masked_leg_icons_cache)

/**
 * This proc serves as a way to ensure that legs layer properly on a mob.
 * To do this, two separate images are created - A low layer one, and a normal layer one.
 * Each of the image will appropriately crop out dirs that are not used on that given layer.
 *
 * Arguments:
 * * limb_overlay - The limb image being masked, not necessarily the original limb image as it could be an overlay on top of it
 * Returns the list of masked images, or `null` if the limb_overlay didn't exist
 */
/obj/item/bodypart/leg/proc/generate_masked_leg(image/limb_overlay)
	RETURN_TYPE(/list)
	if(!limb_overlay)
		return
	. = list()

	var/icon_cache_key = "[limb_overlay.icon]-[limb_overlay.icon_state]-[body_zone]"
	var/icon/new_leg_icon
	var/icon/new_leg_icon_lower

	//in case we do not have a cached version of the two cropped icons for this key, we have to create it
	if(!GLOB.masked_leg_icons_cache[icon_cache_key])
		var/icon/leg_crop_mask = (body_zone == BODY_ZONE_R_LEG ? icon('icons/mob/leg_masks.dmi', "right_leg") : icon('icons/mob/leg_masks.dmi', "left_leg"))
		var/icon/leg_crop_mask_lower = (body_zone == BODY_ZONE_R_LEG ? icon('icons/mob/leg_masks.dmi', "right_leg_lower") : icon('icons/mob/leg_masks.dmi', "left_leg_lower"))

		new_leg_icon = icon(limb_overlay.icon, limb_overlay.icon_state)
		new_leg_icon.Blend(leg_crop_mask, ICON_MULTIPLY)

		new_leg_icon_lower = icon(limb_overlay.icon, limb_overlay.icon_state)
		new_leg_icon_lower.Blend(leg_crop_mask_lower, ICON_MULTIPLY)

		GLOB.masked_leg_icons_cache[icon_cache_key] = list(new_leg_icon, new_leg_icon_lower)
	new_leg_icon = GLOB.masked_leg_icons_cache[icon_cache_key][1]
	new_leg_icon_lower = GLOB.masked_leg_icons_cache[icon_cache_key][2]

	//this could break layering in oddjob cases, but i'm sure it will work fine most of the time... right?
	var/image/new_leg_appearance = new(limb_overlay)
	new_leg_appearance.icon = new_leg_icon
	new_leg_appearance.layer = -BODYPARTS_LAYER
	. += new_leg_appearance
	var/image/new_leg_appearance_lower = new(limb_overlay)
	new_leg_appearance_lower.icon = new_leg_icon_lower
	new_leg_appearance_lower.layer = -BODYPARTS_LOW_LAYER
	. += new_leg_appearance_lower
	return .

/proc/get_default_icon_by_slot(slot_flag)
	switch(slot_flag)
		if(ITEM_SLOT_HEAD)
			return 'icons/mob/clothing/head/default.dmi'
		if(ITEM_SLOT_EYES)
			return 'icons/mob/clothing/eyes.dmi'
		if(ITEM_SLOT_EARS)
			return 'icons/mob/clothing/ears.dmi'
		if(ITEM_SLOT_MASK)
			return 'icons/mob/clothing/mask.dmi'
		if(ITEM_SLOT_NECK)
			return 'icons/mob/clothing/neck.dmi'
		if(ITEM_SLOT_BACK)
			return 'icons/mob/clothing/back.dmi'
		if(ITEM_SLOT_BELT)
			return 'icons/mob/clothing/belt.dmi'
		if(ITEM_SLOT_ID)
			return 'icons/mob/clothing/id.dmi'
		if(ITEM_SLOT_ICLOTHING)
			return DEFAULT_UNIFORM_FILE
		if(ITEM_SLOT_OCLOTHING)
			return DEFAULT_SUIT_FILE
		if(ITEM_SLOT_GLOVES)
			return 'icons/mob/clothing/hands.dmi'
		if(ITEM_SLOT_FEET)
			return DEFAULT_SHOES_FILE

/proc/get_default_layer_by_slot(slot_flag)
	switch(text2num(slot_flag))
		if(ITEM_SLOT_HEAD)
			return HEAD_LAYER
		if(ITEM_SLOT_EYES)
			return GLASSES_LAYER
		if(ITEM_SLOT_EARS)
			return EARS_LAYER
		if(ITEM_SLOT_MASK)
			return FACEMASK_LAYER
		if(ITEM_SLOT_NECK)
			return NECK_LAYER
		if(ITEM_SLOT_BACK)
			return BACK_LAYER
		if(ITEM_SLOT_BELT)
			return BELT_LAYER
		if(ITEM_SLOT_ID)
			return ID_LAYER
		if(ITEM_SLOT_ICLOTHING)
			return UNIFORM_LAYER
		if(ITEM_SLOT_OCLOTHING)
			return SUIT_LAYER
		if(ITEM_SLOT_GLOVES)
			return GLOVES_LAYER
		if(ITEM_SLOT_FEET)
			return SHOES_LAYER
