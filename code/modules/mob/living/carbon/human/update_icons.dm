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
		update_inv_glasses()
		update_inv_l_hand()
		update_inv_r_hand()
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
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)

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

//Human Overlays Indexes/////////
#define MUTANTRACE_LAYER		20		//TODO: make part of body?
#define MUTATIONS_LAYER			19
#define DAMAGE_LAYER			18
#define UNIFORM_LAYER			17
#define ID_LAYER				16
#define SHOES_LAYER				15
#define GLOVES_LAYER			14
#define EARS_LAYER				13
#define SUIT_LAYER				12
#define GLASSES_LAYER			11
#define BELT_LAYER				10		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		9
#define BACK_LAYER				8
#define HAIR_LAYER				7		//TODO: make part of head layer?
#define FACEMASK_LAYER			6
#define HEAD_LAYER				5
#define HANDCUFF_LAYER			4
#define LEGCUFF_LAYER			3
#define L_HAND_LAYER			2
#define R_HAND_LAYER			1
#define TOTAL_LAYERS			20
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_lying[TOTAL_LAYERS]
	var/list/overlays_standing[TOTAL_LAYERS]

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
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this
	overlays.Cut()

	if(lying)		//can't be cloaked when lying. (for now)
		icon = lying_icon
		for(var/image/I in overlays_lying)
			overlays += I
	else
		var/stealth = 0
		if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja) && wear_suit:s_active)
			stealth = 1
		else
			//cloaking devices. //TODO: get rid of this :<
			for(var/obj/item/weapon/cloaking_device/S in list(l_hand,r_hand,belt,l_store,r_store))
				if(S.active)
					stealth = 1
					break
		if(stealth)
			icon = 'icons/mob/human.dmi'
			icon_state = "body_cloaked"
			var/image/I	= overlays_standing[L_HAND_LAYER]
			if(istype(I))	overlays += I
			I 			= overlays_standing[R_HAND_LAYER]
			if(istype(I))	overlays += I
		else
			icon = stand_icon
			for(var/image/I in overlays_standing)
				overlays += I



