#define RESOLVE_ICON_STATE(worn_item) (worn_item.worn_icon_state || worn_item.icon_state)

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_body_parts()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

Note: The defines for layer numbers is now kept exclusvely in __DEFINES/misc.dm instead of being defined there,
	then redefined and undefiend everywhere else. If you need to change the layering of sprites (or add a new layer)
	that's where you should start.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_worn_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body_parts()			//Handles bodyparts, and everything bodyparts render. (Organs, hair, facial features)
		update_body()				//Calls update_body_parts(), as well as updates mutant bodyparts, the old, not-actually-bodypart system.
*/

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()

	if(!..())
		update_worn_undersuit()
		update_worn_id()
		update_worn_glasses()
		update_worn_gloves()
		update_worn_ears()
		update_worn_shoes()
		update_suit_storage()
		update_worn_mask()
		update_worn_head()
		update_worn_belt()
		update_worn_back()
		update_worn_oversuit()
		update_pockets()
		update_worn_neck()
		update_transform()
		//mutations
		update_mutations_overlay()
		//damage overlays
		update_damage_overlays()

/mob/living/carbon/human/update_obscured_slots(obscured_flags)
	..()
	sec_hud_set_security_status()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_worn_undersuit(update_obscured = TRUE)
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ICLOTHING) + 1]
		inv.update_icon()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/uniform = w_uniform
		update_hud_uniform(uniform)

		if(update_obscured)
			update_obscured_slots(uniform.flags_inv)

		if(HAS_TRAIT(uniform, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_ICLOTHING))
			return

		var/target_overlay = uniform.icon_state
		if(uniform.adjusted == ALT_STYLE)
			target_overlay = "[target_overlay]_d"

		var/mutable_appearance/uniform_overlay
		//This is how non-humanoid clothing works. You check if the mob has the right bodyflag, and the clothing has the corresponding clothing flag.
		//handled_by_bodyshape is used to track whether or not we successfully used an alternate sprite. It's set to TRUE to ease up on copy-paste.
		//icon_file MUST be set to null by default, or it causes issues.
		//handled_by_bodyshape MUST be set to FALSE under the if(!icon_exists()) statement, or everything breaks.
		//"override_file = handled_by_bodyshape ? icon_file : null" MUST be added to the arguments of build_worn_icon()
		//Friendly reminder that icon_exists_or_scream(file, state) is your friend when debugging this code.
		var/handled_by_bodyshape = TRUE
		var/icon_file
		var/woman
		//BEGIN SPECIES HANDLING
		if((bodyshape & BODYSHAPE_DIGITIGRADE) && (uniform.supports_variations_flags & CLOTHING_DIGITIGRADE_VARIATION))
			icon_file = DIGITIGRADE_UNIFORM_FILE
		//Female sprites have lower priority than digitigrade sprites
		else if(dna.species.sexes && (bodyshape & BODYSHAPE_HUMANOID) && physique == FEMALE && !(uniform.female_sprite_flags & NO_FEMALE_UNIFORM)) //Agggggggghhhhh
			woman = TRUE

		if(!icon_exists(icon_file, RESOLVE_ICON_STATE(uniform)))
			icon_file = DEFAULT_UNIFORM_FILE
			handled_by_bodyshape = FALSE

		//END SPECIES HANDLING
		uniform_overlay = uniform.build_worn_icon(
			default_layer = UNIFORM_LAYER,
			default_icon_file = icon_file,
			isinhands = FALSE,
			female_uniform = woman ? uniform.female_sprite_flags : null,
			override_state = target_overlay,
			override_file = handled_by_bodyshape ? icon_file : null,
		)

		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_uniform_offset?.apply_offset(uniform_overlay)
		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)
	check_body_shape(BODYSHAPE_DIGITIGRADE, ITEM_SLOT_ICLOTHING)

