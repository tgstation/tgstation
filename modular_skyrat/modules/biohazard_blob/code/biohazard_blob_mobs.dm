/mob/living/simple_animal/hostile/biohazard_blob
	gold_core_spawnable = HOSTILE_SPAWN
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	see_in_dark = 4
	mob_biotypes = MOB_ORGANIC
	gold_core_spawnable = NO_SPAWN
	icon = 'modular_skyrat/modules/biohazard_blob/icons/blob_mobs.dmi'
	vision_range = 5
	aggro_vision_range = 8
	move_to_delay = 6


/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler
	name = "oil shambler"
	desc = "Humanoid figure covered in oil, or maybe they're just oil? They seem to be perpetually on fire."
	icon_state = "oil_shambler"
	icon_living = "oil_shambler"
	icon_dead = "oil_shambler"
	speak_emote = list("blorbles")
	emote_hear = list("blorbles")
	speak_chance = 5
	turns_per_move = 4
	maxHealth = 150
	health = 150
	speed = 0
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	faction = list(MOLD_FACTION)
	attack_sound = 'sound/effects/attackblob.ogg'
	melee_damage_type = BURN
	del_on_death = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
	damage_coeff = list(BRUTE = 1, BURN = 0, TOX = 0, CLONE = 1, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	gender = MALE

/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler/Initialize()
	. = ..()
	update_overlays()

/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler/Destroy()
	visible_message(span_warning("The [src] evaporates!"))
	return ..()

/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	SSvis_overlays.add_vis_overlay(src, icon, "oil_shambler_overlay", layer, plane, dir, alpha)
	SSvis_overlays.add_vis_overlay(src, icon, "oil_shambler_overlay", 0, EMISSIVE_PLANE, dir, alpha)

/mob/living/simple_animal/hostile/biohazard_blob/oil_shambler/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(20))
			L.fire_stacks += 2
		if(L.fire_stacks)
			L.IgniteMob()

/mob/living/simple_animal/hostile/biohazard_blob/diseased_rat
	name = "diseased rat"
	desc = "An incredibly large, rabid looking rat. There's shrooms growing out of it"
	icon_state = "diseased_rat"
	icon_living = "diseased_rat"
	icon_dead = "diseased_rat_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 4
	maxHealth = 70
	health = 70
	obj_damage = 30
	speed = 0
	melee_damage_lower = 7
	melee_damage_upper = 13
	faction = list(MOLD_FACTION)
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	pass_flags = PASSTABLE
	butcher_results = list(/obj/item/food/meat/slab = 1)
	attack_sound = 'sound/weapons/bite.ogg'
	melee_damage_type = BRUTE

/mob/living/simple_animal/hostile/biohazard_blob/diseased_rat/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(src.can_inject(target))
			to_chat(C, span_danger("[src] manages to penetrate your clothing with it's teeth!"))
			C.ForceContractDisease(new /datum/disease/cordyceps(), FALSE, TRUE)

/mob/living/simple_animal/hostile/biohazard_blob/electric_mosquito
	name = "electric mosquito"
	desc = "An ovesized mosquito, with what it seems like electricity inside its body."
	icon_state = "electric_mosquito"
	icon_living = "electric_mosquito"
	icon_dead = "electric_mosquito_dead"
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	speak_chance = 5
	turns_per_move = 4
	maxHealth = 70
	health = 70
	speed = 0
	obj_damage = 20
	melee_damage_lower = 7
	melee_damage_upper = 10
	faction = list(MOLD_FACTION)
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"
	attack_sound = 'sound/effects/attackblob.ogg'
	melee_damage_type = BRUTE
	pass_flags = PASSTABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

/mob/living/simple_animal/hostile/biohazard_blob/electric_mosquito/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.reagents.add_reagent(/datum/reagent/teslium, 2)

/mob/living/simple_animal/hostile/biohazard_blob/centaur
	name = "centaur"
	desc = "A horrific combination of bone and flesh with multiple sets of legs and feet."
	icon_state = "centaur"
	icon_living = "centaur"
	icon_dead = "centaur_dead"
	speak_emote = list("moans")
	emote_hear = list("moans")
	speak_chance = 5
	turns_per_move = 1
	maxHealth = 120
	health = 120
	speed = 0.5
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	faction = list(MOLD_FACTION)
	attack_sound = 'sound/effects/wounds/crackandbleed.ogg'
	melee_damage_type = BRUTE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_GREEN
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 1, STAMINA = 0, OXY = 0)
	gender = NEUTER
	wound_bonus = 30
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

/mob/living/simple_animal/hostile/biohazard_blob/centaur/Initialize()
	. = ..()
	update_overlays()

/mob/living/simple_animal/hostile/biohazard_blob/centaur/death(gibbed)
	visible_message(span_warning("The [src] ruptures!"))
	var/datum/reagents/R = new/datum/reagents(300)
	R.my_atom = src
	R.add_reagent(/datum/reagent/toxin/mutagen, 20)
	chem_splash(loc, 5, list(R))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	return ..()

/mob/living/simple_animal/hostile/biohazard_blob/centaur/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(20))
			radiation_pulse(L, 300, 1, FALSE, TRUE)
			playsound(src, 'modular_skyrat/modules/horrorform/sound/effects/horror_scream.ogg', 60, TRUE)
