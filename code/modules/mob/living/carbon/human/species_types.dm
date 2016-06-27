/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human


/datum/species/human/qualifies_for_rank(rank, list/features)
	if((!features["tail_human"] || features["tail_human"] == "None") && (!features["ears"] || features["ears"] == "None"))
		return 1	//Pure humans are always allowed in all roles.

	//Mutants are not allowed in most roles.
	if(rank in security_positions) //This list does not include lawyers.
		return 0
	if(rank in science_positions)
		return 0
	if(rank in medical_positions)
		return 0
	if(rank in engineering_positions)
		return 0
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 0
	return ..()


/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		return 1

//Curiosity killed the cat's wagging tail.
/datum/species/human/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	specflags = list(MUTCOLORS,EYECOLOR,LIPS)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings")
	mutant_organs = list(/obj/item/organ/tongue/lizard)
	default_features = list("mcolor" = "0F0", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

//I wag in death
/datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "lizard"
	specflags = list(MUTCOLORS,EYECOLOR,LIPS,NOBREATH,NOGUNS)
/*
 PODPEOPLE
*/

/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"
	default_color = "59CE00"
	specflags = list(MUTCOLORS,EYECOLOR)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant


/datum/species/pod/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(10,T.get_lumcount()) - 5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/pod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/pod/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.rad_act(rand(30,80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
				else
					randmutg(H)
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
	return
	

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	blacklisted = 1
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE,VIRUSIMMUNE)
	dangerous_existence = 1

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)

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
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD,VIRUSIMMUNE, TOXINLOVER)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = "slimejelly"
	var/datum/action/innate/regenerate_limbs/regenerate_limbs

/datum/species/jelly/on_species_loss(mob/living/carbon/C)
	if(regenerate_limbs)
		regenerate_limbs.Remove(C)
	..()

/datum/species/jelly/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.blood_volume)
		H.blood_volume += 5
		H.adjustBruteLoss(5)
		H << "<span class='danger'>You feel empty!</span>"

	if(H.blood_volume < BLOOD_VOLUME_NORMAL)
		if(H.nutrition >= NUTRITION_LEVEL_STARVING)
			H.blood_volume += 3
			H.nutrition -= 2.5
	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		if(prob(5))
			H << "<span class='danger'>You feel drained!</span>"
	if(H.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(H)
	H.update_action_buttons_icon()

/datum/species/jelly/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list("r_arm", "l_arm", "r_leg", "l_leg") - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!limbs_to_consume.len)
		H.losebreath++
		return
	if(H.get_num_legs()) //Legs go before arms
		limbs_to_consume -= list("r_arm", "l_arm")
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	H << "<span class='userdanger'>Your [consumed_limb] is drawn back into your body, unable to maintain its shape!</span>"
	qdel(consumed_limb)
	H.blood_volume += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		var/list/limbs_to_heal = H.get_missing_limbs()
		if(limbs_to_heal.len < 1)
			return 0
		if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			return 1
		return 0

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(limbs_to_heal.len < 1)
		H << "<span class='notice'>You feel intact enough as it is.</span>"
		return
	H << "<span class='notice'>You focus intently on your missing [limbs_to_heal.len >= 2 ? "limbs" : "limb"]...</span>"
	if(H.blood_volume >= 40*limbs_to_heal.len+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*limbs_to_heal.len
		H << "<span class='notice'>...and after a moment you finish reforming!</span>"
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		H << "<span class='warning'>...but there is not enough of you to fix everything! You must attain more mass to heal completely!</span>"
		return
	H << "<span class='warning'>...but there is not enough of you to go around! You must attain more mass to heal!</span>"

/*
 SLIMEPEOPLE
*/

/datum/species/jelly/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD,VIRUSIMMUNE, TOXINLOVER)
	say_mod = "says"
	eyes = "eyes"
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)
	burnmod = 0.5
	coldmod = 2
	heatmod = 0.5
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(swap_body)
		swap_body.Remove(C)
	bodies -= C // This means that the other bodies maintain a link
	// so if someone mindswapped into them, they'd still be shared.
	bodies = null
	C.faction -= "slime"
	C.blood_volume = min(C.blood_volume, BLOOD_VOLUME_NORMAL)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		slime_split = new
		slime_split.Grant(C)
		swap_body = new
		swap_body.Grant(C)

		if(!bodies || !bodies.len)
			bodies = list(C)
		else
			bodies |= C

	C.faction |= "slime"

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H)
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(prob(5))
			H << "<span class='notice'>You feel very bloated!</span>"
	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 3
		H.nutrition -= 2.5

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			return 1
		return 0

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return
	CHECK_DNA_AND_SPECIES(H)
	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	H.notransform = TRUE

	if(do_after(owner, delay=60, needhand=FALSE, target=owner, progress=TRUE))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			H << "<span class='warning'>...but there is not enough of you to \
				go around! You must attain more mass to split!</span>"
	else
		H << "<span class='warning'>...but fail to stand perfectly still!\
			</span>"

	H.notransform = FALSE

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner
	CHECK_DNA_AND_SPECIES(H)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)

	spare.underwear = "Nude"
	H.dna.transfer_identity(spare, transfer_SE=1)
	spare.dna.features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance(mutcolor_update=1)
	spare.domutcheck()
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))

	H.blood_volume = BLOOD_VOLUME_SAFE
	H.notransform = 0

	var/datum/species/jelly/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/jelly/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	H.mind.transfer_to(spare)
	spare.visible_message("<span class='warning'>[H] distorts as a new body \
		\"steps out\" of them.</span>",
		"<span class='notice'>...and after a moment of disorentation, \
		you're besides yourself!</span>")


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeswap"
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/Activate()
	if(!isslimeperson(owner))
		owner << "<span class='warning'>You are not a slimeperson.</span>"
		Remove(owner)
	else
		ui_interact(owner)

