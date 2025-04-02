/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face. Passively reclaims water over time."
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	pixel_z = 1
	///Something's being washed at the moment
	var/busy = FALSE
	///What kind of reagent is produced by this sink by default? (We now have actual plumbing, Arcane, August 2020)
	var/dispensedreagent = /datum/reagent/water
	///Material to drop when broken or deconstructed.
	var/buildstacktype = /obj/item/stack/sheet/iron
	///Number of sheets of material to drop when broken or deconstructed.
	var/buildstackamount = 1
	///Does the sink have a water recycler to recollect its water supply?
	var/has_water_reclaimer = TRUE
	///Units of water to reclaim per second
	var/reclaim_rate = 0.5
	///Amount of shift the pixel for placement
	var/pixel_shift = 14

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sink, (-14))

/obj/structure/sink/Initialize(mapload, ndir = 0, has_water_reclaimer = null)
	. = ..()

	if(ndir)
		dir = ndir

	if(has_water_reclaimer != null)
		src.has_water_reclaimer = has_water_reclaimer

	switch(dir)
		if(NORTH)
			pixel_x = 0
			pixel_y = -pixel_shift
		if(SOUTH)
			pixel_x = 0
			pixel_y = pixel_shift
		if(EAST)
			pixel_x = -pixel_shift
			pixel_y = 0
		if(WEST)
			pixel_x = pixel_shift
			pixel_y = 0

	create_reagents(100, NO_REACT)
	if(src.has_water_reclaimer)
		reagents.add_reagent(dispensedreagent, 100)
	AddComponent(/datum/component/plumbing/simple_demand, extend_pipe_to_edge = TRUE)

/obj/structure/sink/examine(mob/user)
	. = ..()
	if(has_water_reclaimer)
		. += span_notice("A water recycler is installed. It looks like you could pry it out.")
	. += span_notice("[reagents.total_volume]/[reagents.maximum_volume] liquids remaining.")

/obj/structure/sink/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return
	if(reagents.total_volume < 5)
		to_chat(user, span_warning("The sink has no more contents left!"))
		return
	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return

	var/selected_area = user.parse_zone_with_bodypart(user.zone_selected)
	var/washing_face = FALSE
	if(selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES))
		washing_face = TRUE

	playsound(src, 'sound/machines/sink-faucet.ogg', 50)
	user.visible_message(span_notice("[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]..."), \
						span_notice("You start washing your [washing_face ? "face" : "hands"]..."))
	busy = TRUE

	if(!do_after(user, 4 SECONDS, target = src))
		busy = FALSE
		return

	busy = FALSE
	reagents.remove_all(5)
	reagents.expose(user, TOUCH, 5 / max(reagents.total_volume, 5))
	begin_reclamation()
	if(washing_face)
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_FACE_ACT, CLEAN_WASH)
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(!human_user.wash_hands(CLEAN_WASH))
			to_chat(user, span_warning("Your hands are covered by something!"))
			return
	else
		user.wash(CLEAN_WASH)

	user.visible_message(span_notice("[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src]."), \
						span_notice("You wash your [washing_face ? "face" : "hands"] using [src]."))

