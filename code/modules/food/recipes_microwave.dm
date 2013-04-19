
// see code/datums/recipe.dm


/* No telebacon. just no...
/datum/recipe/telebacon
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/part/assembly/signaler
	)
	result = /obj/item/chem/food/snacks/telebacon

I said no!
/datum/recipe/syntitelebacon
	items = list(
		/obj/item/trash/syntiflesh,
		/obj/item/part/assembly/signaler
	)
	result = /obj/item/chem/food/snacks/telebacon
*/

/datum/recipe/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/chem/food/snacks/egg
	)
	result = /obj/item/chem/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg
	)
	result = /obj/item/chem/food/snacks/boiledegg

/*
/datum/recipe/bananaphone
	reagents = list("psilocybin" = 5) //Trippin' balls, man.
	items = list(
		/obj/item/chem/food/snacks/grown/banana,
		/obj/item/device/radio
	)
	result = /obj/item/chem/food/snacks/bananaphone
*/

/datum/recipe/jellydonut
	reagents = list("berryjuice" = 5, "flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg
	)
	result = /obj/item/chem/food/snacks/donut/jelly

/datum/recipe/jellydonut/slime
	reagents = list("slimejelly" = 5, "flour" = 5)
	result = /obj/item/chem/food/snacks/donut/slimejelly

/datum/recipe/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "flour" = 5)
	result = /obj/item/chem/food/snacks/donut/cherryjelly

/datum/recipe/donut
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg
	)
	result = /obj/item/chem/food/snacks/donut/normal

/datum/recipe/human
	//invalid recipe
	make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for (var/obj/item/chem/food/snacks/meat/human/HM in container)
			if (!HM.subjectname)
				continue
			human_name = HM.subjectname
			human_job = HM.subjectjob
			break
		var/lastname_index = findtext(human_name, " ")
		if (lastname_index)
			human_name = copytext(human_name,lastname_index+1)

		var/obj/item/chem/food/snacks/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB

/datum/recipe/human/burger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/meat/human
	)
	result = /obj/item/chem/food/snacks/human/burger

/*
/datum/recipe/monkeyburger
	items = list(
		/obj/item/chem/food/snacks/flour,
		/obj/item/chem/food/snacks/meat/monkey
	)
	result = /obj/item/chem/food/snacks/monkeyburger
*/

/datum/recipe/plainburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/meat //do not place this recipe before /datum/recipe/humanburger
	)
	result = /obj/item/chem/food/snacks/monkeyburger

/datum/recipe/syntiburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/trash/syntiflesh
	)
	result = /obj/item/chem/food/snacks/monkeyburger

/datum/recipe/brainburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/medical/organ/brain
	)
	result = /obj/item/chem/food/snacks/brainburger

/* NO FUN ALLOWED
/datum/recipe/roburger
	items = list(
		/obj/item/chem/food/snacks/flour,
		/obj/item/part/cyborg/head
	)
	result = /obj/item/chem/food/snacks/roburger
*/

/datum/recipe/xenoburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/xenomeat
	)
	result = /obj/item/chem/food/snacks/xenoburger

/datum/recipe/fishburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/carpmeat
	)
	result = /obj/item/chem/food/snacks/fishburger

/datum/recipe/tofuburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/tofu
	)
	result = /obj/item/chem/food/snacks/tofuburger

/datum/recipe/ghostburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/trash/ectoplasm
	)
	result = /obj/item/chem/food/snacks/ghostburger

/datum/recipe/clownburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/mask/gas/clown_hat,
		/* /obj/item/chem/food/snacks/grown/banana, */
	)
	result = /obj/item/chem/food/snacks/clownburger

/datum/recipe/mimeburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/head/beret
	)
	result = /obj/item/chem/food/snacks/mimeburger

/datum/recipe/waffles
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/waffles

/*
/datum/recipe/faggot
	monkeymeat_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/chem/food/snacks/faggot"
*/