/mob/living/carbon/human/update_worn_id(update_obscured = TRUE)
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ID) + 1]
		inv.update_icon()

	var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]

	if(wear_id)
		var/obj/item/worn_item = wear_id
		update_hud_id(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON))
			return

		var/icon_file = 'icons/mob/clothing/id.dmi'

		id_overlay = wear_id.build_worn_icon(default_layer = ID_LAYER, default_icon_file = icon_file)

		if(!id_overlay)
			return

		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_id_offset?.apply_offset(id_overlay)
		overlays_standing[ID_LAYER] = id_overlay

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_worn_gloves(update_obscured = TRUE)
	remove_overlay(GLOVES_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1]
		inv.update_icon()

	//Bloody hands begin
	if(isnull(gloves))
		if(blood_in_hands && num_hands > 0)
			// When byond gives us filters that respect dirs we can just use an alpha mask for this but until then, two icons weeeee
			var/mutable_appearance/hands_combined = mutable_appearance(layer = -GLOVES_LAYER, appearance_flags = KEEP_TOGETHER)
			if(has_left_hand(check_disabled = FALSE))
				hands_combined.overlays += mutable_appearance('icons/effects/blood.dmi', "bloodyhands_left")
			if(has_right_hand(check_disabled = FALSE))
				hands_combined.overlays += mutable_appearance('icons/effects/blood.dmi', "bloodyhands_right")
			overlays_standing[GLOVES_LAYER] = hands_combined
			apply_overlay(GLOVES_LAYER)
		return
	// Bloody hands end

	if(gloves)
		var/obj/item/worn_item = gloves
		update_hud_gloves(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_GLOVES))
			return

		var/icon_file = 'icons/mob/clothing/hands.dmi'

		var/mutable_appearance/gloves_overlay = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = icon_file)

		var/feature_y_offset = 0
		//needs to be typed, hand_bodyparts can have nulls
		for (var/obj/item/bodypart/arm/my_hand in hand_bodyparts)
			var/list/glove_offset = my_hand.worn_glove_offset?.get_offset()
			if (glove_offset && (!feature_y_offset || glove_offset["y"] > feature_y_offset))
				feature_y_offset = glove_offset["y"]

		gloves_overlay.pixel_y += feature_y_offset

		// We dont have any >2 hands human species (and likely wont ever), so theres no point in splitting this because:
		// It will only run if the left hand OR the right hand is missing, and it wont run if both are missing because you cant wear gloves with no arms
		// (unless admins mess with this then its their fault)
		if(num_hands < default_num_hands)
			var/static/atom/movable/alpha_filter_target
			if(isnull(alpha_filter_target))
				alpha_filter_target = new(null)
			alpha_filter_target.icon = 'icons/effects/effects.dmi'
			alpha_filter_target.icon_state = "missing[!has_left_hand(check_disabled = FALSE) ? "l" : "r"]"
			alpha_filter_target.render_target = "*MissGlove [REF(src)] [!has_left_hand(check_disabled = FALSE) ? "L" : "R"]"
			gloves_overlay.add_overlay(alpha_filter_target)
			gloves_overlay.filters += filter(type="alpha", render_source=alpha_filter_target.render_target, y=feature_y_offset, flags=MASK_INVERSE)

		overlays_standing[GLOVES_LAYER] = gloves_overlay
	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_worn_glasses(update_obscured = TRUE)
	remove_overlay(GLASSES_LAYER)

	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
	if(isnull(my_head)) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EYES) + 1]
		inv.update_icon()

	if(glasses)
		var/obj/item/worn_item = glasses
		update_hud_glasses(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_EYES))
			return

		var/icon_file = 'icons/mob/clothing/eyes.dmi'

		var/mutable_appearance/glasses_overlay = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = icon_file)
		my_head.worn_glasses_offset?.apply_offset(glasses_overlay)
		overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_worn_ears(update_obscured = TRUE)
	remove_overlay(EARS_LAYER)

	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
	if(isnull(my_head)) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EARS) + 1]
		inv.update_icon()

	if(ears)
		var/obj/item/worn_item = ears
		update_hud_ears(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_EARS))
			return

		var/icon_file = 'icons/mob/clothing/ears.dmi'

		var/mutable_appearance/ears_overlay = ears.build_worn_icon(default_layer = EARS_LAYER, default_icon_file = icon_file)
		my_head.worn_ears_offset?.apply_offset(ears_overlay)
		overlays_standing[EARS_LAYER] = ears_overlay
	apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_worn_neck(update_obscured = TRUE)
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_icon()

	if(wear_neck)
		var/obj/item/worn_item = wear_neck
		update_hud_neck(wear_neck)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_NECK))
			return

		var/icon_file = 'icons/mob/clothing/neck.dmi'

		var/mutable_appearance/neck_overlay = worn_item.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = icon_file)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_belt_offset?.apply_offset(neck_overlay)
		overlays_standing[NECK_LAYER] = neck_overlay

	apply_overlay(NECK_LAYER)

