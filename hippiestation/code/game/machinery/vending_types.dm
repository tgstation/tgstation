/*

CLOTHESMATE

*/

/obj/machinery/vending/clothing
	name = "ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the ClothesMate!"
	vend_reply = "Thank you for using the ClothesMate!"
	height = 750
	refill_canister = /obj/item/weapon/vending_refill/clothing
	products = list(
		/obj/item/clothing/head/that=2,
		/obj/item/clothing/head/fedora=1,
		/obj/item/clothing/glasses/monocle=1,
		/obj/item/clothing/suit/jacket=2,
		/obj/item/clothing/suit/jacket/puffer/vest=2,
		/obj/item/clothing/suit/jacket/puffer=2,
		/obj/item/clothing/under/suit_jacket/navy=1,
		/obj/item/clothing/under/suit_jacket/really_black=1,
		/obj/item/clothing/under/suit_jacket/burgundy=1,
		/obj/item/clothing/under/suit_jacket/charcoal=1,
		/obj/item/clothing/under/suit_jacket/white=1,
		/obj/item/clothing/under/kilt=1,
		/obj/item/clothing/under/overalls=1,
		/obj/item/clothing/under/sl_suit=1,
		/obj/item/clothing/under/pants/jeans=3,
		/obj/item/clothing/under/pants/classicjeans=2,
		/obj/item/clothing/under/pants/camo = 1,
		/obj/item/clothing/under/pants/blackjeans=2,
		/obj/item/clothing/under/pants/khaki=2,
		/obj/item/clothing/under/pants/white=2,
		/obj/item/clothing/under/pants/red=1,
		/obj/item/clothing/under/pants/black=2,
		/obj/item/clothing/under/pants/tan=2,
		/obj/item/clothing/under/pants/track=1,
		/obj/item/clothing/suit/jacket/miljacket = 1,
		/obj/item/clothing/neck/tie/blue=1,
		/obj/item/clothing/neck/tie/red=1,
		/obj/item/clothing/neck/tie/black=1,
		/obj/item/clothing/neck/tie/horrible=1,
		/obj/item/clothing/neck/scarf/red=1,
		/obj/item/clothing/neck/scarf/green=1,
		/obj/item/clothing/neck/scarf/darkblue=1,
		/obj/item/clothing/neck/scarf/purple=1,
		/obj/item/clothing/neck/scarf/yellow=1,
		/obj/item/clothing/neck/scarf/orange=1,
		/obj/item/clothing/neck/scarf/cyan=1,
		/obj/item/clothing/neck/scarf=1,
		/obj/item/clothing/neck/scarf/black=1,
		/obj/item/clothing/neck/scarf/zebra=1,
		/obj/item/clothing/neck/scarf/christmas=1,
		/obj/item/clothing/neck/stripedredscarf=1,
		/obj/item/clothing/neck/stripedbluescarf=1,
		/obj/item/clothing/neck/stripedgreenscarf=1,
		/obj/item/clothing/tie/waistcoat=1,
		/obj/item/clothing/under/skirt/black=1,
		/obj/item/clothing/under/skirt/blue=1,
		/obj/item/clothing/under/skirt/red=1,
		/obj/item/clothing/under/skirt/purple=1,
		/obj/item/clothing/under/sundress=2,
		/obj/item/clothing/under/stripeddress=1,
		/obj/item/clothing/under/sailordress=1,
		/obj/item/clothing/under/redeveninggown=1,
		/obj/item/clothing/under/blacktango=1,
		/obj/item/clothing/under/plaid_skirt=1,
		/obj/item/clothing/under/plaid_skirt/blue=1,
		/obj/item/clothing/under/plaid_skirt/purple=1,
		/obj/item/clothing/under/plaid_skirt/green=1,
		/obj/item/clothing/glasses/regular=2,
		/obj/item/clothing/head/sombrero=1,
		/obj/item/clothing/suit/poncho=1,
		/obj/item/clothing/suit/ianshirt=1,
		/obj/item/clothing/shoes/laceup=2,
		/obj/item/clothing/shoes/sneakers/black=4,
		/obj/item/clothing/shoes/sandal=1,
		/obj/item/clothing/gloves/fingerless=2,
		/obj/item/clothing/glasses/orange=1,
		/obj/item/clothing/glasses/red=1,
		/obj/item/weapon/storage/belt/fannypack=1,
		/obj/item/weapon/storage/belt/fannypack/blue=1,
		/obj/item/weapon/storage/belt/fannypack/red=1,
		/obj/item/clothing/suit/jacket/letterman=2,
		/obj/item/clothing/head/kitty = 2,
		/obj/item/clothing/head/beanie=1,
		/obj/item/clothing/head/beanie/black=1,
		/obj/item/clothing/head/beanie/red=1,
		/obj/item/clothing/head/beanie/green=1,
		/obj/item/clothing/head/beanie/darkblue=1,
		/obj/item/clothing/head/beanie/purple=1,
		/obj/item/clothing/head/beanie/yellow=1,
		/obj/item/clothing/head/beanie/orange=1,
		/obj/item/clothing/head/beanie/cyan=1,
		/obj/item/clothing/head/beanie/christmas=1,
		/obj/item/clothing/head/beanie/striped=1,
		/obj/item/clothing/head/beanie/stripedred=1,
		/obj/item/clothing/head/beanie/stripedblue=1,
		/obj/item/clothing/head/beanie/stripedgreen=1,
		/obj/item/clothing/suit/jacket/letterman_red=1
		)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool=1,
		/obj/item/clothing/mask/balaclava=1,
		/obj/item/clothing/head/ushanka=1,
		/obj/item/clothing/under/soviet=1,
		/obj/item/weapon/storage/belt/fannypack/black=1,
		/obj/item/clothing/suit/jacket/letterman_syndie=1,
		/obj/item/clothing/under/jabroni=1,
		/obj/item/clothing/suit/vapeshirt=1,
		/obj/item/clothing/under/geisha=1
		)
	premium = list(
		/obj/item/clothing/under/suit_jacket/checkered=1,
		/obj/item/clothing/head/mailman=1,
		/obj/item/clothing/under/rank/mailman=1,
		/obj/item/clothing/suit/jacket/leather=1,
		/obj/item/clothing/suit/jacket/leather/overcoat=1,
		/obj/item/clothing/under/pants/mustangjeans=1,
		/obj/item/clothing/neck/necklace/dope=5,
		/obj/item/clothing/suit/jacket/letterman_nanotrasen=1
		)

