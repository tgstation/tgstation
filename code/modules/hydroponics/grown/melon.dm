// Watermelon
/obj/item/seeds/watermelon
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/food/grown/watermelon
	lifespan = 50
	endurance = 40
	instability = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy, /obj/item/seeds/watermelon/barrel)
	reagents_add = list(/datum/reagent/water = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/seeds/watermelon/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/food/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	w_class = WEIGHT_CLASS_NORMAL
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/watermelonjuice = 0)
	wine_power = 40

/obj/item/food/grown/watermelon/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/watermelonslice, 5, 20)

/obj/item/food/grown/watermelon/make_dryable()
	return //No drying

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/food/grown/holymelon
	genes = list(/datum/plant_gene/trait/glow/yellow)
	mutatelist = list()
	reagents_add = list(/datum/reagent/water/holywater = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/glow/yellow

/obj/item/food/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	wine_power = 70 //Water to wine, baby.
	wine_flavor = "divinity"


/obj/item/food/grown/holymelon/make_dryable()
	return //No drying

/obj/item/food/grown/holymelon/Initialize()
	. = ..()
	var/uses = 1
	if(seed)
		uses = round(seed.potency / 20)
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, ITEM_SLOT_HANDS, uses, TRUE, CALLBACK(src, .proc/block_magic), CALLBACK(src, .proc/expire)) //deliver us from evil o melon god

/obj/item/food/grown/holymelon/proc/block_magic(mob/user, major)
	if(major)
		to_chat(user, "<span class='warning'>[src] hums slightly, and seems to decay a bit.</span>")

/obj/item/food/grown/holymelon/proc/expire(mob/user)
	to_chat(user, "<span class='warning'>[src] rapidly turns into ash!</span>")
	qdel(src)
	new /obj/effect/decal/cleanable/ash(drop_location())


/*
/obj/item/food/grown/holymelon/checkLiked(fraction, mob/M)    //chaplains sure love holymelons
	if(!ishuman(M))
		return
	if(last_check_time + 5 SECONDS >= world.time)
		return
	var/mob/living/carbon/human/holy_person = M
	if(!holy_person.mind?.holy_role || HAS_TRAIT(holy_person, TRAIT_AGEUSIA))
		return
	to_chat(holy_person,"<span class='notice'>Truly, a piece of heaven!</span>")
	M.adjust_disgust(-5 + -2.5 * fraction)
	SEND_SIGNAL(holy_person, COMSIG_ADD_MOOD_EVENT, "Divine_chew", /datum/mood_event/holy_consumption)
	last_check_time = world.time


*/

/// Barrel melon Seeds
/obj/item/seeds/watermelon/barrel
	name = "pack of barrelmelon seeds"
	desc = "These seeds grow into barrelmelon plants."
	icon_state = "seed-barrelmelon"
	species = "barrelmelon"
	plantname = "Barrel Melon Vines"
	product = /obj/item/food/grown/barrelmelon
	genes = list(/datum/plant_gene/trait/brewing)
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/ethanol/ale = 0.2, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/brewing

/// Barrel melon Fruit
/obj/item/food/grown/barrelmelon
	seed = /obj/item/seeds/watermelon/barrel
	name = "barrelmelon"
	desc = "The nutriments within this melon have been compressed and fermented into rich alcohol."
	icon_state = "barrelmelon"
	distill_reagent = /datum/reagent/medicine/antihol //You can call it a integer overflow.
