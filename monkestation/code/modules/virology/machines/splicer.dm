#define DISEASE_SPLICER_BURNING_TICKS 5
#define DISEASE_SPLICER_SPLICING_TICKS 5
#define DISEASE_SPLICER_SCANNING_TICKS 5

/obj/machinery/computer/diseasesplicer
	name = "disease splicer"
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "splicer"

	icon_keyboard = null
	icon_screen = null
	circuit = /obj/item/circuitboard/computer/diseasesplicer
	var/datum/symptom/memorybank = null
	var/analysed = FALSE // If the buffered effect came from a dish that had been analyzed this is TRUE
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0 // Time in process ticks until disk burning is over

	var/splicing = 0 // Time in process ticks until splicing is over
	var/scanning = 0 // Time in process ticks until scan is over
	var/spliced = FALSE // If at least one effect has been spliced into the current dish this is TRUE

	///the stage we are set to grab from
	var/target_stage = 1
	idle_power_usage = 100
	active_power_usage = 600

	light_color = "#00FF00"

/obj/machinery/computer/diseasesplicer/attackby(obj/I, mob/user)
	if(!(istype(I,/obj/item/weapon/virusdish) || istype(I,/obj/item/disk/disease)))
		return ..()

	if(istype(I, /obj/item/weapon/virusdish))
		if(dish)
			to_chat(user, span_warning("A virus containment dish is already inside \the [src]."))
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("You can't let go of \the [I]!"))
			return
		dish = I
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		update_icon()

	if(istype(I, /obj/item/disk/disease))
		var/obj/item/disk/disease/disk = I
		visible_message(span_notice("[user] swipes \the [disk] against \the [src]."), span_notice("You swipe \the [disk] against \the [src], copying the data into the machine's buffer."))
		memorybank = disk.effect
		flick_overlay("splicer_disk", src)
		spawn(2)
			update_icon()

	attack_hand(user)

/obj/machinery/computer/diseasesplicer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseaseSplicer")
		ui.open()


/obj/machinery/computer/diseasesplicer/ui_data(mob/user)
	. = ..()
	var/list/data = list(
		"splicing" = splicing,
		"scanning" = scanning,
		"burning" = burning,
		"target_stage" = target_stage,
	)

	if(dish)
		if(dish.contained_virus)
			if (dish.analysed)
				data["dish_name"] = dish.contained_virus.name()
			else
				data["dish_name"] = "Unknown [dish.contained_virus.form]"
		else
			data["dish_name"] = "Empty Dish"

	if(memorybank)
		data["memorybank"] = "[analysed ? memorybank.name : "Unknown DNA strand"] (Stage [memorybank.stage])"

	if(!dish)
		data["dish_error"] = "no dish inserted"
	else if(!dish.contained_virus)
		data["dish_error"] = "no pathogen in dish"
	else if(!dish.analysed)
		data["dish_error"] = "dish not analysed"
	else if(dish.growth < 50)
		data["dish_error"] = "not enough cells"
	return data

/obj/machinery/computer/diseasesplicer/attack_hand(mob/user, list/modifiers)
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		eject_dish()
		return

	if(.)
		return

	ui_interact(user)

/obj/machinery/computer/diseasesplicer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(scanning || splicing || burning)
		use_power = 2
	else
		use_power = 1

	if(scanning)
		scanning--
		if(!scanning)
			update_icon()
	if(splicing)
		splicing--
		if(!splicing)
			update_icon()
	if(burning)
		burning--
		if(!burning)
			update_icon()
			flick_overlay("splicer_print", src)
			var/obj/item/disk/disease/d = new /obj/item/disk/disease(src)
			if(analysed)
				d.name = "\improper [memorybank.name] GNA disk (Stage: [memorybank.stage])"
			else
				d.name = "unknown GNA disk (Stage: [memorybank.stage])"
			d.effect = memorybank
			d.update_desc()
			spawn(10)
				d.forceMove(loc)
				d.pixel_x = -6
				d.pixel_y = 3


