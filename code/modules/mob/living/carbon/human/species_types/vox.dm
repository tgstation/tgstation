/datum/species/vox
	// voxxy is avian humanoids who that can 
	//survive in low oxygen conditions and no good with lots of oxygen. 
	//Also immune to low pressure, and not get cold, yaya!
	name = "Vox"
	id = "vox"
	default_color = COLOR_GREEN
	species_traits = list(EYECOLOR, NOTRANSSTING, FRAGILEBONES, NO_UNDERWEAR, DIGITIGRADE) //todo, add ALT_UNDERWEAR
	exotic_skintones = list("light green","azure","brown","emerald", "light grey")
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AVIAN)
	inherent_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	mutant_bodyparts = list("tail_vox", "quills", "face_quills")
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_NECK, ITEM_SLOT_FEET) //voxxy gets their own masks
	fitted_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, 
						ITEM_SLOT_OCLOTHING, ITEM_SLOT_EYES, ITEM_SLOT_HEAD)
	//popularity power means voxxy gets special fitted sprites for basically everything, yaya!
	//Also it's about damn time someone made this kind of system to swap out sprites on a part
	//by part basis, a bunch of para races have differently shaped heads.
	mutanttail = /obj/item/organ/tail/vox
	mutanteyes = /obj/item/organ/eyes/vox
	mutantlungs = /obj/item/organ/lungs/vox
	mutant_brain = /obj/item/organ/brain/cortical_stack
	
	mutant_organs = list(/obj/item/organ/vox_brain) // it's a fake brain, 
	//long term plan is to make it so a vox that has their cortical stack removed or damaged 
	//to the point of brain death becomes a vegetable instad of dying, and to tie the 
	//consequences of brain damage like oxyloss and paralysis
	//to the vox's brain, while higher personality resides in the stack
	//so you can clone a vox, but need to recover their stack and install it into the new body
	//to bring them back. (does /tg/ cloning already work like this?)

	//outfit_important_for_life = /datum/outfit/vox //get this working later
	default_features = list("quills" = "None", "face_quills" = "None")
	hair_color = "0F0" //vox quill colors are controlled by hair color
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "claw"
	attack_piercing = IS_POINTED
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	//meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/vox //TODO
	//skinned_type = /obj/item/stack/sheet/animalhide/vox //TODO
	exotic_bloodtype = "V"
	disliked_food = GRAIN | DAIRY
	liked_food = RAW | MEAT
	inert_mutation = FIREBREATH
	//deathsound = 'sound/voice/vox/deathsound.ogg'

//datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	//H.grant_language(/datum/language/vox)
	
//datum/species/vox/random_name(gender,unique,lastname)
	//if(unique)
		//return random_unique_vox_name(gender)

	//var/randname = vox_name(gender)

	//if(lastname)
		//randname += " [lastname]"

	//return randname

//Voxxy wag in death, yaya
datum/species/vox/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

datum/species/vox/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

datum/species/vox/can_wag_tail(mob/living/carbon/human/H)
	return ("tail_vox" in mutant_bodyparts) || ("waggingtail_vox" in mutant_bodyparts)

datum/species/vox/is_wagging_tail(mob/living/carbon/human/H)
	return ("waggingtail_vox" in mutant_bodyparts)

datum/species/vox/start_wagging_tail(mob/living/carbon/human/H)
	if("tail_vox" in mutant_bodyparts)
		mutant_bodyparts -= "tail_vox"
		mutant_bodyparts |= "waggingtail_vox"
	H.update_body()

datum/species/vox/stop_wagging_tail(mob/living/carbon/human/H)
	if("waggingtail_vox" in mutant_bodyparts)
		mutant_bodyparts -= "waggingtail_vox"
		mutant_bodyparts |= "tail_vox"
	H.update_body()

