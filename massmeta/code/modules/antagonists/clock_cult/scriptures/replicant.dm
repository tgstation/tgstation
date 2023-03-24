//==================================//
// !           Replicant          ! //
//==================================//
/datum/clockcult/scripture/replicant
	name = "Репликант"
	desc = "Заставляет механизм вызывать свою копию, позволяя вам заменить механизмы, если они потерялись."
	tip = "Сделать запасной механизм."
	button_icon_state = "Replicant"
	power_cost = 50
	invokation_time = 30
	invokation_text = list("блять, а где механизм...")
	category = SPELLTYPE_SERVITUDE
	cogs_required = 0

/datum/clockcult/scripture/replicant/invoke_success()
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(invoker))
	invoker.put_in_hands(slab)
