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
		update_base_icon_state()	//Handles updating var/base_icon_state (WIP) This is used to update the
									mob's icon_state easily e.g. "[base_icon_state]_s" is the standing icon_state
		update_body()				//Handles updating your mob's icon_state (using update_base_icon_state())
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())

If you have any questions/constructive-comments/bugs-to-report
Please contact me on #coderbus IRC. ~Carnie x
//Carn can sometimes be hard to reach now. However IRC is still your best bet for getting help.
*/

//Human Overlays Indexes/////////
#define SPECIES_LAYER			26		// mutantrace colors... these are on a seperate layer in order to prvent
#define BODY_BEHIND_LAYER		25
#define BODY_LAYER				24		//underwear, undershirts, socks, eyes, lips(makeup)
#define BODY_ADJ_LAYER			23
#define MUTATIONS_LAYER			22		//Tk headglows etc.
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
#define TOTAL_LAYERS			26		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/human/proc/update_base_icon_state()
	//var/race = dna ? dna.mutantrace : null
	if(dna)
		base_icon_state = dna.species.update_base_icon_state(src)
	else
		if(disabilities & HUSK)
			base_icon_state = "husk"
		else
			base_icon_state = "[skin_tone]_[(gender == FEMALE) ? "f" : "m"]"

	icon_state = "[base_icon_state]_s"


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

	for(var/obj/item/organ/limb/O in organs)
		if(O.brutestate)
			standing.overlays	+= "[O.icon_state]_[O.brutestate]0"	//we're adding icon_states of the base image as overlays
		if(O.burnstate)
			standing.overlays	+= "[O.icon_state]_0[O.burnstate]"

	apply_overlay(DAMAGE_LAYER)


//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	if( (disabilities & HUSK) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) )
		return

	if((wear_suit) && (wear_suit.hooded) && (wear_suit.suittoggled == 1))
		return

	if(dna)
		dna.species.handle_hair(src)

/mob/living/carbon/human/proc/update_mutcolor()
	if(dna && !(disabilities & HUSK))
		dna.species.update_color(src)

/mob/living/carbon/human/proc/update_mutant_bodyparts()
	if(dna)
		dna.species.handle_mutant_bodyparts(src)


/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)

	if(dna)
		base_icon_state = dna.species.update_base_icon_state(src)
	else
		update_base_icon_state()

	icon_state = "[base_icon_state]_s"

	if(dna)	// didn't want to have a duplicate if(dna) here, but due to the ordering of the code this was the only way
		dna.species.handle_body(src)

/mob/living/carbon/human/update_fire()

	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)


/mob/living/carbon/human/proc/update_augments()
	remove_overlay(AUGMENTS_LAYER)

	var/list/standing	= list()
	var/g = (gender == FEMALE) ? "f" : "m"


	if(getlimb(/obj/item/organ/limb/robot/r_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_arm_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_arm_s", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/r_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_leg_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_leg_s", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/chest))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="chest_[g]_s", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/head))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="head_s", "layer"=-AUGMENTS_LAYER)

	if(standing.len)
		overlays_standing[AUGMENTS_LAYER]	= standing

	apply_overlay(AUGMENTS_LAYER)

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)		return
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
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_fire()
	update_transform()
	//Hud Stuff
	update_hud()
	// Mutantrace colors
	update_mutcolor()

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

		var/image/standing

		var/iconfile2use //Which icon file to use to generate the overlay and any female alterations.

		if(U.alternate_worn_icon)
			iconfile2use = U.alternate_worn_icon
		if(!iconfile2use)
			iconfile2use = 'icons/mob/uniform.dmi'

		standing = image("icon"=iconfile2use, "icon_state"="[t_color]_s", "layer"=-UNIFORM_LAYER)

		overlays_standing[UNIFORM_LAYER]	= standing

		if(dna && dna.species.sexes)
			var/G = (gender == FEMALE) ? "f" : "m"
			if(G == "f" && U.fitted != NO_FEMALE_UNIFORM)
				standing	= wear_female_version(t_color, iconfile2use, UNIFORM_LAYER, U.fitted)
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

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state

		var/image/standing
		if(gloves.alternate_worn_icon)
			standing = image("icon"=gloves.alternate_worn_icon, "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/hands.dmi', "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)

		overlays_standing[GLOVES_LAYER]	= standing

		if(gloves.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

	else
		if(blood_DNA)
			overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands", "layer"=-GLOVES_LAYER)

	apply_overlay(GLOVES_LAYER)



/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		var/image/standing
		if(glasses.alternate_worn_icon)
			standing = image("icon"=glasses.alternate_worn_icon, "icon_state"="[glasses.icon_state]","layer"=-GLASSES_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/eyes.dmi', "icon_state"="[glasses.icon_state]", "layer"=-GLASSES_LAYER)

		overlays_standing[GLASSES_LAYER] = standing

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(ears)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				ears.screen_loc = ui_ears			//...draw the item in the inventory screen
			client.screen += ears					//Either way, add the item to the HUD

		var/image/standing
		if(ears.alternate_worn_icon)
			standing = image("icon"=ears.alternate_worn_icon, "icon_state"="[ears.icon_state]", "layer"=-EARS_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/ears.dmi', "icon_state"="[ears.icon_state]", "layer"=-EARS_LAYER)

		overlays_standing[EARS_LAYER] = standing

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing
		if(shoes.alternate_worn_icon)
			standing = image("icon"=shoes.alternate_worn_icon, "icon_state"="[shoes.icon_state]","layer"=-SHOES_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/feet.dmi', "icon_state"="[shoes.icon_state]", "layer"=-SHOES_LAYER)
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

		var/image/standing
		if(head.alternate_worn_icon)
			standing = image("icon"=head.alternate_worn_icon, "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
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

		var/image/standing
		if(belt.alternate_worn_icon)
			standing = image("icon"=belt.alternate_worn_icon, "icon_state"="[t_state]", "layer"=-BELT_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/belt.dmi', "icon_state"="[t_state]", "layer"=-BELT_LAYER)

		overlays_standing[BELT_LAYER] = standing

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)					//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//TODO	//...draw the item in the inventory screen
			client.screen += wear_suit						//Either way, add the item to the HUD

		var/image/standing
		if(wear_suit.alternate_worn_icon)
			standing = image("icon"=wear_suit.alternate_worn_icon, "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/suit.dmi', "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			unEquip(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood")

	src.update_hair()
	src.update_mutant_bodyparts()

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

		var/image/standing
		if(wear_mask.alternate_worn_icon)
			standing = image("icon"=wear_mask.alternate_worn_icon, "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)

		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")

	update_mutant_bodyparts()

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back

		var/image/standing
		if(back.alternate_worn_icon)
			standing = image("icon"=back.alternate_worn_icon, "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)

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
	if(r_hand)
		r_hand.screen_loc = ui_rhand	//TODO
		if(client)
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_standing[R_HAND_LAYER] = image("icon" = r_hand.righthand_file, "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)



/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if (handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		l_hand.screen_loc = ui_lhand	//TODO
		if(client)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_standing[L_HAND_LAYER] = image("icon" = l_hand.lefthand_file, "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

/mob/living/carbon/human/proc/wear_female_version(t_color, icon, layer, type)
	var/index = "[t_color]_s"
	var/icon/female_clothing_icon = female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index,t_color,icon,type)
	var/standing	= image("icon"=female_clothing_icons["[t_color]_s"], "layer"=-layer)
	return(standing)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i=1;i<=TOTAL_LAYERS;i++)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out

//Human Overlays Indexes/////////
#undef SPECIES_LAYER
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
#undef TOTAL_LAYERS