/obj/structure/sink/attackby(obj/item/O, mob/living/user, list/modifiers)
	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return

	if(is_reagent_container(O))
		var/obj/item/reagent_containers/RG = O
		if(reagents.total_volume <= 0)
			to_chat(user, span_notice("\The [src] is dry."))
			return FALSE
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				reagents.trans_to(RG, RG.amount_per_transfer_from_this, transferred_by = user)
				begin_reclamation()
				to_chat(user, span_notice("You fill [RG] from [src]."))
				return TRUE
			to_chat(user, span_notice("\The [RG] is full."))
			return FALSE

	if(istype(O, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/baton = O
		if(baton.cell?.charge && baton.active)
			flick("baton_active", src)
			user.Paralyze(baton.knockdown_time)
			user.set_stutter(baton.knockdown_time)
			baton.cell.use(baton.cell_hit_cost)
			user.visible_message(span_warning("[user] shocks [user.p_them()]self while attempting to wash the active [baton.name]!"), \
								span_userdanger("You unwisely attempt to wash [baton] while it's still on."))
			playsound(src, baton.on_stun_sound, 50, TRUE)
			return

	if(istype(O, /obj/item/mop))
		if(reagents.total_volume <= 0)
			to_chat(user, span_notice("\The [src] is dry."))
			return FALSE
		reagents.trans_to(O, 5, transferred_by = user)
		begin_reclamation()
		to_chat(user, span_notice("You wet [O] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		return

	if(O.tool_behaviour == TOOL_WRENCH)
		O.play_tool_sound(src)
		deconstruct()
		return

	if(O.tool_behaviour == TOOL_CROWBAR)
		if(!has_water_reclaimer)
			to_chat(user, span_warning("There isn't a water recycler to remove."))
			return

		O.play_tool_sound(src)
		has_water_reclaimer = FALSE
		new/obj/item/stock_parts/water_recycler(get_turf(loc))
		to_chat(user, span_notice("You remove the water reclaimer from [src]"))
		return

	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		new /obj/item/reagent_containers/cup/rag(src.loc)
		to_chat(user, span_notice("You tear off a strip of gauze and make a rag."))
		G.use(1)
		return

	if(istype(O, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/cloth = O
		new /obj/item/reagent_containers/cup/rag(loc)
		to_chat(user, span_notice("You tear off a strip of cloth and make a rag."))
		cloth.use(1)
		return

	if(istype(O, /obj/item/stack/ore/glass))
		new /obj/item/stack/sheet/sandblock(loc)
		to_chat(user, span_notice("You wet the sand in the sink and form it into a block."))
		O.use(1)
		return

	if(istype(O, /obj/item/stock_parts/water_recycler))
		if(has_water_reclaimer)
			to_chat(user, span_warning("There is already has a water recycler installed."))
			return

		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		qdel(O)
		has_water_reclaimer = TRUE
		begin_reclamation()
		return

	if(istype(O, /obj/item/storage/fancy/pickles_jar))
		if(O.contents.len)
			to_chat(user, span_notice("Looks like there's something left in the jar"))
			return
		new /obj/item/reagent_containers/cup/beaker/large(loc)
		to_chat(user, span_notice("You washed the jar, ridding it of the brine."))
		qdel(O)
		return

	if(!istype(O))
		return
	if(O.item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(!user.combat_mode || (O.item_flags & NOBLUDGEON))
		to_chat(user, span_notice("You start washing [O]..."))
		playsound(src, 'sound/machines/sink-faucet.ogg', 50)
		busy = TRUE
		if(!do_after(user, 4 SECONDS, target = src))
			busy = FALSE
			return 1
		busy = FALSE
		O.wash(CLEAN_WASH)
		reagents.expose(O, TOUCH, 5 / max(reagents.total_volume, 5))
		user.visible_message(span_notice("[user] washes [O] using [src]."), \
							span_notice("You wash [O] using [src]."))
		return 1
	else
		return ..()

/obj/structure/sink/atom_deconstruct(dissambled = TRUE)
	drop_materials()
	if(has_water_reclaimer)
		new /obj/item/stock_parts/water_recycler(drop_location())

/obj/structure/sink/process(seconds_per_tick)
	// Water reclamation complete?
	if(!has_water_reclaimer || reagents.total_volume >= reagents.maximum_volume)
		return PROCESS_KILL

	reagents.add_reagent(dispensedreagent, reclaim_rate * seconds_per_tick)

/obj/structure/sink/proc/drop_materials()
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	else
		for(var/i in custom_materials)
			var/datum/material/M = i
			new M.sheet_type(loc, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/sink/proc/begin_reclamation()
	START_PROCESSING(SSplumbing, src)

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"
	pixel_z = 4
	pixel_shift = 16

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sink/kitchen, (-16))

/obj/structure/sink/gasstation
	name = "plasma fuel station"
	desc = "A place to refuel vehicles with liquid plasma. It can also dispense into a container."
	icon_state = "sink_gasstation"
	dispensedreagent = /datum/reagent/toxin/plasma
	has_water_reclaimer = FALSE

/obj/structure/sink/greyscale
	icon_state = "sink_greyscale"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstacktype = null

/obj/structure/sinkframe
	name = "sink frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink_frame"
	desc = "A sink frame, that needs a water recycler to finish construction."
	anchored = FALSE
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/sinkframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/sinkframe/attackby(obj/item/tool, mob/living/user, list/modifiers)
	if(istype(tool, /obj/item/stock_parts/water_recycler))
		qdel(tool)
		var/obj/structure/sink/greyscale/new_sink = new(loc, REVERSE_DIR(dir), TRUE)
		new_sink.set_custom_materials(custom_materials)
		qdel(src)
		playsound(new_sink, 'sound/machines/click.ogg', 20, TRUE)
		return
	return ..()

/obj/structure/sinkframe/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	tool.play_tool_sound(src)
	var/obj/structure/sink/greyscale/new_sink = new(loc, REVERSE_DIR(dir), FALSE)
	new_sink.set_custom_materials(custom_materials)
	qdel(src)

	return TRUE

/obj/structure/sinkframe/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src)
	deconstruct()
	return TRUE

/obj/structure/sinkframe/atom_deconstruct(dissambled = TRUE)
	drop_materials()

/obj/structure/sinkframe/proc/drop_materials()
	for(var/datum/material/material as anything in custom_materials)
		new material.sheet_type(loc, FLOOR(custom_materials[material] / SHEET_MATERIAL_AMOUNT, 1))
