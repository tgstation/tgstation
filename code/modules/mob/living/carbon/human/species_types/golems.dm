/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = SPECIES_GOLEM
	species_traits = list(
		NOTRANSSTING,
		MUTCOLORS,
		NO_UNDERWEAR,
		NO_DNA_COPY,
	)
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	mutantheart = null
	mutantlungs = null
	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	mutant_organs = list(/obj/item/organ/internal/adamantine_resonator)
	speedmod = 2
	payday_modifier = 0.75
	armor = 55
	siemens_coeff = 0
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = 1
	meat = /obj/item/food/meat/slab/human/mutant/golem
	species_language_holder = /datum/language_holder/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	fixed_mut_color = "#aaaaaa"

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."
	var/random_eligible = TRUE //If false, the golem subtype can't be made through golem mutation toxin

	var/prefix = "Iron"
	var/list/special_names = list("Tarkus")
	var/human_surname_chance = 3
	var/special_name_chance = 5

/datum/species/golem/random_name(gender,unique,lastname)
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names?.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "gem",
		SPECIES_PERK_NAME = "Lithoid",
		SPECIES_PERK_DESC = "Lithoids are creatures made out of elements instead of \
			blood and flesh. Because of this, they're generally stronger, slower, \
			and mostly immune to environmental dangers and dangers to their health, \
			such as viruses and dismemberment.",
	))

	return to_add

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = SPECIES_GOLEM_ADAMANTINE
	meat = /obj/item/food/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/internal/adamantine_resonator, /obj/item/organ/internal/vocal_cords/adamantine)
	fixed_mut_color = "#44eedd"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems. Your unique mineral makeup makes you immune to most types of magic."
	prefix = "Adamantine"
	special_names = null
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/adamantine/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/adamantine/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	..()

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = SPECIES_GOLEM_PLASMA
	fixed_mut_color = "#aa33dd"
	meat = /obj/item/stack/ore/plasma
	//Can burn and takes damage from heat
	//no RESISTHEAT, NOFIRE
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	examine_limb_id = SPECIES_GOLEM
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, span_userdanger("You feel like you could blow up at any moment!"))
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, span_notice("You feel more stable."))
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(H, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 5, explosion_cause = src)
		if(H)
			H.investigate_log("has been gibbed as [H.p_their()] body explodes.", INVESTIGATE_DEATHS)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(0.5 * delta_time)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, span_notice("You ignite yourself!"))
		else
			to_chat(owner, span_warning("You try to ignite yourself, but fail!"))
		H.ignite_mob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = SPECIES_GOLEM_DIAMOND
	fixed_mut_color = "#00ffff"
	armor = 70 //up from 55
	meat = /obj/item/stack/ore/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back","Grill")
	examine_limb_id = SPECIES_GOLEM

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = SPECIES_GOLEM_GOLD
	fixed_mut_color = "#cccc00"
	speedmod = 1
	armor = 25 //down from 55
	meat = /obj/item/stack/ore/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."
	prefix = "Golden"
	special_names = list("Boy")
	examine_limb_id = SPECIES_GOLEM

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = SPECIES_GOLEM_SILVER
	fixed_mut_color = "#dddddd"
	meat = /obj/item/stack/ore/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks have a higher chance of stunning. Being made of silver, your body is immune to spirits of the damned and runic golems."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/silver/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/silver/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = SPECIES_GOLEM_PLASTEEL
	fixed_mut_color = "#bbbbbb"
	stunmod = 0.4
	speedmod = 4 //pretty fucking slow
	meat = /obj/item/stack/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching. You also magnetically attach to surfaces and so don't float without gravity and cannot have positions swapped with other beings."
	prefix = "Plasteel"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/plasteel,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/plasteel,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/plasteel,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/plasteel,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

/datum/species/golem/plasteel/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/golem/plasteel/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //THE WALL THE WALL THE WALL

