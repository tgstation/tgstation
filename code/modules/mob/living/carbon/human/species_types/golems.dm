/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "iron golem"
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS,NO_UNDERWEAR)
	mutant_organs = list(/obj/item/organ/adamantine_resonator)
	speedmod = 2
	armor = 55
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	nojumpsuit = 1
	sexes = TRUE
	damage_overlay_type = ""
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	blacklisted = TRUE
	dangerous_existence = TRUE
	limbs_id = "golem"
	fixed_mut_color = "aaa"
	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."

	var/prefix = "Iron"
	var/list/special_names
	var/human_surname_chance = 3
	var/special_name_chance = 5

/datum/species/golem/random_name(gender,unique,lastname)
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names && special_names.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/random
	name = "Random Golem"
	blacklisted = FALSE
	dangerous_existence = FALSE

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	var/list/golem_types = typesof(/datum/species/golem) - src.type
	var/datum/species/golem/golem_type = pick(golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)
	to_chat(H, "[initial(golem_type.info_text)]")

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine golem"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/adamantine_resonator, /obj/item/organ/vocal_cords/adamantine)
	fixed_mut_color = "4ed"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems."
	prefix = "Adamantine"

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = "plasma golem"
	fixed_mut_color = "a3d"
	meat = /obj/item/ore/plasma
	//Can burn and takes damage from heat
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS,NO_UNDERWEAR)
	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>You feel like you could blow up at any moment!<span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>You feel more stable.<span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H),1,2,4,flame_range = 5)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
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
			to_chat(owner, "<span class='notice'>You ignite yourself!</span>")
		else
			to_chat(owner, "<span class='warning'>You try ignite yourself, but fail!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = "diamond golem"
	fixed_mut_color = "0ff"
	armor = 70 //up from 55
	meat = /obj/item/ore/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back")

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = "gold golem"
	fixed_mut_color = "cc0"
	speedmod = 1
	armor = 25 //down from 55
	meat = /obj/item/ore/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."
	prefix = "Golden"

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = "silver golem"
	fixed_mut_color = "ddd"
	punchstunthreshold = 9 //60% chance, from 40%
	meat = /obj/item/ore/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks are heavier and have a higher chance of stunning."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")

//Harder to stun, deals more damage, but it's even slower
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = "plasteel golem"
	fixed_mut_color = "bbb"
	stunmod = 0.40
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 //still 40% stun chance
	speedmod = 4 //pretty fucking slow
	meat = /obj/item/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching."
	attack_verb = "smash"
	attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard
	prefix = "Plasteel"

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = "titanium golem"
	fixed_mut_color = "fff"
	meat = /obj/item/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are immune to ash storms, and slightly more resistant to burn damage."
	burnmod = 0.9
	prefix = "Titanium"

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = "plastitanium golem"
	fixed_mut_color = "888"
	meat = /obj/item/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	burnmod = 0.8
	prefix = "Plastitanium"

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "lava"
	C.weather_immunities |= "ash"

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"
	C.weather_immunities -= "lava"

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = "alloy golem"
	fixed_mut_color = "333"
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/tongue/abductor
	speedmod = 1 //faster
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(2,2)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = "wood golem"
	fixed_mut_color = "49311c"
	meat = /obj/item/stack/sheet/mineral/wood
	//Can burn and take damage from heat
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS,NO_UNDERWEAR)
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", "Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	human_surname_chance = 0
	special_name_chance = 100

/datum/species/golem/wood/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"

/datum/species/golem/wood/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.nutrition += light_amount * 10
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/golem/wood/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = "uranium golem"
	fixed_mut_color = "7f0"
	meat = /obj/item/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, you emit radiation pulses every once in a while. It won't harm fellow golems, but organic lifeforms will be affected."

	var/last_event = 0
	var/active = null
	prefix = "Uranium"

