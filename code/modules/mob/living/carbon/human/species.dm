// This code handles different species in the game.

#define TINT_IMPAIR 2
#define TINT_BLIND 3

#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSmob.wait/30)

#define HEAT_DAMAGE_LEVEL_1 2
#define HEAT_DAMAGE_LEVEL_2 3
#define HEAT_DAMAGE_LEVEL_3 8

#define COLD_DAMAGE_LEVEL_1 0.5
#define COLD_DAMAGE_LEVEL_2 1.5
#define COLD_DAMAGE_LEVEL_3 3

#define HEAT_GAS_DAMAGE_LEVEL_1 2
#define HEAT_GAS_DAMAGE_LEVEL_2 4
#define HEAT_GAS_DAMAGE_LEVEL_3 8

#define COLD_GAS_DAMAGE_LEVEL_1 0.5
#define COLD_GAS_DAMAGE_LEVEL_2 1.5
#define COLD_GAS_DAMAGE_LEVEL_3 3

/datum/species
	var/id = null		// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/name = null		// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/roundstart = 0	// can this mob be chosen at roundstart? (assuming the config option is checked?)
	var/default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race

	var/eyes = "eyes"	// which eyes the race uses. at the moment, the only types of eyes are "eyes" (regular eyes) and "jelleyes" (three eyes)
	var/sexes = 1		// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/hair_color = null	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/use_skintones = 0	// does it use skintones or not? (spoiler alert this is only used by humans)
	var/exotic_blood = null	// If your race wants to bleed something other than bog standard blood, change this.
	var/meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human //What the species drops on gibbing
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids

	var/say_mod = "says"	// affects the speech message

	var/list/mutant_bodyparts = list() 	// Parts of the body that are diferent enough from the standard human model that they cause clipping with some equipment

	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/punchmod = 0	// adds to the punch damage

	var/invis_sight = SEE_INVISIBLE_LIVING
	var/darksight = 2

	// species flags. these can be found in flags.dm
	var/list/specflags = list()

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	var/mob/living/list/ignored_by = list()	// list of mobs that will ignore this species

	///////////
	// PROCS //
	///////////

/datum/species/proc/update_base_icon_state(var/mob/living/carbon/human/H)
	if(H.disabilities & HUSK)
		H.remove_overlay(SPECIES_LAYER) // races lose their color
		return "husk"
	else if(sexes)
		if(use_skintones)
			return "[H.skin_tone]_[(H.gender == FEMALE) ? "f" : "m"]"
		else
			return "[id]_[(H.gender == FEMALE) ? "f" : "m"]"
	else
		return "[id]"

/datum/species/proc/update_color(var/mob/living/carbon/human/H)
	H.remove_overlay(SPECIES_LAYER)

	var/image/standing

	var/g = (H.gender == FEMALE) ? "f" : "m"

	if(MUTCOLORS in specflags)
		var/image/spec_base
		var/icon_state_string = "[id]_"
		if(sexes)
			icon_state_string += "[g]_s"
		else
			icon_state_string += "_s"

		spec_base = image("icon" = 'icons/mob/human.dmi', "icon_state" = icon_state_string, "layer" = -SPECIES_LAYER)

		spec_base.color = "#[H.dna.mutant_color]"
		standing = spec_base

	if(standing)
		H.overlays_standing[SPECIES_LAYER]	+= standing

	H.apply_overlay(SPECIES_LAYER)

/datum/species/proc/handle_hair(var/mob/living/carbon/human/H)
	H.remove_overlay(HAIR_LAYER)

	var/datum/sprite_accessory/S
	var/list/standing	= list()

	if(H.facial_hair_style && FACEHAIR in specflags)
		S = facial_hair_styles_list[H.facial_hair_style]
		if(S)
			var/image/img_facial_s

			img_facial_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			if(hair_color)
				if(hair_color == "mutcolor")
					img_facial_s.color = "#" + H.dna.mutant_color
				else
					img_facial_s.color = "#" + hair_color
			else
				img_facial_s.color = "#" + H.facial_hair_color
			img_facial_s.alpha = hair_alpha

			standing	+= img_facial_s

	//Applies the debrained overlay if there is no brain
	if(!H.getorgan(/obj/item/organ/brain))
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s", "layer" = -HAIR_LAYER)

	if((H.wear_suit) && (H.wear_suit.hooded) && (H.wear_suit.suittoggled == 1))
		if(standing.len)
			H.overlays_standing[HAIR_LAYER]    = standing
		H.apply_overlay(HAIR_LAYER)
		return

	else if(H.hair_style && HAIR in specflags)
		S = hair_styles_list[H.hair_style]
		if(S)
			var/image/img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			if(hair_color)
				if(hair_color == "mutcolor")
					img_hair_s.color = "#" + H.dna.mutant_color
				else
					img_hair_s.color = "#" + hair_color
			else
				img_hair_s.color = "#" + H.hair_color
			img_hair_s.alpha = hair_alpha

			standing	+= img_hair_s

	if(standing.len)
		H.overlays_standing[HAIR_LAYER]	= standing

	H.apply_overlay(HAIR_LAYER)
	return

