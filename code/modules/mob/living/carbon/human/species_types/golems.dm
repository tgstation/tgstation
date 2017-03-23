/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "iron"
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS)
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
	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."

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
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	fixed_mut_color = "4ed"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you don't have any special traits."

//Explodes on death
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = "plasma"
	fixed_mut_color = "a3d"
	meat = /obj/item/weapon/ore/plasma
	//Can burn and takes damage from heat
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS)
	info_text = "As a <span class='danger'>Plasma Golem</span>, you explode on death!"
	burnmod = 1.5

/datum/species/golem/plasma/spec_death(gibbed, mob/living/carbon/human/H)
	explosion(get_turf(H),0,1,2,flame_range = 5)
	if(H)
		H.gib()

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = "diamond"
	fixed_mut_color = "0ff"
	armor = 70 //up from 55
	meat = /obj/item/weapon/ore/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = "gold"
	fixed_mut_color = "cc0"
	speedmod = 1
	armor = 25 //down from 55
	meat = /obj/item/weapon/ore/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = "silver"
	fixed_mut_color = "ddd"
	punchstunthreshold = 9 //60% chance, from 40%
	meat = /obj/item/weapon/ore/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks are heavier and have a higher chance of stunning."

//Harder to stun, deals more damage, but it's even slower
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = "plasteel"
	fixed_mut_color = "bbb"
	stunmod = 0.40
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 //still 40% stun chance
	speedmod = 4 //pretty fucking slow
	meat = /obj/item/weapon/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching."
	attack_verb = "smash"
	attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = "titanium"
	fixed_mut_color = "fff"
	meat = /obj/item/weapon/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are immune to ash storms, and slightly more resistant to burn damage."
	burnmod = 0.9

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = "plastitanium"
	fixed_mut_color = "888"
	meat = /obj/item/weapon/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	burnmod = 0.8

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
	id = "alloy"
	fixed_mut_color = "333"
	meat = /obj/item/stack/sheet/mineral/abductor
	mutant_organs = list(/obj/item/organ/tongue/abductor) //abductor tongue
	speedmod = 1 //faster
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."

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
	id = "wood"
	fixed_mut_color = "49311c"
	meat = /obj/item/stack/sheet/mineral/wood
	//Can burn and take damage from heat
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,MUTCOLORS)
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."

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
	id = "uranium"
	fixed_mut_color = "7f0"
	meat = /obj/item/weapon/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, you emit radiation pulses every once in a while. It won't harm fellow golems, but organic lifeforms will be affected."

	var/last_event = 0
	var/active = null

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
	id = "sand"
	fixed_mut_color = "ffdc8f"
	meat = /obj/item/weapon/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage. You will also turn to sand when dying, preventing any form of recovery."
	attack_sound = 'sound/effects/shovel_dig.ogg'

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] turns into a pile of sand!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/weapon/ore/glass(get_turf(H))
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
	id = "glass"
	fixed_mut_color = "5a96b4aa" //transparent body
	meat = /obj/item/weapon/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage, but you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	attack_sound = 'sound/effects/Glassbr2.ogg'

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] shatters!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/weapon/shard(get_turf(H))
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
	id = "bluespace"
	fixed_mut_color = "33f"
	meat = /obj/item/weapon/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, are spatially unstable: you will teleport when hit, and you can teleport manually at a long distance."
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'

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

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style = M.martial_art)
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
	id = "bananium"
	fixed_mut_color = "ff0"
	say_mod = "honks"
	punchdamagelow = 0
	punchdamagehigh = 1
	punchstunthreshold = 2 //Harmless and can't stun
	meat = /obj/item/weapon/ore/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you cannot hurt people when punching them. Your skin also emits bananas when damaged."
	attack_verb = "honk"
	attack_sound = 'sound/items/AirHorn2.ogg'

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style = M.martial_art)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/weapon/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/weapon/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/weapon/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/weapon/grown/bananapeel/specialpeel(get_turf(H))
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
	id = "runic"
	limbs_id = "cultgolem"
	sexes = FALSE
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder God Nar'Sie."
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER) //no mutcolors

	var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem/phase_shift
	var/obj/effect/proc_holder/spell/targeted/abyssal_gaze/abyssal_gaze
	var/obj/effect/proc_holder/spell/targeted/dominate/dominate

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
	id = "cloth"
	limbs_id = "clothgolem"
	sexes = FALSE
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable."
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER) //no mutcolors, and can burn
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	speedmod = 1 // not as heavy as stone
	punchdamagelow = 4
	punchstunthreshold = 7
	punchdamagehigh = 8 // not as heavy as stone

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
	obj_integrity = 50
	max_integrity = 50
	armor = list(melee = 90, bullet = 90, laser = 25, energy = 80, bomb = 50, bio = 100, fire = -50, acid = -50)
	icon = 'icons/obj/items.dmi'
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
	new /obj/effect/overlay/temp/mummy_animation(get_turf(src))
	if(cloth_golem.revive(full_heal = TRUE, admin_revive = TRUE))
		cloth_golem.grab_ghost() //won't pull if it's a suicide
	sleep(20)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message("<span class='danger'>[src] rises and reforms into [cloth_golem]!</span>","<span class='userdanger'>You reform into yourself!</span>")
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.is_hot())
		visible_message("<span class='danger'>[src] bursts into flames!</span>")
		fire_act()