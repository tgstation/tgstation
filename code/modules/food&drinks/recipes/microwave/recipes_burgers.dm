
// see code/datums/recipe.dm

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////

/datum/recipe/burger/human
	make_food(var/obj/container as obj)
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

	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/human

/datum/recipe/burger/plain
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat //do not place this recipe before /datum/recipe/humanburger
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger

/datum/recipe/burger/appendix
	reagents = list("flour" = 5)
	items = list(
		/obj/item/organ/appendix
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/appendix

/datum/recipe/burger/brain
	reagents = list("flour" = 5)
	items = list(
		/obj/item/organ/brain
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/brain

/datum/recipe/burger/xeno
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/xeno

/datum/recipe/burger/fish
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/fish

/datum/recipe/burger/tofu
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/tofu

/datum/recipe/burger/ghost
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/ectoplasm
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/ghost

/datum/recipe/burger/clown
	reagents = list("flour" = 5)
	items = list(
		/obj/item/device/radio/headset/clown_hat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/clown

/datum/recipe/burger/mime
	reagents = list("flour" = 5)
	items = list(
		/obj/item/device/radio/headset/mime
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/mime

/datum/recipe/burger/red
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/red,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/red

/datum/recipe/burger/orange
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/orange,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/orange

/datum/recipe/burger/yellow
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/yellow,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/yellow

/datum/recipe/burger/green
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/green,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/green

/datum/recipe/burger/blue
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/blue,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/blue

/datum/recipe/burger/purple
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/toy/crayon/purple,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/purple

/datum/recipe/burger/spell
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/recipe/burger/spell
	reagents = list("flour" = 5)
	items = list(
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/recipe/burger/bigbite
	reagents = list("flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bigbite

/datum/recipe/burger/superbite
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "flour" = 15)
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
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/superbite

/datum/recipe/burger/slime
	reagents = list("slimejelly" = 5, "flour" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/slime

/datum/recipe/burger/jelly
	reagents = list("cherryjelly" = 5, "flour" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/cherry
