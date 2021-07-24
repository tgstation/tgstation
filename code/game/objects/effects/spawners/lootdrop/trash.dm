/obj/effect/spawner/lootdrop/trash
	name = "trash spawner"
	desc = "Ewwwwwww gross."

/obj/effect/spawner/lootdrop/trash/garbage
	name = "garbage spawner"
	loot = list(
	/obj/effect/spawner/lootdrop/trash/food_packaging = 56,
	/obj/item/trash/can = 8,
	/obj/item/shard = 8,
	/obj/effect/spawner/lootdrop/trash/botanical_waste = 8,
	/obj/effect/spawner/lootdrop/trash/cigbutt = 8,
	/obj/item/reagent_containers/syringe = 5,
	/obj/item/light/tube/broken = 3,
	/obj/item/food/deadmouse = 2,
	/obj/item/light/tube/broken = 1,
	/obj/item/trash/candle = 1,
	)

/obj/effect/spawner/lootdrop/trash/cigbutt
	name = "cigarette butt spawner"
	loot = list(
	/obj/item/cigbutt = 65,
	/obj/item/cigbutt/roach = 20,
	/obj/item/cigbutt/cigarbutt = 15,
	)

/obj/effect/spawner/lootdrop/trash/food_packaging
	name = "empty food packaging spawner"
	loot = list(
	/obj/item/trash/raisins = 20,
	/obj/item/trash/cheesie = 10,
	/obj/item/trash/candy = 10,
	/obj/item/trash/chips = 10,
	/obj/item/trash/sosjerky = 10,
	/obj/item/trash/pistachios = 10,
	/obj/item/trash/boritos = 8,
	/obj/item/trash/can/food/beans = 6,
	/obj/item/trash/popcorn = 5,
	/obj/item/trash/energybar = 5,
	/obj/item/trash/can/food/peaches/maint = 4,
	/obj/item/trash/semki = 2,
	)

/obj/effect/spawner/lootdrop/trash/botanical_waste
	name = "botanical waste spawner"
	loot = list(
	/obj/item/grown/bananapeel = 60,
	/obj/item/grown/corncob = 30,
	/obj/item/food/grown/bungopit = 10,
	)

/obj/effect/spawner/lootdrop/trash/grille_or_waste
	name = "grille or waste spawner"
	loot = list(
	/obj/structure/grille = 5,
	/obj/item/cigbutt = 1,
	/obj/item/trash/cheesie = 1,
	/obj/item/trash/candy = 1,
	/obj/item/trash/chips = 1,
	/obj/item/food/deadmouse = 1,
	/obj/item/trash/pistachios = 1,
	/obj/item/trash/popcorn = 1,
	/obj/item/trash/raisins = 1,
	/obj/item/trash/sosjerky = 1,
	/obj/item/trash/syndi_cakes = 1
	)

///This spawner can spawn either a swabbable or non-swabble decal, the purpose of this is provide swabbing spots that cannot be rushed every round using map knowledge.
/obj/effect/spawner/lootdrop/trash/mess
	name = "gross decal spawner"
	icon_state = "random_trash"
	loot = list(
	/obj/effect/decal/cleanable/dirt = 30,
	/obj/effect/decal/cleanable/garbage = 15,
	/obj/effect/decal/cleanable/vomit/old = 15,
	/obj/effect/decal/cleanable/blood/gibs/old = 15,
	/obj/effect/decal/cleanable/insectguts = 5,
	/obj/effect/decal/cleanable/greenglow/ecto = 5,
	/obj/effect/decal/cleanable/wrapping = 5,
	/obj/effect/decal/cleanable/plastic = 5,
	/obj/effect/decal/cleanable/glass = 5,
	/obj/effect/decal/cleanable/ants = 5,
	)

/obj/effect/spawner/lootdrop/graffiti
	name = "random graffiti spawner"
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "random_graffiti"
	loot = list(
	"rune1", "rune2", "rune3", "rune4", "rune5", "rune6",
	"amyjon", "face", "matt", "revolution", "engie", "guy",
	"end", "dwarf", "uboa", "body", "cyka", "star", "poseur tag",
	"prolizard", "antilizard", "danger", "firedanger", "electricdanger",
	"biohazard", "radiation", "safe", "evac", "space", "med", "trade", "shop",
	"food", "peace", "like", "skull", "nay", "heart", "credit",
	"smallbrush", "brush", "largebrush", "splatter", "snake", "stickman",
	"carp", "ghost", "clown", "taser", "disk", "fireaxe", "toolbox",
	"corgi", "cat", "toilet", "blueprint", "beepsky", "scroll", "bottle",
	"shotgun", "arrow", "line", "thinline", "shortline", "body", "chevron",
	"footprint", "clawprint", "pawprint",
	)

/obj/effect/spawner/lootdrop/graffiti/Initialize()
	. = ..()
	var/obj/graffiti = new /obj/effect/decal/cleanable/crayon(get_turf(src))
	graffiti.add_atom_colour("#[random_short_color()]", FIXED_COLOUR_PRIORITY)
	graffiti.icon_state = pick(loot)
	return INITIALIZE_HINT_QDEL
