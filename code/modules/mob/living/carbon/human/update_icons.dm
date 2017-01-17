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
	e.g.2 - update_hair()

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
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's body layer and mutant bodyparts
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())


*/

//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna.species.handle_mutant_bodyparts(src)


/mob/living/carbon/human/update_body()
	remove_overlay(BODY_LAYER)
	dna.species.handle_body(src)
	..()

/mob/living/carbon/human/update_fire()
	..("Standing")


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()

	if(!..())
		update_body()
		update_hair()
		update_inv_w_uniform()
		update_inv_wear_id()
		update_inv_gloves()
		update_inv_glasses()
		update_inv_ears()
		update_inv_shoes()
		update_inv_s_store()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_belt()
		update_inv_back()
		update_inv_wear_suit()
		update_inv_pockets()
		update_inv_neck()
		update_transform()
		//mutations
		update_mutations_overlay()
		//damage overlays
		update_damage_overlays()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_w_uniform]
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


		var/t_color = U.item_color
		if(!t_color)
			t_color = U.icon_state
		if(U.adjusted == ALT_STYLE)
			t_color = "[t_color]_d"
		else if(U.adjusted == DIGITIGRADE_STYLE)
			t_color = "[t_color]_l"

		var/image/standing

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
				standing = U.build_worn_icon(state = "[t_color]_s", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE, femaleuniform = U.fitted)

		if(!standing)
			standing = U.build_worn_icon(state = "[t_color]_s", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE)

		overlays_standing[UNIFORM_LAYER]	= standing

	else if(!(dna && dna.species.nojumpsuit))
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			unEquip(thing)

	apply_overlay(UNIFORM_LAYER)
	update_mutant_bodyparts()


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_id]
		inv.update_icon()

	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used && hud_used.hud_shown)
			client.screen += wear_id
		update_observer_view(wear_id)

		//TODO: add an icon file for ID slot stuff, so it's less snowflakey
		var/image/standing = wear_id.build_worn_icon(state = wear_id.item_state, default_layer = ID_LAYER, default_icon_file = 'icons/mob/mob.dmi')
		overlays_standing[ID_LAYER] = standing

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(get_num_arms() <2)
		if(!gloves && blood_DNA)
			if(has_left_hand())
				overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands_left", "layer"=-GLOVES_LAYER)
				apply_overlay(GLOVES_LAYER)
			else if(has_right_hand())
				overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands_right", "layer"=-GLOVES_LAYER)
				apply_overlay(GLOVES_LAYER)
		return

	if(client && hud_used && hud_used.inv_slots[slot_gloves])
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_gloves]
		inv.update_icon()

	if(gloves)
		gloves.screen_loc = ui_gloves
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += gloves
		update_observer_view(gloves,1)
		var/t_state = gloves.item_state
		if(!t_state)
			t_state = gloves.icon_state

		var/image/standing = gloves.build_worn_icon(state = t_state, default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/hands.dmi')

		overlays_standing[GLOVES_LAYER]	= standing

	else
		if(blood_DNA)
			overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands", "layer"=-GLOVES_LAYER)

	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(!get_bodypart("head")) //decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_glasses]
		inv.update_icon()

	if(glasses)
		glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				client.screen += glasses				//Either way, add the item to the HUD
		update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))

			var/image/standing = glasses.build_worn_icon(state = glasses.icon_state, default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/eyes.dmi')
			overlays_standing[GLASSES_LAYER] = standing

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(!get_bodypart("head")) //decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_ears]
		inv.update_icon()

	if(ears)
		ears.screen_loc = ui_ears	//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += ears					//add it to the client's screen
		update_observer_view(ears,1)

		var/image/standing = ears.build_worn_icon(state = ears.icon_state, default_layer = EARS_LAYER, default_icon_file = 'icons/mob/ears.dmi')
		overlays_standing[EARS_LAYER] = standing

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(get_num_legs() <2)
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_shoes]
		inv.update_icon()

	if(shoes)
		shoes.screen_loc = ui_shoes					//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += shoes					//add it to client's screen
		update_observer_view(shoes,1)
		var/image/standing = shoes.build_worn_icon(state = shoes.icon_state, default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/feet.dmi')
		overlays_standing[SHOES_LAYER]	= standing

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_s_store]
		inv.update_icon()

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used && hud_used.hud_shown)
			client.screen += s_store
		update_observer_view(s_store)
		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)

	apply_overlay(SUIT_STORE_LAYER)