/datum/recipe/donkpocket
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/faggot,
	)
	result = /obj/item/chem/food/snacks/donkpocket //SPECIAL
	proc/warm_up(var/obj/item/chem/food/snacks/donkpocket/being_cooked)
		being_cooked.warm = 1
		being_cooked.reagents.add_reagent("tricordrazine", 5)
		being_cooked.bitesize = 6
		being_cooked.name = "Warm " + being_cooked.name
		being_cooked.cooltime()
	make_food(var/obj/container as obj)
		var/obj/item/chem/food/snacks/donkpocket/being_cooked = ..(container)
		warm_up(being_cooked)
		return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/chem/food/snacks/donkpocket
	)
	result = /obj/item/chem/food/snacks/donkpocket //SPECIAL
	make_food(var/obj/container as obj)
		var/obj/item/chem/food/snacks/donkpocket/being_cooked = locate() in container
		if(being_cooked && !being_cooked.warm)
			warm_up(being_cooked)
		return being_cooked

/datum/recipe/meatbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/meatbread

/datum/recipe/syntibread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/trash/syntiflesh,
		/obj/item/trash/syntiflesh,
		/obj/item/trash/syntiflesh,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/meatbread

/*
/datum/recipe/meatbreadhuman
	flour_amount = 3
	humanmeat_amount = 3
	cheese_amount = 3
	creates = "/obj/item/chem/food/snacks/meatbread"
*/

/datum/recipe/xenomeatbread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/xenomeat,
		/obj/item/chem/food/snacks/xenomeat,
		/obj/item/chem/food/snacks/xenomeat,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/xenomeatbread

/datum/recipe/bananabread
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/banana,
	)
	result = /obj/item/chem/food/snacks/sliceable/bananabread

/datum/recipe/omelette
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/omelette

/datum/recipe/muffin
	reagents = list("milk" = 5, "flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/muffin

/datum/recipe/eggplantparm
	items = list(
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/grown/eggplant
	)
	result = /obj/item/chem/food/snacks/eggplantparm

/datum/recipe/soylenviridians
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/grown/soybeans
	)
	result = /obj/item/chem/food/snacks/soylenviridians

/datum/recipe/soylentgreen
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/meat/human,
		/obj/item/chem/food/snacks/meat/human,
	)
	result = /obj/item/chem/food/snacks/soylentgreen

/datum/recipe/carrotcake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/carrot //TODO: more carrots
	)
	result = /obj/item/chem/food/snacks/sliceable/carrotcake

/datum/recipe/cheesecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/cheesecake

/datum/recipe/plaincake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/sliceable/plaincake

/datum/recipe/meatpie
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/meat,
	)
	result = /obj/item/chem/food/snacks/meatpie

/datum/recipe/tofupie
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/tofu,
	)
	result = /obj/item/chem/food/snacks/tofupie

/datum/recipe/xemeatpie
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/xenomeat,
	)
	result = /obj/item/chem/food/snacks/xemeatpie

/datum/recipe/pie
	reagents = list("flour" = 10)
	items = list(
		 /obj/item/chem/food/snacks/grown/banana,
	)
	result = /obj/item/chem/food/snacks/pie

/datum/recipe/cherrypie
	reagents = list("flour" = 10)
	items = list(
		 /obj/item/chem/food/snacks/grown/cherries,
	)
	result = /obj/item/chem/food/snacks/cherrypie
/*
/datum/recipe/berrypie
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/chem/food/snacks/flour,
		/obj/item/chem/food/snacks/flour,
	)
	result = /obj/item/chem/food/snacks/berrypie
*/
/datum/recipe/berryclafoutis
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/berries,
	)
	result = /obj/item/chem/food/snacks/berryclafoutis

/datum/recipe/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/chem/food/snacks/xenomeat,
	)
	result = /obj/item/chem/food/snacks/wingfangchu

/datum/recipe/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg
	)
	result = /obj/item/chem/food/snacks/donut/chaos

/datum/recipe/human/kabob
	items = list(
		/obj/item/part/stack/rods,
		/obj/item/chem/food/snacks/meat/human,
		/obj/item/chem/food/snacks/meat/human,
	)
	result = /obj/item/chem/food/snacks/human/kabob

/datum/recipe/monkeykabob
	items = list(
		/obj/item/part/stack/rods,
		/obj/item/chem/food/snacks/meat/monkey,
		/obj/item/chem/food/snacks/meat/monkey,
	)
	result = /obj/item/chem/food/snacks/monkeykabob

/datum/recipe/syntikabob
	items = list(
		/obj/item/part/stack/rods,
		/obj/item/trash/syntiflesh,
		/obj/item/trash/syntiflesh,
	)
	result = /obj/item/chem/food/snacks/monkeykabob