/datum/species/proc/handle_body(var/mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing	= list()

	handle_mutant_bodyparts(H)

	// lipstick
	if(H.lip_style && LIPS in specflags)
		var/image/lips = image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[H.lip_style]_s", "layer" = -BODY_LAYER)
		lips.color = H.lip_color
		standing	+= lips

	// eyes
	if(EYECOLOR in specflags)
		var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[eyes]_s", "layer" = -BODY_LAYER)
		img_eyes_s.color = "#" + H.eye_color
		standing	+= img_eyes_s

	//Underwear, Undershirts & Socks
	if(H.underwear)
		var/datum/sprite_accessory/underwear/U = underwear_list[H.underwear]
		if(U)
			standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)

	if(H.undershirt)
		var/datum/sprite_accessory/undershirt/U2 = undershirt_list[H.undershirt]
		if(U2)
			if(H.dna && H.dna.species.sexes && H.gender == FEMALE)
				standing	+=	H.wear_female_version(U2.icon_state, U2.icon, BODY_LAYER)
			else
				standing	+= image("icon"=U2.icon, "icon_state"="[U2.icon_state]_s", "layer"=-BODY_LAYER)

	if(H.socks)
		var/datum/sprite_accessory/socks/U3 = socks_list[H.socks]
		if(U3)
			standing	+= image("icon"=U3.icon, "icon_state"="[U3.icon_state]_s", "layer"=-BODY_LAYER)

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)

	return

