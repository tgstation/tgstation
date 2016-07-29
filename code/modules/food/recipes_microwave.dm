
//**************************************************************
//
// Microwave Recipes
// -----------------------
// See code/datums/recipe.dm
// TODO: More inheritance
//
//**************************************************************

// Donuts //////////////////////////////////////////////////////

/datum/recipe/donut
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal

/datum/recipe/jellydonut
	reagents = list(BERRYJUICE = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly

/datum/recipe/jellydonut/slime
	reagents = list(SLIMEJELLY = 5, FLOUR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly

/datum/recipe/jellydonut/cherry
	reagents = list(CHERRYJELLY = 5, FLOUR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly

/datum/recipe/chaosdonut
	reagents = list(FROSTOIL = 5, CAPSAICIN = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos

// Burgers /////////////////////////////////////////////////////

/datum/recipe/customizable_bun
	items = list(/obj/item/weapon/reagent_containers/food/snacks/dough)
	result = /obj/item/weapon/reagent_containers/food/snacks/bun

/datum/recipe/plainburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/animal)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger

/datum/recipe/appendixburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/organ)
	result = /obj/item/weapon/reagent_containers/food/snacks/appendixburger

/datum/recipe/syntiburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger/synth

/datum/recipe/brainburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/organ/brain)
	result = /obj/item/weapon/reagent_containers/food/snacks/brainburger

/datum/recipe/roburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/robot_parts/head)
	result = /obj/item/weapon/reagent_containers/food/snacks/roburger

/datum/recipe/xenoburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/xenoburger

/datum/recipe/tofuburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofuburger

/datum/recipe/chickenburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/chickenburger

/datum/recipe/ghostburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/ectoplasm)
	result = /obj/item/weapon/reagent_containers/food/snacks/ghostburger

/datum/recipe/clownburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/mask/gas/clown_hat)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownburger

/datum/recipe/mimeburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/beret)
	result = /obj/item/weapon/reagent_containers/food/snacks/mimeburger

/datum/recipe/assburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/assburger

/datum/recipe/spellburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/clothing/head/wizard)
	result = /obj/item/weapon/reagent_containers/food/snacks/spellburger

/datum/recipe/bigbiteburger
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger

