/**
 * Inserts the target_datum into [/datum/admins/var/tagged_datums], for later reference.
 *
 * Arguments:
 * * target_datum - The datum you want to create a tag for
 */
/datum/admins/proc/add_tagged_datum(datum/target_datum)
	if(LAZYFIND(tagged_datums, target_datum))
		to_chat(owner, span_warning("[target_datum] is already tagged!"))
		return

	LAZYADD(tagged_datums, target_datum)
	RegisterSignal(target_datum, COMSIG_PARENT_QDELETING, .proc/handle_tagged_del)
	to_chat(owner, span_notice("[target_datum] has been tagged."))

/// Get ahead of the curve with deleting
/datum/admins/proc/handle_tagged_del(datum/source)
	SIGNAL_HANDLER

	if(owner)
		to_chat(owner, span_boldnotice("Tagged datum [source] ([source.type]) has been deleted."))
	remove_tagged_datum(source, silent = TRUE)

/**
 * Attempts to remove the specified datum from [/datum/admins/var/tagged_datums] if it exists
 *
 * Arguments:
 * * target_datum - The datum you want to remove from the tagged_datums list
 * * silent - If TRUE, won't print messages to the owner's chat
 */
/datum/admins/proc/remove_tagged_datum(datum/target_datum, silent=FALSE)
	if(!istype(target_datum))
		return

	if(LAZYFIND(tagged_datums, target_datum))
		LAZYREMOVE(tagged_datums, target_datum)
		if(!silent)
			to_chat(owner, span_notice("[target_datum] has been untagged."))
	else if(!silent)
		to_chat(owner, span_warning("[target_datum] was not already tagged."))

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
		for(var/datum/iter_datum as anything in tagged_datums)
			index++
			var/specific_info = ""

			if(isnull(iter_datum))
				specific_info = "(Null reference)"
				nulls_found++
			else if(ismob(iter_datum))
				specific_info = "[ADMIN_PP(iter_datum)] [ADMIN_FLW(iter_datum)] [ADMIN_VV(iter_datum)]"
			else if(ismovable(iter_datum))
				specific_info = "[ADMIN_FLW(iter_datum)] [ADMIN_VV(iter_datum)]"
			else if(isatom(iter_datum))
				var/atom/resolved_atom = iter_datum // needed for ADMIN_JMP
				specific_info = "[ADMIN_JMP(resolved_atom)] [ADMIN_VV(iter_datum)]"
			else
				specific_info = "[ADMIN_VV(iter_datum)]]"

			dat += "\t[index]: [iter_datum] | [specific_info] | [TAG_DEL(iter_datum)]"
	else
		dat += "No datums tagged :("

	dat = dat.Join("<br>")
	usr << browse(dat, "window=tag;size=760x480")

#undef TAG_DEL
