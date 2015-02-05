

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////


/datum/table_recipe/burger/human
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/human

/*
/datum/recipe/burger/human/make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for (var/obj/item/weapon/reagent_containers/food/snacks/meat/human/HM in container)
			if (!HM.subjectname)
				continue
			human_name = HM.subjectname
			human_job = HM.subjectjob
			break
		var/lastname_index = findtext(human_name, " ")
		if (lastname_index)
			human_name = copytext(human_name,lastname_index+1)

		var/obj/item/weapon/reagent_containers/food/snacks/burger/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB
*/

/datum/table_recipe/burger/plain
	name = "Burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/burger/plain

/datum/table_recipe/burger/appendix
	name = "Appendix burger"
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/appendix

/datum/table_recipe/burger/brain
	name = "Brain burger"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/brain

/datum/table_recipe/burger/xeno
	name = "Xeno burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/xeno

/datum/table_recipe/burger/fish
	name = "Fish burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/fish

/datum/table_recipe/burger/tofu
	name = "Tofu burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/tofu

/datum/table_recipe/burger/ghost
	name = "Ghost burger"
	reqs = list(
		/obj/item/weapon/ectoplasm = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/ghost

/datum/table_recipe/burger/clown
	name = "Clown burger"
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/clown

/datum/table_recipe/burger/mime
	name = "Mime burger"
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/mime

/datum/table_recipe/burger/red
	name = "Red burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/red

/datum/table_recipe/burger/orange
	name = "Orange burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/orange

/datum/table_recipe/burger/yellow
	name = "Yellow burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/yellow

/datum/table_recipe/burger/green
	name = "Green burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/green

/datum/table_recipe/burger/blue
	name = "Blue burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/blue

/datum/table_recipe/burger/purple
	name = "Purple burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/purple

/datum/table_recipe/burger/spell
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/table_recipe/burger/spell2
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/table_recipe/burger/bigbite
	name = "Big bite burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat = 3,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bigbite

/datum/table_recipe/burger/superbite
	name = "Super bite burger"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/weapon/reagent_containers/food/snacks/meat = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 4,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/superbite

/datum/table_recipe/burger/slime
	name = "Jelly burger"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/slime

/datum/table_recipe/burger/jelly
	name = "Jelly burger"
	reqs = list(
			/datum/reagent/consumable/cherryjelly = 5,
			/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/cherry