/obj/machinery/disease2/diseaseanalyser
	name = "disease analyzer"
	desc = "For analysing pathogenic dishes of sufficient growth."
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "analyser"
	anchored = TRUE
	density = TRUE
	light_color = "#6496FA"
	light_outer_range = 2
	light_power = 1

	circuit = /obj/item/circuitboard/machine/diseaseanalyser

	idle_power_usage = 100
	active_power_usage = 100//1000 extra power once per analysis

	var/process_time = 5
	var/minimum_growth = 100
	var/obj/item/weapon/virusdish/dish = null
	var/last_scan_name = ""
	var/last_scan_info = ""

	var/processing = FALSE

	var/mob/scanner = null

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	. = ..()
	var/scancount = 0
	for(var/datum/stock_part/scanning_module/M in component_parts)
		scancount += M.tier
	minimum_growth = round((initial(minimum_growth) - (scancount * 6)))

/obj/machinery/disease2/diseaseanalyser/attackby(obj/item/I, mob/living/user, params)
	. = ..()

	if(machine_stat & (BROKEN))
		to_chat(user, span_warning("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return

	if (scanner)
		to_chat(user, span_warning("\The [scanner] is currently busy using this analyzer."))
		return

	if(.)
		return

	if (dish)
		if (istype(I,/obj/item/weapon/virusdish))
			to_chat(user, span_warning("There is already a dish in there. Alt+Click or perform the analysis to retrieve it first."))
		else if (istype(I,/obj/item/reagent_containers))
			dish.attackby(I,user)
	else
		if (istype(I,/obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/D = I
			if (D.open)
				visible_message(span_notice("\The [user] inserts \the [I] in \the [src]."),span_notice("You insert \the [I] in \the [src]."))
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				user.dropItemToGround(I, TRUE)
				I.forceMove(src)
				dish = I
				update_appearance()
			else
				to_chat(user, span_warning("You must open the dish's lid before it can be analysed. Be sure to wear proper protection first (at least a sterile mask and latex gloves)."))

/obj/machinery/disease2/diseaseanalyser/attack_hand(mob/user)
	. = ..()
	if(machine_stat & (BROKEN))
		to_chat(user, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if(machine_stat & (NOPOWER))
		to_chat(user, span_notice("Deprived of power, \the [src] is unresponsive."))
		if (dish)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish.forceMove(loc)
			dish = null
			update_appearance()
		return

	if(.)
		return

	if (scanner)
		to_chat(user, span_warning("\The [scanner] is currently busy using this analyzer."))
		return

	if (!dish)
		to_chat(user, span_notice("Place an open growth dish first to analyse its pathogen."))
		return

	if (dish.growth < minimum_growth)
		say("Pathogen growth insufficient. Minimal required growth: [minimum_growth]%.")
		to_chat(user,span_notice("Add some virus food to the dish and incubate."))
		if (minimum_growth == 100)
			to_chat(user,span_notice("Replacing the machine's scanning modules with better parts will lower the growth requirement."))
		dish.forceMove(loc)
		dish = null
		update_appearance()
		return

	scanner = user
	icon_state = "analyzer_processing"
	processing = TRUE
	update_appearance()

	spawn (1)
		var/mutable_appearance/I = mutable_appearance(icon,"analyser_light",src)
		I.plane = ABOVE_LIGHTING_PLANE
		add_overlay(I)
	use_power(1000)
	set_light(2,2)
	playsound(src, 'sound/machines/chime.ogg', 50)

	if(do_after(user, 5 SECONDS, src))
		if(machine_stat & (BROKEN|NOPOWER))
			return
		if(!istype(dish.contained_virus, /datum/disease/advanced))
			QDEL_NULL(dish)
			say("ERROR:Bad Pathogen detected PURGING")
		if (dish.contained_virus.addToDB())
			say("Added new pathogen to database.")
		var/datum/data/record/v = GLOB.virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
		dish.info = dish.contained_virus.get_info()
		dish.update_desc()
		last_scan_name = dish.contained_virus.name(TRUE)
		if (v)
			last_scan_name += v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""

		dish.name = "growth dish ([last_scan_name])"
		last_scan_info = dish.info
		var/datum/browser/popup = new(user, "\ref[dish]", dish.name, 600, 500, src)
		popup.set_content(dish.info)
		popup.open()
		dish.analysed = TRUE
		dish.contained_virus.disease_flags |= DISEASE_ANALYZED
		dish.update_appearance()
		dish.forceMove(loc)
		dish = null
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)

	processing = FALSE
	update_appearance()
	scanner = null

/obj/machinery/disease2/diseaseanalyser/update_icon()
	. = ..()
	icon_state = "analyser"
	if(processing)
		icon_state = "analyzer-processing"

	if (machine_stat & (NOPOWER))
		icon_state = "analyser0"

	if (machine_stat & (BROKEN))
		icon_state = "analyserb"

	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(2,1)


/obj/machinery/disease2/diseaseanalyser/update_overlays()
	. = ..()
	if(processing)
		. += emissive_appearance(icon, "analyzer-processing-emissive", src)

		. += mutable_appearance(icon,"analyser_light",src)
		. += emissive_appearance(icon,"analyser_light",src)

	. += emissive_appearance(icon, "analyzer-emissive", src)
	if (dish)
		.+= mutable_appearance(icon, "smalldish-outline",src)
		if (dish.contained_virus)
			var/mutable_appearance/I = mutable_appearance(icon,"smalldish-color",src)
			I.color = dish.contained_virus.color
			.+= I
		else
			.+= mutable_appearance(icon, "smalldish-empty",src)

/obj/machinery/disease2/diseaseanalyser/verb/PrintPaper()
	set name = "Print last analysis"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(machine_stat & (BROKEN))
		to_chat(usr, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if(machine_stat & (NOPOWER))
		to_chat(usr, span_notice("Deprived of power, \the [src] is unresponsive."))
		return

	var/turf/T = get_turf(src)
	playsound(T, "sound/effects/fax.ogg", 50, 1)
	var/image/paper = image(icon, src, "analyser-paper")
	flick_overlay_global(paper, GLOB.clients, 3 SECONDS)
	visible_message("\The [src] prints a sheet of paper.")
	spawn(1 SECONDS)
		var/obj/item/paper/P = new(T)
		P.name = last_scan_name
		P.add_raw_text(last_scan_info)
		P.pixel_x = 8
		P.pixel_y = -8
		P.update_appearance()

/obj/machinery/disease2/diseaseanalyser/process()
	if(machine_stat & (NOPOWER|BROKEN))
		scanner = null
		return

	if (scanner && !(scanner in range(src,1)))
		update_appearance()
		processing = FALSE
		scanner = null


/obj/machinery/disease2/diseaseanalyser/AltClick()
	if((!usr.Adjacent(src) || usr.incapacitated()))
		return ..()

	if (dish && !scanner)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		dish.forceMove(loc)
		dish = null
		update_appearance()
