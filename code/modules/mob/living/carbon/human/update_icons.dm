	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys //more like 27
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

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations() //handles updating your appearance for certain mutations. e.g TK head-glows
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's icon_state (using update_base_icon_state())
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())

>	I repurposed an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.
	//NOTE: fairly unused, maybe this could be removed?

If you have any questions/constructive-comments/bugs-to-report
Please contact me on #coderbus IRC. ~Carnie x
//Carn can sometimes be hard to reach now. However IRC is still your best bet for getting help.
*/

/*
	Most of the new overlay-based human rendering system here is RemieRichards' work, but never made it in-game.
	I adapted the system (with permission) for the update to a datum-based organ system.
	|- Ricotez
*/
/*
//Human Overlays Indexes///////// Seemingly defined in misc.dm so I'm commenting this out
#define SPECIES_LAYER			27		// mutantrace colors... these are on a seperate layer in order to prvent
#define BODY_BEHIND_LAYER		26
#define BODY_LAYER				25		//underwear, undershirts, socks, eyes, lips(makeup)
#define BODY_ADJ_LAYER			24
#define MUTATIONS_LAYER			23		//Tk headglows etc.
#define BODYPARTS_LAYER			22
#define AUGMENTS_LAYER			21
#define DAMAGE_LAYER			20		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			19
#define ID_LAYER				18
#define SHOES_LAYER				17
#define GLOVES_LAYER			16
#define EARS_LAYER				15
#define SUIT_LAYER				14
#define GLASSES_LAYER			13
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		11
#define BACK_LAYER				10
#define HAIR_LAYER				9		//TODO: make part of head layer?
#define FACEMASK_LAYER			8
#define HEAD_LAYER				7
#define HANDCUFF_LAYER			6
#define LEGCUFF_LAYER			5
#define L_HAND_LAYER			4
#define R_HAND_LAYER			3		//Having the two hands seperate seems rather silly, merge them together? It'll allow for code to be reused on mobs with arbitarily many hands
#define BODY_FRONT_LAYER		2
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			27		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
//////////////////////////////////
*/

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/human/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]

	if(I)
		overlays += I

/mob/living/carbon/human/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

//UPDATES OVERLAYS FROM OVERLAYS_STANDING
//TODO: Remove all instances where this proc is called. It used to be the fastest way to swap between standing/lying.
/mob/living/carbon/human/update_icons()

	update_hud()		//TODO: remove the need for this

	if(overlays.len != overlays_standing.len)
		overlays.Cut()

		for(var/thing in overlays_standing)
			if(thing)	overlays += thing

	update_transform()

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/image/standing	= image("icon"='icons/mob/dam_human.dmi', "icon_state"="blank", "layer"=-DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing

	for(var/datum/organ/limb/limbdata in get_limbs()) //Update this list if we ever want to render more body parts. |- Ricotez
		if(!limbdata.exists())
			continue
		var/obj/item/organ/limb/O = limbdata.organitem
		if(O.brutestate)
			standing.overlays	+= "[O.icon_state]_[O.brutestate]0"	//we're adding icon_states of the base image as overlays
		if(O.burnstate)
			standing.overlays	+= "[O.icon_state]_0[O.burnstate]"

	apply_overlay(DAMAGE_LAYER)


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	var/datum/organ/H = get_organ("head")
	if((HUSK in mutations) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
		return

	if(H.exists() && isorgan(H.organitem))
		var/obj/item/organ/limb/head/HE = H.organitem
		if(HE.dna)
			HE.dna.species.handle_hair(src)

/mob/living/carbon/human/proc/update_mutations()
	remove_overlay(MUTATIONS_LAYER)

/mob/living/carbon/human/proc/update_mutant_bodyparts()
	var/list/standing = list()

	for(var/mut in mutations)
		switch(mut)
			if(COLDRES)
				standing += image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_s", "layer"=-MUTATIONS_LAYER)
			if(TK)
				standing += image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_s", "layer"=-MUTATIONS_LAYER)
			if(LASER)
				standing += image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_s", "layer"=-MUTATIONS_LAYER)
	if(standing.len)
		overlays_standing[MUTATIONS_LAYER] = standing

	apply_overlay(MUTATIONS_LAYER)

/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)

	if(dna)
		dna.species.handle_body(src)

//Temporary solution for a type problem. This will be resolved once I expand organsystems to all subtypes of carbon. |- Ricotez
/mob/living/carbon/proc/update_body_parts()
	return

/mob/living/carbon/human/update_body_parts()
	icon_state = ""//Reset here as apposed to having a null one due to some getFlatIcon calls at roundstart.

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
		update_inv_gloves()
		update_hair()
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/datum/organ/limb/limbdata in get_limbs())
		var/image/temp = generate_limb_icon(limbdata)
		if(temp)
			new_limbs += temp
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	update_body()	//In case we need to remove clothing
	update_hair()	//Ditto for hair

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()
	update_inv_gloves()