/mob/living/carbon/human/update_worn_shoes(update_obscured = TRUE)
	remove_overlay(SHOES_LAYER)

	if(num_legs < 2)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_FEET) + 1]
		inv.update_icon()

	if(shoes)
		var/obj/item/worn_item = shoes
		update_hud_shoes(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_FEET))
			return

		var/icon_file = DEFAULT_SHOES_FILE

		var/mutable_appearance/shoes_overlay = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = icon_file)
		if(!shoes_overlay)
			return

		var/feature_y_offset = 0
		for (var/body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
			var/obj/item/bodypart/leg/my_leg = get_bodypart(body_zone)
			if(isnull(my_leg))
				continue
			var/list/foot_offset = my_leg.worn_foot_offset?.get_offset()
			if (foot_offset && foot_offset["y"] > feature_y_offset)
				feature_y_offset = foot_offset["y"]

		shoes_overlay.pixel_y += feature_y_offset
		overlays_standing[SHOES_LAYER] = shoes_overlay

	apply_overlay(SHOES_LAYER)
	check_body_shape(BODYSHAPE_DIGITIGRADE, ITEM_SLOT_FEET)

/mob/living/carbon/human/update_suit_storage(update_obscured = TRUE)
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_SUITSTORE) + 1]
		inv.update_icon()

	if(s_store)
		var/obj/item/worn_item = s_store
		update_hud_s_store(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_SUITSTORE))
			return

		var/mutable_appearance/s_store_overlay = worn_item.build_worn_icon(default_layer = SUIT_STORE_LAYER, default_icon_file = 'icons/mob/clothing/belt_mirror.dmi')
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_suit_storage_offset?.apply_offset(s_store_overlay)
		overlays_standing[SUIT_STORE_LAYER] = s_store_overlay
	apply_overlay(SUIT_STORE_LAYER)

/mob/living/carbon/human/update_worn_head(update_obscured = TRUE)
	remove_overlay(HEAD_LAYER)
	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_icon()

	if(head)
		var/obj/item/worn_item = head
		update_hud_head(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_HEAD))
			return

		var/icon_file = 'icons/mob/clothing/head/default.dmi'

		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = icon_file)
		var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
		my_head?.worn_head_offset?.apply_offset(head_overlay)
		overlays_standing[HEAD_LAYER] = head_overlay

	apply_overlay(HEAD_LAYER)
	check_body_shape(BODYSHAPE_SNOUTED, ITEM_SLOT_HEAD)

/mob/living/carbon/human/update_worn_belt(update_obscured = TRUE)
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BELT) + 1]
		inv.update_icon()

	if(belt)
		var/obj/item/worn_item = belt
		update_hud_belt(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_BELT))
			return

		var/icon_file = 'icons/mob/clothing/belt.dmi'

		var/mutable_appearance/belt_overlay = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = icon_file)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_belt_offset?.apply_offset(belt_overlay)
		overlays_standing[BELT_LAYER] = belt_overlay

	apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_worn_oversuit(update_obscured = TRUE)
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_OCLOTHING) + 1]
		inv.update_icon()

	if(wear_suit)
		var/obj/item/worn_item = wear_suit
		update_hud_wear_suit(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON))
			return

		var/icon_file = DEFAULT_SUIT_FILE

		var/mutable_appearance/suit_overlay = wear_suit.build_worn_icon(default_layer = SUIT_LAYER, default_icon_file = icon_file)
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_suit_offset?.apply_offset(suit_overlay)
		overlays_standing[SUIT_LAYER] = suit_overlay

	apply_overlay(SUIT_LAYER)
	check_body_shape(BODYSHAPE_DIGITIGRADE, ITEM_SLOT_OCLOTHING)

/mob/living/carbon/human/update_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv

		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_LPOCKET) + 1]
		inv.update_icon()
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_RPOCKET) + 1]
		inv.update_icon()

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			update_observer_view(r_store)

