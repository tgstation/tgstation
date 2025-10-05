/obj/structure/billboard
	name = "blank billboard"
	desc = "A blank billboard, with space for all kinds of advertising."
	icon = 'icons/obj/fluff/billboard.dmi'
	icon_state = "billboard_blank"
	plane = ABOVE_GAME_PLANE
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/billboard/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_BILLBOARD)

/obj/structure/billboard/donk_n_go
	name = "\improper Donk-n-Go billboard"
	desc = "A billboard advertising Donk-n-Go, Donk Co's ever-present and ever-unhealthy fast-food venture: GET IN, GET FED, GET GONE!"
	icon_state = "billboard_donk_n_go"

/obj/structure/billboard/space_cola
	name = "\improper Space Cola billboard"
	desc = "A billboard advertising Space Cola: Relax, have a Spoke."
	icon_state = "billboard_space_cola"

/obj/structure/billboard/nanotrasen
	name = "\improper Nanotrasen billboard"
	desc = "A billboard advertising Nanotrasen: A Better Tomorrow, Today."
	icon_state = "billboard_nanotrasen"

/obj/structure/billboard/nanotrasen/defaced
	name = "defaced Nanotrasen billboard"
	desc = "A billboard advertising Nanotrasen. Someone's sprayed a message onto it: Fuck Corpo Pigs."
	icon_state = "billboard_fuck_corps"

/obj/structure/billboard/azik
	name = "\improper Azik Interstellar billboard"
	desc = "A billboard advertising Azik Interstellar and their newest model: the Autocrat Solar Sailer. Azik Interstellar: Tiziran Refinement for Galactic Necessities."
	icon_state = "billboard_azik"

/obj/structure/billboard/cvr
	name = "\improper Charlemagne von Rheinland billboard"
	desc = "A billboard advertising Charlemagne von Rheinland's Germania-class superyacht. Charlemagne von Rheinland: Die Werft der Könige."
	icon_state = "billboard_cvr"

/obj/structure/billboard/twenty_four_seven
	name = "\improper 24-Seven billboard"
	desc = "A billboard advertising 24-Seven's new range of limited-edition Slushee flavours. 24-Seven: All Day, Every Day."
	icon_state = "billboard_twenty_four_seven"

/obj/structure/billboard/starway
	name = "\improper Starway Transit billboard"
	desc = "A billboard advertising Starway Transit's direct flight from New Moscow to New York: only 2000 credits for an economy class berth. Starway: Your Ticket to the Stars."
	icon_state = "billboard_starway"

/obj/structure/billboard/lizards_gas
	name = "\improper The Lizard's Gas billboard"
	desc = "A billboard labelling the gas station known as 'The Lizard's Gas'. It's been lost to time, and this is the only known gas station of its type. It's hard to see why it flopped based on the quality of the billboard."
	icon_state = "billboard_lizards_gas"

/obj/structure/billboard/lizards_gas/defaced
	desc = "A billboard labelling the gas station known as 'The Lizard's Gas'. The soulfully drawn billboard has been graffitied, with a kind stranger painting over the vitriolic graffiti."
	icon_state = "billboard_lizards_gas_defaced"

/obj/structure/billboard/roadsign
	name = "\improper Roadsign billboard"
	desc = "A billboard notifying the reader how many miles are left until the gas station. This one seems to be blank, however."
	icon_state = "billboard_roadsign_blank"

/obj/structure/billboard/roadsign/two
	desc = "A billboard notifying the reader how many miles are left until the next gas station. It's hard to see a purpose for this sign at all."
	icon_state = "billboard_roadsign_two"

/obj/structure/billboard/roadsign/twothousand
	desc = "A billboard notifying the reader how many miles are left until the next gas station. You'll probably want to stock up on food and gas if you see something like this."
	icon_state = "billboard_roadsign_twothousand"

/obj/structure/billboard/roadsign/twomillion
	desc = "A billboard notifying the reader how many miles are left until the next gas station. If you're capable of multi-million-mile travel, this shouldn't be a sweat! If you aren't..."
	icon_state = "billboard_roadsign_twomillion"

/obj/structure/billboard/roadsign/error
	desc = "A billboard notifying the reader how many miles are left until the next gas station. This is a static sign, so you have to wonder what sort of person would both print this and then hang it up."
	icon_state = "billboard_roadsign_error"

/obj/structure/billboard/smoothies
	name = "\improper Spinward Smoothies billboard"
	desc = "A billboard advertising Spinward Smoothies."
	icon_state = "billboard_smoothies"

/obj/structure/billboard/fortune_telling
	name = "\improper Fortune Teller billboard"
	desc = "A billboard advertising Fortune Telling. Apparently it's done by real psykers!"
	icon_state = "billboard_fortune_tell"

/obj/structure/billboard/Phone_booth
	name = "\improper Holophone Billboard"
	desc = "A billboard advertising Holophones. Interstellar calls for a affordable 49.99 credits with duty free snacks!"
	icon_state = "billboard_phone"

/obj/structure/billboard/american_diner
	name = "\improper All-American Diner billboard"
	desc = "A billboard advertising an old-school 1950's themed restaurant franchise \"All-American Diner\""
	icon_state = "billboard_american_diner"

/obj/structure/billboard/gloves
	name = "\improper RoroCo Gloves billboard"
	desc = "A billboard advertising RoroCo, a manufacturer of insulated gloves and insulated glove accessories. Features the company's loveable mascot Roro."
	icon_state = "billboard_gloves"
