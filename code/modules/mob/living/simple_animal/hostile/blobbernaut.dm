/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER
	melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER
	obj_damage = BLOBMOB_BLOBBERNAUT_DMG_OBJ
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blobattack.ogg'
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	force_threshold = 10
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	hud_type = /datum/hud/living/blobbernaut

/mob/living/simple_animal/hostile/blob/blobbernaut/Initialize(mapload)
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/hostile/blob/blobbernaut/mind_initialize()
	. = ..()
	if(independent | !overmind)
		return
	var/datum/antagonist/blob_minion/blobbernaut/naut = new(overmind)
	mind.add_antag_datum(naut)

/mob/living/simple_animal/hostile/blob/blobbernaut/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBBERNAUT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/blob/blobbernaut/Life(delta_time = SSMOBS_DT, times_fired)
	if(!..())
		return FALSE
	var/list/blobs_in_area = range(2, src)

	if(independent)
		return FALSE // strong independent blobbernaut that don't need no blob

	var/damagesources = 0

	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damagesources++

	if(!factory)
		damagesources++
	else
		if(locate(/obj/structure/blob/special/core) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_CORE * delta_time)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = "#000000"
		if(locate(/obj/structure/blob/special/node) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_NODE * delta_time)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = "#000000"

	if(!damagesources)
		return FALSE

	adjustHealth(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damagesources * delta_time) //take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
	var/image/image = new('icons/mob/nonhuman-player/blob.dmi', src, "nautdamage", MOB_LAYER+0.01)
	image.appearance_flags = RESET_COLOR

	if(overmind)
		image.color = overmind.blobstrain.complementary_color

	flick_overlay_view(image, 8)

/mob/living/simple_animal/hostile/blob/blobbernaut/AttackingTarget()
	. = ..()
	if(. && isliving(target) && overmind)
		overmind.blobstrain.blobbernaut_attack(target, src)

/mob/living/simple_animal/hostile/blob/blobbernaut/update_icons()
	..()
	if(overmind) //if we have an overmind, we're doing chemical reactions instead of pure damage
		melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_LOWER
		melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_UPPER
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		attack_verb_continuous = initial(attack_verb_continuous)

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	..(gibbed)
	if(factory)
		factory.naut = null //remove this naut from its factory
		factory.max_integrity = initial(factory.max_integrity)
	flick("blobbernaut_death", src)

/mob/living/simple_animal/hostile/blob/blobbernaut/independent
	independent = TRUE
	gold_core_spawnable = HOSTILE_SPAWN