/mob/living/carbon/human/update_worn_mask(update_obscured = TRUE)
	remove_overlay(FACEMASK_LAYER)

	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
	if(isnull(my_head)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_icon()

	if(wear_mask)
		var/obj/item/worn_item = wear_mask
		update_hud_wear_mask(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON) || (check_obscured_slots(transparent_protection = TRUE) & ITEM_SLOT_MASK))
			return

		var/icon_file = 'icons/mob/clothing/mask.dmi'

		var/mutable_appearance/mask_overlay = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = icon_file)
		my_head.worn_mask_offset?.apply_offset(mask_overlay)
		overlays_standing[FACEMASK_LAYER] = mask_overlay

	apply_overlay(FACEMASK_LAYER)
	check_body_shape(BODYSHAPE_SNOUTED, ITEM_SLOT_MASK)

/mob/living/carbon/human/update_worn_back(update_obscured = TRUE)
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_icon()

	if(back)
		var/obj/item/worn_item = back
		var/mutable_appearance/back_overlay
		update_hud_back(worn_item)

		if(update_obscured)
			update_obscured_slots(worn_item.flags_inv)

		if(HAS_TRAIT(worn_item, TRAIT_NO_WORN_ICON))
			return

		var/icon_file = 'icons/mob/clothing/back.dmi'

		back_overlay = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = icon_file)

		if(!back_overlay)
			return
		var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
		my_chest?.worn_back_offset?.apply_offset(back_overlay)
		overlays_standing[BACK_LAYER] = back_overlay
	apply_overlay(BACK_LAYER)