/datum/action/innate/swap_body/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = conscious_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "slime_swap_body", name, 400, 400, master_ui, state)
		ui.open()

/datum/action/innate/swap_body/ui_data(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return

	var/datum/species/jelly/slime/SS = H.dna.species

	var/list/data = list()
	data["bodies"] = list()
	for(var/b in SS.bodies)
		if(!b || qdeleted(b) || !isslimeperson(b))
			SS.bodies -= b
			continue
		var/mob/living/carbon/human/body = b

		var/list/L = list()
		// HTML colors need a # prefix
		L["htmlcolor"] = "#[body.dna.features["mcolor"]]"
		var/area/A = get_area(body)
		L["area"] = A.name
		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(UNCONSCIOUS)
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"
		var/current = body.mind
		var/is_conscious = (body.stat == CONSCIOUS)

		L["status"] = stat
		L["exoticblood"] = body.blood_volume
		L["name"] = body.name
		L["ref"] = "\ref[body]"
		L["is_current"] = current
		var/button
		if(current)
			button = "selected"
		else if(is_conscious)
			button = null
		else
			button = "disabled"

		L["swap_button_state"] = button
		L["swappable"] = !current && is_conscious

		data["bodies"] += list(L)

	return data

/datum/action/innate/swap_body/ui_act(action, params)
	if(..())
		return
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(owner))
		return
	var/datum/species/jelly/slime/SS = H.dna.species

	var/datum/mind/M
	for(var/mob/living/L in SS.bodies)
		if(L.mind && L.mind.active)
			M = L.mind
	if(!M)
		return
	if(!isslimeperson(M.current))
		return

	switch(action)
		if("swap")
			var/mob/living/carbon/human/selected = locate(params["ref"])
			if(!(selected in SS.bodies))
				return
			if(!selected || qdeleted(selected) || !isslimeperson(selected))
				SS.bodies -= selected
				return
			if(M.current == selected)
				return
			if(selected.stat != CONSCIOUS)
				return

			swap_to_dupe(M, selected)

/datum/action/innate/swap_body/proc/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	M.current.visible_message("<span class='notice'>[M.current] \
		stops moving and starts staring vacantly into space.</span>",
		"<span class='notice'>You stop moving this body...</span>")
	M.transfer_to(dupe)
	dupe.visible_message("<span class='notice'>[dupe] blinks and looks \
		around.</span>",
		"<span class='notice'>...and move this one instead.</span>")

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,RESISTTEMP,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS)
	speedmod = 2
	armor = 55
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)
	nojumpsuit = 1
	sexes = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	blacklisted = TRUE
	dangerous_existence = TRUE
	limbs_id = "golem"
	fixed_mut_color = "aaa"

