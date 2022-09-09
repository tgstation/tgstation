
/obj/effect/spawner/random/trap
	name = "trap spawner"
	desc = "dur yolcu"
	icon_state = "trap"
	alpha = 95				//tuzaklarımız %95 görünmez

/obj/effect/spawner/random/trap/safe
	name = "trap spawner safe"
	desc = "guvenli"
	icon_state = "trap_safe"
	spawn_loot_chance = 10
	loot = list(

			/obj/structure/trap/chill = 10,
			/obj/structure/trap/stun = 8,
			/obj/structure/trap/fire = 10,
			/obj/structure/trap/blind = 10,
			/obj/structure/trap/damage = 5,
			/obj/structure/trap/zombie = 12,
			/obj/structure/trap/imp = 12,
			/obj/structure/trap/wall = 20,
			/obj/structure/trap/flashbang = 15,

	)

/obj/effect/spawner/random/trap/risky
	name = "trap spawner risky"
	desc = "tehlikeli"
	icon_state = "trap_risky"

/obj/effect/spawner/random/trap/deadly
	name = "trap spawner deadly"
	desc = "ölümcül"
	icon_state = "trap_deadly"
	loot = list(

			/obj/structure/trap/chill = 10,
			/obj/structure/trap/stun = 8,
			/obj/structure/trap/fire = 10,
			/obj/structure/trap/blind = 10,
			/obj/structure/trap/damage = 5,
			/obj/structure/trap/zombie = 12,
			/obj/structure/trap/imp = 12,
			/obj/structure/trap/wall = 20,
			/obj/structure/trap/flashbang = 15,

	)
