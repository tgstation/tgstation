/*
Recurring extracts:
	Generates a new charge every few seconds.
	If depleted of its' last charge, stops working.
*/
/obj/item/slimecross/recurring
	name = "recurring extract"
	desc = "A tiny, glowing core, wrapped in several layers of goo."
	effect = "recurring"
	icon_state = "recurring"
	var/extract_type
	var/obj/item/slime_extract/extract
	var/cooldown = 0
	var/max_cooldown = 10 // In seconds

/obj/item/slimecross/recurring/Initialize(mapload)
	. = ..()
	extract = new extract_type(src.loc)
	visible_message(span_notice("[src] wraps a layer of goo around itself!"))
	extract.name = name
	extract.desc = desc
	extract.icon = icon
	extract.icon_state = icon_state
	extract.color = color
	extract.recurring = TRUE
	src.forceMove(extract)
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/recurring/process(seconds_per_tick)
	if(cooldown > 0)
		cooldown -= seconds_per_tick
	else if(extract.Uses < 10 && extract.Uses > 0)
		extract.Uses++
		cooldown = max_cooldown
	else if(extract.Uses <= 0)
		extract.visible_message(span_warning("The light inside [extract] flickers and dies out."))
		extract.desc = "A tiny, inert core, bleeding dark, cerulean-colored goo."
		extract.icon_state = "prismatic"
		qdel(src)

/obj/item/slimecross/recurring/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj,src)

/obj/item/slimecross/recurring/grey
	extract_type = /obj/item/slime_extract/grey
	colour = SLIME_TYPE_GREY

/obj/item/slimecross/recurring/orange
	extract_type = /obj/item/slime_extract/orange
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/recurring/purple
	extract_type = /obj/item/slime_extract/purple
	colour = SLIME_TYPE_PURPLE

/obj/item/slimecross/recurring/blue
	extract_type = /obj/item/slime_extract/blue
	colour = SLIME_TYPE_BLUE

/obj/item/slimecross/recurring/metal
	extract_type = /obj/item/slime_extract/metal
	colour = SLIME_TYPE_METAL
	max_cooldown = 20

/obj/item/slimecross/recurring/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = SLIME_TYPE_YELLOW
	max_cooldown = 20

/obj/item/slimecross/recurring/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	max_cooldown = 20

/obj/item/slimecross/recurring/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/item/slimecross/recurring/silver
	extract_type = /obj/item/slime_extract/silver
	colour = SLIME_TYPE_SILVER

/obj/item/slimecross/recurring/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = SLIME_TYPE_BLUESPACE

/obj/item/slimecross/recurring/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = SLIME_TYPE_SEPIA
	max_cooldown = 36 //No infinite timestop for you!

/obj/item/slimecross/recurring/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = SLIME_TYPE_CERULEAN

/obj/item/slimecross/recurring/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = SLIME_TYPE_PYRITE

/obj/item/slimecross/recurring/red
	extract_type = /obj/item/slime_extract/red
	colour = SLIME_TYPE_RED

/obj/item/slimecross/recurring/green
	extract_type = /obj/item/slime_extract/green
	colour = SLIME_TYPE_GREEN

/obj/item/slimecross/recurring/pink
	extract_type = /obj/item/slime_extract/pink
	colour = SLIME_TYPE_PINK

/obj/item/slimecross/recurring/gold
	extract_type = /obj/item/slime_extract/gold
	colour = SLIME_TYPE_GOLD
	max_cooldown = 30

/obj/item/slimecross/recurring/oil
	extract_type = /obj/item/slime_extract/oil
	colour = SLIME_TYPE_OIL //Why would you want this?

/obj/item/slimecross/recurring/black
	extract_type = /obj/item/slime_extract/black
	colour = SLIME_TYPE_BLACK

/obj/item/slimecross/recurring/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = SLIME_TYPE_LIGHT_PINK

/obj/item/slimecross/recurring/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	max_cooldown = 20

/obj/item/slimecross/recurring/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = SLIME_TYPE_RAINBOW
	max_cooldown = 40 //It's pretty powerful.
