/**
 * Maintenance programs
 *
 * Programs that are found from data disks in maintenance
 * Can only be cloned once to a modular computer, then deletes itself.
 */
/datum/computer_file/program/maintenance
	filetype = "MNT"
	available_on_ntnet = FALSE

/datum/computer_file/program/maintenance/clone(rename = FALSE)
	. = ..()
	if(computer)
		computer.remove_file(src)
	if(disk_host)
		disk_host.remove_file(src)
