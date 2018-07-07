/obj/structure/fermenting_barrel
	name = "wooden barrel"
	desc = "A large wooden barrel. You can ferment fruits and such inside it, or just use it to hold liquid."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = FALSE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	var/open = FALSE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	max_integrity = 300
	var/list/ferment_times = list()

/obj/structure/fermenting_barrel/Initialize()
	create_reagents(500) //Half of a beer keg, since it can be refilled.
	. = ..()

/obj/structure/fermenting_barrel/Destroy()
	QDEL_LIST(ferment_times)
	. = ..()

/obj/structure/fermenting_barrel/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It is currently [open?"open, letting you pour liquids in.":"closed, letting you draw liquids from the tap."]</span>")

/obj/structure/fermenting_barrel/process()
	if(contents.len == 0)
		STOP_PROCESSING(SSobj,src)
		return

	for(var/obj/item/reagent_containers/food/snacks/grown/fruit in contents)
		if(ferment_times["[REF(fruit)]"])
			ferment_times["[REF(fruit)]"]--
		else
			ferment_times -= "[REF(fruit)]"
			if(fruit.reagents)
				fruit.reagents.trans_to(src, fruit.reagents.total_volume)
			var/amount = fruit.seed.potency / 2
			if(fruit.distill_reagent)
				reagents.add_reagent(fruit.distill_reagent, amount)
				qdel(fruit)
				return
			else
				var/data = list()
				data["name"] = "[initial(fruit.name)] wine"
				data["color"] = fruit.filling_color
				data["boozepwr"] = fruit.wine_power
				data["taste"] = fruit.tastes[1]
				if(fruit.wine_flavor)
					data["taste"] = fruit.wine_flavor
				var/power_desc = "flavorful"
				if(data["boozepwr"] >= 15)
					power_desc = "mild"
				if(data["boozepwr"] >= 30)
					power_desc = "rich"
				if(data["boozepwr"] >= 60)
					power_desc = "strong"
				if(data["boozepwr"] >= 80)
					power_desc = "very strong"
				if(data["boozepwr"] >= 120) //Should really only happen with strange plants...
					power_desc = "suicidally strong"
				data["desc"] = "A [power_desc] wine made from [initial(fruit.name)][fruit.gender==PLURAL?"":"s"]."
				data["species"] = fruit.seed.species
				reagents.add_reagent("fruit_wine", amount, data)
				qdel(fruit)
				return

/obj/structure/fermenting_barrel/attackby(obj/item/I, mob/user, params)
	var/obj/item/reagent_containers/food/snacks/grown/fruit = I
	if(istype(fruit))
		if(!fruit.can_distill)
			to_chat(user, "<span class='warning'>You can't distill this into anything...</span>")
			return
		else if(!user.transferItemToLoc(I,src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You place [I] into [src] to start the fermentation process.</span>")
		ferment_times["[REF(I)]"] = rand(30,60)
		START_PROCESSING(SSobj,src)
	else
		return ..()

/obj/structure/fermenting_barrel/attack_hand(mob/user)
	open = !open
	if(open)
		container_type = REFILLABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You open [src], letting you fill it.</span>")
		icon_state = "barrel_open"
	else
		container_type = DRAINABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You close [src], letting you draw from its tap.</span>")
		icon_state = "barrel"

/datum/crafting_recipe/fermenting_barrel
	name = "Wooden Barrel"
	result = /obj/structure/fermenting_barrel
	reqs = list(/obj/item/stack/sheet/mineral/wood = 30)
	time = 50
	category = CAT_PRIMAL