/datum/species/golem/plasteel/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //NOTHING ON ERF CAN MAKE IT FALL
	..()

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = SPECIES_GOLEM_TITANIUM
	fixed_mut_color = "#ffffff"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are immune to ash storms, and slightly more resistant to burn damage."
	burnmod = 0.9
	prefix = "Titanium"
	special_names = list("Dioxide")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = SPECIES_GOLEM_PLASTITANIUM
	fixed_mut_color = "#888888"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	burnmod = 0.8
	prefix = "Plastitanium"
	special_names = null
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_LAVA_IMMUNE, SPECIES_TRAIT)
	ADD_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_LAVA_IMMUNE, SPECIES_TRAIT)
	REMOVE_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = SPECIES_GOLEM_ALIEN
	fixed_mut_color = "#333333"
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/internal/tongue/abductor
	speedmod = 1 //faster
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown
	examine_limb_id = SPECIES_GOLEM

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(brute = 1 * delta_time, burn = 1 * delta_time, required_bodytype = BODYTYPE_ORGANIC)
	H.adjustToxLoss(-1 * delta_time)
	H.adjustOxyLoss(-1 * delta_time)

//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = SPECIES_GOLEM_WOOD
	fixed_mut_color = "#9E704B"
	meat = /obj/item/stack/sheet/mineral/wood
	//Can burn and take damage from heat
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100
	inherent_factions = list("plants", "vines")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.adjust_nutrition(5 * light_amount * delta_time)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(brute = 0.5 * delta_time, burn = 0.5 * delta_time, required_bodytype = BODYTYPE_ORGANIC)
			H.adjustToxLoss(-0.5 * delta_time)
			H.adjustOxyLoss(-0.5 * delta_time)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(brute = 2, required_bodytype = BODYTYPE_ORGANIC)

/datum/species/golem/wood/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE

//Radioactive puncher, hits for burn but only as hard as human, slightly more durable against brute but less against everything else
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = SPECIES_GOLEM_URANIUM
	fixed_mut_color = "#77ff00"
	meat = /obj/item/stack/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, your very touch burns and irradiates organic lifeforms. You don't hit as hard as most golems, but you are far more durable against blunt force trauma."
	var/last_event = 0
	var/active = null
	armor = 40
	brutemod = 0.5
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")
	COOLDOWN_DECLARE(radiation_emission_cooldown)
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/uranium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/uranium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

/datum/species/golem/uranium/proc/radiation_emission(mob/living/carbon/human/H)
	if(!COOLDOWN_FINISHED(src, radiation_emission_cooldown))
		return
	else
		radiation_pulse(H, max_range = 1, threshold = RAD_VERY_LIGHT_INSULATION, chance = 3)
		COOLDOWN_START(src, radiation_emission_cooldown, 2 SECONDS)

/datum/species/golem/uranium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(COOLDOWN_FINISHED(src, radiation_emission_cooldown) && M != H && M.combat_mode)
		radiation_emission(H)

/datum/species/golem/uranium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(COOLDOWN_FINISHED(src, radiation_emission_cooldown) && user != H)
		radiation_emission(H)

