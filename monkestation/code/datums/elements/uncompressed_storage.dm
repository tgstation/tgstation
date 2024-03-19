/// An item with this element can be compressed by a bluespace
/datum/element/uncompressed_storage

/datum/element/uncompressed_storage/Attach(obj/item/target)
	. = ..()
	if(!istype(target) || QDELETED(target.atom_storage))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_BYPASS_COMPRESS_CHECK, REF(src))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_COMPRESSED, PROC_REF(on_compressed))

/datum/element/uncompressed_storage/Detach(obj/item/target, ...)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_COMPRESSED))
	REMOVE_TRAIT(target, TRAIT_BYPASS_COMPRESS_CHECK, REF(src))

/datum/element/uncompressed_storage/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	// Only display the examine the storage hasn't been delete, and like, the user actually HAS a compression kit.
	if(QDELETED(source.atom_storage) || !length(examiner.get_all_contents_type(/obj/item/compression_kit)))
		return
	examine_list += span_notice("It can be compressed with a bluespace compression kit, <b>but it will lose its ability to store items if compressed.</b>")

/datum/element/uncompressed_storage/proc/on_compressed(obj/item/source, mob/user, obj/item/compression_kit/kit)
	SIGNAL_HANDLER
	if(QDELETED(source.atom_storage))
		return
	to_chat(user, span_warning("\The [source] loses its ability to store items as its compressed by \the [kit]!"))
	source.atom_storage.remove_all(source.drop_location())
	QDEL_NULL(source.atom_storage)
