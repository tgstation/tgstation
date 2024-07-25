#define INCUBATOR_DISH_GROWTH  (1 << 0)
#define INCUBATOR_DISH_REAGENT (1 << 1)
#define INCUBATOR_DISH_MAJOR   (1 << 2)
#define INCUBATOR_DISH_MINOR   (1 << 3)

/obj/machinery/disease2/incubator
	name = "pathogenic incubator"
	desc = "Uses radiation to accelerate the incubation of pathogen. The dishes must be filled with reagents for the incubation to have any effects."
	density = TRUE
	anchored = TRUE
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "incubator"

	circuit = /obj/item/circuitboard/machine/incubator

	light_color = "#6496FA"
	light_outer_range = 2
	light_power = 1

	idle_power_usage = 100
	active_power_usage = 200

	// Contains instances of /dish_incubator_dish.
	var/list/dish_data = list(null, null, null)

	var/on = FALSE

	var/mutatechance = 10
	var/growthrate = 8
	var/can_focus = FALSE //Whether the machine can focus on an effect to mutate it or not
	var/effect_focus = 0 //What effect of the disease are we focusing on?

/obj/machinery/disease2/incubator/New()
	. = ..()
	RefreshParts()

/obj/machinery/disease2/incubator/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/disease2/incubator/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/disease2/incubator/RefreshParts()
	. = ..()
	var/scancount = 0
	var/lasercount = 0
	for(var/datum/stock_part/scanning_module/SP in component_parts)
		scancount += SP.tier * 0.5
	for(var/datum/stock_part/micro_laser/SP in component_parts)
		lasercount += SP.tier * 0.5
	if(lasercount >= 4)
		can_focus = TRUE
	else
		can_focus = FALSE
	mutatechance = initial(mutatechance) * max(1, scancount)
	growthrate = initial(growthrate) + lasercount


