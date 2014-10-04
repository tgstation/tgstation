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
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
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

//Human Overlays Indexes/////////
#define FIRE_LAYER				1		//If you're on fire (/tg/ shit)
#define MUTANTRACE_LAYER		2		//TODO: make part of body?
#define MUTATIONS_LAYER			3
#define DAMAGE_LAYER			4
#define UNIFORM_LAYER			5
#define ID_LAYER				6
#define SHOES_LAYER				7
#define GLOVES_LAYER			8
#define EARS_LAYER				9
#define SUIT_LAYER				10
#define GLASSES_LAYER			11
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		13
#define BACK_LAYER				14
#define HAIR_LAYER				15		//TODO: make part of head layer?
#define GLASSES_OVER_HAIR_LAYER	16
#define FACEMASK_LAYER			17
#define HEAD_LAYER				18
#define HANDCUFF_LAYER			19
#define LEGCUFF_LAYER			20
#define L_HAND_LAYER			21
#define R_HAND_LAYER			22
#define TAIL_LAYER				23		//bs12 specific. this hack is probably gonna come back to haunt me
#define TARGETED_LAYER			24		//BS12: Layer for the target overlay from weapon targeting system
#define TOTAL_LAYERS			25
//////////////////////////////////

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed
	var/icon/race_icon
	var/icon/deform_icon

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()
	update_hud()		//TODO: remove the need for this

	if(species && species.override_icon)
		overlays.len = 0
		icon = species.override_icon
		icon_state = "[lowertext(species.name)]_[gender][(mutations & M_FAT)?"_fat":""]"
	else
		if(overlays.len != overlays_standing.len)
			overlays.len = 0
			overlays.len = overlays_standing.len
			icon = stand_icon

			for(var/overlay in overlays_standing)
				if(overlay)
					overlays += overlay

	update_transform()

var/global/list/damage_icon_parts = list()

