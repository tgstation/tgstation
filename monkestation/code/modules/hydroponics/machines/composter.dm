/obj/machinery/composters
	name = "NT-Brand Auto Composter"
	desc = "Just insert your bio degradable materials and it will produce compost."
	icon = 'monkestation/icons/obj/machines/composter.dmi'
	icon_state = "composter"
	density = TRUE

	//current biomatter level
	var/biomatter = 0

	var/list/chem_choices = list("Saltpetre (5 Biomatter/U)")
	var/list/cost_list = list("Saltpetre (5 Biomatter/U)" = 5)
	var/list/name_to_chem = list("Saltpetre (5 Biomatter/U)" = /datum/reagent/saltpetre)

/obj/machinery/composters/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/seeds))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/food/grown))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/reagent_containers/cup))
		attempt_fill(attacking_item, user)

/obj/machinery/composters/update_desc()
	. = ..()
	. += "Biomatter: [biomatter]"

/obj/machinery/composters/proc/compost(atom/composter)
	if(istype(composter, /obj/item/seeds))
		biomatter++
		qdel(composter)
	if(istype(composter, /obj/item/food/grown))
		biomatter += 4
	update_desc()

/obj/machinery/composters/proc/attempt_fill(obj/item/reagent_containers/cup/filler, mob/user)
	var/max_capacity = (filler.volume - filler.reagents.total_volume)
	var/chem_choice = tgui_input_list(user, "Choose a reagent to fill", "[name]", chem_choices)
	if(!chem_choice)
		return
	var/cost = cost_list[chem_choice]

	var/max_amount = min(max_capacity, round(biomatter / cost))
	var/amount = tgui_input_number(user, "Choose an amount", "[name]", 0, max_amount, 0)
	if(!amount)
		return

	filler.reagents.add_reagent(name_to_chem[chem_choice], amount)

/obj/item/seeds/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(over, /obj/machinery/composters))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/seeds/seed in src_location)
			dropped.compost(seed)

/obj/item/food/grown/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(over, /obj/machinery/composters))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/food/grown/grown in src_location)
			dropped.compost(grown)
