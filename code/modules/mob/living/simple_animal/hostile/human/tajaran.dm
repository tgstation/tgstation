/mob/living/simple_animal/hostile/humanoid/tajaran
	name = "tajaran"
	desc = "A terrible beast from the depths of hell. Actually, just a terrible beast."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "tajaran"

	melee_damage_lower = 4
	melee_damage_upper = 12
	attacktext = "claws"
	attack_sound = 'sound/weapons/slice.ogg'

	corpse = /obj/effect/landmark/corpse/tajaran

/obj/effect/landmark/corpse/tajaran
	name = "tajaran"
	mutantrace = "Tajaran"

	corpseuniform = /obj/item/clothing/under/stripper/mankini
