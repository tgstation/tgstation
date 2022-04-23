/datum/supply_pack/armament

/datum/supply_pack/armament/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	/*
	var/obj/structure/container = .
	for(var/obj/item/gun/gun_actually in container.contents)
		if(gun_actually.company_flag & COMPANY_SCARBOROUGH) //illegal company doesn't care about pins
			continue
		QDEL_NULL(gun_actually.pin)
		var/obj/item/firing_pin/permit_pin/new_pin = new(gun_actually)
		gun_actually.pin = new_pin
*/
