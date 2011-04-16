/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'vending.dmi'
	icon_state = "generic"
	layer = 2.9
	anchored = 1
	density = 1
	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/product_paths = "" //String of product paths separated by semicolons. No spaces!
	var/product_amounts = "" //String of product amounts separated by semicolons, must have amount for every path in product_paths
	var/product_slogans = "" //String of slogans separated by semicolons, optional
	var/product_hidden = "" //String of products that are hidden unless hacked.
	var/product_hideamt = "" //String of hidden product amounts, separated by semicolons. Exact same as amounts. Must be left blank if hidden is.
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/slogan_list = list()
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 600 //How long until we can pitch again?
	var/icon_vend //Icon_state when vending!
	var/icon_deny //Icon_state when vending!
	var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/extended_inventory = 0 //can we access the hidden inventory?
	var/panel_open = 0 //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	product_paths = "/obj/item/weapon/reagent_containers/food/drinks/bottle/gin;/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey;/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla;/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka;/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth;/obj/item/weapon/reagent_containers/food/drinks/bottle/rum;/obj/item/weapon/reagent_containers/food/drinks/bottle/wine;/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac;/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua;/obj/item/weapon/reagent_containers/food/drinks/beer;/obj/item/weapon/reagent_containers/food/drinks/ale;/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice;/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice;/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice;/obj/item/weapon/reagent_containers/food/drinks/bottle/cream;/obj/item/weapon/reagent_containers/food/drinks/tonic;/obj/item/weapon/reagent_containers/food/drinks/cola;/obj/item/weapon/reagent_containers/food/drinks/sodawater;/obj/item/weapon/reagent_containers/food/drinks/drinkingglass;/obj/item/weapon/reagent_containers/food/drinks/ice"
	product_amounts = "5;5;5;5;5;5;5;5;5;6;6;4;4;4;4;8;8;8;30;10"
	vend_delay = 15
	product_hidden = "/obj/item/weapon/reagent_containers/food/drinks/coffee;/obj/item/weapon/reagent_containers/food/drinks/tea"
	product_hideamt = "10;10"
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"

/obj/machinery/vending/assist
	product_amounts = "5;3;4;1;4"
	product_hidden = "/obj/item/device/flashlight;obj/item/device/timer"
	product_paths = "/obj/item/device/prox_sensor;/obj/item/device/igniter;/obj/item/device/radio/signaler;/obj/item/weapon/wirecutters;/obj/item/weapon/cartridge/signal"
	product_hideamt = "5;2"

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	product_paths = "/obj/item/weapon/reagent_containers/food/drinks/coffee;/obj/item/weapon/reagent_containers/food/drinks/tea;/obj/item/weapon/reagent_containers/food/drinks/h_chocolate"
	product_amounts = "25;25;25"
	vend_delay = 34
	product_hidden = "/obj/item/weapon/reagent_containers/food/drinks/ice"
	product_hideamt = "10"

/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	icon_state = "snack"
	product_paths = "/obj/item/weapon/reagent_containers/food/snacks/candy;/obj/item/weapon/reagent_containers/food/drinks/dry_ramen;/obj/item/weapon/reagent_containers/food/snacks/chips;/obj/item/weapon/reagent_containers/food/snacks/sosjerky;/obj/item/weapon/reagent_containers/food/snacks/no_raisin;/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie;/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers"
	product_amounts = "10;10;10;10;10;10;10"
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_hidden = "/obj/item/weapon/reagent_containers/food/snacks/syndicake"
	product_hideamt = "10"


/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_paths = "/obj/item/weapon/reagent_containers/food/drinks/cola;/obj/item/weapon/reagent_containers/food/drinks/space_mountain_wind;/obj/item/weapon/reagent_containers/food/drinks/dr_gibb;/obj/item/weapon/reagent_containers/food/drinks/starkist;/obj/item/weapon/reagent_containers/food/drinks/space_up"
	product_amounts = "10;10;10;10;10"
	product_slogans = "Robust Softdrinks: More robust then a toolbox to the head!"
	product_hidden = "/obj/item/weapon/reagent_containers/food/drinks/thirteenloko"
	product_hideamt = "5"

