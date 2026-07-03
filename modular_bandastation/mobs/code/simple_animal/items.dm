
/obj/item/food/meat/slab/corgi
	icon = 'modular_bandastation/mobs/icons/items.dmi'
	icon_state = "meat_dog"

/obj/item/food/meat/slab/pug
	icon = 'modular_bandastation/mobs/icons/items.dmi'
	icon_state = "meat_dog"

/obj/item/food/meat/slab/corgi/dog
	name = "собачье мясо"
	desc = "Не слишком питательно, Но говорят деликатес для космокорейцев."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/epinephrine = 2
	)

/obj/item/food/meat/slab/corgi/dog/security
	name = "мясо безопасника"
	desc = "Мясо наполненное чувством мужества и долга."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/epinephrine = 5
	)
	tastes = list("meat" = 1, "безопасность" = 1, "храбрость" = 1, "долг" = 1)

/obj/item/food/meat/slab/mouse
	icon = 'modular_bandastation/mobs/icons/items.dmi'
	icon_state = "meat_clear"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/coffee = 2, // Крысы пьют много кофе и всякую гадость
		/datum/reagent/toxin = 1
	)

/obj/effect/decal/remains/mouse
	name = "останки"
	desc = "Бывший грызун..."
	icon = 'modular_bandastation/mobs/icons/items.dmi'
	icon_state = "mouse_skeleton"