/datum/recipe/tofukabob
	items = list(
		/obj/item/part/stack/rods,
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/tofu,
	)
	result = /obj/item/chem/food/snacks/tofukabob

/datum/recipe/tofubread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/tofubread

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/chem/food/snacks/grown/potato,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/chem/food/snacks/fries,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/cheesyfries

/datum/recipe/cubancarp
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/chili,
		/obj/item/chem/food/snacks/carpmeat,
	)
	result = /obj/item/chem/food/snacks/cubancarp

/datum/recipe/popcorn
	items = list(
		/obj/item/chem/food/snacks/grown/corn
	)
	result = /obj/item/chem/food/snacks/popcorn

/datum/recipe/fortunecookie
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/office/paper,
	)
	result = /obj/item/chem/food/snacks/fortunecookie
	make_food(var/obj/container as obj)
		var/obj/item/office/paper/paper = locate() in container
		paper.loc = null //prevent deletion
		var/obj/item/chem/food/snacks/fortunecookie/being_cooked = ..(container)
		paper.loc = being_cooked
		being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
		return being_cooked
	check_items(var/obj/container as obj)
		. = ..()
		if (.)
			var/obj/item/office/paper/paper = locate() in container
			if (!paper.info)
				return 0
		return .

/datum/recipe/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/chem/food/snacks/meat
	)
	result = /obj/item/chem/food/snacks/meatsteak

/datum/recipe/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/trash/syntiflesh
	)
	result = /obj/item/chem/food/snacks/meatsteak

/datum/recipe/pizzamargherita
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/sliceable/pizza/margherita

/datum/recipe/meatpizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/syntipizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/trash/syntiflesh,
		/obj/item/trash/syntiflesh,
		/obj/item/trash/syntiflesh,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom,
		/obj/item/chem/food/snacks/grown/mushroom,
		/obj/item/chem/food/snacks/grown/mushroom,
		/obj/item/chem/food/snacks/grown/mushroom,
		/obj/item/chem/food/snacks/grown/mushroom,
	)
	result = /obj/item/chem/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/eggplant,
		/obj/item/chem/food/snacks/grown/carrot,
		/obj/item/chem/food/snacks/grown/corn,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/libertycap,
		/obj/item/chem/food/snacks/grown/mushroom/libertycap,
		/obj/item/chem/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/chem/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/amanita,
		/obj/item/chem/food/snacks/grown/mushroom/amanita,
		/obj/item/chem/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/chem/food/snacks/amanitajelly
	make_food(var/obj/container as obj)
		var/obj/item/chem/food/snacks/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("amatoxin")
		return being_cooked

/datum/recipe/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/faggot ,
		/obj/item/chem/food/snacks/grown/carrot,
		/obj/item/chem/food/snacks/grown/potato,
	)
	result = /obj/item/chem/food/snacks/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/carrot,
		/obj/item/chem/food/snacks/grown/corn,
		/obj/item/chem/food/snacks/grown/eggplant,
		/obj/item/chem/food/snacks/grown/potato,
	)
	result = /obj/item/chem/food/snacks/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/botany/grown/nettle,
		/obj/item/chem/food/snacks/grown/potato,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/nettlesoup

/datum/recipe/wishsoup
	reagents = list("water" = 20)
	result= /obj/item/chem/food/snacks/wishsoup

/datum/recipe/hotchili
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/grown/chili,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/hotchili

/datum/recipe/coldchili
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/grown/icepepper,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/coldchili

/datum/recipe/amanita_pie
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/chem/food/snacks/amanita_pie

/datum/recipe/plump_pie
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/chem/food/snacks/plump_pie

/datum/recipe/spellburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/chem/food/snacks/spellburger

/datum/recipe/spellburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/chem/food/snacks/spellburger

/datum/recipe/bigbiteburger
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
	)
	result = /obj/item/chem/food/snacks/bigbiteburger

/datum/recipe/enchiladas
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/grown/chili,
		/obj/item/chem/food/snacks/grown/chili,
		/obj/item/chem/food/snacks/grown/corn,
	)
	result = /obj/item/chem/food/snacks/enchiladas

/datum/recipe/creamcheesebread
	reagents = list("flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sliceable/creamcheesebread

/datum/recipe/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/monkeycube,
		/obj/item/chem/food/snacks/grown/banana,
	)
	result = /obj/item/chem/food/snacks/monkeysdelight

/datum/recipe/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 15)
	result = /obj/item/chem/food/snacks/baguette

