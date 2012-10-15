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
	metroid etc. Instead, it'll just return without doing any work. So no harm in calling it for metroids and such.


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
#define MUTANTRACE_LAYER		1		//TODO: make part of body?
#define MUTATIONS_LAYER			2
#define DAMAGE_LAYER			3
#define UNIFORM_LAYER			4
#define ID_LAYER				5
#define SHOES_LAYER				6
#define GLOVES_LAYER			7
#define EARS_LAYER				8
#define SUIT_LAYER				9
#define GLASSES_LAYER			10
#define BELT_LAYER				11		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		12
#define BACK_LAYER				13
#define HAIR_LAYER				14		//TODO: make part of head layer?
#define FACEMASK_LAYER			15
#define HEAD_LAYER				16
#define HANDCUFF_LAYER			17
#define LEGCUFF_LAYER			18
#define L_HAND_LAYER			19
#define R_HAND_LAYER			20
#define TAIL_LAYER				21		//bs12 specific. this hack is probably gonna come back to haunt me
#define TOTAL_LAYERS			21
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_lying[TOTAL_LAYERS]
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed


//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()

	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this
	overlays = null

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

var/global/list/damage_icon_parts = list()
proc/get_damage_icon_part(damage_state, body_part)
	if(damage_icon_parts["[damage_state]/[body_part]"] == null)
		var/icon/DI = new /icon('icons/mob/dam_human.dmi', damage_state)			// the damage icon for whole human
		DI.Blend(new /icon('dam_mask.dmi', body_part), ICON_MULTIPLY)		// mask with this organ's pixels
		damage_icon_parts["[damage_state]/[body_part]"] = DI
		return DI
	else
		return damage_icon_parts["[damage_state]/[body_part]"]

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(var/update_icons=1)
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/datum/organ/external/O in organs)
		if(O.status & ORGAN_DESTROYED) damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	previous_damage_appearance = damage_appearance

	var/icon/standing = new /icon('dam_human.dmi', "00")
	var/icon/lying = new /icon('dam_human.dmi', "00-2")

	var/image/standing_image = new /image("icon" = standing)
	var/image/lying_image = new /image("icon" = lying)


	// blend the individual damage states with our icons
	for(var/datum/organ/external/O in organs)
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00") continue

			var/icon/DI = get_damage_icon_part(O.damage_state, O.icon_name)

			standing_image.overlays += DI

			DI = get_damage_icon_part("[O.damage_state]-2", "[O.icon_name]2")
			lying_image.overlays += DI


	overlays_standing[DAMAGE_LAYER]	= standing_image
	overlays_lying[DAMAGE_LAYER]	= lying_image

	if(update_icons)   update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons=1)

	if(stand_icon)	del(stand_icon)
	if(lying_icon)	del(lying_icon)
	if(dna && dna.mutantrace)	return
	var/husk = (HUSK in src.mutations)  //100% unnecessary -Agouri	//nope, do you really want to iterate through src.mutations repeatedly? -Pete	var/fat = (FAT in src.mutations)	var/skeleton = (SKELETON in src.mutations)	var/g = "m"

	if(gender == FEMALE)	g = "f"
	var/husk = (HUSK in src.mutations)
	var/obese = (FAT in src.mutations)

	// whether to draw the individual limbs
	var/individual_limbs = 1

	//Base mob icon
	if(husk)		stand_icon = new /icon('icons/mob/human.dmi', "husk_s")		lying_icon = new /icon('icons/mob/human.dmi', "husk_l")	else if(fat)		stand_icon = new /icon('icons/mob/human.dmi', "fatbody_s")
		lying_icon = new /icon('icons/mob/human.dmi', "fatbody_l")
