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
	RegisterSignal(target_datum, COMSIG_PARENT_QDELETING, .proc/handle_tagged_del, override = TRUE)
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
#define TAG_DEL(X) "<b>(<A href='?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];del_tag=[REF(X)]'>UNTAG</a>)</b>"
#define TAG_MARK(X) "<b>(<A href='?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];mark_datum=[REF(X)]'>MARK</a>)</b>"
#define TAG_SIMPLE_HEALTH(X) "<font color='#ff0000'><b>Health: [X.health]</b></font>"
#define TAG_CARBON_HEALTH(X) "<font color='#ff0000'><b>Health: [X.health]</b></font> (\
					<font color='#ff3333'>[X.getBruteLoss()]</font> \
					<font color='#ff9933'>[X.getFireLoss()]</font> \
					<font color='#00cc66'>[X.getToxLoss()]</font> \
					<font color='#00cccc'>[X.getOxyLoss()]</font>\
					[X.getCloneLoss() ? " <font color='#1c3ac4'>[X.getCloneLoss()]</font>" : ""])"

/// Display all of the tagged datums
/datum/admins/proc/display_tags()
	set category = "Admin.Game"
	set name = "View Tags"

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!", confidential = TRUE)
		return

	var/index = 0
	var/list/dat = list("<center><B>Tag Menu</B></center><hr>")

	dat += "<br><A href='?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];show_tags=1'>Refresh</a><br>"
	if(LAZYLEN(tagged_datums))
		for(var/datum/iter_datum as anything in tagged_datums)
			index++
			var/specific_info

			if(isnull(iter_datum))
				dat += "\t[index]: Null reference - Check runtime logs!"
				stack_trace("Null datum found in tagged datum menu! User: [usr]")
				continue
			else if(iscarbon(iter_datum))
				var/mob/living/carbon/resolved_carbon = iter_datum
				specific_info = "[TAG_CARBON_HEALTH(resolved_carbon)] | [AREACOORD(resolved_carbon)] [ADMIN_PP(iter_datum)] [ADMIN_FLW(iter_datum)]"
			else if(isliving(iter_datum))
				var/mob/living/resolved_living = iter_datum
				specific_info = "[TAG_SIMPLE_HEALTH(resolved_living)] | [AREACOORD(resolved_living)] [ADMIN_PP(iter_datum)] [ADMIN_FLW(iter_datum)]"
			else if(ismob(iter_datum))
				var/atom/resolved_atom = iter_datum // needed for ADMIN_JMP
				specific_info = "[AREACOORD(resolved_atom)] [ADMIN_PP(iter_datum)] [ADMIN_FLW(iter_datum)]"
			else if(ismovable(iter_datum))
				var/atom/resolved_atom = iter_datum // needed for ADMIN_JMP
				specific_info = "[AREACOORD(resolved_atom)] [ADMIN_FLW(iter_datum)]"
			else if(isatom(iter_datum))
				var/atom/resolved_atom = iter_datum // needed for ADMIN_JMP
				specific_info = "[AREACOORD(resolved_atom)] [ADMIN_JMP(resolved_atom)]"
			else if(istype(iter_datum, /datum/controller/subsystem))
				var/datum/controller/subsystem/resolved_subsystem = iter_datum
				specific_info = "[resolved_subsystem.stat_entry()]"
			// else, it's just a /datum

			dat += "\t[index]: [iter_datum] | [specific_info] | [ADMIN_VV(iter_datum)] | [TAG_DEL(iter_datum)] | [iter_datum == marked_datum ? "<b>Marked</b>" : TAG_MARK(iter_datum)] "
			dat += "\t(<b><font size='2'>[iter_datum.type])</font></b>"
	else
		dat += "No datums tagged :("

	dat = dat.Join("<br>")
	usr << browse(dat, "window=tag;size=800x480")

#undef TAG_DEL
#undef TAG_MARK
#undef TAG_SIMPLE_HEALTH
#undef TAG_CARBON_HEALTH
