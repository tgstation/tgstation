///This spawner can spawn either a swabbable or non-swabble decal, the purpose of this is provide swabbing spots that cannot be rushed every round using map knowledge.
/obj/effect/spawner/lootdrop/gross_decal_spawner
	name = "gross decal spawner"
	icon_state = "random_trash"
	loot = list(
				/obj/effect/decal/cleanable/garbage = 15,
				/obj/effect/decal/cleanable/vomit/old = 15,
				/obj/effect/decal/cleanable/blood/gibs/old = 15,
				/obj/effect/decal/cleanable/insectguts = 5,
				/obj/effect/decal/cleanable/greenglow/ecto = 5,
				/obj/effect/decal/cleanable/wrapping = 5,
				/obj/effect/decal/cleanable/plastic = 5,
				/obj/effect/decal/cleanable/glass = 5,
				/obj/effect/decal/cleanable/dirt = 30
				)
