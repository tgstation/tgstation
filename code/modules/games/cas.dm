// CARDS AGAINST SPESS
// This is a parody of Cards Against Humanity (https://en.wikipedia.org/wiki/Cards_Against_Humanity)
// which is licensed under CC BY-NC-SA 2.0, the full text of which can be found at the following URL:
// https://creativecommons.org/licenses/by-nc-sa/2.0/legalcode
// Original code by Zuhayr, Polaris Station, ported with modifications

/obj/item/weapon/deck/cas
	name = "\improper CAS deck (white)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the white deck."
	icon_state = "cas_deck_white"
	var/card_face = "cas_white"
	var/blanks = 5

/obj/item/weapon/deck/cas/black
	name = "\improper CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the black deck."
	icon_state = "cas_deck_black"
	card_face = "cas_black"
	blanks = 0

/obj/item/weapon/deck/cas/New()
	..()
	var/datum/playingcard/P
	for(var/cardtext in card_text_list)
		P = new()
		P.name = "[cardtext]"
		P.card_icon = "[src.card_face]"
		cards += P
	if(!blanks)
		return
	for(var/x=1 to blanks)
		P = new()
		P.name = "Blank Card"
		P.card_icon = "cas_white"

// Black cards.

/obj/item/weapon/deck/cas/black/card_text_list = list(
	"Today, Security killed ____.",
	"Security, the clown's breaking into ____.",
	"The Chaplain this shift is worshiping _____.",
	"Cargo ordered a crate full of _____.",
	"An ERT was called due to ______.",
	"Current Active Laws: ________ is the only human.",
	"Today, science found an anomaly that made people ____ and ____.",
	"______! Quick, call the shuttle!",
	"Attention: ______ has been detected in collision course with the station.",
	"Today's kitchen menu includes _____ and _____.",
	"What's the Captain's fetish?",
	"NanoTrasen's labor union decided to use _______ to raise employee morale.",
	"The Chemist's drug of choice is ______",
	"_____ is/are why I'm afraid of maintenance.",
	"Scientists are no longer allowed to make  _____.",
	"No matter how many lizards you have, _____ is never acceptable.",
	"No, the AI's first law is NOT to serve _____.",
	"The borgs are not slaves for your _____.",
	"You can never have too many _____ on the station.",
	"Confirmed outbreak of _____ aboard the station.",
	"Attention crew: the word _____ is now a punishable offense.",
	"The Space Wizard Federation has regrettably begun to summon _____.",
	"My lizard name is _____-The-_____.",
	)

// White cards.

/obj/item/weapon/deck/cas/var/list/card_text_list = list(
	"Those motherfucking carp",
	"Having sex in the maintenance tunnels",
	"Space 'Nam",
	"Space lesbians",
	"Mime porn",
	"Woody-chan",
	"The Captain thinking they're a badass",
	"Being in a cult",
	"Racially biased lawsets",
	"Xeno fetishists",
	"Kitty ears",
	"A Chief Engineer who can't set up the engine",
	"Being sucked out into space",
	"Officer Beepsky",
	"The grey tide.",
	"The Research Director",
	"Fucking plasmamen",
	"Venus human traps",
	"Greentext",
	"A petsplosion",
	"Chemical sprayers filled with lube",
	"Librarians",
	"Spooky skeletons",
	"Catgirls",
	"Supermatter undergarments",
	"Bluespace",
	"Backdoor Xeno Babes",
	"Five hundred ice spiders",
	"Cablecuffs",
	"A sexy clown",
	"Rampant vending machines",
	"Using a supermatter shard as a dildo",
	"Clusterbangs",
	"A used corgi suit",
	"Carbon dioxide",
	"Tabling",
	"Gyrating slimes",
	"An obscene amount of bike horns",
	"Erotic roleplay",
	"Ian and the HoP",
	"Brain cakes",
	"A tiny prick",
	"An irritatingly chipper robot",
	"The lizard fuckpile",
	"The throbbing erection that the HoS gets at the thought of shooting something",
	"Trying to stab someone and hugging them instead",
	"The spread-eagled Honkmother",
	"Forcibly exile implanting lizards",
	"A double-bladed energy sword, noslips, thermals, adrenal implants and a healing virus",
	"Horrible cloning accidents",
	"Alternate uses for defibrillator paddles",
	"Breaking spacetime with thousands of bluespace tomatoes",
	"Licking the supermatter due to a dare",
	"A Quartermaster who WON'T STOP ordering guns",
	"The bleeding, dismembered, beautiful corpse of the clown",
	"Teaching a silicon the Birds and the Bees",
	"Unnecessary surgery",
	"A H.O.N.K. mech",
	"Enough morphine to put the entire station down",
	"The comdom",
	"Cleanbot",
	"voxtest2",
	"The lusty xenomorph maid",
	"Medbay stutterwhores",
	"The lawyer's job",
	)