/datum/species/golem/random
	name = "Random Golem"
	blacklisted = FALSE
	dangerous_existence = FALSE

/datum/species/golem/random/New()
	. = ..()
	var/list/golem_types = typesof(/datum/species/golem) - src.type
	var/datum/species/golem/golem_type = pick(golem_types)
	name = initial(golem_type.name)
	id = initial(golem_type.id)
	meat = initial(golem_type.meat)

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	fixed_mut_color = "4ed"

/datum/species/golem/plasma
	name = "Plasma Golem"
	id = "plasma"
	fixed_mut_color = "a3d"

/datum/species/golem/diamond
	name = "Diamond Golem"
	id = "diamond"
	fixed_mut_color = "0ff"

/datum/species/golem/gold
	name = "Gold Golem"
	id = "gold"
	fixed_mut_color = "ee0"

/datum/species/golem/silver
	name = "Silver Golem"
	id = "silver"
	fixed_mut_color = "ddd"

/datum/species/golem/uranium
	name = "Uranium Golem"
	id = "uranium"
	fixed_mut_color = "7f0"


/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	mutant_organs = list(/obj/item/organ/tongue/fly)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1


/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor > 0)
			var/turf/pos = get_turf(H)
			H.vomit(0, 0, 0, 1, 1)
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message("<span class='danger'>[H] vomits on the floor!</span>", \
						"<span class='userdanger'>You throw up on the floor!</span>")
	..()

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	blacklisted = 1
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,RESISTTEMP,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NOHUNGER,EASYDISMEMBER,EASYLIMBATTACHMENT)
	mutant_organs = list(/obj/item/organ/tongue/bone)

/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "High Functioning Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	blacklisted = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,RESISTTEMP,NOBLOOD,RADIMMUNE,NOZOMBIE,EASYDISMEMBER,EASYLIMBATTACHMENT, TOXINLOVER)
	mutant_organs = list(/obj/item/organ/tongue/zombie)
	speedmod = 2

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	no_equip = list(slot_wear_mask, slot_head)
	armor = 20 // 120 damage to KO a zombie, which kills it

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = "harm" // THE SUFFERING MUST FLOW
	if(C.InCritical())
		C.death()
		// Zombies only move around when not in crit, they instantly
		// succumb otherwise, and will standup again soon

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	// Drop items in hands
	// If you're a zombie lucky enough to have a NODROP item, then it stays.
	if(C.unEquip(C.l_hand))
		C.put_in_l_hand(new /obj/item/zombie_hand(C))
	if(C.unEquip(C.r_hand))
		C.put_in_r_hand(new /obj/item/zombie_hand(C))

	// Next, deal with the source of this zombie corruption
	var/obj/item/organ/body_egg/zombie_infection/infection
	infection = C.getorganslot("zombie_infection")
	if(!infection)
		infection = new(C)

/datum/species/zombie/infectious/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/obj/item/zombie_hand/left = C.l_hand
	var/obj/item/zombie_hand/right = C.r_hand
	// Deletion of the hands is handled in the items dropped()
	if(istype(left))
		C.unEquip(left, TRUE)
	if(istype(right))
		C.unEquip(right, TRUE)

// Your skin falls off
/datum/species/krokodil_addict
	name = "Human"
	id = "zombie"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutant_organs = list(/obj/item/organ/tongue/zombie)

/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE,NOGUNS)
	mutant_organs = list(/obj/item/organ/tongue/abductor)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/team = 1

var/global/image/plasmaman_on_fire = image("icon"='icons/mob/OnFire.dmi', "icon_state"="plasmaman")

/datum/species/plasmaman
	name = "Plasmaman"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	specflags = list(NOBLOOD,RADIMMUNE,NOTRANSSTING,VIRUSIMMUNE,NOHUNGER)
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	blacklisted = 1 //See above
	burnmod = 2
	heatmod = 2
	speedmod = 1

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()

	if(!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman))
		if(environment)
			var/total_moles = environment.total_moles()
			if(total_moles)
				if(environment.gases["o2"] && (environment.gases["o2"][MOLES] /total_moles) >= 0.01)
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	H.equipOutfit(O, visualsOnly)
	H.internal = H.r_hand
	H.update_internals_hud_icon(1)
	return 0

