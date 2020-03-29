/datum/component/diskmachine
	/// the disk to be held
	var/obj/item/disk/disk
	/// callback for passing the data
	var/datum/callback/data_callback



/datum/component/diskmachine/proc/disk_inserted(datum/source, obj/item/disk/disk, mob/living/user)
	if(!istype(disk))
		return

	user.transferItemToLoc(disk, src)
	src.disk = disk

	data_callback.Invoke(disk.data)

