	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we do not generate either lying or standing, as used to happen.
Instead, we generate both standing and lying stances and store them in two fixed-length lists,
both using the same list-index. (The index values are defines within this file.

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing.
	var/overlays_lying[20]			//For the lying down stance
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
	This unfortunately means that cloaking is not working properly at time of writing,
	however the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	One such example would be when var/lying changes state (because every overlay needs to be updated, but not regenerated). In these
	very specific cases, update_icons() will be faster than calling each update_X proc individually.
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
		update_mutations()			//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_base_icon_state()	//Handles updating var/base_icon_state (WIP) This is used to update the
									mob's icon_state easily e.g. "[base_icon_state]_s" is the standing icon_state
		update_body()				//Handles updating your mob's icon_state (using update_base_icon_state())
									as well as sprite-accessories that didn't really fit elsewhere (underwear, lips, eyes)
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
*/

//Human Overlays Indexes/////////
#define BODY_LAYER				22		//underwear, eyes, lips(makeup)
#define MUTATIONS_LAYER			21		//Tk headglows etc.
#define AUGMENTS_LAYER			20
#define DAMAGE_LAYER			19		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			18
#define ID_LAYER				17
#define SHOES_LAYER				16
#define GLOVES_LAYER			15
#define EARS_LAYER				14
#define SUIT_LAYER				13
#define GLASSES_LAYER			12
#define BELT_LAYER				11		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		10
#define BACK_LAYER				9
#define HAIR_LAYER				8		//TODO: make part of head layer?
#define FACEMASK_LAYER			7
#define HEAD_LAYER				6
#define HANDCUFF_LAYER			5
#define LEGCUFF_LAYER			4
#define L_HAND_LAYER			3
#define R_HAND_LAYER			2		//Having the two hands seperate seems rather silly, merge them together? It'll allow for code to be reused on mobs with arbitarily many hands
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			22		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_lying[TOTAL_LAYERS]
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/human/proc/update_base_icon_state()
	var/race = dna ? dna.mutantrace : null
	switch(race)
		if("lizard","golem","slime","shadow","adamantine","fly","plant")
			base_icon_state = "[dna.mutantrace]_[(gender == FEMALE) ? "f" : "m"]"
		if("skeleton")
			base_icon_state = "skeleton"
		else
			if(HUSK in mutations)
				base_icon_state = "husk"
			else
				base_icon_state = "[skin_tone]_[(gender == FEMALE) ? "f" : "m"]"


/mob/living/carbon/human/proc/apply_overlay(cache_index)
	var/image/I = lying ? overlays_lying[cache_index] : overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/human/proc/remove_overlay(cache_index)
	if(overlays_lying[cache_index])
		overlays -= overlays_lying[cache_index]
		overlays_lying[cache_index] = null
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING

/mob/living/carbon/human/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this
	overlays.Cut()

	if(lying)		//can't be cloaked whilst lying down
		icon_state = "[base_icon_state]_l"
		for(var/thing in overlays_lying)
			if(thing)	overlays += thing
	else
		icon_state = "[base_icon_state]_s"
		for(var/thing in overlays_standing)
			if(thing)	overlays += thing



//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/image/standing	= image("icon"='icons/mob/dam_human.dmi', "icon_state"="blank", "layer"=-DAMAGE_LAYER)
	var/image/lying		= image("icon"='icons/mob/dam_human.dmi', "icon_state"="blank2", "layer"=-DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing
	overlays_lying[DAMAGE_LAYER]	= lying

	for(var/obj/item/organ/limb/O in organs)
		if(O.brutestate)
			standing.overlays	+= "[O.icon_state]_[O.brutestate]0"	//we're adding icon_states of the base image as overlays //made icon_name redundant - RR
			lying.overlays		+= "[O.icon_state]2_[O.brutestate]0"
		if(O.burnstate)
			standing.overlays	+= "[O.icon_state]_0[O.burnstate]"
			lying.overlays		+= "[O.icon_state]2_0[O.burnstate]"

	apply_overlay(DAMAGE_LAYER)


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	//mutants don't have hair. masks and helmets can obscure our hair too.
	if( (HUSK in mutations) || (dna && dna.mutantrace) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) )
		return

	//base icons
	var/datum/sprite_accessory/S
	var/list/standing	= list()
	var/list/lying		= list()

	if(facial_hair_style)
		S = facial_hair_styles_list[facial_hair_style]
		if(S)
			var/icon/facial_s = icon("icon"=S.icon, "icon_state"="[S.icon_state]_s")
			var/icon/facial_l = icon("icon"=S.icon, "icon_state"="[S.icon_state]_l")

			var/image/img_facial_s = image("icon"=facial_s, "layer"=-HAIR_LAYER)
			var/image/img_facial_l = image("icon"=facial_l, "layer"=-HAIR_LAYER)

			var/new_color = "#" + facial_hair_color
			img_facial_l.color = new_color
			img_facial_s.color = new_color

			standing	+= img_facial_s
			lying		+= img_facial_l

	//Applies the debrained overlay if there is no brain
	if(!getorgan(/obj/item/organ/brain))
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state"="debrained_s", "layer"=-HAIR_LAYER)
		lying		+= image("icon"='icons/mob/human_face.dmi', "icon_state"="debrained_l", "layer"=-HAIR_LAYER)
	else if(hair_style)
		S = hair_styles_list[hair_style]
		if(S)
			var/icon/hair_s = icon("icon"=S.icon, "icon_state"="[S.icon_state]_s")
			var/icon/hair_l = icon("icon"=S.icon, "icon_state"="[S.icon_state]_l")

			var/image/img_hair_s = image("icon"=hair_s, "layer"=-HAIR_LAYER)
			var/image/img_hair_l = image("icon"=hair_l, "layer"=-HAIR_LAYER)

			var/new_color = "#" + hair_color
			img_hair_s.color = new_color
			img_hair_l.color = new_color

			standing	+= img_hair_s
			lying		+= img_hair_l

	if(lying.len)
		overlays_lying[HAIR_LAYER]		= lying
	if(standing.len)
		overlays_standing[HAIR_LAYER]	= standing

	apply_overlay(HAIR_LAYER)


/mob/living/carbon/human/update_mutations()
	remove_overlay(MUTATIONS_LAYER)

	var/list/standing	= list()
	var/list/lying		= list()

	var/g = (gender == FEMALE) ? "f" : "m"
	for(var/mut in mutations)
		switch(mut)
			if(HULK)
				lying		+= image("icon"='icons/effects/genetics.dmi', "icon_state"="hulk_[g]_l", "layer"=-MUTATIONS_LAYER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="hulk_[g]_s", "layer"=-MUTATIONS_LAYER)
			if(COLD_RESISTANCE)
				lying		+= image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_l", "layer"=-MUTATIONS_LAYER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="fire_s", "layer"=-MUTATIONS_LAYER)
			if(TK)
				lying		+= image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_l", "layer"=-MUTATIONS_LAYER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="telekinesishead_s", "layer"=-MUTATIONS_LAYER)
			if(LASER)
				lying		+= image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_l", "layer"=-MUTATIONS_LAYER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_s", "layer"=-MUTATIONS_LAYER)
	if(lying.len)
		overlays_lying[MUTATIONS_LAYER]		= lying
	if(standing.len)
		overlays_standing[MUTATIONS_LAYER]	= standing

	apply_overlay(MUTATIONS_LAYER)


