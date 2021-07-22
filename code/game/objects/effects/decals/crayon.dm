GLOBAL_LIST(gang_tags)

/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE
	var/do_icon_rotate = TRUE
	var/rotation = 0
	var/paint_colour = "#FFFFFF"

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	if(e_name)
		name = e_name
	desc = "A graffiti vandalizing the station."
	if(alt_icon)
		icon = alt_icon
	if(type)
		icon_state = type
	if(graf_rot)
		rotation = graf_rot
	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M
	if(main)
		paint_colour = main
	add_atom_colour(paint_colour, FIXED_COLOUR_PRIORITY)
/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/T)
	return isgroundlessturf(T)

/obj/effect/decal/cleanable/crayon/gang
	name = "Leet Like Jeff K gang tag"
	desc = "Looks like someone's claimed this area for Leet Like Jeff K."
	icon = 'icons/obj/gang/tags.dmi'
	layer = BELOW_MOB_LAYER
	var/datum/team/gang/my_gang

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	LAZYADD(GLOB.gang_tags, src)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	LAZYREMOVE(GLOB.gang_tags, src)
	..()

// Mapping

/obj/effect/decal/cleanable/crayon/rune
	name = "Rune"
	icon_state = "rune1"

/obj/effect/decal/cleanable/crayon/rune/rune1
	icon_state = "rune1"
/obj/effect/decal/cleanable/crayon/rune/rune2
	icon_state = "rune2"
/obj/effect/decal/cleanable/crayon/rune/rune3
	icon_state = "rune3"
/obj/effect/decal/cleanable/crayon/rune/rune4
	icon_state = "rune4"
/obj/effect/decal/cleanable/crayon/rune/rune5
	icon_state = "rune5"
/obj/effect/decal/cleanable/crayon/rune/rune6
	icon_state = "rune6"

/obj/effect/decal/cleanable/crayon/graffiti
	name = "Graffiti"
	icon_state = "amyjon"

/obj/effect/decal/cleanable/crayon/graffiti/amyjon
	icon_state = "amyjon"
/obj/effect/decal/cleanable/crayon/graffiti/face
	icon_state = "face"
/obj/effect/decal/cleanable/crayon/graffiti/matt
	icon_state = "matt"
/obj/effect/decal/cleanable/crayon/graffiti/revolution
	icon_state = "revolution"
/obj/effect/decal/cleanable/crayon/graffiti/engie
	icon_state = "engie"
/obj/effect/decal/cleanable/crayon/graffiti/guy
	icon_state = "guy"
/obj/effect/decal/cleanable/crayon/graffiti/end
	icon_state = "end"
/obj/effect/decal/cleanable/crayon/graffiti/dwarf
	icon_state = "dwarf"
/obj/effect/decal/cleanable/crayon/graffiti/uboa
	icon_state = "uboa"
/obj/effect/decal/cleanable/crayon/graffiti/body
	icon_state = "body"
/obj/effect/decal/cleanable/crayon/graffiti/cyka
	icon_state = "cyka"
/obj/effect/decal/cleanable/crayon/graffiti/star
	icon_state = "star"
/obj/effect/decal/cleanable/crayon/graffiti/poseur_tag
	icon_state = "poseur tag"
/obj/effect/decal/cleanable/crayon/graffiti/prolizard
	icon_state = "prolizard"
/obj/effect/decal/cleanable/crayon/graffiti/antilizard
	icon_state = "antilizard"

/obj/effect/decal/cleanable/crayon/graffiti_large
	name = "Graffiti Large"
	icon = 'icons/effects/96x32.dmi'
	icon_state = "yiffhell"

/obj/effect/decal/cleanable/crayon/graffiti_large/yiffhell
	icon_state = "yiffhell"
/obj/effect/decal/cleanable/crayon/graffiti_large/secborg
	icon_state = "secborg"
/obj/effect/decal/cleanable/crayon/graffiti_large/paint
	icon_state = "paint"

/obj/effect/decal/cleanable/crayon/symbols
	name = "Symbol"
	icon_state = "danger"

/obj/effect/decal/cleanable/crayon/symbols/danger
	icon_state = "danger"
/obj/effect/decal/cleanable/crayon/symbols/firedanger
	icon_state = "firedanger"
/obj/effect/decal/cleanable/crayon/symbols/electricdanger
	icon_state = "electricdanger"
/obj/effect/decal/cleanable/crayon/symbols/biohazard
	icon_state = "biohazard"
