
/obj/item/reagent_containers/hypospray/medipen/methamphetamine/gamer
	name = "gamer energy medipen"
	desc = "Contains everything needed to empower your gamer instincts and keep your fuel reserves topped up for a full session."


/obj/item/food/croissant/gamer
	desc = "A delicious, buttery croissant. The ultimate sandwich."
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/medicine/omnizine = 6, /datum/reagent/love = 2)
	tastes = list("fluffy bread" = 1, "butter" = 1, "bits and bytes" = 2)

/obj/item/reagent_containers/cup/glass/mug/pepper_night_tea
	name = "pepper night tea"
	desc = "Perfect to shortly keep you warm on a cold winter night."
	icon_state = "tea"
	list_reagents = list(/datum/reagent/consumable/tea = 30, /datum/reagent/love = 5)

/obj/item/storage/box/papersack/gamer_lunch
	name = "gamer lunch bag"
	desc = "It smells like home."

/obj/item/storage/box/papersack/gamer_lunch/PopulateContents()
	new /obj/item/food/croissant/gamer(src)
	new /obj/item/food/croissant/gamer(src)
	new /obj/item/food/croissant/gamer(src)
	new /obj/item/reagent_containers/cup/glass/mug/pepper_night_tea(src)
	new /obj/item/reagent_containers/cup/glass/mug/pepper_night_tea(src)
	new /obj/item/reagent_containers/condiment/hotsauce(src)


/obj/item/reagent_containers/applicator/pill/gamer_pill/red
	name = "red pill"
	desc = "An oval-shaped maroon pill; it feels smooth to the touch."
	list_reagents = list(
		/datum/reagent/medicine/mannitol = 5,
		/datum/reagent/medicine/neurine = 2,
		/datum/reagent/inverse/lentslurri = 2, // oof ouch stomach cramps
	)
	icon_state = "pill4"

/obj/item/reagent_containers/applicator/pill/gamer_pill/blue
	name = "blue pill"
	desc = "An oval-shaped blue pill; it has a little ridge in the middle on one side."
	list_reagents = list(/datum/reagent/medicine/psicodine = 10, /datum/reagent/drug/happiness = 5)
	icon_state = "pill3"

/*
/obj/item/storage/pill_bottle/transgender_allegory
	name = "bottle of gamer pills"
	desc = "A bottle of pills issued by the Port Authority to ensure a bitrunner's mind stays sharp. \
		Despite the strange side effects many bitrunners thank these pills for having done wonders \
		for their mental health and body confidence."
	special_desc = "Side effects of long-term use may include: cessation/reversal of male-pattern scalp hair loss, \
		softening of skin/decreased oiliness and acne, redistribution of body fat in a feminine pattern, \
		decreased muscle mass/strength, thinning/slowed growth of facial/body hair, \
		breast development and nipple/areolar enlargement, and changes in mood, emotionality, and behavior."

/obj/item/storage/pill_bottle/transgender_allegory/PopulateContents()
	// Three red pills, two blue pills
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/applicator/pill/gamer_pill/red(src)
		new /obj/item/reagent_containers/applicator/pill/gamer_pill/blue(src)
	new /obj/item/reagent_containers/applicator/pill/gamer_pill/red(src)
*/
