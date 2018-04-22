#define SPACE_EXPLORATION_CONFIG_FILE "config/space_exploration_config.txt"

/datum/space_exploration_config
	var/category = 0

	New()
		..()
		var/list/values = GetSpaceExplorationConfigValues(category)
		for(var/val in values)
			if(hasvar(src, val))
				var/value
				if(isnum(text2num(values[val])))
					value = text2num(values[val])
				else
					value = values[val]
				vars[val] = value

/proc/GetSpaceExplorationConfigFromCategory(var/category)
	if(!category)
		return 0

	var/list/lines = world.file2list(SPACE_EXPLORATION_CONFIG_FILE)
	lines = lines.Copy(lines.Find("\[[category]\]") + 1, 0)

	var/line_pos
	for(var/line in lines)
		if(copytext(line, 1, 2) == "#")
			lines.Remove(line)

		if(line == null || line == "" || line == "\n" || line == " ")
			lines.Remove(line)

		if(findtext(line, "\[") && findtext(line, "\]"))
			line_pos = lines.Find(line)
			break

	if(line_pos)
		lines = lines.Copy(1, line_pos)

	return lines

/proc/GetSpaceExplorationConfigValues(var/category)
	if(!category)
		return 0

	var/list/lines = GetSpaceExplorationConfigFromCategory(category)
	var/list/values = list()

	for(var/line in lines)
		var/token = lowertext(copytext(line, 1, findtext(line, " ", 1, 0)))
		var/value = copytext(line, length(token) + 2)

		if(!token)
			continue

		if(values.Find(token))
			var/list/newlist = list()
			newlist += values[token]
			newlist += value

			values[token] = newlist
			continue

		values.Add(token)
		values[token] = value

	return values

#undef SPACE_EXPLORATION_CONFIG_FILE