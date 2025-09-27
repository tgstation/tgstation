/datum/market_item/misc
	category = "Miscellaneous"
	abstract_path = /datum/market_item/misc

/datum/market_item/misc/clear_pda
	name = "Clear PDA"
	desc = "Show off your style with this limited edition clear PDA!."
	item = /obj/item/modular_computer/pda/clear

	price_min = CARGO_CRATE_VALUE * 1.25
	price_max = CARGO_CRATE_VALUE *3
	stock_max = 2
	availability_prob = 50

/datum/market_item/misc/jade_lantern
	name = "Jade Lantern"
	desc = "Found in a box labeled 'Danger: Radioactive'. Probably safe."
	item = /obj/item/flashlight/lantern/jade

	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE * 2.5
	stock_max = 2
	availability_prob = 45

/datum/market_item/misc/cap_gun
	name = "Cap Gun"
	desc = "Prank your friends with this harmless gun! Harmlessness guaranteed."
	item = /obj/item/toy/gun

	price_min = CARGO_CRATE_VALUE * 0.25
	price_max = CARGO_CRATE_VALUE
	stock_max = 6
	availability_prob = 80

/datum/market_item/misc/shoulder_holster
	name = "Shoulder holster"
	desc = "Yeehaw, hardboiled friends! This holster is the first step in your dream of becoming a detective and being allowed to shoot real guns!"
	item = /obj/item/storage/belt/holster

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 8
	availability_prob = 60

/datum/market_item/misc/donk_recycler
	name = "MOD Riot Foam Dart Recycler Module"
	desc = "If you love toy guns, hate cleaning and got a MODsuit, this module is a must-have."
	item = /obj/item/mod/module/recycler/donk
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4.5
	stock_max = 2
	availability_prob = 30

/datum/market_item/misc/atrocinator
	name = "MOD Anti-Gravity Module"
	desc = "We found this module in a maintenance tunnel, behind several warning cones and hazard signs, unlabeled. It's probably safe."
	item = /obj/item/mod/module/atrocinator
	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 7
	stock_max = 1
	availability_prob = 22

/datum/market_item/misc/tanner
	name = "MOD Tanning Module"
	desc = "Ever wanted to be at the beach AND at work? Now you can with this snazzy tanning module!"
	item = /obj/item/mod/module/tanner
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 2
	availability_prob = 30

/datum/market_item/misc/hat_stabilizer
	name = "MOD Hat Stabilizer Module"
	desc = "Don't sacrifice style for substance with this module! Hats not included."
	item = /obj/item/mod/module/hat_stabilizer
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 2
	availability_prob = 35

/datum/market_item/misc/shove_blocker
	name = "MOD Bulwark Module"
	desc = "You have no idea how much effort it took us to extract this module from that damn safeguard MODsuit last shift."
	item = /obj/item/mod/module/shove_blocker
	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 5.75
	stock_max = 1
	availability_prob = 25

/datum/market_item/misc/holywater
	name = "Flask of holy water"
	desc = "Father Lootius' own brand of ready-made holy water."
	item = /obj/item/reagent_containers/cup/glass/bottle/holywater

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 3
	availability_prob = 40

/datum/market_item/misc/holywater/spawn_item(loc, datum/market_purchase/purchase)
	if (prob(6.66))
		item = /obj/item/reagent_containers/cup/beaker/unholywater
	else
		item = initial(item)
	return ..()

/datum/market_item/misc/strange_seed
	name = "Strange Seeds"
	desc = "An Exotic Variety of seed that can contain anything from glow to acid."
	item = /obj/item/seeds/random

	price_min = CARGO_CRATE_VALUE * 1.6
	price_max = CARGO_CRATE_VALUE * 1.8
	stock_min = 2
	stock_max = 5
	availability_prob = 50

/datum/market_item/misc/smugglers_satchel
	name = "Smuggler's Satchel"
	desc = "This easily hidden satchel can become a versatile tool to anybody with the desire to keep certain items out of sight and out of mind. Its contents cannot be detected by contraband scanners."
	item = /obj/item/storage/backpack/satchel/flat/empty

	price_min = CARGO_CRATE_VALUE * 3.75
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 30

