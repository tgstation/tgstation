
/obj/effect/spawner/random/trap
	name = "trap spawner"
	desc = "dur yolcu"
	icon_state = "trap"
	alpha = 95				//tuzaklarımız %95 görünmez

/obj/effect/spawner/random/trap/safe
	name = "trap spawner safe"
	desc = "guvenli"
	icon_state = "trap_safe"
	spawn_loot_chance = 50
	loot = list(

			/obj/structure/trap/chill = 8,
			/obj/structure/trap/stun = 2,


	)

/obj/effect/spawner/random/trap/risky
	name = "trap spawner risky"
	desc = "tehlikeli"
	icon_state = "trap_risky"

/obj/effect/spawner/random/trap/deadly
	name = "trap spawner deadly"
	desc = "ölümcül"
	icon_state = "trap_deadly"