/*

ROBOTECH DELUXE

*/

/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/clothing/under/rank/chief_engineer = 4,
		/obj/item/clothing/under/rank/engineer = 4,
		/obj/item/clothing/shoes/sneakers/orange = 4,
		/obj/item/clothing/head/hardhat = 4,
		/obj/item/weapon/storage/belt/utility = 4,
		/obj/item/clothing/glasses/meson/engine = 4,
		/obj/item/clothing/gloves/color/yellow = 4,
		/obj/item/weapon/screwdriver = 12,
		/obj/item/weapon/crowbar = 12,
		/obj/item/weapon/wirecutters = 12,
		/obj/item/device/multitool = 12,
		/obj/item/weapon/wrench = 12,
		/obj/item/device/t_scanner = 12,
		/obj/item/weapon/stock_parts/cell = 8,
		/obj/item/weapon/weldingtool = 8,
		/obj/item/clothing/head/welding = 8,
		/obj/item/weapon/light/tube = 10,
		/obj/item/clothing/suit/fire = 4,
		/obj/item/weapon/stock_parts/scanning_module = 5,
		/obj/item/weapon/stock_parts/micro_laser = 5,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/console_screen = 5
		)

/*

ENGI VEND

*/

/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "11" //Engineering Equipment access
	contraband = list(/obj/item/weapon/stock_parts/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/clothing/glasses/meson/engine = 2,
		/obj/item/device/multitool = 4,
		/obj/item/weapon/electronics/airlock = 10,
		/obj/item/weapon/electronics/apc = 10,
		/obj/item/weapon/electronics/airalarm = 10,
		/obj/item/weapon/stock_parts/cell/high = 10,
		/obj/item/weapon/construction/rcd/loaded = 3,
		/obj/item/device/geiger_counter = 5
		)

