
// see code/module/crafting/table.dm

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////


/datum/crafting_recipe/food/humanburger
	name = "Human burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain/human = 1
	)
	parts = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain/human = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/human
	category = CAT_BURGER

/datum/crafting_recipe/food/burger
	name = "Burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/burger/plain
	category = CAT_BURGER

/datum/crafting_recipe/food/corgiburger
	name = "Corgi burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/burger/corgi
	category = CAT_BURGER

/datum/crafting_recipe/food/appendixburger
	name = "Appendix burger"
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/appendix
	category = CAT_BURGER

/datum/crafting_recipe/food/brainburger
	name = "Brain burger"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/brain
	category = CAT_BURGER

/datum/crafting_recipe/food/xenoburger
	name = "Xeno burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/xeno = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/xeno
	category = CAT_BURGER

/datum/crafting_recipe/food/bearger
	name = "Bearger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/bear = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bearger
	category = CAT_BURGER

/datum/crafting_recipe/food/fishburger
	name = "Fish burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/fish
	category = CAT_BURGER

/datum/crafting_recipe/food/tofuburger
	name = "Tofu burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/tofu
	category = CAT_BURGER

/datum/crafting_recipe/food/ghostburger
	name = "Ghost burger"
	reqs = list(
		/obj/item/weapon/ectoplasm = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/ghost
	category = CAT_BURGER

/datum/crafting_recipe/food/clownburger
	name = "Clown burger"
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/clown
	category = CAT_BURGER

/datum/crafting_recipe/food/mimeburger
	name = "Mime burger"
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/mime
	category = CAT_BURGER

/datum/crafting_recipe/food/redburger
	name = "Red burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/red
	category = CAT_BURGER

/datum/crafting_recipe/food/orangeburger
	name = "Orange burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/orange
	category = CAT_BURGER

/datum/crafting_recipe/food/yellowburger
	name = "Yellow burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/yellow
	category = CAT_BURGER

/datum/crafting_recipe/food/greenburger
	name = "Green burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/green
	category = CAT_BURGER

/datum/crafting_recipe/food/blueburger
	name = "Blue burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/blue
	category = CAT_BURGER

/datum/crafting_recipe/food/purpleburger
	name = "Purple burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/purple
	category = CAT_BURGER

/datum/crafting_recipe/food/spellburger
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard/fake = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell
	category = CAT_BURGER

/datum/crafting_recipe/food/spellburger2
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell
	category = CAT_BURGER

/datum/crafting_recipe/food/bigbiteburger
	name = "Big bite burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 3,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bigbite
	category = CAT_BURGER

/datum/crafting_recipe/food/superbiteburger
	name = "Super bite burger"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 4,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/superbite
	category = CAT_BURGER

/datum/crafting_recipe/food/slimeburger
	name = "Jelly burger"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/slime
	category = CAT_BURGER

/datum/crafting_recipe/food/jellyburger
	name = "Jelly burger"
	reqs = list(
			/datum/reagent/consumable/cherryjelly = 5,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/cherry
	category = CAT_BURGER

/datum/crafting_recipe/food/fivealarmburger
	name = "Five alarm burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili = 2,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/fivealarm
	category = CAT_BURGER

/datum/crafting_recipe/food/ratburger
	name = "Rat burger"
	reqs = list(
			/obj/item/trash/deadmouse = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/rat
	category = CAT_BURGER

/datum/crafting_recipe/food/baseballburger
	name = "Home run baseball burger"
	reqs = list(
			/obj/item/weapon/melee/baseball_bat = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/baseball
	category = CAT_BURGER

/datum/crafting_recipe/food/baconburger
	name = "Bacon Burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat/bacon = 3,
			/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/burger/baconburger
	category = CAT_BURGER
