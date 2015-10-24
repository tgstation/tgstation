/mob/living/simple_animal/hostile/humanoid/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	speak_chance = 0

	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	corpse = /obj/effect/landmark/corpse/pirate
	items_to_drop = list(/obj/item/weapon/melee/energy/sword/pirate)

	faction = "pirate"

/mob/living/simple_animal/hostile/humanoid/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "piratemelee_dead"

	melee_damage_lower = 10
	melee_damage_upper = 10 //He's ranged!

	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam

	corpse = /obj/effect/landmark/corpse/pirate/ranged
	items_to_drop = list(/obj/item/weapon/gun/energy/laser)
