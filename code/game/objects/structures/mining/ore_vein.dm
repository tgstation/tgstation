GLOBAL_LIST_INIT(weighted_rare_ore_types, list(
	/obj/item/stack/ore/uranium = 5,
	/obj/item/stack/ore/diamond = 5,
	/obj/item/stack/ore/titanium = 10,
	/obj/item/stack/ore/bluespace_crystal = 5
	))

#define MAX_ORE_AMOUNT 1500
#define MAX_EXTRACTION_RATE 10
#define EXTRACTION_ORE_AMOUNT 1

/obj/structure/ore_vein
	name = "ore vein"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "ore_vein"
	anchored = TRUE

	var/obj/item/stack/ore/ore_type
	var/ore_amount_current
	var/ore_amount_max
	var/current_extraction = 0
	///Have we been discovered with a mining scanner?
	var/discovered = FALSE
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this geyser.
	var/discovery_message = null

	var/obj/machinery/drill/connected_drill

/obj/structure/ore_vein/iron
	ore_type = /obj/item/stack/ore/iron

/obj/structure/ore_vein/plasma
	ore_type = /obj/item/stack/ore/plasma

/obj/structure/ore_vein/gold
	ore_type = /obj/item/stack/ore/gold

/obj/structure/ore_vein/silver
	ore_type = /obj/item/stack/ore/silver

/obj/structure/ore_vein/Initialize()
	. = ..()
	if(!ore_type)
		ore_type = pickweight(GLOB.weighted_rare_ore_types)
	if(!ore_amount_max || !ore_amount_current)
		ore_amount_max = ore_amount_current = rand(500, MAX_ORE_AMOUNT)

/obj/structure/ore_vein/attackby(obj/item/item, mob/user)
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return

	if(discovered)
		to_chat(user, "<span class='warning'>This ore vein has already been discovered!</span>")
		return

	to_chat(user, "<span class='notice'>You discovered the ore vein and mark it on the GPS system!</span>")
	if(discovery_message)
		to_chat(user, discovery_message)

	discovered = TRUE
	if(!true_name)
		true_name = ore_type.name
		name = true_name

	AddComponent(/datum/component/gps, true_name)

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_idcard()
		if(card)
			to_chat(user, "<span class='notice'>[point_value] mining points have been paid out!</span>")
			card.mining_points += point_value

/obj/structure/ore_vein/proc/reduce_ore_amount(amount)
	ore_amount_current -= amount
	if(ore_amount_current <= 0)
		consume_vein()

/obj/structure/ore_vein/proc/consume_vein()
	qdel(src)

/obj/machinery/drill
	name = "drilling apparatus"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	use_power = NO_POWER_USE
	density = TRUE
	anchored = TRUE
	var/ore_extraction_rate = 0.1
	var/extraction_amount
	var/obj/structure/ore_vein/current_vein
	var/obj/item/stack/ore/ore_to_spawn
	var/operating = FALSE
	var/is_powered = FALSE

/obj/machinery/drill/Initialize()
	. = ..()
	current_vein = locate(/obj/structure/ore_vein) in loc
	if(!current_vein)
		repack()
		return
	ore_to_spawn = current_vein.ore_type
	RegisterSignal(current_vein, COMSIG_PARENT_QDELETING, .proc/consumed_vein)

/obj/machinery/drill/process(delta_time)
	if(!current_vein || !operating || !is_powered)
		return
	extract_ores(delta_time)

/obj/machinery/drill/proc/extract_ores(delta_time)
	extraction_amount += ore_extraction_rate * EXTRACTION_ORE_AMOUNT * delta_time
	if(extraction_amount >= 1)
		var/ore_amount = round(extraction_amount, 1)
		extraction_amount -= ore_amount
		current_vein.reduce_ore_amount(ore_amount)
		new ore_to_spawn(loc, ore_amount)

/obj/machinery/drill/proc/consumed_vein()
	UnregisterSignal(current_vein, COMSIG_PARENT_QDELETING)
	current_vein = null
	repack()

/obj/machinery/drill/proc/repack()
	new/obj/item/drill_package(loc)
	qdel(src)

/obj/item/drill_package
	name = "drill pack"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "box_corner"

/obj/item/drill_package/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, name)

/obj/item/drill_package/attack_self(mob/user, modifiers)
	var/turf/user_location = get_turf(user.loc)
	if(locate(/obj/structure/ore_vein) in user_location)
		new/obj/machinery/drill(user_location)
		qdel(src)

/obj/machinery/drills_controller
	name = "mining drills controller"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	var/list/obj/machinery/drill/drills = list()

/obj/machinery/drills_controller/Initialize()
	. = ..()
	get_drills()

/obj/machinery/drills_controller/proc/get_drills()
	for(var/drill in GLOB.machines)
		if(!istype(drill, /obj/machinery/drill))
			continue
		if(!(drill in drills))
			RegisterSignal(drill, COMSIG_PARENT_QDELETING, .proc/remove_drill)
		drills |= drill

/obj/machinery/drills_controller/proc/remove_drill()
	for(var/obj/machinery/drill/drill in drills)
		if(!QDELETED(drill))
			continue
		UnregisterSignal(drill, COMSIG_PARENT_QDELETING)
		drills -= drill

/obj/machinery/drills_controller/ui_interact(mob/user, datum/tgui/ui)
	get_drills()
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DrillsController", name)
		ui.open()

/obj/machinery/drills_controller/ui_data()
	var/data = list()
	data["online_drills"] = list(list())
	for(var/obj/machinery/drill/drill in drills)
		data["online_drills"] += list(list(
			"name" = drill.name,
			"coord" = "[drill.x], [drill.y], [drill.z]",
			"operating" = drill.operating,
			"powered" = drill.is_powered,
			"extraction_rate" = drill.ore_extraction_rate,
			"ore_type" = drill.current_vein.ore_type.name,
			"ore_amount" = drill.current_vein.ore_amount_current,
			"path" = drill
			))
	return data
