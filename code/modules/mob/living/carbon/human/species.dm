// This code handles different species in the game.

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
	var/need_nutrition = 1  //Does it need to eat food on a regular basis?
	var/exotic_blood = ""	// If your race wants to bleed something other than bog standard blood, change this to reagent id.
	var/meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human //What the species drops on gibbing
	var/skinned_type = /obj/item/stack/sheet/animalhide/generic
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/blacklisted = 0 //Flag to exclude from green slime core species.
	var/dangerous_existence = null //A flag for transformation spells that tells them "hey if you turn a person into one of these without preperation, they'll probably die!"
	var/say_mod = "says"	// affects the speech message
	var/list/default_features = list() // Default mutant bodyparts for this species. Don't forget to set one for every mutant bodypart you allow this species to have.
	var/list/mutant_bodyparts = list() 	// Parts of the body that are diferent enough from the standard human model that they cause clipping with some equipment
	var/list/mutant_organs = list(/obj/item/organ/internal/tongue)		//Internal organs that are unique to this race.
	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9//damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/siemens_coeff = 1 //base electrocution coefficient

	var/invis_sight = SEE_INVISIBLE_LIVING
	var/darksight = 2

	// species flags. these can be found in flags.dm
	var/list/specflags = list()

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	var/mob/living/list/ignored_by = list()	// list of mobs that will ignore this species

	//Breathing!
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent

	//Breath damage
	var/oxy_breath_dam_min = 1
	var/oxy_breath_dam_max = 10
	var/co2_breath_dam_min = 1
	var/co2_breath_dam_max = 10
	var/tox_breath_dam_min = MIN_PLASMA_DAMAGE
	var/tox_breath_dam_max = MAX_PLASMA_DAMAGE

	///////////
	// PROCS //
	///////////



//Called when admins use the Set Species verb, let's species
//do some init stuff on the mob that got SS'd if necessary
/datum/species/proc/admin_set_species(mob/living/carbon/human/H, datum/species/old_species)
	return


/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(first_names_male)
	else
		randname = pick(first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(last_names)]"

	return randname


//Please override this locally if you want to define when what species qualifies for what rank if human authority is enforced.
/datum/species/proc/qualifies_for_rank(rank, list/features)
	if(rank in command_positions)
		return 0
	return 1

/datum/species/proc/on_species_gain(mob/living/carbon/C)
	// Drop the items the new species can't wear
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing)
			C.unEquip(thing)
	if(exotic_blood)
		C.reagents.add_reagent(exotic_blood, 80)
	for(var/path in mutant_organs)
		var/obj/item/organ/internal/I = new path()
		I.Insert(C)

/datum/species/proc/on_species_loss(mob/living/carbon/C)
	if(C.dna.species && C.dna.species.exotic_blood)
		C.reagents.del_reagent(C.dna.species.exotic_blood)

/datum/species/proc/update_base_icon_state(mob/living/carbon/human/H)
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

