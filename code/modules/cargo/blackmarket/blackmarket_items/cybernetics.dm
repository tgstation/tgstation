

// CYBERLINKS

/datum/blackmarket_item/cyberlinks
	category = "Cybernetics"
	markets = list(/datum/blackmarket_market/cybernetics)
	root = /datum/blackmarket_item/cyberlinks

/datum/blackmarket_item/cyberlinks/nt_low
	name = "Nanotrasen's Basic Cyberlink Package"
	desc = "We honestly have no clue why you are trying to purchase these off of us, but if you are willing to buy, we are willing to sell."
	item = /obj/item/organ/cyberimp/cyberlink/nt_low
	availability_prob = 60
	stock_min = 2
	stock_max = 5
	price_min = 200
	price_max = 400

/datum/blackmarket_item/cyberlinks/nt_high
	name = "Nanotrasen's Advanced Cyberlink Package"
	desc = "More advanced form of NT cyberlink, allows for more implants, but may require some hacking to make older implants compatible with this."
	item = /obj/item/organ/cyberimp/cyberlink/nt_high
	availability_prob = 40
	stock_min = 1
	stock_max = 2
	price_min = 300
	price_max = 600

/datum/blackmarket_item/cyberlinks/terragov
	name = "Terragov Integrated Cybernetic Managment System"
	desc = "Quite rare around this part of the galaxy, allows unrestricted connection to all of Terragov's implants, we don't guarantee it will work with any other cybernetic tough."
	item = /obj/item/organ/cyberimp/cyberlink/terragov
	availability_prob = 15
	price_min = 700
	price_max = 1000

/datum/blackmarket_item/cyberlinks/syndicate
	name = "Interdyne Cybernetic Operating Bioware"
	desc = "A very rare cyberlink, used only by interdyne politicians, and other syndicate assault teams. Very rare find."
	item = /obj/item/organ/cyberimp/cyberlink/syndicate
	availability_prob = 5
	price_min = 1000
	price_max = 1200

/// CYBERNETICS

/datum/blackmarket_item/cybernetics
	category = "Cybernetics"
	markets = list(/datum/blackmarket_market/cybernetics)
	root = /datum/blackmarket_item/cybernetics
	stock = 1 //Can never have more than 1 of the same implant on the auction at the same time.
	var/randomizable = TRUE

/datum/blackmarket_item/cybernetics/spawn_item(loc)
	. = ..()
	var/obj/item/organ/cyberimp/implant = .
	if(prob(30) && randomizable)
		implant.random_encode()

// LEGS

/datum/blackmarket_item/cybernetics/table_glider
	name = "Table-gliding cybernetic"
	desc = "Works like a charm, can get you up any table in a second, don't ask if you can also quickly get down, we are still figuring that part out."
	item = /obj/item/organ/cyberimp/leg/table_glider
	availability_prob = 20
	stock = 2 // ok, ok these require 2 implants on each leg to work
	price_min = 200
	price_max = 400

/datum/blackmarket_item/cybernetics/shove_resist
	name = "BU-TAM resistor cybernetic"
	desc = "This bad boy roots you in ground whenever you get shoved, doesn't come with muscle actuators so your legs will get tired after a while."
	item = /obj/item/organ/cyberimp/leg/shove_resist
	availability_prob = 15
	stock = 2 // ok, ok these require 2 implants on each leg to work
	price_min = 300
	price_max = 600

/datum/blackmarket_item/cybernetics/accelerator
	name = "P.R.Y.Z.H.O.K. accelerator cybernetic"
	desc = "Advanced russian implant that allows you to tackle people without special gloves or training, very rare to aquire these as TerraGov has cracked down on the sales."
	item = /obj/item/organ/cyberimp/leg/accelerator
	availability_prob = 10
	stock = 2 // ok, ok these require 2 implants on each leg to work
	price_min = 400
	price_max = 800

/datum/blackmarket_item/cybernetics/chemplant_drug
	name = "deep-vein emergency morale rejuvenator"
	desc = "Interdyne Pharmaceutic's cybernetic that was recenetly 'legally' aquired by us, now we are willing to sell a one of these bad boys to anyone in need of some rejuvenation!"
	item = /obj/item/organ/cyberimp/leg/chemplant/drugs
	availability_prob = 10
	price_min = 500
	price_max = 1000

/datum/blackmarket_item/cybernetics/chemplant_emergency
	name = "deep emergency chemical infuser"
	desc = "Nanotrasens attempt at recreating Interdyne's success with in-leg chemical cybernetics. This implant will inject you with healing chemicals given the situation is dire."
	item = /obj/item/organ/cyberimp/leg/chemplant/emergency
	availability_prob = 20
	price_min = 400
	price_max = 800

/datum/blackmarket_item/cybernetics/chemplant_rage
	name = "R.A.G.E. chemical system"
	desc = "An implant created by Terragov scientists, later modified by their prison warden's to serve as both a torture tool and a last-stand implant by their military."
	item = /obj/item/organ/cyberimp/leg/chemplant/rage
	availability_prob = 10
	price_min = 700
	price_max = 1000

/// ARMS

/datum/blackmarket_item/cybernetics/medibeam
	name = "medibeam toolset cybernetic"
	desc = "An old design of a medibeam used by terragov doctors in dire situations, very rare."
	item = /obj/item/organ/cyberimp/arm/item_set/medibeam
	availability_prob = 10
	price_min = 1200
	price_max = 2200

/datum/blackmarket_item/cybernetics/laser
	name = "in-built laser cybernetic"
	desc = "Laser implant of Terran design, used by their high-ranking officers."
	item = /obj/item/organ/cyberimp/arm/item_set/gun/laser
	availability_prob = 5
	price_min = 1200
	price_max = 2200