//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(update_icons=0)
	remove_overlay(DAMAGE_LAYER)
	
	var/image/standing	= image("icon" = 'icons/mob/dam_human.dmi', "icon_state" = "blank", "layer" = -DAMAGE_LAYER)
	var/image/lying		= image("icon" = 'icons/mob/dam_human.dmi', "icon_state" = "blank2", "layer" = -DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing
	overlays_lying[DAMAGE_LAYER]	= lying
	
	for(var/datum/limb/O in organs)
		if(O.brutestate)
			standing.overlays	+= "[O.icon_name]_[O.brutestate]0"	//we're adding icon_states of the base image as overlays
			lying.overlays		+= "[O.icon_name]2_[O.brutestate]0"
		if(O.burnstate)
			standing.overlays	+= "[O.icon_name]_0[O.burnstate]"
			lying.overlays		+= "[O.icon_name]2_0[O.burnstate]"
	
	apply_overlay(DAMAGE_LAYER)
	if(update_icons)   update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(update_icons=0)
	stand_icon = null
	lying_icon = null
	if(dna && dna.mutantrace)	return

	var/skeleton = (SKELETON in src.mutations)
	
	var/base_icon_state
	//Base mob icon
	if(skeleton)
		base_icon_state = "skeleton"
	else
		if(HUSK in src.mutations)
			base_icon_state = "husk"
		else
			base_icon_state = "[skin_tone]_[(gender == FEMALE) ? "f" : "m"]"
		
	stand_icon = icon('icons/mob/human.dmi', "[base_icon_state]_s")
	lying_icon = icon('icons/mob/human.dmi', "[base_icon_state]_l")

	//Mouth	(lipstick!)
	if(lip_style)	//skeletons are allowed to wear lipstick no matter what you think, agouri.
		stand_icon.Blend(icon('icons/mob/human_face.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)
		lying_icon.Blend(icon('icons/mob/human_face.dmi', "lips_[lip_style]_l"), ICON_OVERLAY)

	//Eyes
	if(!skeleton)
		var/icon/eyes_s = icon('icons/mob/human_face.dmi', "eyes_s")
		var/icon/eyes_l = icon('icons/mob/human_face.dmi', "eyes_l")
		eyes_s.Blend("#[eye_color]", ICON_ADD)
		eyes_l.Blend("#[eye_color]", ICON_ADD)
		stand_icon.Blend(eyes_s, ICON_OVERLAY)
		lying_icon.Blend(eyes_l, ICON_OVERLAY)

		//Underwear
		if(underwear)
			var/datum/sprite_accessory/underwear/U = underwear_all[underwear]
			if(U)
				stand_icon.Blend(icon(U.icon, "[U.icon_state]_s"), ICON_OVERLAY)
				lying_icon.Blend(icon(U.icon, "[U.icon_state]_l"), ICON_OVERLAY)

	if(update_icons)	update_icons()


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair(update_icons=0)
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	//mutants don't have hair. masks and helmets can obscure our hair too.
	if( (dna && dna.mutantrace) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) )
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")
	var/icon/face_lying		= new /icon('icons/mob/human_face.dmi',"bald_l")

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
			facial_s.Blend("#[f_color]", ICON_ADD)
			facial_l.Blend("#[f_color]", ICON_ADD)
			face_standing.Blend(facial_s, ICON_OVERLAY)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	//Applies the debrained overlay if there is no brain
	if(!getbrain(src))
		face_standing.Blend(new /icon('icons/mob/human_face.dmi', "debrained_s"), ICON_OVERLAY)
		face_lying.Blend(new /icon('icons/mob/human_face.dmi', "debrained_l"), ICON_OVERLAY)
		h_style = "Bald"

	else if(h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
			hair_s.Blend("#[h_color]", ICON_ADD)
			hair_l.Blend("#[h_color]", ICON_ADD)
			face_standing.Blend(hair_s, ICON_OVERLAY)
			face_lying.Blend(hair_l, ICON_OVERLAY)

	overlays_lying[HAIR_LAYER]		= image(face_lying, "layer" = -HAIR_LAYER)
	overlays_standing[HAIR_LAYER]	= image(face_standing, "layer" = -HAIR_LAYER)

	apply_overlay(HAIR_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_mutations(update_icons=0)
	remove_overlay(MUTATIONS_LAYER)

	var/image/lying		= image("icon" = 'icons/effects/genetics.dmi', "layer" = -MUTATIONS_LAYER)
	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi', "layer" = -MUTATIONS_LAYER)
	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	for(var/mut in mutations)
		switch(mut)
			if(HULK)
				lying.underlays		+= "hulk_[g]_l"
				standing.underlays	+= "hulk_[g]_s"
				add_image = 1
			if(COLD_RESISTANCE)
				lying.underlays		+= "fire_l"
				standing.underlays	+= "fire_s"
				add_image = 1
			if(TK)
				lying.underlays		+= "telekinesishead_l"
				standing.underlays	+= "telekinesishead_s"
				add_image = 1
			if(LASER)
				lying.overlays		+= "lasereyes_l"
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if(add_image)
		overlays_lying[MUTATIONS_LAYER]		= lying
		overlays_standing[MUTATIONS_LAYER]	= standing
	
	apply_overlay(MUTATIONS_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/proc/update_mutantrace(update_icons=0)
	remove_overlay(MUTANTRACE_LAYER)

	if(dna)
		switch(dna.mutantrace)
			if("lizard","golem","slime","shadow","adamantine", "fly")
				overlays_lying[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_[gender]_l", "layer" = -MUTANTRACE_LAYER)
				overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_[gender]_s", "layer" = -MUTANTRACE_LAYER)
			if("plant")
				if(stat == DEAD)	//TODO
					overlays_lying[MUTANTRACE_LAYER] = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_d", "layer" = -MUTANTRACE_LAYER)
				else
					overlays_lying[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_[gender]_l", "layer" = -MUTANTRACE_LAYER)
					overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_[gender]_s", "layer" = -MUTANTRACE_LAYER)

	update_body(0)
	update_hair(0)
	
	apply_overlay(MUTANTRACE_LAYER)
	if(update_icons)   update_icons()

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(monkeyizing)		return
	update_mutations(0)
	update_mutantrace(0)
	update_inv_w_uniform(0)
	update_inv_wear_id(0)
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
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_inv_legcuffed(0)
	update_inv_pockets(0)
	update_icons()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(update_icons=0)
	remove_overlay(UNIFORM_LAYER)
	
	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			w_uniform.screen_loc = ui_iclothing
			client.screen += w_uniform
		
		var/t_color = w_uniform.color
		if(!t_color)		t_color = icon_state
		var/image/lying		= image("icon" = 'icons/mob/uniform.dmi', "icon_state" = "[t_color]_l", "layer" = -UNIFORM_LAYER)
		var/image/standing	= image("icon" = 'icons/mob/uniform.dmi', "icon_state" = "[t_color]_s", "layer" = -UNIFORM_LAYER)
		overlays_lying[UNIFORM_LAYER]		= lying
		overlays_standing[UNIFORM_LAYER]	= standing
		
		if(w_uniform.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
		
		if(U.hastie)
			var/tie_color = U.hastie.color
			if(!tie_color) tie_color = U.hastie.icon_state
			lying.overlays		+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]2")
			standing.overlays	+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]")
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			drop_from_inventory(thing)
	
	apply_overlay(UNIFORM_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_wear_id(update_icons=0)
	remove_overlay(ID_LAYER)
	if(wear_id)
		if(client && hud_used && hud_used.hud_shown)
			wear_id.screen_loc = ui_id	//TODO
			client.screen += wear_id
		
		overlays_lying[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id2", "layer" = -ID_LAYER)
		overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id", "layer" = -ID_LAYER)
		
	apply_overlay(ID_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_gloves(update_icons=0)
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			gloves.screen_loc = ui_gloves
			client.screen += gloves

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/lying		= image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]2", "layer" = -GLOVES_LAYER)
		var/image/standing	= image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]", "layer" = -GLOVES_LAYER)
		overlays_lying[GLOVES_LAYER]	= lying
		overlays_standing[GLOVES_LAYER]	= standing
		
		if(gloves.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
	else
		if(blood_DNA)
			overlays_lying[GLOVES_LAYER]	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands2")
			overlays_standing[GLOVES_LAYER]	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
	
	apply_overlay(GLOVES_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_glasses(update_icons=0)
	remove_overlay(GLASSES_LAYER)
	
	if(glasses)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			glasses.screen_loc = ui_glasses
			client.screen += glasses
		
		overlays_lying[GLASSES_LAYER]		= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]2", "layer" = -GLASSES_LAYER)
		overlays_standing[GLASSES_LAYER]	= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]", "layer" = -GLASSES_LAYER)

	apply_overlay(GLASSES_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_ears(update_icons=0)
	remove_overlay(EARS_LAYER)
	
	if(ears)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			ears.screen_loc = ui_ears
			client.screen += ears
		
		overlays_lying[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[ears.icon_state]2", "layer" = -EARS_LAYER)
		overlays_standing[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[ears.icon_state]", "layer" = -EARS_LAYER)
	
	apply_overlay(EARS_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_shoes(update_icons=0)
	remove_overlay(SHOES_LAYER)
	
	if(shoes)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			shoes.screen_loc = ui_shoes
			client.screen += shoes
		
		var/image/lying		= image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]2", "layer" = -SHOES_LAYER)
		var/image/standing	= image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]", "layer" = -SHOES_LAYER)
		overlays_lying[SHOES_LAYER]		= lying
		overlays_standing[SHOES_LAYER]	= standing
		
		if(shoes.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
	
	apply_overlay(SHOES_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_s_store(update_icons=0)
	remove_overlay(SUIT_STORE_LAYER)
	
	if(s_store)
		if(client && hud_used && hud_used.hud_shown)
			s_store.screen_loc = ui_sstore1		//TODO
			client.screen += s_store
		
		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_lying[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]2", "layer" = -SUIT_STORE_LAYER)
		overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]", "layer" = -SUIT_STORE_LAYER)
	
	apply_overlay(SUIT_STORE_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_head(update_icons=0)
	remove_overlay(HEAD_LAYER)
	
	if(head)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			head.screen_loc = ui_head		//TODO
			client.screen += head
		
		var/image/lying
		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty))
			var/obj/item/clothing/head/kitty/K = head
			lying		= image("icon" = K.mob2, "layer" = -HEAD_LAYER)
			standing	= image("icon" = K.mob, "layer" = -HEAD_LAYER)
		else
			lying		= image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]2", "layer" = -HEAD_LAYER)
			standing	= image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]", "layer" = -HEAD_LAYER)
		overlays_lying[HEAD_LAYER]		= lying
		overlays_standing[HEAD_LAYER]	= standing
		
		if(head.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
	
	apply_overlay(HEAD_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_belt(update_icons=0)
	remove_overlay(BELT_LAYER)
	
	if(belt)
		if(client && hud_used && hud_used.hud_shown)
			belt.screen_loc = ui_belt
			client.screen += belt
		
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		overlays_lying[BELT_LAYER]		= image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]2", "layer" = -BELT_LAYER)
		overlays_standing[BELT_LAYER]	= image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]", "layer" = -BELT_LAYER)

	apply_overlay(BELT_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_wear_suit(update_icons=0)
	remove_overlay(SUIT_LAYER)
	
	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_suit.screen_loc = ui_oclothing	//TODO
			client.screen += wear_suit
		
		var/image/lying		= image("icon" = 'icons/mob/suit.dmi', "icon_state" = "[wear_suit.icon_state]2", "layer" = -SUIT_LAYER)
		var/image/standing	= image("icon" = 'icons/mob/suit.dmi', "icon_state" = "[wear_suit.icon_state]", "layer" = -SUIT_LAYER)
		overlays_lying[SUIT_LAYER]		= lying
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[S.blood_overlay_type]blood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[S.blood_overlay_type]blood")

	apply_overlay(SUIT_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_pockets(update_icons=0)
	if(l_store)
		if(client && hud_used && hud_used.hud_shown)
			l_store.screen_loc = ui_storage1	//TODO
			client.screen += l_store
	if(r_store)
		if(client && hud_used && hud_used.hud_shown)
			r_store.screen_loc = ui_storage2	//TODO
			client.screen += r_store
	if(update_icons)	update_icons()


/mob/living/carbon/human/update_inv_wear_mask(update_icons=0)
	remove_overlay(FACEMASK_LAYER)
	
	if(istype(wear_mask, /obj/item/clothing/mask))
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_mask.screen_loc = ui_mask	//TODO
			client.screen += wear_mask
		
		var/image/lying		= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]2", "layer" = -FACEMASK_LAYER)
		var/image/standing	= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]", "layer" = -FACEMASK_LAYER)
		overlays_lying[FACEMASK_LAYER]		= lying
		overlays_standing[FACEMASK_LAYER]	= standing
		
		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
	
	apply_overlay(FACEMASK_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_back(update_icons=0)
	remove_overlay(BACK_LAYER)
	
	if(back)
		if(client && hud_used && hud_used.hud_shown)
			back.screen_loc = ui_back	//TODO
			client.screen += back
		
		overlays_lying[BACK_LAYER]		= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]2", "layer" = -BACK_LAYER)
		overlays_standing[BACK_LAYER]	= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]", "layer" = -BACK_LAYER)
	
	apply_overlay(BACK_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed(update_icons=0)
	remove_overlay(HANDCUFF_LAYER)
	
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		if(hud_used)	//hud handcuff icons
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays += image("icon" = 'icons/mob/screen_gen.dmi', "icon_state" = "markus")
			L.overlays += image("icon" = 'icons/mob/screen_gen.dmi', "icon_state" = "gabrielle")

		overlays_lying[HANDCUFF_LAYER]		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff2", "layer" = -HANDCUFF_LAYER)
		overlays_standing[HANDCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1", "layer" = -HANDCUFF_LAYER)
	else
		if(hud_used)
			var/obj/screen/inventory/R = hud_used.adding[3]
			var/obj/screen/inventory/L = hud_used.adding[4]
			R.overlays = null
			L.overlays = null
	
	apply_overlay(HANDCUFF_LAYER)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_legcuffed(update_icons=0)
	remove_overlay(LEGCUFF_LAYER)
	
	if(legcuffed)
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"
		
		overlays_lying[LEGCUFF_LAYER]		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff2", "layer" = -LEGCUFF_LAYER)
		overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1", "layer" = -LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_r_hand(update_icons=0)
	remove_overlay(R_HAND_LAYER)
	
	if(r_hand)
		if(client)
			r_hand.screen_loc = ui_rhand	//TODO
			client.screen += r_hand
		
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		
		overlays_standing[R_HAND_LAYER] = image("icon" = 'icons/mob/items_righthand.dmi', "icon_state" = "[t_state]", "layer" = -R_HAND_LAYER)
	
	apply_overlay(R_HAND_LAYER)
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_l_hand(update_icons=0)
	remove_overlay(L_HAND_LAYER)
	
	if(l_hand)
		if(client)
			l_hand.screen_loc = ui_lhand	//TODO
			client.screen += l_hand
		
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state
		
		overlays_standing[L_HAND_LAYER] = image("icon" = 'icons/mob/items_lefthand.dmi', "icon_state" = "[t_state]", "layer" = -L_HAND_LAYER)
	
	apply_overlay(L_HAND_LAYER)
	if(update_icons)   update_icons()

//Human Overlays Indexes/////////
#undef MUTANTRACE_LAYER
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
#undef TOTAL_LAYERS
