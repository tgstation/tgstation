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
		hardset_dna(H, null, null, null, null, /datum/species/slime)
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
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
	mutant_bodyparts = list("tail", "snout")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard

/datum/species/lizard/handle_speech(message)
	// jesus christ why
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", "sss")

	return message

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Plant"
	id = "plant"
	default_color = "59CE00"
	specflags = list(MUTCOLORS,EYECOLOR)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.irradiate(rand(30,80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					randmutg(H)
					domutcheck(H,null)
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
	return

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"
	specflags = list(MUTCOLORS,EYECOLOR)

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
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
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	dangerous_existence = 1

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
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/slime/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
		if(S.volume < 50)
			if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/slime/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1
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
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
			else if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1
/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,HARDFEET)
	speedmod = 3
	armor = 55
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
	nojumpsuit = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem


/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine

/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	return replacetext(message, "z", stutter("zz"))

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,HARDFEET)
/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Brain-Munching Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE)

/datum/species/zombie/handle_speech(message)
	var/list/message_list = text2list(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return list2text(message_list, " ")

/datum/species/cosmetic_zombie
	name = "Human"
	id = "zombie"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie


/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/team = 1

/datum/species/abductor/handle_speech(message)
	//Hacks
	var/mob/living/carbon/human/user = usr
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna.species.id != "abductor")
			continue
		else
			var/datum/species/abductor/target_spec = H.dna.species
			if(target_spec.team == team)
				H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
				//return - technically you can add more aliens to a team
	for(var/mob/M in dead_mob_list)
		M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
	return ""


var/global/image/plasmaman_on_fire = image("icon"='icons/mob/OnFire.dmi', "icon_state"="plasmaman")

/datum/species/plasmaman
	name = "Plasbone"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBLOOD,RADIMMUNE)
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	var/skin = 0

/datum/species/plasmaman/skin
	name = "Skinbone"
	skin = 1

/datum/species/plasmaman/update_base_icon_state(var/mob/living/carbon/human/H)
	var/base = ..()
	if(base == id)
		base = "[base][skin]"
	return base

/datum/species/plasmaman/spec_life(var/mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()

	if(!istype(H.wear_suit, /obj/item/clothing/suit/space/eva/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/plasmaman))
		if(environment)
			var/total_moles = environment.total_moles()
			if(total_moles)
				if((environment.oxygen /total_moles) >= 0.01)
					if(!H.on_fire)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.adjust_fire_stacks(0.5)
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/suit/space/eva/plasmaman/P = H.wear_suit
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()

//Heal from plasma
/datum/species/plasmaman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plasma")
		H.adjustBruteLoss(-5)
		H.adjustFireLoss(-5)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1




