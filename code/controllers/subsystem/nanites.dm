SUBSYSTEM_DEF(nanites)
	name = "Nanites"
	flags = SS_NO_FIRE
	
	var/list/obj/machinery/computer/nanite_cloud_controller/cloud_storage = list()
	var/list/datum/component/nanites/cloud/cloud_backups = list()
	var/list/mob/living/nanite_monitored_mobs = list()
	var/list/datum/nanite_program/relay/nanite_relays = list()

/datum/controller/subsystem/nanites/proc/check_hardware()
	if(!LAZYLEN(cloud_storage))
		QDEL_LIST(cloud_backups) //uh oh we're out of backups
		return FALSE
	for(var/X in cloud_storage)
		var/obj/machinery/computer/nanite_cloud_controller/storage = X
		if(storage.stat & (NOPOWER|BROKEN))
			continue
		else
			return TRUE
	return FALSE
	
/datum/controller/subsystem/nanites/proc/get_cloud_backup(cloud_id, force = FALSE)
	if(!force && !check_hardware())
		return
	for(var/I in cloud_backups)
		var/datum/component/nanites/cloud/backup = I
		if(backup.cloud_id == cloud_id)
			return backup

/datum/controller/subsystem/nanites/proc/generate_cloud_backup(cloud_id)
	if(get_cloud_backup(cloud_id, TRUE))
		return
	var/datum/component/nanites/cloud/backup = new(src)
	backup.cloud_id = cloud_id
	cloud_backups += backup

/datum/controller/subsystem/nanites/proc/delete_cloud_backup(cloud_id)
	var/datum/component/nanites/cloud/backup = get_cloud_backup(cloud_id, TRUE)
	if(backup)
		cloud_backups -= backup
		qdel(backup)