/datum/species/golem/uranium/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(COOLDOWN_FINISHED(src, radiation_emission_cooldown))
		radiation_emission(H)

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = SPECIES_GOLEM_SAND
	fixed_mut_color = "#ffdc8f"
	meat = /obj/item/stack/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of sand!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.armor_flag == BULLET || P.armor_flag == BOMB)
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, TRUE)
			H.visible_message(span_danger("The [P.name] sinks harmlessly in [H]'s sandy body!"), \
			span_userdanger("The [P.name] sinks harmlessly in [H]'s sandy body!"))
			return BULLET_ACT_BLOCK
	return ..()

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = SPECIES_GOLEM_GLASS
	fixed_mut_color = "#5a96b4aa" //transparent body
	meat = /obj/item/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, SFX_SHATTER, 70, TRUE)
	H.visible_message(span_danger("[H] shatters!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.armor_flag == LASER || P.armor_flag == ENERGY)
			H.visible_message(span_danger("The [P.name] gets reflected by [H]'s glass skin!"), \
			span_userdanger("The [P.name] gets reflected by [H]'s glass skin!"))
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				// redirect the projectile
				P.firer = H
				P.preparePixelProjectile(locate(clamp(new_x, 1, world.maxx), clamp(new_y, 1, world.maxy), H.z), H)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	id = SPECIES_GOLEM_BLUESPACE
	fixed_mut_color = "#3333ff"
	meat = /obj/item/stack/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")
	examine_limb_id = SPECIES_GOLEM

	var/datum/action/cooldown/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] teleports!"), span_danger("You destabilize and teleport!"))
	new /obj/effect/particle_effect/sparks(get_turf(H))
	playsound(get_turf(H), SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	do_teleport(H, get_turf(H), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H && M.combat_mode)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/cooldown/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	cooldown_time = 17.5 SECONDS

/datum/action/cooldown/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message(span_warning("[H] starts vibrating!"), span_danger("You start charging your bluespace core..."))
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 1.5 SECONDS)
	return TRUE

/datum/action/cooldown/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	StartCooldown()
	H.visible_message(span_warning("[H] disappears in a shower of sparks!"), span_danger("You teleport!"))
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = SPECIES_GOLEM_BANANIUM
	fixed_mut_color = "#ffff00"
	inherent_traits = list(
		TRAIT_CLUMSY,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	mutanttongue = /obj/item/organ/internal/tongue/bananium
	meat = /obj/item/stack/ore/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you can barely even hurt people when punching them. Your skin also bleeds banana peels when damaged."
	prefix = "Bananium"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bananium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bananium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bananium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bananium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	/// Cooldown for producing honks
	COOLDOWN_DECLARE(honkooldown)
	/// Cooldown for producing bananas
	COOLDOWN_DECLARE(banana_cooldown)
	/// Time between possible banana productions
	var/banana_delay = 10 SECONDS
	/// Same as the uranium golem. I'm pretty sure this is vestigial.
	var/active = FALSE

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	COOLDOWN_START(src, honkooldown, 0)
	COOLDOWN_START(src, banana_cooldown, banana_delay)
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	var/obj/item/organ/internal/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		ADD_TRAIT(liver, TRAIT_COMEDY_METABOLISM, SPECIES_TRAIT)

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

	var/obj/item/organ/internal/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		REMOVE_TRAIT(liver, TRAIT_COMEDY_METABOLISM, SPECIES_TRAIT)

/datum/species/golem/bananium/random_name(gender,unique,lastname)
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[uppertext(clown_name)]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(COOLDOWN_FINISHED(src, banana_cooldown) && M != H && M.combat_mode)
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if((user != H) && COOLDOWN_FINISHED(src, banana_cooldown))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(COOLDOWN_FINISHED(src, banana_cooldown))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(!active && COOLDOWN_FINISHED(src, honkooldown))
		active = TRUE
		playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, TRUE)
		COOLDOWN_START(src, honkooldown, rand(2 SECONDS, 8 SECONDS))
		active = FALSE
	..()

/datum/species/golem/bananium/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, FALSE)

/datum/species/golem/bananium/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_CLOWN

/datum/species/golem/runic
	name = "Runic Golem"
	id = SPECIES_GOLEM_CULT
	sexes = FALSE
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder Goddess Nar'Sie."
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES) //no mutcolors
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NOBLOOD,
	)
	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	prefix = "Runic"
	special_names = null
	inherent_factions = list("cult")
	species_language_holder = /datum/language_holder/golem/runic
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cult,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cult,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cult,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cult,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cult,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cult,
	)

	/// A ref to our jaunt spell that we get on species gain.
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/golem/jaunt
	/// A ref to our gaze spell that we get on species gain.
	var/datum/action/cooldown/spell/pointed/abyssal_gaze/abyssal_gaze
	/// A ref to our dominate spell that we get on species gain.
	var/datum/action/cooldown/spell/pointed/dominate/dominate