/datum/recipe/fishandchips
	items = list(
		/obj/item/chem/food/snacks/fries,
		/obj/item/chem/food/snacks/carpmeat,
	)
	result = /obj/item/chem/food/snacks/fishandchips

/datum/recipe/birthdaycake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/clothing/head/cakehat
	)
	result = /obj/item/chem/food/snacks/sliceable/birthdaycake

/datum/recipe/bread
	reagents = list("flour" = 15)
	result = /obj/item/chem/food/snacks/sliceable/bread

/datum/recipe/sandwich
	items = list(
		/obj/item/chem/food/snacks/meatsteak,
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/sandwich

/datum/recipe/toastedsandwich
	items = list(
		/obj/item/chem/food/snacks/sandwich
	)
	result = /obj/item/chem/food/snacks/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/grilledcheese

/datum/recipe/tomatosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/tomatosoup

/datum/recipe/rofflewaffles
	reagents = list("psilocybin" = 5, "flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/rofflewaffles

/datum/recipe/stew
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/grown/potato,
		/obj/item/chem/food/snacks/grown/carrot,
		/obj/item/chem/food/snacks/grown/eggplant,
		/obj/item/chem/food/snacks/grown/mushroom,
	)
	result = /obj/item/chem/food/snacks/stew

/datum/recipe/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/chem/food/snacks/breadslice,
	)
	result = /obj/item/chem/food/snacks/jelliedtoast/slime

/datum/recipe/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/chem/food/snacks/breadslice,
	)
	result = /obj/item/chem/food/snacks/jelliedtoast/cherry

/datum/recipe/milosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/soydope,
		/obj/item/chem/food/snacks/soydope,
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/tofu,
	)
	result = /obj/item/chem/food/snacks/milosoup

/datum/recipe/stewedsoymeat
	items = list(
		/obj/item/chem/food/snacks/soydope,
		/obj/item/chem/food/snacks/soydope,
		/obj/item/chem/food/snacks/grown/carrot,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/stewedsoymeat

/datum/recipe/spagetti
	reagents = list("flour" = 5)
	result= /obj/item/chem/food/snacks/spagetti

/datum/recipe/boiledspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/chem/food/snacks/spagetti,
	)
	result = /obj/item/chem/food/snacks/boiledspagetti

/datum/recipe/pastatomato
	reagents = list("water" = 5)
	items = list(
		/obj/item/chem/food/snacks/spagetti,
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/grown/tomato,
	)
	result = /obj/item/chem/food/snacks/pastatomato

/datum/recipe/poppypretzel
	reagents = list("flour" = 5)
	items = list(
		/obj/item/botany/seeds/poppyseed,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/poppypretzel

/datum/recipe/meatballspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/chem/food/snacks/spagetti,
		/obj/item/chem/food/snacks/faggot,
		/obj/item/chem/food/snacks/faggot,
	)
	result = /obj/item/chem/food/snacks/meatballspagetti

/datum/recipe/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/chem/food/snacks/spagetti,
		/obj/item/chem/food/snacks/faggot,
		/obj/item/chem/food/snacks/faggot,
		/obj/item/chem/food/snacks/faggot,
		/obj/item/chem/food/snacks/faggot,
	)
	result = /obj/item/chem/food/snacks/spesslaw

/datum/recipe/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/meat,
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/grown/tomato,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/cheesewedge,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,

	)
	result = /obj/item/chem/food/snacks/superbiteburger

/datum/recipe/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/apple
	)
	result = /obj/item/chem/food/snacks/candiedapple

/datum/recipe/applepie
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/apple,
	)
	result = /obj/item/chem/food/snacks/applepie

/datum/recipe/applecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/apple,
		/obj/item/chem/food/snacks/grown/apple,
	)
	result = /obj/item/chem/food/snacks/sliceable/applecake

/datum/recipe/slimeburger
	reagents = list("slimejelly" = 5, "flour" = 15)
	items = list()
	result = /obj/item/chem/food/snacks/jellyburger/slime

/datum/recipe/jellyburger
	reagents = list("cherryjelly" = 5, "flour" = 15)
	items = list()
	result = /obj/item/chem/food/snacks/jellyburger/cherry

/datum/recipe/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/breadslice,
	)
	result = /obj/item/chem/food/snacks/twobread

/datum/recipe/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/breadslice,
	)
	result = /obj/item/chem/food/snacks/jellysandwich/slime

