<<<<<<< HEAD
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

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/image/standing	= image("icon"='icons/mob/dam_human.dmi', "icon_state"="blank", "layer"=-DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing

	var/dmgoverlaytype = ""
	if(dna.species.exotic_damage_overlay)
		dmgoverlaytype = dna.species.exotic_damage_overlay + "_"

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.brutestate)
			standing.overlays	+= "[dmgoverlaytype][BP.body_zone]_[BP.brutestate]0"	//we're adding icon_states of the base image as overlays
		if(BP.burnstate)
			standing.overlays	+= "[dmgoverlaytype][BP.body_zone]_0[BP.burnstate]"

	apply_overlay(DAMAGE_LAYER)


//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna.species.handle_mutant_bodyparts(src)


/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)
	dna.species.handle_body(src)
	update_body_parts()

/mob/living/carbon/human/update_fire()
	..("Standing")

/mob/living/carbon/human/proc/update_body_parts()
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(BODYPARTS_LAYER)

	//LOAD ICONS
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache()
		update_damage_overlays()
		update_mutant_bodyparts()
		update_hair()
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(!BP.no_update)
			BP.update_limb()
		var/image/temp = BP.get_limb_icon()
		if(temp)
			new_limbs += temp
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()


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
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				U.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return


		var/t_color = U.item_color
		if(!t_color)
			t_color = U.icon_state
		if(U.adjusted)
			t_color = "[t_color]_d"

		var/image/standing

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
				standing = U.build_worn_icon(state = "[t_color]_s", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE, femaleuniform = U.fitted)

		if(!standing)
			standing = U.build_worn_icon(state = "[t_color]_s", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/uniform.dmi', isinhands = FALSE)

		overlays_standing[UNIFORM_LAYER]	= standing

	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			unEquip(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_id]
		inv.update_icon()

	if(wear_id)
		if(client && hud_used && hud_used.hud_shown)
			wear_id.screen_loc = ui_id
			client.screen += wear_id

		//TODO: add an icon file for ID slot stuff, so it's less snowflakey
		var/image/standing = wear_id.build_worn_icon(state = wear_id.item_state, default_layer = ID_LAYER, default_icon_file = 'icons/mob/mob.dmi')
		overlays_standing[ID_LAYER] = standing

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(get_num_arms() <2)
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_gloves]
		inv.update_icon()

	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

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
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

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
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				ears.screen_loc = ui_ears			//...draw the item in the inventory screen
			client.screen += ears					//Either way, add the item to the HUD

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
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing = shoes.build_worn_icon(state = shoes.icon_state, default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/feet.dmi')
		overlays_standing[SHOES_LAYER]	= standing

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_s_store]
		inv.update_icon()

	if(s_store)
		if(client && hud_used && hud_used.hud_shown)
			s_store.screen_loc = ui_sstore1
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)

	apply_overlay(SUIT_STORE_LAYER)



/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)
	if(!get_bodypart("head")) //Decapitated
		return
	..()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_head]
		inv.update_icon()

	update_mutant_bodyparts()


/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_belt]
		inv.update_icon()

		if(hud_used.hud_shown && belt)
			client.screen += belt
			belt.screen_loc = ui_belt

	if(belt)
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
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/image/standing = wear_suit.build_worn_icon(state = wear_suit.icon_state, default_layer = SUIT_LAYER, default_icon_file = 'icons/mob/suit.dmi')
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_l_hand()
			drop_r_hand()

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

		if(hud_used.hud_shown)
			if(l_store)
				client.screen += l_store
				l_store.screen_loc = ui_storage1

			if(r_store)
				client.screen += r_store
				r_store.screen_loc = ui_storage2


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)
	if(!get_bodypart("head")) //Decapitated
		return
	..()
	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_mask]
		inv.update_icon()
	update_mutant_bodyparts()

/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
		apply_overlay(HANDCUFF_LAYER)

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
	for(var/i=1;i<=TOTAL_LAYERS;i++)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			I.screen_loc = ui_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			I.screen_loc = ui_mask
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_back
		client.screen += I


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

	standing.alpha = alpha
	standing.color = color

	return standing









/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste
	See RemieRichards on irc.rizon.net #coderbus
*/

var/global/list/limb_icon_cache = list()

/mob/living/carbon/human
	var/icon_render_key = ""


//produces a key based on the human's limbs
/mob/living/carbon/human/proc/generate_icon_render_key()
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
		if(BP.status == ORGAN_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"

	if(disabilities & HUSK)
		. += "-husk"


//change the human's icon to the one matching it's key
/mob/living/carbon/human/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)
=======
	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.
	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance
When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).
On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.
Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.
In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...
There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()
	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.
>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		QueueUpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you
>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand()		//<---calls update_icons()
	or equivillantly:
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand(0)
		update_icons()
>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.
>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.
This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3
If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x
*/

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed
	var/icon/race_icon
	var/icon/deform_icon
	var/update_overlays = 0

/mob/living/carbon/human/proc/obj_to_plane_overlay(var/obj/Overlays/object,var/slot)
	var/image/I = new()
	I.appearance = object.appearance
	I.plane = FLOAT_PLANE
	obj_overlays[slot] = I
	overlays += I

