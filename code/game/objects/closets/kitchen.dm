/obj/structure/closet/secure_closet/freezer
	var
		target_temp = T0C - 40
		cooling_power = 40

	return_air()
		var/datum/gas_mixture/gas = (..())
		if(!gas)	return null
		var/datum/gas_mixture/newgas = new/datum/gas_mixture()
		newgas.oxygen = gas.oxygen
		newgas.carbon_dioxide = gas.carbon_dioxide
		newgas.nitrogen = gas.nitrogen
		newgas.toxins = gas.toxins
		newgas.volume = gas.volume
		newgas.temperature = gas.temperature
		if(newgas.temperature <= target_temp)	return

		if((newgas.temperature - cooling_power) > target_temp)
			newgas.temperature -= cooling_power
		else
			newgas.temperature = target_temp
		return newgas



/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

	New()
		..()
		sleep(2)
		for(var/i = 0, i < 16, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/flour(src)
		new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)
		return


/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()



/obj/structure/closet/secure_closet/freezer/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 4, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)
		return



/obj/structure/closet/secure_closet/freezer/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
		for(var/i = 0, i < 2, i++)
			new /obj/item/kitchen/egg_box(src)
		return



/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(access_heads_vault)


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 3, i++)
			new /obj/item/weapon/spacecash/c1000(src)
		for(var/i = 0, i < 5, i++)
			new /obj/item/weapon/spacecash/c500(src)
		for(var/i = 0, i < 6, i++)
			new /obj/item/weapon/spacecash/c200(src)
		return








