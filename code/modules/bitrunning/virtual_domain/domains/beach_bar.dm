/datum/lazy_template/virtual_domain/beach_bar
	name = "Бар на пляже"
	desc = "Веселая пляжная обитель, где дружелюбные скелеты подают напитки. Ребят, а как вы погибли?"
	completion_loot = list(/obj/item/toy/beach_ball = 1)
	help_text = "Это место работает на скелетной команде, и они не очень хотят делиться информацией. \
	Может быть, парочка рюмочек жидкого очарования поднимут им настроение. Как говорится, если не можешь их победить - присоединись к ним!"
	key = "beach_bar"
	map_name = "beach_bar"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/beach_bar/setup_domain(list/created_atoms)
	. = ..()

	for(var/obj/item/reagent_containers/cup/glass/drink in created_atoms)
		RegisterSignal(drink, COMSIG_GLASS_DRANK, PROC_REF(on_drink_drank))
	for(var/obj/machinery/vending/vending_machine in created_atoms)
		RegisterSignal(vending_machine, COMSIG_VENDING_DISPENSED, PROC_REF(on_vended_item))


/datum/lazy_template/virtual_domain/beach_bar/proc/on_vended_item(obj/machinery/vending/vending_machine, obj/item/vended_item)
	if(istype(vended_item, /obj/item/reagent_containers/cup/glass))
		RegisterSignal(vended_item, COMSIG_GLASS_DRANK, PROC_REF(on_drink_drank))


/// Eventually reveal the cache
/datum/lazy_template/virtual_domain/beach_bar/proc/on_drink_drank(datum/source)
	SIGNAL_HANDLER

	add_points(0.5)
