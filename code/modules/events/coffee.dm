/datum/round_event_control/coffee
	name = "Coffee"
	weight = 0
	typepath = /datum/round_event/coffee

/datum/round_event/coffee/start()
	for(var/mob/living/carbon/human/H in living_mob_list)
		H.unEquip(H.r_hand)
		var/obj/item/I = new /obj/item/weapon/reagent_containers/food/drinks/coffee
		H.equip_to_slot_or_del(I, H.r_hand)
		for(var/obj/structure/table/T in range(H,5))
			var/obj/item/J = new /obj/item/weapon/reagent_containers/food/drinks/coffee

/datum/round_event/presents/announce()
	priority_announce("Lets talk over a cup of coffee.", "Central Command Transmission")
