/obj/effect/decal/ash
	name = "Ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	icon = 'objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/ash/attack_hand(mob/user as mob)
	usr << "\blue The ashes slip through your fingers."
	del(src)
	return

/obj/effect/decal/remains/human
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'blood.dmi'
	icon_state = "remains"
	anchored = 1

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'blood.dmi'
	icon_state = "remainsxeno"
	anchored = 1

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'robots.dmi'
	icon_state = "remainsrobot"
	anchored = 1

/obj/effect/decal/point
	name = "point"
	icon = 'screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1

/obj/effect/decal/cleanable
	var/list/random_icon_states = list()

//HUMANS

/obj/effect/decal/cleanable/blood
	name = "Blood"
	desc = "It's red and disgusting."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = list()
	var/datum/disease2/disease/virus2 = null
	var/OriginalMob = null

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/mucus
	name = "Mucus"
	desc = "Disgusting mucus."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")
	var/datum/disease2/disease/virus2 = null

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "Grisly...and not the good kind neither."
	density = 0
	anchored = 0
	layer = 2
	icon = 'blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

//ALIENS

/obj/effect/decal/cleanable/xenoblood
	name = "xeno blood"
	desc = "It's green blood. What the hell?"
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	var/list/viruses = list()

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/xenoblood/xsplatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/xenoblood/xgibs
	name = "xeno gibs"
	desc = "Gnarly..."
	icon = 'blood.dmi'
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")

/obj/effect/decal/cleanable/xenoblood/xgibs/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/xenoblood/xgibs/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/xenoblood/xgibs/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/xenoblood/xgibs/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/xenoblood/xgibs/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/xtracks
	icon_state = "xtracks"
	random_icon_states = null

//ROBOTS

/obj/effect/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "Useless heap of junk...or is it..."
	density = 0
	anchored = 0
	layer = 2
	icon = 'robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

/obj/effect/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/robot_debris/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup1","gibup1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/robot_debris/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown1","gibdown1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black oil."
	density = 0
	anchored = 1
	layer = 2
	icon = 'robots.dmi'
	icon_state = "floor1"
	var/viruses = list()
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

//OTHER

/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "dirt"

/obj/effect/decal/cleanable/greenglow
	name = "green glow"
	desc = "Eerie. This makes you feel creepy."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "Huh. Creepy..."
	density = 0
	anchored = 1
	layer = 3
	icon = 'chemical.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'effects.dmi'
	icon_state = "cobweb2"

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	anchored = 1
	layer = 50

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "Vomit"
	desc = "Unpleasant."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	var/list/viruses = list()

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/tomato_smudge
	name = "Tomato smooth"
	desc = "It looks sort of like blood, but it's not that dark."
	density = 0
	anchored = 1
	layer = 2
	icon = 'tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/egg_smudge
	name = "Smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = 2
	icon = 'tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "Smashed pie"
	desc = "Pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/warning_stripes
	icon = 'decal_warning_stripes.dmi'
	layer = 2

/obj/effect/decal/warning_stripes/New()
	..()

	loc.overlays += src
	del src