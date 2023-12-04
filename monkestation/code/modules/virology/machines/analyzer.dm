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

	idle_power_usage = 100
	active_power_usage = 100//1000 extra power once per analysis

	var/process_time = 5
	var/minimum_growth = 100
	var/obj/item/weapon/virusdish/dish = null
	var/last_scan_name = ""
	var/last_scan_info = ""

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
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if (scanner)
		to_chat(user, "<span class='warning'>\The [scanner] is currently busy using this analyzer.</span>")
		return

	if(.)
		return

	if (dish)
		if (istype(I,/obj/item/weapon/virusdish))
			to_chat(user, "<span class='warning'>There is already a dish in there. Alt+Click or perform the analysis to retrieve it first.</span>")
		else if (istype(I,/obj/item/reagent_containers))
			dish.attackby(I,user)
	else
		if (istype(I,/obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/D = I
			if (D.open)
				visible_message("<span class='notice'>\The [user] inserts \the [I] in \the [src].</span>","<span class='notice'>You insert \the [I] in \the [src].</span>")
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				user.dropItemToGround(I, TRUE)
				I.forceMove(src)
				dish = I
				update_icon()
			else
				to_chat(user, "<span class='warning'>You must open the dish's lid before it can be analysed. Be sure to wear proper protection first (at least a sterile mask and latex gloves).</span>")

/obj/machinery/disease2/diseaseanalyser/attack_hand(mob/user)
	. = ..()
	if(machine_stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return
	if(machine_stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		if (dish)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish.forceMove(loc)
			dish = null
			update_icon()
		return

	if(.)
		return

	if (scanner)
		to_chat(user, "<span class='warning'>\The [scanner] is currently busy using this analyzer.</span>")
		return

	if (!dish)
		to_chat(user, "<span class='notice'>Place an open growth dish first to analyse its pathogen.</span>")
		return

	if (dish.growth < minimum_growth)
		say("Pathogen growth insufficient. Minimal required growth: [minimum_growth]%.")
		to_chat(user,"<span class='notice'>Add some virus food to the dish and incubate.</span>")
		if (minimum_growth == 100)
			to_chat(user,"<span class='notice'>Replacing the machine's scanning modules with better parts will lower the growth requirement.</span>")
		dish.forceMove(loc)
		dish = null
		update_icon()
		return

	scanner = user
	icon_state = "analyser_processing"
	flick("analyser_turnon",src)

	spawn (1)
		var/image/I = image(icon,"analyser_light")
		I.plane = ABOVE_LIGHTING_PLANE
		overlays += I
	use_power(1000)
	set_light(2,2)
	playsound(src, 'sound/machines/chime.ogg', 50)

	if(do_after(user, 5 SECONDS, src))
		if(machine_stat & (BROKEN|NOPOWER))
			return
		if (dish.contained_virus.addToDB())
			say("Added new pathogen to database.")
		var/datum/data/record/v = GLOB.virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
		dish.info = dish.contained_virus.get_info()
		last_scan_name = dish.contained_virus.name(TRUE)
		if (v)
			last_scan_name += v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""

		dish.name = "growth dish ([last_scan_name])"
		last_scan_info = dish.info
		var/datum/browser/popup = new(user, "\ref[dish]", dish.name, 600, 500, src)
		popup.set_content(dish.info)
		popup.open()
		dish.analysed = TRUE
		dish.update_icon()
		dish.forceMove(loc)
		dish = null
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)

	update_icon()
	flick("analyser_turnoff",src)
	scanner = null

/obj/machinery/disease2/diseaseanalyser/update_icon()
	. = ..()
	overlays.len = 0
	icon_state = "analyser"

	if (machine_stat & (NOPOWER))
		icon_state = "analyser0"

	if (machine_stat & (BROKEN))
		icon_state = "analyserb"

	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(2,1)

	if (dish)
		overlays += "smalldish-outline"
		if (dish.contained_virus)
			var/image/I = image(icon,"smalldish-color")
			I.color = dish.contained_virus.color
			overlays += I
		else
			overlays += "smalldish-empty"

/obj/machinery/disease2/diseaseanalyser/verb/PrintPaper()
	set name = "Print last analysis"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(machine_stat & (BROKEN))
		to_chat(usr, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return
	if(machine_stat & (NOPOWER))
		to_chat(usr, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		return

	var/turf/T = get_turf(src)
	playsound(T, "sound/effects/fax.ogg", 50, 1)
	flick_overlay("analyser-paper", src)
	visible_message("\The [src] prints a sheet of paper.")
	spawn(1 SECONDS)
		var/obj/item/paper/P = new(T)
		P.name = last_scan_name
		P.add_raw_text(last_scan_info)
		P.pixel_x = 8
		P.pixel_y = -8
		P.update_icon()

/obj/machinery/disease2/diseaseanalyser/process()
	if(machine_stat & (NOPOWER|BROKEN))
		scanner = null
		return

	if (scanner && !(scanner in range(src,1)))
		update_icon()
		flick("analyser_turnoff",src)
		scanner = null


/obj/machinery/disease2/diseaseanalyser/AltClick()
	if((!usr.Adjacent(src) || usr.incapacitated()))
		return ..()

	if (dish && !scanner)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		dish.forceMove(loc)
		dish = null
		update_icon()
