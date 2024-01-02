PROCESSING_SUBSYSTEM_DEF(nanites)
	name = "Nanites"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 10

	///List of all mobs that have nanites, used by Nanite HUD
	var/list/mob/living/nanite_monitored_mobs = list()

	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	var/list/datum/nanite_program/relay/nanite_relays = list()

/datum/controller/subsystem/processing/nanites/proc/check_hardware(datum/nanite_cloud_backup/backup)
	if(QDELETED(backup.storage) || (backup.storage.machine_stat & (NOPOWER|BROKEN)))
		return FALSE
	return TRUE

/**
 * ##get_cloud_backup
 *
 * Goes through all nanite cloud backups and checks:
 * 1- It works properly (or is forced)
 * 2- It is the same ID as the one we are looking for.
 * Args:
 * cloud_id - the cloud ID we are looking for
 * forced - Whether we should check for hardware or not.
 */
/datum/controller/subsystem/processing/nanites/proc/get_cloud_backup(cloud_id, force = FALSE)
	for(var/datum/nanite_cloud_backup/backup as anything in cloud_backups)
		if(!force && !check_hardware(backup))
			return
		if(backup.cloud_id == cloud_id)
			return backup