/mob/living/carbon/human/update_fire()
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)
	apply_overlay(FIRE_LAYER)

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)		return
	update_body_parts()
	update_body()
	update_hair()
	update_mutations()
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
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_fire()
	update_transform()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return

		var/t_color = w_uniform.item_color
		if(!t_color)		t_color = icon_state

		var/image/standing = image("icon"='icons/mob/uniform.dmi', "icon_state"="[t_color]_s", "layer"=-UNIFORM_LAYER)

		overlays_standing[UNIFORM_LAYER]	= standing

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
				standing	= wear_female_version(t_color, 'icons/mob/uniform.dmi', UNIFORM_LAYER, U.fitted)
				overlays_standing[UNIFORM_LAYER]	= standing

		if(w_uniform.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")

		if(U.hastie)
			var/tie_color = U.hastie.item_color
			if(!tie_color) tie_color = U.hastie.icon_state
			standing.overlays	+= image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]")
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			unEquip(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id	//TODO
		if(client && hud_used)
			client.screen += wear_id

		overlays_standing[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		if(!(exists("l_arm") && exists("r_arm")))
			return

		var/datum/organ/limb/left = get_organ("l_arm")
		var/datum/organ/limb/right = get_organ("r_arm")
		var/obj/item/organ/larm = left.organitem
		var/obj/item/organ/rarm = right.organitem
		if(larm.organtype == ORGAN_WEAPON || rarm.organtype == ORGAN_WEAPON)
			return

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state

		var/image/standing = image("icon"='icons/mob/hands.dmi', "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)

		overlays_standing[GLOVES_LAYER]	= standing

		if(gloves.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

	else
		if(blood_DNA)
			overlays_standing[GLOVES_LAYER] = image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

	apply_overlay(GLOVES_LAYER)



/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		overlays_standing[GLASSES_LAYER] = image("icon"='icons/mob/eyes.dmi', "icon_state"="[glasses.icon_state]", "layer"=-GLASSES_LAYER)

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(ears)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				ears.screen_loc = ui_ears			//...draw the item in the inventory screen
			client.screen += ears					//Either way, add the item to the HUD

		overlays_standing[EARS_LAYER] = image("icon"='icons/mob/ears.dmi', "icon_state"="[ears.icon_state]", "layer"=-EARS_LAYER)

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		if(!(exists("l_leg") && exists("r_leg")))
			return

		var/image/standing = image("icon"='icons/mob/feet.dmi', "icon_state"="[shoes.icon_state]", "layer"=-SHOES_LAYER)

		overlays_standing[SHOES_LAYER]	= standing

		if(shoes.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(s_store)
		s_store.screen_loc = ui_sstore1		//TODO
		if(client && hud_used)
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)

	apply_overlay(SUIT_STORE_LAYER)



/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)				//if the inventory is open ...
				head.screen_loc = ui_head		//TODO	//...draw the item in the inventory screen
			client.screen += head						//Either way, add the item to the HUD

		var/image/standing = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		standing.color = head.color // For now, this is here solely for kitty ears, but everything should do this eventually
		standing.alpha = head.alpha

		overlays_standing[HEAD_LAYER]	= standing

		if(head.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used)
			client.screen += belt

		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state

		var/image/standing = image("icon"='icons/mob/belt.dmi', "icon_state"="[t_state]", "layer"=-BELT_LAYER)

		overlays_standing[BELT_LAYER] = standing

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/image/standing = image("icon"='icons/mob/suit.dmi', "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)

		overlays_standing[SUIT_LAYER] = standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			unEquip(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			standing.overlays+= image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood")

	apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1	//TODO
		if(client && hud_used)
			client.screen += l_store
	if(r_store)
		r_store.screen_loc = ui_storage2	//TODO
		if(client && hud_used)
			client.screen += r_store


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)				//if the inventory is open ...
				wear_mask.screen_loc = ui_mask	//TODO	//...draw the item in the inventory screen
			client.screen += wear_mask					//Either way, add the item to the HUD

		var/image/standing = image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)

		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back

		var/image/standing = image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)

		overlays_standing[BACK_LAYER] = standing

	apply_overlay(BACK_LAYER)



/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		if(hud_used)	//hud handcuff icons
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="markus")
			L.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="gabrielle")

		overlays_standing[HANDCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
	else
		if(hud_used)
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays = null
			L.overlays = null

	apply_overlay(HANDCUFF_LAYER)


/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)

	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)



/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if (handcuffed)
		drop_r_hand()
		return

	if(hud_used)
		var/obj/screen/inventory/R = hud_used.adding[3]
		if(!exists("r_arm"))
			R.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="x")
		else
			R.overlays = null


	if(r_hand)
		r_hand.screen_loc = ui_rhand	//TODO
		if(client)
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_standing[R_HAND_LAYER] = image("icon" = 'icons/mob/inhands/items_righthand.dmi', "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)



/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if (handcuffed)
		drop_l_hand()
		return

	if(hud_used)
		var/obj/screen/inventory/L = hud_used.adding[4]
		if(!exists("l_arm"))
			L.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="x")
		else
			L.overlays = null

	if(l_hand)
		l_hand.screen_loc = ui_lhand	//TODO
		if(client)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_standing[L_HAND_LAYER] = image("icon" = 'icons/mob/inhands/items_lefthand.dmi', "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

/mob/living/carbon/human/proc/wear_female_version(t_color, icon, layer, type)
	var/index = "[t_color]_s"
	var/icon/female_clothing_icon = female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index,t_color,icon,type)
	var/standing	= image("icon"=female_clothing_icons["[t_color]_s"], "layer"=-layer)
	return(standing)