/datum/market_item/misc/roulette
	name = "Roulette Beacon"
	desc = "Start your own underground casino, wherever you go. One use only. No refunds."
	item = /obj/item/roulette_wheel_beacon
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 2.5
	stock_max = 3
	availability_prob = 50

/datum/market_item/misc/jawed_hook
	name = "Jawed Fishing Hook"
	desc = "The thing ya use if y'are strugglin' with fishes. Just remember to whoop yer rod before it's too late, 'cause this thing's gonna hurt them like an Arkansas toothpick."
	item = /obj/item/fishing_hook/jaws
	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 3
	availability_prob = 70

/datum/market_item/misc/v8_engine
	name = "Genuine V8 Engine (Perserved)"
	desc = "Hey greasemonkeys, you ready to start those engines? Want to start racing through the halls and making some tighter turns on the interstellar beltway? Then you need this classic engine."
	item = /obj/item/v8_engine
	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 6
	stock_max = 1
	availability_prob = 15

/datum/market_item/misc/fishing_capsule
	name = "Fishing Spot Capsule"
	//IUU stands for Illegal Unreported and Unregulated fishing. Ironic.
	desc = "A repurposed mining capsule connected to a selection of exclusive fishing spots. Approved by the Intergalactic IUU Fishing Association."
	price_min = CARGO_CRATE_VALUE * 1.125
	price_max = CARGO_CRATE_VALUE * 2.125
	item = /obj/item/survivalcapsule/fishing
	stock_min = 1
	stock_max = 4
	availability_prob = 80

/datum/market_item/misc/fish
	name = "Fish"
	desc = "Fish! Fresh fish! Fish you can cut, grind and even keep in aquarium if you want to! Get some before the next fight at my village breaks out!"
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.2
	item = /obj/item/storage/fish_case/blackmarket
	stock_min = 3
	stock_max = 8
	availability_prob = 90

/datum/market_item/misc/girlypop
	name = "Girlypop Posters"
	desc = "A collection of cute and adorable posters. Girl power!"
	price_min = PAYCHECK_CREW * 2
	price_max = PAYCHECK_CREW * 5
	item = /obj/item/poster/contraband/heart // gives it the rolled poster icon in the menu
	stock_min = 1
	stock_max = 3
	availability_prob = 90

/datum/market_item/misc/girlypop/spawn_item(loc, datum/market_purchase/purchase)
	. = ..()
	var/obj/structure/closet/crate/glitter/C = new(loc)
	for (var/type in list(
		/obj/item/poster/contraband/dream,
		/obj/item/poster/contraband/beekind,
		/obj/item/poster/contraband/heart,
		/obj/item/poster/contraband/dolphin,
		/obj/item/poster/contraband/principles,
		/obj/item/poster/contraband/trigger,
		/obj/item/poster/contraband/barbaro,
		/obj/item/poster/contraband/seabiscuit,
		/obj/item/poster/contraband/pharlap,
		/obj/item/poster/contraband/waradmiral,
		/obj/item/poster/contraband/silver,
		/obj/item/poster/contraband/jovial,
		/obj/item/poster/contraband/bojack,
	))
		new type(C)
	return C

/datum/market_item/misc/self_surgery_skillchip
	name = /obj/item/skillchip/self_surgery::name
	desc = "Man, the insurance companies HATE this one. Damn fat-cats can't stand the idea of people treating their own illnesses - \
	they'd rather you go to THEIR doctors, who THEY convinced to charge EXTORTIONARY prices the average Joe can't afford, all so you \
	gotta sign on to THEIR packages. Most people end up paying for NOTHING for YEARS just so that they have a CHANCE at being able to afford \
	treatment when they actually NEED it. \n\n Uh, what was I talking about again... Oh, yeah. This here skillchip'll let you put yourself under the knife. \
	A must-have for the person who can't rely on anyone else."
	item = /obj/item/skillchip/self_surgery
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 10
	stock_max = 1
	availability_prob = 15

/datum/market_item/misc/self_surgery_skillchip/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method, legal_status)
	. = ..()
	if(.)
		availability_prob *= 0.5
