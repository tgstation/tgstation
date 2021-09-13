//Compost
/datum/reagent/compost
	name = "compost"
	description = "A mixture of waste and rotten plant matter that nurtures plants and keeps them free of pests."
	reagent_state = SOLID
	color = "#44341F"
	taste_description = "rot"

//Compost when used on soil
/datum/reagent/compost/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustPests(-1)
		if(myseed && chems.has_reagent(src.type, 1))
			myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 0.1))
			myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.25))

// Compost when drunk..?
/datum/reagent/compost/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	. = TRUE
	..()

// Left-4-Zed Tribal edition
/datum/reagent/reactive_compost
	name = "reactive compost"
	description = "Compost mixed with mutjuice and daturatea. The resulting mixture is capable of drawing forth the inner potential of plants, at the expense of it's well being."
	reagent_state = "LIQUID"
	color = "#8181E9"
	taste_description = "sizzling rot"

// Making Left-4-Zed Tribal edition
/datum/chemical_reaction/reactive_compost
	results = list(/datum/reagent/reactive_compost = 3)
	required_reagents = list(/datum/reagent/compost = 1, /datum/reagent/uranium = 1, /datum/reagent/toxin/plasma = 1)
	mix_message = "The compost emits a noxious scent"

//If used on trays
/datum/reagent/reactive_compost/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		mytray.adjustHealth(-round(chems.get_reagent_amount(src.type) * 0.025))
		myseed.adjust_instability(round(chems.get_reagent_amount(src.type) * 0.3))

// Enduro Grow Tribal Edition
/datum/reagent/fortifying_compost
	name = "fortifying compost"
	description = "Compost mixed with tatojuice and yucca juice. The resulting mixture will fortify the plant from weed infestations, toxins and the toils of gardening."
	reagent_state = LIQUID
	color = "#AD462C"
	taste_description = "earthy rot"

// Making Enduro Grow Tribal edition
/datum/chemical_reaction/fortifying_compost
	results = list(/datum/reagent/fortifying_compost = 3)
	required_reagents = list(/datum/reagent/compost = 1, /datum/reagent/iron = 1, /datum/reagent/ash = 1)
	mix_message = "The compost emits an earthy armora"

//If used on trays
/datum/reagent/fortifying_compost/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_endurance(round(chems.get_reagent_amount (src.type) * 0.35))
		myseed.adjust_weed_chance(-round(chems.get_reagent_amount (src.type) * 0.2))
		mytray.adjustHealth(round(chems.get_reagent_amount (src.type) * 0.2))

// Saltpetre Tribal Edition
/datum/reagent/alacritous_compost
	name = "alacritous compost"
	description = "A strange mixture of compost, ashes and pungajuice. This potent mixture will hasten the plant's harvest while increasing the yield."
	reagent_state = "LIQUID"
	color = "#4CB529"
	taste_description = "cool, salty rot"

//Making Saltpetre Tribal Edition
/datum/chemical_reaction/alacritous_compost
	results = list(/datum/reagent/alacritous_compost = 3)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/silver = 1, /datum/reagent/compost = 1)
	mix_message = "The compost starts smelling like manure"

// If added to tray
/datum/reagent/alacritous_compost/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		var/acompost = chems.get_reagent_amount(src.type)
		if(myseed)
			myseed.adjust_production(-round(acompost/8)-prob(acompost%10))
			myseed.adjust_potency(round(acompost*1.2))
			myseed.adjust_yield(round(acompost*0.1))

// Stabilizing Compost
/datum/reagent/stabilizing_compost
	name = "stabilizing compost"
	description = "A soothing mixture of compost, milk and honey. The resulting mixture will stabilize a soil at the cost of potency."
	reagent_state = "LIQUID"
	color = "#B5ABAB"
	taste_description = "sweet rot"

//Making Stabilizing Compost
/datum/chemical_reaction/stabilizing_compost
	results = list(/datum/reagent/stabilizing_compost = 3)
	required_reagents = list(/datum/reagent/compost = 1, /datum/reagent/consumable/ethanol/manly_dorf = 1, /datum/reagent/silicon = 1)
	mix_message= "A sweet smell comes over the compost"

// If added to tray
/datum/reagent/stabilizing_compost/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		var/scompost =chems.get_reagent_amount(src.type)
		if(myseed)
			myseed.adjust_instability(-round(scompost*1.2))
			myseed.adjust_potency(-round(scompost*0.5))