/*

YOUTOOL

*/

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	premium = list(/obj/item/clothing/gloves/color/yellow = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/weapon/crowbar = 5,
		/obj/item/weapon/weldingtool = 3,
		/obj/item/weapon/wirecutters = 5,
		/obj/item/weapon/wrench = 5,
		/obj/item/device/analyzer = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/weapon/screwdriver = 5
		)
	contraband = list(
		/obj/item/weapon/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/color/fyellow = 2
		)

/*

DINNERWARE

*/

/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor"
	icon_state = "dinnerware"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/weapon/storage/bag/tray = 8,
		/obj/item/weapon/kitchen/fork = 6,
		/obj/item/weapon/kitchen/knife = 6,
		/obj/item/weapon/kitchen/rollingpin = 2,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,
		/obj/item/clothing/suit/apron/chef = 2,
		/obj/item/weapon/reagent_containers/food/condiment/pack/ketchup = 5,
		/obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce = 5,
		/obj/item/weapon/reagent_containers/food/condiment/saltshaker = 5,
		/obj/item/weapon/reagent_containers/food/condiment/peppermill = 5,
		/obj/item/weapon/reagent_containers/glass/bowl = 20
		)
	contraband = list(
		/obj/item/weapon/kitchen/rollingpin = 2,
		/obj/item/weapon/kitchen/knife/butcher = 2
		)

/*

AUTODROBE

*/