/obj/machinery/disease2/incubator/attackby(obj/item/I, mob/living/user, params)
	. = ..()

	if (machine_stat & (BROKEN))
		to_chat(user, span_warning("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return FALSE

	if (.)
		return

	if (istype(I, /obj/item/weapon/virusdish))
		for (var/i in 1 to dish_data.len)
			if (dish_data[i] == null) // Empty slot
				addDish(I, user, i)
				return TRUE

		to_chat(user, span_warning("There is no more room inside \the [src]. Remove a dish first."))
		return FALSE


/obj/machinery/disease2/incubator/proc/addDish(obj/item/weapon/virusdish/VD, mob/user, slot)
	if (!VD.open)
		to_chat(user, span_warning("You must open the dish's lid before it can be put inside the incubator. Be sure to wear proper protection first (at least a sterile mask and latex gloves)."))
		return

	if (dish_data[slot] != null)
		to_chat(user,span_warning("This slot is already occupied. Remove the dish first."))
		return

	if (!user.transferItemToLoc(VD, src))
		return

	var/dish_incubator_dish/dish_datum = new
	dish_datum.dish = VD
	dish_data[slot] = dish_datum

	visible_message(span_notice("\The [user] adds \the [VD] to \the [src]."),span_notice("You add \the [VD] to \the [src]."))
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	update_appearance()


/obj/machinery/disease2/incubator/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)
		if ("power")
			on = !on
			if (on)
				for (var/dish_incubator_dish/dish_datum in dish_data)
					if (dish_datum.dish.contained_virus)
						dish_datum.dish.contained_virus.log += "<br />[ROUND_TIME()] Incubation started by [key_name(usr)]"

			update_appearance()
			return TRUE

		if ("ejectdish")
			var/slot = text2num(params["slot"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.forceMove(loc)
			if (Adjacent(usr))
				usr.put_in_hands(dish_datum.dish)

			dish_datum.dish.update_appearance()
			dish_data[slot] = null
			update_appearance()
			return TRUE

		if ("insertdish")
			var/slot = text2num(params["slot"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/mob/living/user = usr
			if (!isliving(user))
				return TRUE

			var/obj/item/weapon/virusdish/VD = user.get_active_hand()
			if (istype(VD))
				addDish(VD, user, slot)

			update_appearance()
			return TRUE

		if ("examinedish")
			var/slot = text2num(params["slot"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.examine(usr)
			return TRUE

		if ("flushdish")
			var/slot = text2num(params["slot"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.reagents.clear_reagents()
			return TRUE
		if ("changefocus")
			var/slot = text2num(params["slot"])
			if(slot == null || slot < 1 || slot > dish_data.len)
				return TRUE
			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE
			var/stage_to_focus = input(usr, "Choose a stage to focus on. This will block symptoms from other stages from being mutated. Input 0 to disable effect focusing.", "Choose a stage.") as num
			if(!stage_to_focus)
				to_chat(usr, span_notice("The effect focusing is now turned off."))
			else
				to_chat(usr, span_notice("\The [src] will now focus on stage [stage_to_focus]."))
			effect_focus = stage_to_focus
			return TRUE

/obj/machinery/disease2/incubator/attack_hand(mob/user)
	. = ..()
	if (machine_stat & (BROKEN))
		to_chat(user, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if (machine_stat & (NOPOWER))
		to_chat(user, span_notice("Deprived of power, \the [src] is unresponsive."))
		for (var/i in 1 to dish_data.len)
			var/dish_incubator_dish/dish_datum = dish_data[i]
			if (dish_datum == null)
				continue

			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish_datum.dish.forceMove(loc)
			update_appearance()
			dish_data[i] = null
			sleep(1)

		return

	if (.)
		return

	ui_interact(user)



/obj/machinery/disease2/incubator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DiseaseIncubator", "Incubator")
		ui.open()

/obj/machinery/disease2/incubator/ui_data(mob/user)
	// this is the data which will be sent to the ui
	var/list/data = list()

	data["on"] = on
	data["can_focus"] = can_focus
	data["focus_stage"] = effect_focus
	var/list/dish_ui_data = list()
	data["dishes"] = dish_ui_data

	for (var/i = 1 to dish_data.len)
		var/dish_incubator_dish/dish_datum = dish_data[i]
		var/list/dish_ui_datum = list()
		// tfw no linq
		dish_ui_data[++dish_ui_data.len] = dish_ui_datum

		var/inserted = dish_datum != null
		dish_ui_datum["inserted"] = inserted
		if (!inserted)
			dish_ui_datum["name"] = "Empty Slot"
			continue

		dish_ui_datum["name"] = dish_datum.dish.name
		dish_ui_datum["growth"] = dish_datum.dish.growth
		dish_ui_datum["reagents_volume"] = dish_datum.dish.reagents.total_volume
		dish_ui_datum["major_mutations"] = dish_datum.major_mutations_count
		dish_ui_datum["minor_mutations_strength"] = mutatechance //add support for other reagents
		dish_ui_datum["minor_mutations_robustness"] = mutatechance //add support for other reagents
		dish_ui_datum["minor_mutations_effects"] = mutatechance //add support for other reagents
		dish_ui_datum["dish_slot"] = i

		var/list/symptom_data = list()
		var/obj/item/weapon/virusdish/dish = dish_datum.dish
		for(var/datum/symptom/symptom in dish.contained_virus.symptoms)
			if(!(dish.contained_virus.disease_flags & DISEASE_ANALYZED))
				symptom_data += list(list("name" = "Unknown", "desc" = "Unknown", "strength" = symptom.multiplier, "max_strength" = symptom.max_multiplier, "chance" = symptom.chance, "max_chance" = symptom.max_chance, "stage" = symptom.stage))
				continue
			symptom_data += list(list("name" = symptom.name, "desc" = symptom.desc, "strength" = symptom.multiplier, "max_strength" = symptom.max_multiplier, "chance" = symptom.chance, "max_chance" = symptom.max_chance, "stage" = symptom.stage))
		dish_ui_datum["symptom_data"] = symptom_data

	return data

/obj/machinery/disease2/incubator/process()
	if (machine_stat & (NOPOWER|BROKEN))
		return

	if (on)
		use_power = ACTIVE_POWER_USE
		for (var/dish_incubator_dish/dish_datum in dish_data)
			dish_datum.dish.incubate(mutatechance, growthrate, effect_focus)
	else
		use_power = IDLE_POWER_USE

	update_appearance()


/obj/machinery/disease2/incubator/proc/find_dish_datum(obj/item/weapon/virusdish/dish)
	for (var/dish_incubator_dish/dish_datum in dish_data)
		if (dish_datum.dish == dish)
			return dish_datum

	return null


/obj/machinery/disease2/incubator/proc/update_major(obj/item/weapon/virusdish/dish)
	var/dish_incubator_dish/dish_datum = find_dish_datum(dish)
	if (dish_datum == null)
		return

	dish_datum.updates_new |= INCUBATOR_DISH_MAJOR
	dish_datum.updates &= ~INCUBATOR_DISH_MAJOR
	dish_datum.major_mutations_count++


/obj/machinery/disease2/incubator/proc/update_minor(obj/item/weapon/virusdish/dish, str=0, rob=0, eff=0)
	var/dish_incubator_dish/dish_datum = find_dish_datum(dish)
	if (dish_datum == null)
		return

	dish_datum.updates_new |= INCUBATOR_DISH_MINOR
	dish_datum.updates &= ~INCUBATOR_DISH_MINOR
	dish_datum.minor_mutation_strength += str;
	dish_datum.minor_mutation_robustness += rob;
	dish_datum.minor_mutation_effects += eff;


/obj/machinery/disease2/incubator/update_icon()
	. = ..()
	icon_state = "incubator"

	if (machine_stat & (NOPOWER))
		icon_state = "incubator0"

	if (machine_stat & (BROKEN))
		icon_state = "incubatorb"

	if (on)
		light_color = "#E1C400"
	else
		light_color = "#6496FA"

	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		if (on)
			set_light(2,2)
		else
			set_light(2,1)

/obj/machinery/disease2/incubator/update_overlays()
	. = ..()
	if(!(machine_stat & (BROKEN|NOPOWER)))
		if (on)
			. += mutable_appearance(icon,"incubator_light",src)
			. += mutable_appearance(icon,"incubator_glass",src)
			. += emissive_appearance(icon,"incubator_light",src)
			. += emissive_appearance(icon,"incubator_glass",src)

	for (var/i = 1 to dish_data.len)
		if (dish_data[i] != null)
			. += add_dish_sprite(dish_data[i], i)

/obj/machinery/disease2/incubator/proc/add_dish_sprite(dish_incubator_dish/dish_datum, slot)
	var/obj/item/weapon/virusdish/dish = dish_datum.dish
	var/list/overlays = list()

	slot--
	var/mutable_appearance/dish_outline = mutable_appearance(icon,"smalldish2-outline",src)
	dish_outline.alpha = 128
	dish_outline.pixel_y = -5 * slot
	overlays += dish_outline
	var/mutable_appearance/dish_content = mutable_appearance(icon,"smalldish2-empty",src)
	dish_content.alpha = 128
	dish_content.pixel_y = -5 * slot
	if (dish.contained_virus)
		dish_content.icon_state = "smalldish2-color"
		dish_content.color = dish.contained_virus.color
	overlays += dish_content

	//updating the light indicators
	if (dish.contained_virus && !(machine_stat & (BROKEN|NOPOWER)))
		var/mutable_appearance/grown_gauge = mutable_appearance(icon,"incubator_growth7",src)
		grown_gauge.plane = ABOVE_LIGHTING_PLANE
		grown_gauge.pixel_y = -5 * slot
		if (dish.growth < 100)
			grown_gauge.icon_state = "incubator_growth[min(6,max(1,round(dish.growth*70/1000)))]"
		else
			var/update = FALSE
			if (!(dish_datum.updates & INCUBATOR_DISH_GROWTH))
				dish_datum.updates += INCUBATOR_DISH_GROWTH
				update = TRUE

			if (update)
				var/mutable_appearance/grown_light = emissive_appearance(icon,"incubator_grown_update",src)
				grown_light.pixel_y = -5 * slot
				var/mutable_appearance/grown_light_n = mutable_appearance(icon,"incubator_grown_update",src)
				grown_light_n.pixel_y = -5 * slot

				overlays += grown_light
				overlays += grown_light_n
			else
				var/mutable_appearance/grown_light = emissive_appearance(icon,"incubator_grown",src)
				grown_light.pixel_y = -5 * slot
				var/mutable_appearance/grown_light_n = mutable_appearance(icon,"incubator_grown",src)
				grown_light_n.pixel_y = -5 * slot

				overlays += grown_light_n
				overlays += grown_light

		overlays += grown_gauge
		if (dish.reagents.total_volume < 0.02)
			var/update = FALSE
			if (!(dish_datum.updates & INCUBATOR_DISH_REAGENT))
				dish_datum.updates += INCUBATOR_DISH_REAGENT
				update = TRUE

			if (update)
				var/mutable_appearance/reagents_light = emissive_appearance(icon,"incubator_reagents_update",src)
				reagents_light.pixel_y = -5 * slot
				var/mutable_appearance/reagents_light_n = mutable_appearance(icon,"incubator_reagents_update",src)
				reagents_light_n.pixel_y = -5 * slot

				overlays += reagents_light_n
				overlays += reagents_light
			else
				var/mutable_appearance/reagents_light = emissive_appearance(icon,"incubator_reagents",src)
				reagents_light.pixel_y = -5 * slot
				var/mutable_appearance/reagents_light_n = mutable_appearance(icon,"incubator_reagents",src)
				reagents_light_n.pixel_y = -5 * slot

				overlays += reagents_light_n
				overlays += reagents_light

		/*
		if (dish_datum.updates_new & INCUBATOR_DISH_MAJOR)
			if (!(dish_datum.updates & INCUBATOR_DISH_MAJOR))
				dish_datum.updates += INCUBATOR_DISH_MAJOR
				var/mutable_appearance/effect_light = emissive_appearance(icon,"incubator_major_update",src)
				effect_light.pixel_y = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon,"incubator_major_update",src)
				effect_light_n.pixel_y = -5 * slot

				overlays += effect_light_n
				overlays += effect_light
			else
				var/mutable_appearance/effect_light = emissive_appearance(icon,"incubator_major",src)
				effect_light.pixel_y = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon,"incubator_major",src)
				effect_light_n.pixel_y = -5 * slot

				overlays += effect_light_n
				overlays += effect_light

		if (dish_datum.updates_new & INCUBATOR_DISH_MINOR)
			if (!(dish_datum.updates & INCUBATOR_DISH_MINOR))
				dish_datum.updates += INCUBATOR_DISH_MINOR
				var/mutable_appearance/effect_light = emissive_appearance(icon,"incubator_minor_update",src)
				effect_light.pixel_y = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon,"incubator_minor_update",src)
				effect_light_n.pixel_y = -5 * slot

				overlays += effect_light_n

				overlays += effect_light
			else
				var/mutable_appearance/effect_light = mutable_appearance(icon,"incubator_minor",src)
				effect_light.pixel_y = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon,"incubator_minor",src)
				effect_light_n.pixel_y = -5 * slot

				overlays += effect_light_n
				overlays += effect_light
			*/

	return overlays

/obj/machinery/disease2/incubator/Destroy()
	. = ..()
	for (var/i in 1 to dish_data.len)
		var/dish_incubator_dish/dish_datum = dish_data[i]
		if (dish_datum == null)
			continue

		dish_datum.dish.forceMove(loc)
		dish_data[i] = null

	..()

/dish_incubator_dish
	// The inserted virus dish.
	var/obj/item/weapon/virusdish/dish

	var/major_mutations_count = 0

	var/minor_mutation_strength = 0
	var/minor_mutation_robustness = 0
	var/minor_mutation_effects = 0

	var/updates_new = 0
	var/updates = 0

#undef INCUBATOR_DISH_GROWTH
#undef INCUBATOR_DISH_REAGENT
#undef INCUBATOR_DISH_MAJOR
#undef INCUBATOR_DISH_MINOR