/datum/species/golem/uranium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_event+30)
			active = 1
			radiation_pulse(get_turf(H), 3, 3, 5, 0)
			last_event = world.time
			active = null
	..()

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = "sand golem"
	fixed_mut_color = "ffdc8f"
	meat = /obj/item/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage. You will also turn to sand when dying, preventing any form of recovery."
	attack_sound = 'sound/effects/shovel_dig.ogg'
	prefix = "Sand"

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] turns into a pile of sand!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == "bullet" || P.flag == "bomb")
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>", \
			"<span class='userdanger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>")
			return 2
	return 0

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = "glass golem"
	fixed_mut_color = "5a96b4aa" //transparent body
	meat = /obj/item/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage, but you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	attack_sound = 'sound/effects/glassbr2.ogg'
	prefix = "Glass"

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] shatters!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.flag == "laser" || P.flag == "energy")
			H.visible_message("<span class='danger'>The [P.name] gets reflected by [H]'s glass skin!</span>", \
			"<span class='userdanger'>The [P.name] gets reflected by [H]'s glass skin!</span>")
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/turf/curloc = get_turf(H)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = H
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x
				P.Angle = null
			return -1
	return 0

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	id = "bluespace golem"
	fixed_mut_color = "33f"
	meat = /obj/item/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, are spatially unstable: you will teleport when hit, and you can teleport manually at a long distance."
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] teleports!</span>", "<span class='danger'>You destabilize and teleport!</span>")
	new /obj/effect/particle_effect/sparks(get_turf(H))
	playsound(get_turf(H), "sparks", 50, 1)
	do_teleport(H, get_turf(H), 6, asoundin = 'sound/weapons/emitter2.ogg')
	last_teleport = world.time

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	var/cooldown = 150
	var/last_teleport = 0

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] starts vibrating!</span>", "<span class='danger'>You start charging your bluespace core...</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/teleport, H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] disappears in a shower of sparks!</span>", "<span class='danger'>You teleport!</span>")
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg')
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	sleep(cooldown + 5)
	UpdateButtonIcon() //action icon looks available again


//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = "bananium golem"
	fixed_mut_color = "ff0"
	say_mod = "honks"
	punchdamagelow = 0
	punchdamagehigh = 1
	punchstunthreshold = 2 //Harmless and can't stun
	meat = /obj/item/ore/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you cannot hurt people when punching them. Your skin also emits bananas when damaged."
	attack_verb = "honk"
	attack_sound = 'sound/items/airhorn2.ogg'
	prefix = "Bananium"

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/random_name(gender,unique,lastname)
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[uppertext(clown_name)]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/species/golem/bananium/get_spans()
	return list(SPAN_CLOWN)


/datum/species/golem/runic
	name = "Runic Golem"
	id = "runic golem"
	limbs_id = "cultgolem"
	sexes = FALSE
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder God Nar'Sie."
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,NO_UNDERWEAR) //no mutcolors
	prefix = "Runic"

	var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem/phase_shift
	var/obj/effect/proc_holder/spell/targeted/abyssal_gaze/abyssal_gaze
	var/obj/effect/proc_holder/spell/targeted/dominate/dominate

/datum/species/golem/runic/random_name(gender,unique,lastname)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "cult"
	phase_shift = new
	C.AddSpell(phase_shift)
	abyssal_gaze = new
	C.AddSpell(abyssal_gaze)
	dominate = new
	C.AddSpell(dominate)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "cult"
	if(phase_shift)
		C.RemoveSpell(phase_shift)
	if(abyssal_gaze)
		C.RemoveSpell(abyssal_gaze)
	if(dominate)
		C.RemoveSpell(dominate)

/datum/species/golem/runic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "holywater")
		H.adjustFireLoss(4)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)

	if(chem.id == "unholywater")
		H.adjustBruteLoss(-4)
		H.adjustFireLoss(-4)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)

