///Used to calculate how large a text file is.
#define BLOCK_SIZE 250

/**
 * Base DATA file type
 * Doesn't do anything, mostly here for organization.
 */
/datum/computer_file/data
	filetype = "DAT"

/**
 * Holds data in string format.
 */
/datum/computer_file/data/text
	filetype = "TXT"

	/// Stored data in string format.
	var/stored_text = ""

/datum/computer_file/data/text/clone()
	var/datum/computer_file/data/text/temp = ..()
	temp.stored_text = stored_text
	return temp

// Calculates file size from amount of characters in saved string
/datum/computer_file/data/text/proc/calculate_size()
	size = max(1, round(length(stored_text) / BLOCK_SIZE))

/**
 * A text file with a different filetype
 * Used for flavortext
 */
/datum/computer_file/data/text/logfile
	filetype = "LOG"

/**
 * Ordnance data
 * Holds possible experiments to do
 */
/datum/computer_file/data/ordnance
	filetype = "ORD"
	size = 4

	/// List of experiments filtered by doppler array or populated by the tank compressor. Experiment path as key, score as value.
	var/list/possible_experiments

/datum/computer_file/data/ordnance/proc/return_data()
	return null

/datum/computer_file/data/ordnance/clone()
	var/datum/computer_file/data/ordnance/temp = ..()
	temp.possible_experiments = possible_experiments
	return temp

/**
 * Explosive data
 * Holds a specific taychon record.
 */
/datum/computer_file/data/ordnance/explosive
	filetype = "DOP"
	/// Tachyon record, used for an explosive experiment.
	var/datum/data/tachyon_record/explosion_record

/datum/computer_file/data/ordnance/explosive/return_data()
	return explosion_record

/datum/computer_file/data/ordnance/explosive/clone()
	var/datum/computer_file/data/ordnance/explosive/temp = ..()
	temp.explosion_record = explosion_record
	return temp

/**
 * Gaseous data
 * Holds a specific compressor record.
 */
/datum/computer_file/data/ordnance/gaseous
	filetype = "COM"
	///The gas record stored in the file.
	var/datum/data/compressor_record/gas_record

/datum/computer_file/data/ordnance/gaseous/return_data()
	return gas_record

/datum/computer_file/data/ordnance/gaseous/clone()
	var/datum/computer_file/data/ordnance/gaseous/temp = ..()
	temp.gas_record = gas_record
	return temp

/datum/computer_file/data/paint_project
	filetype = "NPNT"
	/// The sprite editor workspace stored in the file
	var/datum/sprite_editor_workspace/workspace
	/// The unmodified photo or painting this is a digital copy of.
	var/source_photo_or_painting

/datum/computer_file/data/paint_project/New(datum/sprite_editor_workspace/workspace, source_photo_or_painting)
	..()
	src.workspace = workspace
	src.source_photo_or_painting = source_photo_or_painting

/datum/computer_file/data/paint_project/clone(rename)
	var/datum/computer_file/data/paint_project/temp = ..()
	temp.workspace = workspace.copy()
	temp.source_photo_or_painting = source_photo_or_painting
	return temp

/// Assign this file's backing datum
/datum/computer_file/data/paint_project/proc/set_source(new_source)
	source_photo_or_painting = new_source

#undef BLOCK_SIZE
