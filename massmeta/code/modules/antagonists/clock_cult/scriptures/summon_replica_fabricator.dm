//==================================//
// !       Replica Fab       ! //
//==================================//

/datum/clockcult/scripture/replica_fabricator
	name = "производитель реплик"
	desc = "Призывает производителя реплик, который может изготовить латунь для строительства защитных сооружений."
	tip = "Создавай латунь и строй укрепления."
	button_icon_state = "Replica Fabricator"
	power_cost = 400
	cogs_required = 2
	invokation_time = 50
	invokation_text = list("Их технологии не сравнятся с мощью Дви'гателя.")
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/replica_fabricator/invoke_success()
	var/obj/item/clockwork/replica_fabricator/RF = new(get_turf(invoker))
	invoker.put_in_inactive_hand(RF)