proc/get_damage_icon_part(damage_state, body_part)
	if(damage_icon_parts["[damage_state]/[body_part]"] == null)
		var/icon/DI = new /icon('icons/mob/dam_human.dmi', damage_state)			// the damage icon for whole human
		DI.Blend(new /icon('icons/mob/dam_mask.dmi', body_part), ICON_MULTIPLY)		// mask with this organ's pixels
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

	var/icon/standing = new /icon('icons/mob/dam_human.dmi', "00")

	var/image/standing_image = new /image("icon" = standing)


	// blend the individual damage states with our icons
	for(var/datum/organ/external/O in organs)
		if(!(O.status & ORGAN_DESTROYED))
			O.update_icon()
			if(O.damage_state == "00") continue

			var/icon/DI = get_damage_icon_part(O.damage_state, O.icon_name)

			standing_image.overlays += DI


	overlays_standing[DAMAGE_LAYER]	= standing_image

	if(update_icons)   update_icons()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(var/update_icons=1)

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (M_HUSK in src.mutations)  //100% unnecessary -Agouri	//nope, do you really want to iterate through src.mutations repeatedly? -Pete
	var/fat = (M_FAT in src.mutations)
	var/hulk = (M_HULK in src.mutations) && species.name == "Horror" // Part of the species.
	var/skeleton = (SKELETON in src.mutations)

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	var/datum/organ/external/chest = get_organ("chest")
	stand_icon = chest.get_icon(g,fat)
	if(!skeleton)
		if(husk)
			stand_icon.ColorTone(husk_color_mod)
		else if(hulk)
			var/list/TONE = ReadRGB(hulk_color_mod)
			stand_icon.MapColors(rgb(TONE[1],0,0),rgb(0,TONE[2],0),rgb(0,0,TONE[3]))

	var/datum/organ/external/head = get_organ("head")
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
	overlays_standing[HAIR_LAYER]	= null

	var/datum/organ/external/head/head_organ = get_organ("head")
	if( !head_organ || (head_organ.status & ORGAN_DESTROYED) )
		if(update_icons)   update_icons()
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)))
		if(update_icons)   update_icons()
		return

	//base icons
	var/icon/face_standing	= new /icon('icons/mob/human_face.dmi',"bald_s")

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style && src.species.name in facial_hair_style.species_allowed)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			face_standing.Blend(facial_s, ICON_OVERLAY)
		else
			warning("Invalid f_style for [species.name]: [f_style]")

	if(h_style && !(head && (head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(istype(hair_style) && (src.species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

			face_standing.Blend(hair_s, ICON_OVERLAY)
		else
			warning("Invalid h_style for [species.name]: [h_style]")

	overlays_standing[HAIR_LAYER]	= image(face_standing)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_mutations(var/update_icons=1)
	var/fat
	if(M_FAT in mutations)
		fat = "fat"

	var/image/standing	= image("icon" = 'icons/effects/genetics.dmi')
	var/add_image = 0
	var/g = "m"
	if(gender == FEMALE)	g = "f"
	// DNA2 - Drawing underlays.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			var/underlay=gene.OnDrawUnderlays(src,g,fat)
			if(underlay)
				standing.underlays += underlay
				add_image = 1
	for(var/mut in mutations)
		switch(mut)
			/*
			if(M_HULK)
				if(fat)
					standing.underlays	+= "hulk_[fat]_s"
				else
					standing.underlays	+= "hulk_[g]_s"
				add_image = 1
			if(M_RESIST_COLD)
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
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if((M_RESIST_COLD in mutations) && (M_RESIST_HEAT in mutations))
		standing.underlays	-= "cold[fat]_s"
		standing.underlays	-= "fire[fat]_s"
		standing.underlays	+= "coldfire[fat]_s"
	if(add_image)
		overlays_standing[MUTATIONS_LAYER]	= standing
	else
		overlays_standing[MUTATIONS_LAYER]	= null
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
		race_icon = species.icobase
		deform_icon = species.deform

	if(dna)
		switch(dna.mutantrace)
			if("golem","slime","shadow","adamantine")
				overlays_standing[MUTANTRACE_LAYER]	= image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[dna.mutantrace][fat]_[gender]_s")
			else
				overlays_standing[MUTANTRACE_LAYER]	= null

	if(!dna || !(dna.mutantrace in list("golem","metroid")))
		update_body(0)

	update_hair(0)
	if(update_icons)   update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted(var/update_icons=1)
	if (targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	if (!targeted_by)
		overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)		update_icons()

/mob/living/carbon/human/update_fire(var/update_icons=1)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_sprite, "layer"=-FIRE_LAYER)
	else
		overlays_standing[FIRE_LAYER] = null
	if(update_icons)		update_icons()


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(monkeyizing)		return
	update_fire(0)
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
		var/t_color = w_uniform._color
		if(!t_color)		t_color = icon_state
		var/image/standing	= image("icon_state" = "[t_color]_s")

		if(M_FAT in mutations)
			if(w_uniform.flags&ONESIZEFITSALL)
				standing.icon	= 'icons/mob/uniform_fat.dmi'
			else
				src << "\red You burst out of \the [w_uniform]!"
				drop_from_inventory(w_uniform)
				return
		else
			standing.icon	= 'icons/mob/uniform.dmi'

		var/obj/item/I = w_uniform
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.uniform_icons)
				standing.icon = species.uniform_icons

		if(w_uniform.icon_override)
			standing.icon	= w_uniform.icon_override

		if(w_uniform.blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "uniformblood")
			bloodsies.color		= w_uniform.blood_color
			standing.overlays	+= bloodsies

		if(w_uniform:hastie)	//WE CHECKED THE TYPE ABOVE. THIS REALLY SHOULD BE FINE.
			var/tie_color = w_uniform:hastie._color
			if(!tie_color) tie_color = w_uniform:hastie.icon_state
			standing.overlays	+= image("icon" = 'icons/mob/ties.dmi', "icon_state" = "[tie_color]")

		overlays_standing[UNIFORM_LAYER]	= standing
	else
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
		wear_id.screen_loc = ui_id	//TODO
		if(w_uniform && w_uniform:displays_id)
			overlays_standing[ID_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")
		else
			overlays_standing[ID_LAYER]	= null
	else
		overlays_standing[ID_LAYER]	= null

	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_gloves(var/update_icons=1)
	if(gloves)
		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/standing	= image("icon" = ((gloves.icon_override) ? gloves.icon_override : 'icons/mob/hands.dmi'), "icon_state" = "[t_state]")

		var/obj/item/I = gloves
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.gloves_icons)
				standing.icon = species.gloves_icons

		if(gloves.blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
		gloves.screen_loc = ui_gloves
		overlays_standing[GLOVES_LAYER]	= standing
	else
		if(blood_DNA)
			var/image/bloodsies	= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "bloodyhands")
			bloodsies.color = hand_blood_color
			overlays_standing[GLOVES_LAYER]	= bloodsies
		else
			overlays_standing[GLOVES_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_glasses(var/update_icons=1)
	if(glasses)
		var/image/standing = image("icon" = ((glasses.icon_override) ? glasses.icon_override : 'icons/mob/eyes.dmi'), "icon_state" = "[glasses.icon_state]")

		var/obj/item/I = glasses
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.glasses_icons)
				standing.icon = species.glasses_icons

		if(glasses.cover_hair)
			overlays_standing[GLASSES_OVER_HAIR_LAYER]	= standing
		else
			overlays_standing[GLASSES_LAYER]	= standing

	else
		overlays_standing[GLASSES_LAYER]	= null
		overlays_standing[GLASSES_OVER_HAIR_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_ears(var/update_icons=1)
	if(ears)
		var/image/standing = image("icon" = ((ears.icon_override) ? ears.icon_override : 'icons/mob/ears.dmi'), "icon_state" = "[ears.icon_state]")

		var/obj/item/I = ears
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.ears_icons)
				standing.icon = species.ears_icons

		overlays_standing[EARS_LAYER] = standing
	else
		overlays_standing[EARS_LAYER] = null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_shoes(var/update_icons=1)
	if(shoes)
		var/image/standing	= image("icon" = ((shoes.icon_override) ? shoes.icon_override : 'icons/mob/feet.dmi'), "icon_state" = "[shoes.icon_state]")

		var/obj/item/I = shoes
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.shoes_icons)
				standing.icon = species.shoes_icons

		if(shoes.blood_DNA)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "shoeblood")
			bloodsies.color = shoes.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[SHOES_LAYER]	= standing
	else
		overlays_standing[SHOES_LAYER]		= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_s_store(var/update_icons=1)
	if(s_store)
		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= image("icon" = 'icons/mob/belt_mirror.dmi', "icon_state" = "[t_state]")
		s_store.screen_loc = ui_sstore1		//TODO
	else
		overlays_standing[SUIT_STORE_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_head(var/update_icons=1)
	if(head)
		head.screen_loc = ui_head		//TODO
		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty))
			standing	= image("icon" = head:mob)
		else
			standing	= image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]")

		var/obj/item/I = head
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.head_icons)
				standing.icon = species.head_icons

		if(head.blood_DNA)
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[HEAD_LAYER]	= standing
	else
		overlays_standing[HEAD_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_belt(var/update_icons=1)
	if(belt)
		belt.screen_loc = ui_belt	//TODO
		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		var/image/standing = image("icon" = ((belt.icon_override) ? belt.icon_override : 'icons/mob/belt.dmi'), "icon_state" = "[t_state]")

		var/obj/item/I = belt
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.belt_icons)
				standing.icon = species.belt_icons

		overlays_standing[BELT_LAYER]	= standing
	else
		overlays_standing[BELT_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_wear_suit(var/update_icons=1)
	if( wear_suit && istype(wear_suit, /obj/item/clothing/suit) )	//TODO check this
		wear_suit.screen_loc = ui_oclothing	//TODO
		var/image/standing	= image("icon" = ((wear_suit.icon_override) ? wear_suit.icon_override : 'icons/mob/suit.dmi'), "icon_state" = "[wear_suit.icon_state]")

		if( istype(wear_suit, /obj/item/clothing/suit/straight_jacket) )
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()

		var/obj/item/I = wear_suit
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.wear_suit_icons)
				standing.icon = species.wear_suit_icons

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[S.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays	+= bloodsies

		overlays_standing[SUIT_LAYER]	= standing

		update_tail_showing(0)

	else
		overlays_standing[SUIT_LAYER]	= null

		update_tail_showing(0)

	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_pockets(var/update_icons=1)
	if(l_store)			l_store.screen_loc = ui_storage1	//TODO
	if(r_store)			r_store.screen_loc = ui_storage2	//TODO
	if(update_icons)	update_icons()


/mob/living/carbon/human/update_inv_wear_mask(var/update_icons=1)
	if( wear_mask && ( istype(wear_mask, /obj/item/clothing/mask) || istype(wear_mask, /obj/item/clothing/tie) ) )
		wear_mask.screen_loc = ui_mask	//TODO
		var/image/standing	= image("icon" = ((wear_mask.icon_override) ? wear_mask.icon_override : 'icons/mob/mask.dmi'), "icon_state" = "[wear_mask.icon_state]")

		var/obj/item/I = wear_mask
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.wear_mask_icons)   //This REQUIRES the species to be listed in species_fit and also to have an appropriate dmi allocated in their species datum
				standing.icon = species.wear_mask_icons

		if( !istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA )
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
			bloodsies.color = wear_mask.blood_color
			standing.overlays	+= bloodsies
		overlays_standing[FACEMASK_LAYER]	= standing
	else
		overlays_standing[FACEMASK_LAYER]	= null
	if(update_icons)   update_icons()


/mob/living/carbon/human/update_inv_back(var/update_icons=1)
	if(back)
		back.screen_loc = ui_back	//TODO
		var/image/standing	= image("icon" = ((back.icon_override) ? back.icon_override : 'icons/mob/back.dmi'), "icon_state" = "[back.icon_state]")

		var/obj/item/I = back
		if(species.name in I.species_fit) //Allows clothes to display differently for multiple species
			if(species.back_icons)
				standing.icon = species.back_icons

		overlays_standing[BACK_LAYER]	= standing
	else
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
		overlays_standing[HANDCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1")
	else
		overlays_standing[HANDCUFF_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/human/update_inv_legcuffed(var/update_icons=1)
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER]	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "legcuff1")
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

	else
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
	overlays_standing[TAIL_LAYER] = null

	if(species.tail && species.flags & HAS_TAIL)
		if(!wear_suit || !(wear_suit.flags_inv & HIDEJUMPSUIT) && !istype(wear_suit, /obj/item/clothing/suit/space))
			overlays_standing[TAIL_LAYER] = image("icon" = 'icons/effects/species.dmi', "icon_state" = "[species.tail]_s")

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
#undef FIRE_LAYER
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
#undef TARGETED_LAYER
#undef TOTAL_LAYERS