/mob/living/carbon/human/proc/QueueUpdateDamageIcon(var/forced = 0)
	if(forced)
		UpdateDamageIcon(1)
		update_overlays = 0
		return
	update_overlays = 1

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()
	update_hud()		//TODO: remove the need for this
	update_overlays_standing()
	update_transform()

/mob/living/carbon/human/proc/update_overlays_standing()
	if(species && species.override_icon)
		species_override_icon()
	else
		generate_overlays_icon()

/mob/living/carbon/human/proc/species_override_icon()
	//overlays.len = 0
	icon = species.override_icon
	icon_state = "[lowertext(species.name)]_[gender][ (species.flags & CAN_BE_FAT ? (mutations & M_FAT) ? "_fat" : "" : "") ]"
	//temporary fix for having mutations on top of overriden icons for like muton, horror, etc
	overlays -= obj_overlays[MUTANTRACE_LAYER]


/mob/living/carbon/human/proc/generate_overlays_icon()
	icon = stand_icon

var/global/list/damage_icon_parts = list()

/mob/living/carbon/human/proc/get_damage_icon_part(damage_state, body_part,species_blood = "")
	var/icon/I = damage_icon_parts["[damage_state]/[body_part]/[species_blood]"]
	if(!I)
		var/icon/DI = icon('icons/mob/dam_human.dmi', damage_state)			// the damage icon for whole human
		DI.Blend(icon('icons/mob/dam_mask.dmi', body_part), ICON_MULTIPLY)	// mask with this organ's pixels
		if(species_blood)
			DI.Blend(species_blood, ICON_MULTIPLY)							// mask with this species's blood color
		damage_icon_parts["[damage_state]/[body_part]/[species_blood]"] = DI
		return DI
	else
		return I

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(var/update_icons=1)
	// first check whether something actually changed about damage appearance
	/*for(var/datum/organ/external/O in organs)
		if(O.status & ORGAN_DESTROYED) damage_appearance += "d"
		else
			damage_appearance += O.damage_state
	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return
	previous_damage_appearance = damage_appearance
	*/

	var/image/standing_image = image('icons/mob/dam_human.dmi', "blank")

	// blend the individual damage states with our icons
	for(var/datum/organ/external/O in organs)
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00") continue

			var/icon/DI

			DI = get_damage_icon_part(O.damage_state, O.icon_name, (species.blood_color == "#A10808" ? "" : species.blood_color))

			standing_image.overlays += DI
	var/obj/Overlays/O = obj_overlays[DAMAGE_LAYER]
	overlays -= O
	O.overlays.len = 0
	O.overlays += standing_image
	obj_to_plane_overlay(O,DAMAGE_LAYER)
	//overlays_standing[DAMAGE_LAYER]	= standing_image



	if(update_icons)   update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons=1)


	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (M_HUSK in src.mutations)  //100% unnecessary -Agouri	//nope, do you really want to iterate through src.mutations repeatedly? -Pete
	var/fat = (M_FAT in src.mutations) && (species && species.flags & CAN_BE_FAT)
	var/hulk = (M_HULK in src.mutations) && species.name == "Horror" // Part of the species.
	var/skeleton = (SKELETON in src.mutations)

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	var/datum/organ/external/chest = get_organ(LIMB_CHEST)
	stand_icon = chest.get_icon(g,fat)
	if(!skeleton)
		if(husk)
			stand_icon.ColorTone(husk_color_mod)
		else if(hulk)
			var/list/TONE = ReadRGB(hulk_color_mod)
			stand_icon.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

	var/datum/organ/external/head = get_organ(LIMB_HEAD)
	var/has_head = 0
	if(head && !(head.status & ORGAN_DESTROYED))
		has_head = 1

	for(var/datum/organ/external/part in organs)
		if(!istype(part, /datum/organ/external/chest) && !(part.status & ORGAN_DESTROYED))
			var/icon/temp
			if (istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
				temp = part.get_icon(g,fat)
			else
				temp = part.get_icon()

			if(part.status & ORGAN_DEAD)
				temp.ColorTone(necrosis_color_mod)
				temp.SetIntensity(0.7)

			else if(!skeleton)
				if(husk)
					temp.ColorTone(husk_color_mod)
				else if(hulk)
					var/list/TONE = ReadRGB(hulk_color_mod)
					temp.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position&(LEFT|RIGHT))
				var/icon/temp2 = new('icons/mob/human.dmi',"blank")
				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)
				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				stand_icon.Blend(temp2, ICON_OVERLAY)
				temp2 = new('icons/mob/human.dmi',"blank")
				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				stand_icon.Blend(temp2, ICON_UNDERLAY)
			else
				stand_icon.Blend(temp, ICON_OVERLAY)

	//Skin tone
	if(!skeleton && !husk && !hulk && (species.flags & HAS_SKIN_TONE))
		if(s_tone >= 0)
			stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	if(husk)
		var/icon/mask = new(stand_icon)
		var/icon/husk_over = new(race_icon,"overlay_husk")
		mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
		husk_over.Blend(mask, ICON_ADD)
		stand_icon.Blend(husk_over, ICON_OVERLAY)

	if(has_head)
		//Eyes
		if(!skeleton)
			var/icon/eyes = new/icon('icons/mob/human_face.dmi', species.eyes)
			eyes.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
			stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style && (species && species.flags & HAS_LIPS))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)

	//Underwear
	if(underwear >0 && underwear < 12 && species.flags & HAS_UNDERWEAR)
		if(!fat && !skeleton)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

	if(update_icons)
		update_icons()

	//tail
	update_tail_showing(0)


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair(var/update_icons=1)
	//Reset our hair

	overlays -= obj_overlays[HAIR_LAYER]

	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if( !head_organ || (head_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our hair.
	if(check_hidden_head_flags(HIDEHEADHAIR) && check_hidden_head_flags(HIDEBEARDHAIR))
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")

	if(f_style && !check_hidden_head_flags(HIDEBEARDHAIR))
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if((facial_hair_style) && (src.species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_standing.Blend(facial_s, ICON_OVERLAY)
		else
			warning("Invalid f_style for [species.name]: [f_style]")

	if(h_style && !check_hidden_head_flags(HIDEHEADHAIR))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if((hair_style) && (src.species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			if(hair_style.additional_accessories)
				hair_s.Blend(icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_acc"), ICON_OVERLAY)

			face_standing.Blend(hair_s, ICON_OVERLAY)
		else
			warning("Invalid h_style for [species.name]: [h_style]")

	//overlays_standing[HAIR_LAYER]	= image(face_standing)
	var/image/I = image(face_standing)
	var/obj/Overlays/O = obj_overlays[HAIR_LAYER]
	O.icon = I
	O.icon_state = I.icon_state
	obj_to_plane_overlay(O,HAIR_LAYER)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_mutations(var/update_icons=1)

	var/fat
	if(M_FAT in mutations)
		fat = "fat"

	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi')
	overlays -= obj_overlays[MUTATIONS_LAYER]
	var/obj/Overlays/O = obj_overlays[MUTATIONS_LAYER]
	O.overlays.len = 0
	O.underlays.len = 0

	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	// DNA2 - Drawing underlays.
	var/hulk = 0
	for(var/gene_type in active_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		if(!gene.block)
			continue
		if(gene.name == "Hulk") hulk = 1
		var/underlay=gene.OnDrawUnderlays(src,g,fat)
		if(underlay)
			//standing.underlays += underlay
			O.underlays += underlay
			add_image = 1
	for(var/mut in mutations)
		switch(mut)
			if(M_HULK)
				if(!hulk)
					if(fat)
						standing.underlays	+= "hulk_[fat]_s"
					else
						standing.underlays	+= "hulk_[g]_s"
					add_image = 1
			/*if(M_RESIST_COLD)
				standing.underlays	+= "fire[fat]_s"
				add_image = 1
			if(M_RESIST_HEAT)
				standing.underlays	+= "cold[fat]_s"
				add_image = 1
			if(TK)
				standing.underlays	+= "telekinesishead[fat]_s"
				add_image = 1
			*/
			if(M_LASER)
				//standing.overlays += image(icon = standing.icon, icon_state = "lasereyes_s")
				O.overlays += image(icon = O.icon, icon_state = "lasereyes_s")
				add_image = 1
	if((M_RESIST_COLD in mutations) && (M_RESIST_HEAT in mutations))
		//standing.underlays	-= "cold[fat]_s"
		//standing.underlays	-= "fire[fat]_s"
		//standing.underlays	+= "coldfire[fat]_s"
		O.underlays	-= "cold[fat]_s"
		O.underlays	-= "fire[fat]_s"
		O.underlays	+= "coldfire[fat]_s"

	if(add_image)
		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,MUTATIONS_LAYER)
		//overlays_standing[MUTATIONS_LAYER]	= standing
	//else
		//overlays_standing[MUTATIONS_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/proc/update_mutantrace(var/update_icons=1)


	var/fat
	if( M_FAT in mutations )
		fat = "fat"
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"
//BS12 EDIT
	var/skeleton = (SKELETON in src.mutations)
	if(skeleton)
		race_icon = 'icons/mob/human_races/r_skeleton.dmi'
	else
		//Icon data is kept in species datums within the mob.
		if(species && istype(species, /datum/species))
			species.updatespeciescolor(src)
		race_icon = species.icobase
		deform_icon = species.deform
	overlays -= obj_overlays[MUTANTRACE_LAYER]

	if(dna)
		switch(dna.mutantrace)
			if("golem","slime","shadow","adamantine","coalgolem")
				if(species && (!species.override_icon && species.has_mutant_race))
					var/obj/Overlays/O = obj_overlays[MUTANTRACE_LAYER]
					O.icon = 'icons/effects/genetics.dmi'
					O.icon_state = "[dna.mutantrace][fat]_[gender]_s"
					obj_to_plane_overlay(O,MUTANTRACE_LAYER)
				//overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_s")
			//else
				//overlays_standing[MUTANTRACE_LAYER]	= null

	if(!dna || !(dna.mutantrace in list("golem","metroid")))
		update_body(0)

	update_hair(0)
	if(update_icons)   update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted(var/update_icons=1)
	overlays -= obj_overlays[TARGETED_LAYER]
	if (targeted_by && target_locked)
		var/obj/Overlays/O = obj_overlays[TARGETED_LAYER]
		O.icon = target_locked
		O.icon_state = "locking" //Does not update to "locked" sprite, need to find a way to get icon_state from an image, or rewrite Targeted() proc
		obj_to_plane_overlay(O,TARGETED_LAYER)
		//overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	//if (!targeted_by)
		//overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)		update_icons()

/mob/living/carbon/human/update_fire(var/update_icons=1)
	overlays -= obj_overlays[FIRE_LAYER]
	if(on_fire)
		var/obj/Overlays/O = obj_overlays[FIRE_LAYER]
		O.icon = fire_dmi
		O.icon_state = fire_sprite
		obj_to_plane_overlay(O,FIRE_LAYER)
		//overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_sprite, "layer"=-FIRE_LAYER)
	//else
		//overlays_standing[FIRE_LAYER] = null
	if(update_icons)		update_icons()


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()//Changing the order of those procs doesn't change which layer appears on top! That's what the defines in setup.dm are for.
	..()
	if(monkeyizing)		return
	update_fire(0)
	update_mutations(0)
	update_mutantrace(0)
	update_inv_w_uniform(0)
	update_inv_gloves(0)
	update_inv_glasses(0)
	update_inv_ears(0)
	update_inv_shoes(0)
	update_inv_s_store(0)
	update_inv_wear_mask(0)
	update_inv_head(0)
	update_inv_belt(0)
	update_inv_back(0)
	update_inv_wear_suit(0)
	update_inv_wear_id(0)
	update_inv_hands(0)
	update_inv_handcuffed(0)
	update_inv_legcuffed(0)
	update_inv_pockets(0)
	QueueUpdateDamageIcon(1)
	update_icons()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(var/update_icons=1)

	overlays -= obj_overlays[UNIFORM_LAYER]
	if(w_uniform && istype(w_uniform, /obj/item/clothing/under) && !check_hidden_body_flags(HIDEJUMPSUIT))
		w_uniform.screen_loc = ui_iclothing
		var/obj/Overlays/O = obj_overlays[UNIFORM_LAYER]
		O.overlays.len = 0
		var/t_color = w_uniform._color
		if(!t_color)		t_color = icon_state
		var/image/standing	= image("icon_state" = "[t_color]_s")

		if(((M_FAT in mutations) && (species.flags & CAN_BE_FAT)) || species.flags & IS_BULKY)
			if(w_uniform.flags&ONESIZEFITSALL)
				standing.icon	= 'icons/mob/uniform_fat.dmi'
			else
				to_chat(src, "<span class='warning'>You burst out of \the [w_uniform]!</span>")
				drop_from_inventory(w_uniform)
				return
		else
			standing.icon	= 'icons/mob/uniform.dmi'

		var/obj/item/clothing/under/under_uniform = w_uniform

		if(species.name in under_uniform.species_fit) //Allows clothes to display differently for multiple species
			if(species.uniform_icons)
				standing.icon = species.uniform_icons

		if(w_uniform.icon_override)
			standing.icon	= w_uniform.icon_override

		if(w_uniform.dynamic_overlay)
			if(w_uniform.dynamic_overlay["[UNIFORM_LAYER]"])
				var/image/dyn_overlay = w_uniform.dynamic_overlay["[UNIFORM_LAYER]"]
				O.overlays += dyn_overlay

		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
			bloodsies.color		= w_uniform.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies

		under_uniform.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,UNIFORM_LAYER)
		//overlays_standing[UNIFORM_LAYER]	= standing
	else if (!check_hidden_body_flags(HIDEJUMPSUIT))
		//overlays_standing[UNIFORM_LAYER]	= null
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for( var/obj/item/thing in list(r_store, l_store, wear_id, belt) )						//
			if(thing)																			//
				u_equip(thing,1)																//
				if (client)																		//
					client.screen -= thing														//
																								//
				if (thing)																		//
					thing.loc = loc																//
					//thing.dropped(src)														//
					thing.layer = initial(thing.layer)
					thing.plane = initial(thing.plane)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_wear_id(var/update_icons=1)
	overlays -= obj_overlays[ID_LAYER]
	if(wear_id)
		wear_id.screen_loc = ui_id	//TODO
		if(w_uniform && w_uniform:displays_id)
			var/obj/Overlays/O = obj_overlays[ID_LAYER]
			var/obj/item/weapon/card/ID_worn = wear_id
			O.icon = 'icons/mob/ids.dmi'
			O.icon_state = ID_worn.icon_state
			O.overlays.len = 0
			if(wear_id.dynamic_overlay)
				if(wear_id.dynamic_overlay["[ID_LAYER]"])
					var/image/dyn_overlay = wear_id.dynamic_overlay["[ID_LAYER]"]
					O.overlays += dyn_overlay
			obj_to_plane_overlay(O,ID_LAYER)
			//overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")
		//else
			//overlays_standing[ID_LAYER]	= null
	//else
		//overlays_standing[ID_LAYER]	= null

	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_gloves(var/update_icons=1)
	overlays -= obj_overlays[GLOVES_LAYER]
	var/obj/Overlays/O = obj_overlays[GLOVES_LAYER]
	O.overlays.len = 0
	O.color = null
	if(gloves && !check_hidden_body_flags(HIDEGLOVES))


		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/standing	= image("icon" = ((gloves.icon_override) ? gloves.icon_override : 'icons/mob/hands.dmi'), "icon_state" = "[t_state]")

		var/obj/item/I = gloves

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_gloves, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.gloves_icons)
				standing.icon = S.gloves_icons


		if(gloves.dynamic_overlay)
			if(gloves.dynamic_overlay["[GLOVES_LAYER]"])
				var/image/dyn_overlay = gloves.dynamic_overlay["[GLOVES_LAYER]"]
				O.overlays += dyn_overlay

		if(gloves.blood_DNA && gloves.blood_DNA.len)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
			O.overlays += bloodsies
		gloves.screen_loc = ui_gloves

		gloves.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,GLOVES_LAYER)
		//overlays_standing[GLOVES_LAYER]	= standing
	else
		if(blood_DNA && blood_DNA.len)
			O.icon = 'icons/effects/blood.dmi'
			O.icon_state = "bloodyhands"
			O.color = hand_blood_color
			//var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			//bloodsies.color = hand_blood_color
			//overlays_standing[GLOVES_LAYER]	= bloodsies
			obj_to_plane_overlay(O,GLOVES_LAYER)
		//else
			//overlays_standing[GLOVES_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_glasses(var/update_icons=1)
	overlays -= obj_overlays[GLASSES_LAYER]
	overlays -= obj_overlays[GLASSES_OVER_HAIR_LAYER]
	if(glasses && !check_hidden_head_flags(HIDEEYES))
		var/image/standing = image("icon" = ((glasses.icon_override) ? glasses.icon_override : 'icons/mob/eyes.dmi'), "icon_state" = "[glasses.icon_state]")

		var/obj/item/I = glasses

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.glasses_icons)
				standing.icon = S.glasses_icons

		if(glasses.cover_hair)
			var/obj/Overlays/O = obj_overlays[GLASSES_OVER_HAIR_LAYER]
			O.icon = standing
			O.icon_state = standing.icon_state
			O.overlays.len = 0
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"])
					var/image/dyn_overlay = glasses.dynamic_overlay["[GLASSES_OVER_HAIR_LAYER]"]
					O.overlays += dyn_overlay
			obj_to_plane_overlay(O,GLASSES_OVER_HAIR_LAYER)
			//overlays_standing[GLASSES_OVER_HAIR_LAYER]	= standing
		else
			var/obj/Overlays/O = obj_overlays[GLASSES_LAYER]
			O.icon = standing
			O.icon_state = standing.icon_state
			O.overlays.len = 0
			if(glasses.dynamic_overlay)
				if(glasses.dynamic_overlay["[GLASSES_LAYER]"])
					var/image/dyn_overlay = glasses.dynamic_overlay["[GLASSES_LAYER]"]
					O.overlays += dyn_overlay
			obj_to_plane_overlay(O,GLASSES_LAYER)
			//overlays_standing[GLASSES_LAYER]	= standing


	//else
		//overlays_standing[GLASSES_LAYER]	= null
		//overlays_standing[GLASSES_OVER_HAIR_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_ears(var/update_icons=1)

	overlays -= obj_overlays[EARS_LAYER]
	if(ears && !check_hidden_head_flags(HIDEEARS))
		var/image/standing = image("icon" = ((ears.icon_override) ? ears.icon_override : 'icons/mob/ears.dmi'), "icon_state" = "[ears.icon_state]")

		var/obj/item/I = ears

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.ears_icons)
				standing.icon = S.ears_icons

		var/obj/Overlays/O = obj_overlays[EARS_LAYER]
		O.icon = standing
		O.icon_state = standing.icon_state
		O.overlays.len = 0
		if(ears.dynamic_overlay)
			if(ears.dynamic_overlay["[EARS_LAYER]"])
				var/image/dyn_overlay = ears.dynamic_overlay["[EARS_LAYER]"]
				O.overlays += dyn_overlay
		obj_to_plane_overlay(O,EARS_LAYER)
		//overlays_standing[EARS_LAYER] = standing
	//else
		//overlays_standing[EARS_LAYER] = null

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_shoes(var/update_icons=1)
	overlays -= obj_overlays[SHOES_LAYER]
	if(shoes && !check_hidden_body_flags(HIDESHOES))
		var/obj/Overlays/O = obj_overlays[SHOES_LAYER]
		O.icon = ((shoes.icon_override) ? shoes.icon_override : 'icons/mob/feet.dmi')
		O.icon_state = shoes.icon_state
		//var/image/standing	= image("icon" = ((shoes.icon_override) ? shoes.icon_override : 'icons/mob/feet.dmi'), "icon_state" = "[shoes.icon_state]")

		var/obj/item/I = shoes

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_shoes, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.gloves_icons)
				O.icon = S.shoes_icons

		O.overlays.len = 0
		if(shoes.dynamic_overlay)
			if(shoes.dynamic_overlay["[SHOES_LAYER]"])
				var/image/dyn_overlay = shoes.dynamic_overlay["[SHOES_LAYER]"]
				O.overlays += dyn_overlay
		if(shoes.blood_DNA && shoes.blood_DNA.len)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
			bloodsies.color = shoes.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies
		//overlays_standing[SHOES_LAYER]	= standing

		shoes.generate_accessory_overlays(O)

		obj_to_plane_overlay(O,SHOES_LAYER)
	//else
		//overlays_standing[SHOES_LAYER]		= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_s_store(var/update_icons=1)
	overlays -= obj_overlays[SUIT_STORE_LAYER]
	if(s_store)
		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		var/obj/Overlays/O = obj_overlays[SUIT_STORE_LAYER]
		O.icon = 'icons/mob/belt_mirror.dmi'
		O.icon_state = t_state
		O.overlays.len = 0
		if(s_store.dynamic_overlay)
			if(s_store.dynamic_overlay["[SUIT_STORE_LAYER]"])
				var/image/dyn_overlay = s_store.dynamic_overlay["[SUIT_STORE_LAYER]"]
				O.overlays += dyn_overlay
		obj_to_plane_overlay(O,SUIT_STORE_LAYER)
		//overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]")
		s_store.screen_loc = ui_sstore1		//TODO
	//else
		//overlays_standing[SUIT_STORE_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_head(var/update_icons=1)
	overlays -= obj_overlays[HEAD_LAYER]
	if(head)
		var/obj/Overlays/O = obj_overlays[HEAD_LAYER]
		O.overlays.len = 0
		head.screen_loc = ui_head		//TODO
		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty)) //AAAAUUUGH
			standing	= image("icon" = head:mob)
		else
			standing	= image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]")

		var/obj/item/I = head

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_head, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.head_icons)
				standing.icon = S.head_icons

		if(head.dynamic_overlay)
			if(head.dynamic_overlay["[HEAD_LAYER]"])
				var/image/dyn_overlay = head.dynamic_overlay["[HEAD_LAYER]"]
				O.overlays += dyn_overlay

		if(head.blood_DNA && head.blood_DNA.len)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			//standing.overlays	+= bloodsies
			O.overlays	+= bloodsies

		head.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,HEAD_LAYER)
		//overlays_standing[HEAD_LAYER]	= standing
	//else
		//overlays_standing[HEAD_LAYER]	= null

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_belt(var/update_icons=1)
	overlays -= obj_overlays[BELT_LAYER]
	if(belt)
		belt.screen_loc = ui_belt	//TODO
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		var/image/standing = image("icon" = ((belt.icon_override) ? belt.icon_override : 'icons/mob/belt.dmi'), "icon_state" = "[t_state]")

		var/obj/item/I = belt

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_belt, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.belt_icons)
				standing.icon = S.belt_icons

		var/obj/Overlays/O = obj_overlays[BELT_LAYER]
		O.icon = standing
		O.icon_state = standing.icon_state
		O.overlays.len = 0
		if(belt.dynamic_overlay)
			if(belt.dynamic_overlay["[BELT_LAYER]"])
				var/image/dyn_overlay = belt.dynamic_overlay["[BELT_LAYER]"]
				O.overlays += dyn_overlay
		obj_to_plane_overlay(O,BELT_LAYER)
		//overlays_standing[BELT_LAYER]	= standing
	//else
		//overlays_standing[BELT_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_wear_suit(var/update_icons=1)
	overlays -= obj_overlays[SUIT_LAYER]
	if( wear_suit && istype(wear_suit, /obj/item/clothing/suit) )	//TODO check this
		wear_suit.screen_loc = ui_oclothing	//TODO
		var/obj/Overlays/O = obj_overlays[SUIT_LAYER]
		O.overlays.len = 0
		var/image/standing	= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[wear_suit.icon_state]")
		if((((M_FAT in mutations) && (species.flags & CAN_BE_FAT)) || (species.flags & IS_BULKY)) && !(wear_suit.icon_override))
			if(wear_suit.flags&ONESIZEFITSALL)
				standing.icon	= 'icons/mob/suit_fat.dmi'
			else
				to_chat(src, "<span class='warning'>You burst out of \the [wear_suit]!</span>")
				drop_from_inventory(wear_suit)

		if( istype(wear_suit, /obj/item/clothing/suit/straight_jacket) )
			drop_from_inventory(handcuffed)
			drop_hands()

		var/datum/species/SP = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_suit, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				SP = OE.species
				break

		if(SP.name in wear_suit.species_fit) //Allows clothes to display differently for multiple species
			if(SP.wear_suit_icons)
				standing.icon = SP.wear_suit_icons

		if(wear_suit.dynamic_overlay)
			if(wear_suit.dynamic_overlay["[SUIT_LAYER]"])
				var/image/dyn_overlay = wear_suit.dynamic_overlay["[SUIT_LAYER]"]
				O.overlays += dyn_overlay

		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/C = wear_suit
			if(C.blood_DNA && C.blood_DNA.len)
				var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[C.blood_overlay_type]blood")
				bloodsies.color = wear_suit.blood_color
				//standing.overlays	+= bloodsies
				O.overlays	+= bloodsies

		wear_suit.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,SUIT_LAYER)
		//overlays_standing[SUIT_LAYER]	= standing
		update_tail_showing(0)
	else
		//overlays_standing[SUIT_LAYER]	= null
		update_tail_showing(0)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_pockets(var/update_icons=1)

	if(l_store)			l_store.screen_loc = ui_storage1	//TODO
	if(r_store)			r_store.screen_loc = ui_storage2	//TODO
	if(update_icons)	update_icons()