/datum/recipe/superbiteburger
	reagents = list(SODIUMCHLORIDE = 5, BLACKPEPPER = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/superbiteburger

/datum/recipe/slimeburger
	reagents = list(SLIMEJELLY = 5, FLOUR = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/datum/recipe/jellyburger
	reagents = list(CHERRYJELLY = 5, FLOUR = 15)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

// Burger sliders //////////////////////////////////////////////

/datum/recipe/sliders
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box

/datum/recipe/sliders/synth
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/synth

/datum/recipe/sliders/xeno
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/xeno

/datum/recipe/sliders/chicken
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/chicken

/datum/recipe/sliders/spider
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/spider

/datum/recipe/sliders/clown
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/mask/gas/clown_hat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/clown

/datum/recipe/sliders/mime
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/clothing/head/beret
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/mime

/datum/recipe/sliders/slippery
	reagents = list(FLOUR = 10, LUBE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/slippery

// Eggs ////////////////////////////////////////////////////////

/datum/recipe/friedegg
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledegg

/datum/recipe/omelette
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/omelette

/datum/recipe/benedict
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict

/datum/recipe/chocolateegg
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

// Human ///////////////////////////////////////////////////////

/datum/recipe/human //Parent datum only
	make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for(var/obj/item/weapon/reagent_containers/food/snacks/meat/human/HM in container)
			if(HM.subjectname)
				human_name = HM.subjectname
				human_job = HM.subjectjob
				break
		var/lastname_index = findtext(human_name, " ")
		if(lastname_index) human_name = copytext(human_name,lastname_index+1)
		var/obj/item/weapon/reagent_containers/food/snacks/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB

/datum/recipe/human/burger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human)
	result = /obj/item/weapon/reagent_containers/food/snacks/human

/datum/recipe/human/kabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/human/kabob

// Pastries ////////////////////////////////////////////////////

/datum/recipe/eclair
	reagents = list(FLOUR = 5, CREAM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eclair

/datum/recipe/waffles
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/waffles

/datum/recipe/poppypretzel
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/seeds/poppyseed,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel

/datum/recipe/rofflewaffles
	reagents = list(PSILOCYBIN = 5, FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/sugarcookie
	reagents = list(FLOUR = 5, SUGAR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie

/datum/recipe/muffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin

/datum/recipe/berrymuffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/berry

/datum/recipe/booberrymuffin
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/ectoplasm
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/booberry

/datum/recipe/dindumuffin
	reagents = list(NOTHING = 5, MILK = 5, FLOUR = 5)
	items = list(/obj/item/weapon/handcuffs)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin

// Donk Pockets ////////////////////////////////////////////////

/datum/recipe/donkpocket
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/faggot)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket //SPECIAL

/datum/recipe/donkpocket/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = ..(container)
	being_cooked.warm_up()
	return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //No flour required
	items = list(/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket

/datum/recipe/donkpocket/warm/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = locate() in container
	if(istype(being_cooked))
		if(being_cooked.warm <= 0)
			being_cooked.warm_up()
		else
			being_cooked.warm = 80
	return being_cooked

// Bread ///////////////////////////////////////////////////////

/datum/recipe/bread
	reagents = list(FLOUR = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/syntibread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth

/datum/recipe/xenomeatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/spidermeatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread

/datum/recipe/meatbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/bananabread
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread

/datum/recipe/tofubread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/creamcheesebread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/eucharist
	reagents = list(FLOUR = 5, HOLYWATER = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/eucharist

// French //////////////////////////////////////////////////////

/datum/recipe/eggplantparm
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/recipe/berryclafoutis
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/berries)
	result = /obj/item/weapon/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/baguette
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, FLOUR = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/baguette

// Asian ///////////////////////////////////////////////////////

/datum/recipe/wingfangchu
	reagents = list(SOYSAUCE = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/wingfangchu

/datum/recipe/fortunecookie
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/paper,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fortunecookie

/datum/recipe/fortunecookie/make_food(var/obj/container)
	var/obj/item/weapon/paper/paper = locate() in container
	paper.loc = null //prevent deletion
	var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/being_cooked = ..(container)
	paper.loc = being_cooked
	being_cooked.trash = paper
	return being_cooked

/datum/recipe/fortunecookie/check_items(var/obj/container)
	. = ..()
	if(.)
		var/obj/item/weapon/paper/paper = locate() in container
		if(!paper.info) . = 0
	return

/datum/recipe/boiledrice
	reagents = list(WATER = 5, RICE = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledrice

/datum/recipe/ricepudding
	reagents = list(MILK = 5, RICE = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/ricepudding

/datum/recipe/riceball
	reagents = list(RICE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/riceball

/datum/recipe/eggplantsushi
	reagents = list(RICE = 10, VINEGAR = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
				/obj/item/weapon/reagent_containers/food/snacks/grown/chili
				)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantsushi

// American ////////////////////////////////////////////////////

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/popcorn
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn

/datum/recipe/syntisteak
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth

/datum/recipe/meatsteak
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak

/datum/recipe/hotchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotchili

/datum/recipe/coldchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/coldchili

/datum/recipe/wrap
	reagents = list(SOYSAUCE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/beans
	reagents = list(KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

/datum/recipe/hotdog
	reagents = list(KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog

/datum/recipe/meatbun
	reagents = list(SOYSAUCE = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun

/datum/recipe/candiedapple
	reagents = list(WATER = 5, SUGAR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple

// Cakes ///////////////////////////////////////////////////////

/datum/recipe/carrotcake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/cheesecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/plaincake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/braincake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/organ/brain
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/birthdaycake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/clothing/head/cakehat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/applecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/orangecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/limecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/lemoncake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/chocolatecake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/buchedenoel
	reagents = list(MILK = 5, FLOUR = 15, CREAM = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel

/datum/recipe/popoutcake
	reagents = list("milk" = 15, "flour" = 45)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/sheet/cardboard
		)
	result = /obj/structure/popout_cake

// Pies ////////////////////////////////////////////////////////

/datum/recipe/pie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie

/datum/recipe/applepie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/applepie

/datum/recipe/meatpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/meatpie

/datum/recipe/tofupie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/tofu)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/tofupie

/datum/recipe/xemeatpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie

/datum/recipe/cherrypie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/cherries)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie

/datum/recipe/amanita_pie
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie

/datum/recipe/plump_pie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie

/datum/recipe/asspie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/clothing/head/butt)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/asspie

/datum/recipe/appletart
	reagents = list(SUGAR = 5, MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/appletart

/datum/recipe/pumpkinpie
	reagents = list(MILK = 5, SUGAR = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie

/datum/recipe/nofruitpie
	reagents = list(FLOUR = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie

// Kebabs //////////////////////////////////////////////////////

/datum/recipe/syntikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeykabob/synth

/datum/recipe/monkeykabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeykabob

/datum/recipe/corgikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/corgikabob

/datum/recipe/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofukabob

// Pizza ///////////////////////////////////////////////////////

/datum/recipe/pizzamargherita
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/syntipizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth

/datum/recipe/meatpizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

// Mushrooms ///////////////////////////////////////////////////

/datum/recipe/spacylibertyduff
	reagents = list(WATER = 5, VODKA = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list(WATER = 5, VODKA = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly

/datum/recipe/amanitajelly/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(AMATOXIN)
	return being_cooked

/datum/recipe/plumphelmetbiscuit
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/chawanmushi
	reagents = list(WATER = 5, SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi

// Soup ////////////////////////////////////////////////////////

/datum/recipe/meatballsoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot ,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/nettlesoup

/datum/recipe/wishsoup
	reagents = list(WATER = 20)
	result = /obj/item/weapon/reagent_containers/food/snacks/wishsoup

/datum/recipe/stew
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stew

/datum/recipe/milosoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/milosoup

/datum/recipe/stewedsoymeat
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat

/datum/recipe/tomatosoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/tomatosoup

/datum/recipe/bloodsoup
	reagents = list(BLOOD = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/bloodsoup

/datum/recipe/slimesoup
	reagents = list(WATER = 10, SLIMEJELLY = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/slimesoup

/datum/recipe/clownstears
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/ore/clown,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownstears

/datum/recipe/mushroomsoup
	reagents = list(WATER = 5, MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/beetsoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/beetsoup

/datum/recipe/mysterysoup
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup

// Sandwiches //////////////////////////////////////////////////

/datum/recipe/sandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich

/datum/recipe/toastedsandwich
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sandwich)
	result = /obj/item/weapon/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/recipe/slimetoast
	reagents = list(SLIMEJELLY = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/jelliedtoast
	reagents = list(CHERRYJELLY = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/notasandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich

/datum/recipe/twobread
	reagents = list(WINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread

/datum/recipe/slimesandwich
	reagents = list(SLIMEJELLY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/recipe/cherrysandwich
	reagents = list(CHERRYJELLY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

// Coder Snacks ///////////////////////////////////////////////////////

/datum/recipe/spaghetti
	reagents = list(FLOUR = 5)
	result= /obj/item/weapon/reagent_containers/food/snacks/spaghetti

/datum/recipe/copypasta
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

// Pasta ///////////////////////////////////////////////////////

/datum/recipe/mommispaghetti // Same as roburger, but for mommis
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/pipe,
		/obj/item/stack/sheet/mineral/plasma,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mommispaghetti

/datum/recipe/boiledspaghetti
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/spaghetti)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti

/datum/recipe/pastatomato
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/recipe/meatballspaghetti
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti

// Salad ///////////////////////////////////////////////////////

/datum/recipe/spesslaw
	reagents = list(WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw

/datum/recipe/herbsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad

/datum/recipe/herbsalad/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/herbsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(TOXIN)
	return being_cooked

/datum/recipe/aesirsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	reagents_forbidden = list(SYNAPTIZINE)

/datum/recipe/validsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad

/datum/recipe/validsalad/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(TOXIN)
	return being_cooked
// Curry ///////////////////////////////////////////////////////

/datum/recipe/curry
	reagents = list (WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry

/datum/recipe/vindaloo
	reagents = list (WATER = 10, CAPSAICIN = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo

/datum/recipe/lemoncurry
	reagents = list (WATER = 10, LEMONJUICE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/lemon

/datum/recipe/xenocurry
	reagents = list (SACID = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/curry/xeno

// Chips ///////////////////////////////////////////////////////

/datum/recipe/chips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list (/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable

/datum/recipe/vinegarchips
	reagents = list (SODIUMCHLORIDE = 2, VINEGAR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar

/datum/recipe/cheddarchips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar

/datum/recipe/clownchips
	reagents = list (BANANA = 20)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown

/datum/recipe/nuclearchips
	reagents = list (URANIUM = 10, SODIUMCHLORIDE = 2)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear

/datum/recipe/commiechips
	reagents = list (SODIUMCHLORIDE = 2, VODKA = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist

/datum/recipe/xenochips
	reagents = list (SODIUMCHLORIDE = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno


// Misc ////////////////////////////////////////////////////////

/datum/recipe/ramen
	reagents = list(FLOUR = 5)
	items = list(/obj/item/stack/sheet/cardboard)
	result = /obj/item/weapon/reagent_containers/food/drinks/dry_ramen

/datum/recipe/sundaeramen
	reagents = list(DRY_RAMEN = 30, SPRINKLES = 1, BLACKCOLOR = 1, BUSTANUT = 6)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundaeramen

/datum/recipe/sweetsundaeramen
	items = list(/obj/item/weapon/reagent_containers/food/snacks/sundaeramen,/obj/item/weapon/reagent_containers/food/snacks/ricepudding,/obj/item/weapon/reagent_containers/food/snacks/gigapuddi,/obj/item/weapon/reagent_containers/food/snacks/donkpocket)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen

/datum/recipe/cracker
	reagents = list(FLOUR = 5, SODIUMCHLORIDE = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/cracker

/datum/recipe/soylenviridians
	reagents = list(FLOUR = 15)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians

/datum/recipe/soylentgreen
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen

/datum/recipe/monkeysdelight
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/boiledspiderleg
	reagents = list(WATER = 10)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/spidereggsham
	reagents = list(SODIUMCHLORIDE = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/spidereggsham

/datum/recipe/sausage
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sausage

/datum/recipe/enchiladas
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/enchiladas

/datum/recipe/fishburger
	reagents = list(FLOUR = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishburger

/datum/recipe/fishandchips
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/recipe/fishfingers
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishfingers

/datum/recipe/sashimi
	reagents = list(SOYSAUCE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi

/datum/recipe/cubancarp
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/recipe/sliders/carp
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
		)
	result = /obj/item/weapon/storage/fancy/food_box/slider_box/carp

/datum/recipe/sliders/carp/make_food(var/obj/container)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/C = locate() in container
	if(C.poisonsacs)
		result = /obj/item/weapon/storage/fancy/food_box/slider_box/toxiccarp
	..()

/datum/recipe/turkey
	reagents = list(SODIUMCHLORIDE = 1, BLACKPEPPER = 1, CORNOIL = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey

/datum/recipe/chicken_nuggets
	reagents = list(KETCHUP = 5)
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets

/datum/recipe/chicken_drumsticks
	items = list(
		/obj/item/stack/sheet/cardboard,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		)
	result = /obj/item/weapon/storage/fancy/food_box/chicken_bucket

/datum/recipe/chicken_fillet
	reagents = list(CORNOIL = 3)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken)
	result = /obj/item/weapon/reagent_containers/food/snacks/chicken_fillet

/datum/recipe/gigapuddi
	reagents = list(MILK = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi

/datum/recipe/gigapuddi/happy
	reagents = list(MILK = 15, SUGAR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy

/datum/recipe/gigapuddi/anger
	reagents = list(MILK = 15, SODIUMCHLORIDE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger

//LIVING PUDDI
//This is a terrible idea.

/datum/recipe/livingpuddi/happy
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi/happy

/datum/recipe/livingpuddi/anger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi/anger

/datum/recipe/livingpuddi
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/gigapuddi,
		/obj/item/slime_extract/grey
		)
	result = /mob/living/simple_animal/puddi


// END OF LIVING PUDDI SHIT THAT PROBABLY WON'T WORK

/datum/recipe/flan
	reagents = list(MILK = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flan

/datum/recipe/honeyflan
	reagents = list(MILK = 5,CINNAMON = 5,"honey" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/honeyflan

/datum/recipe/omurice
	reagents = list(RICE = 5, KETCHUP = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice

/datum/recipe/omurice/heart
	reagents = list(RICE = 5, KETCHUP = 5, SUGAR = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/heart

/datum/recipe/omurice/face
	reagents = list(RICE = 5, KETCHUP = 5, SODIUMCHLORIDE = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/omurice/face

/datum/recipe/bluespace
	reagents = list(MILK = 5, FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
		/obj/item/bluespace_crystal
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace

/datum/recipe/yellowcake
	reagents = list(URANIUM = 5, RADIUM = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcake

/datum/recipe/yellowcupcake
	reagents = list(URANIUM = 2, RADIUM = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg)
	result = /obj/item/weapon/reagent_containers/food/snacks/yellowcupcake

/datum/recipe/cookiebowl
	reagents = list(FLOUR = 5, SUGAR = 2)
	items = list (
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cookiebowl

/datum/recipe/chococherrycake
	reagents = list(MILK = 5, FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/chococherrycake

/datum/recipe/pumpkinbread
	reagents = list(FLOUR = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread

/datum/recipe/corndog
	reagents = list(FLOUR = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/weapon/reagent_containers/food/snacks/corndog

/datum/recipe/cornydog
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi,
		/obj/item/stack/rods)
	result = /obj/item/weapon/reagent_containers/food/snacks/cornydog

/datum/recipe/higashikata
	reagents = list(CREAM = 20, WATERMELONJUICE = 10, SLIMEJELLY = 10, ICE = 20, MILK = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/higashikata

/datum/recipe/sundae
	reagents = list(CREAM = 10, ICE = 10, MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundae

/datum/recipe/potatosalad
	reagents = list(WATER = 10, MILK = 10, SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potatosalad

/datum/recipe/coleslaw
	reagents = list(VINEGAR = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/coleslaw

/datum/recipe/risotto
	reagents = list(RICE = 10, WINE = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/risotto

/datum/recipe/potentham
	reagents = list(PLASMA = 10)
	items = list(
		/obj/item/weapon/aiModule/core/asimov,
		/obj/item/robot_parts/head,
		/obj/item/weapon/handcuffs

		)
	result = /obj/item/weapon/reagent_containers/food/snacks/potentham

/datum/recipe/chococoin
	reagents = list(MILK = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/weapon/reagent_containers/food/snacks/chococoin

/datum/recipe/claypot//it just works
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/ore/glass,
		)
	result = /obj/item/claypot

/datum/recipe/cinnamonroll
	reagents = list(MILK = 5, SUGAR = 10, FLOUR = 5, CINNAMON = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonroll

/datum/recipe/cinnamonpie
	reagents = list(MILK = 5, SUGAR = 10, FLOUR = 10, CINNAMON = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/cinnamonpie

/datum/recipe/ijzerkoekje
	reagents = list(FLOUR = 30, IRON = 30)
	result = /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy
	name = "Helper Dummy"
	desc = "You should never see this text."

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy/New()
	for(var/i = 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje(get_turf(src))
	qdel(src)

///Vox Food///
/datum/recipe/gravyboat
	reagents = list(WATER = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/condiment/gravy

/datum/recipe/sundayroast
	reagents = list(GRAVY = 10,SODIUMCHLORIDE = 1, BLACKPEPPER = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundayroast

/datum/recipe/risenshiny
	reagents = list(FLOUR = 10, GRAVY = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/risenshiny

/datum/recipe/mushnslush
	reagents = list(GRAVY = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushnslush

/datum/recipe/breadfruitpie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit

/datum/recipe/woodapplejam
	reagents = list(SUGAR = 20)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/woodapplejam

/datum/recipe/candiedwoodapple
	reagents = list(SUGAR = 5, WATER = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple

/datum/recipe/voxstew
	reagents = list(GRAVY = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/voxstew

/datum/recipe/garlicbread
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/garlicbread

/datum/recipe/flammkuche
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		/obj/item/weapon/reagent_containers/food/snacks/grown/garlic,
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/flammkuchen

/datum/recipe/welcomepie
	reagents = list(FLOUR = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/welcomepie

/datum/recipe/zhulongcaofan
	reagents = list(RICE = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan

/datum/recipe/zhulongcaofan/make_food(var/obj/container as obj)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher/P in container)
		P.reagents.del_reagent(SACID) //This cleanses the plant.
	return ..()

/datum/recipe/bacon
	items = list(/obj/item/weapon/reagent_containers/food/snacks/meat/box)
	result = /obj/item/weapon/reagent_containers/food/snacks/bacon

/datum/recipe/porktenderloin
	reagents = list(GRAVY = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/porktenderloin

/datum/recipe/sweetandsourpork
	reagents = list(SOYSAUCE = 10, SUGAR = 10) //Will require trading with humans to get soy, but they can make their own acid.
	items = (
		/obj/item/weapon/reagent_containers/food/snacks/meat/box
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/sweetandsourpork

/datum/recipe/hoboburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/box,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/hoboburger

/datum/recipe/hoboburger/make_food(var/obj/container as obj)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher/P in container)
		P.reagents.del_reagent(SACID) //This cleanses the plant.
	return ..()

/datum/recipe/reclaimed
	reagents = list(VOMIT = 5, ANTI_TOXIN = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/reclaimed

/datum/recipe/bruisepack
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/stack/medical/bruise_pack

/datum/recipe/ointment
	reagents = list(DERMALINE = 5)
	result = /obj/item/stack/medical/ointment

/datum/recipe/poachedaloe
	reagents = list(WATER = 5)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/weapon/reagent_containers/food/snacks/poachedaloe

/datum/recipe/toxicmint
	reagents = list(SUGAR = 1)
	items = list(/obj/item/weapon/reagent_containers/food/snacks/grown/aloe)
	result = /obj/item/weapon/reagent_containers/food/snacks/mint

/datum/recipe/vanishingstew
	reagents = list(VAPORSALT = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
		)
	result = /obj/item/weapon/reagent_containers/food/snacks/vanishingstew
