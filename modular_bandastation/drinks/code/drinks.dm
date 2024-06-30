/datum/reagent/consumable/kvass
	name = "Квас"
	description = "Напиток, приготовленный путем брожения хлеба, ржи или ячменя, который обладает освежающим и слегка кисловатым вкусом."
	color = "#351300"
	nutriment_factor = 1
	taste_description = "a pleasant tartness with a hint of sweetness and a bread-like aftertaste."

/datum/glass_style/drinking_glass/kvass
	required_drink_type = /datum/reagent/consumable/kvass
	name = "стакан кваса"
	desc = "В стакане кристально чистая жидкость насыщенного темно-коричневого цвета, которая кажется почти янтарной при определенном угле освещения."
	icon = 'modular_bandastation/drinks/icons/drinks.dmi'
	icon_state = "kvass"

/datum/export/large/reagent_dispenser/kvass
	unit_name = "kvasstank"
	export_types = list(/obj/structure/reagent_dispensers/kvasstank)

/obj/structure/reagent_dispensers/kvasstank
	name = "бочка кваса"
	desc = "Ярко-желтая бочка с квасом, которая сразу привлекает внимание своим насыщенным цветом. Она выполнена в классическом стиле, из толстого, прочного металла с гладкой, блестящей поверхностью. Бочка имеет цилиндрическую форму, слегка расширяясь к середине и снова сужаясь к краям."
	icon = 'modular_bandastation/drinks/icons/chemical_tanks.dmi'
	icon_state = "kvass"
	reagent_id = /datum/reagent/consumable/kvass
	openable = TRUE