/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)

	update_base_icon_state()
	icon_state = "[base_icon_state]_[src.lying ? "l" : "s"]"

	var/list/lying		= list()
	var/list/standing	= list()

	//Mouth	(lipstick!)
	if(lip_style)
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[lip_style]_s", "layer"=-BODY_LAYER)
		lying		+= image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[lip_style]_l", "layer"=-BODY_LAYER)

	//Eyes
	if(!dna || dna.mutantrace != "skeleton")
		var/icon/eyes_s = icon('icons/mob/human_face.dmi', "eyes_s")
		var/icon/eyes_l = icon('icons/mob/human_face.dmi', "eyes_l")

		var/image/img_eyes_s = image("icon"=eyes_s, "layer"=-BODY_LAYER)
		var/image/img_eyes_l = image("icon"=eyes_l, "layer"=-BODY_LAYER)

		var/new_color = "#" + eye_color

		img_eyes_s.color = new_color
		img_eyes_l.color = new_color

		standing	+= img_eyes_s
		lying		+= img_eyes_l

	//Underwear
	if(underwear)
		var/datum/sprite_accessory/underwear/U = underwear_all[underwear]
		if(U)
			standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)
			lying		+= image("icon"=U.icon, "icon_state"="[U.icon_state]_l", "layer"=-BODY_LAYER)

	if(lying.len)
		overlays_lying[BODY_LAYER]		= lying
	if(standing.len)
		overlays_standing[BODY_LAYER]	= standing

	apply_overlay(BODY_LAYER)


