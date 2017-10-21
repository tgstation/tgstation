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
	var/obj/item/clothing/cycled_clothing
	var/list/slots = list(slot_wear_suit, slot_shoes, slot_head, slot_wear_mask, slot_gloves, slot_glasses, slot_w_uniform)
	for(var/slot in slots)
		item_fanciness = 0
		cycled_clothing = sap.get_item_by_slot(slot)
		if(cycled_clothing)
			item_fanciness = cycled_clothing.fanciness
			total_fanciness += item_fanciness
			if(item_fanciness && istype(cycled_clothing))
				fancy_clothing_info[cycled_clothing.name] = item_fanciness > 0 ? "+[item_fanciness]" : item_fanciness
	if(sap.mind)
		if(sap.mind.special_role)
			total_fanciness += 20
			fancy_clothing_info[sap.mind.special_role] = "+20"
		if(sap.mind.assigned_role == "Clown")
			total_fanciness += 50 //Very ugly starting gear
			fancy_clothing_info["Clown shamelessness"] = "+50"
	total_fanciness = Clamp(total_fanciness, 0, 100)
	fanciness = total_fanciness
	return

/datum/species/sap/on_species_gain(mob/living/carbon/C)
	. = ..()
	C.throw_alert("fanciness", /obj/screen/alert/fanciness)

/datum/species/sap/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.clear_alert("fanciness")