/datum/species/golem/cloth
	name = "Cloth Golem"
	id = "cloth golem"
	limbs_id = "clothgolem"
	sexes = FALSE
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable."
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,NO_UNDERWEAR) //no mutcolors, and can burn
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	speedmod = 1 // not as heavy as stone
	punchdamagelow = 4
	punchstunthreshold = 7
	punchdamagehigh = 8 // not as heavy as stone
	prefix = "Cloth"

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
		H.visible_message("<span class='danger'>[H] burns into ash!</span>")
		H.dust(just_ash = TRUE)
		return

	H.visible_message("<span class='danger'>[H] falls apart into a pile of bandages!</span>")
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	max_integrity = 50
	armor = list(melee = 90, bullet = 90, laser = 25, energy = 80, bomb = 50, bio = 100, fire = -50, acid = -50)
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 900
	var/mob/living/carbon/human/cloth_golem

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, "<span class='notice'>You start gathering your life energy, preparing to rise again...</span>")
		addtimer(CALLBACK(src, .proc/revive), revive_time)
	else
		qdel(src)

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message("<span class='danger'>[src] burns into ash!</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(cloth_golem.suiciding || cloth_golem.disabilities & NOCLONE)
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	if(cloth_golem.revive(full_heal = TRUE, admin_revive = TRUE))
		cloth_golem.grab_ghost() //won't pull if it's a suicide
	sleep(20)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message("<span class='danger'>[src] rises and reforms into [cloth_golem]!</span>","<span class='userdanger'>You reform into yourself!</span>")
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.is_hot())
		visible_message("<span class='danger'>[src] bursts into flames!</span>")
		fire_act()

/datum/species/golem/plastic
	name = "Plastic"
	id = "plastic golem"
	prefix = "Plastic"
	fixed_mut_color = "fff"
	info_text = "As a <span class='danger'>Plastic Golem</span>, you are capable of ventcrawling, and passing through plastic flaps."

/datum/species/golem/plastic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = VENTCRAWLER_NUDE

/datum/species/golem/plastic/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)

//Weird golems able to shift their flesh to heal or make weapons
/datum/species/golem/flesh
	name = "Flesh Golem"
	id = "flesh golem"
	limbs_id = "fleshgolem"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human
	//If someone removes nodismember please add a check for missing limbs in the armblade skill
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,RADIMMUNE,VIRUSIMMUNE,NODISMEMBER,NO_UNDERWEAR)
	info_text = "As a <span class='danger'>Flesh Golem</span>, you can gain extra flesh by eating, which you can then use to heal or to form armblades."
	prefix = "Flesh"
	armor = 25 //not rock, but very thick skin is still hard to damage
	sexes = FALSE
	var/flesh = 0 //excess flesh, used for abilities
	var/max_flesh = 300
	var/datum/action/innate/flesh/shifting_flesh/shifting_flesh
	var/datum/action/innate/flesh/blade/armblade
	disliked_food = 0 //eats everything
	liked_food = MEAT | RAW //but especially FRESH MEAT

/datum/species/golem/flesh/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(C.hud_used)
		C.hud_used.fleshdisplay.invisibility = 0
	if(ishuman(C))
		shifting_flesh = new(src)
		shifting_flesh.Grant(C)
		armblade = new(src)
		armblade.Grant(C)

/datum/species/golem/flesh/on_species_loss(mob/living/carbon/C)
	if(C.hud_used)
		C.hud_used.fleshdisplay.invisibility = INVISIBILITY_ABSTRACT
	if(shifting_flesh)
		shifting_flesh.owner_species = null
		shifting_flesh.Remove(C)
	if(armblade)
		armblade.owner_species = null
		armblade.Remove(C)
	..()

/datum/species/golem/flesh/spec_life(mob/living/carbon/human/H)
	H.hud_used.fleshdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[flesh]</font></div>"
	switch(H.nutrition)
		if(0 to NUTRITION_LEVEL_STARVING)
			flesh = max(flesh - 1, 0)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			flesh = max(flesh - 0.5, 0)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			flesh = min(flesh + 1, max_flesh)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			flesh = min(flesh + 2, max_flesh)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FAT)
			flesh = min(flesh + 3, max_flesh)
		if(NUTRITION_LEVEL_FAT to INFINITY)
			flesh = min(flesh + 5, max_flesh)
			H.nutrition = NUTRITION_LEVEL_FAT - 1 //it's not fat, it's extra flesh
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		flesh = max(flesh-5, 0)
	if(H.hud_used) //because the body does not have a HUD until inhabited
		H.hud_used.fleshdisplay.invisibility = 0

/datum/action/innate/flesh
	name = "Flesh Skill"
	desc = "Something went wrong if you see this, warn a coder"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	var/datum/species/golem/flesh/owner_species
	var/flesh_cost = 0 // how much flesh it costs
	var/use_without_flesh = FALSE // can be used without remaining flesh
	var/available = TRUE