/datum/species/golem/runic/random_name(gender,unique,lastname)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly","Coldsteel")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	// Create our species specific spells here.
	// Note we link them to the mob, not the mind,
	// so they're not moved around on mindswaps
	jaunt = new(grant_to)
	jaunt.StartCooldown()
	jaunt.Grant(grant_to)

	abyssal_gaze = new(grant_to)
	abyssal_gaze.StartCooldown()
	abyssal_gaze.Grant(grant_to)

	dominate = new(grant_to)
	dominate.StartCooldown()
	dominate.Grant(grant_to)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	// Aaand cleanup our species specific spells.
	// No free rides.
	QDEL_NULL(jaunt)
	QDEL_NULL(abyssal_gaze)
	QDEL_NULL(dominate)
	return ..()

/datum/species/golem/runic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(istype(chem, /datum/reagent/water/holywater))
		H.adjustFireLoss(4 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)

	if(chem.type == /datum/reagent/fuel/unholywater)
		H.adjustBruteLoss(-4 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.adjustFireLoss(-4 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)

/datum/species/golem/cloth
	name = "Cloth Golem"
	id = SPECIES_GOLEM_CLOTH
	sexes = FALSE
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable. \
	Being made of cloth, your body is immune to spirits of the damned and runic golems. You are faster than that of other golems, but weaker and less resilient."
	species_traits = list(NO_UNDERWEAR) //no mutcolors, and can burn
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	speedmod = 1 // not as heavy as stone
	prefix = "Cloth"
	special_names = null
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cloth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cloth,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cloth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cloth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cloth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cloth,
	)

/datum/species/golem/cloth/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

/datum/species/golem/cloth/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/golem/cloth/random_name(gender,unique,lastname)
	var/pharaoh_name = pick("Neferkare", "Hudjefa", "Khufu", "Mentuhotep", "Ahmose", "Amenhotep", "Thutmose", "Hatshepsut", "Tutankhamun", "Ramses", "Seti", \
	"Merenptah", "Djer", "Semerkhet", "Nynetjer", "Khafre", "Pepi", "Intef", "Ay") //yes, Ay was an actual pharaoh
	var/golem_name = "[pharaoh_name] \Roman[rand(1,99)]"
	return golem_name

/datum/species/golem/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message(span_danger("[H] burns into ash!"))
		H.dust(just_ash = TRUE)
		return

	H.visible_message(span_danger("[H] falls apart into a pile of bandages!"))
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/datum/species/golem/cloth/get_species_description()
	return "A wrapped up Mummy! They descend upon Space Station Thirteen every year to spook the crew! \"Return the slab!\""

/datum/species/golem/cloth/get_species_lore()
	return list(
		"Mummies are very self conscious. They're shaped weird, they walk slow, and worst of all, \
		they're considered the laziest halloween costume. But that's not even true, they say.",

		"Making a mummy costume may be easy, but making a CONVINCING mummy costume requires \
		things like proper fabric and purposeful staining to achieve the look. Which is FAR from easy. Gosh.",
	)

// Calls parent, as Golems have a species-wide perk we care about.
/datum/species/golem/cloth/create_pref_unique_perks()
	var/list/to_add = ..()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "recycle",
		SPECIES_PERK_NAME = "Reformation",
		SPECIES_PERK_DESC = "A boon quite similar to Ethereals, Mummies collapse into \
			a pile of bandages after they die. If left alone, they will reform back \
			into themselves. The bandages themselves are very vulnerable to fire.",
	))

	return to_add

// Override to add a perk elaborating on just how dangerous fire is.
/datum/species/golem/cloth/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "fire-alt",
		SPECIES_PERK_NAME = "Incredibly Flammable",
		SPECIES_PERK_DESC = "Mummies are made entirely of cloth, which makes them \
			very vulnerable to fire. They will not reform if they die while on \
			fire, and they will easily catch alight. If your bandages burn to ash, you're toast!",
	))

	return to_add

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	max_integrity = 50
	armor_type = /datum/armor/structure_cloth_pile
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 90 SECONDS
	var/mob/living/carbon/human/cloth_golem

