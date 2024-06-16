/// Sent when /datum/storage/dump_content_at(): (obj/item/storage_source, mob/user)
#define COMSIG_STORAGE_DUMP_CONTENT "storage_dump_contents"
	/// Return to stop the standard dump behavior.
	#define STORAGE_DUMP_HANDLED (1<<0)
/// Sent after dumping into some other storage object: (atom/dest_object, mob/user)
#define COMSIG_STORAGE_DUMP_POST_TRANSFER "storage_dump_into_storage"

/// Fired off the storage's PARENT when an ITEM is STORED INSIDE. (obj/item, mob, force)
#define COMSIG_ATOM_STORED_ITEM "atom_storing_item"

/// Fired off the storage's PARENT when an ITEM is REMOVED. (obj/item, atom, silent)
#define COMSIG_ATOM_REMOVED_ITEM "atom_removing_item"

/// Sent to the STORAGE when an ITEM is STORED INSIDE. (obj/item, mob, force)
#define COMSIG_STORAGE_STORED_ITEM "storage_storing_item"

/// Sent to the STORAGE when an ITEM is REMOVED. (obj/item, atom, silent)
#define COMSIG_STORAGE_REMOVED_ITEM "storage_removing_item"
