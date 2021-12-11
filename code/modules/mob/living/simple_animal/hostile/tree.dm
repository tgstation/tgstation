/mob/living/simple_animal/hostile/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	health_doll_icon = "pine_1"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "brushes"
	response_help_simple = "brush"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	faction = list("hostile")
	speed = 1
	maxHealth = 250
	health = 250
	mob_size = MOB_SIZE_LARGE

	pixel_x = -16
	base_pixel_x = -16

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("pines")
	emote_taunt = list("growls")
	taunt_chance = 20

	atmos_requirements = list("min_oxy" = 2, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	minbodytemp = 0
	maxbodytemp = 1200

	deathmessage = "is hacked into pieces!"
	loot = list(/obj/item/stack/sheet/mineral/wood)
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = 1

	var/is_tree = TRUE

/mob/living/simple_animal/hostile/tree/Initialize(mapload)
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/hostile/tree/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(!is_tree || !isopenturf(loc))
		return
	var/turf/open/T = src.loc
	if(!T.air || !T.air.gases[/datum/gas/carbon_dioxide])
		return

	var/co2 = T.air.gases[/datum/gas/carbon_dioxide][MOLES]
	if(co2 > 0 && DT_PROB(13, delta_time))
		var/amt = min(co2, 9)
		T.air.gases[/datum/gas/carbon_dioxide][MOLES] -= amt
		T.atmos_spawn_air("o2=[amt]")

/mob/living/simple_animal/hostile/tree/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(15))
			C.Paralyze(60)
			C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
					span_userdanger("\The [src] knocks you down!"))

/mob/living/simple_animal/hostile/tree/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PINE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/tree/festivus
	name = "festivus pole"
	desc = "Serenity now... SERENITY NOW!"
	maxHealth = 200
	health = 200
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	health_doll_icon = "festivus_pole"
	response_help_continuous = "rubs"
	response_help_simple = "rub"
	loot = list(/obj/item/stack/rods)
	speak_emote = list("polls")
	faction = list()
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	is_tree = FALSE

/mob/living/simple_animal/hostile/tree/festivus/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(!user.combat_mode)
		visible_message(span_warning("[src] crackles with static electricity!"))
		for(var/obj/item/stock_parts/cell/C in range(2, get_turf(src)))
			C.give(75)
		for(var/mob/living/silicon/robot/R in range(2, get_turf(src)))
			if(R.cell)
				R.cell.give(75)
		for(var/obj/machinery/power/apc/A in range(2, get_turf(src)))
			if(A.cell)
				A.cell.give(75)

/mob/living/simple_animal/hostile/tree/festivus/add_cell_sample()
	return
