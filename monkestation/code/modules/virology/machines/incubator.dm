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

	light_color = "#6496FA"
	light_outer_range = 2
	light_power = 1

	idle_power_usage = 100
	active_power_usage = 200

	// Contains instances of /dish_incubator_dish.
	var/list/dish_data = list(null, null, null)

	var/on = FALSE

	var/mutatechance = 5
	var/growthrate = 4
	var/can_focus = 0 //Whether the machine can focus on an effect to mutate it or not
	var/effect_focus = 0 //What effect of the disease are we focusing on?

/obj/machinery/disease2/incubator/New()
	. = ..()


	RefreshParts()


/obj/machinery/disease2/incubator/RefreshParts()
	. = ..()
	var/scancount = 0
	var/lasercount = 0
	for(var/datum/stock_part/scanning_module/SP in component_parts)
		scancount += SP.tier-1
	for(var/datum/stock_part/micro_laser/SP in component_parts)
		lasercount += SP.tier-1
	if(lasercount >= 4)
		can_focus = 1
	else
		can_focus = 0
	mutatechance = initial(mutatechance) * max(1, scancount)
	growthrate = initial(growthrate) + lasercount


/obj/machinery/disease2/incubator/attackby(var/obj/I, var/mob/user)
	. = ..()

	if (machine_stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return FALSE

	if (.)
		return

	if (istype(I, /obj/item/weapon/virusdish))
		for (var/i in 1 to dish_data.len)
			if (dish_data[i] == null) // Empty slot
				addDish(I, user, i)
				return TRUE

		to_chat(user, "<span class='warning'>There is no more room inside \the [src]. Remove a dish first.</span>")
		return FALSE


/obj/machinery/disease2/incubator/proc/addDish(var/obj/item/weapon/virusdish/VD, var/mob/user, var/slot)
	if (!VD.open)
		to_chat(user, "<span class='warning'>You must open the dish's lid before it can be put inside the incubator. Be sure to wear proper protection first (at least a sterile mask and latex gloves).</span>")
		return

	if (dish_data[slot] != null)
		to_chat(user,"<span class='warning'>This slot is already occupied. Remove the dish first.</span>")
		return

	if (!user.transferItemToLoc(VD, src))
		return

	var/dish_incubator_dish/dish_datum = new
	dish_datum.dish = VD
	dish_data[slot] = dish_datum

	visible_message("<span class='notice'>\The [user] adds \the [VD] to \the [src].</span>","<span class='notice'>You add \the [VD] to \the [src].</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	update_icon()


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

			update_icon()
			return TRUE

		if ("ejectdish")
			var/slot = text2num(params["ejectdish"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.forceMove(loc)
			if (Adjacent(usr))
				usr.put_in_hands(dish_datum.dish)

			dish_datum.dish.update_icon()
			dish_data[slot] = null
			update_icon()
			return TRUE

		if ("insertdish")
			var/slot = text2num(params["insertdish"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/mob/living/user = usr
			if (!isliving(user))
				return TRUE

			var/obj/item/weapon/virusdish/VD = user.get_active_hand()
			if (istype(VD))
				addDish(VD, user, slot)

			update_icon()
			return TRUE

		if ("examinedish")
			var/slot = text2num(params["examinedish"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.examine(usr)
			return TRUE

		if ("flushdish")
			var/slot = text2num(params["flushdish"])
			if (slot == null || slot < 1 || slot > dish_data.len)
				return TRUE

			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE

			dish_datum.dish.reagents.clear_reagents()
			return TRUE
		if ("changefocus")
			var/slot = text2num(params["changefocus"])
			if(slot == null || slot < 1 || slot > dish_data.len)
				return TRUE
			var/dish_incubator_dish/dish_datum = dish_data[slot]
			if (dish_datum == null)
				return TRUE
			var/stage_to_focus = input(usr, "Choose a stage to focus on. This will block symptoms from other stages from being mutated. Input 0 to disable effect focusing.", "Choose a stage.") as num
			if(!stage_to_focus)
				to_chat(usr, "<span class='notice'>The effect focusing is now turned off.</span>")
			else
				to_chat(usr, "span class='notice'>\The [src] will now focus on stage [stage_to_focus].</span>")
			effect_focus = stage_to_focus
			return TRUE

/obj/machinery/disease2/incubator/attack_hand(var/mob/user)
	. = ..()
	if (machine_stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return
	if (machine_stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		for (var/i in 1 to dish_data.len)
			var/dish_incubator_dish/dish_datum = dish_data[i]
			if (dish_datum == null)
				continue

			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish_datum.dish.forceMove(loc)
			update_icon()
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
			continue

		dish_ui_datum["name"] = dish_datum.dish.name
		dish_ui_datum["growth"] = dish_datum.dish.growth
		dish_ui_datum["reagents_volume"] = dish_datum.dish.reagents.total_volume
		dish_ui_datum["major_mutations"] = dish_datum.major_mutations_count
		dish_ui_datum["minor_mutations_strength"] = dish_datum.minor_mutation_strength
		dish_ui_datum["minor_mutations_robustness"] = dish_datum.minor_mutation_robustness
		dish_ui_datum["minor_mutations_effects"] = dish_datum.minor_mutation_effects

	return data

/obj/machinery/disease2/incubator/process()
	if (machine_stat & (NOPOWER|BROKEN))
		return

	if (on)
		use_power = ACTIVE_POWER_USE
		for (var/dish_incubator_dish/dish_datum in dish_data)
			dish_datum.dish.incubate(mutatechance, growthrate)
	else
		use_power = IDLE_POWER_USE

	update_icon()


/obj/machinery/disease2/incubator/proc/find_dish_datum(var/obj/item/weapon/virusdish/dish)
	for (var/dish_incubator_dish/dish_datum in dish_data)
		if (dish_datum.dish == dish)
			return dish_datum

	return null


/obj/machinery/disease2/incubator/proc/update_major(var/obj/item/weapon/virusdish/dish)
	var/dish_incubator_dish/dish_datum = find_dish_datum(dish)
	if (dish_datum == null)
		return

	dish_datum.updates_new |= INCUBATOR_DISH_MAJOR
	dish_datum.updates &= ~INCUBATOR_DISH_MAJOR
	dish_datum.major_mutations_count++


/obj/machinery/disease2/incubator/proc/update_minor(var/obj/item/weapon/virusdish/dish, var/str=0, var/rob=0, var/eff=0)
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
	overlays.len = 0
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
			var/image/incubator_light = image(icon,"incubator_light")
			incubator_light.plane = ABOVE_LIGHTING_PLANE
			overlays += incubator_light
			var/image/incubator_glass = image(icon,"incubator_glass")
			incubator_glass.plane = ABOVE_LIGHTING_PLANE
			incubator_glass.blend_mode = BLEND_ADD
			overlays += incubator_glass
		else
			set_light(2,1)

	for (var/i = 1 to dish_data.len)
		if (dish_data[i] != null)
			add_dish_sprite(dish_data[i], i)


/obj/machinery/disease2/incubator/proc/add_dish_sprite(var/dish_incubator_dish/dish_datum, var/slot)
	var/obj/item/weapon/virusdish/dish = dish_datum.dish

	slot--
	var/image/dish_outline = image(icon,"smalldish2-outline")
	dish_outline.alpha = 128
	dish_outline.pixel_y = -5 * slot
	overlays += dish_outline
	var/image/dish_content = image(icon,"smalldish2-empty")
	dish_content.alpha = 128
	dish_content.pixel_y = -5 * slot
	if (dish.contained_virus)
		dish_content.icon_state = "smalldish2-color"
		dish_content.color = dish.contained_virus.color
	overlays += dish_content

	//updating the light indicators
	if (dish.contained_virus && !(machine_stat & (BROKEN|NOPOWER)))
		var/image/grown_gauge = image(icon,"incubator_growth7")
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
				var/image/grown_light = image(icon,"incubator_grown_update")
				grown_light.pixel_y = -5 * slot
				grown_light.plane = ABOVE_LIGHTING_PLANE

				overlays += grown_light
			else
				var/image/grown_light = image(icon,"incubator_grown")
				grown_light.pixel_y = -5 * slot
				grown_light.plane = ABOVE_LIGHTING_PLANE

				overlays += grown_light

		overlays += grown_gauge
		if (dish.reagents.total_volume < 0.02)
			var/update = FALSE
			if (!(dish_datum.updates & INCUBATOR_DISH_REAGENT))
				dish_datum.updates += INCUBATOR_DISH_REAGENT
				update = TRUE

			if (update)
				var/image/reagents_light = image(icon,"incubator_reagents_update")
				reagents_light.pixel_y = -5 * slot
				reagents_light.plane = ABOVE_LIGHTING_PLANE

				overlays += reagents_light
			else
				var/image/reagents_light = image(icon,"incubator_reagents")
				reagents_light.pixel_y = -5 * slot
				reagents_light.plane = ABOVE_LIGHTING_PLANE

				overlays += reagents_light

		if (dish_datum.updates_new & INCUBATOR_DISH_MAJOR)
			if (!(dish_datum.updates & INCUBATOR_DISH_MAJOR))
				dish_datum.updates += INCUBATOR_DISH_MAJOR
				var/image/effect_light = image(icon,"incubator_major_update")
				effect_light.pixel_y = -5 * slot
				effect_light.plane = ABOVE_LIGHTING_PLANE

				overlays += effect_light
			else
				var/image/effect_light = image(icon,"incubator_major")
				effect_light.plane = ABOVE_LIGHTING_PLANE

				effect_light.pixel_y = -5 * slot
				overlays += effect_light

		if (dish_datum.updates_new & INCUBATOR_DISH_MINOR)
			if (!(dish_datum.updates & INCUBATOR_DISH_MINOR))
				dish_datum.updates += INCUBATOR_DISH_MINOR
				var/image/effect_light = image(icon,"incubator_minor_update")
				effect_light.pixel_y = -5 * slot
				effect_light.plane = ABOVE_LIGHTING_PLANE

				overlays += effect_light
			else
				var/image/effect_light = image(icon,"incubator_minor")
				effect_light.pixel_y = -5 * slot
				overlays += effect_light


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