/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access_txt = "46" //Theatre access needed, unless hacked.
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_reply = "Thank you for using AutoDrobe!"
	height = 750
	refill_canister = /obj/item/weapon/vending_refill/autodrobe
	products = list(
		/obj/item/clothing/suit/chickensuit = 1,
		/obj/item/clothing/head/chicken = 1,
		/obj/item/clothing/under/gladiator = 1,
		/obj/item/clothing/head/helmet/gladiator = 1,
		/obj/item/clothing/under/gimmick/rank/captain/suit = 1,
		/obj/item/clothing/head/flatcap = 1,
		/obj/item/clothing/suit/toggle/labcoat/mad = 1,
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/clothing/under/schoolgirl = 1,
		/obj/item/clothing/under/schoolgirl/red = 1,
		/obj/item/clothing/under/schoolgirl/green = 1,
		/obj/item/clothing/under/schoolgirl/orange = 1,
		/obj/item/clothing/head/kitty = 1,
		/obj/item/clothing/under/skirt/black = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/tie/waistcoat = 1,
		/obj/item/clothing/under/suit_jacket = 1,
		/obj/item/clothing/head/that =1,
		/obj/item/clothing/under/kilt = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/tie/waistcoat = 1,
		/obj/item/clothing/glasses/monocle =1,
		/obj/item/clothing/head/bowler = 1,
		/obj/item/weapon/cane = 1,
		/obj/item/clothing/under/sl_suit = 1,
		/obj/item/clothing/mask/fakemoustache = 1,
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
		/obj/item/clothing/head/plaguedoctorhat = 1,
		/obj/item/clothing/mask/gas/plaguedoctor = 1,
		/obj/item/clothing/suit/toggle/owlwings = 1,
		/obj/item/clothing/under/owl = 1,
		/obj/item/clothing/mask/gas/owl_mask = 1,
		/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1,
		/obj/item/clothing/under/griffin = 1,
		/obj/item/clothing/shoes/griffin = 1,
		/obj/item/clothing/head/griffin = 1,
		/obj/item/clothing/suit/apron = 1,
		/obj/item/clothing/under/waiter = 1,
		/obj/item/clothing/suit/jacket/miljacket = 1,
		/obj/item/clothing/under/pirate = 1,
		/obj/item/clothing/suit/pirate = 1,
		/obj/item/clothing/head/pirate = 1,
		/obj/item/clothing/head/bandana = 1,
		/obj/item/clothing/head/bandana = 1,
		/obj/item/clothing/under/soviet = 1,
		/obj/item/clothing/head/ushanka = 1,
		/obj/item/clothing/suit/imperium_monk = 1,
		/obj/item/clothing/mask/gas/cyborg = 1,
		/obj/item/clothing/suit/holidaypriest = 1,
		/obj/item/clothing/head/wizard/marisa/fake = 1,
		/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
		/obj/item/clothing/under/sundress = 1,
		/obj/item/clothing/head/witchwig = 1,
		/obj/item/weapon/staff/broom = 1,
		/obj/item/clothing/suit/wizrobe/fake = 1,
		/obj/item/clothing/head/wizard/fake = 1,
		/obj/item/weapon/staff = 3,
		/obj/item/clothing/mask/gas/sexyclown = 1,
		/obj/item/clothing/under/rank/clown/sexy = 1,
		/obj/item/clothing/mask/gas/sexymime = 1,
		/obj/item/clothing/under/sexymime = 1,
		/obj/item/clothing/mask/rat/bat = 1,
		/obj/item/clothing/mask/rat/bee = 1,
		/obj/item/clothing/mask/rat/bear = 1,
		/obj/item/clothing/mask/rat/raven = 1,
		/obj/item/clothing/mask/rat/jackal = 1,
		/obj/item/clothing/mask/rat/fox = 1,
		/obj/item/clothing/mask/rat/tribal = 1,
		/obj/item/clothing/mask/rat = 1,
		/obj/item/clothing/suit/apron/overalls = 1,
		/obj/item/clothing/head/rabbitears =1,
		/obj/item/clothing/head/sombrero = 1,
		/obj/item/clothing/head/sombrero/green = 1,
		/obj/item/clothing/suit/poncho = 1,
		/obj/item/clothing/suit/poncho/green = 1,
		/obj/item/clothing/suit/poncho/red = 1,
		/obj/item/clothing/under/maid = 1,
		/obj/item/clothing/under/janimaid = 1,
		/obj/item/clothing/glasses/cold=1,
		/obj/item/clothing/glasses/heat=1,
		/obj/item/clothing/suit/whitedress = 1,
		/obj/item/clothing/under/jester = 1,
		/obj/item/clothing/head/jester = 1,
		/obj/item/clothing/under/villain = 1,
		/obj/item/clothing/shoes/singery = 1,
		/obj/item/clothing/under/singery = 1,
		/obj/item/clothing/shoes/singerb = 1,
		/obj/item/clothing/under/singerb = 1,
		/obj/item/clothing/suit/hooded/carp_costume = 1,
		/obj/item/clothing/suit/hooded/ian_costume = 1,
		/obj/item/clothing/suit/hooded/bee_costume = 1,
		/obj/item/clothing/suit/snowman = 1,
		/obj/item/clothing/head/snowman = 1,
		/obj/item/clothing/mask/joy = 1,
		/obj/item/clothing/head/cueball = 1,
		/obj/item/clothing/under/scratch = 1,
		/obj/item/clothing/under/sailor = 1
		)
	contraband = list(
		/obj/item/clothing/suit/judgerobe = 1,
		/obj/item/clothing/head/powdered_wig = 1,
		/obj/item/weapon/gun/magic/wand = 2,
		/obj/item/clothing/glasses/sunglasses/garb = 2,
		/obj/item/clothing/glasses/sunglasses/blindfold = 1,
		/obj/item/clothing/mask/muzzle = 2
		)
	premium = list(
		/obj/item/clothing/suit/pirate/captain = 2,
		/obj/item/clothing/head/pirate/captain = 2,
		/obj/item/clothing/head/helmet/roman = 1,
		/obj/item/clothing/head/helmet/roman/legionaire = 1,
		/obj/item/clothing/under/roman = 1,
		/obj/item/clothing/shoes/roman = 1,
		/obj/item/weapon/shield/riot/roman = 1,
		/obj/item/weapon/skub = 3
		)

/*

MAGIVEND

*/

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/wizarditis = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	height = 350
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/yellow = 1,
		/obj/item/clothing/suit/wizrobe/yellow = 1,
		/obj/item/clothing/shoes/sandal/magic = 1,
		/obj/item/weapon/staff = 2
		)

