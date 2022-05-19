/obj/effect/spawner/random/animal
	name = "animal spawner"
	desc = "Can I pet it?"
	icon_state = "corgi"

/obj/effect/spawner/random/animal/frog
	name = "frog spawner"
	loot = list(
		/mob/living/simple_animal/hostile/retaliate/frog = 99,
		/mob/living/simple_animal/hostile/retaliate/frog/rare = 1
	)

/obj/effect/spawner/random/animal/frog/vatgrown
	name = "vatgrown frog spawner"
	spawn_on_init = FALSE