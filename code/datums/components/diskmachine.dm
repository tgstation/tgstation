/datum/component/diskmachine
	/// the disk to be held
	var/obj/item/disk/disk
	/// callback for passing the data
	var/datum/callback/data_callback
	/// disk types allowed
	var/list/disk_typecache

/datum/component/diskmachine/Initialize(datum/callback/data_callback, list/disk_typecache)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.data_callback = data_callback
	if(!disk_typecache)
		src.disk_typecache = typecacheof(/obj/item/disk)
	else if(!islist(disk_typecache))
		if(!ispath(disk_typecache))
			CRASH("arg passed to diskmachine component wasn't a valid path")
		src.disk_typecache = typecacheof(disk_typecache)
	else
		src.disk_typecache = disk_typecache

/datum/component/diskmachine/Destroy(force, silent)
	. = ..()
	disk.forceMove(get_turf(parent))
	disk = null
	data_callback = null

/datum/component/diskmachine/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/disk_inserted)
	RegisterSignal(parent, list(
		COMSIG_CLICK_ALT,
		COMPONENT_DISK_EJECT), .proc/eject)
	RegisterSignal(parent, COMPONENT_HAS_DISK, .proc/hasdisk)
	RegisterSignal(parent, COMPONENT_SAVE_DATA, .proc/savedata)

/datum/component/diskmachine/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_CLICK_ALT,
		COMPONENT_DISK_EJECT,
		COMPONENT_HAS_DISK,
		COMPONENT_SAVE_DATA))

/datum/component/diskmachine/proc/savedata(datum/source, datum/newdata, newname)
	if(!disk)
		return
	if(disk.data)
		QDEL_NULL(disk.data)

	disk.data = newdata

	disk.name = "[initial(disk.name)][newname?"\[[newname]\]":""]"

/datum/component/diskmachine/proc/hasdisk()
	if(disk)
		return COMPONENT_DISK_INSERTED

/datum/component/diskmachine/proc/disk_inserted(datum/source, obj/item/disk/disk, mob/living/user)
	if(!is_type_in_typecache(disk, disk_typecache))
		return

	user.transferItemToLoc(disk, parent)
	disk.moveToNullspace()

	if(src.disk)
		user.put_in_active_hand(src.disk)
		to_chat(user, "<span class='notice'>You swap the disks in [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You insert [disk] into [parent].</span>")

	src.disk = disk

	data_callback.Invoke(disk.data)

	return COMPONENT_NO_AFTERATTACK

/datum/component/diskmachine/proc/eject(datum/source, mob/user)
	if(!disk)
		return

	var/atom/atom_parent = parent

	if(user.canUseTopic(parent, !issilicon(user)) && atom_parent.Adjacent(user) && user.put_in_active_hand(disk))
		to_chat(user, "<span class='notice'>You eject the [disk] from [parent]")
	else
		disk.forceMove(atom_parent.drop_location())

	data_callback.Invoke(null)
	disk = null

/obj/item/disk
	var/datum/data
