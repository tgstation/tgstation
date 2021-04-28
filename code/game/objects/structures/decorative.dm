/obj/structure/fluff/decorative
	name = "broken decoration"
	desc = "If this showed up, something definitely broke."
	icon = 'icons/obj/decorative.dmi'
	icon_state = "damnit"
	anchored = TRUE
	density = TRUE

///////////////////////////////////////////
/////////////    SHELVES      /////////////
/obj/structure/fluff/decorative/shelf
	name = "shelf"
	desc = "A sturdy wooden shelf to store a variety of items on."
	icon_state = "empty_shelf_1"

/obj/structure/fluff/decorative/shelf/crates
	desc = "A sturdy wooden shelf with a bunch of crates on it."
	icon_state = "shelf_1"

/obj/structure/fluff/decorative/shelf/milkjugs
	desc = "A sturdy wooden shelf with a jugs and cartons of skimmed, semi-skimmed and full fat milk."
	icon_state = "shelf_2"

/obj/structure/fluff/decorative/shelf/alcohol
	desc = "A sturdy wooden shelf with a bunch of probably alcoholic drinks on it."
	icon_state = "shelf_3"

/obj/structure/fluff/decorative/shelf/soda
	desc = "A sturdy wooden shelf with a bunch of soft drinks on it. This planet's version of coca cola?"
	icon_state = "shelf_4"

/obj/structure/fluff/decorative/shelf/soda_multipacks
	desc = "A sturdy wooden shelf with a bunch of multipack soft drinks."
	icon_state = "shelf_5"

/obj/structure/fluff/decorative/shelf/crates1
	desc = "A sturdy wooden shelf with a bunch of crates on it. How... generic?"
	icon_state = "shelf_6"

/obj/structure/fluff/decorative/shelf/soda_milk
	desc = "A sturdy wooden shelf with an assortment of boxes. Multipack soft drinks and some milk."
	icon_state = "shelf_7"

/obj/structure/fluff/decorative/shelf/milk
	desc = "A sturdy wooden shelf with a variety of small milk cartons. Great for those who live alone!"
	icon_state = "shelf_8"

/obj/structure/fluff/decorative/shelf/milk_big
	desc = "A sturdy wooden shelf with lots of larger milk cartons."
	icon_state = "shelf_9"

/obj/structure/fluff/decorative/shelf/alcohol_small
	desc = "A sturdy wooden shelf with lots of alcohol."
	icon_state = "shelf_10"

/obj/structure/fluff/decorative/shelf/alcohol_assortment
	desc = "A sturdy wooden shelf with a variety of branded alcoholic drinks."
	icon_state = "shelf_11"
/////////////    SHELVES      /////////////
///////////////////////////////////////////
/////////////      LADDER     /////////////
// If you're curious to how this works, just put one down and it'll automatically detect ones in the same location above or below it.
/obj/structure/ladder/wood
	name = "wooden ladder"
	desc = "It's kind of fun to go up or down these once in a while."
	icon_state = "ladder"
/////////////      LADDER     /////////////
///////////////////////////////////////////
////////////	WALLMOUNTS    /////////////
/obj/structure/fluff/decorative/wall
	density = FALSE
	layer = OBJ_LAYER

/obj/structure/fluff/decorative/wall/vent
	name = "wall vent"
	desc = "A white noise machine disguised as a wall vent."
	icon_state = "vent1"

/obj/structure/fluff/decorative/wall/vent/alt
	icon_state = "vent2"

/obj/structure/fluff/decorative/wall/vent/small
	icon_state = "vent3"

/obj/structure/fluff/decorative/wall/clock
	name = "clock"
	desc = "Purely aesthetic ever since the implimentation of time-telling nanochips in everyone's brains."
	icon_state = "clock"

/obj/structure/fluff/decorative/wall/clock/examine(mob/user)
	. = ..()
	. += "<span class='info'>Station Time: [station_time_timestamp()]</span>"

/obj/structure/fluff/decorative/wall/clock/north
	pixel_y = 28
/obj/structure/fluff/decorative/wall/clock/east
	pixel_x = 25
/obj/structure/fluff/decorative/wall/clock/south
	pixel_y = -25
/obj/structure/fluff/decorative/wall/clock/west
	pixel_x = -25

/obj/structure/fluff/decorative/wall/toilet
	name = "toilet paper"
	desc = "As much as you'd love to be forced to wipe, it doesn't look like this paper is real."
	icon_state = "toiletholder"

/obj/structure/fluff/decorative/wall/junctionbox
	name = "junction box"
	desc = "Remnants from the station's previous power system. It's useless now."
	icon_state = "junctionbox"

/obj/structure/fluff/decorative/wall/junctionbox/north
	pixel_y = 32
/obj/structure/fluff/decorative/wall/junctionbox/east
	pixel_x = 28
/obj/structure/fluff/decorative/wall/junctionbox/south
	pixel_y = -27
/obj/structure/fluff/decorative/wall/junctionbox/west
	pixel_x = -24

/obj/structure/fluff/decorative/wall/junctionbox/tall
	icon_state = "junctionbox2"

/obj/structure/fluff/decorative/wall/junctionbox/tall/north
	pixel_y = 32
/obj/structure/fluff/decorative/wall/junctionbox/tall/east
	pixel_x = 26
/obj/structure/fluff/decorative/wall/junctionbox/tall/south
	pixel_y = -29
/obj/structure/fluff/decorative/wall/junctionbox/tall/west
	pixel_x = -26

/obj/structure/fluff/decorative/wall/junctionbox/wide
	icon_state = "junctionbox3"

/obj/structure/fluff/decorative/wall/junctionbox/wide/north
	pixel_y = 32
/obj/structure/fluff/decorative/wall/junctionbox/wide/east
	pixel_x = 28
/obj/structure/fluff/decorative/wall/junctionbox/wide/south
	pixel_y = -27
/obj/structure/fluff/decorative/wall/junctionbox/wide/west
	pixel_x = -26

/obj/structure/fluff/decorative/wall/junctionbox/gutted
	desc = "Remnants from the station's previous power system. Looks like someone scavenged the wires."
	icon_state = "junctionbox_open"

/obj/structure/fluff/decorative/wall/junctionbox/gutted/north
	pixel_y = 32
/obj/structure/fluff/decorative/wall/junctionbox/gutted/east
	pixel_x = 28
/obj/structure/fluff/decorative/wall/junctionbox/gutted/south
	pixel_y = -27
/obj/structure/fluff/decorative/wall/junctionbox/gutted/west
	pixel_x = -24

/obj/structure/fluff/decorative/wall/junctionbox/gutted/tall
	icon_state = "junctionbox2_open"

/obj/structure/fluff/decorative/wall/junctionbox/gutted/tall/north
	pixel_y = 32
/obj/structure/fluff/decorative/wall/junctionbox/gutted/tall/east
	pixel_x = 26
/obj/structure/fluff/decorative/wall/junctionbox/gutted/tall/south
	pixel_y = -29
/obj/structure/fluff/decorative/wall/junctionbox/gutted/tall/west
	pixel_x = -26
////////////	WALLMOUNTS    /////////////
///////////////////////////////////////////
////////////	  OBJECTS	  /////////////

/obj/structure/fluff/decorative/skeleton
	name = "skeleton model"
	desc = "AAAAHH!! Oh, wait, it's just a model."
	icon_state = "skeleton_stand"