/mob/living/carbon/human/get_held_overlays()
	var/list/hands = list()
	for(var/obj/item/worn_item in held_items)
		var/held_index = get_held_index_of_item(worn_item)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			worn_item.screen_loc = ui_hand_position(held_index)
			client.screen += worn_item
			if(observers?.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += worn_item
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/t_state = worn_item.inhand_icon_state
		if(!t_state)
			t_state = worn_item.icon_state

		var/mutable_appearance/hand_overlay
		var/icon_file = IS_RIGHT_INDEX(held_index) ? worn_item.righthand_file : worn_item.lefthand_file
		hand_overlay = worn_item.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
		var/obj/item/bodypart/arm/held_in_hand = hand_bodyparts[held_index]
		held_in_hand?.held_hand_offset?.apply_offset(hand_overlay)

		hands += hand_overlay
	return hands

/// Modifies a sprite slightly to conform to female body shapes
/proc/wear_female_version(icon_state, icon, type, greyscale_colors)
	var/index = "[icon_state]-[greyscale_colors]"
	var/static/list/female_clothing_icons = list()
	var/icon/female_clothing_icon = female_clothing_icons[index]
	if(!female_clothing_icon) //Create standing/laying icons if they don't exist
		var/female_icon_state = "female[type == FEMALE_UNIFORM_FULL ? "_full" : ((!type || type & FEMALE_UNIFORM_TOP_ONLY) ? "_top" : "")][type & FEMALE_UNIFORM_NO_BREASTS ? "_no_breasts" : ""]"
		var/icon/female_cropping_mask = icon('icons/mob/clothing/under/masking_helpers.dmi', female_icon_state)
		female_clothing_icon = icon(icon, icon_state)
		female_clothing_icon.Blend(female_cropping_mask, ICON_MULTIPLY)
		female_clothing_icon = fcopy_rsc(female_clothing_icon)
		female_clothing_icons[index] = female_clothing_icon

	return icon(female_clothing_icon)

/// Modifies a sprite to conform to digitigrade body shapes
/proc/wear_digi_version(icon/base_icon, obj/item/item, key, greyscale_colors)
	ASSERT(istype(item), "wear_digi_version: no item passed")
	ASSERT(istext(key), "wear_digi_version: no key passed")
	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = item.get_general_color(base_icon)

	var/index = "[key]-[item.type]-[greyscale_colors]"
	var/static/list/digitigrade_clothing_cache = list()
	var/icon/resulting_icon = digitigrade_clothing_cache[index]
	if(!resulting_icon)
		resulting_icon = item.generate_digitigrade_icons(base_icon, greyscale_colors)
		if(!resulting_icon)
			stack_trace("[item.type] is set to generate a masked digitigrade icon, but generate_digitigrade_icons was not implemented (or error'd).")
			return base_icon
		digitigrade_clothing_cache[index] = fcopy_rsc(resulting_icon)

	return icon(resulting_icon)

/// Modifies a sprite to replace the legs with a new version
/proc/replace_icon_legs(icon/base_icon, icon/new_legs)
	var/static/icon/leg_mask
	if(!leg_mask)
		leg_mask = icon('icons/mob/clothing/under/masking_helpers.dmi', "digi_leg_mask")

	// cuts the legs off
	base_icon.Blend(leg_mask, ICON_SUBTRACT)
	// staples the new legs on
	base_icon.Blend(new_legs, ICON_OVERLAY)
	return base_icon

/**
 * Generates a digitigrade version of this item's worn icon
 *
 * Arguments:
 * * base_icon: The icon to generate the digitigrade icon from
 * * greyscale_colors: The greyscale colors to use for the digitigrade icon
 *
 * Returns an icon that is the digitigrade version of the item's worn icon
 * Returns null if the item has no support for digitigrade variations via this method
 */
/obj/item/proc/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	return null

/**
 * Get what color the item is on "average"
 * Can be used to approximate what color this item is/should be
 *
 * Arguments:
 * * base_icon: The icon to get the color from
 */
/obj/item/proc/get_general_color(icon/base_icon)
	if(greyscale_colors && length(SSgreyscale.ParseColorString(greyscale_colors)) == 1)
		return greyscale_colors
	return color

// These coordinates point to the middle of the left leg
#define LEG_SAMPLE_X_LOWER 13
#define LEG_SAMPLE_X_UPPER 14
#define LEG_SAMPLE_Y_LOWER 8
#define LEG_SAMPLE_Y_UPPER 9

/obj/item/clothing/get_general_color(icon/base_icon)
	if(slot_flags & (ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING))
		var/pant_color
		// approximates the color of the pants by sampling a few pixels in the middle of the left leg
		for(var/x in LEG_SAMPLE_X_LOWER to LEG_SAMPLE_X_UPPER)
			for(var/y in LEG_SAMPLE_Y_LOWER to LEG_SAMPLE_Y_UPPER)
				var/xy_color = base_icon.GetPixel(x, y)
				pant_color = pant_color ? BlendRGB(pant_color, xy_color, 0.5) : xy_color

		return pant_color || "#1d1d1d" // black pants always look good

	return ..()

#undef LEG_SAMPLE_X_LOWER
#undef LEG_SAMPLE_X_UPPER
#undef LEG_SAMPLE_Y_LOWER
#undef LEG_SAMPLE_Y_UPPER

// Points to the tip of the left foot
#define SHOE_SAMPLE_X 11
#define SHOE_SAMPLE_Y 2

/obj/item/clothing/shoes/get_general_color(icon/base_icon)
	// just grabs the color of the middle of the left foot
	return base_icon.GetPixel(SHOE_SAMPLE_X, SHOE_SAMPLE_Y) || "#1d1d1d"

#undef SHOE_SAMPLE_X
#undef SHOE_SAMPLE_Y

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

/mob/living/carbon/human/proc/update_hud_uniform(obj/item/worn_item)
	worn_item.screen_loc = ui_iclothing
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_id(obj/item/worn_item)
	worn_item.screen_loc = ui_id
	if((client && hud_used?.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item)

/mob/living/carbon/human/proc/update_hud_gloves(obj/item/worn_item)
	worn_item.screen_loc = ui_gloves
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_glasses(obj/item/worn_item)
	worn_item.screen_loc = ui_glasses
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_ears(obj/item/worn_item)
	worn_item.screen_loc = ui_ears
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_shoes(obj/item/worn_item)
	worn_item.screen_loc = ui_shoes
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_s_store(obj/item/worn_item)
	worn_item.screen_loc = ui_sstore1
	if(client && hud_used?.hud_shown)
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_wear_suit(obj/item/worn_item)
	worn_item.screen_loc = ui_oclothing
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/proc/update_hud_belt(obj/item/worn_item)
	belt.screen_loc = ui_belt
	if(client && hud_used?.hud_shown)
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

/mob/living/carbon/human/update_hud_head(obj/item/worn_item)
	worn_item.screen_loc = ui_head
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/worn_item)
	worn_item.screen_loc = ui_mask
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/worn_item)
	worn_item.screen_loc = ui_neck
	if((client && hud_used) && (hud_used.inventory_shown && hud_used.hud_shown))
		client.screen += worn_item
	update_observer_view(worn_item,TRUE)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/worn_item)
	worn_item.screen_loc = ui_back
	if(client && hud_used?.hud_shown)
		client.screen += worn_item
	update_observer_view(worn_item, inventory = TRUE)

