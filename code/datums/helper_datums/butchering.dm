//Actual butchering code is handled in living.dm

/datum/butchering_product
	var/obj/item/result
	//What item this is for

	var/verb_name
	//Something like "skin", don't name this "Butcher" please

	var/verb_gerund
	//Something like "skinning"

	var/amount = 1
	var/initial_amount = 1
	//How much results you can spawn before this datum disappears

	var/stored_in_organ
	//Example value: "head" or "arm". When an organ with the same type is cut off, this object will be transferred to it.

/datum/butchering_product/New()
	..()

	initial_amount = amount

/datum/butchering_product/proc/spawn_result(location, mob/parent)
	if(amount > 0)
		amount--
		return new result(location)

//This is added to the description of dead mobs! It's important to add a space at the end (like this: "It has been skinned. ").
/datum/butchering_product/proc/desc_modifier(mob/parent, mob/user) //User - the guy who is looking at Parent
	return

//==============Teeth============

/datum/butchering_product/teeth
	result = /obj/item/stack/teeth
	verb_name = "harvest teeth"
	verb_gerund = "removing teeth from"

	stored_in_organ = "head" //Cutting a "head" off will transfer teeth to the head object

/datum/butchering_product/teeth/desc_modifier(mob/parent, mob/user)
	if(amount == initial_amount) return
	if(!isliving(parent)) return

	var/mob/living/L = parent

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/organ/external/head = H.get_organ("head")
		if((head.status & ORGAN_DESTROYED) || !head)
			return //If he has no head, you can't see whether he has teeth or not!

		var/obj/item/clothing/mask/M = H.wear_mask
		if(istype(M) && is_slot_hidden(M,MOUTH))
			return //If his mouth is covered, we can't see his teeth

	var/pronoun = "Its"
	if(L.gender == MALE) pronoun = "His"
	if(L.gender == FEMALE) pronoun = "Her"

	if(amount == 0)
		return "[pronoun] teeth are gone. "
	else
		if(parent.Adjacent(user))
			return "[(initial_amount - amount)] of [lowertext(pronoun)] teeth are missing."
		else
			return "Some of [lowertext(pronoun)] teeth are missing. "

#define ALL_TEETH -1
/datum/butchering_product/teeth/spawn_result(location, mob/parent, drop_amount = ALL_TEETH)
	if(amount <= 0) return

	var/obj/item/stack/teeth/T = new(location)
	T.update_name(parent) //Change name of the teeth - from the default "teeth" to "corgi teeth", for example

	if(drop_amount == ALL_TEETH) //Drop ALL teeth
		T.amount = amount
		amount = 0
	else //Drop a random amount
		var/actual_amount = min(src.amount, drop_amount)
		T.amount = actual_amount
		src.amount -= actual_amount

	return T

/datum/butchering_product/teeth/few/New()
	amount = rand(4,8)
	..()

/datum/butchering_product/teeth/bunch/New()
	amount = rand(8,16)
	..()

/datum/butchering_product/teeth/lots/New()
	amount = rand(16,24)
	..()

/datum/butchering_product/teeth/human/New()
	amount = 32
	..()

#undef ALL_TEETH

//===============Skin=============

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

//--------------Spider legs-------

/datum/butchering_product/spider_legs
	result = /obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg
	verb_name = "remove legs from"
	verb_gerund = "removing legs from"
	amount = 8 //Amount of legs that all normal spiders have

/datum/butchering_product/spider_legs/desc_modifier()
	if(amount < 8)
		return "It only has [amount] [amount==1 ? "leg" : "legs"]. "

//=============Alien claws========

/datum/butchering_product/xeno_claw
	result = /obj/item/xenos_claw
	verb_name = "declaw"
	verb_gerund = "declawing"

/datum/butchering_product/xeno_claw/desc_modifier()
	if(!amount)
		return "Its claws have been cut off. "

#define TEETH_FEW		/datum/butchering_product/teeth/few		//4-8
#define TEETH_BUNCH		/datum/butchering_product/teeth/bunch	//8-16
#define TEETH_LOTS		/datum/butchering_product/teeth/lots	//16-24
#define TEETH_HUMAN		/datum/butchering_product/teeth/human	//32

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
	/mob/living/carbon/monkey							= list(/datum/butchering_product/skin/monkey, TEETH_FEW),

	/mob/living/carbon/human							= list(TEETH_HUMAN),
	/mob/living/carbon/human/skellington				= list(TEETH_HUMAN),
	/mob/living/carbon/human/tajaran					= list(TEETH_HUMAN),
	/mob/living/carbon/human/dummy						= list(TEETH_HUMAN),

)

#undef TEETH_FEW
#undef TEETH_BUNCH
#undef TEETH_LOTS
#undef TEETH_HUMAN
