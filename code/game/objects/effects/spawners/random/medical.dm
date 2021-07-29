/obj/effect/spawner/random/medical
	name = "medical loot spawner"
	desc = "Doc, gimmie something good."

/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
	)

/obj/effect/spawner/random/medical/injector
	name = "injector spawner"
	loot = list(
		/obj/item/implanter,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
	)
