/obj/item/forging
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_items.dmi'
	var/work_time = 2 SECONDS

/obj/item/forging/tongs
	name = "forging tongs"
	desc = "A set of tongs specifically crafted for use in forging. A wise man once said 'I lift things up and put them down.'"
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_items.dmi'
	icon_state = "tong_empty"

/obj/item/forging/tongs/primitive
	name = "primitive forging tongs"
	work_time = 3 SECONDS

/obj/item/forging/tongs/attack_self(mob/user, modifiers)
	. = ..()
	var/obj/search_obj = locate(/obj) in contents
	if(search_obj)
		search_obj.forceMove(get_turf(src))
		icon_state = "tong_empty"
		return

/obj/item/forging/hammer
	name = "forging hammer"
	desc = "A hammer specifically crafted for use in forging. Used to slowly shape metal; careful, you could break something with it!"
	icon_state = "hammer"

/obj/item/forging/hammer/primitive
	name = "primitive forging hammer"

/obj/item/forging/billow
	name = "forging billow"
	desc = "A billow specifically crafted for use in forging. Used to stoke the flames and keep the forge lit."
	icon_state = "billow"

/obj/item/forging/billow/primitive
	name = "primitive forging billow"
	work_time = 3 SECONDS

//incomplete pre-complete items
/obj/item/forging/incomplete
	name = "parent dev item"
	desc = "An incomplete forge item, continue to work hard to be rewarded for your efforts."
	//the compare of when it gets too cold to hammer
	var/heat_world_compare = 0
	//the compare so you cant just keep hitting
	var/world_compare = 0
	var/average_hits = 30
	var/times_hit = 0
	var/average_wait = 1 SECONDS

	var/spawn_item

/obj/item/forging/incomplete/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/forging/tongs))
		var/obj/search_obj = locate(/obj) in I.contents
		if(search_obj)
			to_chat(user, span_warning("The tongs are already holding something, make room."))
			return
		forceMove(I)
		I.icon_state = "tong_full"
		return

/obj/item/forging/incomplete/chain
	name = "incomplete chain"
	icon_state = "hot_chain"
	average_hits = 10
	average_wait = 0.5 SECONDS
	spawn_item = /obj/item/forging/complete/chain

/obj/item/forging/incomplete/sword
	name = "incomplete sword blade"
	icon_state = "hot_blade"
	spawn_item = /obj/item/forging/complete/sword

/obj/item/forging/incomplete/staff
	name = "incomplete staff head"
	icon_state = "hot_staffhead"
	spawn_item = /obj/item/forging/complete/staff

/obj/item/forging/incomplete/spear
	name = "incomplete spear head"
	icon_state = "hot_spearhead"
	spawn_item = /obj/item/forging/complete/spear

/obj/item/forging/incomplete/plate
	name = "incomplete plate"
	icon_state = "hot_plate"
	average_hits = 10
	average_wait = 0.5 SECONDS
	spawn_item = /obj/item/forging/complete/plate

//"complete" pre-complete items
/obj/item/forging/complete/chain
	name = "chain"
	desc = "A singular chain, best used in combination with multiple chains."
	icon_state = "chain"

/obj/item/forging/complete/sword
	name = "sword blade"
	desc = "A sword blade, ready to get some wood for completion."
	icon_state = "blade"

/obj/item/forging/complete/staff
	name = "staff head"
	desc = "A staff head, ready to get some wood for completion."
	icon_state = "staffhead"

/obj/item/forging/complete/spear
	name = "spear head"
	desc = "A spear head, ready to get some wood for completion."
	icon_state = "spearhead"

/obj/item/forging/complete/plate
	name = "plate"
	desc = "A plate, best used in combination with multiple plates."
	icon_state = "plate"

/obj/item/forging/reagent_tile
	name = "reagent tile"
	desc = "A tile that is ready to be placed down. It is capable of being imbued."
	icon_state = "full_plate"
	var/list/imbued_reagent = list()
	var/has_imbued = FALSE

/obj/item/forging/reagent_tile/Initialize()
	. = ..()
	create_reagents(500, INJECTABLE | REFILLABLE)

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/forging/reagent_tile))
		var/obj/item/forging/reagent_tile/reagent_tile = C
		var/turf/open/floor/reagent_plating/reagent_plating = ChangeTurf(/turf/open/floor/reagent_plating)
		reagent_plating.imbued_reagent = reagent_tile.imbued_reagent
		reagent_plating.name = reagent_tile.name
		reagent_plating.color = reagent_tile.color
		reagent_plating.has_imbued = reagent_tile.has_imbued
		reagent_plating.previous_turf = src.type
		qdel(reagent_tile)

/turf/open/floor/reagent_plating
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_items.dmi'
	icon_state = "plate_plating"
	var/list/imbued_reagent = list()
	var/list/current_affect = list()
	var/world_timer = 0
	var/obj/item/reagent_containers/reagent_container
	var/has_imbued = FALSE
	var/turf/previous_turf

/turf/open/floor/reagent_plating/Initialize(mapload)
	. = ..()
	reagent_container = new /obj/item/reagent_containers(src)

/turf/open/floor/reagent_plating/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(reagent_container)
	. = ..()

/turf/open/floor/reagent_plating/process()
	if(world_timer >= world.time)
		return
	world_timer = world.time + 2 SECONDS
	if(!contents || imbued_reagent.len <= 0)
		return
	for(var/attempt_injectee in current_affect)
		if(get_turf(attempt_injectee) != src)
			current_affect -= attempt_injectee
			continue
		if(!iscarbon(attempt_injectee))
			current_affect -= attempt_injectee
			continue
		var/mob/living/carbon/carbon_mob = attempt_injectee
		if(!carbon_mob.can_inject())
			continue
		for(var/reagent_list in imbued_reagent)
			reagent_container.reagents.add_reagent(reagent_list, 0.5)
			reagent_container.reagents.trans_to(target = carbon_mob, amount = 0.5, transfered_by = src, methods = INJECT)
	if(current_affect.len <= 0)
		STOP_PROCESSING(SSobj, src)

/turf/open/floor/reagent_plating/Entered(atom/movable/arrived, direction)
	. = ..()
	if(iscarbon(arrived))
		current_affect += arrived
		START_PROCESSING(SSobj, src)

/turf/open/floor/reagent_plating/crowbar_act(mob/living/user, obj/item/I)
	var/obj/item/forging/reagent_tile/reagent_tile = new /obj/item/forging/reagent_tile(get_turf(src))
	reagent_tile.name = name
	reagent_tile.color = color
	reagent_tile.imbued_reagent = imbued_reagent
	reagent_tile.has_imbued = has_imbued
	ChangeTurf(previous_turf)
	I.play_tool_sound(src, 80)
