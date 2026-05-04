/obj/item/keycard/heretic_entrance
	name = "secure storage keycard"
	desc = "A keycard that simply states, basic access."
	color = "#000000"
	puzzle_id = "heretic_gateway0"

/obj/machinery/door/puzzle/keycard/heretic_entrance
	name = "secure airlock"
	puzzle_id = "heretic_gateway0"

/obj/item/keycard/highsec_access
	name = "secure storage keycard"
	desc = "A keycard that simply states, 'only under exteme circumstances'."
	color = "#440000"
	puzzle_id = "heretic_gateway1"

/obj/machinery/door/puzzle/keycard/highsec_access
	name = "secure airlock"
	puzzle_id = "heretic_gateway1"

/obj/item/keycard/cbrn_area
	name = "CBRN storage keycard"
	desc = "A keycard that has a few weird logos and stickers on it all related to biohazards or radiation."
	color = "#80e71f"
	puzzle_id = "heretic_gateway2"

/obj/machinery/door/puzzle/keycard/cbrn_area
	name = "secure airlock"
	puzzle_id = "heretic_gateway2"

/obj/item/keycard/biological_anomalies
	name = "Bio storage keycard"
	desc = "A keycard that looks like the basic access card however it has a biological hazard warning on it."
	color = "#357735"
	puzzle_id = "heretic_gateway3"

/obj/machinery/door/puzzle/keycard/biological_anomalies
	name = "secure airlock"
	puzzle_id = "heretic_gateway3"

/obj/item/keycard/weapon_anomalies
	name = "Weapon storage keycard"
	desc = "A keycard that looks like the basic access card however it has a simple recognizable handgun on it."
	color = "#4b4b4b"
	puzzle_id = "heretic_gateway4"

/obj/machinery/door/puzzle/keycard/weapon_anomalies
	name = "secure airlock"
	puzzle_id = "heretic_gateway4"

/obj/item/keycard/misc_anomalies
	name = "Misc storage keycard"
	desc = "A keycard that looks like the basic access card however it has a staff on it."
	color = "#df2190"
	puzzle_id = "heretic_gateway5"

/obj/machinery/door/puzzle/keycard/misc_anomalies
	name = "secure airlock"
	puzzle_id = "heretic_gateway5"

/obj/item/paper/fluff/awaymissions/heretic
	name = "a hint"
	desc = "This place was designed with many failsafes to keep whats in it safe"

/obj/item/paper/fluff/awaymissions/heretic/floorsafe
	default_raw_text = "<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  +  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li> \
	<li>X  X  X  X  X  X  X  X  X  X</li>"

/obj/item/paper/fluff/awaymissions/heretic/blackroomhint
	default_raw_text = "Hey, one of the high sec guards came through and closed things off and told us to evacuate, they hid the keycard to the facility in this room in its proper spot. If you can read this it should be fine and remember to look into the walls to find the keycard."

/obj/item/paper/fluff/awaymissions/heretic/gravehint
	default_raw_text = "there are rumors around the office that there are a few fake graves in the graveyard down the way that are empty and instead have, insurance- in them whatever that means, Yours truly, Jeramy."

/turf/open/misc/ashplanet/wateryrock/safeair
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/obj/machinery/mass_driver/feeder
	name = "mass driver"
	id = "MASSDRIVER_HERETIC"

/obj/machinery/computer/pod/old/mass_driver_controller/feeder
	id = "MASSDRIVER_HERETIC"
