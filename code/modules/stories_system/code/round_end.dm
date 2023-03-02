/datum/controller/subsystem/ticker/proc/story_report()
	var/list/result = list()

	result += "<div class='panel stationborder'><span class='header'>Executed Story Report:</span><br>"

	if(!length(SSstories.used_stories))
		result += span_red("No stories were executed.")
	else
		for(var/datum/story_type/story as anything in SSstories.used_stories)
			result += story.roundend_report()

	result += "<br><br>Remaining budget: <b>[SSstories.budget]</b><br><br>"
	result += "Starting budget: <b>[SSstories.initial_budget]</b>"
	result += "</div>"

	return result.Join()
