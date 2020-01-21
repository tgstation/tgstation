/obj/structure/fermenting_barrel
	name = "brewing barrel"
	desc = "You feel like entering a fey mood."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "still"
	density = TRUE
	anchored = FALSE
	var/list/brewables = list()
	var/list/already_brewing = list()

/obj/structure/fermenting_barrel/attackby(obj/item/W, mob/user, params)
	if(is_type_in_list(W, already_brewing))
		to_chat(user, "You're already brewing that!")
		return FALSE
	var/brewing_result = list()
	SEND_SIGNAL(W, COMSIG_ATOM_ON_BREW, brewing_result)
	if(istype(W, /obj/item/reagent_containers) && !brewing_result)
		return FALSE
	if(!brewing_result)
		return ..()
	if(user.temporarilyRemoveItemFromInventory(W))
		seedify(W, rand(1,4))
		brewables += list(brewing_result)
		already_brewing += W.type
		to_chat(user, "You insert [W] into [src].")
		qdel(W)

/obj/structure/fermenting_barrel/attack_hand(mob/user)
	if(brewables.len)
		to_chat(user, "You brew a batch of ale.")
		var/obj/item/reagent_containers/food/drinks/wooden_mug/AB = new(get_turf(src))
		var/datum/reagent/consumable/ethanol/customizable/ale = AB.reagents.add_reagent(/datum/reagent/consumable/ethanol/customizable, 50)
		var/current_highest_boozepwr = list("prefix" = "christaincode", "power" = 0)
		for(var/A in brewables)
			var/list/christaincode = A["reagents"]
			for(var/R in christaincode)
				if(!ale.contained_reagents.has_reagent(R))
					ale.contained_reagents.add_reagent(R, 30)
			ale.boozepwr += A["booze_power"]
			if(A["booze_power"] >= current_highest_boozepwr["power"])
				current_highest_boozepwr["prefix"] = A["prefix"]
				current_highest_boozepwr["power"] = A["booze_power"]
		var/final_name = current_highest_boozepwr["prefix"]
		if(current_highest_boozepwr["prefix"] == "plump-helmet")
			AB.name = "dwarven wine"
		else
			AB.name = "[final_name] ale"
		brewables = list()
		already_brewing = list()

/datum/crafting_recipe/fermenting_barrel
	name = "Brewing Barrel"
	result = /obj/structure/fermenting_barrel
	reqs = list(/obj/item/stack/sheet/mineral/wood = 30)
	time = 50
	category = CAT_PRIMAL