/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
Inhands and any other form of worn item
Rentering large appearances
Layering appearances on custom layers
Building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

female_uniform: A value matching a uniform item's female_sprite_flags var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables


*/
/obj/item/proc/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	female_uniform = NO_FEMALE_UNIFORM,
	override_state = null,
	override_file = null,
)

	//Find a valid icon_state from variables+arguments
	var/t_state = override_state || (isinhands ? inhand_icon_state : worn_icon_state) || icon_state
	//Find a valid icon file from variables+arguments
	var/file2use = override_file || (isinhands ? null : worn_icon) || default_icon_file
	//Find a valid layer from variables+arguments
	var/layer2use = alternate_worn_layer || default_layer

	var/mob/living/carbon/wearer = loc
	var/is_digi = istype(wearer) && (wearer.bodyshape & BODYSHAPE_DIGITIGRADE) && !wearer.is_digitigrade_squished()

	var/mutable_appearance/standing // this is the actual resulting MA
	var/icon/building_icon // used to construct an icon across multiple procs before converting it to MA
	if(female_uniform)
		building_icon = wear_female_version(
			icon_state = t_state,
			icon = file2use,
			type = female_uniform,
			greyscale_colors = greyscale_colors,
		)
	if(!isinhands && is_digi && (supports_variations_flags & CLOTHING_DIGITIGRADE_MASK))
		building_icon = wear_digi_version(
			base_icon = building_icon || icon(file2use, t_state),
			item = src,
			key = "[t_state]-[file2use]-[female_uniform]",
			greyscale_colors = greyscale_colors,
		)
	if(building_icon)
		standing = mutable_appearance(building_icon, layer = -layer2use)

	// no special handling done, default it
	standing ||= mutable_appearance(file2use, t_state, layer = -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(standing, isinhands, file2use)
	if(length(worn_overlays))
		standing.overlays += worn_overlays

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	//Worn offsets
	var/list/offsets = get_worn_offsets(isinhands)
	standing.pixel_x += offsets[1]
	standing.pixel_y += offsets[2]

	standing.alpha = alpha
	standing = color_atom_overlay(standing)

	return standing

/// Returns offsets used for equipped item overlays in list(px_offset,py_offset) form.
/obj/item/proc/get_worn_offsets(isinhands)
	. = list(0,0) //(px,py)
	if(isinhands)
		//Handle held offsets
		var/mob/holder = loc
		if(istype(holder))
			var/list/offsets = holder.get_item_offsets_for_index(holder.get_held_index_of_item(src))
			if(offsets)
				.[1] = offsets["x"]
				.[2] = offsets["y"]
	else
		.[2] = worn_y_offset

//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)//Handle held offsets

/mob/living/carbon/human/proc/update_observer_view(obj/item/worn_item, inventory)
	if(observers?.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += worn_item
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

// Only renders the head of the human
/mob/living/carbon/human/proc/update_body_parts_head_only(update_limb_data)
	if(!dna?.species)
		return

	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	if(!istype(my_head))
		return

	my_head.update_limb(is_creating = update_limb_data)

	add_overlay(my_head.get_limb_icon())
	update_worn_head()
	update_worn_mask()

/**
 * Used to perform regular updates to the limbs of humans with special bodyshapes
 *
 * * check_shapes: The bodyshapes to check for.
 * Any limbs or organs which share this shape, will be updated.
 * * ignore_slots: The slots to ignore when updating the limbs.
 * This is useful for things like digitigrade legs, where we can skip some slots that we're already updating.
 *
 * return an integer, the number of limbs updated
 */
/mob/living/carbon/human/proc/check_body_shape(check_shapes = BODYSHAPE_DIGITIGRADE|BODYSHAPE_SNOUTED, ignore_slots = NONE)
	. = 0
	if(!(bodyshape & check_shapes))
		// optimization - none of our limbs or organs have the desired shape
		return .

	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/checked_bodyshape = limb.bodyshape
		// accounts for stuff like snouts
		for(var/obj/item/organ/organ in limb)
			checked_bodyshape |= organ.external_bodyshapes

		// any limb needs to be updated, so stop here and do it
		if(checked_bodyshape & check_shapes)
			. = update_body_parts()
			break

	if(!.)
		return
	// hardcoding this here until bodypart updating is more sane
	// we need to update clothing items that may have been affected by bodyshape updates
	if(check_shapes & BODYSHAPE_DIGITIGRADE)
		for(var/obj/item/thing as anything in get_equipped_items())
			if(thing.slot_flags & ignore_slots)
				continue
			if(thing.supports_variations_flags & DIGITIGRADE_VARIATIONS)
				thing.update_slot_icon()

// Hooks into human apply overlay so that we can modify all overlays applied through standing overlays to our height system.
// Some of our overlays will be passed through a displacement filter to make our mob look taller or shorter.
// Some overlays can't be displaced as they're too close to the edge of the sprite or cross the middle point in a weird way.
// So instead we have to pass them through an offset, which is close enough to look good.
/mob/living/carbon/human/apply_overlay(cache_index)
	if(mob_height == HUMAN_HEIGHT_MEDIUM)
		return ..()

	var/raw_applied = overlays_standing[cache_index]
	var/string_form_index = num2text(cache_index)
	var/offset_type = GLOB.layers_to_offset[string_form_index]
	if(isnull(offset_type))
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_filters(applied_appearance)
		else if(isimage(raw_applied))
			apply_height_filters(raw_applied)
	else
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_offsets(applied_appearance, offset_type)
		else if(isimage(raw_applied))
			apply_height_offsets(raw_applied, offset_type)

	return ..()

/**
 * Used in some circumstances where appearances can get cut off from the mob sprite from being too tall
 *
 * upper_torso is to specify whether the appearance is locate in the upper half of the mob rather than the lower half,
 * higher up things (hats for example) need to be offset more due to the location of the filter displacement
 */
/mob/living/carbon/human/proc/apply_height_offsets(image/appearance, upper_torso)
	var/height_to_use = num2text(mob_height)
	var/final_offset = 0
	switch(upper_torso)
		if(UPPER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][1]
		if(LOWER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][2]
		else
			return

	appearance.pixel_y += final_offset
	return appearance

/**
 * Applies a filter to an appearance according to mob height
 */
/mob/living/carbon/human/proc/apply_height_filters(image/appearance)
	var/static/icon/cut_torso_mask = icon('icons/effects/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('icons/effects/cut.dmi', "Cut2")
	var/static/icon/lenghten_torso_mask = icon('icons/effects/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('icons/effects/cut.dmi', "Cut4")

	appearance.remove_filter(list(
		"Cut_Torso",
		"Cut_Legs",
		"Lenghten_Legs",
		"Lenghten_Torso",
		"Gnome_Cut_Torso",
		"Gnome_Cut_Legs",
		"Monkey_Torso",
		"Monkey_Legs",
		"Monkey_Gnome_Cut_Torso",
		"Monkey_Gnome_Cut_Legs",
	))

	switch(mob_height)
		// Don't set this one directly, use TRAIT_DWARF
		if(MONKEY_HEIGHT_DWARF)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Gnome_Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 3),
				),
				list(
					"name" = "Monkey_Gnome_Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		if(MONKEY_HEIGHT_MEDIUM)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
				),
				list(
					"name" = "Monkey_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		if(HUMAN_HEIGHT_DWARF) // tall monkeys and dwarves use the same value
			if(ismonkey(src))
				appearance.add_filters(list(
					list(
						"name" = "Monkey_Torso",
						"priority" = 1,
						"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1),
					),
					list(
						"name" = "Monkey_Legs",
						"priority" = 1,
						"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1),
					),
				))
			else
				appearance.add_filters(list(
					list(
						"name" = "Gnome_Cut_Torso",
						"priority" = 1,
						"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
					),
					list(
						"name" = "Gnome_Cut_Legs",
						"priority" = 1,
						"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 3),
					),
				))
		// Don't set this one directly, use TRAIT_DWARF
		if(HUMAN_HEIGHT_SHORTEST)
			appearance.add_filters(list(
				list(
					"name" = "Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_SHORT)
			appearance.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALL)
			appearance.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALLER)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_TALLEST)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 2),
				),
			))

	// Kinda gross but because many humans overlays do not use KEEP_TOGETHER we need to manually propogate the filter
	// Otherwise overlays, such as worn overlays on icons, won't have the filter "applied", and the effect kinda breaks
	if(!(appearance.appearance_flags & KEEP_TOGETHER))
		for(var/image/overlay in list() + appearance.underlays + appearance.overlays)
			apply_height_filters(overlay)

	return appearance

#undef RESOLVE_ICON_STATE
