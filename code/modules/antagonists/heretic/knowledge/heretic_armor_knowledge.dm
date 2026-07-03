/datum/heretic_knowledge/armor
	name = "Ритуал брони"
	desc = "Позволяет трансмутировать стол (или костюм) и маску, чтобы создать Потустороннюю броню. \
		Потусторонняя броня обеспечивает отличную защиту, в тоже время, когда надет капюшон служит фокусировщиком заклинаний. "
	gain_text = "Ржавые Холмы приветствовали Кузнеца своей щедростью. И Кузнец ответил взаимностью на их щедрость."

	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)
	abstract_type = /datum/heretic_knowledge/armor
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 1

/datum/heretic_knowledge/armor/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return
	SEND_SIGNAL(heretic_datum, COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST)
	heretic_datum.gain_knowledge(/datum/heretic_knowledge/knowledge_ritual)