/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- race (a local variable to these procs which simplifies mutantraces for these procs)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste

	See RemieRichards on irc.rizon.net #coderbus
*/


var/global/list/limb_icon_cache = list()

/mob/living/carbon/human
	var/icon_render_key = ""

//simplifies species and mutations into one var
/obj/item/organ/limb/proc/get_race()

	var/sm_type = "human"
	if(dna)
		var/datum/species/race = dna ? dna.species : null
		if(race)
			sm_type = race.id

		if(HULK in dna.mutations)
			sm_type = "hulk"
		if(HUSK in dna.mutations)
			sm_type = "husk"
	else sm_type = "non-human"
	return sm_type

/obj/item/organ/limb/proc/has_color()

	if(dna)
		var/datum/species/race = dna ? dna.species : null
		if(race)
			if(MUTCOLORS in race.specflags)
				return 1
	return 0

/obj/item/organ/limb/proc/has_gender()

	//Robot limbs have gendered appearance, but no DNA
	if(organtype == ORGAN_ROBOTIC)
		return 1
	if(dna)
		var/datum/species/race = dna ? dna.species : null
		if(race)
			return race.sexes
	return 0

//produces a key based on the human's limbs
/mob/living/carbon/human/proc/generate_icon_render_key()
	. += "-[gender]"

	for(var/limbname in organsystem.organlist)
		. += "-[initial(limbname)]"
		var/datum/organ/limb/limbdata = get_organ(limbname)
		if(!limbdata.exists())
			. += "-removed"
		else
			if(istype(limbdata.organitem, /obj/item/organ/limb/))
				var/obj/item/organ/limb/LI = limbdata.organitem
				. += "-fine"
				if(!(LI.organtype & ORGAN_ROBOTIC))
					. += "-organic"
					var/race = LI.get_race()
					. += "[race]"
					switch(race)
						if("human" || "plant" || "lizard")
							. += "-coloured-[LI.dna.mutant_color]"
						else
							. += "-not_coloured"
				else
					. += "-robotic"

//change the human's icon to the one matching it's key
/mob/living/carbon/human/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)


//draws an icon from a limb
/mob/living/carbon/human/proc/generate_limb_icon(var/datum/organ/limb/affecting)
	if(!affecting.exists()) //If the limb does not exist, we render nothing right now.
		if(affecting.status & ORGAN_DESTROYED || affecting.status & ORGAN_NOBLEED)
			return 0	//I'll replace this with bloody stumps for destroyed limbs as soon as the sprites are ready. |- Ricotez
		else return 0

	var/obj/item/organ/limb/LI = null
	if(isorgan(affecting.organitem))	//Should always be true!
		LI = affecting.organitem
	else
		return -1
	if(LI.organtype == ORGAN_WEAPON)	//The item handles drawing
		return 0

	var/image/I
	var/should_draw_gender = FALSE
	var/icon_gender = (gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable
	var/race = LI.get_race() //simplified physical appearence of mob
	var/should_draw_greyscale = FALSE

	if((affecting.body_part == HEAD || affecting.body_part == CHEST) && LI.has_gender())
		should_draw_gender = TRUE

	if(LI.has_color())
		should_draw_greyscale = TRUE

	if(LI.organtype == ORGAN_ROBOTIC)
		if(should_draw_gender)
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
		else
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
		if(I)
			return I
		return 0
	else
		if(should_draw_greyscale)
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
			else
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
		else
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
			else
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)

	if(!should_draw_greyscale)
		if(I)
			return I //We're done here
		return 0


	//Greyscale Colouring
	var/draw_color

	if(LI.dna && LI.dna.species)
		if(dna.species.use_skintones || MUTCOLORS in LI.dna.species.specflags)
			//If you ever want to add the option to force default mutant colours, add var/mutant_colors to configuration and remove the comments here. |- Ricotez
			//if(!config.mutant_colors)
				//dna.mutant_color = dna.species.default_color
			draw_color = LI.dna.mutant_color

	if(draw_color)
		I.color = "#[draw_color]"
	//End Greyscale Colouring

	if(I)
		return I
	return 0


/proc/skintone2hex(var/skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"

/mob/living/carbon/human/proc/get_overlays_copy(var/list/unwantedLayers)
	var/list/out = new
	for(var/i=1;i<=TOTAL_LAYERS;i++)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out

//Human Overlays Indexes///////// See top of file for why this is commented out
/*#undef SPECIES_LAYER
#undef BODY_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef UNIFORM_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
#undef HAIR_LAYER
#undef HEAD_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef L_HAND_LAYER
#undef R_HAND_LAYER
#undef FIRE_LAYER
#undef TOTAL_LAYERS*/
