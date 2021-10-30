/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "A specialized drilling system that allows the MODsuit to pierce the heavens."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/drill)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!. || QDELETED(target))
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(!wearer_human.Adjacent(target))
		return
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(wearer_human)

/obj/item/mod/module/drill/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, .proc/bump_mine)

/obj/item/mod/module/drill/on_deactivation()
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/H, atom/A, proximity)
	SIGNAL_HANDLER
	if(!istype(A, /turf/closed/mineral))
		return
	var/turf/closed/mineral/mineral_turf = A
	mineral_turf.gets_drilled(H)
	drain_power(use_power_cost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/mod/module/orebag
	name = "MOD ore pickup module"
	desc = "An integrated ore storage system that allows the MODsuit to automatically collect and deposit ore."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/orebag, /obj/item/mod/module/orebag/bluespace)
	var/max_items
	var/max_stack_amt = 50
	var/max_w_class = WEIGHT_CLASS_HUGE

/obj/item/mod/module/orebag/bluespace
	name = "MOD bluespace ore pickup module"
	desc = "An integrated ore storage system that allows the MODsuit to automatically collect and deposit ore. Now with bluespace!"
	max_items = INFINITY
	max_stack_amt = INFINITY
	max_w_class = INFINITY

/obj/item/mod/module/orebag/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rad_insulation, 0.01)
	AddComponent(/datum/component/storage/concrete/stack)
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.allow_quick_empty = TRUE
	STR.set_holdable(list(/obj/item/stack/ore))
	STR.max_w_class = max_w_class
	STR.max_combined_stack_amount = max_stack_amt
	if(max_items)
		STR.max_items = max_items

/obj/item/mod/module/orebag/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/ore_pickup)

/obj/item/mod/module/orebag/on_deactivation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/orebag/proc/ore_pickup(mob/living/user)
	SIGNAL_HANDLER
	var/obj/structure/ore_box/box
	var/turf/tile = user.loc
	var/show_message = FALSE
	if (!isturf(tile))
		return
	if (istype(user.pulling, /obj/structure/ore_box))
		box = user.pulling
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	if(STR)
		for(var/A in tile)
			if (!is_type_in_typecache(A, STR.can_hold))
				continue
			if (box)
				user.transferItemToLoc(A, box)
				show_message = TRUE
			else if(SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, A, user, TRUE))
				show_message = TRUE
			else
				user.balloon_alert("[name] is full")
				continue
	if(show_message)
		playsound(user, "rustle", 50, TRUE)
		if (box)
			user.balloon_alert("ores sent to [box]")
		else
			user.balloon_alert("ores sent to [src]")

/obj/item/mod/module/orebag/on_select_use(atom/target)
	. = ..()
	if(!. || QDELETED(target))
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(!wearer_human.Adjacent(target))
		return
	var/datum/component/storage/ore_storage = GetComponent(/datum/component/storage)
	mod.wearer.balloon_alert("ores dropped on [target]")
	ore_storage.do_quick_empty(target)