else if(skeleton)
		stand_icon = new /icon('icons/mob/human.dmi', "skeleton_s")		lying_icon = new /icon('icons/mob/human.dmi', "skeleton_l")
	else
		stand_icon = new /icon('icons/mob/human.dmi', "body_[g]_s")
		lying_icon = new /icon('icons/mob/human.dmi', "body_[g]_l")
		individual_limbs = 0

	// Draw each individual limb
	if(individual_limbs)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "chest_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('icons/mob/human.dmi', "chest_[g]_l"), ICON_OVERLAY)

		var/datum/organ/external/head = get_organ("head")
		if(head && !(head.status & ORGAN_DESTROYED))
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "head_[g]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('icons/mob/human.dmi', "head_[g]_l"), ICON_OVERLAY)

		for(var/datum/organ/external/part in organs)
			if(!istype(part, /datum/organ/external/groin) \
				&& !istype(part, /datum/organ/external/chest) \
				&& !istype(part, /datum/organ/external/head) \
				&& !(part.status & ORGAN_DESTROYED))
				var/icon/temp = new /icon('human.dmi', "[part.icon_name]_s")
				if(part.status & ORGAN_ROBOT) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
				stand_icon.Blend(temp, ICON_OVERLAY)
				temp = new /icon('human.dmi', "[part.icon_name]_l")
				if(part.status & ORGAN_ROBOT) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
				lying_icon.Blend(temp , ICON_OVERLAY)

		stand_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "groin_[g]_l"), ICON_OVERLAY)

	if (husk)
		var/icon/husk_s = new /icon('human.dmi', "husk_s")
		var/icon/husk_l = new /icon('human.dmi', "husk_l")

		for(var/datum/organ/external/part in organs)
			if(!istype(part, /datum/organ/external/groin) \
				&& !istype(part, /datum/organ/external/chest) \
				&& !istype(part, /datum/organ/external/head) \
				&& (part.status & ORGAN_DESTROYED))
				husk_s.Blend(new /icon('dam_mask.dmi', "[part.icon_name]"), ICON_SUBTRACT)
				husk_l.Blend(new /icon('dam_mask.dmi', "[part.icon_name]2"), ICON_SUBTRACT)

		stand_icon.Blend(husk_s, ICON_OVERLAY)
		lying_icon.Blend(husk_l, ICON_OVERLAY)

	//Skin tone
	if(!skeleton)
		if(s_tone >= 0)
			stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
			lying_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	//Eyes
	if(!skeleton)
		var/icon/eyes_s = new/icon('icons/mob/human_face.dmi', "eyes_s")
		var/icon/eyes_l = new/icon('icons/mob/human_face.dmi', "eyes_l")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
		eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
		stand_icon.Blend(eyes_s, ICON_OVERLAY)
		lying_icon.Blend(eyes_l, ICON_OVERLAY)
	// Note: These used to be in update_face(), and the fact they're here will make it difficult to create a disembodied head
	var/icon/eyes_s = new/icon('icons/mob/human_face.dmi', "eyes_s")
	var/icon/eyes_l = new/icon('icons/mob/human_face.dmi', "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	stand_icon.Blend(eyes_s, ICON_OVERLAY)
	lying_icon.Blend(eyes_l, ICON_OVERLAY)

	//Mouth	(lipstick!)
	if(lip_style)	//skeletons are allowed to wear lipstick no matter what you think, agouri.
		stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)
		lying_icon.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_l"), ICON_OVERLAY)

	//Underwear
	if(underwear >0 && underwear < 12)
		if(!fat && !skeleton)			stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)	if(update_icons)	update_icons()
	//tail	update_tail_showing(0)


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair(var/update_icons=1)
	//Reset our hair
	overlays_lying[HAIR_LAYER]		= null
	overlays_standing[HAIR_LAYER]	= null

	var/datum/organ/external/head/head = get_organ("head")
	if( !head || (head.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.status & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
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
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_standing.Blend(facial_s, ICON_OVERLAY)
			face_lying.Blend(facial_l, ICON_OVERLAY)

	if(h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			face_standing.Blend(hair_s, ICON_OVERLAY)
			face_lying.Blend(hair_l, ICON_OVERLAY)

	overlays_lying[HAIR_LAYER]		= image(face_lying)
	overlays_standing[HAIR_LAYER]	= image(face_standing)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_mutations(var/update_icons=1)
	var/fat
	if(FAT in mutations)
		fat = "fat"

	var/image/lying		= image("icon" = 'icons/effects/genetics.dmi')
	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi')
	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	for(var/mut in mutations)
		switch(mut)
			if(HULK)
				if(fat)
					lying.underlays		+= "hulk_[fat]_l"
					standing.underlays	+= "hulk_[fat]_s"
				else
					lying.underlays		+= "hulk_[g]_l"
					standing.underlays	+= "hulk_[g]_s"
				add_image = 1
			if(COLD_RESISTANCE)
				lying.underlays		+= "fire[fat]_l"
				standing.underlays	+= "fire[fat]_s"
				add_image = 1
			if(TK)
				lying.underlays		+= "telekinesishead[fat]_l"
				standing.underlays	+= "telekinesishead[fat]_s"
				add_image = 1
			if(LASER)
				lying.overlays		+= "lasereyes_l"
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if(add_image)
		overlays_lying[MUTATIONS_LAYER]		= lying
		overlays_standing[MUTATIONS_LAYER]	= standing
	else
		overlays_lying[MUTATIONS_LAYER]		= null
		overlays_standing[MUTATIONS_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/proc/update_mutantrace(var/update_icons=1)
	var/fat
	if( FAT in mutations )
		fat = "fat"
	var/g = "m"
	if (gender == FEMALE)	g = "f"
//BS12 EDIT
	if(dna)
		switch(dna.mutantrace)
			if("golem","metroid")
				overlays_lying[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_l")
				overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_s")
			if("lizard", "tajaran", "skrell")
				overlays_lying[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/species.dmi', "icon_state" = "[dna.mutantrace]_[g]_l")
				overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/species.dmi', "icon_state" = "[dna.mutantrace]_[g]_s")
			if("plant")
				if(stat == DEAD)	//TODO
					overlays_lying[MUTANTRACE_LAYER] = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace]_d")
				else
					overlays_lying[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_l")
					overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_s")
			else
				overlays_lying[MUTANTRACE_LAYER]	= null
				overlays_standing[MUTANTRACE_LAYER]	= null
	update_body(0)
	update_hair(0)
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
	UpdateDamageIcon()
	update_icons()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(var/update_icons=1)
	if(w_uniform && istype(w_uniform, /obj/item/clothing/under) )
		w_uniform.screen_loc = ui_iclothing
		var/t_color = w_uniform.color
		if(!t_color)		t_color = icon_state
		var/image/lying		= image("icon_state" = "[t_color]_l")
		var/image/standing	= image("icon_state" = "[t_color]_s")

		if(FAT in mutations)
			if(w_uniform.flags&ONESIZEFITSALL)
				lying.icon		= 'icons/mob/uniform_fat.dmi'
				standing.icon	= 'icons/mob/uniform_fat.dmi'
			else
				src << "\red You burst out of \the [w_uniform]!"
				drop_from_inventory(w_uniform)
				return
		else
			lying.icon		= 'icons/mob/uniform.dmi'
			standing.icon	= 'icons/mob/uniform.dmi'

		if(w_uniform.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")

		if(w_uniform:hastie)	//WE CHECKED THE TYPE ABOVE. THIS REALLY SHOULD BE FINE.
			var/tie_color = w_uniform:hastie.color
			if(!tie_color) tie_color = w_uniform:hastie.icon_state
			lying.overlays		+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]2")
			standing.overlays	+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]")

		overlays_lying[UNIFORM_LAYER]		= lying
		overlays_standing[UNIFORM_LAYER]	= standing
	else
		overlays_lying[UNIFORM_LAYER]		= null
		overlays_standing[UNIFORM_LAYER]	= null
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for( var/obj/item/thing in list(r_store, l_store, wear_id, belt) )						//
			if(thing)																			//
				u_equip(thing)																	//
				if (client)																		//
					client.screen -= thing														//
																								//
				if (thing)																		//
					thing.loc = loc																//
					thing.dropped(src)															//
					thing.layer = initial(thing.layer)
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_wear_id(var/update_icons=1)
	if(wear_id)
		overlays_lying[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id2")
		overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")
		wear_id.screen_loc = ui_id	//TODO
	else
		overlays_lying[ID_LAYER]	= null
		overlays_standing[ID_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_gloves(var/update_icons=1)
	if(gloves)
		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/lying		= image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]2")
		var/image/standing	= image("icon" = 'icons/mob/hands.dmi', "icon_state" = "[t_state]")
		if(gloves.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
		gloves.screen_loc = ui_gloves
		overlays_lying[GLOVES_LAYER]	= lying
		overlays_standing[GLOVES_LAYER]	= standing
	else
		if(blood_DNA)
			overlays_lying[GLOVES_LAYER]	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands2")
			overlays_standing[GLOVES_LAYER]	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
		else
			overlays_lying[GLOVES_LAYER]	= null
			overlays_standing[GLOVES_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_glasses(var/update_icons=1)
	if(glasses)
		overlays_lying[GLASSES_LAYER]		= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]2")
		overlays_standing[GLASSES_LAYER]	= image("icon" = 'icons/mob/eyes.dmi', "icon_state" = "[glasses.icon_state]")
	else
		overlays_lying[GLASSES_LAYER]		= null
		overlays_standing[GLASSES_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_ears(var/update_icons=1)
	if(ears)
		overlays_lying[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[ears.icon_state]2")
		overlays_standing[EARS_LAYER] = image("icon" = 'icons/mob/ears.dmi', "icon_state" = "[ears.icon_state]")
	else
		overlays_lying[EARS_LAYER]		= null
		overlays_standing[EARS_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_shoes(var/update_icons=1)
	if(shoes)
		var/image/lying		= image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]2")
		var/image/standing	= image("icon" = 'icons/mob/feet.dmi', "icon_state" = "[shoes.icon_state]")
		if(shoes.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
		overlays_lying[SHOES_LAYER]		= lying
		overlays_standing[SHOES_LAYER]	= standing
	else
		overlays_lying[SHOES_LAYER]			= null
		overlays_standing[SHOES_LAYER]		= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_s_store(var/update_icons=1)
	if(s_store)
		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_lying[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]2")
		overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]")
		s_store.screen_loc = ui_sstore1		//TODO
	else
		overlays_lying[SUIT_STORE_LAYER]	= null
		overlays_standing[SUIT_STORE_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_head(var/update_icons=1)
	if(head)
		head.screen_loc = ui_head		//TODO
		var/image/lying
		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty))
			lying		= image("icon" = head:mob2)
			standing	= image("icon" = head:mob)
		else
			lying		= image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]2")
			standing	= image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]")
		if(head.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
		overlays_lying[HEAD_LAYER]		= lying
		overlays_standing[HEAD_LAYER]	= standing
	else
		overlays_lying[HEAD_LAYER]		= null
		overlays_standing[HEAD_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_belt(var/update_icons=1)
	if(belt)
		belt.screen_loc = ui_belt	//TODO
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		overlays_lying[BELT_LAYER]		= image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]2")
		overlays_standing[BELT_LAYER]	= image("icon" = 'icons/mob/belt.dmi', "icon_state" = "[t_state]")
	else
		overlays_lying[BELT_LAYER]		= null
		overlays_standing[BELT_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_wear_suit(var/update_icons=1)
	if( wear_suit && istype(wear_suit, /obj/item/clothing/suit) )	//TODO check this
		wear_suit.screen_loc = ui_oclothing	//TODO
		var/image/lying		= image("icon" = 'icons/mob/suit.dmi', "icon_state" = "[wear_suit.icon_state]2")
		var/image/standing	= image("icon" = 'icons/mob/suit.dmi', "icon_state" = "[wear_suit.icon_state]")

		if(FAT in mutations)
			if(!wear_suit.flags&ONESIZEFITSALL)
				src << "\red You burst out of \the [wear_suit]!"
				var/obj/item/clothing/c = wear_suit
				wear_suit = null
				if(client)
					client.screen -= c
				c.loc = loc
				c.dropped(src)
				c.layer = initial(c.layer)
				lying		= null
				standing	= null

		else
			if( istype(wear_suit, /obj/item/clothing/suit/straight_jacket) )
				drop_from_inventory(handcuffed)
				drop_l_hand()
				drop_r_hand()

			if(wear_suit.blood_DNA)
				var/t_state
				if( istype(wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/wcoat) )
					t_state = "armor"
				else if( istype(wear_suit, /obj/item/clothing/suit/det_suit || /obj/item/clothing/suit/labcoat) )
					t_state = "coat"
				else
					t_state = "suit"
				lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_state]blood2")
				standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_state]blood")

		overlays_lying[SUIT_LAYER]		= lying
		overlays_standing[SUIT_LAYER]	= standing

		update_tail_showing(0)

	else
		overlays_lying[SUIT_LAYER]		= null
		overlays_standing[SUIT_LAYER]	= null

		update_tail_showing(0)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_pockets(var/update_icons=1)
	if(l_store)			l_store.screen_loc = ui_storage1	//TODO
	if(r_store)			r_store.screen_loc = ui_storage2	//TODO
	if(update_icons)	update_icons()


/mob/living/carbon/human/update_inv_wear_mask(var/update_icons=1)
	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) )
		wear_mask.screen_loc = ui_mask	//TODO
		var/image/lying		= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]2")
		var/image/standing	= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]")
		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA )
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
		overlays_lying[FACEMASK_LAYER]		= lying
		overlays_standing[FACEMASK_LAYER]	= standing
	else
		overlays_lying[FACEMASK_LAYER]		= null
		overlays_standing[FACEMASK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_back(var/update_icons=1)
	if(back)
		back.screen_loc = ui_back	//TODO
		overlays_lying[BACK_LAYER]		= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]2")
		overlays_standing[BACK_LAYER]	= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]")
	else
		overlays_lying[BACK_LAYER]		= null
		overlays_standing[BACK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/human/update_inv_handcuffed(var/update_icons=1)
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		overlays_lying[HANDCUFF_LAYER]		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff2")
		overlays_standing[HANDCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1")
	else
		overlays_lying[HANDCUFF_LAYER]		= null
		overlays_standing[HANDCUFF_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_legcuffed(var/update_icons=1)
	if(legcuffed)
		overlays_lying[LEGCUFF_LAYER]		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff2")
		overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1")
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

	else
		overlays_lying[LEGCUFF_LAYER]		= null
		overlays_standing[LEGCUFF_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_r_hand(var/update_icons=1)
	if(r_hand)
		r_hand.screen_loc = ui_rhand	//TODO
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		overlays_standing[R_HAND_LAYER] = image("icon" = 'icons/mob/items_righthand.dmi', "icon_state" = "[t_state]")
		if (handcuffed) drop_r_hand()
	else
		overlays_standing[R_HAND_LAYER] = null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_l_hand(var/update_icons=1)
	if(l_hand)
		l_hand.screen_loc = ui_lhand	//TODO
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state
		overlays_standing[L_HAND_LAYER] = image("icon" = 'icons/mob/items_lefthand.dmi', "icon_state" = "[t_state]")
		if (handcuffed) drop_l_hand()
	else
		overlays_standing[L_HAND_LAYER] = null
	if(update_icons)   update_icons()

/mob/living/carbon/human/proc/update_tail_showing(var/update_icons=1)
	overlays_lying[TAIL_LAYER] = null
	overlays_standing[TAIL_LAYER] = null
	var/cur_species = get_species()
	if( cur_species == "Tajaran")
		if(!wear_suit || !(wear_suit.flags_inv & HIDEJUMPSUIT) && !istype(wear_suit, /obj/item/clothing/suit/space))
			overlays_lying[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "tajtail_l")
			overlays_standing[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "tajtail_s")
	else if( cur_species == "Soghun")
		if(!wear_suit || !(wear_suit.flags_inv & HIDEJUMPSUIT) && !istype(wear_suit, /obj/item/clothing/suit/space))
			overlays_lying[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "sogtail_l")
			overlays_standing[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "sogtail_s")

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
#undef TAIL_LAYER
#undef TOTAL_LAYERS