/datum/action/innate/flesh/New(species)
	. = ..()
	owner_species = species
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/flesh/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/action/innate/flesh/process()
	var/now_available = IsAvailable()
	if((!available && now_available) || (available && !now_available))
		available = now_available
		UpdateButtonIcon()

/datum/action/innate/flesh/IsAvailable()
	if((owner_species.flesh < flesh_cost) && !use_without_flesh)
		return FALSE
	return ..()

/datum/action/innate/flesh/Activate()
	owner_species.flesh = max(owner_species.flesh - flesh_cost, 0)

/datum/action/innate/flesh/shifting_flesh
	name = "Shifting Flesh"
	desc = "Use your excess flesh to patch your wounds. <br>Costs 50 flesh."
	button_icon_state = "shift_flesh"
	var/healing_ticks = 8 // 5 per tick
	var/total_healing = 40
	flesh_cost = 50
	var/ongoing = FALSE //Only one activation at a time

/datum/action/innate/flesh/shifting_flesh/IsAvailable()
	if(ongoing)
		return FALSE
	return ..()

/datum/action/innate/flesh/shifting_flesh/Activate()
	..()
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H]'s flesh twists and shifts along [H.p_their()] body!</span>", "<span class='notice'>You shift your flesh, using it to patch up your wounds.</span>")
	playsound(H, 'sound/effects/blobattack.ogg', 30, 1)
	INVOKE_ASYNC(src, .proc/fleshmend)

/datum/action/innate/flesh/shifting_flesh/proc/fleshmend()
	var/mob/living/carbon/human/H = owner
	ongoing = TRUE
	for(var/i in 1 to healing_ticks)
		if(H)
			var/healpertick = -(total_healing / healing_ticks)
			H.adjustBruteLoss(healpertick, 0)
			H.adjustFireLoss(healpertick, 0)
			H.updatehealth()
		else
			break
		sleep(10)
	ongoing = FALSE


/datum/action/innate/flesh/blade
	name = "Armblade"
	desc = "Temporarily turn one of your arms into a sharp armblade. <br>Costs 100 flesh."
	button_icon_state = "flesh_blade"
	flesh_cost = 100
	use_without_flesh = TRUE
	var/duration = 450

/datum/action/innate/flesh/blade/Activate()
	var/mob/living/carbon/human/H = owner
	var/obj/item/I = H.get_active_held_item()
	if(istype(I, /obj/item/melee/arm_blade))
		drop_blade(I)
	else
		if(!H.drop_item())
			to_chat(H, "<span class='warning'>The [H.get_active_held_item()] is stuck to your hand, you cannot grow an armblade over it!</span>")
			return
		if(owner_species.flesh < flesh_cost)
			to_chat(H, "<span class='warning'>You don't have enough flesh to do this!</span>")
			return
		var/obj/item/melee/arm_blade/W = new(H, silent = TRUE)
		owner_species.flesh = max(owner_species.flesh - flesh_cost, 0)
		H.visible_message("<span class='warning'>[H]'s arm rapidly grows into a sharp blade!</span>", "<span class='warning'>Your flesh gathers around your arm and hardens into a sharp blade!</span>")
		playsound(H, 'sound/effects/blobattack.ogg', 30, 1)
		H.put_in_hands(W)
		addtimer(CALLBACK(src, .proc/drop_blade, W), duration)

/datum/action/innate/flesh/blade/proc/drop_blade(obj/item/melee/arm_blade/blade)
	if(QDELETED(blade))
		return
	var/mob/living/carbon/human/H = owner
	H.temporarilyRemoveItemFromInventory(blade, TRUE) //DROPDEL will delete the item
	playsound(H, 'sound/effects/blobattack.ogg', 30, 1)
	H.visible_message("<span class='warning'>[H]'s [blade] quickly rots and drops off in a mass of flesh!</span>", "<span class='notice'>Your [blade] melts and falls off, freeing your arm.</span>")
	new /obj/effect/decal/cleanable/blood/gibs(H.drop_location())
	H.update_inv_hands()