/datum/species/proc/handle_mutant_bodyparts(var/mob/living/carbon/human/H)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts)
		return

	if("tail" in mutant_bodyparts)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail"

	if("snout" in mutant_bodyparts) //Take a closer look at that snout!
		if(H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE))
			bodyparts_to_add -= "snout"

	if(!bodyparts_to_add)
		return

	var/icon_state_string = "[id]_"
	var/g = (H.gender == FEMALE) ? "f" : "m"
	var/image/I

	if(sexes)
		icon_state_string += "[g]_s"
	else
		icon_state_string += "_s"

	for(var/layer in relevent_layers)
		for(var/bodypart in bodyparts_to_add)
			I = image("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = "[icon_state_string]_[bodypart]_[layer]", "layer" =- layer)
			if(!(H.disabilities & HUSK))
				I.color = "#[H.dna.mutant_color]"
			standing += I
		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

/datum/species/proc/spec_life(var/mob/living/carbon/human/H)
	return

/datum/species/proc/spec_death(var/gibbed, var/mob/living/carbon/human/H)
	return

/datum/species/proc/auto_equip(var/mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(var/obj/item/I, var/slot, var/disable_warning, var/mob/living/carbon/human/H)
	if(slot in no_equip)
		if(!(type in I.species_exception))
			return 0

	switch(slot)
		if(slot_l_hand)
			if(H.l_hand)
				return 0
			return 1
		if(slot_r_hand)
			if(H.r_hand)
				return 0
			return 1
		if(slot_wear_mask)
			if(H.wear_mask)
				return 0
			if( !(I.slot_flags & SLOT_MASK) )
				return 0
			return 1
		if(slot_back)
			if(H.back)
				return 0
			if( !(I.slot_flags & SLOT_BACK) )
				return 0
			return 1
		if(slot_wear_suit)
			if(H.wear_suit)
				return 0
			if( !(I.slot_flags & SLOT_OCLOTHING) )
				return 0
			return 1
		if(slot_gloves)
			if(H.gloves)
				return 0
			if( !(I.slot_flags & SLOT_GLOVES) )
				return 0
			return 1
		if(slot_shoes)
			if(H.shoes)
				return 0
			if( !(I.slot_flags & SLOT_FEET) )
				return 0
			return 1
		if(slot_belt)
			if(H.belt)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return 0
			if( !(I.slot_flags & SLOT_BELT) )
				return
			return 1
		if(slot_glasses)
			if(H.glasses)
				return 0
			if( !(I.slot_flags & SLOT_EYES) )
				return 0
			return 1
		if(slot_head)
			if(H.head)
				return 0
			if( !(I.slot_flags & SLOT_HEAD) )
				return 0
			return 1
		if(slot_ears)
			if(H.ears)
				return 0
			if( !(I.slot_flags & SLOT_EARS) )
				return 0
			return 1
		if(slot_w_uniform)
			if(H.w_uniform)
				return 0
			if( !(I.slot_flags & SLOT_ICLOTHING) )
				return 0
			return 1
		if(slot_wear_id)
			if(H.wear_id)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return 0
			if( !(I.slot_flags & SLOT_ID) )
				return 0
			return 1
		if(slot_l_store)
			if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
				return 0
			if(H.l_store)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return
			if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
				return 1
		if(slot_r_store)
			if(I.flags & NODROP)
				return 0
			if(H.r_store)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>"
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return 0
			if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
				return 1
			return 0
		if(slot_s_store)
			if(I.flags & NODROP)
				return 0
			if(H.s_store)
				return 0
			if(!H.wear_suit)
				if(!disable_warning)
					H << "<span class='warning'>You need a suit before you can attach this [I.name]!</span>"
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					H << "You somehow have a suit with no defined allowed items for suit storage, stop that."
				return 0
			if(I.w_class > 4)
				if(!disable_warning)
					H << "The [I.name] is too big to attach."  //should be src?
				return 0
			if( istype(I, /obj/item/device/pda) || istype(I, /obj/item/weapon/pen) || is_type_in_list(I, H.wear_suit.allowed) )
				return 1
			return 0
		if(slot_handcuffed)
			if(H.handcuffed)
				return 0
			if(!istype(I, /obj/item/weapon/restraints/handcuffs))
				return 0
			return 1
		if(slot_legcuffed)
			if(H.legcuffed)
				return 0
			if(!istype(I, /obj/item/weapon/restraints/legcuffs))
				return 0
			return 1
		if(slot_in_backpack)
			if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = H.back
				if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
					return 1
			return 0
	return 0 //Unsupported slot

/datum/species/proc/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	return

/datum/species/proc/after_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	return

/datum/species/proc/handle_chemicals(var/datum/reagent/chem, var/mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_speech(var/message, var/mob/living/carbon/human/H)
	return message

////////
	//LIFE//
	////////

/datum/species/proc/handle_chemicals_in_body(var/mob/living/carbon/human/H)

	//The fucking FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(H.disabilities & FAT)
		if(H.overeatduration < 100)
			H << "<span class='notice'>You feel fit again!</span>"
			H.disabilities &= ~FAT
			H.update_inv_w_uniform(0)
			H.update_inv_wear_suit()
	else
		if(H.overeatduration > 500)
			H << "<span class='danger'>You suddenly feel blubbery!</span>"
			H.disabilities |= FAT
			H.update_inv_w_uniform(0)
			H.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (H.nutrition > 0 && H.stat != 2)
		var/hunger_rate = HUNGER_FACTOR
		if(H.satiety > 0)
			H.satiety--
		if(H.satiety < 0)
			H.satiety++
			if(prob(round(-H.satiety/40)))
				H.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		H.nutrition = max (0, H.nutrition - hunger_rate)


	if (H.nutrition > NUTRITION_LEVEL_FULL)
		if(H.overeatduration < 600) //capped so people don't take forever to unfat
			H.overeatduration++
	else
		if(H.overeatduration > 1)
			H.overeatduration -= 2 //doubled the unfat rate

	//metabolism change
	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.metabolism_efficiency = 1
	else if(H.nutrition > NUTRITION_LEVEL_FED && H.satiety > 80)
		if(H.metabolism_efficiency != 1.25)
			H << "<span class='notice'>You feel vigorous.</span>"
			H.metabolism_efficiency = 1.25
	else if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(H.metabolism_efficiency != 0.8)
			H << "<span class='notice'>You feel sluggish.</span>"
		H.metabolism_efficiency = 0.8
	else
		if(H.metabolism_efficiency == 1.25)
			H << "<span class='notice'>You no longer feel vigorous.</span>"
		H.metabolism_efficiency = 1

	H.updatehealth()

	return

/datum/species/proc/handle_vision(var/mob/living/carbon/human/H)
	if( H.stat == DEAD )
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		H.see_in_dark = 8
		if(!H.druggy)		H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		if(!(SEE_TURFS & H.permanent_sight_flags))
			H.sight &= ~SEE_TURFS
		if(!(SEE_MOBS & H.permanent_sight_flags))
			H.sight &= ~SEE_MOBS
		if(!(SEE_OBJS & H.permanent_sight_flags))
			H.sight &= ~SEE_OBJS

		if(H.remote_view)
			H.sight |= SEE_TURFS
			H.sight |= SEE_MOBS
			H.sight |= SEE_OBJS

		H.see_in_dark = (H.sight == SEE_TURFS|SEE_MOBS|SEE_OBJS) ? 8 : darksight
		var/see_temp = H.see_invisible
		H.see_invisible = invis_sight

		if(H.seer)
			H.see_invisible = SEE_INVISIBLE_OBSERVER

		if(H.glasses)
			if(istype(H.glasses, /obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = H.glasses
				H.sight |= G.vision_flags
				H.see_in_dark = G.darkness_view
				H.see_invisible = G.invis_view
		if(H.druggy)	//Override for druggy
			H.see_invisible = see_temp

		if(H.see_override)	//Override all
			H.see_invisible = H.see_override

		//	This checks how much the mob's eyewear impairs their vision
		if(H.tinttotal >= TINT_IMPAIR)
			if(tinted_weldhelh)
				if(H.tinttotal >= TINT_BLIND)
					H.eye_blind = max(H.eye_blind, 1)
				if(H.client)
					H.client.screen += global_hud.darkMask

		if(H.blind)
			if(H.eye_blind)		H.blind.layer = 18
			else			H.blind.layer = 0

		if(!H.client)//no client, no screen to update
			return 1

		if( H.disabilities & NEARSIGHT && !istype(H.glasses, /obj/item/clothing/glasses/regular) )
			H.client.screen += global_hud.vimpaired
		if(H.eye_blurry)			H.client.screen += global_hud.blurry
		if(H.druggy)				H.client.screen += global_hud.druggy


		if(H.eye_stat > 20)
			if(H.eye_stat > 30)	H.client.screen += global_hud.darkMask
			else				H.client.screen += global_hud.vimpaired

	return 1

/datum/species/proc/handle_hud_icons(var/mob/living/carbon/human/H)
	if(H.healths)
		if(H.stat == DEAD)
			H.healths.icon_state = "health7"
		else
			switch(H.hal_screwyhud)
				if(1)	H.healths.icon_state = "health6"
				if(2)	H.healths.icon_state = "health7"
				else
					switch(H.health - H.staminaloss)
						if(100 to INFINITY)		H.healths.icon_state = "health0"
						if(80 to 100)			H.healths.icon_state = "health1"
						if(60 to 80)			H.healths.icon_state = "health2"
						if(40 to 60)			H.healths.icon_state = "health3"
						if(20 to 40)			H.healths.icon_state = "health4"
						if(0 to 20)				H.healths.icon_state = "health5"
						else					H.healths.icon_state = "health6"

	if(H.healthdoll)
		H.healthdoll.overlays.Cut()
		if(H.stat == DEAD)
			H.healthdoll.icon_state = "healthdoll_DEAD"
		else
			H.healthdoll.icon_state = "healthdoll_OVERLAY"
			for(var/obj/item/organ/limb/L in H.organs)
				var/damage = L.burn_dam + L.brute_dam
				var/comparison = (L.max_damage/5)
				var/icon_num = 0
				if(damage)
					icon_num = 1
				if(damage > (comparison))
					icon_num = 2
				if(damage > (comparison*2))
					icon_num = 3
				if(damage > (comparison*3))
					icon_num = 4
				if(damage > (comparison*4))
					icon_num = 5
				if(icon_num)
					H.healthdoll.overlays += image('icons/mob/screen_gen.dmi',"[L.name][icon_num]")

	switch(H.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			H.throw_alert("nutrition","fat")
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			H.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("nutrition","hungry")
		else
			H.throw_alert("nutrition","starving")

	return 1

/datum/species/proc/handle_mutations_and_radiation(var/mob/living/carbon/human/H)

	if(!(RADIMMUNE in specflags))
		if(H.radiation)
			if (H.radiation > 100)
				H.Weaken(10)
				H << "<span class='danger'>You feel weak.</span>"
				H.emote("collapse")

			switch(H.radiation)

				if(50 to 75)
					if(prob(5))
						H.Weaken(3)
						H << "<span class='danger'>You feel weak.</span>"
						H.emote("collapse")
					if(prob(15))
						if(!( H.hair_style == "Shaved") || !(H.hair_style == "Bald") || HAIR in specflags)
							H << "<span class='danger'>Your hair starts to fall out in clumps...<span>"
							spawn(50)
								H.facial_hair_style = "Shaved"
								H.hair_style = "Bald"
								H.update_hair()

				if(75 to 100)
					if(prob(1))
						H << "<span class='danger'>You mutate!</span>"
						randmutb(H)
						domutcheck(H,null)
						H.emote("gasp")
		return 1

////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/movement_delay(var/mob/living/carbon/human/H)
	var/mspeed = 0

	if(!(H.status_flags & IGNORESLOWDOWN))

		var/grav = has_gravity(H)
		var/hasjetpack = 0
		if(!grav)
			var/obj/item/weapon/tank/jetpack/J
			var/obj/item/weapon/tank/jetpack/P

			if(istype(H.back, /obj/item/weapon/tank/jetpack))
				J = H.back
			if(istype(H.wear_suit,/obj/item/clothing/suit/space/hardsuit)) //copypasta but faster implementation currently
				var/obj/item/clothing/suit/space/hardsuit/C = H.wear_suit
				P = C.jetpack
			if(J)
				if(J.allow_thrust(0.01, H))
					hasjetpack = 1
			else if(P)
				if(P.allow_thrust(0.01, H))
					hasjetpack = 1

			mspeed = 1 - hasjetpack

		if(grav || !hasjetpack)
			var/health_deficiency = (100 - H.health + H.staminaloss)
			if(health_deficiency >= 40)
				mspeed += (health_deficiency / 25)

			var/hungry = (500 - H.nutrition) / 5	//So overeat would be 100 and default level would be 80
			if(hungry >= 70)
				mspeed += hungry / 50

			if(H.wear_suit)
				mspeed += H.wear_suit.slowdown
			if(H.shoes)
				mspeed += H.shoes.slowdown
			if(H.back)
				mspeed += H.back.slowdown

			if((H.disabilities & FAT))
				mspeed += 1.5
			if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
				mspeed += (BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

			mspeed += speedmod

	if(H.status_flags & GOTTAGOFAST)
		mspeed -= 1

	if(H.status_flags & GOTTAGOREALLYFAST)
		mspeed -= 2

	return mspeed

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_attack_hand(var/mob/living/carbon/human/M, var/mob/living/carbon/human/H)
	if(!istype(M)) //sanity check for drones.
		return
	if((M != H) && H.check_shields(0, M.name))
		add_logs(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
		return 0

	var/datum/martial_art/attacker_style = M.martial_art

	switch(M.a_intent)
		if("help")
			if(H.health >= 0)
				H.help_shake_act(M)
				if(H != M)
					add_logs(M, H, "shaked")
				return 1
			else
				M.do_cpr(H)

		if("grab")
			if(attacker_style && attacker_style.grab_act(M,H))
				return 1
			else
				H.grabbedby(M)
				return 1

		if("harm")
			if(attacker_style && attacker_style.harm_act(M,H))
				return 1
			else
				add_logs(M, H, "punched")
				M.do_attack_animation(H)

				var/atk_verb = "punch"
				if(H.lying)
					atk_verb = "kick"
				else if(M.dna)
					atk_verb = M.dna.species.attack_verb

				var/damage = rand(0, 9)
				if(M.dna)
					damage += M.dna.species.punchmod

				if(!damage)
					if(M.dna)
						playsound(H.loc, M.dna.species.miss_sound, 25, 1, -1)
					else
						playsound(H.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

					H.visible_message("<span class='warning'>[M] has attempted to [atk_verb] [H]!</span>")
					return 0


				var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_sel.selecting))
				var/armor_block = H.run_armor_check(affecting, "melee")

				if(M.dna)
					playsound(H.loc, M.dna.species.attack_sound, 25, 1, -1)
				else
					playsound(H.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


				H.visible_message("<span class='danger'>[M] has [atk_verb]ed [H]!</span>", \
								"<span class='userdanger'>[M] has [atk_verb]ed [H]!</span>")

				H.apply_damage(damage, BRUTE, affecting, armor_block)
				if((H.stat != DEAD) && damage >= 9)
					H.visible_message("<span class='danger'>[M] has weakened [H]!</span>", \
									"<span class='userdanger'>[M] has weakened [H]!</span>")
					H.apply_effect(4, WEAKEN, armor_block)
					H.forcesay(hit_appends)
				else if(H.lying)
					H.forcesay(hit_appends)
		if("disarm")
			if(attacker_style && attacker_style.disarm_act(M,H))
				return 1
			else
				M.do_attack_animation(H)
				add_logs(M, H, "disarmed")

				if(H.w_uniform)
					H.w_uniform.add_fingerprint(M)
				var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_sel.selecting))
				var/randn = rand(1, 100)
				if(randn <= 25)
					playsound(H, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					H.visible_message("<span class='danger'>[M] has pushed [H]!</span>",
									"<span class='userdanger'>[M] has pushed [H]!</span>")
					H.apply_effect(2, WEAKEN, H.run_armor_check(affecting, "melee", "Your armor prevents your fall!", "Your armor softens your fall!"))
					H.forcesay(hit_appends)
					return

				var/talked = 0	// BubbleWrap

				if(randn <= 60)
					//BubbleWrap: Disarming breaks a pull
					if(H.pulling)
						H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [H.pulling]!</span>")
						talked = 1
						H.stop_pulling()

					//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
					if(istype(H.l_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/lgrab = H.l_hand
						if(lgrab.affecting)
							H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [lgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(lgrab)
					if(istype(H.r_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/rgrab = H.r_hand
						if(rgrab.affecting)
							H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [rgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(rgrab)
					//End BubbleWrap

					if(!talked)	//BubbleWrap
						if(H.drop_item())
							H.visible_message("<span class='danger'>[M] has disarmed [H]!</span>", \
											"<span class='userdanger'>[M] has disarmed [H]!</span>")
					playsound(H, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return


				playsound(H, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				H.visible_message("<span class='danger'>[M] attempted to disarm [H]!</span>", \
								"<span class='userdanger'>[M] attemped to disarm [H]!</span>")
	return

/datum/species/proc/spec_attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/obj/item/organ/limb/affecting, var/hit_area, var/intent, var/obj/item/organ/limb/target_limb, target_area, var/mob/living/carbon/human/H)
	// Allows you to put in item-specific reactions based on species
	if(user != src)
		user.do_attack_animation(H)
	if((user != H) && H.check_shields(I.force, "the [I.name]"))
		return 0

	if(I.attack_verb && I.attack_verb.len)
		H.visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [H] in the [hit_area] with [I]!</span>", \
						"<span class='userdanger'>[user] has [pick(I.attack_verb)] [H] in the [hit_area] with [I]!</span>")
	else if(I.force)
		H.visible_message("<span class='danger'>[user] has attacked [H] in the [hit_area] with [I]!</span>", \
						"<span class='userdanger'>[user] has attacked [H] in the [hit_area] with [I]!</span>")
	else
		return 0

	var/armor = H.run_armor_check(affecting, "melee", "<span class='notice'>Your armor has protected your [hit_area].</span>", "<span class='notice'>Your armor has softened a hit to your [hit_area].</span>")
	if(armor >= 100)	return 0
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force, I.damtype, affecting, armor, H)

	var/bloody = 0
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.status == ORGAN_ORGANIC)
			I.add_blood(H)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				var/turf/location = H.loc
				if(istype(location, /turf/simulated))
					location.add_blood(H)
				if(get_dist(H, H) <= 1)	//people with TK won't get smeared with blood
					if(H.wear_suit)
						H.wear_suit.add_blood(H)
						H.update_inv_wear_suit(0)	//updates mob overlays to show the new blood (no refresh)
					else if(H.w_uniform)
						H.w_uniform.add_blood(H)
						H.update_inv_w_uniform(0)	//updates mob overlays to show the new blood (no refresh)
					if (H.gloves)
						var/obj/item/clothing/gloves/G = H.gloves
						G.add_blood(H)
					else
						H.add_blood(H)
						H.update_inv_gloves()	//updates on-mob overlays for bloody hands and/or bloody gloves


		switch(hit_area)
			if("head")	//Harder to score a stun but if you do it lasts a bit longer
				if(H.stat == CONSCIOUS && armor < 50)
					if(prob(I.force))
						H.visible_message("<span class='danger'>[H] has been knocked unconscious!</span>", \
										"<span class='userdanger'>[H] has been knocked unconscious!</span>")
						H.apply_effect(20, PARALYZE, armor)
					if(prob(I.force + ((100 - H.health)/2)) && H != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(H.mind)
						ticker.mode.remove_gangster(H.mind, exclude_bosses=1)

				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_blood(H)
						H.update_inv_wear_mask(0)
					if(H.head)
						H.head.add_blood(H)
						H.update_inv_head(0)
					if(H.glasses && prob(33))
						H.glasses.add_blood(H)
						H.update_inv_glasses(0)

			if("chest")	//Easier to score a stun but lasts less time
				if(H.stat == CONSCIOUS && I.force && prob(I.force + 10))
					H.visible_message("<span class='danger'>[H] has been knocked down!</span>", \
									"<span class='userdanger'>[H] has been knocked down!</span>")
					H.apply_effect(5, WEAKEN, armor)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_blood(H)
						H.update_inv_wear_suit(0)
					if(H.w_uniform)
						H.w_uniform.add_blood(H)
						H.update_inv_w_uniform(0)

		if(Iforce > 10 || Iforce >= 5 && prob(33))
			H.forcesay(hit_appends)	//forcesay checks stat already.
		return

/datum/species/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/mob/living/carbon/human/H)
	H.apply_damage(I.force, I.damtype)
	if(I.damtype == "brute")
		if(prob(33) && I.force && !(NOBLOOD in specflags))
			var/turf/location = H.loc
			if(istype(location, /turf/simulated))
				location.add_blood_floor(H)

	var/message_verb = ""
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(I.force)
		message_verb = "attacked"

	var/attack_message = "[H] has been [message_verb] with [I]."
	if(user)
		user.do_attack_animation(src)
		if(user in viewers(src, null))
			attack_message = "[user] has [message_verb] [H] with [I]!"
	if(message_verb)
		H.visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>")

	return

/datum/species/proc/apply_damage(var/damage, var/damagetype = BRUTE, var/def_zone = null, var/blocked, var/mob/living/carbon/human/H)
	blocked = (100-(blocked+armor))/100
	if(blocked <= 0)	return 0

	var/obj/item/organ/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = H.get_organ(check_zone(def_zone))
	if(!organ)	return 0

	damage = (damage * blocked)

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			if(organ.take_damage(damage*brutemod, 0))
				H.update_damage_overlays(0)
		if(BURN)
			H.damageoverlaytemp = 20
			if(organ.take_damage(0, damage*burnmod))
				H.update_damage_overlays(0)
		if(TOX)
			H.adjustToxLoss(damage * blocked)
		if(OXY)
			H.adjustOxyLoss(damage * blocked)
		if(CLONE)
			H.adjustCloneLoss(damage * blocked)
		if(STAMINA)
			H.adjustStaminaLoss(damage * blocked)

/datum/species/proc/on_hit(var/obj/item/projectile/proj_type, var/mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florayield)
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	return

/////////////
//BREATHING//
/////////////

/datum/species/proc/breathe(var/mob/living/carbon/human/H)
	if(H.reagents.has_reagent("lexorin")) return
	if(istype(H.loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = H.loc.return_air()
	var/datum/gas_mixture/breath
	if(H.health <= config.health_threshold_crit)
		H.losebreath++
	if(H.losebreath>0) //Suffocating so do not take a breath
		H.losebreath--
		if (prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn H.emote("gasp")
		if(istype(H.loc, /obj/))
			var/obj/location_as_object = H.loc
			location_as_object.handle_internal_lifeform(H, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = H.get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(isobj(H.loc))
				var/obj/location_as_object = H.loc
				breath = location_as_object.handle_internal_lifeform(H, BREATH_VOLUME)
			else if(isturf(H.loc))
				var/breath_moles = 0
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
					// Not enough air around, take a percentage of what's there to model this properly
				breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = H.loc.remove_air(breath_moles)

				// Handle chem smoke effect  -- Doohl
				if(!H.has_smoke_protection())
					for(var/obj/effect/effect/chem_smoke/smoke in view(1, H))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(H, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(H, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
							break // If they breathe in the nasty stuff once, no need to continue checking

		else //Still give containing object the chance to interact
			if(istype(H.loc, /obj/))
				var/obj/location_as_object = H.loc
				location_as_object.handle_internal_lifeform(H, 0)

	check_breath(breath, H)

	if(breath)
		H.loc.assume_air(breath)

/datum/species/proc/check_breath(datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	if((H.status_flags & GODMODE))
		return

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent("epinephrine"))
			return
		if(H.health >= config.health_threshold_crit)
			if(NOBREATH in specflags)	return 1
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			H.failed_last_breath = 1
		else
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			H.failed_last_breath = 1

		H.throw_alert("oxy")

		return 0

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	//Partial pressure of the O2 in our breath
	var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
	// Same, but for the toxins
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure // Tweaking to fit the hacky bullshit I've done with atmo -- TLE
	//var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*0.5 // The default pressure value

	if(O2_pp < safe_oxygen_min) // Too little oxygen
		if(!(NOBREATH in specflags) || (H.health <= config.health_threshold_crit))
			if(prob(20))
				spawn(0) H.emote("gasp")
			if(O2_pp > 0)
				var/ratio = safe_oxygen_min/O2_pp
				H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
				H.failed_last_breath = 1
				oxygen_used = breath.oxygen*ratio/6
			else
				H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
				H.failed_last_breath = 1
			H.throw_alert("oxy")
	else								// We're in safe limits
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		H.clear_alert("oxy")

	breath.oxygen -= oxygen_used
	breath.carbon_dioxide += oxygen_used

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(CO2_pp > safe_co2_max && !(NOBREATH in specflags))
		if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			H.co2overloadtime = world.time
		else if(world.time - H.co2overloadtime > 120)
			H.Paralyse(3)
			H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				H.adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			spawn(0) H.emote("cough")

	else
		H.co2overloadtime = 0

	if(Toxins_pp > safe_toxins_max && !(NOBREATH in specflags)) // Too much toxins
		var/ratio = (breath.toxins/safe_toxins_max) * 10
		//adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(H.reagents)
			H.reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.throw_alert("tox_in_air")
	else
		H.clear_alert("tox_in_air")

	if(breath.trace_gases.len && !(NOBREATH in specflags))	// If there's some other shit in the air lets deal with it here.
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
				H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
					H.sleeping = max(H.sleeping+2, 10)
			else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					spawn(0) H.emote(pick("giggle", "laugh"))

	handle_breath_temperature(breath, H)

	return 1

/datum/species/proc/handle_breath_temperature(datum/gas_mixture/breath, var/mob/living/carbon/human/H) // called by human/life, handles temperatures
	if(abs(310.15 - breath.temperature) > 50)

		if(!(mutations_list[COLDRES] in H.dna.mutations)) // COLD DAMAGE
			switch(breath.temperature)
				if(-INFINITY to 120)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head")
				if(120 to 200)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(200 to 260)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head")

		if(!(HEATRES in specflags)) // HEAT DAMAGE
			switch(breath.temperature)
				if(360 to 400)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head")
				if(400 to 1000)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(1000 to INFINITY)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head")

/datum/species/proc/handle_environment(datum/gas_mixture/environment, var/mob/living/carbon/human/H)
	if(!environment)
		return

	var/loc_temp = H.get_temperature(environment)

	//Body temperature is adjusted in two steps. First, your body tries to stabilize itself a bit.
	if(H.stat != DEAD)
		H.natural_bodytemperature_stabilization()

	//Then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < H.bodytemperature)
			//Place is colder than we are
			var/thermal_protection = H.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				H.bodytemperature += min((1-thermal_protection) * ((loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			//Place is hotter than we are
			var/thermal_protection = H.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				H.bodytemperature += min((1-thermal_protection) * ((loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !(HEATRES in specflags))
		//Body temperature is too hot.
		switch(H.bodytemperature)
			if(360 to 400)
				H.throw_alert("temp","hot",1)
				H.apply_damage(HEAT_DAMAGE_LEVEL_1*heatmod, BURN)
			if(400 to 460)
				H.throw_alert("temp","hot",2)
				H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
			if(460 to INFINITY)
				H.throw_alert("temp","hot",3)
				if(H.on_fire)
					H.apply_damage(HEAT_DAMAGE_LEVEL_3*heatmod, BURN)
				else
					H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !(mutations_list[COLDRES] in H.dna.mutations))
		if(!istype(H.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			switch(H.bodytemperature)
				if(200 to 260)
					H.throw_alert("temp","cold",1)
					H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod, BURN)
				if(120 to 200)
					H.throw_alert("temp","cold",2)
					H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod, BURN)
				if(-INFINITY to 120)
					H.throw_alert("temp","cold",3)
					H.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod, BURN)
		else
			H.clear_alert("temp")

	else
		H.clear_alert("temp")

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!(HEATRES in specflags))
				H.adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
				H.throw_alert("pressure","highpressure",2)
			else
				H.clear_alert("pressure")
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure","highpressure",1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.throw_alert("pressure","lowpressure",1)
		else
			if(H.dna.check_mutation(COLDRES) || (COLDRES in specflags))
				H.clear_alert("pressure")
			else
				H.adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				H.throw_alert("pressure","lowpressure",2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(var/mob/living/carbon/human/H)
	if((HEATRES in specflags) || (NOFIRE in specflags))
		return
	if(H.fire_stacks < 0)
		H.fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		H.fire_stacks = min(0, H.fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!H.on_fire)
		return
	var/datum/gas_mixture/G = H.loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob(H) //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(H)
	location.hotspot_expose(700, 50, 1)

/datum/species/proc/IgniteMob(var/mob/living/carbon/human/H)
	if(H.fire_stacks > 0 && !H.on_fire && !(HEATRES in specflags) && !(NOFIRE in specflags))
		H.on_fire = 1
		H.AddLuminosity(3)
		H.update_fire()

/datum/species/proc/ExtinguishMob(var/mob/living/carbon/human/H)
	if(H.on_fire)
		H.on_fire = 0
		H.fire_stacks = 0
		H.AddLuminosity(-3)
		H.update_fire()

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3

#undef COLD_DAMAGE_LEVEL_1
#undef COLD_DAMAGE_LEVEL_2
#undef COLD_DAMAGE_LEVEL_3

#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3

#undef TINT_IMPAIR
#undef TINT_BLIND
