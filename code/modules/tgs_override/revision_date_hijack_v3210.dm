#ifndef TGS_V3_API
#error Codebase no longer compiled for TGSv3210. Remove hijack implementation
#endif

#define TGS_FILE2LIST(filename) (splittext(trim_left(trim_right(file2text(filename))), "\n"))

/datum/tgs_api/v3210/var/revision_date
/datum/tgs_api/v3210/OnWorldNew(minimum_required_security_level)
	. = ..()
	if(. == FALSE)
		return

	var/list/logs = TGS_FILE2LIST(".git/logs/HEAD")
	if(length(logs) >= 5)
		var/unix_timestamp = text2num(logs[5])
		if(isnum(unix_timestamp))
			unix_timestamp += world.timezone * 3600
			unix_timestamp -= 946684800
			unix_timestamp *= 10
			revision_date = "[time2text(unix_timestamp, "YYYY-MM-DDThh:mm:ss", 0)]+00:00"
		else
			TGS_ERROR_LOG("Failed to parse timestamp from commit logs")

	return .

/datum/tgs_api/v3210/Revision()
	var/datum/tgs_revision_information/revision_info = ..()
	if(!isnull(revision_date))
		revision_info.timestamp = revision_date
	return revision_info

#undef TGS_FILE2LIST
