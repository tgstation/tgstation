/mob/living/carbon/monkey
	name = "monkey"
	voice_name = "monkey"
	verb_say = "chimpers"
	initial_language_holder = /datum/language_holder/monkey
	icon = 'icons/mob/monkey.dmi'
	icon_state = ""
	gender = NEUTER
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_NUDE
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	type_of_meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey
	gib_type = /obj/effect/decal/cleanable/blood/gibs
	unique_name = 1
	bodyparts = list(/obj/item/bodypart/chest/monkey, /obj/item/bodypart/head/monkey, /obj/item/bodypart/l_arm/monkey,
					 /obj/item/bodypart/r_arm/monkey, /obj/item/bodypart/r_leg/monkey, /obj/item/bodypart/l_leg/monkey)



/mob/living/carbon/monkey/Initialize()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	if(unique_name) //used to exclude pun pun
		gender = pick(MALE, FEMALE)
	real_name = name

	//initialize limbs
	create_bodyparts()

	create_internal_organs()

	. = ..()

	create_dna(src)
	dna.initialize_dna(random_blood_type())

/mob/living/carbon/monkey/create_internal_organs()
	internal_organs += new /obj/item/organ/appendix
	internal_organs += new /obj/item/organ/lungs
	internal_organs += new /obj/item/organ/heart
	internal_organs += new /obj/item/organ/brain
	internal_organs += new /obj/item/organ/tongue
	internal_organs += new /obj/item/organ/eyes
	internal_organs += new /obj/item/organ/ears
	..()

/mob/living/carbon/monkey/movement_delay()
	if(reagents)
		if(reagents.has_reagent("morphine"))
			return -1

		if(reagents.has_reagent("nuka_cola"))
			return -1

	. = ..()
	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		. += (health_deficiency / 25)

	if (bodytemperature < 283.222)
		. += (283.222 - bodytemperature) / 10 * 1.75
	return . + config.monkey_delay

/mob/living/carbon/monkey/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(client && mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)
	return


/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return


/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	return 0

/mob/living/carbon/monkey/reagent_check(datum/reagent/R) //can metabolize all reagents
	return 0

/mob/living/carbon/monkey/canBeHandcuffed()
	return 1

/mob/living/carbon/monkey/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgement_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Securitrons can't identify monkeys
	if( !(judgement_criteria & JUDGE_IGNOREMONKEYS) && (judgement_criteria & JUDGE_IDCHECK) )
		threatcount += 4

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(is_holding_item_of_type(/obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 4

		if(lasercolor == "r")
			if(is_holding_item_of_type(/obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 4

		return threatcount

	//Check for weapons
	if( (judgement_criteria & JUDGE_WEAPONCHECK) && weaponcheck )
		for(var/obj/item/I in held_items)
			if(weaponcheck.Invoke(I))
				threatcount += 4

	//mindshield implants imply trustworthyness
	if(isloyal())
		threatcount -= 1

	return threatcount

/mob/living/carbon/monkey/get_permeability_protection()
	var/protection = 0
	if(head)
		protection = 1 - head.permeability_coefficient
	if(wear_mask)
		protection = max(1 - wear_mask.permeability_coefficient, protection)
	protection = protection/7 //the rest of the body isn't covered.
	return protection

/mob/living/carbon/monkey/IsVocal()
	if(!getorganslot("lungs"))
		return 0
	return 1

/mob/living/carbon/monkey/can_use_guns(var/obj/item/weapon/gun/G)
	return 1

/mob/living/carbon/monkey/angry
	aggressive = TRUE

/mob/living/carbon/monkey/angry/Initialize()
	..()
	if(prob(10))
		var/obj/item/clothing/head/helmet/justice/escape/helmet = new(src)
		equip_to_slot_or_del(helmet,slot_head)
		helmet.attack_self(src) // todo encapsulate toggle