/obj/machinery/computer/diseasesplicer/update_overlays()
	..()
	if (dish)
		var/mutable_appearance/dish_outline = mutable_appearance(icon,"smalldish2-outline", src)
		dish_outline.alpha = 128
		dish_outline.pixel_x = -1
		dish_outline.pixel_y = -13
		.+= dish_outline
		var/mutable_appearance/dish_content = mutable_appearance(icon,"smalldish2-empty", src)
		dish_content.alpha = 128
		dish_content.pixel_x = -1
		dish_content.pixel_y = -13
		if (dish.contained_virus)
			dish_content.icon_state = "smalldish2-color"
			dish_content.color = dish.contained_virus.color
		.+=dish_outline

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if (dish && dish.contained_virus)
		if (dish.analysed)
			var/mutable_appearance/scan_pattern = mutable_appearance(icon,"pattern-[dish.contained_virus.pattern]b", src)
			scan_pattern.color = "#00FF00"
			scan_pattern.pixel_x = -2
			scan_pattern.pixel_y = 4
			.+= scan_pattern
		else
			.+= mutable_appearance(icon,"splicer_unknown")

	if(scanning || splicing)
		var/mutable_appearance/splicer_glass = emissive_appearance(icon,"splicer_glass", src)
		splicer_glass.blend_mode = BLEND_ADD
		.+= splicer_glass

	if (memorybank)
		.+= emissive_appearance(icon,"splicer_buffer", src)

/obj/machinery/computer/diseasesplicer/proc/buffer2dish()
	if(!memorybank || !dish || !dish.contained_virus)
		return

	var/list/effects = dish.contained_virus.symptoms
	for(var/x = 1 to effects.len)
		if(x == target_stage)
			var/datum/symptom/e = effects[x]
			effects[x] = memorybank.Copy(dish.contained_virus)
			dish.contained_virus.log += "<br />[ROUND_TIME()] [memorybank.name] spliced in by [key_name(usr)] (replaces [e.name])"
			break

	splicing = DISEASE_SPLICER_SPLICING_TICKS
	spliced = TRUE
	update_icon()

/obj/machinery/computer/diseasesplicer/proc/dish2buffer(target_stage)
	if(!dish || !dish.contained_virus)
		return
	if(dish.growth < 50)
		return
	var/list/effects = dish.contained_virus.symptoms
	for(var/x = 1 to effects.len)
		var/datum/symptom/e = effects[x]
		if(e.stage == target_stage)
			memorybank = e
			break
	scanning = DISEASE_SPLICER_SCANNING_TICKS
	analysed = dish.analysed
	qdel(dish)
	dish = null
	update_icon()
	flick("splicer_scan", src)

/obj/machinery/computer/diseasesplicer/proc/eject_dish()
	if(!dish)
		return
	if(spliced)
		//Here we generate a new ID so the spliced pathogen gets it's own entry in the database instead of being shown as the old one.
		dish.contained_virus.subID = rand(0, 9999)
		var/list/randomhexes = list("7","8","9","a","b","c","d","e")
		var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		dish.contained_virus.color = BlendRGB(dish.contained_virus.color,colormix,0.25)
		dish.contained_virus.addToDB()
		say("Updated pathogen database with new spliced entry.")
		dish.info = dish.contained_virus.get_info()
		dish.name = "growth dish ([dish.contained_virus.name()])"
		spliced = FALSE
		dish.contained_virus.update_global_log()

	dish.forceMove(loc)
	if (Adjacent(usr))
		dish.forceMove(usr.loc)
		usr.put_in_hands(dish)
	dish = null
	update_icon()


/obj/machinery/computer/diseasesplicer/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE

	if(scanning || splicing || burning)
		return FALSE

	add_fingerprint(usr)

	switch(action)
		if("eject_dish")
			eject_dish()
			return TRUE
		if("erase_buffer")
			memorybank = null
			update_appearance()
			return TRUE
		if("dish_effect_to_buffer")
			dish2buffer(target_stage)
			return TRUE
		if("splice_buffer_to_dish")
			buffer2dish()
			return TRUE
		if("burn_buffer_to_disk")
			burning = DISEASE_SPLICER_BURNING_TICKS
			return TRUE
		if("target_stage")
			target_stage = params["stage"]
	return FALSE

#undef DISEASE_SPLICER_BURNING_TICKS
#undef DISEASE_SPLICER_SPLICING_TICKS
#undef DISEASE_SPLICER_SCANNING_TICKS
