/datum/species/vox
	// Avian humanoids who can survive in low oxygen conditions, and are immune to low pressure
	name = "Vox"
	id = "vox"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR, NOTRANSSTING, FRAGILEBONES, NO_UNDERWEAR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AVIAN)
	inherent_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	mutant_bodyparts = list("tail_vox", "quills", "facequills")
	fitted_slots = list(ITEM_SLOT_MASK, ITEM_SLOT_EYES, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_EYES)
	//popularity power means voxxy gets special fitted sprites for basically everything, yaya!
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
	//

	//outfit_important_for_life = /datum/outfit/vox
	default_features = list("mcolor" = "0F0", "quills" = "None", "vox_facequills" = "None")
	hair_color = "0F0" //vox quill colors are controlled by hair color
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "claw"
	attack_piercing = IS_POINTED
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	//meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/vox
	//skinned_type = /obj/item/stack/sheet/animalhide/vox
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

//I wag in death
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

