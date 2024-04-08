GLOBAL_LIST_INIT(biomass_unlocks, list())

/obj/machinery/biomass_recycler
	name = "biomass recycler"
	desc = "A machine used for recycling dead biomass and fabricating dehydrated creatures and eggs."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/biomass_recycler
	var/stored_matter = 0
	var/cube_production = 0.2

	var/static/list/recyclable_types = list(/mob/living/carbon/human/species/monkey = 1)
	var/list/printable_types = list(/obj/item/stack/biomass = 1, /obj/item/food/monkeycube = 1)
	var/list/vacuum_printable_types = list(/mob/living/carbon/human/species/monkey = 1)

/obj/machinery/biomass_recycler/RefreshParts() //Ranges from 0.2 to 0.8 per monkey recycled
	. = ..()
	cube_production = 0.2
	for(var/obj/item/stock_parts/manipulator/B in component_parts)
		cube_production += B.rating * 0.1
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cube_production += M.rating * 0.1

/obj/machinery/biomass_recycler/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recycles <b>[cube_production]</b> biomass units per unit inserted.")

/obj/machinery/biomass_recycler/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_unfasten_wrench(user, tool))
		power_change()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/biomass_recycler/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", O))
		return

	if(default_pry_open(O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(machine_stat) //NOPOWER etc
		return

	if(HAS_TRAIT(O, TRAIT_NODROP))
		return

	if(istype(O, /obj/item/stack/biomass))
		var/obj/item/stack/biomass/biomass = O
		to_chat(user, span_notice("You insert [biomass.amount] cube\s of biomass into [src]."))
		stored_matter += biomass.amount
		qdel(biomass)
		return

	var/can_recycle
	for(var/recycable_type in recyclable_types)
		if(istype(O, recycable_type))
			can_recycle = recycable_type
			break

	if(can_recycle)
		recycle(O, user, can_recycle)

/obj/machinery/biomass_recycler/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target))
		return

	var/can_recycle
	for(var/recycable_type in recyclable_types)
		if(istype(target, recycable_type))
			can_recycle = recycable_type
			break

	if(can_recycle)
		stuff_creature_in(target, user, can_recycle)

/obj/machinery/biomass_recycler/proc/stuff_creature_in(mob/living/target, mob/living/user, recycable_type)
	if(!istype(target))
		return
	if(target.stat == CONSCIOUS)
		to_chat(user, span_warning("[target] is struggling far too much to put it in the recycler."))
		return
	if(target.buckled || target.has_buckled_mobs())
		to_chat(user, span_warning("[target] is attached to something."))
		return

	recycle(target, user, recycable_type)

/obj/machinery/biomass_recycler/proc/recycle(atom/movable/target, mob/living/user, recycable_type)
	qdel(target)
	to_chat(user, span_notice("You stuff [target] into the machine."))
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	use_power(active_power_usage)
	stored_matter += cube_production * recyclable_types[recycable_type]
	addtimer(VARSET_CALLBACK(src, pixel_x, base_pixel_x))
	addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, user, span_notice("The machine now has [stored_matter] unit\s of biomass stored.")))

/obj/machinery/biomass_recycler/interact(mob/user)
	var/list/items = list()
	var/list/item_names = list()
	for(var/printable_type in GLOB.biomass_unlocks)
		printable_types |= printable_type
		printable_types[printable_type] = GLOB.biomass_unlocks[printable_type]

		recyclable_types |= list(printable_type = 1)

	for(var/printable_type in printable_types)
		var/atom/movable/printable = printable_type
		var/image/printable_image = image(icon = initial(printable.icon), icon_state = initial(printable.icon_state))
		items += list(initial(printable.name) = printable_image)
		item_names[initial(printable.name)] = printable_type

	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)

	if(!pick)
		return

	var/spawn_type = item_names[pick]
	if(stored_matter < printable_types[spawn_type])
		to_chat(user, span_warning("[src] does not have enough stored biomass for that! It currently has [stored_matter] out of [printable_types[spawn_type]] unit\s required."))
		return

	var/spawned = new spawn_type(user.loc)
	to_chat(user, span_notice("The machine hisses loudly as it condenses the biomass. After a moment, it dispenses a brand new [spawned]."))
	playsound(src.loc, 'sound/machines/hiss.ogg', 50, TRUE)
	stored_matter -= printable_types[spawn_type]
	to_chat(user, span_notice("The machine's display flashes that it has [stored_matter] unit\s of biomass left."))

/obj/item/stack/biomass
	name = "biomass cubes"
	desc = "A few cubes of green biomass."
	icon = 'monkestation/code/modules/slimecore/icons/stack_objects.dmi'
	icon_state = "biomass"
	base_icon_state = "biomass"
	max_amount = 5
	singular_name = "biomass cube"
	merge_type = /obj/item/stack/biomass
	flags_1 = CONDUCT_1

/obj/item/stack/biomass/update_icon_state()
	. = ..()
	icon_state = (amount == 1) ? "[base_icon_state]" : "[base_icon_state]_[min(amount, 5)]"

/obj/item/disk/biomass_upgrade
	name = "biomass recycler upgrade disk"
	desc = "An upgrade disk for biomass recycler."
	icon_state = "rndmajordisk"
	var/list/printable_types = list()
	var/list/vacuum_printable_types = list()

/obj/item/disk/biomass_upgrade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/biomass_recycler))
		var/obj/machinery/biomass_recycler/recycler = target
		to_chat(user, span_notice("You install [src] into [recycler]."))
		playsound(user, 'sound/machines/click.ogg', 30, TRUE)

		for(var/print_type in printable_types)
			recycler.printable_types[print_type] = printable_types[print_type]

		for(var/print_type in vacuum_printable_types)
			recycler.vacuum_printable_types[print_type] = vacuum_printable_types[print_type]

/*
/obj/item/disk/biomass_upgrade/wobble
	name = "\"Wobble Chicken\" biomass recycler upgrade disk"
	printable_types = list(/obj/item/food/wobble_egg = 0.75)
	vacuum_printable_types = list(/obj/item/food/wobble_egg = 0.75)
*/

/obj/item/disk/biomass_upgrade/rockroach
	name = "\"Rockroach\" biomass recycler upgrade disk"
	printable_types = list(/mob/living/basic/cockroach/rockroach = 0.4)
	vacuum_printable_types = list(/mob/living/basic/cockroach/rockroach = 0.4)