/obj/machinery/vending/cigarette
	name = "cigarette machine"
	desc = "If you want to get cancer, might as well do it in style"
	icon_state = "cigs"
	product_paths = "/obj/item/weapon/cigpacket;/obj/item/weapon/matchbox"
	product_amounts = "10;10"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	vend_delay = 34
	product_hidden = "/obj/item/weapon/zippo"
	product_hideamt = "4"

/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	req_access_txt = "5"
	product_paths = "/obj/item/weapon/reagent_containers/glass/bottle/antitoxin;/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline;/obj/item/weapon/reagent_containers/glass/bottle/stoxin;/obj/item/weapon/reagent_containers/glass/bottle/toxin;/obj/item/weapon/reagent_containers/syringe/antiviral;/obj/item/weapon/reagent_containers/syringe;/obj/item/device/healthanalyzer"
	product_amounts = "4;4;4;4;8;12;5"
	product_hidden = "/obj/item/weapon/reagent_containers/pill/tox;/obj/item/weapon/reagent_containers/pill/stox;/obj/item/weapon/reagent_containers/pill/antitox"
	product_hideamt = "3;4;6"

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	product_paths = "/obj/item/weapon/handcuffs;/obj/item/weapon/flashbang;/obj/item/device/flash"
	product_amounts = "8;2;5"
	//product_amounts = "8;5;4" Old totals
	product_hidden = "/obj/item/clothing/glasses/sunglasses;/obj/item/weapon/reagent_containers/food/snacks/donut"
	product_hideamt = "2;12"

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor"
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	product_paths = "/obj/item/nutrient/ez;/obj/item/nutrient/l4z;/obj/item/nutrient/rh;/obj/item/weapon/pestspray;/obj/item/weapon/reagent_containers/syringe"
	product_amounts = "35;25;15;20;5"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_hidden = "/obj/item/weapon/reagent_containers/glass/bottle/ammonia;/obj/item/weapon/reagent_containers/glass/bottle/diethylamine"
	product_hideamt = "10;5"

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon_state = "seeds"
	product_paths = "/obj/item/seeds/cornseed;/obj/item/seeds/chiliseed;/obj/item/seeds/berryseed;/obj/item/seeds/eggplantseed;/obj/item/seeds/tomatoseed;/obj/item/seeds/wheatseed;/obj/item/seeds/soyaseed;/obj/item/seeds/carrotseed;/obj/item/seeds/potatoseed;/obj/item/seeds/chantermycelium"
	product_amounts = "2;2;2;2;2;2;2;2;2;2"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_hidden = "/obj/item/seeds/amanitamycelium;/obj/item/seeds/libertymycelium;/obj/item/seeds/nettleseed;/obj/item/seeds/plumpmycelium"
	product_hideamt = "2;2;2;2"

/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_amounts = "1;1;1;1;1;2"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	product_paths = "/obj/item/clothing/head/wizard;/obj/item/clothing/suit/wizrobe;/obj/item/clothing/head/wizard/red;/obj/item/clothing/suit/wizrobe/red;/obj/item/clothing/shoes/sandal;/obj/item/weapon/staff"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_hidden = "/obj/item/weapon/reagent_containers/glass/bottle/wizarditis" //No one can get to the machine to hack it anyways
	product_hideamt = "1" //Just one, for the lulz, not like anyone can get it - Microwave

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor"
	icon_state = "dinnerware"
	product_paths = "/obj/item/weapon/tray;/obj/item/weapon/kitchen/utensil/fork;/obj/item/weapon/kitchenknife"
	product_amounts = "6;4;2"
	//product_amounts = "8;5;4" Old totals
	product_hidden = "/obj/item/weapon/kitchen/utensil/spoon;/obj/item/weapon/kitchen/utensil/knife;/obj/item/weapon/kitchen/rollingpin"
	product_hideamt = "2;2;2"