/datum/armor/structure_cloth_pile
	melee = 90
	bullet = 90
	laser = 25
	energy = 80
	bomb = 50
	fire = -50
	acid = -50

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, span_notice("You start gathering your life energy, preparing to rise again..."))
		addtimer(CALLBACK(src, PROC_REF(revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message(span_danger("[src] burns into ash!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(cloth_golem.suiciding)
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	cloth_golem.revive(ADMIN_HEAL_ALL)
	sleep(2 SECONDS)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message(span_danger("[src] rises and reforms into [cloth_golem]!"),span_userdanger("You reform into yourself!"))
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.get_temperature())
		visible_message(span_danger("[src] bursts into flames!"))
		fire_act()

/datum/species/golem/plastic
	name = "Plastic Golem"
	id = SPECIES_GOLEM_PLASTIC
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VENTCRAWLER_NUDE,
	)
	prefix = "Plastic"
	special_names = list("Sheet", "Bag", "Bottle")
	fixed_mut_color = "fffa"
	info_text = "As a <span class='danger'>Plastic Golem</span>, you are capable of ventcrawling and passing through plastic flaps as long as you are naked."
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/bronze
	name = "Bronze Golem"
	id = SPECIES_GOLEM_BRONZE
	prefix = "Bronze"
	special_names = list("Bell")
	fixed_mut_color = "#cd7f32"
	info_text = "As a <span class='danger'>Bronze Golem</span>, you are very resistant to loud noises, and make loud noises if something hard hits you, however this ability does hurt your hearing."
	special_step_sounds = list('sound/machines/clockcult/integration_cog_install.ogg', 'sound/magic/clockwork/fellowship_armory.ogg' )
	mutantears = /obj/item/organ/internal/ears/bronze
	examine_limb_id = SPECIES_GOLEM
	var/last_gong_time = 0
	var/gong_cooldown = 150

/datum/species/golem/bronze/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(world.time > last_gong_time + gong_cooldown))
		return ..()
	if(P.armor_flag == BULLET || P.armor_flag == BOMB)
		gong(H)
		return ..()

/datum/species/golem/bronze/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_gong_time + gong_cooldown && M.combat_mode)
		gong(H)

/datum/species/golem/bronze/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/proc/gong(mob/living/carbon/human/H)
	last_gong_time = world.time
	for(var/mob/living/M in get_hearers_in_view(7,H))
		if(M.stat == DEAD) //F
			continue
		if(M == H)
			H.show_message(span_narsiesmall("You cringe with pain as your body rings around you!"), MSG_AUDIBLE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.soundbang_act(2, 0, 100, 1)
			H.adjust_jitter(14 SECONDS)
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message(span_narsiesmall("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.soundbang_act(1, 0, 30, 3)
				M.adjust_confusion(10 SECONDS)
				M.adjust_jitter(8 SECONDS)
				M.add_mood_event("gonged", /datum/mood_event/loud_gong)
			if(2 to 3)
				M.show_message(span_cult("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.soundbang_act(1, 0, 15, 2)
				M.adjust_jitter(6 SECONDS)
				M.add_mood_event("gonged", /datum/mood_event/loud_gong)
			else
				M.show_message(span_warning("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)


/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = "Cardboard Golem"
	id = SPECIES_GOLEM_CARDBOARD
	prefix = "Cardboard"
	special_names = list("Box")
	info_text = "As a <span class='danger'>Cardboard Golem</span>, you aren't very strong, but you are a bit quicker and can easily create more brethren by using cardboard on yourself. Cardboard makes a poor building material for tongues, so you'll have difficulty speaking."
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	mutanttongue = null
	fixed_mut_color = null
	armor = 25
	burnmod = 1.25
	heatmod = 2
	speedmod = 1.5
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cardboard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cardboard,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cardboard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cardboard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cardboard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cardboard,
	)
	var/last_creation = 0
	var/brother_creation_cooldown = 300

/datum/species/golem/cardboard/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	. = ..()
	if(user != H)
		return FALSE //forced reproduction is rape.
	if(istype(I, /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/C = I
		if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
			return
		if(C.amount < 10)
			to_chat(H, span_warning("You do not have enough cardboard!"))
			return FALSE
		to_chat(H, span_notice("You attempt to create a new cardboard brother."))
		if(do_after(user, 30, target = user))
			if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
				return
			if(!C.use(10))
				to_chat(H, span_warning("You do not have enough cardboard!"))
				return FALSE
			to_chat(H, span_notice("You create a new cardboard golem shell."))
			create_brother(H, H.loc)

/datum/species/golem/cardboard/proc/create_brother(mob/living/carbon/human/golem, atom/location)
	var/mob/living/master = golem.mind.enslaved_to?.resolve()
	if(master)
		new /obj/effect/mob_spawn/ghost_role/human/golem/servant(location, /datum/species/golem/cardboard, master)
	else
		new /obj/effect/mob_spawn/ghost_role/human/golem(location, /datum/species/golem/cardboard)

	last_creation = world.time

/datum/species/golem/leather
	name = "Leather Golem"
	id = SPECIES_GOLEM_LEATHER
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_STRONG_GRABBER,
	)
	prefix = "Leather"
	fixed_mut_color = "#624a2e"
	info_text = "As a <span class='danger'>Leather Golem</span>, you are flammable, but you can grab things with incredible ease, allowing all your grabs to start at a strong level."
	grab_sound = 'sound/weapons/whipgrab.ogg'
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/durathread
	name = "Durathread Golem"
	id = SPECIES_GOLEM_DURATHREAD
	prefix = "Durathread"
	special_names = list("Boll","Weave")
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES)
	fixed_mut_color = null
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	info_text = "As a <span class='danger'>Durathread Golem</span>, your strikes will cause those your targets to start choking, but your woven body won't withstand fire as well."
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/durathread,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/durathread,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/durathread,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/durathread,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/durathread,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/durathread,
	)

/datum/species/golem/durathread/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target.apply_status_effect(/datum/status_effect/strandling)

/datum/species/golem/bone
	name = "Bone Golem"
	id = SPECIES_GOLEM_BONE
	prefix = "Bone"
	special_names = list("Head", "Broth", "Fracture", "Rattler", "Appetit")
	liked_food = GROSS | MEAT | RAW | GORE
	toxic_food = null
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/internal/tongue/bone
	mutantstomach = /obj/item/organ/internal/stomach/bone
	sexes = FALSE
	fixed_mut_color = null
	species_traits = list(
		NO_UNDERWEAR,
		NOEYESPRITES,
	)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NOFIRE,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	species_language_holder = /datum/language_holder/golem/bone
	info_text = "As a <span class='danger'>Bone Golem</span>, You have a powerful spell that lets you chill your enemies with fear, and milk heals you! Just make sure to watch our for bone-hurting juice."
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bone,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bone,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/bone,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bone,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bone,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/bone,
	)
	var/datum/action/innate/bonechill/bonechill

/datum/species/golem/bone/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		bonechill = new
		bonechill.Grant(C)

/datum/species/golem/bone/on_species_loss(mob/living/carbon/C)
	if(bonechill)
		bonechill.Remove(C)
	..()

/datum/species/golem/bone/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.adjustStaminaLoss(7.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		H.adjustBruteLoss(0.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		if(DT_PROB(10, delta_time))
			switch(rand(1, 3))
				if(1)
					H.say(pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = /datum/reagent/toxin/bonehurtingjuice)
				if(2)
					H.manual_emote(pick("oofs silently.", "looks like [H.p_their()] bones hurt.", "grimaces, as though [H.p_their()] bones hurt."))
				if(3)
					to_chat(H, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(DT_PROB(2, delta_time) && iscarbon(H)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly.
				var/obj/item/bodypart/bp = H.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bp)
					playsound(H, get_sfx(SFX_DESECRATION), 50, TRUE, -1) //You just want to socialize
					H.visible_message(span_warning("[H] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					H.say("OOF!!", forced=/datum/reagent/toxin/bonehurtingjuice)
					bp.receive_damage(200, 0, 0) //But I don't think we should
				else
					to_chat(H, span_warning("Your missing arm aches from wherever you left it."))
					H.emote("sigh")
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * delta_time)
		return TRUE

/datum/action/innate/bonechill
	name = "Bone Chill"
	desc = "Rattle your bones and strike fear into your enemies!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	var/cooldown = 600
	var/last_use
	var/snas_chance = 3

/datum/action/innate/bonechill/Activate()
	if(world.time < last_use + cooldown)
		to_chat(owner, span_warning("You aren't ready yet to rattle your bones again!"))
		return
	owner.visible_message(span_warning("[owner] rattles [owner.p_their()] bones harrowingly."), span_notice("You rattle your bones"))
	last_use = world.time
	if(prob(snas_chance))
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES2.ogg', 100)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/mutable_appearance/badtime = mutable_appearance('icons/mob/species/human/bodyparts.dmi', "b_golem_eyes", -FIRE_LAYER-0.5)
			badtime.appearance_flags = RESET_COLOR
			H.overlays_standing[FIRE_LAYER+0.5] = badtime
			H.apply_overlay(FIRE_LAYER+0.5)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/, remove_overlay), FIRE_LAYER+0.5), 25)
	else
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES.ogg', 100)
	for(var/mob/living/L in orange(7, get_turf(owner)))
		if((L.mob_biotypes & MOB_UNDEAD) || isgolem(L) || HAS_TRAIT(L, TRAIT_RESISTCOLD))
			continue //Do not affect our brothers

		to_chat(L, span_cultlarge("A spine-chilling sound chills you to the bone!"))
		L.apply_status_effect(/datum/status_effect/bonechill)
		L.add_mood_event("spooked", /datum/mood_event/spooked)

/datum/species/golem/snow
	name = "Snow Golem"
	id = SPECIES_GOLEM_SNOW
	fixed_mut_color = null //custom sprites
	armor = 45 //down from 55
	burnmod = 3 //melts easily
	info_text = "As a <span class='danger'>Snow Golem</span>, you are extremely vulnerable to burn damage, but you can generate snowballs and shoot cryokinetic beams. You will also turn to snow when dying, preventing any form of recovery."
	prefix = "Snow"
	special_names = list("Flake", "Blizzard", "Storm")
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES) //no mutcolors, no eye sprites
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/snow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/snow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/snow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/snow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/snow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/snow,
	)

	/// A ref to our "throw snowball" spell we get on species gain.
	var/datum/action/cooldown/spell/conjure_item/snowball/snowball
	/// A ref to our cryobeam spell we get on species gain.
	var/datum/action/cooldown/spell/pointed/projectile/cryo/cryo

/datum/species/golem/snow/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of snow!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/sheet/mineral/snow(get_turf(H))
	new /obj/item/food/grown/carrot(get_turf(H))
	qdel(H)

/datum/species/golem/snow/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_SNOWSTORM_IMMUNE, SPECIES_TRAIT)

	snowball = new(grant_to)
	snowball.StartCooldown()
	snowball.Grant(grant_to)

	cryo = new(grant_to)
	cryo.StartCooldown()
	cryo.Grant(grant_to)

/datum/species/golem/snow/on_species_loss(mob/living/carbon/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_SNOWSTORM_IMMUNE, SPECIES_TRAIT)
	QDEL_NULL(snowball)
	QDEL_NULL(cryo)
	return ..()

/datum/species/golem/mhydrogen //Effectively most other metal-based golem types rolled into one - immune to all weather, lava, flashes, and magic, while being just as hardened as diamond golems.
	name = "Metallic Hydrogen Golem"
	id = SPECIES_GOLEM_HYDROGEN
	fixed_mut_color = "#535469"
	armor = 70 //equal to a diamond golem
	info_text = "As a <span class='danger'>Metallic Hydrogen Golem</span>, you were forged in the highest pressures and the highest heats. Your unique material makeup makes you immune to magic and most environmental damage, while helping you resist most other attacks."
	prefix = "Metallic Hydrogen"
	special_names = list("Pressure","Crush")
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WEATHER_IMMUNE,
		TRAIT_LAVA_IMMUNE,
	)
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/mhydrogen/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/mhydrogen/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	return ..()
