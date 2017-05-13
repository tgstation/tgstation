/obj/machinery/brewing_barrel
	name = "still"
	desc = "You feel like entering a fey mood."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "still"
	density = 1
	anchored = 0
	var/list/brewables = list()
	var/list/already_brewing = list()

/obj/machinery/brewing_barrel/attackby(obj/item/weapon/W, mob/user, params)
	if(is_type_in_list(W, already_brewing))
		to_chat(user, "You're already brewing that!")
		return
	var/brewing_result = W.on_brew() // list("reagents" = list("fuck", "shit"), "booze_power" = 420, "prefix" = "ass")
	if(istype(W, /obj/item/weapon/reagent_containers) && !brewing_result)
		return 0
	if(!brewing_result)
		return ..()
	if(user.drop_item())
		brewables += list(brewing_result)
		already_brewing += W.type
		to_chat(user, "You insert [W] into [src].")
		qdel(W)

/obj/machinery/brewing_barrel/attack_hand(mob/user)
	if(brewables.len)
		to_chat(user, "You brew a batch of ale.")
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/ale/AB = new(get_turf(src))
		var/datum/reagent/consumable/ethanol/customizable/ale = AB.reagents.add_reagent("customizable_ale", 75)
		var/current_highest_boozepwr = list("prefix" = "fuck", "power" = 0)
		for(var/A in brewables)
			var/list/fuckshit = A["reagents"]
			for(var/R in fuckshit)
				if(!ale.contained_reagents.has_reagent(R))
					ale.contained_reagents.add_reagent(R, 75)
			ale.boozepwr += A["booze_power"]
			if(A["booze_power"] >= current_highest_boozepwr["power"])
				current_highest_boozepwr["prefix"] = A["prefix"]
				current_highest_boozepwr["power"] = A["booze_power"]
		var/final_name = current_highest_boozepwr["prefix"]
		AB.name = "[final_name] ale"
		brewables = list()
		already_brewing = list()