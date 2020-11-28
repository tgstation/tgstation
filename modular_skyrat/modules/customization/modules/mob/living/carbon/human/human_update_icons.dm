/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ICLOTHING) + 1]
		inv.update_icon()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		U.screen_loc = ui_iclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_uniform
		update_observer_view(w_uniform,1)

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return

		var/applied_style = NONE
		var/icon_file = w_uniform.worn_icon
		if(dna.species.mutant_bodyparts["taur"])
			var/datum/sprite_accessory/taur/S = GLOB.sprite_accessories["taur"][dna.species.mutant_bodyparts["taur"][MUTANT_INDEX_NAME]]
			if(w_uniform.mutant_variants & S.taur_mode)
				applied_style = S.taur_mode
			else if(w_uniform.mutant_variants & S.alt_taur_mode)
				applied_style = S.alt_taur_mode
		if(!applied_style)
			if((DIGITIGRADE in dna.species.species_traits) && (w_uniform.mutant_variants & STYLE_DIGITIGRADE))
				applied_style = STYLE_DIGITIGRADE

		var/x_override
		switch(applied_style)
			if(STYLE_DIGITIGRADE)
				icon_file = w_uniform.worn_icon_digi || 'modular_skyrat/master_files/icons/mob/clothing/under/uniform_digi.dmi'
			if(STYLE_TAUR_SNAKE)
				icon_file = w_uniform.worn_icon_taur_snake || 'modular_skyrat/master_files/icons/mob/clothing/under/uniform_taur_snake.dmi'
			if(STYLE_TAUR_HOOF)
				icon_file = w_uniform.worn_icon_taur_hoof || 'modular_skyrat/master_files/icons/mob/clothing/under/uniform_taur_hoof.dmi'
			if(STYLE_TAUR_PAW)
				icon_file = w_uniform.worn_icon_taur_paw || 'modular_skyrat/master_files/icons/mob/clothing/under/uniform_taur_paw.dmi'

		if(applied_style & STYLE_TAUR_ALL)
			x_override = 64

		var/target_overlay = U.icon_state
		if(U.adjusted == ALT_STYLE)
			target_overlay = "[target_overlay]_d"


		var/mutable_appearance/uniform_overlay

		if(dna && dna.species.sexes && !applied_style)
			if(body_type == FEMALE && U.fitted != NO_FEMALE_UNIFORM)
				uniform_overlay = U.build_worn_icon(default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, femaleuniform = U.fitted, override_state = target_overlay, override_icon = icon_file, override_x_center = x_override)

		if(!uniform_overlay)
			uniform_overlay = U.build_worn_icon(default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_state = target_overlay, override_icon = icon_file, override_x_center = x_override)

		if(OFFSET_UNIFORM in dna.species.offset_features)
			uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
			uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)
	update_mutant_bodyparts()

/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_OCLOTHING) + 1]
		inv.update_icon()

	if(istype(wear_suit, /obj/item/clothing/suit))
		wear_suit.screen_loc = ui_oclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_suit
		update_observer_view(wear_suit,1)
		var/icon_file = wear_suit.worn_icon
		var/applied_style = NONE
		if(dna.species.mutant_bodyparts["taur"])
			var/datum/sprite_accessory/taur/S = GLOB.sprite_accessories["taur"][dna.species.mutant_bodyparts["taur"][MUTANT_INDEX_NAME]]
			if(wear_suit.mutant_variants & S.taur_mode)
				applied_style = S.taur_mode
			else if(wear_suit.mutant_variants & S.alt_taur_mode)
				applied_style = S.alt_taur_mode
		if(!applied_style)
			if((DIGITIGRADE in dna.species.species_traits) && (wear_suit.mutant_variants & STYLE_DIGITIGRADE))
				applied_style = STYLE_DIGITIGRADE

		var/x_override
		switch(applied_style)
			if(STYLE_DIGITIGRADE)
				icon_file = wear_suit.worn_icon_digi || 'modular_skyrat/master_files/icons/mob/clothing/suit_digi.dmi'
			if(STYLE_TAUR_SNAKE)
				icon_file = wear_suit.worn_icon_taur_snake || 'modular_skyrat/master_files/icons/mob/clothing/suit_taur_snake.dmi'
			if(STYLE_TAUR_HOOF)
				icon_file = wear_suit.worn_icon_taur_hoof || 'modular_skyrat/master_files/icons/mob/clothing/suit_taur_hoof.dmi'
			if(STYLE_TAUR_PAW)
				icon_file = wear_suit.worn_icon_taur_paw || 'modular_skyrat/master_files/icons/mob/clothing/suit_taur_paw.dmi'

		if(applied_style & STYLE_TAUR_ALL)
			x_override = 64

		overlays_standing[SUIT_LAYER] = wear_suit.build_worn_icon(default_layer = SUIT_LAYER, default_icon_file = 'icons/mob/clothing/suit.dmi', override_icon = icon_file, override_x_center = x_override)
		var/mutable_appearance/suit_overlay = overlays_standing[SUIT_LAYER]
		if(OFFSET_SUIT in dna.species.offset_features)
			suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
			suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
		overlays_standing[SUIT_LAYER] = suit_overlay
	update_hair()
	update_mutant_bodyparts()

	apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(dna.species.mutant_bodyparts["taur"])
		var/datum/sprite_accessory/taur/S = GLOB.sprite_accessories["taur"][dna.species.mutant_bodyparts["taur"][MUTANT_INDEX_NAME]]
		if(S.hide_legs)
			return

	if(num_legs<2)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_FEET) + 1]
		inv.update_icon()

	if(shoes)
		shoes.screen_loc = ui_shoes					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += shoes					//add it to client's screen
		update_observer_view(shoes,1)
		var/icon_file = shoes.worn_icon
		if((DIGITIGRADE in dna.species.species_traits) && (shoes.mutant_variants & STYLE_DIGITIGRADE))
			icon_file = shoes.worn_icon_digi || 'modular_skyrat/master_files/icons/mob/clothing/feet_digi.dmi'

		overlays_standing[SHOES_LAYER] = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi', override_icon = icon_file)
		var/mutable_appearance/shoes_overlay = overlays_standing[SHOES_LAYER]
		if(OFFSET_SHOES in dna.species.offset_features)
			shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
			shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
		overlays_standing[SHOES_LAYER] = shoes_overlay

	apply_overlay(SHOES_LAYER)