/*

MEGASEED SERVITOR

*/

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	icon_state = "seeds"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	height = 750
	width = 400
	products = list(
		/obj/item/seeds/ambrosia = 3,
		/obj/item/seeds/apple = 3,
		/obj/item/seeds/banana = 3,
		/obj/item/seeds/berry = 3,
		/obj/item/seeds/cabbage = 3,
		/obj/item/seeds/carrot = 3,
		/obj/item/seeds/cherry = 3,
		/obj/item/seeds/chanter = 3,
		/obj/item/seeds/chili = 3,
		/obj/item/seeds/cocoapod = 3,
		/obj/item/seeds/coffee = 3,
		/obj/item/seeds/corn = 3,
		/obj/item/seeds/eggplant = 3,
		/obj/item/seeds/grape = 3,
		/obj/item/seeds/grass = 3,
		/obj/item/seeds/lemon = 3,
		/obj/item/seeds/lime = 3,
		/obj/item/seeds/orange = 3,
		/obj/item/seeds/potato = 3,
		/obj/item/seeds/poppy = 3,
		/obj/item/seeds/pumpkin = 3,
		/obj/item/seeds/replicapod = 3,
		/obj/item/seeds/buttseed = 2,
		/obj/item/seeds/limbseed = 3,
		/obj/item/seeds/wheat/rice = 3,
		/obj/item/seeds/soya = 3,
		/obj/item/seeds/sunflower = 3,
		/obj/item/seeds/tea = 3,
		/obj/item/seeds/tobacco = 3,
		/obj/item/seeds/tomato = 3,
		/obj/item/seeds/tower = 3,
		/obj/item/seeds/watermelon = 3,
		/obj/item/seeds/wheat = 3,
		/obj/item/seeds/whitebeet = 3
		)
	contraband = list(
		/obj/item/seeds/amanita = 2,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/liberty = 2,
		/obj/item/seeds/nettle = 2,
		/obj/item/seeds/plump = 2,
		/obj/item/seeds/reishi = 2,
		/obj/item/seeds/cannabis = 3,
		/obj/item/seeds/random = 2
		)
	premium = list(
		/obj/item/weapon/reagent_containers/spray/waterflower = 1,
		/obj/item/seeds/random = 10
		)

/*

NUTRIMAX

*/

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	icon_state = "nutri"
	height = 750
	icon_deny = "nutri-deny"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez = 30,
		/obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z = 20,
		/obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh = 10,
		/obj/item/weapon/reagent_containers/spray/pestspray = 20,
		/obj/item/weapon/reagent_containers/syringe = 5,
		/obj/item/weapon/storage/bag/plants = 5,
		/obj/item/weapon/cultivator = 3,
		/obj/item/weapon/shovel/spade = 3,
		/obj/item/device/plant_analyzer = 4
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5
		)

/*

SECTECH

*/

/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	premium = list(/obj/item/weapon/coin/antagtoken = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/weapon/restraints/handcuffs = 8,
		/obj/item/weapon/restraints/handcuffs/cable/zipties = 10,
		/obj/item/weapon/grenade/flashbang = 4,
		/obj/item/device/assembly/flash/handheld = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut = 12,
		/obj/item/weapon/storage/box/evidence = 6,
		/obj/item/device/flashlight/seclite = 4,
		/obj/item/weapon/restraints/legcuffs/bola/energy = 7
		)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/weapon/storage/fancy/donut_box = 2
		)

/*

BOOZE O MAT

*/
/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/mug/tea = 12)
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	req_access_txt = "25"
	refill_canister = /obj/item/weapon/vending_refill/boozeomat
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/hcider = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/grappa = 5,
		/obj/item/weapon/reagent_containers/food/drinks/ale = 6,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic = 8,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 8,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater = 15,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 10,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass = 12,
		/obj/item/weapon/reagent_containers/food/drinks/flask = 3
		)

/*

VENDOMAT

*/


