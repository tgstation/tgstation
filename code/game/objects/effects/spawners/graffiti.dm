///this spawner generates a randomized graffiti symbol, color, and rotation
/obj/effect/graffiti_spawner
	name = "random graffiti spawner"
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "random_graffiti"
	var/list/graffiti_table = list(
		/obj/effect/decal/cleanable/crayon/rune/rune1,
		/obj/effect/decal/cleanable/crayon/rune/rune2,
		/obj/effect/decal/cleanable/crayon/rune/rune3,
		/obj/effect/decal/cleanable/crayon/rune/rune4,
		/obj/effect/decal/cleanable/crayon/rune/rune5,
		/obj/effect/decal/cleanable/crayon/rune/rune6,
		/obj/effect/decal/cleanable/crayon/graffiti/amyjon,
		/obj/effect/decal/cleanable/crayon/graffiti/face,
		/obj/effect/decal/cleanable/crayon/graffiti/matt,
		/obj/effect/decal/cleanable/crayon/graffiti/revolution,
		/obj/effect/decal/cleanable/crayon/graffiti/engie,
		/obj/effect/decal/cleanable/crayon/graffiti/guy,
		/obj/effect/decal/cleanable/crayon/graffiti/end,
		/obj/effect/decal/cleanable/crayon/graffiti/dwarf,
		/obj/effect/decal/cleanable/crayon/graffiti/uboa,
		/obj/effect/decal/cleanable/crayon/graffiti/body,
		/obj/effect/decal/cleanable/crayon/graffiti/cyka,
		/obj/effect/decal/cleanable/crayon/graffiti/star,
		/obj/effect/decal/cleanable/crayon/graffiti/poseur_tag,
		/obj/effect/decal/cleanable/crayon/graffiti/prolizard,
		/obj/effect/decal/cleanable/crayon/graffiti/antilizard,
		/obj/effect/decal/cleanable/crayon/symbols/danger,
		/obj/effect/decal/cleanable/crayon/symbols/firedanger,
		/obj/effect/decal/cleanable/crayon/symbols/electricdanger,
		/obj/effect/decal/cleanable/crayon/symbols/biohazard,
		/obj/effect/decal/cleanable/crayon/symbols/radiation,
		/obj/effect/decal/cleanable/crayon/symbols/safe,
		/obj/effect/decal/cleanable/crayon/symbols/evac,
		/obj/effect/decal/cleanable/crayon/symbols/space,
		/obj/effect/decal/cleanable/crayon/symbols/med,
		/obj/effect/decal/cleanable/crayon/symbols/trade,
		/obj/effect/decal/cleanable/crayon/symbols/shop,
		/obj/effect/decal/cleanable/crayon/symbols/food,
		/obj/effect/decal/cleanable/crayon/symbols/peace,
		/obj/effect/decal/cleanable/crayon/symbols/like,
		/obj/effect/decal/cleanable/crayon/symbols/skull,
		/obj/effect/decal/cleanable/crayon/symbols/nay,
		/obj/effect/decal/cleanable/crayon/symbols/heart,
		/obj/effect/decal/cleanable/crayon/symbols/credit,
		/obj/effect/decal/cleanable/crayon/drawings/smallbrush,
		/obj/effect/decal/cleanable/crayon/drawings/brush,
		/obj/effect/decal/cleanable/crayon/drawings/largebrush,
		/obj/effect/decal/cleanable/crayon/drawings/splatter,
		/obj/effect/decal/cleanable/crayon/drawings/snake,
		/obj/effect/decal/cleanable/crayon/drawings/stickman,
		/obj/effect/decal/cleanable/crayon/drawings/carp,
		/obj/effect/decal/cleanable/crayon/drawings/ghost,
		/obj/effect/decal/cleanable/crayon/drawings/clown,
		/obj/effect/decal/cleanable/crayon/drawings/taser,
		/obj/effect/decal/cleanable/crayon/drawings/disk,
		/obj/effect/decal/cleanable/crayon/drawings/fireaxe,
		/obj/effect/decal/cleanable/crayon/drawings/toolbox,
		/obj/effect/decal/cleanable/crayon/drawings/corgi,
		/obj/effect/decal/cleanable/crayon/drawings/cat,
		/obj/effect/decal/cleanable/crayon/drawings/toilet,
		/obj/effect/decal/cleanable/crayon/drawings/blueprint,
		/obj/effect/decal/cleanable/crayon/drawings/beepsky,
		/obj/effect/decal/cleanable/crayon/drawings/scroll,
		/obj/effect/decal/cleanable/crayon/drawings/bottle,
		/obj/effect/decal/cleanable/crayon/drawings/shotgun,
		/obj/effect/decal/cleanable/crayon/oriented/arrow,
		/obj/effect/decal/cleanable/crayon/oriented/line,
		/obj/effect/decal/cleanable/crayon/oriented/thinline,
		/obj/effect/decal/cleanable/crayon/oriented/shortline,
		/obj/effect/decal/cleanable/crayon/oriented/body,
		/obj/effect/decal/cleanable/crayon/oriented/chevron,
		/obj/effect/decal/cleanable/crayon/oriented/footprint,
		/obj/effect/decal/cleanable/crayon/oriented/clawprint,
		/obj/effect/decal/cleanable/crayon/oriented/pawprint)

/obj/effect/graffiti_spawner/Initialize()
	..()
	if(!length(graffiti_table))
		return INITIALIZE_HINT_QDEL

	var/graffiti = pickweight(graffiti_table)
	var/obj/effect/decal/cleanable/crayon/graffiti_decal = new graffiti(get_turf(src))
	graffiti_decal.add_atom_colour("#[random_short_color()]", FIXED_COLOUR_PRIORITY)

	return INITIALIZE_HINT_QDEL