/obj/effect/decal/cleanable/crayon/symbols/radiation
	icon_state = "radiation"
/obj/effect/decal/cleanable/crayon/symbols/safe
	icon_state = "safe"
/obj/effect/decal/cleanable/crayon/symbols/evac
	icon_state = "evac"
/obj/effect/decal/cleanable/crayon/symbols/space
	icon_state = "space"
/obj/effect/decal/cleanable/crayon/symbols/med
	icon_state = "med"
/obj/effect/decal/cleanable/crayon/symbols/trade
	icon_state = "trade"
/obj/effect/decal/cleanable/crayon/symbols/shop
	icon_state = "shop"
/obj/effect/decal/cleanable/crayon/symbols/food
	icon_state = "food"
/obj/effect/decal/cleanable/crayon/symbols/peace
	icon_state = "peace"
/obj/effect/decal/cleanable/crayon/symbols/like
	icon_state = "like"
/obj/effect/decal/cleanable/crayon/symbols/skull
	icon_state = "skull"
/obj/effect/decal/cleanable/crayon/symbols/nay
	icon_state = "nay"
/obj/effect/decal/cleanable/crayon/symbols/heart
	icon_state = "heart"
/obj/effect/decal/cleanable/crayon/symbols/credit
	icon_state = "credit"

/obj/effect/decal/cleanable/crayon/drawings
	name = "Drawing"
	icon_state = "danger"

/obj/effect/decal/cleanable/crayon/drawings/smallbrush
	icon_state = "smallbrush"
/obj/effect/decal/cleanable/crayon/drawings/brush
	icon_state = "brush"
/obj/effect/decal/cleanable/crayon/drawings/largebrush
	icon_state = "largebrush"
/obj/effect/decal/cleanable/crayon/drawings/splatter
	icon_state = "splatter"
/obj/effect/decal/cleanable/crayon/drawings/snake
	icon_state = "snake"
/obj/effect/decal/cleanable/crayon/drawings/stickman
	icon_state = "stickman"
/obj/effect/decal/cleanable/crayon/drawings/carp
	icon_state = "carp"
/obj/effect/decal/cleanable/crayon/drawings/ghost
	icon_state = "ghost"
/obj/effect/decal/cleanable/crayon/drawings/clown
	icon_state = "clown"
/obj/effect/decal/cleanable/crayon/drawings/taser
	icon_state = "taser"
/obj/effect/decal/cleanable/crayon/drawings/disk
	icon_state = "disk"
/obj/effect/decal/cleanable/crayon/drawings/fireaxe
	icon_state = "fireaxe"
/obj/effect/decal/cleanable/crayon/drawings/toolbox
	icon_state = "toolbox"
/obj/effect/decal/cleanable/crayon/drawings/corgi
	icon_state = "corgi"
/obj/effect/decal/cleanable/crayon/drawings/cat
	icon_state = "cat"
/obj/effect/decal/cleanable/crayon/drawings/toilet
	icon_state = "toilet"
/obj/effect/decal/cleanable/crayon/drawings/blueprint
	icon_state = "blueprint"
/obj/effect/decal/cleanable/crayon/drawings/beepsky
	icon_state = "beepsky"
/obj/effect/decal/cleanable/crayon/drawings/scroll
	icon_state = "scroll"
/obj/effect/decal/cleanable/crayon/drawings/bottle
	icon_state = "bottle"
/obj/effect/decal/cleanable/crayon/drawings/shotgun
	icon_state = "shotgun"

/obj/effect/decal/cleanable/crayon/oriented
	name = "Oriented"
	icon_state = "arrow"

/obj/effect/decal/cleanable/crayon/oriented/arrow
	icon_state = "arrow"
/obj/effect/decal/cleanable/crayon/oriented/line
	icon_state = "line"
/obj/effect/decal/cleanable/crayon/oriented/thinline
	icon_state = "thinline"
/obj/effect/decal/cleanable/crayon/oriented/shortline
	icon_state = "shortline"
/obj/effect/decal/cleanable/crayon/oriented/body
	icon_state = "body"
/obj/effect/decal/cleanable/crayon/oriented/chevron
	icon_state = "chevron"
/obj/effect/decal/cleanable/crayon/oriented/footprint
	icon_state = "footprint"
/obj/effect/decal/cleanable/crayon/oriented/clawprint
	icon_state = "clawprint"
/obj/effect/decal/cleanable/crayon/oriented/pawprint
	icon_state = "pawprint"

