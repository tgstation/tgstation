/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None")
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
		H.faction |= "slime"
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
	mutant_organs = list(/obj/item/organ/internal/tongue/lizard)
	default_features = list("mcolor" = "0F0", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard

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
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD,VIRUSIMMUNE)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = "slimejelly"

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.reagents.get_reagent_amount(exotic_blood))
		H.reagents.add_reagent(exotic_blood, 5)
		H.adjustBruteLoss(5)
		H << "<span class='danger'>You feel empty!</span>"

	var/jelly_amount = H.reagents.get_reagent_amount(exotic_blood)

	if(jelly_amount < 100)
		if(H.nutrition >= NUTRITION_LEVEL_STARVING)
			H.reagents.add_reagent(exotic_blood, 0.5)
			H.nutrition -= 2.5
	if(jelly_amount < 50)
		if(prob(5))
			H << "<span class='danger'>You feel drained!</span>"
	if(jelly_amount < 10)
		H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == exotic_blood)
		return 1

/*
 SLIMEPEOPLE
*/

/datum/species/jelly/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD,VIRUSIMMUNE)
	say_mod = "says"
	eyes = "eyes"
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)
	burnmod = 0.5
	coldmod = 2
	heatmod = 0.5
	var/datum/action/innate/split_body/slime_split
	var/datum/action/innate/swap_body/callforward
	var/datum/action/innate/swap_body/callback

/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(callforward)
		callforward.Remove(C)
	if(callback)
		callback.Remove(C)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C)
	..()
	if(ishuman(C))
		slime_split = new
		slime_split.Grant(C)

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H)
	var/jelly_amount = H.reagents.get_reagent_amount(exotic_blood)
	if(jelly_amount >= 200)
		if(prob(5))
			H << "<span class='notice'>You feel very bloated!</span>"
	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.reagents.add_reagent(exotic_blood, 0.5)
		H.nutrition -= 2.5

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	H << "<span class='notice'>You focus intently on moving your body while standing perfectly still...</span>"
	H.notransform = 1
	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume >= 200)
			var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)
			spare.underwear = "Nude"
			H.dna.transfer_identity(spare, transfer_SE=1)
			H.dna.features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
			spare.real_name = spare.dna.real_name
			spare.name = spare.dna.real_name
			spare.updateappearance(mutcolor_update=1)
			spare.domutcheck()
			spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))
			S.volume = 80
			H.notransform = 0
			var/datum/species/jelly/slime/SS = H.dna.species
			SS.callforward = new
			SS.callforward.body = spare
			SS.callforward.Grant(H)
			SS.callback = new
			SS.callback.body = H
			SS.callback.Grant(spare)
			H.mind.transfer_to(spare)
			spare << "<span class='notice'>...and after a moment of disorentation, you're besides yourself!</span>"
			return

	H << "<span class='warning'>...but there is not enough of you to go around! You must attain more mass to split!</span>"
	H.notransform = 0

/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeswap"
	background_icon_state = "bg_alien"
	var/mob/living/carbon/human/body

/datum/action/innate/swap_body/Activate()
	if(!body || !istype(body) || !body.dna || !body.dna.species || body.dna.species.id != "slime" || body.stat == DEAD || qdeleted(body))
		owner << "<span class='warning'>Something is wrong, you cannot sense your other body!</span>"
		Remove(owner)
		return
	if(body.stat == UNCONSCIOUS)
		owner << "<span class='warning'>You sense this body has passed out for some reason. Best to stay away.</span>"
		return

	owner.mind.transfer_to(body)

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	speedmod = 2
	armor = 55
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)
	nojumpsuit = 1
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine

/datum/species/golem/plasma
	name = "Plasma Golem"
	id = "plasma"
	dangerous_existence = 1
	blacklisted = 1

/datum/species/golem/diamond
	name = "Diamond Golem"
	id = "diamond"
	blacklisted = 1
	dangerous_existence = 1

/datum/species/golem/gold
	name = "Gold Golem"
	id = "gold"
	blacklisted = 1
	dangerous_existence = 1

/datum/species/golem/silver
	name = "Silver Golem"
	id = "silver"
	blacklisted = 1
	dangerous_existence = 1

/datum/species/golem/uranium
	name = "Uranium Golem"
	id = "uranium"
	blacklisted = 1
	dangerous_existence = 1


/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	mutant_organs = list(/obj/item/organ/internal/tongue/fly)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1


/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor >0)
			var/turf/pos = get_turf(H)
			H.vomit()
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
	need_nutrition = 0
	blacklisted = 1
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	var/list/myspan = null

/datum/species/skeleton/New()
	..()
	myspan = list(pick(SPAN_SANS,SPAN_PAPYRUS)) //pick a span and stick with it for the round

/datum/species/skeleton/get_spans()
	return myspan


