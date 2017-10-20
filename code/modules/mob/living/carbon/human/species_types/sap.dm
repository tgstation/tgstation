//Posh plant-based humanoids with woody skin. Their mood and by extension nutrition is determined by how fancy they are.
/datum/species/sap
	name = "Sap"
	id = "sap"
	default_color = "59CE00"
	species_traits = list(MUTCOLORS, EYECOLOR, HAIRCOLOR, NO_UNDERWEAR)
	mutant_bodyparts = list("canopy")
	default_features = list("mcolor" = "59CE00", "canopy" = "Oakley Traditional")
	attack_verb = "smashed"
	attack_sound = "genhit"
	miss_sound = 'sound/weapons/slashmiss.ogg'
	say_mod = "demeans"
	speedmod = 1 //Though strong, saps are posh and insist on walking everywhere to maintain class
	brutemod = 0.9 //Woody skin means that blunt attacks and the like are less effective
	burnmod = 1.1
	heatmod = 1.5
	siemens_coeff = 0.4 //They're plants and are less vulnerable to shocks
	exotic_blood = "eznutriment"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN
	var/fanciness = 0 //Percentage of fanciness, determined by clothing worn. Below 50% fanciness you begin to starve, and above it you are nourished!
	var/list/fancy_clothing_info //Used so saps can track their fanciness in an alert


	var/static/list/despicable_clothing_typecache = typecacheof(list(\
	/obj/item/clothing/head/radiation, \
	/obj/item/clothing/suit/radiation, \
	/obj/item/clothing/suit/armor/bone, \
	/obj/item/clothing/head/wizard/fake, \
	/obj/item/clothing/gloves/boxing, \
	/obj/item/clothing/gloves/bracer, \
	/obj/item/clothing/head/helmet/justice, \
	/obj/item/clothing/head/helmet/skull, \
	/obj/item/clothing/head/cueball, \
	/obj/item/clothing/head/snowman, \
	/obj/item/clothing/head/chicken, \
	/obj/item/clothing/head/griffin, \
	/obj/item/clothing/head/bearpelt, \
	/obj/item/clothing/head/xenos, \
	/obj/item/clothing/head/fedora, \
	/obj/item/clothing/head/sombrero, \
	/obj/item/clothing/head/cone, \
	/obj/item/clothing/head/jester, \
	/obj/item/clothing/head/papersack/smiley, \
	/obj/item/clothing/head/lobsterhat, \
	/obj/item/clothing/under/rank/clown/sexy, \
	/obj/item/clothing/under/jabroni, \
	/obj/item/clothing/under/jester, \
	/obj/item/clothing/under/villain, \
	/obj/item/clothing/under/lobster, \
	/obj/item/clothing/under/shorts, \
	/obj/item/clothing/under/rank/clown, \
	)) //Each worn item reduces fanciness by 10%


	var/static/list/ugly_clothing_typecache = typecacheof(list(\
	/obj/item/clothing/head/helmet/space, \
	/obj/item/clothing/suit/space, \
	/obj/item/clothing/head/hardhat, \
	/obj/item/clothing/suit/fire, \
	/obj/item/clothing/head/bomb_hood, \
	/obj/item/clothing/suit/bomb_suit, \
	/obj/item/clothing/head/bio_hood, \
	/obj/item/clothing/suit/bio_suit, \
	/obj/item/clothing/suit/hazardvest, \
	/obj/item/clothing/suit/armor, \
	/obj/item/clothing/suit/wizrobe/fake, \
	/obj/item/clothing/glasses/meson, \
	/obj/item/clothing/glasses/material, \
	/obj/item/clothing/glasses/regular/jamjar, \
	/obj/item/clothing/glasses/godeye, \
	/obj/item/clothing/gloves, \
	/obj/item/clothing/head/helmet, \
	/obj/item/clothing/head/papersack, \
	/obj/item/clothing/under/color/grey, \
	/obj/item/clothing/under/rank/prisoner, \
	/obj/item/clothing/under/owl, \
	/obj/item/clothing/under/griffin, \
	/obj/item/clothing/under/schoolgirl, \
	/obj/item/clothing/under/kilt, \
	/obj/item/clothing/under/sexymime, \
	/obj/item/clothing/under/pants, \
	)) //Reduces fanciness by 5%


	var/static/list/fancy_clothing_typecache = typecacheof(list(\
	/obj/item/clothing/neck/cloak, \
	/obj/item/clothing/suit/apron, \
	/obj/item/clothing/suit/studentuni, \
	/obj/item/clothing/suit/toggle/chef, \
	/obj/item/clothing/suit/det_suit, \
	/obj/item/clothing/suit/toggle/lawyer, \
	/obj/item/clothing/suit/curator, \
	/obj/item/clothing/suit/armor/vest, \
	/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard, \
	/obj/item/clothing/suit/space/hardsuit/shielded/wizard, \
	/obj/item/clothing/glasses/meson/gar, \
	/obj/item/clothing/glasses/science, \
	/obj/item/clothing/glasses/sunglasses, \
	/obj/item/clothing/glasses/welding, \
	/obj/item/clothing/glasses/cold, \
	/obj/item/clothing/glasses/heat, \
	/obj/item/clothing/glasses/orange, \
	/obj/item/clothing/glasses/red, \
	/obj/item/clothing/gloves/color/captain, \
	/obj/item/clothing/gloves/botanic_leather, \
	/obj/item/clothing/head/beanie, \
	/obj/item/clothing/head/collectable, \
	/obj/item/clothing/head/helmet/roman, \
	/obj/item/clothing/head/hasturhood, \
	/obj/item/clothing/head/rice_hat, \
	/obj/item/clothing/head/nemes, \
	/obj/item/clothing/under/scratch, \
	/obj/item/clothing/under/rank/vice, \
	/obj/item/clothing/under/suit_jacket, \
	/obj/item/clothing/under/assistantformal, \
	/obj/item/clothing/under/plaid_skirt, \
	/obj/item/clothing/under/trek, \
	/obj/item/clothing/under/rank/bartender, \
	/obj/item/clothing/under/lawyer, \
	/obj/item/clothing/under/rank/curator, \
	/obj/item/clothing/under/rank/chief_engineer, \
	/obj/item/clothing/under/rank/research_director, \
	/obj/item/clothing/under/rank/chief_medical_officer, \
	/obj/item/clothing/under/rank/head_of_security, \
	/obj/item/clothing/under/rank/det, \
	)) //Each worn item increases fanciness by 5%


	var/static/list/lavish_clothing_typecache = typecacheof(list(\
	/obj/item/clothing/suit/captunic, \
	/obj/item/clothing/suit/armor/vest/capcarapace/alt, \
	/obj/item/clothing/head/wizard, \
	/obj/item/clothing/suit/wizrobe, \
	/obj/item/clothing/head/that, \
	/obj/item/clothing/head/crown, \
	/obj/item/clothing/under/waiter, \
	/obj/item/clothing/under/rank/centcom_officer, \
	/obj/item/clothing/under/suit_jacket/really_black, \
	/obj/item/clothing/under/captainparade, \
	/obj/item/clothing/under/hosparademale, \
	/obj/item/clothing/under/hosparadefem, \
	/obj/item/clothing/under/blacktango, \
	/obj/item/clothing/under/redeveninggown, \
	/obj/item/clothing/under/rank/captain, \
	)) //Increases fanciness by 10%


	var/static/list/chichi_clothing_typecache = typecacheof(list(\
	/obj/item/clothing/glasses/monocle, \
	/obj/item/clothing/glasses/thermal/monocle, \
	/obj/item/clothing/head/centhat, \
	/obj/item/clothing/head/bowler, \
	/obj/item/clothing/head/crown/fancy, \
	/obj/item/clothing/under/rank/centcom_commander, \
	/obj/item/clothing/under/syndicate, \
	)) //Increases fanciness by 15%


