/datum/butchering_product
	var/obj/item/result
	//What item this is for

	var/verb_name
	//Something like "skin", don't name this "Butcher" please

	var/verb_gerund
	//Something like "skinning"

	var/amount = 1
	//How much results you can spawn before this datum disappears

/datum/butchering_product/proc/spawn_result(location)
	if(amount > 0)
		new result(location)
		amount--

/datum/butchering_product/skin
	result = /obj/item/stack/sheet/animalhide
	verb_name = "skin"
	verb_gerund = "skinning"

/datum/butchering_product/skin/cat
	result = /obj/item/stack/sheet/animalhide/cat

/datum/butchering_product/skin/corgi
	result = /obj/item/stack/sheet/animalhide/corgi

/datum/butchering_product/skin/lizard
	result = /obj/item/stack/sheet/animalhide/lizard

/datum/butchering_product/skin/goliath
	result = /obj/item/asteroid/goliath_hide

/datum/butchering_product/skin/bear
	result = /obj/item/clothing/head/bearpelt/real

/datum/butchering_product/spider_legs
	result = /obj/item/weapon/reagent_containers/food/snacks/spiderleg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
	amount = 8

var/global/list/animal_butchering_products = list(
	/mob/living/simple_animal/cat						= list(/datum/butchering_product/skin/cat),
	/mob/living/simple_animal/corgi						= list(/datum/butchering_product/skin/corgi),
	/mob/living/simple_animal/lizard					= list(/datum/butchering_product/skin/lizard),
	/mob/living/simple_animal/hostile/asteroid/goliath	= list(/datum/butchering_product/skin/goliath),
	/mob/living/simple_animal/hostile/giant_spider		= list(/datum/butchering_product/spider_legs),
	/mob/living/simple_animal/hostile/bear				= list(/datum/butchering_product/skin/bear)
)