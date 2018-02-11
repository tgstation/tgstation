/proc/format_admin_log_object(datum/thing, list/subject_index)  //list because can't pass vars by ref stupidly
	if(ismob(thing) || istype(thing, /client))
		++subject_counter.len
		return "%M[index]%"
	if(isatom(thing))
		++subject_counter.len
		return "[thing] %A[index]%"
	if(istype(thing))
		return thing.type
	if(isnull(thing))
		return "NULL"
	return thing

/proc/admin_log(raw_message, list/formatter, list/subject_atoms, message_admins = FALSE, private = FALSE, write_log = TRUE, update_tickets = TRUE)
	if(formatter && !islist(formatter))
		formatter = list(formatter)
	if(subject_atoms && !islist(subject_atoms))
		subject_atoms = list(subject_atoms)
	var/pre_formatted_message = raw_message
	var/list/subject_counter = list()
	for(var/I in 1 to length(formatter))
		pre_formatted_message = replacetext(pre_formatted_message, "%[I]%", format_admin_log_object(formatter[I], subject_counter))

	if(message_admins)
		var/in_game_formatted_message = pre_formatted_message
		for(var/I in 1 to length(subject_atoms))
			var/atom/A = subject_atoms[I]
			if(!istype(A))
				continue
			in_game_formatted_message = replacetext(in_game_formatted_message, "%M[I]%", ADMIN_LOOKUPFLW(A))
			in_game_formatted_message = replacetext(in_game_formatted_message, "%A[I]%", ADMIN_COORDJMP(A))

		message_admins2(in_game_formatted_message)

	var/log_formatted_message = pre_formatted_message
	for(var/I in 1 to length(subject_atoms))
		var/atom/A = subject_atoms[I]
		if(!istype(A))
			continue
		log_formatted_message = replacetext(in_game_formatted_message, "%M[I]%", COORD(A))
		log_formatted_message = replacetext(in_game_formatted_message, "%A[I]%", key_name(A))

	. = log_formatted_message

	if(write_log)
		write_admin_log(log_formatted_message)
	
	if(!update_tickets)
		return

	var/list/relevant_mobs = list()
	var/list/tickets = list()
	for(var/mob/M in subject_atoms)
		relevant_mobs += I
		var/ticket = M.client.current_ticket
		if(ticket)
			tickets += ticket
	
	for(var/I in tickets)
		var/datum/admin_help/AH = I
		AH.AddInteraction(in_game_formatted_message, log_formatted_message)
