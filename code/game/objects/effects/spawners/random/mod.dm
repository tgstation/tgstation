/obj/effect/spawner/random/mod
	name = "MOD module spawner"
	desc = "Modularize this, please."
	icon_state = "circuit"

/obj/effect/spawner/random/mod/maint
	name = "maint MOD module spawner"
	loot = list(
		/obj/item/mod/module/springlock,
		/obj/item/mod/module/visor/rave,
		/obj/item/mod/module/tanner,
		/obj/item/mod/module/balloon,
		/obj/item/mod/module/paper_dispenser,
		/obj/item/mod/module/hat_stabilizer,
	)

/obj/effect/spawner/random/mod/maint/Initialize(mapload)
	if(SSmapping.level_trait(z, ZTRAIT_UP) || SSmapping.level_trait(z, ZTRAIT_DOWN))
		loot += /obj/item/mod/module/atrocinator
	return ..()