/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Brain-Munching Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	blacklisted = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE)
	mutant_organs = list(/obj/item/organ/internal/tongue/zombie)

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
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE)
	mutant_organs = list(/obj/item/organ/internal/tongue/abductor)
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
	specflags = list(NOBLOOD,RADIMMUNE,NOTRANSSTING,VIRUSIMMUNE)
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	blacklisted = 1 //See above
	need_nutrition = 0 //Hard to eat through a helmet
	burnmod = 2
	heatmod = 2
	speedmod = 1
	var/skin = 0

/datum/species/plasmaman/skin
	name = "Skinbone"
	skin = 1
	roundstart = 0

/datum/species/plasmaman/update_base_icon_state(mob/living/carbon/human/H)
	var/base = ..()
	if(base == id && !skin)
		base = "[base]_m"
	else
		base = "skinbone_m"
	return base

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
	return 0

/datum/species/plasmaman/qualifies_for_rank(rank, list/features)
	if(rank in security_positions)
		return 0
	if(rank == "Clown" || rank == "Mime")//No funny bussiness
		return 0
	return ..()




var/global/list/synth_flesh_disguises = list()

/datum/species/synth
	name = "Synth" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE) //all of these + whatever we inherit from the real species
	safe_oxygen_min = 0
	safe_toxins_min = 0
	safe_toxins_max = 0
	safe_co2_max = 0
	SA_para_min = 0
	SA_sleep_min = 0
	dangerous_existence = 1
	blacklisted = 1
	need_nutrition = 0 //beep boop robots do not need sustinance
	meat = null
	var/list/initial_specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE) //for getting these values back for assume_disguise()
	var/disguise_fail_health = 75 //When their health gets to this level their synthflesh partially falls off
	var/image/damaged_synth_flesh = null //an image to display when we're below disguise_fail_health
	var/datum/species/fake_species = null //a species to do most of our work for us, unless we're damaged


/datum/species/synth/military
	name = "Military Synth"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun
	disguise_fail_health = 50


/datum/species/synth/admin_set_species(mob/living/carbon/human/H, old_species)
	assume_disguise(old_species,H)


/datum/species/synth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "synthflesh")
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		handle_disguise(H) //and update flesh disguise
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1


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

	build_disguise(H)
	handle_disguise(H)


/datum/species/synth/proc/build_disguise(mob/living/carbon/human/H)
	var/base = ""
	if(fake_species)
		base = fake_species.update_base_icon_state(H)
		if(synth_flesh_disguises[base])
			damaged_synth_flesh = synth_flesh_disguises[base]
		else
			var/icon/base_flesh = icon(H.icon,"[base]_s")
			var/icon/damage = icon(H.icon,"synthflesh_damage")
			base_flesh.Blend(damage,ICON_MULTIPLY) //damage the skin
			damaged_synth_flesh = image(icon = base_flesh, layer= -SPECIES_LAYER)
			synth_flesh_disguises[base] = damaged_synth_flesh
	else
		damaged_synth_flesh = null


/datum/species/synth/proc/handle_disguise(mob/living/carbon/human/H)
	if(H && fake_species) // Obviously we only are disguise when we're... disguised.
		H.updatehealth()
		var/add_overlay = FALSE
		if(H.health < disguise_fail_health)
			//clear these out, they look weird
			H.underwear = ""
			H.undershirt = ""
			H.socks = ""
			add_overlay = TRUE
		else
			H.overlays -= damaged_synth_flesh
			if(H.overlays_standing[SPECIES_LAYER] == damaged_synth_flesh)
				H.overlays_standing[SPECIES_LAYER] = null

		H.regenerate_icons()
		if(add_overlay)
			H.remove_overlay(SPECIES_LAYER)

			//Copy and colour the image for coloured species
			var/image/I = image(layer = -SPECIES_LAYER)
			I.appearance = damaged_synth_flesh.appearance
			if(MUTCOLORS in specflags)
				I.color = "#[H.dna.features["mcolor"]]"
			damaged_synth_flesh = I

			H.overlays_standing[SPECIES_LAYER] = damaged_synth_flesh
			H.apply_overlay(SPECIES_LAYER)



/datum/species/synth/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	handle_disguise(H)


//Proc redirects:
//Passing procs onto the fake_species, to ensure we look as much like them as possible

/datum/species/synth/update_base_icon_state(mob/living/carbon/human/H)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			return fake_species.update_base_icon_state(H)
		else
			return ..()
	else
		. = ..()

/datum/species/synth/update_color(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.update_color(H, forced_colour)


/datum/species/synth/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_hair(H, forced_colour)


/datum/species/synth/handle_body(mob/living/carbon/human/H)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_body(H)


/datum/species/synth/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_body(H,forced_colour)


/datum/species/synth/get_spans()
	if(fake_species)
		return fake_species.get_spans()
	return list()


/datum/species/synth/handle_speech(message, mob/living/carbon/human/H)
	H.updatehealth()
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
	need_nutrition = 0//They don't need to eat
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
	specflags = list(RADIMMUNE,VIRUSIMMUNE,NOBLOOD,PIERCEIMMUNE,EYECOLOR)
	sexes = 0