/mob/living/carbon/human/update_inv_wear_mask(var/update_icons=1)
	overlays -= obj_overlays[FACEMASK_LAYER]
	if( wear_mask && !check_hidden_head_flags(HIDEMASK))
		var/obj/Overlays/O = obj_overlays[FACEMASK_LAYER]
		O.overlays.len = 0
		wear_mask.screen_loc = ui_mask	//TODO
		var/image/standing	= image("icon" = ((wear_mask.icon_override) ? wear_mask.icon_override : 'icons/mob/mask.dmi'), "icon_state" = "[wear_mask.icon_state]")

		var/obj/item/I = wear_mask

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_wear_mask, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.wear_mask_icons)
				standing.icon = S.wear_mask_icons

		if(wear_mask.dynamic_overlay)
			if(wear_mask.dynamic_overlay["[FACEMASK_LAYER]"])
				var/image/dyn_overlay = wear_mask.dynamic_overlay["[FACEMASK_LAYER]"]
				O.overlays += dyn_overlay

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA && wear_mask.blood_DNA.len )
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
			bloodsies.color = wear_mask.blood_color
			//standing.overlays	+= bloodsies
			O.overlays += bloodsies

		wear_mask.generate_accessory_overlays(O)

		O.icon = standing
		O.icon_state = standing.icon_state
		obj_to_plane_overlay(O,FACEMASK_LAYER)
		//overlays_standing[FACEMASK_LAYER]	= standing
	//else
		//overlays_standing[FACEMASK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_back(var/update_icons=1)
	overlays -= obj_overlays[BACK_LAYER]
	if(back)
		back.screen_loc = ui_back	//TODO
		var/image/standing	= image("icon" = ((back.icon_override) ? back.icon_override : 'icons/mob/back.dmi'), "icon_state" = "[back.icon_state]")

		var/obj/item/I = back

		var/datum/species/S = species
		for(var/datum/organ/external/OE in get_organs_by_slot(slot_back, src)) //Display species-exclusive species correctly on attached limbs
			if(OE.species)
				S = OE.species
				break

		if(S.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(S.back_icons)
				standing.icon = S.back_icons

		var/obj/Overlays/O = obj_overlays[BACK_LAYER]
		O.icon = standing
		O.icon_state = standing.icon_state
		O.overlays.len = 0
		if(back.dynamic_overlay)
			if(back.dynamic_overlay["[BACK_LAYER]"])
				var/image/dyn_overlay = back.dynamic_overlay["[BACK_LAYER]"]
				O.overlays += dyn_overlay
		obj_to_plane_overlay(O,BACK_LAYER)

		//overlays_standing[BACK_LAYER]	= standing
	//else
		//overlays_standing[BACK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed(var/update_icons=1)
	overlays -= obj_overlays[HANDCUFF_LAYER]
	if(handcuffed)
		drop_hands()
		stop_pulling()	//TODO: should be handled elsewhere
		var/obj/Overlays/O = obj_overlays[HANDCUFF_LAYER]
		O.icon = 'icons/mob/mob.dmi'
		O.icon_state = "handcuff1"
		obj_to_plane_overlay(O,HANDCUFF_LAYER)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_legcuffed(var/update_icons=1)
	overlays -= obj_overlays[LEGCUFF_LAYER]
	if(legcuffed)
		var/obj/Overlays/O = obj_overlays[LEGCUFF_LAYER]
		O.icon = 'icons/mob/mob.dmi'
		O.icon_state = "legcuff1"
		obj_to_plane_overlay(O,LEGCUFF_LAYER)
		//overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1")
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

	//elsek
		//overlays_standing[LEGCUFF_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_hand(index, var/update_icons = 1)
	var/obj/Overlays/hand_layer/O = obj_overlays[HAND_LAYER]
	overlays.Remove(O)

	var/obj/Overlays/new_item_overlay

	for(var/obj/Overlays/OV in O.hands_overlays) //Go through all item overlays and remove those with the same index
		if(OV.name == "[index]")
			O.overlays.Remove(OV)
			new_item_overlay = OV

	var/obj/item/I = get_held_item_by_index(index)

	if(I)
		var/t_state = I.item_state
		var/t_inhand_state = I.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		if(!t_state)	t_state = I.icon_state

		if(!new_item_overlay)
			new_item_overlay = new()

			if(!istype(O.hands_overlays, /list)) O.hands_overlays = list()
			O.hands_overlays.Add(new_item_overlay)

		new_item_overlay.name = "[index]"
		new_item_overlay.icon = t_inhand_state
		new_item_overlay.icon_state = t_state
		new_item_overlay.pixel_x = -1*(check_dimensions.Width() - 32)/2
		new_item_overlay.pixel_y = -1*(check_dimensions.Height() - 32)/2
		new_item_overlay.layer = O.layer

		var/list/offsets = get_item_offset_by_index(index)

		new_item_overlay.pixel_x += offsets["x"]
		new_item_overlay.pixel_y += offsets["y"]

		if(I.dynamic_overlay && I.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/image/dyn_overlay = I.dynamic_overlay["[HAND_LAYER]-[index]"]
			new_item_overlay.overlays.Add(dyn_overlay)
		I.screen_loc = get_held_item_ui_location(index)

		O.overlays.Add(new_item_overlay)

		if(handcuffed)
			drop_item(I)

	overlays.Add(O)

	if(update_icons)
		update_icons()

/mob/living/carbon/human/update_inv_r_hand(var/update_icons=1)
	return update_inv_hand(GRASP_RIGHT_HAND, update_icons)

/mob/living/carbon/human/update_inv_l_hand(var/update_icons=1)
	return update_inv_hand(GRASP_LEFT_HAND, update_icons)

/mob/living/carbon/human/proc/update_tail_showing(var/update_icons=1)
	//overlays_standing[TAIL_LAYER] = null
	overlays -= obj_overlays[TAIL_LAYER]
	if(species && species.tail && species.flags & HAS_TAIL)
		if(!wear_suit || !is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT))
			var/obj/Overlays/O = obj_overlays[TAIL_LAYER]
			O.icon = 'icons/effects/species.dmi'
			O.icon_state = "[species.tail]_s"
			obj_to_plane_overlay(O,TAIL_LAYER)
			//if(!old_tail_state) //only update if we didnt show our tail already

				//overlays_standing[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_s")
//				to_chat(src, "update: tail is different")
		//else
			//overlays_standing[TAIL_LAYER] = null

	if(update_icons)
		update_icons()

// Used mostly for creating head items
/mob/living/carbon/human/proc/generate_head_icon()
//gender no longer matters for the mouth, although there should probably be seperate base head icons.
//	var/g = "m"
//	if (gender == FEMALE)	g = "f"

	//base icons
	var/icon/face_lying		= new /icon('icons/mob/human_face.dmi',"bald_l")

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
			facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	if(h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
			hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			face_lying.Blend(hair_l, ICON_OVERLAY)

	//Eyes
	// Note: These used to be in update_face(), and the fact they're here will make it difficult to create a disembodied head
	var/icon/eyes_l = new/icon('icons/mob/human_face.dmi', "eyes_l")
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	face_lying.Blend(eyes_l, ICON_OVERLAY)

	if(lip_style)
		face_lying.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_l"), ICON_OVERLAY)

	var/image/face_lying_image = new /image(icon = face_lying)
	return face_lying_image

//lower cost way of updating the necessary human icons on equip and unequip
/mob/living/carbon/human/proc/update_hidden_item_icons(var/obj/item/W)
	if(!W)
		return

	if(is_slot_hidden(W.body_parts_covered,HIDEHEADHAIR) || is_slot_hidden(W.body_parts_covered,HIDEBEARDHAIR))
		update_hair()
	if(is_slot_hidden(W.body_parts_covered,(HIDEMASK)))
		update_inv_wear_mask()
	if(is_slot_hidden(W.body_parts_covered,(HIDEGLOVES)))
		update_inv_gloves()
	if(is_slot_hidden(W.body_parts_covered,HIDESHOES))
		update_inv_shoes()
	if(is_slot_hidden(W.body_parts_covered,(HIDEJUMPSUIT)))
		update_inv_w_uniform()
	if(is_slot_hidden(W.body_parts_covered,(HIDEEYES)))
		update_inv_glasses()
	if(is_slot_hidden(W.body_parts_covered, (HIDEEARS)))
		update_inv_ears()

proc/is_slot_hidden(var/clothes, var/slot = -1,var/ignore_slot = 0)
	if(!clothes)
		return 0
	var/true_body_parts_covered = clothes
	if(slot == -1)
		slot = true_body_parts_covered
	if(true_body_parts_covered & IGNORE_INV)
		true_body_parts_covered = 0
	if(true_body_parts_covered & ignore_slot)
		true_body_parts_covered ^= ignore_slot
	if((true_body_parts_covered & slot) == slot)
		return 1
	return 0

/mob/living/carbon/human/proc/update_inv_by_slot(var/slot_flags) //Yeah this is pretty shit but I couldn't find a better way
	if(slot_flags & SLOT_BACK)
		update_inv_back()
	if(slot_flags & SLOT_MASK)
		update_inv_wear_mask()
	if(slot_flags & SLOT_BELT)
		update_inv_belt()
	if(slot_flags & SLOT_EARS)
		update_inv_ears()
	if(slot_flags & SLOT_EYES)
		update_inv_glasses()
	if(slot_flags & SLOT_GLOVES)
		update_inv_gloves()
	if(slot_flags & SLOT_HEAD)
		update_inv_head()
	if(slot_flags & SLOT_FEET)
		update_inv_shoes()
	if(slot_flags & SLOT_OCLOTHING)
		update_inv_wear_suit()
	if(slot_flags & SLOT_ICLOTHING)
		update_inv_w_uniform()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
