/proc/render_stats(list/stats, user, sort = GLOBAL_PROC_REF(cmp_generic_stat_item_time))
	sortTim(stats, sort, TRUE)

	var/list/lines = list()

	for (var/entry in stats)
		var/list/data = stats[entry]
		lines += "[entry] => [num2text(data[STAT_ENTRY_TIME], 10)]ms ([data[STAT_ENTRY_COUNT]]) (avg:[num2text(data[STAT_ENTRY_TIME]/(data[STAT_ENTRY_COUNT] || 1), 99)])"

	if (user)
		user << browse("<ol><li>[lines.Join("</li><li>")]</li></ol>", "window=[url_encode("stats:[REF(stats)]")]")

	. = lines.Join("\n")

/proc/stat_tracking_export_to_file_later(filename, costs, counts)
	if (IsAdminAdvancedProcCall())
		return

	var/list/output = list()

	for (var/key in costs)
		output[key] = list(
			"cost" = costs[key],
			"count" = counts[key],
		)

	rustg_file_write(json_encode(output), "[GLOB.log_directory]/[filename]")