/mob/living/carbon/human/update_fire()

	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_lying[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Lying", "layer"=-FIRE_LAYER)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)


/mob/living/carbon/human/proc/update_augments()
	remove_overlay(AUGMENTS_LAYER)

	var/list/lying		= list()
	var/list/standing	= list()


	if(getlimb(/obj/item/organ/limb/robot/r_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_arm_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_arm_l", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_arm))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_arm_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_arm_l", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/r_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_leg_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="r_leg_l", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/l_leg))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_leg_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="l_leg_l", "layer"=-AUGMENTS_LAYER)

	if(getlimb(/obj/item/organ/limb/robot/chest))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="chest_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="chest_l", "layer"=-AUGMENTS_LAYER)
	if(getlimb(/obj/item/organ/limb/robot/head))
		standing	+= image("icon"='icons/mob/augments.dmi', "icon_state"="head_s", "layer"=-AUGMENTS_LAYER)
		lying		+= image("icon"='icons/mob/augments.dmi', "icon_state"="head_l", "layer"=-AUGMENTS_LAYER)



	if(lying.len)
		overlays_lying[AUGMENTS_LAYER]		= lying
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
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			w_uniform.screen_loc = ui_iclothing
			client.screen += w_uniform

		var/t_color = w_uniform.item_color
		if(!t_color)		t_color = icon_state
		var/image/lying		= image("icon"='icons/mob/uniform.dmi', "icon_state"="[t_color]_l", "layer"=-UNIFORM_LAYER)
		var/image/standing	= image("icon"='icons/mob/uniform.dmi', "icon_state"="[t_color]_s", "layer"=-UNIFORM_LAYER)
		overlays_lying[UNIFORM_LAYER]		= lying
		overlays_standing[UNIFORM_LAYER]	= standing


		var/G = (gender == FEMALE) ? "f" : "m"
		if(G == "f" && U.fitted == 1)
			var/index = "[t_color]_s"
			var/icon/female_uniform_icon = female_uniform_icons[index]
			if(!female_uniform_icon ) 	//Create standing/laying icons if they don't exist
				generate_uniform(index,t_color)
			standing	= image("icon"=female_uniform_icons["[t_color]_s"], "layer"=-UNIFORM_LAYER)
			overlays_standing[UNIFORM_LAYER]	= standing

		if(w_uniform.blood_DNA)
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")

		if(U.hastie)
			var/tie_color = U.hastie.item_color
			if(!tie_color) tie_color = U.hastie.icon_state
			lying.overlays		+= image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]2")
			standing.overlays	+= image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]")
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			drop_from_inventory(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		if(client && hud_used && hud_used.hud_shown)
			wear_id.screen_loc = ui_id	//TODO
			client.screen += wear_id

		overlays_lying[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id2", "layer"=-ID_LAYER)
		overlays_standing[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			gloves.screen_loc = ui_gloves
			client.screen += gloves

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/lying		= image("icon"='icons/mob/hands.dmi', "icon_state"="[t_state]2", "layer"=-GLOVES_LAYER)
		var/image/standing	= image("icon"='icons/mob/hands.dmi', "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)
		overlays_lying[GLOVES_LAYER]	= lying
		overlays_standing[GLOVES_LAYER]	= standing

		if(gloves.blood_DNA)
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")
	else
		if(blood_DNA)
			overlays_lying[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands2")
			overlays_standing[GLOVES_LAYER]	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")

	apply_overlay(GLOVES_LAYER)



/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			glasses.screen_loc = ui_glasses
			client.screen += glasses

		overlays_lying[GLASSES_LAYER]		= image("icon"='icons/mob/eyes.dmi', "icon_state"="[glasses.icon_state]2", "layer"=-GLASSES_LAYER)
		overlays_standing[GLASSES_LAYER]	= image("icon"='icons/mob/eyes.dmi', "icon_state"="[glasses.icon_state]", "layer"=-GLASSES_LAYER)

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(ears)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			ears.screen_loc = ui_ears
			client.screen += ears

		overlays_lying[EARS_LAYER] = image("icon"='icons/mob/ears.dmi', "icon_state"="[ears.icon_state]2", "layer"=-EARS_LAYER)
		overlays_standing[EARS_LAYER] = image("icon"='icons/mob/ears.dmi', "icon_state"="[ears.icon_state]", "layer"=-EARS_LAYER)

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			shoes.screen_loc = ui_shoes
			client.screen += shoes

		var/image/lying		= image("icon"='icons/mob/feet.dmi', "icon_state"="[shoes.icon_state]2", "layer"=-SHOES_LAYER)
		var/image/standing	= image("icon"='icons/mob/feet.dmi', "icon_state"="[shoes.icon_state]", "layer"=-SHOES_LAYER)
		overlays_lying[SHOES_LAYER]		= lying
		overlays_standing[SHOES_LAYER]	= standing

		if(shoes.blood_DNA)
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(s_store)
		if(client && hud_used && hud_used.hud_shown)
			s_store.screen_loc = ui_sstore1		//TODO
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_lying[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]2", "layer"=-SUIT_STORE_LAYER)
		overlays_standing[SUIT_STORE_LAYER]	= image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)

	apply_overlay(SUIT_STORE_LAYER)



/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			head.screen_loc = ui_head		//TODO
			client.screen += head

		var/image/lying = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]2", "layer"=-HEAD_LAYER)
		var/image/standing = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)

		overlays_lying[HEAD_LAYER]		= lying
		overlays_standing[HEAD_LAYER]	= standing

		if(head.blood_DNA)
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(belt)
		if(client && hud_used && hud_used.hud_shown)
			belt.screen_loc = ui_belt
			client.screen += belt

		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		overlays_lying[BELT_LAYER]		= image("icon"='icons/mob/belt.dmi', "icon_state"="[t_state]2", "layer"=-BELT_LAYER)
		overlays_standing[BELT_LAYER]	= image("icon"='icons/mob/belt.dmi', "icon_state"="[t_state]", "layer"=-BELT_LAYER)

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_suit.screen_loc = ui_oclothing	//TODO
			client.screen += wear_suit

		var/image/lying		= image("icon"='icons/mob/suit.dmi', "icon_state"="[wear_suit.icon_state]2", "layer"=-SUIT_LAYER)
		var/image/standing	= image("icon"='icons/mob/suit.dmi', "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)
		overlays_lying[SUIT_LAYER]		= lying
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood")

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		if(client && hud_used && hud_used.hud_shown)
			l_store.screen_loc = ui_storage1	//TODO
			client.screen += l_store
	if(r_store)
		if(client && hud_used && hud_used.hud_shown)
			r_store.screen_loc = ui_storage2	//TODO
			client.screen += r_store


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask))
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_mask.screen_loc = ui_mask	//TODO
			client.screen += wear_mask

		var/image/lying		= image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]2", "layer"=-FACEMASK_LAYER)
		var/image/standing	= image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)
		overlays_lying[FACEMASK_LAYER]		= lying
		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			lying.overlays		+= image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood2")
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")

	apply_overlay(FACEMASK_LAYER)



/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		if(client && hud_used && hud_used.hud_shown)
			back.screen_loc = ui_back	//TODO
			client.screen += back

		overlays_lying[BACK_LAYER]		= image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]2", "layer"=-BACK_LAYER)
		overlays_standing[BACK_LAYER]	= image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)

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

		overlays_lying[HANDCUFF_LAYER]		= image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff2", "layer"=-HANDCUFF_LAYER)
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
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

		overlays_lying[LEGCUFF_LAYER]		= image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff2", "layer"=-LEGCUFF_LAYER)
		overlays_standing[LEGCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)



/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)

	if(r_hand)
		if(client)
			r_hand.screen_loc = ui_rhand	//TODO
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state

		overlays_standing[R_HAND_LAYER] = image("icon"='icons/mob/items_righthand.dmi', "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)



/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)

	if(l_hand)
		if(client)
			l_hand.screen_loc = ui_lhand	//TODO
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state

		overlays_standing[L_HAND_LAYER] = image("icon"='icons/mob/items_lefthand.dmi', "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

//Human Overlays Indexes/////////
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