/obj/effect/decal/cleanable/crayon/letter
	name = "Letter"
	icon_state = "a"

/obj/effect/decal/cleanable/crayon/letter/a
	icon_state = "a"
/obj/effect/decal/cleanable/crayon/letter/b
	icon_state = "b"
/obj/effect/decal/cleanable/crayon/letter/c
	icon_state = "c"
/obj/effect/decal/cleanable/crayon/letter/d
	icon_state = "d"
/obj/effect/decal/cleanable/crayon/letter/e
	icon_state = "e"
/obj/effect/decal/cleanable/crayon/letter/f
	icon_state = "f"
/obj/effect/decal/cleanable/crayon/letter/g
	icon_state = "g"
/obj/effect/decal/cleanable/crayon/letter/h
	icon_state = "h"
/obj/effect/decal/cleanable/crayon/letter/i
	icon_state = "i"
/obj/effect/decal/cleanable/crayon/letter/j
	icon_state = "j"
/obj/effect/decal/cleanable/crayon/letter/k
	icon_state = "k"
/obj/effect/decal/cleanable/crayon/letter/l
	icon_state = "l"
/obj/effect/decal/cleanable/crayon/letter/m
	icon_state = "m"
/obj/effect/decal/cleanable/crayon/letter/n
	icon_state = "n"
/obj/effect/decal/cleanable/crayon/letter/o
	icon_state = "o"
/obj/effect/decal/cleanable/crayon/letter/p
	icon_state = "p"
/obj/effect/decal/cleanable/crayon/letter/q
	icon_state = "q"
/obj/effect/decal/cleanable/crayon/letter/r
	icon_state = "r"
/obj/effect/decal/cleanable/crayon/letter/s
	icon_state = "s"
/obj/effect/decal/cleanable/crayon/letter/t
	icon_state = "t"
/obj/effect/decal/cleanable/crayon/letter/u
	icon_state = "u"
/obj/effect/decal/cleanable/crayon/letter/v
	icon_state = "v"
/obj/effect/decal/cleanable/crayon/letter/w
	icon_state = "w"
/obj/effect/decal/cleanable/crayon/letter/x
	icon_state = "x"
/obj/effect/decal/cleanable/crayon/letter/y
	icon_state = "y"
/obj/effect/decal/cleanable/crayon/letter/z
	icon_state = "z"

/obj/effect/decal/cleanable/crayon/number
	name = "Number"
	icon_state = "1"

/obj/effect/decal/cleanable/crayon/number/one
	icon_state = "1"
/obj/effect/decal/cleanable/crayon/number/two
	icon_state = "2"
/obj/effect/decal/cleanable/crayon/number/three
	icon_state = "3"
/obj/effect/decal/cleanable/crayon/number/four
	icon_state = "4"
/obj/effect/decal/cleanable/crayon/number/five
	icon_state = "5"
/obj/effect/decal/cleanable/crayon/number/six
	icon_state = "6"
/obj/effect/decal/cleanable/crayon/number/seven
	icon_state = "7"
/obj/effect/decal/cleanable/crayon/number/eight
	icon_state = "8"
/obj/effect/decal/cleanable/crayon/number/nine
	icon_state = "9"
/obj/effect/decal/cleanable/crayon/number/zero
	icon_state = "0"

/obj/effect/decal/cleanable/crayon/punctuation
	name = "Punctuation"
	icon_state = "+"

/obj/effect/decal/cleanable/crayon/punctuation/plus
	icon_state = "+"
/obj/effect/decal/cleanable/crayon/punctuation/minus
	icon_state = "-"
/obj/effect/decal/cleanable/crayon/punctuation/exclaimation
	icon_state = "!"
/obj/effect/decal/cleanable/crayon/punctuation/question
	icon_state = "?"
/obj/effect/decal/cleanable/crayon/punctuation/equal
	icon_state = "="
/obj/effect/decal/cleanable/crayon/punctuation/percent
	icon_state = "%"
/obj/effect/decal/cleanable/crayon/punctuation/and
	icon_state = "&"
/obj/effect/decal/cleanable/crayon/punctuation/comma
	icon_state = ","
/obj/effect/decal/cleanable/crayon/punctuation/period
	icon_state = "."
/obj/effect/decal/cleanable/crayon/punctuation/hash
	icon_state = "#"
/obj/effect/decal/cleanable/crayon/punctuation/slash
	icon_state = "/"
