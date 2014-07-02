/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	use_skintones = 1

/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.dna.species = new /datum/species/slime()
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		return 1

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

/datum/species/lizard/handle_speech(message)
	// jesus christ why
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", stutter("ss"))

	return message

/datum/species/lizard/mutant
	punchmod = 2 //lizards have claws for extra damage
	heatmod = 0.9 //lizards are cold blooded and enjoy warmth.. a little bit
	brutemod = 0.95 //lizards have tough scales
	coldmod = 2 //lizards are cold blooded, so cold will affect them a lot faster and harder

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Plant"
	id = "plant"
	default_color = "59CE00"
	specflags = list(MUTCOLORS,EYECOLOR)
	attack_verb = "slice"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.apply_effect((rand(30,80)),IRRADIATE)
				H.Weaken(5)
				for (var/mob/V in viewers(H))
					V.show_message("<span class='danger'>[H] writhes in pain as \his vacuoles boil.</span>", 3, "<span class='danger'>You hear the crunching of leaves.</span>", 2)
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					randmutg(H)
					domutcheck(H,null)
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='danger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, 500)
	return

/datum/species/plant/mutant
	burnmod = 2 //THE FIRE, IT BURNS
	heatmod = 1.5 //THE POTENTIAL FOR FIRE, IT'S UNCOMFORTABLE
	armor = -2 //we're plants, very fragile
	punchmod = 1 //venosaur used vinewhip
	darksight = 0 //plants are horrid in the darkness
	ignored_by = list(/mob/living/simple_animal/hostile/tomato) //so our mutant pets don't eat us
	var/overdosing = 0

/datum/species/plant/mutant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	//sugar makes us strong
	//water makes us faster
	//fertilizer heals us
	//mutagen makes us fruit bombs
	//we can overdose on stuff
	var/maximum_dose = 75
	var/overdose_type = 0
	//HARDER
	if(chem.id == "eznutriment" || chem.id == "left4zednutriment" || chem.id == "robustharvestnutriment")
		//fertilizer is essentially doctor's delight, but weaker, for plantmen.
		if(H.getOxyLoss() && prob(80)) H.adjustOxyLoss(-1)
		if(H.getBruteLoss() && prob(80)) H.heal_organ_damage(1,0)
		if(H.getFireLoss() && prob(80)) H.heal_organ_damage(0,1)
		if(H.getToxLoss() && prob(80)) H.adjustToxLoss(-1)
		if(H.dizziness !=0) H.dizziness = max(0,H.dizziness-5)
		if(H.confused !=0) H.confused = max(0,H.confused - 1)
		overdose_type = 0
		if(prob(10))
			H.smell_message("<b>\red You smell something awful nearby..</b>")
	//FASTER
	if(chem.id == "water" || chem.id == "sodawater" || chem.id == "ice")
		H.status_flags |= GOTTAGOFAST
		overdose_type = 1
	//STRONGER
	if(chem.id == "sprinkles" || chem.id == "sugar")
		punchmod += 1 //grow in strength as we metabolise sugar
		overdose_type = 2
		spawn(REAGENTS_METABOLISM*2)
			punchmod = 1 //after some time, it wears off
	//..BETTER?
	if(chem.id == "mutagen")
		overdose_type = 3
		//mutagen does funny things to plants
		if(chem.volume > 25) //we require a significant amount to mutate our form
			var/obj/I
			switch(rand(1,100))
				if(1 to 25)
					//apple flashbombs (apples that explode lightly and blind nearby foes)
					I = new/obj/item/weapon/grenade/apple_bomb(get_turf(H))
				if(26 to 50)
					//banana-rangs ('regular' bananas that are suspiciously sharp)
					I = new/obj/item/weapon/reagent_containers/food/snacks/grown/banana/bananarang(get_turf(H))
				if(51 to 75)
					//mutant pods (tomatos that burst into hostile pets)
					I = new/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/mutant(get_turf(H))
				else
					//honk! spawn a regular garden item
					var/random = pick(/obj/item/weapon/reagent_containers/food/snacks/grown/poppy,
					/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
					/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
					/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
					I = new random(get_turf(H))
			H.put_in_any_hand_if_possible(I)
	//deal with overdoses
	if(chem.volume >= maximum_dose && !overdosing)
		spawn(1) //give it time in case we are eating pills or injecting
			overdose(overdose_type,chem.volume,H)
	..()

/datum/species/plant/mutant/proc/overdose(var/dose = 0,var/volume = 0, var/mob/living/carbon/human/H)
	overdosing = 1
	if(dose == 0)
		H.show_message("<span class='danger'>You feel so healthy!</span>")
		H.reagents.add_reagent("nutriment",volume*100) //git fat off of our delicious fertilizer
	if(dose == 1)
		H.show_message("<span class='danger'>You feel your insides vibrate!</span>")
		H.incorporeal_move = 2
	if(dose == 2)
		H.show_message("<span class='danger'>You feel your body contort and twist!</span>")
		H.mutations.Add(HULK)
		H.update_mutations()
	if(dose == 3)
		for (var/mob/V in viewers(H))
			V.show_message("<span class='danger'>[H] begin to split all over, plants pouring out of [H]!</span>",3, "<span class='danger'>You hear a sickening pop.</span>", 2)
		H.take_organ_damage(10,0)
		H.adjustOxyLoss(10)
		H.dizziness = H.dizziness + 15
		H.confused = H.confused + 3
		for(var/i = 0; i < volume/10; i++)
			spawn(0)
				var/random = pick(/obj/item/weapon/reagent_containers/food/snacks/grown/poppy,
					/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
					/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
					/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
					/obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
				var/I = new random(get_turf(H))
				walk_away(I,H.loc,rand(1,3))
	spawn(volume*rand(0.1,2)) // different chemical metabolism.. absorption.. science.. i don't know, just rand to give it some balance
		H.show_message("<span class='danger'>You feel normal again..</span>")
		H.incorporeal_move = 0
		H.mutations.Remove(HULK)
		H.update_mutations()
		overdosing = 0

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > 500)
			H.nutrition = 500
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < 200)
		H.take_overall_damage(2,0)

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	sexes = 0
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
			else						light_amount =  10
		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)

/datum/species/shadow/mutant
	name = "Shadowkin"
	speedmod = 1 //speedy ghouls
	coldmod = 0.85 //the dark is cold
	specflags = list(NOBREATH,COLDRES,NOBLOOD) //shadowkin are abominations of life, they neither breath nor bleed, and the cold barely effects them

/*
 SLIMEPEOPLE
*/

/datum/species/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/carbon/slime)

/datum/species/slime/mutant
	heatmod = 0.5
	coldmod = 0.5
	burnmod = 0.5
	brutemod = 0.5
	punchmod = -2 //slimes are pretty soft, not much they can do in melee
	nojumpsuit = 1 //just ram it on in them rolls
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,RADIMMUNE) //slimes are big jelly people who aren't really affected by much

/*
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(MUTCOLORS,EYECOLOR)

/datum/species/jelly/mutant
	//these are the same as above basically, but since they have a skeletal structure, have higher melee damage and less resistance
	heatmod = 0.75
	coldmod = 0.75
	burnmod = 0.75
	brutemod = 0.75
	nojumpsuit = 1 //just ram it on in them rolls
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,RADIMMUNE) //slimes are big jelly people who aren't really affected by much

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE)
	speedmod = 3
	armor = 55
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
	nojumpsuit = 1

/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"

/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "z", stutter("zz"))

	return message

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	sexes = 0