/obj/machinery/vending/assist
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	height = 350
	products = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/weapon/wirecutters = 1,
		/obj/item/weapon/cartridge/signal = 4
		)
	contraband = list(
		/obj/item/device/flashlight = 5,
		/obj/item/device/assembly/timer = 2,
		/obj/item/device/assembly/voice = 2,
		/obj/item/device/assembly/health = 2
		)

/*

HOTDRINKS

*/

/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 12)
	refill_canister = /obj/item/weapon/vending_refill/coffee
	height = 250
	products = list(
	/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,
	/obj/item/weapon/reagent_containers/food/drinks/mug/tea = 25,
	/obj/item/weapon/reagent_containers/food/drinks/mug/coco = 25
	)


/*

NANOMED

*/

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	req_access_txt = "5"
	height = 675
	premium = list(/obj/item/weapon/storage/box/hug/medical = 1,/obj/item/weapon/reagent_containers/hypospray/medipen = 3, /obj/item/weapon/storage/belt/medical = 3, /obj/item/weapon/wrench/medical = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/weapon/vending_refill/medical
	products = list(
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/weapon/reagent_containers/dropper = 3,
		/obj/item/stack/medical/gauze = 8,
		/obj/item/weapon/reagent_containers/pill/patch/styptic = 5,
		/obj/item/weapon/reagent_containers/pill/insulin = 10,
		/obj/item/weapon/reagent_containers/pill/patch/silver_sulf = 5,
		/obj/item/weapon/reagent_containers/glass/bottle/charcoal = 4,
		/obj/item/weapon/reagent_containers/spray/medical/sterilizer = 1,
		/obj/item/weapon/reagent_containers/glass/bottle/epinephrine = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/morphine = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/salglu_solution = 3,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 3,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 6,
		/obj/item/weapon/reagent_containers/pill/salbutamol = 2,
		/obj/item/device/healthanalyzer = 4,
		/obj/item/device/sensor_device = 2
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/pill/morphine = 4,
		/obj/item/weapon/reagent_containers/pill/charcoal = 6
		)

/*

WALLMED

*/

/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon = 'icons/obj/vending.dmi'
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0
	height = 300
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/weapon/vending_refill/medical
	refill_count = 1
	products = list(
		/obj/item/weapon/reagent_containers/syringe = 3,
		/obj/item/weapon/reagent_containers/pill/patch/styptic = 5,
		/obj/item/weapon/reagent_containers/pill/patch/silver_sulf = 5,
		/obj/item/weapon/reagent_containers/pill/charcoal = 2,
		/obj/item/weapon/reagent_containers/spray/medical/sterilizer = 1
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 2,
		/obj/item/weapon/reagent_containers/pill/morphine = 2
		)

/*

CHOCOLATE

*/

/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	icon_state = "snack"
	width = 375
	height = 350
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)
	refill_canister = /obj/item/weapon/vending_refill/snack
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chips =6,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6
		)

/obj/machinery/vending/snack/random
	name = "\improper Random Snackies"
	desc = "Uh oh!"

/obj/machinery/vending/snack/random/Initialize()
    ..()
    var/T = pick(subtypesof(/obj/machinery/vending/snack) - /obj/machinery/vending/snack/random)
    new T(get_turf(src))
    qdel(src)

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"

/*

CIGARETTE

*/

/obj/machinery/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	icon_state = "cigs"
	height = 550
	premium = list(
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_robustgold = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigars = 1,
		/obj/item/weapon/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/weapon/storage/fancy/cigarettes/cigars/cohiba = 1
		)
	refill_canister = /obj/item/weapon/vending_refill/cigarette
	products = list(
		/obj/item/weapon/storage/fancy/cigarettes = 5,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_robust = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_midori = 3,
		/obj/item/weapon/storage/box/matches = 10,
		/obj/item/weapon/lighter/greyscale = 4,
		/obj/item/weapon/storage/fancy/rollingpapers = 5,
		/obj/item/weapon/lighter = 1,
		/obj/item/clothing/mask/vape = 2
		)
	contraband = list(
		/obj/item/weapon/lighter = 3,
		/obj/item/clothing/mask/vape = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_shadyjims = 3
		)

/*

LIBERATION STATION

*/