/mob/living/carbon/human/update_inv_head()
	..()
	update_mutant_bodyparts()

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_belt]
		inv.update_icon()

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used && hud_used.hud_shown)
			client.screen += belt
		update_observer_view(belt)

		var/t_state = belt.item_state
		if(!t_state)
			t_state = belt.icon_state

		var/image/standing = belt.build_worn_icon(state = t_state, default_layer = BELT_LAYER, default_icon_file = 'icons/mob/belt.dmi')
		overlays_standing[BELT_LAYER] = standing


	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_suit]
		inv.update_icon()

	if(istype(wear_suit, /obj/item/clothing/suit))
		wear_suit.screen_loc = ui_oclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_suit
		update_observer_view(wear_suit,1)

		var/image/standing = wear_suit.build_worn_icon(state = wear_suit.icon_state, default_layer = SUIT_LAYER, default_icon_file = 'icons/mob/suit.dmi')
		overlays_standing[SUIT_LAYER]	= standing

		if(wear_suit.breakouttime) //suit is restraining
			drop_all_held_items()

	update_hair()
	update_mutant_bodyparts()

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/obj/screen/inventory/inv

		inv = hud_used.inv_slots[slot_l_store]
		inv.update_icon()

		inv = hud_used.inv_slots[slot_r_store]
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


/mob/living/carbon/human/update_inv_wear_mask()
	..()
	update_mutant_bodyparts() //e.g. upgate needed because mask now hides lizard snout


/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = src.legcuffed)

/proc/wear_female_version(t_color, icon, layer, type)
	var/index = t_color
	var/icon/female_clothing_icon = female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index,t_color,icon,type)
	var/standing	= image("icon"=female_clothing_icons["[t_color]"], "layer"=-layer)
	return(standing)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	I.screen_loc = ui_head
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	I.screen_loc = ui_mask
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/I)
	I.screen_loc = ui_neck
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)




/*
Does everything in relation to building the /image used in the mob's overlays list
covers:
 inhands and any other form of worn item
 centering large images
 layering images on custom layers
 building images from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

femalueuniform: A value matching a uniform item's fitted var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables


*/
/obj/item/proc/build_worn_icon(var/state = "", var/default_layer = 0, var/default_icon_file = null, var/isinhands = FALSE, var/femaleuniform = NO_FEMALE_UNIFORM)

	//Find a valid icon file from variables+arguments
	var/file2use
	if(!isinhands && alternate_worn_icon)
		file2use = alternate_worn_icon
	if(!file2use)
		file2use = default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use
	if(alternate_worn_layer)
		layer2use = alternate_worn_layer
	if(!layer2use)
		layer2use = default_layer

	var/image/standing
	if(femaleuniform)
		standing = wear_female_version(state,file2use,layer2use,femaleuniform)
	if(!standing)
		standing = image("icon"=file2use, "icon_state"=state,"layer"=-layer2use)

	//Get the overlay images for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands)
	if(worn_overlays && worn_overlays.len)
		standing.overlays.Add(worn_overlays)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

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


/obj/item/proc/get_held_offsets()
	var/list/L
	if(ismob(loc))
		var/mob/M = loc
		L = M.get_item_offsets_for_index(M.get_held_index_of_item(src))
	return L


//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)



//produces a key based on the human's limbs
/mob/living/carbon/human/generate_icon_render_key()
	. = "[dna.species.limbs_id]"

	if(dna.check_mutation(HULK))
		. += "-coloured-hulk"
	else if(dna.species.use_skintones)
		. += "-coloured-[skin_tone]"
	else if(dna.species.fixed_mut_color)
		. += "-coloured-[dna.species.fixed_mut_color]"
	else if(dna.features["mcolor"])
		. += "-coloured-[dna.features["mcolor"]]"
	else
		. += "-not_coloured"

	. += "-[gender]"

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.dmg_overlay_type)
			. += "-[BP.dmg_overlay_type]"

	if(disabilities & HUSK)
		. += "-husk"

/mob/living/carbon/human/load_limb_from_cache()
	..()
	update_hair()



/mob/living/carbon/human/proc/update_observer_view(obj/item/I, inventory)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break
