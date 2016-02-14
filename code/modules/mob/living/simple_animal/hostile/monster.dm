/mob/living/simple_animal/hostile/monster

/mob/living/simple_animal/hostile/monster/necromorph
	name = "necromorph"
	desc = "A twisted husk of what was once a human, repurposed to kill."
	speak_emote = list("roars")
	icon = 'icons/mob/monster_big.dmi'
	icon_state = "nmorph_standard"
	icon_living = "nmorph_standard"
	icon_dead = "nmorph_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "creature"
	speed = 4
	size = SIZE_BIG
	move_to_delay = 4

/mob/living/simple_animal/hostile/monster/skrite
	name = "skrite"
	desc = "A highly predatory being with two dripping claws."
	icon_state = "skrite"
	icon_living = "skrite"
	icon_dead = "skrite_dead"
	icon_gib = "skrite_dead"
	speak = list("SKREEEEEEEE!","SKRAAAAAAAAW!","KREEEEEEEEE!")
	speak_emote = list("screams", "shrieks")
	emote_hear = list("snarls")
	emote_see = list("lets out a scream", "rubs its claws together")
	speak_chance = 20
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 30
	attack_sound = 'sound/effects/lingstabs.ogg'
	attacktext = "uses its blades to stab"
	projectiletype = /obj/item/projectile/energy/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	move_to_delay = 7

/obj/item/projectile/energy/neurotox
	damage = 10
	damage_type = TOX
	icon_state = "toxin"