/datum/blackmarket_item/cybernetics/toolset
	name = "integrated toolset implant"
	desc = "Doesn't NT produce those en masse? Oh well, if you are willing to buy, we are willing to sell."
	item = /obj/item/organ/cyberimp/arm/item_set/toolset
	availability_prob = 25
	price_min = 300
	price_max = 800

/datum/blackmarket_item/cybernetics/flash
	name = "integrated high-intensity photon projector"
	desc = "Can be quite handy, especially since it is quite literally, built into your hand."
	item = /obj/item/organ/cyberimp/arm/item_set/flash
	availability_prob = 20
	price_min = 600
	price_max = 800

/datum/blackmarket_item/cybernetics/surgery
	name = "surgery toolset cybernetic"
	desc = "Doesn't NT produce those en masse? Oh well, if you are willing to buy, we are willing to sell."
	item = /obj/item/organ/cyberimp/arm/item_set/surgery
	availability_prob = 25
	price_min = 300
	price_max = 800

/datum/blackmarket_item/cybernetics/cook
	name = "cooking toolset cybernetic"
	desc = "Useful for extra-fast cooking."
	item = /obj/item/organ/cyberimp/arm/item_set/cook
	availability_prob = 25
	price_min = 300
	price_max = 500

/datum/blackmarket_item/cybernetics/janitor
	name = "janitorial toolset cybernetic"
	desc = "Useful for extra-fast cleaning."
	item = /obj/item/organ/cyberimp/arm/item_set/janitor
	availability_prob = 25
	price_min = 300
	price_max = 500

/datum/blackmarket_item/cybernetics/detective
	name = "detective's toolset cybernetic"
	desc = "Catch crime! Fast!"
	item = /obj/item/organ/cyberimp/arm/item_set/detective
	availability_prob = 15
	price_min = 600
	price_max = 700

/datum/blackmarket_item/cybernetics/chemical
	name = "chemical toolset cybernetic"
	desc = "Useful for extra-fast research."
	item = /obj/item/organ/cyberimp/arm/item_set/chemical
	availability_prob = 25
	price_min = 300
	price_max = 500

/datum/blackmarket_item/cybernetics/atmos
	name = "atmos toolset cybernetic"
	desc = "Useful for extra-fast firefighting."
	item = /obj/item/organ/cyberimp/arm/item_set/atmospherics
	availability_prob = 25
	price_min = 300
	price_max = 500

/datum/blackmarket_item/cybernetics/tablet
	name = "inbuilt tablet implant"
	desc = "These come in very handy, since you can use them wherever and instead of sitting in your backpack, they are inside of your hand!"
	item = /obj/item/organ/cyberimp/arm/item_set/tablet
	availability_prob = 30
	stock_min = 1
	stock_max = 4
	price_min = 200
	price_max = 500

/datum/blackmarket_item/cybernetics/hack
	name = "universal connection implant"
	desc = "Allows for direct connection between your brain, the cyberlink and the implant's firmware, allowing you to change protocols to make them compatible with your cyberlink."
	item = /obj/item/organ/cyberimp/arm/item_set/connector
	availability_prob = 95
	stock_min = 1
	stock_max = 4
	price_min = 250
	price_max = 1000

/datum/blackmarket_item/cybernetics/ammo_counter
	name = "S.M.A.R.T. ammo logistics system"
	desc = "Created by Nanotrasen's scientist's and used by their high-command. Very useful if you don't want to examine your gun every few seconds."
	item = /obj/item/organ/cyberimp/arm/ammo_counter
	availability_prob = 10
	price_min = 500
	price_max = 1000

/datum/blackmarket_item/cybernetics/heater
	name = "sub-dermal heating implant"
	desc = "Helps you stabilize your temperature, extra useful for those filthy lizards, I wonder if they made this thing?"
	item = /obj/item/organ/cyberimp/arm/heater
	availability_prob = 25
	price_min = 100
	price_max = 500

/datum/blackmarket_item/cybernetics/cooler
	name = "sub-dermal cooling implant"
	desc = "Helps you stabilize your temperature, extra useful for those filthy lizards, I wonder if they made this thing?"
	item = /obj/item/organ/cyberimp/arm/cooler
	availability_prob = 25
	price_min = 100
	price_max = 500

/datum/blackmarket_item/cybernetics/filter
	name = "S.I.L.V.E.R. filtration pump"
	desc = "Another major success of Interdyne, this time this blood pump will filter out all harmful substances from your system."
	item = /obj/item/organ/cyberimp/chest/filtration
	availability_prob = 10
	price_min = 800
	price_max = 1000

/datum/blackmarket_item/cybernetics/filter_offbrand
	name = "offbrand filtration pump"
	desc = "An offbrand version of Interdyne's filtration pump, god I hope this one works."
	item = /obj/item/organ/cyberimp/chest/filtration/offbrand
	availability_prob = 20
	price_min = 200
	price_max = 400

/datum/blackmarket_item/cybernetics/sensors
	name = "Interdyne Sensor Field Visualizer"
	desc = "Makes you see sensor signals from nearby dead crew that had the sensors turned to Tracking Beacon. Very useful, just a note, this uses Terran firmware for some reason."
	item = /obj/item/organ/cyberimp/eyes/hud/sensor
	availability_prob = 10
	price_min = 600
	price_max = 1000

/datum/blackmarket_item/cybernetics/mantis
	name = "C.H.R.O.M.A.T.A. cybernetic mantis blades"
	desc = "Powerful blades, first developed on earth, they fit right under your Humerus, and can be sprung into actions in just miliseconds."
	item = /obj/item/organ/cyberimp/arm/item_set/mantis
	availability_prob = 10
	price_min = 1200
	price_max = 1800
