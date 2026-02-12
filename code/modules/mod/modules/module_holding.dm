#define HOLDING_MODULE_PREVENT_DUPLICATE_CHECK 1
#define HOLDING_MODULE_CHECK_CONFIRMED 2

/obj/item/mod/module/storage/holding
	name = "MOD storage module of holding"
	desc = "A prototype storage module utilizing the power of anomalous bluespace phenomena \
		to store copious amounts of matter. Unfortunately, it suffers from the same drawbacks as its standalone counterpart, \
		including <b>tearing catastrophic rifts in reality</b> when nested inside bluespace pockets produced through similar means."
	icon_state = "storage_holding"
	complexity = 4
	storage_type = null // core-less modules should be safe to insert into bags of holding
	var/prebuilt = FALSE
	var/core_removable = TRUE
	var/datum/component/anomaly_locked_module/anomalock
	var/list/possible_bag_bombs = list()

/obj/item/mod/module/storage/holding/Initialize(mapload)
	. = ..()
	anomalock = AddComponent(/datum/component/anomaly_locked_module,\
		list(/obj/item/assembly/signaler/anomaly/bluespace),\
		prebuilt,\
		core_removable,\
		PROC_REF(pre_core_inserted),\
		PROC_REF(on_core_inserted),\
		PROC_REF(on_core_removed),\
	)
	RegisterSignal(src, COMSIG_MODULE_TRY_INSTALL, PROC_REF(try_install))

/obj/item/mod/module/storage/holding/Destroy()
	possible_bag_bombs.Cut()
	return ..()

/obj/item/mod/module/storage/holding/proc/pre_core_inserted(mob/user, obj/item/core, list/modifiers)
	if(possible_bag_bombs[core] == HOLDING_MODULE_PREVENT_DUPLICATE_CHECK)
		return ITEM_INTERACT_FAILURE
	var/datum/storage/bag_of_holding/other_bag
	for(var/atom/nested_loc in get_nested_locs(src))
		if(istype(nested_loc.atom_storage, /datum/storage/bag_of_holding))
			other_bag = nested_loc.atom_storage
			break
	if(other_bag && !possible_bag_bombs[core])
		INVOKE_ASYNC(src, PROC_REF(recursive_core_insertion), other_bag, user, core, modifiers)
		return ITEM_INTERACT_BLOCKING

/obj/item/mod/module/storage/holding/proc/recursive_core_insertion(datum/storage/bag_of_holding/bag_storage, mob/user, obj/item/core, list/modifiers)
	possible_bag_bombs[core] = HOLDING_MODULE_PREVENT_DUPLICATE_CHECK
	if(bag_storage.confirm_recursive_insertion(core, user) && !QDELETED(core) && user.is_holding(core) && IsReachableBy(user))
		anomalock.insert_core(src, user, core, modifiers)
	possible_bag_bombs -= core

/obj/item/mod/module/storage/holding/proc/on_core_inserted(obj/item/core, mob/user)
	for(var/atom/nested_loc in get_nested_locs(src))
		var/datum/storage/bag_of_holding/boh = nested_loc.atom_storage
		if(istype(boh))
			boh.create_rift(core, user)
			return
	core.moveToNullspace() // Otherwise, the core would become part of the suit's inventory.
	storage_type = /datum/storage/bag_of_holding
	create_storage(storage_type = /datum/storage/bag_of_holding)
	atom_storage.set_locked(STORAGE_FULLY_LOCKED)

/obj/item/mod/module/storage/holding/proc/on_core_removed()
	QDEL_NULL(atom_storage)
	storage_type = null

/obj/item/mod/module/storage/holding/proc/try_install(_source, obj/item/mod/control/suit, mob/user)
	SIGNAL_HANDLER
	if(possible_bag_bombs[suit] == HOLDING_MODULE_PREVENT_DUPLICATE_CHECK)
		return MOD_ABORT_INSTALL
	if(!anomalock.core)
		balloon_alert(user, "no core!")
		playsound(suit, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return MOD_ABORT_INSTALL
	var/datum/storage/bag_of_holding/other_bag
	for(var/atom/nested_loc in get_nested_locs(suit))
		if(istype(nested_loc.atom_storage, /datum/storage/bag_of_holding))
			other_bag = nested_loc.atom_storage
			break
	if(other_bag)
		if(possible_bag_bombs[suit] == HOLDING_MODULE_CHECK_CONFIRMED)
			other_bag.create_rift(src, user)
		else
			INVOKE_ASYNC(src, PROC_REF(recursive_installation), other_bag, suit, user)
		return MOD_ABORT_INSTALL

/obj/item/mod/module/storage/holding/proc/recursive_installation(datum/storage/bag_of_holding/bag_storage, obj/item/mod/control/suit, mob/user)
	possible_bag_bombs[suit] = HOLDING_MODULE_PREVENT_DUPLICATE_CHECK
	if(bag_storage.confirm_recursive_insertion(src, user) && !QDELETED(suit) && user.is_holding(src) && suit.IsReachableBy(user))
		possible_bag_bombs[suit] = HOLDING_MODULE_CHECK_CONFIRMED
		suit.install(src, user)
	possible_bag_bombs -= suit

/obj/item/mod/module/storage/holding/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/storage/holding/prebuilt/locked
	core_removable = FALSE

#undef HOLDING_MODULE_PREVENT_DUPLICATE_CHECK
#undef HOLDING_MODULE_CHECK_CONFIRMED