/datum/species/plasmaman/qualifies_for_rank(rank, list/features)
	if(rank in security_positions)
		return 0
	if(rank == "Clown" || rank == "Mime")//No funny bussiness
		return 0
	return ..()



/datum/species/synth
	name = "Synth" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE,NODISMEMBER,NOHUNGER) //all of these + whatever we inherit from the real species
	safe_oxygen_min = 0
	safe_toxins_min = 0
	safe_toxins_max = 0
	safe_co2_max = 0
	SA_para_min = 0
	SA_sleep_min = 0
	dangerous_existence = 1
	blacklisted = 1
	meat = null
	exotic_damage_overlay = "synth"
	limbs_id = "synth"
	var/list/initial_specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE,NODISMEMBER,NOHUNGER) //for getting these values back for assume_disguise()
	var/disguise_fail_health = 75 //When their health gets to this level their synthflesh partially falls off
	var/datum/species/fake_species = null //a species to do most of our work for us, unless we're damaged

/datum/species/synth/military
	name = "Military Synth"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun
	disguise_fail_health = 50

/datum/species/synth/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	assume_disguise(old_species, H)

/datum/species/synth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "synthflesh")
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1
	else
		return ..()


/datum/species/synth/proc/assume_disguise(datum/species/S, mob/living/carbon/human/H)
	if(S && !istype(S, type))
		name = S.name
		say_mod = S.say_mod
		sexes = S.sexes
		specflags = initial_specflags.Copy()
		specflags.Add(S.specflags)
		attack_verb = S.attack_verb
		attack_sound = S.attack_sound
		miss_sound = S.miss_sound
		meat = S.meat
		mutant_bodyparts = S.mutant_bodyparts.Copy()
		mutant_organs = S.mutant_organs.Copy()
		default_features = S.default_features.Copy()
		nojumpsuit = S.nojumpsuit
		no_equip = S.no_equip.Copy()
		limbs_id = S.id
		use_skintones = S.use_skintones
		fixed_mut_color = S.fixed_mut_color
		hair_color = S.hair_color
		fake_species = new S.type
	else
		name = initial(name)
		say_mod = initial(say_mod)
		specflags = initial_specflags.Copy()
		attack_verb = initial(attack_verb)
		attack_sound = initial(attack_sound)
		miss_sound = initial(miss_sound)
		mutant_bodyparts = list()
		default_features = list()
		nojumpsuit = initial(nojumpsuit)
		no_equip = list()
		qdel(fake_species)
		fake_species = null
		meat = initial(meat)
		limbs_id = "synth"
		use_skintones = 0
		sexes = 0
		fixed_mut_color = ""
		hair_color = ""


//Proc redirects:
//Passing procs onto the fake_species, to ensure we look as much like them as possible

/datum/species/synth/handle_hair(mob/living/carbon/human/H, forced_colour)
	if(fake_species)
		fake_species.handle_hair(H, forced_colour)
	else
		return ..()


/datum/species/synth/handle_body(mob/living/carbon/human/H)
	if(fake_species)
		fake_species.handle_body(H)
	else
		return ..()


/datum/species/synth/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	if(fake_species)
		fake_species.handle_body(H,forced_colour)
	else
		return ..()


/datum/species/synth/get_spans()
	if(fake_species)
		return fake_species.get_spans()
	return list()


/datum/species/synth/handle_speech(message, mob/living/carbon/human/H)
	if(H.health > disguise_fail_health)
		if(fake_species)
			return fake_species.handle_speech(message,H)
		else
			return ..()
	else
		return ..()


/*
SYNDICATE BLACK OPS
*/
//The hardcore return of the failed Deathsquad augmentation project
//Now it's own, wizard-tier, very robust, lone antag
/datum/species/corporate
	name = "Corporate Agent"
	id = "agent"
	hair_alpha = 0
	say_mod = "declares"
	speedmod = -2//Fast
	brutemod = 0.7//Tough against firearms
	burnmod = 0.65//Tough against lasers
	coldmod = 0
	heatmod = 0.5//it's a little tough to burn them to death not as hard though.
	punchdamagelow = 20
	punchdamagehigh = 30//they are inhumanly strong
	punchstunthreshold = 25
	attack_verb = "smash"
	attack_sound = "sound/weapons/resonator_blast.ogg"
	blacklisted = 1
	use_skintones = 0
	specflags = list(RADIMMUNE,VIRUSIMMUNE,NOBLOOD,PIERCEIMMUNE,EYECOLOR,NODISMEMBER,NOHUNGER)
	sexes = 0