/datum/species/proc/update_color(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(SPECIES_LAYER)

	var/image/standing

	var/g = (H.gender == FEMALE) ? "f" : "m"

	if((MUTCOLORS in specflags) || use_skintones)
		var/image/spec_base
		var/icon_state_string = "[id]_"

		if(use_skintones)
			if(sexes)
				icon_state_string = "[H.skin_tone]_[g]_s"
			else
				icon_state_string = "[H.skin_tone]_s"
		else
			if(sexes)
				icon_state_string += "[g]_s"
			else
				icon_state_string += "_s"

		spec_base = image("icon" = 'icons/mob/human.dmi', "icon_state" = icon_state_string, "layer" = -SPECIES_LAYER)

		if(!forced_colour && !use_skintones)
			spec_base.color = "#[H.dna.features["mcolor"]]"
		else
			spec_base.color = forced_colour

		standing = spec_base

	if(standing)
		H.overlays_standing[SPECIES_LAYER]	+= standing

	H.apply_overlay(SPECIES_LAYER)

/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	if(H.disabilities & HUSK)
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()
	var/hair_hidden = 0
	var/facialhair_hidden = 0
	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = 1
	if(H.wear_mask)
		var/obj/item/clothing/mask/M = H.wear_mask
		if(M.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = 1

	if(H.facial_hair_style && (FACEHAIR in specflags) && !facialhair_hidden)
		S = facial_hair_styles_list[H.facial_hair_style]
		if(S)
			var/image/img_facial_s

			img_facial_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						img_facial_s.color = "#" + H.dna.features["mcolor"]
					else
						img_facial_s.color = "#" + hair_color
				else
					img_facial_s.color = "#" + H.facial_hair_color
			else
				img_facial_s.color = forced_colour

			img_facial_s.alpha = hair_alpha

			standing += img_facial_s

	//we check if our hat or helmet hides our hair.
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(H.wear_mask)
		var/obj/item/clothing/mask/M = H.wear_mask
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(!hair_hidden)
		if(!H.getorgan(/obj/item/organ/internal/brain)) //Applies the debrained overlay if there is no brain
			standing += image("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s", "layer" = -HAIR_LAYER)

		else if(H.hair_style && (HAIR in specflags))
			S = hair_styles_list[H.hair_style]
			if(S)
				var/image/img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

				img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							img_hair_s.color = "#" + H.dna.features["mcolor"]
						else
							img_hair_s.color = "#" + hair_color
					else
						img_hair_s.color = "#" + H.hair_color
				else
					img_hair_s.color = forced_colour
				img_hair_s.alpha = hair_alpha

				standing += img_hair_s

	if(standing.len)
		H.overlays_standing[HAIR_LAYER]	= standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
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
			if(H.dna.species.sexes && H.gender == FEMALE)
				standing	+=	wear_female_version("[U2.icon_state]_s", U2.icon, BODY_LAYER)
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

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts)
		return

	if("tail_lizard" in mutant_bodyparts)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_lizard"

	if("waggingtail_lizard" in mutant_bodyparts)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_lizard"
		else if ("tail_lizard" in mutant_bodyparts)
			bodyparts_to_add -= "waggingtail_lizard"

	if("tail_human" in mutant_bodyparts)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_human"


	if("waggingtail_human" in mutant_bodyparts)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_human"
		else if ("tail_human" in mutant_bodyparts)
			bodyparts_to_add -= "waggingtail_human"

	if("spines" in mutant_bodyparts)
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "spines"

	if("waggingspines" in mutant_bodyparts)
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingspines"
		else if ("tail" in mutant_bodyparts)
			bodyparts_to_add -= "waggingspines"

	if("snout" in mutant_bodyparts) //Take a closer look at that snout!
		if((H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE)) || (H.head && (H.head.flags_inv & HIDEFACE)))
			bodyparts_to_add -= "snout"

	if("frills" in mutant_bodyparts)
		if(!H.dna.features["frills"] || H.dna.features["frills"] == "None" || H.head && (H.head.flags_inv & HIDEEARS))
			bodyparts_to_add -= "frills"

	if("horns" in mutant_bodyparts)
		if(!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)))
			bodyparts_to_add -= "horns"

	if("ears" in mutant_bodyparts)
		if(!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)))
			bodyparts_to_add -= "ears"

	if(!bodyparts_to_add)
		return

	var/g = (H.gender == FEMALE) ? "f" : "m"

	var/image/I

	for(var/layer in relevent_layers)
		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/S
			switch(bodypart)
				if("tail_lizard")
					S = tails_list_lizard[H.dna.features["tail_lizard"]]
				if("waggingtail_lizard")
					S.= animated_tails_list_lizard[H.dna.features["tail_lizard"]]
				if("tail_human")
					S = tails_list_human[H.dna.features["tail_human"]]
				if("waggingtail_human")
					S.= animated_tails_list_human[H.dna.features["tail_human"]]
				if("spines")
					S = spines_list[H.dna.features["spines"]]
				if("waggingspines")
					S.= animated_spines_list[H.dna.features["spines"]]
				if("snout")
					S = snouts_list[H.dna.features["snout"]]
				if("frills")
					S = frills_list[H.dna.features["frills"]]
				if("horns")
					S = horns_list[H.dna.features["horns"]]
				if("ears")
					S = ears_list[H.dna.features["ears"]]
				if("body_markings")
					S = body_markings_list[H.dna.features["body_markings"]]

			if(!S || S.icon_state == "none")
				continue

			//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
			if(bodypart == "tail_lizard" || bodypart == "tail_human")
				bodypart = "tail"
			else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
				bodypart = "waggingtail"


			var/icon_string

			if(S.gender_specific)
				icon_string = "[g]_[bodypart]_[S.icon_state]_[layer]"
			else
				icon_string = "m_[bodypart]_[S.icon_state]_[layer]"

			I = image("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = icon_string, "layer" =- layer)

			if(!(H.disabilities & HUSK))
				if(!forced_colour)
					switch(S.color_src)
						if(MUTCOLORS)
							I.color = "#[H.dna.features["mcolor"]]"
						if(HAIR)
							if(hair_color == "mutcolor")
								I.color = "#[H.dna.features["mcolor"]]"
							else
								I.color = "#[H.hair_color]"
						if(FACEHAIR)
							I.color = "#[H.facial_hair_color]"
						if(EYECOLOR)
							I.color = "#[H.eye_color]"
				else
					I.color = forced_colour
			standing += I

			if(S.hasinner)
				if(S.gender_specific)
					icon_string = "[g]_[bodypart]inner_[S.icon_state]_[layer]"
				else
					icon_string = "m_[bodypart]inner_[S.icon_state]_[layer]"

				I = image("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = icon_string, "layer" =- layer)

				standing += I

		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

/datum/species/proc/spec_life(mob/living/carbon/human/H)
	return

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	return

/datum/species/proc/auto_equip(mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H)
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

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	return

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_speech(message, mob/living/carbon/human/H)
	return message

//return a list of spans or an empty list
/datum/species/proc/get_spans()
	return list()

////////
	//LIFE//
	////////

/datum/species/proc/handle_chemicals_in_body(mob/living/carbon/human/H)

	//The fucking FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(H.disabilities & FAT)
		if(H.overeatduration < 100)
			H << "<span class='notice'>You feel fit again!</span>"
			H.disabilities &= ~FAT
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
	else
		if(H.overeatduration > 500)
			H << "<span class='danger'>You suddenly feel blubbery!</span>"
			H.disabilities |= FAT
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (H.nutrition > 0 && H.stat != DEAD && H.dna.species.need_nutrition)
		var/hunger_rate = HUNGER_FACTOR
		if(H.satiety > 0)
			H.satiety--
		if(H.satiety < 0)
			H.satiety++
			if(prob(round(-H.satiety/40)))
				H.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		H.nutrition = max(0, H.nutrition - hunger_rate)


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

	switch(H.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			H.throw_alert("nutrition", /obj/screen/alert/fat)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			H.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("nutrition", /obj/screen/alert/hungry)
		else
			H.throw_alert("nutrition", /obj/screen/alert/starving)


/datum/species/proc/update_sight(mob/living/carbon/human/H)
	H.sight = initial(H.sight)
	H.see_in_dark = darksight
	H.see_invisible = invis_sight

	if(H.client.eye != H)
		var/atom/A = H.client.eye
		if(A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
			return

	for(var/obj/item/organ/internal/cyberimp/eyes/E in H.internal_organs)
		H.sight |= E.sight_flags
		if(E.dark_view)
			H.see_in_dark = E.dark_view
		if(E.see_invisible)
			H.see_invisible = min(H.see_invisible, E.see_invisible)

	if(H.glasses)
		var/obj/item/clothing/glasses/G = H.glasses
		H.sight |= G.vision_flags
		H.see_in_dark = max(G.darkness_view, H.see_in_dark)
		if(G.invis_override)
			H.see_invisible = G.invis_override
		else
			H.see_invisible = min(G.invis_view, H.see_invisible)

	for(var/X in H.dna.mutations)
		var/datum/mutation/M = X
		if(M.name == XRAY)
			H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
			H.see_in_dark = max(H.see_in_dark, 8)

	if(H.see_override)	//Override all
		H.see_invisible = H.see_override

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/H)

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
						H.emote("gasp")
						H.domutcheck()
		return 0
	return 1

////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/movement_delay(mob/living/carbon/human/H)
	. = 0

	if(H.status_flags & GOTTAGOFAST)
		. -= 1
	if(H.status_flags & GOTTAGOREALLYFAST)
		. -= 2

	if(!(H.status_flags & IGNORESLOWDOWN))
		if(!has_gravity(H))
			// If there's no gravity we have the sanic speed of jetpack.
			var/obj/item/weapon/tank/jetpack/J = H.back
			var/obj/item/clothing/suit/space/hardsuit/C = H.wear_suit
			if(!istype(J) && istype(C))
				J = C.jetpack

			if(istype(J) && J.allow_thrust(0.01, H))
				. -= 2
		else
			var/health_deficiency = (100 - H.health + H.staminaloss)
			if(health_deficiency >= 40)
				. += (health_deficiency / 25)

			var/hungry = (500 - H.nutrition) / 5 // So overeat would be 100 and default level would be 80
			if(hungry >= 70)
				. += hungry / 50

			if(H.wear_suit)
				. += H.wear_suit.slowdown
			if(H.shoes)
				. += H.shoes.slowdown
			if(H.back)
				. += H.back.slowdown
			if(H.l_hand && (H.l_hand.flags & HANDSLOW))
				. += H.l_hand.slowdown
			if(H.r_hand && (H.r_hand.flags & HANDSLOW))
				. += H.r_hand.slowdown

			if((H.disabilities & FAT))
				. += 1.5
			if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
				. += (BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

			. += speedmod

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H)
	if(!istype(M)) //sanity check for drones.
		return
	if((M != H) && M.a_intent != "help" && H.check_shields(0, M.name, attack_type = UNARMED_ATTACK))
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
				M.do_attack_animation(H)

				var/atk_verb = M.dna.species.attack_verb
				if(H.lying)
					atk_verb = "kick"

				var/damage = rand(M.dna.species.punchdamagelow, M.dna.species.punchdamagehigh)

				if(!damage)
					playsound(H.loc, M.dna.species.miss_sound, 25, 1, -1)
					H.visible_message("<span class='warning'>[M] has attempted to [atk_verb] [H]!</span>")
					return 0


				var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_selected))
				var/armor_block = H.run_armor_check(affecting, "melee")

				playsound(H.loc, M.dna.species.attack_sound, 25, 1, -1)

				H.visible_message("<span class='danger'>[M] has [atk_verb]ed [H]!</span>", \
								"<span class='userdanger'>[M] has [atk_verb]ed [H]!</span>")

				H.apply_damage(damage, BRUTE, affecting, armor_block)
				add_logs(M, H, "punched")
				if((H.stat != DEAD) && damage >= M.dna.species.punchstunthreshold)
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
				var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_selected))
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

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, def_zone, obj/item/organ/limb/affecting, hit_area, intent, obj/item/organ/limb/target_limb, target_area, mob/living/carbon/human/H)
	// Allows you to put in item-specific reactions based on species
	if(user != H)
		user.do_attack_animation(H)
		if(H.check_shields(I.force, "the [I.name]", I, MELEE_ATTACK, I.armour_penetration))
			return 0

	if(I.attack_verb && I.attack_verb.len)
		H.visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [H] in the [hit_area] with [I]!</span>", \
						"<span class='userdanger'>[user] has [pick(I.attack_verb)] [H] in the [hit_area] with [I]!</span>")
	else if(I.force)
		H.visible_message("<span class='danger'>[user] has attacked [H] in the [hit_area] with [I]!</span>", \
						"<span class='userdanger'>[user] has attacked [H] in the [hit_area] with [I]!</span>")
	else
		return 0

	var/armor_block = H.run_armor_check(affecting, "melee", "<span class='notice'>Your armor has protected your [hit_area].</span>", "<span class='notice'>Your armor has softened a hit to your [hit_area].</span>",I.armour_penetration)
	armor_block = min(90,armor_block) //cap damage reduction at 90%
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force, I.damtype, affecting, armor_block, H)

	var/bloody = 0
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.status == ORGAN_ORGANIC)
			I.add_blood(H)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				var/turf/location = H.loc
				if(istype(location, /turf))
					location.add_blood(H)
				if(ishuman(user))
					var/mob/living/carbon/human/M = user
					if(get_dist(M, H) <= 1)	//people with TK won't get smeared with blood
						if(M.wear_suit)
							M.wear_suit.add_blood(H)
							M.update_inv_wear_suit()	//updates mob overlays to show the new blood (no refresh)
						else if(M.w_uniform)
							M.w_uniform.add_blood(H)
							M.update_inv_w_uniform()	//updates mob overlays to show the new blood (no refresh)
						if (M.gloves)
							var/obj/item/clothing/gloves/G = M.gloves
							G.add_blood(H)
						else
							M.add_blood(H)
							M.update_inv_gloves()	//updates on-mob overlays for bloody hands and/or bloody gloves


		switch(hit_area)
			if("head")	//Harder to score a stun but if you do it lasts a bit longer
				if(H.stat == CONSCIOUS && armor_block < 50)
					if(prob(I.force))
						H.visible_message("<span class='danger'>[H] has been knocked unconscious!</span>", \
										"<span class='userdanger'>[H] has been knocked unconscious!</span>")
						H.apply_effect(20, PARALYZE, armor_block)
					if(prob(I.force + ((100 - H.health)/2)) && H != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(H.mind)

				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_blood(H)
						H.update_inv_head()
					if(H.glasses && prob(33))
						H.glasses.add_blood(H)
						H.update_inv_glasses()

			if("chest")	//Easier to score a stun but lasts less time
				if(H.stat == CONSCIOUS && I.force && prob(I.force + 10))
					H.visible_message("<span class='danger'>[H] has been knocked down!</span>", \
									"<span class='userdanger'>[H] has been knocked down!</span>")
					H.apply_effect(5, WEAKEN, armor_block)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_blood(H)
						H.update_inv_w_uniform()

		if(Iforce > 10 || Iforce >= 5 && prob(33))
			H.forcesay(hit_appends)	//forcesay checks stat already.
		return

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	blocked = (100-(blocked+armor))/100
	if(!damage || blocked <= 0)
		return 0

	var/obj/item/organ/limb/organ = null
	if(islimb(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = H.get_organ(check_zone(def_zone))
	if(!organ)
		return 0

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
			H.adjustToxLoss(damage)
		if(OXY)
			H.adjustOxyLoss(damage)
		if(CLONE)
			H.adjustCloneLoss(damage)
		if(STAMINA)
			H.adjustStaminaLoss(damage)
	return 1

/datum/species/proc/on_hit(obj/item/projectile/proj_type, mob/living/carbon/human/H)
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

/datum/species/proc/breathe(mob/living/carbon/human/H)
	return

/datum/species/proc/check_breath(datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	if((H.status_flags & GODMODE))
		return

	var/lungs = H.getorganslot("lungs")

	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(H.reagents.has_reagent("epinephrine") && lungs)
			return
		if(H.health >= config.health_threshold_crit)
			if(NOBREATH in specflags)
				return 1
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			if(!lungs)
				H.adjustOxyLoss(1)
			H.failed_last_breath = 1
		else
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			H.failed_last_breath = 1

		H.throw_alert("oxy", /obj/screen/alert/oxy)

		return 0

	var/gas_breathed = 0

	var/list/breath_gases = breath.gases

	breath.assert_gases("o2", "plasma", "co2", "n2o")

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath_gases["o2"][MOLES])
	var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases["plasma"][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(breath_gases["co2"][MOLES])


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max && !(NOBREATH in specflags))
			var/ratio = (breath_gases["o2"][MOLES]/safe_oxygen_max) * 10
			H.adjustOxyLoss(Clamp(ratio,oxy_breath_dam_min,oxy_breath_dam_max))
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
		else
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H,O2_pp,safe_oxygen_min,breath_gases["o2"][MOLES])
			H.throw_alert("oxy", /obj/screen/alert/oxy)
		else
			H.failed_last_breath = 0
			if(H.getOxyLoss())
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["o2"][MOLES]
			H.clear_alert("oxy")

	//Exhale
	breath_gases["o2"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max && !(NOBREATH in specflags))
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Paralyse(3)
				H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.adjustOxyLoss(8)
				H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H,CO2_pp, safe_co2_min,breath_gases["co2"][MOLES])
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["co2"][MOLES]
			H.clear_alert("not_enough_co2")

	//Exhale
	breath_gases["co2"][MOLES] -= gas_breathed
	breath_gases["o2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max && !(NOBREATH in specflags))
			var/ratio = (breath_gases["plasma"][MOLES]/safe_toxins_max) * 10
			if(H.reagents)
				H.reagents.add_reagent("plasma", Clamp(ratio, tox_breath_dam_min, tox_breath_dam_max))
			H.throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
		else
			H.clear_alert("tox_in_air")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min && !(NOBREATH in specflags))
			gas_breathed = handle_too_little_breath(H,Toxins_pp, safe_toxins_min, breath_gases["plasma"][MOLES])
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["plasma"][MOLES]
			H.clear_alert("not_enough_tox")

	//Exhale
	breath_gases["plasma"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TRACES --//

	if(breath && !(NOBREATH in specflags))	// If there's some other shit in the air lets deal with it here.
		var/SA_pp = breath.get_breath_partial_pressure(breath_gases["n2o"][MOLES])
		if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
			H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.sleeping+2, 10))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))
		handle_breath_temperature(breath, H)
		breath.garbage_collect()

	return 1


