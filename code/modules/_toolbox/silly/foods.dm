//******
//Fernet
//******

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	id = "fernet"
	description = "An incredibly bitter herbal liqueur used as a digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	boozepwr = 80
	taste_description = "utter bitterness"
	glass_name = "glass of fernet"
	glass_desc = "A glass of pure Fernet. Only an absolute madman would drink this alone." //Hi Kevum

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/carbon/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, 0)
	//M.adjust_nutrition(-5)
	M.nutrition = max(0, M.nutrition + -5)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	description = "A very popular and bittersweet digestif, ideal after a heavy meal. Best served on a sawed-off cola bottle as per tradition."
	color = "#390600" // rgb: 57, 6, 0
	boozepwr = 25
	//quality = DRINK_NICE
	taste_description = "sweet relief"
	glass_icon_file = 'icons/oldschool/food.dmi'
	glass_icon_state = "godlyblend"
	glass_name = "glass of fernet cola"
	glass_desc = "A sawed-off cola bottle filled with Fernet Cola. Nothing better after eating like a lardass."

/datum/reagent/consumable/ethanol/fernet_cola/on_mob_life(mob/living/carbon/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	//M.adjust_nutrition(- 3)
	M.nutrition = max(0, M.nutrition + -3)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli

	name = "Fanciulli"
	id = "fanciulli"
	description = "What if the Manhattan coctail ACTUALLY used a bitter herb liquour? Helps you sobers up." //also causes a bit of stamina damage to symbolize the afterdrink lazyness
	color = "#CA933F" // rgb: 202, 147, 63
	boozepwr = -10
	//quality = DRINK_NICE
	taste_description = "a sweet sobering mix"
	glass_icon_file = 'icons/oldschool/food.dmi'
	glass_icon_state = "fanciulli"
	glass_name = "glass of fanciulli"
	glass_desc = "A glass of Fanciulli. It's just Manhattan with Fernet."

/datum/reagent/consumable/ethanol/fanciulli/on_mob_life(mob/living/carbon/M)
	//M.adjust_nutrition(-5)
	M.nutrition = max(0, M.nutrition + -5)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli/on_mob_add(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(20)
		. = TRUE
	..()


/datum/reagent/consumable/ethanol/branca_menta
	name = "Branca Menta"
	id = "branca_menta"
	description = "A refreshing mixture of bitter Fernet with mint creme liquour."
	color = "#4B5746" // rgb: 75, 87, 70
	boozepwr = 35
	//quality = DRINK_GOOD
	taste_description = "a bitter freshness"
	glass_icon_file = 'icons/oldschool/food.dmi'
	glass_icon_state = "minted_fernet"
	glass_name = "glass of branca menta"
	glass_desc = "A glass of Branca Menta, perfect for those lazy and hot sunday summer afternoons." //Get lazy literally by drinking this


/datum/reagent/consumable/ethanol/branca_menta/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C)
	return ..()

/datum/reagent/consumable/ethanol/branca_menta/on_mob_add(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(35)
		. = TRUE
	..()

//****************
//Fernet Reactions
//****************

/datum/chemical_reaction/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	results = list("fernet_cola" = 2)
	required_reagents = list("fernet" = 1, "cola" = 1)


/datum/chemical_reaction/fanciulli
	name = "Fanciulli"
	id = "fanciulli"
	results = list("fanciulli" = 2)
	required_reagents = list("manhattan" = 1, "fernet" = 1)

/datum/chemical_reaction/branca_menta
	name = "Branca Menta"
	id = "branca_menta"
	results = list("branca_menta" = 3)
	required_reagents = list("fernet" = 1, "creme_de_menthe" = 1, "ice" = 1)

//*************
//Fernet bottle
//*************

/obj/item/reagent_containers/food/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "A bottle of pure Fernet Bronca, produced in Cordoba Space Station"
	icon = 'icons/oldschool/food.dmi'
	icon_state = "fernetbottle"
	list_reagents = list("fernet" = 100)

