/obj/decal/ash
	name = "Ashes"
	desc = "Ashes to ashes, dust to dust."
	icon = 'objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/decal/remains/human
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'blood.dmi'
	icon_state = "remains"
	anchored = 1

/obj/decal/remains/xeno
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'blood.dmi'
	icon_state = "remainsxeno"
	anchored = 1

/obj/decal/remains/robot
	name = "remains"
	desc = "These remains have a strange sense about them..."
	icon = 'robots.dmi'
	icon_state = "remainsrobot"
	anchored = 1

/obj/decal/point
	name = "point"
	icon = 'screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1

/obj/decal/cleanable
	var/list/random_icon_states = list()

//HUMANS

/obj/decal/cleanable/blood
	name = "Blood"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = null
	blood_type = null

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/blood/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "Grisly..."
	density = 0
	anchored = 0
	layer = 2
	icon = 'blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

//ALIENS

/obj/decal/cleanable/xenoblood
	name = "xeno blood"
	desc = "It's green."
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

/obj/decal/cleanable/xenoblood/xsplatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/decal/cleanable/xenoblood/xgibs
	name = "xeno gibs"
	desc = "Gnarly..."
	icon = 'blood.dmi'
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")

/obj/decal/cleanable/xenoblood/xgibs/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/decal/cleanable/xenoblood/xgibs/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/decal/cleanable/xenoblood/xgibs/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/decal/cleanable/xenoblood/xgibs/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/decal/cleanable/xenoblood/xgibs/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/decal/cleanable/blood/xtracks
	icon_state = "xtracks"
	random_icon_states = null

//ROBOTS

/obj/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "Useless heap of junk."
	density = 0
	anchored = 0
	layer = 2
	icon = 'robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

/obj/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/decal/cleanable/robot_debris/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup1","gibup1") //2:7 is close enough to 1:4

/obj/decal/cleanable/robot_debris/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown1","gibdown1") //2:7 is close enough to 1:4

/obj/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black."
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

/obj/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

//OTHER

/obj/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'objects.dmi'
	icon_state = "shards"

/obj/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "dirt"

/obj/decal/cleanable/greenglow
	name = "green glow"
	desc = "Eerie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "greenglow"

/obj/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'effects.dmi'
	icon_state = "cobweb1"

/obj/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "huh."
	density = 0
	anchored = 1
	layer = 3
	icon = 'chemical.dmi'
	icon_state = "molten"

/obj/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'effects.dmi'
	icon_state = "cobweb2"

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/decal/spraystill
	density = 0
	anchored = 1
	layer = 50
