//Actual butchering code is handled in living.dm

/datum/butchering_product
	var/obj/item/result
	//What item this is for

	var/verb_name
	//Something like "skin", don't name this "Butcher" please

	var/verb_gerund
	//Something like "skinning"

	var/amount = 1
	//How much results you can spawn before this datum disappears

/datum/butchering_product/proc/spawn_result(location, mob/parent)
	if(amount > 0)
		new result(location)
		amount--

//This is added to the description of dead mobs! It's important to add a space at the end (like this: "It has been skinned. ").
/datum/butchering_product/proc/desc_modifier(mob/parent)
	return

/datum/butchering_product/teeth
	result = /obj/item/stack/teeth
	verb_name = "harvest teeth"
	verb_gerund = "removing teeth from"

/datum/butchering_product/teeth/desc_modifier(mob/parent)
	if(amount == 0)
		if(ishuman(parent))
			var/mob/living/carbon/human/H = parent
			if(H.is_destroyed["head"]) then return //If he has no head, you can't see whether he has teeth or not!

		var/pronoun = "Its"
		if(parent.gender == MALE) pronoun = "His"
		if(parent.gender == FEMALE) pronoun = "Her"
		return "[pronoun] teeth are missing. "

/datum/butchering_product/teeth/spawn_result(location, mob/parent)
	if(amount <= 0) return

	var/obj/item/stack/teeth/T = new(location)
	if(parent)
		if(isliving(parent))
			var/mob/living/L = parent
			var/mob/parent_species = L.species_type
			var/parent_species_name = initial(parent_species.name)
			T.name = "[parent_species_name] teeth"
			T.singular_name = "[parent_species_name] tooth"
			T.animal_type = parent_species

	T.amount = amount
	amount = 0

/datum/butchering_product/teeth/few/New()
	amount = rand(1,4)

/datum/butchering_product/teeth/bunch/New()
	amount = rand(4,8)

/datum/butchering_product/teeth/lots/New()
	amount = rand(6,12)

/datum/butchering_product/skin
	result = /obj/item/stack/sheet/animalhide
	verb_name = "skin"
	verb_gerund = "skinning"

/datum/butchering_product/skin/desc_modifier(mob/parent)
	if(!amount)
		var/pronoun = "It"
		if(parent.gender == MALE) pronoun = "He"
		if(parent.gender == FEMALE) pronoun = "She"
		return "[pronoun] has been skinned. "

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

/datum/butchering_product/skin/xeno
	result = /obj/item/stack/sheet/xenochitin
	verb_name = "remove chitin"
	verb_gerund = "removing chitin"

/datum/butchering_product/skin/xeno/New()
	amount = rand(1,3)

/datum/butchering_product/skin/xeno/spawn_result(location)
	..()
	if(!amount) //If all chitin was removed
		new /obj/item/stack/sheet/animalhide/xeno(location)

/datum/butchering_product/skin/monkey
	result = /obj/item/stack/sheet/animalhide/monkey

//--------------

/datum/butchering_product/spider_legs
	result = /obj/item/weapon/reagent_containers/food/snacks/spiderleg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
	amount = 8 //Amount of legs that all normal spiders have

/datum/butchering_product/spider_legs/desc_modifier()
	if(amount < 8)
		return "It only has [amount] [amount==1 ? "leg" : "legs"]. "

/datum/butchering_product/xeno_claw
	result = /obj/item/xenos_claw
	verb_name = "declaw"
	verb_gerund = "declawing"

/datum/butchering_product/xeno_claw/desc_modifier()
	if(!amount)
		return "Its claws have been cut off. "

#define TEETH_FEW		/datum/butchering_product/teeth/few		//1-4
#define TEETH_BUNCH		/datum/butchering_product/teeth/bunch	//4-8
#define TEETH_LOTS		/datum/butchering_product/teeth/lots	//6-12

var/global/list/animal_butchering_products = list(
	/mob/living/simple_animal/cat						= list(/datum/butchering_product/skin/cat),
	/mob/living/simple_animal/corgi						= list(/datum/butchering_product/skin/corgi, TEETH_FEW),
	/mob/living/simple_animal/lizard					= list(/datum/butchering_product/skin/lizard),
	/mob/living/simple_animal/hostile/asteroid/goliath	= list(/datum/butchering_product/skin/goliath, TEETH_LOTS),
	/mob/living/simple_animal/hostile/giant_spider		= list(/datum/butchering_product/spider_legs),
	/mob/living/simple_animal/hostile/bear				= list(/datum/butchering_product/skin/bear, TEETH_LOTS),
	/mob/living/carbon/alien/humanoid					= list(/datum/butchering_product/xeno_claw, /datum/butchering_product/skin/xeno, TEETH_BUNCH),
	/mob/living/simple_animal/hostile/alien				= list(/datum/butchering_product/xeno_claw, /datum/butchering_product/skin/xeno, TEETH_BUNCH), //Same as the player-controlled aliens
	/mob/living/simple_animal/hostile/retaliate/cluwne	= list(TEETH_BUNCH), //honk
	/mob/living/simple_animal/hostile/creature			= list(TEETH_LOTS),
	/mob/living/carbon/monkey							= list(/datum/butchering_product/skin/monkey)
)

#undef TEETH_FEW
#undef TEETH_BUNCH
#undef TEETH_LOTS
