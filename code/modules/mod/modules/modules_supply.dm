/obj/item/mod/module/orebag
	name = "MOD ore pickup module"
	desc = "An integrated ore storage system that allows the MODsuit to automatically collect and deposit ore."
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/orebag)
	var/max_items = 20
	var/max_stack_amt = 50
	var/max_w_class = WEIGHT_CLASS_HUGE

/obj/item/mod/module/orebag/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rad_insulation, 0.01)
	AddComponent(/datum/component/storage/concrete/stack)
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.allow_quick_empty = TRUE
	STR.set_holdable(list(/obj/item/stack/ore))
	STR.max_w_class = max_w_class
	STR.max_combined_stack_amount = max_stack_amt
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
	var/turf/tile = mod.wearer.loc
	var/show_message = FALSE
	if (!isturf(tile))
		return
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	if(STR)
		for(var/thing in tile)
			if(!is_type_in_typecache(thing, STR.can_hold))
				continue
			if(SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, thing, user, TRUE))
				show_message = TRUE
			else
				mod.wearer.balloon_alert("ore bag full!")
				continue
	if(show_message)
		playsound(mod.wearer, "rustle", 50, TRUE)

/obj/item/mod/module/orebag/on_use()
	. = ..()
	if(!.)
		return
	var/datum/component/storage/ore_storage = GetComponent(/datum/component/storage)
	mod.wearer.balloon_alert("ores dropped")
	ore_storage.do_quick_empty(mod.wearer.drop_location())
