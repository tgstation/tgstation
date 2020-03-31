/datum/component/diskmachine
	/// the disk to be held
	var/obj/item/disk/disk
	/// callback for passing the data
	var/datum/callback/data_callback

/datum/component/diskmachine/Initialize(datum/callback/data_callback)
	src.data_callback = data_callback

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

/datum/component/diskmachine/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_CLICK_ALT,
		COMPONENT_DISK_EJECT,
		COMPONENT_HAS_DISK))

/datum/component/diskmachine/proc/hasdisk()
	if(disk)
		return COMPONENT_DISK_INSERTED

/datum/component/diskmachine/proc/disk_inserted(datum/source, obj/item/disk/disk, mob/living/user)
	if(!istype(disk))
		return

	user.transferItemToLoc(disk, src)

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

	if(user.put_in_active_hand(disk))
		to_chat(user, "<span class='notice'>You eject the [disk] from [parent]")
		data_callback.Invoke(null)
		disk = null

/obj/item/disk
	var/datum/data