/obj/item/proc/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, override_icon = null, override_x_center = null, override_y_center = null)

	//Find a valid icon_state from variables+arguments
	var/t_state
	if(override_state)
		t_state = override_state
	else
		t_state = !isinhands ? (worn_icon_state ? worn_icon_state : icon_state) : (inhand_icon_state ? inhand_icon_state : icon_state)

	//Find a valid icon file from variables+arguments
	var/file2use
	if(override_icon)
		file2use = override_icon
	else
		file2use = !isinhands ? (worn_icon ? worn_icon : default_icon_file) : default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use = alternate_worn_layer ? alternate_worn_layer : default_layer

	var/mutable_appearance/standing
	if(femaleuniform)
		standing = wear_female_version(t_state,file2use,layer2use,femaleuniform) //should layer2use be in sync with the adjusted value below? needs testing - shiz
	if(!standing)
		standing = mutable_appearance(file2use, t_state, -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands, file2use)
	if(worn_overlays && worn_overlays.len)
		standing.overlays.Add(worn_overlays)

	var/x_center
	var/y_center
	if(override_x_center)
		x_center = override_x_center
	else
		x_center = isinhands ? inhand_x_dimension : worn_x_dimension
	if(override_y_center)
		y_center = override_y_center
	else
		y_center = isinhands ? inhand_y_dimension : worn_y_dimension
	standing = center_image(standing, x_center, y_center)

	//Handle held offsets
	var/mob/M = loc
	if(istype(M))
		var/list/L = get_held_offsets()
		if(L)
			standing.pixel_x += L["x"] //+= because of center()ing
			standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing.color = color

	return standing

//Removed the icon cache from this, as its not feasible to make a cache for the plathora of customizable species and markings
/mob/living/carbon/human/update_body_parts()
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(BODYPARTS_LAYER)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_limb()

	var/is_taur = FALSE
	if(dna?.species.mutant_bodyparts["taur"])
		var/datum/sprite_accessory/taur/S = GLOB.sprite_accessories["taur"][dna.species.mutant_bodyparts["taur"][MUTANT_INDEX_NAME]]
		if(S.hide_legs)
			is_taur = TRUE

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(is_taur && (BP.body_part == LEG_LEFT || BP.body_part == LEG_RIGHT))
			continue

		new_limbs += BP.get_limb_icon()
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()

/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EYES) + 1]
		inv.update_icon()

	if(glasses)
		glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				client.screen += glasses				//Either way, add the item to the HUD
		update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
			var/icon_file = glasses.worn_icon
			if(dna.species.id == "vox")
				icon_file = 'modular_skyrat/master_files/icons/mob/clothing/eyes_vox.dmi'
			overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/clothing/eyes.dmi', override_icon = icon_file)

		var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
		if(glasses_overlay)
			if(OFFSET_GLASSES in dna.species.offset_features)
				glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
				glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
			overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)