/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	product_slogans = "Liberation Station: Your one-stop shop for all things second ammendment!;Be a patriot today, pick up a gun!;Quality weapons for cheap prices!;Better dead than red!"
	vend_reply = "Remember the name: Liberation Station!"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/gold = 2,
		/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/camo = 2,
		/obj/item/weapon/gun/ballistic/automatic/pistol/m1911 = 2,
		/obj/item/weapon/gun/ballistic/automatic/proto/unrestricted = 2,
		/obj/item/weapon/gun/ballistic/shotgun/automatic/combat = 2,
		/obj/item/weapon/gun/ballistic/automatic/gyropistol = 1,
		/obj/item/weapon/gun/ballistic/shotgun = 2,
		/obj/item/weapon/gun/ballistic/automatic/ar = 2
		)
	premium = list(
		/obj/item/ammo_box/magazine/smgm9mm = 2,
		/obj/item/ammo_box/magazine/m50 = 4,
		/obj/item/ammo_box/magazine/m45 = 2,
		/obj/item/ammo_box/magazine/m75 = 2
		)
	contraband = list(
		/obj/item/clothing/under/patriotsuit = 1,
		/obj/item/weapon/bedsheet/patriot = 3
		)

/*

SODA

*/

/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko = 6)
	premium = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 1)
	refill_canister = /obj/item/weapon/vending_refill/cola
	height = 400
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime = 10
		)

/obj/machinery/vending/cola/random
	name = "\improper Random Drinkies"
	desc = "Uh oh!"

/obj/machinery/vending/cola/random/Initialize()
    ..()
    var/T = pick(subtypesof(/obj/machinery/vending/cola) - /obj/machinery/vending/cola/random)
    new T(get_turf(src))
    qdel(src)

/obj/machinery/vending/cola/blue
	icon_state = "Cola_Machine"

/obj/machinery/vending/cola/black
	icon_state = "cola_black"

/obj/machinery/vending/cola/red
	icon_state = "red_cola"
	name = "\improper Space Cola Vendor"
	desc = "It vends cola, in space."
	product_slogans = "Cola in space!"

/obj/machinery/vending/cola/space_up
	icon_state = "space_up"
	name = "\improper Space-up! Vendor"
	desc = "Indulge in an explosion of flavor."
	product_slogans = "Space-up! Like a hull breach in your mouth."

/obj/machinery/vending/cola/starkist
	icon_state = "starkist"
	name = "\improper Star-kist Vendor"
	desc = "The taste of a star in liquid form."
	product_slogans = "Drink the stars! Star-kist!"

/obj/machinery/vending/cola/sodie
	icon_state = "soda"

/obj/machinery/vending/cola/pwr_game
	icon_state = "pwr_game"
	name = "\improper Pwr Game Vendor"
	desc = "You want it, we got it. Brought to you in partnership with Vlad's Salads."
	product_slogans = "The POWER that gamers crave! PWR GAME!"

/obj/machinery/vending/cola/shamblers
	name = "\improper Shambler's Vendor"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"
	product_slogans = "~Shake me up some of that Shambler's Juice!~"

/*

SUSTENANCE VENDOR

*/

/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	icon_state = "sustenance"
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	products = list (
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 24,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 12,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn = 6
		)
	contraband = list(
		/obj/item/weapon/kitchen/knife = 6,
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 12,
		/obj/item/weapon/tank/internals/emergency_oxygen = 6,
		/obj/item/clothing/mask/breath = 6
		)

/*

RUSSIAN SODA

*/

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine"
	icon_state = "sovietsoda"
	height = 200
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/filled/cola = 20)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/*

PDA TECH

*/

/obj/machinery/vending/cart
	name = "\improper PTech"
	icon = 'icons/obj/vending.dmi'
	desc = "Cartridges for PDAs"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(
					/obj/item/weapon/cartridge/medical = 10,
					/obj/item/weapon/cartridge/engineering = 10,
					/obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10,
					/obj/item/weapon/cartridge/signal/toxins = 10,
					/obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3,
					/obj/item/weapon/cartridge/quartermaster = 10
					)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF