/mob/living/simple_animal/hostile/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	speak_chance = 0
	turns_per_move = 5
	response_help = "brushes"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 1
	maxHealth = 250
	health = 250
	mob_size = MOB_SIZE_LARGE

	pixel_x = -16

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("pines")

	//Space carp aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("hostile")
	var/drop_type = /obj/item/stack/sheet/mineral/wood

/mob/living/simple_animal/hostile/tree/FindTarget()
	. = ..()
	if(.)
		emote("me", 1, "growls at [.].")

/mob/living/simple_animal/hostile/tree/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\The [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/tree/death(gibbed)
	..(1)
	visible_message("<span class='danger'>[src] is hacked into pieces!</span>")
	new drop_type(loc)
	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/tree/festivus
	name = "festivus pole"
	desc = "serenity now... SERENITY NOW!"
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	drop_type = /obj/item/stack/rods
	speak_emote = list("polls")