//Returns the amount of true_pp we breathed
/datum/species/proc/handle_too_little_breath(mob/living/carbon/human/H = null,breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return 0

	if(!(NOBREATH in specflags) || (H.health <= config.health_threshold_crit))
		if(prob(20))
			H.emote("gasp")
		if(breath_pp > 0)
			var/ratio = safe_breath_min/breath_pp
			H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
			H.failed_last_breath = 1
			. = true_pp*ratio/6
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			H.failed_last_breath = 1


/datum/species/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
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

/datum/species/proc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
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
				H.throw_alert("temp", /obj/screen/alert/hot, 1)
				H.apply_damage(HEAT_DAMAGE_LEVEL_1*heatmod, BURN)
			if(400 to 460)
				H.throw_alert("temp", /obj/screen/alert/hot, 2)
				H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
			if(460 to INFINITY)
				H.throw_alert("temp", /obj/screen/alert/hot, 3)
				if(H.on_fire)
					H.apply_damage(HEAT_DAMAGE_LEVEL_3*heatmod, BURN)
				else
					H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !(mutations_list[COLDRES] in H.dna.mutations))
		switch(H.bodytemperature)
			if(200 to 260)
				H.throw_alert("temp", /obj/screen/alert/cold, 1)
				H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod, BURN)
			if(120 to 200)
				H.throw_alert("temp", /obj/screen/alert/cold, 2)
				H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod, BURN)
			if(-INFINITY to 120)
				H.throw_alert("temp", /obj/screen/alert/cold, 3)
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
				H.throw_alert("pressure", /obj/screen/alert/highpressure, 2)
			else
				H.clear_alert("pressure")
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
		else
			if(H.dna.check_mutation(COLDRES) || (COLDRES in specflags))
				H.clear_alert("pressure")
			else
				H.adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				H.throw_alert("pressure", /obj/screen/alert/lowpressure, 2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H)
	if((HEATRES in specflags) || (NOFIRE in specflags))
		return 1

/datum/species/proc/IgniteMob(mob/living/carbon/human/H)
	if((HEATRES in specflags) || (NOFIRE in specflags))
		return 1

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/H)
	return

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