/datum/species/angel
	name = "Angel"
	id = "angel"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "Angel")
	use_skintones = 1
	no_equip = list(slot_back)
	blacklisted = 1
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human

	var/datum/action/innate/flight/fly

/datum/species/angel/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	if(H.dna && H.dna.species &&((H.dna.features["wings"] != "Angel") && ("wings" in H.dna.species.mutant_bodyparts)))
		H.dna.features["wings"] = "Angel"
		H.update_body()
	if(ishuman(H)&& !fly)
		fly = new
		fly.Grant(H)


/datum/species/angel/on_species_loss(mob/living/carbon/human/H)
	if(fly)
		fly.Remove(H)
	if(FLYING in specflags)
		specflags -= FLYING
	ToggleFlight(H,0)
	if(H.dna && H.dna.species &&((H.dna.features["wings"] != "None") && ("wings" in H.dna.species.mutant_bodyparts)))
		H.dna.features["wings"] = "None"
		H.update_body()
	..()

/datum/species/angel/spec_life(mob/living/carbon/human/H)
	HandleFlight(H)

/datum/species/angel/proc/HandleFlight(mob/living/carbon/human/H)
	if(FLYING in specflags)
		if(!CanFly(H))
			ToggleFlight(H,0)
			H.float(0)
			return 0
		H.float(1)
		return 1
	else
		H.float(0)
		return 0

/datum/species/angel/proc/CanFly(mob/living/carbon/human/H)
	if(H.stat || H.stunned || H.weakened)
		return 0
	if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))	//Jumpsuits have tail holes, so it makes sense they have wing holes too
		H << "Your suit blocks your wings from extending!"
		return 0
	var/turf/T = get_turf(H)
	if(!T)
		return 0

	var/datum/gas_mixture/environment = T.return_air()
	if(environment && !(environment.return_pressure() > 30))
		H << "<span class='warning'>The atmosphere is too thin for you to fly!</span>"
		return 0
	else
		return 1

/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUNNED
	button_icon_state = "slimesplit"
	background_icon_state = "bg_alien"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/angel/A = H.dna.species
	if(A.CanFly(H))
		if(FLYING in A.specflags)
			H << "<span class='notice'>You settle gently back onto the ground...</span>"
			A.ToggleFlight(H,0)
			H.update_canmove()
		else
			H << "<span class='notice'>You beat your wings and begin to hover gently above the ground...</span>"
			H.resting = 0
			A.ToggleFlight(H,1)
			H.update_canmove()

/datum/species/angel/proc/flyslip(mob/living/carbon/human/H)
	var/obj/buckled_obj
	if(H.buckled)
		buckled_obj = H.buckled

	H << "<span class='notice'>Your wings spazz out and launch you!</span>"

	playsound(H.loc, 'sound/misc/slip.ogg', 50, 1, -3)

	H.accident(H.l_hand)
	H.accident(H.r_hand)

	var/olddir = H.dir

	H.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(H)
		step(buckled_obj, olddir)
	else
		for(var/i=1, i<5, i++)
			spawn (i)
				step(H, olddir)
				H.spin(1,1)
	return 1


/datum/species/angel/spec_stun(mob/living/carbon/human/H,amount)
	if(FLYING in specflags)
		ToggleFlight(H,0)
		flyslip(H)
	. = ..()

/datum/species/angel/negates_gravity()
	if(FLYING in specflags)
		return 1

/datum/species/angel/space_move()
	if(FLYING in specflags)
		return 1

/datum/species/angel/proc/ToggleFlight(mob/living/carbon/human/H,flight)
	if(flight && CanFly(H))
		stunmod = 2
		speedmod = -1
		specflags += FLYING
		override_float = 1
		H.pass_flags |= PASSTABLE
		H.OpenWings()
	else
		stunmod = 1
		speedmod = 0
		specflags -= FLYING
		override_float = 0
		H.pass_flags &= ~PASSTABLE
		H.CloseWings()
