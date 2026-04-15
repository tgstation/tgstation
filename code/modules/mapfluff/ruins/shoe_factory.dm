/obj/effect/spawner/random/mining_loot/shoe_factory
	name = "random shoe factory loot"
	desc = "Spawns shoes from the loot list. Shoes have a randomized slowdown modifier."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "sneakers"
	loot = list()
	loot_subtype_path = /obj/item/clothing/shoes
	spawn_loot_count = 5
	spawn_scatter_radius = 2
	spawn_random_offset = TRUE

/obj/effect/spawner/random/mining_loot/shoe_factory/make_item(spawn_loc, type_path_to_make)
	var/obj/item/clothing/shoes/shoe = ..()
	if(istype(shoe))
		// shoes will spawn anywhere from -0.5 speed modifer (fast) to +2.0 speed (slow)
		// using dice rolls we can make shoes that make you fast rarer than slow shoes
		// See https://tadeohepperle.com/dice-calculator-frontend/?d1=max(d20,%20d20)%2B3d4 to view dice chances for rolls (higher rolls == faster shoes)
		var/dice = "5d5"
		var/slowdown_modifier = (2 - (roll(dice) * 0.1))
		shoe.slowdown += slowdown_modifier

	return shoe

/obj/item/paper/fluff/ruins/shoe_factory/osha_shutdown
    name = "Official Spess OSHA Closure Notice"
    desc = "A heavily stamped document with a bright red 'CONDEMNED' watermark."
    default_raw_text = "<b>SPESS OCCUPATIONAL SAFETY & HEALTH ADMINISTRATION</b><br><br> \
    <b>ORDER OF IMMEDIATE CLOSURE</b><br><br> \
    Facility 44-S (Footwear Manufacturing Division) is hereby ordered to cease all operations indefinitely pending a Class-A kinetic anomaly investigation.<br><br> \
    <b>Citations:</b><br> \
    <ul> \
    <li><b>Violation 882.A:</b> Extreme deviation in product density. Random inspections reveal that approximately 99% of 'Sprint-Mate' footwear units possess a localized gravitational anomaly. Users report immense physical exertion, equating standard walking to 'dragging an asteroid through wet cement.'</li> \
    <li><b>Violation 882.B:</b> Lethal kinetic acceleration. The remaining 1% of the production line exhibits zero-friction bluespace properties. A OSHA inspector testing a pair was accelerated to 150 km/h into a reinforced plasma glass window, resulting in critical injuries and a localized hull breach.</li> \
    </ul><br> \
    All assets are frozen. Do not attempt to transport the remaining stock. If you must move a crate, DO NOT wear the contents."
