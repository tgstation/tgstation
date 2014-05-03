/datum/species/human
	name = "Human"
	id = "human"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	use_skintones = 1

	handle_chemicals(chem)
		if(chem == "mutationtoxin")
			owner << "\red Your flesh rapidly mutates!"
			owner.dna.species = new /datum/species/slime(owner)
			owner.regenerate_icons()

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

	// This is commented out since it was... kinda annoying.
	/*handle_speech(message)
		if(copytext(message, 1, 2) != "*")
			message = replacetext(message, "s", stutter("ss"))

		return message*/

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

	handle_chemicals(chem)
		if(chem == "plantbgone")
			owner.adjustToxLoss(2)

	on_hit(proj_type)
		switch(proj_type)
			if(/obj/item/projectile/energy/floramut)
				if(prob(15))
					owner.apply_effect((rand(30,80)),IRRADIATE)
					owner.Weaken(5)
					for (var/mob/V in viewers(owner))
						V.show_message("\red [owner] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
					if(prob(80))
						randmutb(owner)
						domutcheck(owner,null)
					else
						randmutg(owner)
						domutcheck(owner,null)
				else
					owner.adjustFireLoss(rand(5,15))
					owner.show_message("\red The radiation beam singes you!")
			if(/obj/item/projectile/energy/florayield)
				owner.nutrition = min(owner.nutrition+30, 500)
		return

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"

	spec_life()
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(owner.loc)) //else, there's considered to be no light
			var/turf/T = owner.loc
			var/area/A = T.loc
			if(A)
				if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
				else						light_amount =  5
			owner.nutrition += light_amount
			if(owner.nutrition > 500)
				owner.nutrition = 500
			if(light_amount > 2) //if there's enough light, heal
				owner.heal_overall_damage(1,1)
				owner.adjustToxLoss(-1)
				owner.adjustOxyLoss(-1)

		if(owner.nutrition < 200)
			owner.take_overall_damage(2,0)

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	sexes = 0
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)

	spec_life()
		var/light_amount = 0
		if(isturf(owner.loc))
			var/turf/T = owner.loc
			var/area/A = T.loc
			if(A)
				if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
				else						light_amount =  10
			if(light_amount > 2) //if there's enough light, start dying
				owner.take_overall_damage(1,1)
			else if (light_amount < 2) //heal in the dark
				owner.heal_overall_damage(1,1)

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

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(MUTCOLORS,EYECOLOR)

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

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"

	handle_chemicals(chem)
		if(chem == "pestkiller")
			owner.adjustToxLoss(2)

	handle_speech(message)
		if(copytext(message, 1, 2) != "*")
			message = replacetext(message, "z", stutter("zz"))

		return message

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	sexes = 0