/datum/species/sap/random_name(gender,unique)
	if(unique)
		return random_unique_sap_name(gender)
	var/randname = sap_name(gender)
	return randname

/datum/species/sap/spec_life(mob/living/carbon/human/sap)
	calculate_fanciness(sap)
	var/light = 0
	if(isturf(sap.loc))
		var/turf/T = sap.loc
		light = T.get_lumcount()
		if(sap.nutrition < NUTRITION_LEVEL_WELL_FED && light >= SAP_NUTRITION_THRESHOLD)
			sap.nutrition += -0.5 + (0.01 * fanciness) //Past 50% fanciness is no hunger loss, and above it is hunger gain
			if(sap.nutrition <= NUTRITION_LEVEL_HUNGRY && prob(1))
				to_chat(sap, "<span class='warning'>[pick("These clothes really stick out...", "You feel ugly.", "Your outfit is doing dreadful things for your bark.", \
				"These clothes don't accentuate your canopy at all.", "You stick out like a green thumb. You should probably get some nicer clothing.")]<span>")

/datum/species/sap/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/sap)
	. = ..()
	switch(chem.id)
		if("plantbgone")
			sap.adjustToxLoss(4)
			sap.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		if("left4zednutriment")
			sap.adjustBruteLoss(-0.5)
			sap.adjustFireLoss(-0.5)
			sap.radiation += rand(1, 3)
			sap.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		if("robustharvestnutriment")
			sap.adjustBruteLoss(-1)
			sap.adjustFireLoss(-1)
			sap.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		if("water")
			sap.nutrition += 0.1 //Water is nourishing! Barely.
			sap.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)

/datum/species/sap/proc/calculate_fanciness(mob/living/carbon/human/sap)
	fancy_clothing_info = list()
	var/total_fanciness = 50
	var/item_fanciness
	var/obj/item/cycled_clothing
	if(sap.mind && sap.mind.special_role) //Antagonists don't need to worry about fanciness
		fancy_clothing_info[sap.mind.special_role] = 80
		total_fanciness = 80
	else
		var/list/slots = list(slot_wear_suit, slot_shoes, slot_head, slot_wear_mask, slot_gloves, slot_glasses, slot_w_uniform)
		for(var/slot in slots)
			item_fanciness = 0
			cycled_clothing = sap.get_item_by_slot(slot)
			if(cycled_clothing)
				if(is_type_in_typecache(cycled_clothing, chichi_clothing_typecache))
					item_fanciness = 15
				else if(is_type_in_typecache(cycled_clothing, lavish_clothing_typecache))
					item_fanciness = 10
				else if(is_type_in_typecache(cycled_clothing, fancy_clothing_typecache))
					item_fanciness = 5
				else if(is_type_in_typecache(cycled_clothing, ugly_clothing_typecache))
					item_fanciness = -5
				else if(is_type_in_typecache(cycled_clothing, despicable_clothing_typecache))
					item_fanciness = -10
				if(slot == slot_head) //Fancy hats are by far the most important to a sap's class.
					item_fanciness *= 2
				total_fanciness += item_fanciness
				if(item_fanciness)
					fancy_clothing_info[cycled_clothing.name] = item_fanciness
	total_fanciness = Clamp(total_fanciness, 0, 100)
	fanciness = total_fanciness
	return

/datum/species/sap/on_species_gain(mob/living/carbon/C)
	. = ..()
	C.throw_alert("fanciness", /obj/screen/alert/fanciness)

/datum/species/sap/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.clear_alert("fanciness")