/datum/recipe/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/chem/food/snacks/breadslice,
		/obj/item/chem/food/snacks/breadslice,
	)
	result = /obj/item/chem/food/snacks/jellysandwich/cherry

/datum/recipe/orangecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/orange,
		/obj/item/chem/food/snacks/grown/orange,
	)
	result = /obj/item/chem/food/snacks/sliceable/orangecake

/datum/recipe/limecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/lime,
		/obj/item/chem/food/snacks/grown/lime,
	)
	result = /obj/item/chem/food/snacks/sliceable/limecake

/datum/recipe/lemoncake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/lemon,
		/obj/item/chem/food/snacks/grown/lemon,
	)
	result = /obj/item/chem/food/snacks/sliceable/lemoncake

/datum/recipe/chocolatecake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/chocolatebar,
		/obj/item/chem/food/snacks/chocolatebar,
	)
	result = /obj/item/chem/food/snacks/sliceable/chocolatecake

/datum/recipe/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/bloodtomato,
		/obj/item/chem/food/snacks/grown/bloodtomato,
	)
	result = /obj/item/chem/food/snacks/bloodsoup


/datum/recipe/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	items = list(
	)
	result = /obj/item/chem/food/snacks/slimesoup

/datum/recipe/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/banana,
		/obj/item/mining/ore/clown,
	)
	result = /obj/item/chem/food/snacks/clownstears
/*
/datum/recipe/boiledslimeextract
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_core,
	)
	result = /obj/item/chem/food/snacks/boiledslimecore
*/
/datum/recipe/braincake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/medical/organ/brain
	)
	result = /obj/item/chem/food/snacks/sliceable/braincake

/datum/recipe/chocolateegg
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/chocolatebar,
	)
	result = /obj/item/chem/food/snacks/chocolateegg

/datum/recipe/sausage
	items = list(
		/obj/item/chem/food/snacks/faggot,
		/obj/item/chem/food/snacks/meat,
	)
	result = /obj/item/chem/food/snacks/sausage

/datum/recipe/fishfingers
	reagents = list("flour" = 10)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/carpmeat,
	)
	result = /obj/item/chem/food/snacks/fishfingers

/datum/recipe/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/badrecipe,
		/obj/item/chem/food/snacks/tofu,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/cheesewedge,
	)
	result = /obj/item/chem/food/snacks/mysterysoup

/datum/recipe/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5, "flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/pumpkin,
		/obj/item/chem/food/snacks/egg,
	)
	result = /obj/item/chem/food/snacks/sliceable/pumpkinpie

/datum/recipe/plumphelmetbiscuit
	reagents = list("flour" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/chem/food/snacks/plumphelmetbiscuit

/datum/recipe/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/chem/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/chem/food/snacks/mushroomsoup

/datum/recipe/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/chem/food/snacks/chawanmushi

/datum/recipe/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/chem/food/snacks/grown/whitebeet,
		/obj/item/chem/food/snacks/grown/cabbage,
	)
	result = /obj/item/chem/food/snacks/beetsoup

/datum/recipe/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 15)
	items = list(
		/obj/item/chem/food/snacks/egg,
		/obj/item/chem/food/snacks/grown/goldapple,
	)
	result = /obj/item/chem/food/snacks/appletart

/datum/recipe/herbsalad
	items = list(
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/apple,
	)
	result = /obj/item/chem/food/snacks/herbsalad
	make_food(var/obj/container as obj)
		var/obj/item/chem/food/snacks/herbsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

/datum/recipe/aesirsalad
	items = list(
		/obj/item/chem/food/snacks/grown/ambrosiadeus,
		/obj/item/chem/food/snacks/grown/ambrosiadeus,
		/obj/item/chem/food/snacks/grown/ambrosiadeus,
		/obj/item/chem/food/snacks/grown/goldapple,
	)
	result = /obj/item/chem/food/snacks/aesirsalad

/datum/recipe/validsalad
	items = list(
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/chem/food/snacks/grown/potato,
		/obj/item/chem/food/snacks/faggot,
	)
	result = /obj/item/chem/food/snacks/validsalad
	make_food(var/obj/container as obj)
		var/obj/item/chem/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

/datum/recipe/cracker
	reagents = list("flour" = 5, "sodiumchloride" = 1)
	result = /obj/item/chem/food/snacks/cracker