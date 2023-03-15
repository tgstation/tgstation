//The following is all part of the botany chemical rebalance
//Move chems from this block if you modify them
/datum/reagent/vaccine
	random_unrestricted = FALSE //This does nothing without data, so don't synth it.

/datum/reagent/fuel/unholywater
	can_synth = FALSE //Far too powerful for botany

/datum/reagent/mutationtoxin/lizard
	can_synth = TRUE

/datum/reagent/mutationtoxin/fly
	can_synth = TRUE

/datum/reagent/mutationtoxin/moth
	can_synth = TRUE

/datum/reagent/mutationtoxin/apid
	can_synth = TRUE

/datum/reagent/mutationtoxin/skeleton
	can_synth = TRUE //Roundstart species

/datum/reagent/mutationtoxin/golem
	can_synth = TRUE //Non-dangerous chem

//Unrestricting base chemicals

/datum/reagent/water
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/oxygen
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/copper
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/nitrogen
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/hydrogen
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/potassium
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/mercury
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/sulfur
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/carbon
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/chlorine
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/fluorine
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/sodium
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/phosphorus
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/lithium
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/iron
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/gold
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/silver
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/uranium/radium
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/aluminium
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/silicon
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/fuel
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/stable_plasma
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/iodine
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/bromine
	can_synth = TRUE
	random_unrestricted = TRUE

//End of chem bases

/datum/reagent/snail
	can_synth = TRUE

/datum/reagent/smart_foaming_agent
	random_unrestricted = TRUE

//Virology chem start
//These have no real point

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	can_synth = FALSE

/datum/reagent/toxin/plasma/plasmavirusfood
	can_synth = FALSE

/datum/reagent/uranium/uraniumvirusfood
	can_synth = FALSE

/datum/reagent/uranium/uraniumvirusfood/stable
	can_synth = FALSE

/datum/reagent/consumable/laughter/laughtervirusfood
	can_synth = FALSE

//Virology chem end
//End of botany chem balance

/datum/reagent/flatulynt
	name = "Flatulynt"
	description = "A powerful food additive created by the Nanotrasen Organics Division, allows for easier passing of gas."
	color = "#9c7012"
	taste_description = "dietary fiber"
	metabolization_rate = 0.5
	overdose_threshold = 30


/datum/reagent/flatulynt/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!overdosed && ishuman(M) && prob(20))
		var/mob/living/carbon/human/effected = M
		effected.emote("fart")

/datum/reagent/flatulynt/overdose_start(mob/living/M)
	. = ..()
	metabolization_rate = 2

/datum/reagent/flatulynt/overdose_process(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/effected = M
		effected.emote("fart")

//Acetone Sticker Removal
/datum/reagent/acetone/reaction_mob(mob/living/M, method, reac_volume, show_message, touch_protection)
	. = ..()
	if(method == TOUCH || VAPOR)
		for(var/obj/item/stickable/dummy_holder/dummy_stickable in M.vis_contents)
			M.visible_message("<span class='notice'>[M]'s stickers slide off!</span>")
			for(var/obj/item/stickable/dropping in dummy_stickable.contents)
				dropping.forceMove(get_turf(M))
			M.vis_contents -= dummy_stickable


/datum/reagent/acetone/reaction_obj(obj/O, volume)
	. = ..()
	for(var/obj/item/stickable/dummy_holder/dummy_stickable in O.vis_contents)
		O.visible_message("<span class='notice'>The stickers slide right off of [O]!</span>")
		for(var/obj/item/stickable/dropping in dummy_stickable.contents)
			dropping.forceMove(get_turf(O))
		O.vis_contents -= dummy_stickable

/datum/reagent/acetone/reaction_turf(turf/T, volume)
	. = ..()
	for(var/obj/item/stickable/dummy_holder/dummy_stickable in T.vis_contents)
		T.visible_message("<span class='notice'>The stickers attached to [T] lose their grip and fall off!</span>")
		for(var/obj/item/stickable/dropping in dummy_stickable.contents)
			dropping.forceMove(get_turf(T))
		T.vis_contents -= dummy_stickable
