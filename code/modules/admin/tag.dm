/**
 * Creates a weakref of the target datum and inserts it into [/datum/admins/var/tagged_datums], for later reference.
 *
 * Note that if the original target is deleted and another datum is put in the same memory address, tthis
 *
 * Arguments:
 * * target_datum - The datum you want to create a tag for. Should be the datum itself, not a weakref
 */
/datum/admins/proc/add_tagged_datum(datum/target_datum)
	for(var/datum/weakref/iter_weakref as anything in tagged_datums)
		var/datum/resolved_ref = iter_weakref.resolve()
		if(resolved_ref == target_datum)
			to_chat(owner, span_warning("[target_datum] is already tagged!"))
			return

	var/datum/weakref/new_weakref = WEAKREF(target_datum)
	LAZYADD(tagged_datums, new_weakref)
	RegisterSignal(target_datum, COMSIG_PARENT_QDELETING, .proc/handle_tagged_del)
	to_chat(owner, span_notice("[target_datum] has been tagged."))

/// Get ahead of the curve with deleting
/datum/admins/proc/handle_tagged_del(datum/source)
	SIGNAL_HANDLER

	if(owner)
		to_chat(owner, span_boldnotice("Tagged datum [source] ([source.type]) has been deleted."))
	remove_tagged_datum(source)

/**
 * Attempts to remove the specified datum from [/datum/admins/var/tagged_datums] if it exists
 *
 * The argument can be either the datum itself or the specific weakref used to link to it from this admins datum.
 *
 * Arguments:
 * * target_datum - The datum you want to remove from the tagged_datums list. Can also be the specific weakref used in said list.
 */
/datum/admins/proc/remove_tagged_datum(datum/target_datum)
	if(isnull(target_datum))
		return

	if(!istype(target_datum)) // for handling memory REF(X)'s to the target datum
		target_datum = locate(target_datum)

	if(isweakref(target_datum)) // no need to iterate and resolve each weakref
		if(LAZYFIND(tagged_datums, target_datum))
			LAZYREMOVE(tagged_datums, target_datum)
			qdel(target_datum)
			to_chat(owner, span_notice("[target_datum] has been untagged."))
		else
			to_chat(owner, span_warning("[target_datum] was not already tagged."))
		return
	else // we have to actually resolve each tagged weakref to see which one is ours
		for(var/datum/weakref/iter_weakref as anything in tagged_datums)
			var/datum/resolved_ref = iter_weakref.resolve()
			if(resolved_ref == target_datum)
				LAZYREMOVE(tagged_datums, iter_weakref)
				qdel(iter_weakref)
				UnregisterSignal(target_datum, COMSIG_PARENT_QDELETING)
				to_chat(owner, span_notice("[target_datum] has been untagged."))
				return

		to_chat(owner, span_warning("[target_datum] was not already tagged."))

/// Simply removes all of the weakref's that don't resolve to anything.
/datum/admins/proc/clear_nulled_tags()
	var/cleared_nulls = 0

	for(var/datum/weakref/iter_weakref as anything in tagged_datums)
		if(!iter_weakref.resolve())
			LAZYREMOVE(tagged_datums, iter_weakref)
			qdel(iter_weakref)
			cleared_nulls++

	if(cleared_nulls)
		to_chat(owner, span_notice("[cleared_nulls] nulls cleared."))
	else
		to_chat(owner, span_warning("No nulls found."))


/// Quick define for readability
#define TAG_DEL(X) "<b>(<A href='?src=[REF(src)];[HrefToken(TRUE)];del_tag=[REF(X)]'>UNTAG</a>)</b>"

/// Display all of the tagged datums
/datum/admins/proc/display_tags()
	set category = "Admin.Game"
	set name = "View Tags"

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!", confidential = TRUE)
		return

	var/nulls_found = 0
	var/index = 0
	var/list/dat = list("<center><B>Tag Menu</B></center><hr>")

	dat += "<br><A href='?src=[REF(src)];[HrefToken(TRUE)];show_tags=1'>Refresh</a><br>"
	if(LAZYLEN(tagged_datums))
		for(var/datum/weakref/iter_weakref as anything in tagged_datums)
			index++
			var/datum/resolved_ref = iter_weakref.resolve()
			var/specific_info = ""

			if(isnull(resolved_ref))
				specific_info = "(Null reference)"
				nulls_found++
			else if(ismob(resolved_ref))
				specific_info = "[ADMIN_PP(resolved_ref)] [ADMIN_FLW(resolved_ref)] [ADMIN_VV(resolved_ref)]"
			else if(ismovable(resolved_ref))
				specific_info = "[ADMIN_FLW(resolved_ref)] [ADMIN_VV(resolved_ref)]"
			else if(isatom(resolved_ref))
				var/atom/resolved_atom = resolved_ref
				specific_info = "[ADMIN_JMP(resolved_atom)] [ADMIN_VV(resolved_ref)]"
			else
				specific_info = "[ADMIN_VV(resolved_ref)]]"

			dat += "\t[index]: [resolved_ref] | [specific_info] | [TAG_DEL(iter_weakref)]"
	else
		dat += "No datums tagged :("

	if(nulls_found)
		dat += "<br><b><A href='?src=[REF(src)];[HrefToken(TRUE)];clear_nulls=1'>Clear nulled tags</b></a>"

	dat = dat.Join("<br>")
	usr << browse(dat, "window=tag;size=760x480")

#undef TAG_DEL
