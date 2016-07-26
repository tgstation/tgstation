// By Carnwennan
//
// This system was made as an alternative to all the in-game lists and variables used to log stuff in-game.
// lists and variables are great. However, they have several major flaws:
// Firstly, they use memory. TGstation has one of the highest memory usage of all the ss13 branches.
// Secondly, they are usually stored in an object. This means that they aren't centralised. It also means that
// the data is lost when the object is deleted! This is especially annoying for things like the singulo engine!
//
// Reworked a bit by N3X15 for /vg/, 2014.

// Where we plop our logs.
#define INVESTIGATE_DIR "data/investigate/"

// Just in case
#define AVAILABLE_INVESTIGATIONS list(I_HREFS,I_NOTES,I_NTSL,I_SINGULO,I_ATMOS,I_CHEMS,I_WIRES)

// Actual list of global controllers.
var/global/list/investigations=list(
	I_HREFS   = null, // Set on world.New()
	I_NOTES   = new /datum/log_controller(I_NOTES),
	I_NTSL    = new /datum/log_controller(I_NTSL),
	I_SINGULO = new /datum/log_controller(I_SINGULO),
	I_ATMOS   = null, //new /datum/log_controller("atmos",filename="data/logs/[date_string] atmos.htm", persist=TRUE),
	I_CHEMS   = null, // Set on world.New()
	I_WIRES   = null // Set on world.New()
)

// Handles appending shit to log.
/datum/log_controller
	var/subject=""
	var/filename
	var/handle // File handle

// Set up the logging for a particular investigation subject.
//  sub      = Subject ID
//  persist  = Do we delete the log on starting a new round?
//  filename = Set to override default filename, otherwise leave null.
/datum/log_controller/New(var/sub, var/persist=FALSE, var/filename=null)
	subject = sub
	src.filename = "[INVESTIGATE_DIR][subject].html"

	// Overridden filename?
	if(!isnull(filename))
		src.filename = filename

	// Delete existing files before opening? (akin to 'w' mode rather than 'a'ppend)
	if(!persist)
		fdel(src.filename)

	// Persistent file handle.
	handle = file(src.filename)

/datum/log_controller/proc/write(var/message)
	handle << message

/datum/log_controller/proc/read(var/mob/user)
	user << browse(handle,"window=investigate[subject];size=800x300")

// Calls our own formatting functions, but then appends to the global log.
/atom/proc/investigation_log(var/subject, var/message)
	var/datum/log_controller/I = investigations[subject]
	if(!I)
		warning("SOME ASSHAT USED INVALID INVESTIGATION ID [subject]")
		return
	var/formatted=format_investigation_text(message)
	I.write(formatted)
	return formatted

// Permits special snowflake formatting.
/atom/proc/format_investigation_text(var/message)
	var/turf/T = get_turf(src)
	return "<small>[time2text(world.timeofday,"hh:mm:ss")] \ref[src] ([T.x],[T.y],[T.z])</small> || [src] [message]<br />"

// Permits special snowflake formatting.
/mob/format_investigation_text(var/message)
	return "<small>[time2text(world.timeofday,"hh:mm:ss")] \ref[src] ([x],[y],[z])</small> || [key_name(src)] [message]<br />"

// For non-atoms or very specific messages.
/proc/minimal_investigation_log(var/subject, var/message, var/prefix)
	var/datum/log_controller/I = investigations[subject]
	if(!I)
		warning("SOME ASSHAT USED INVALID INVESTIGATION ID [subject]")
		return
	I.write("<small>[time2text(world.timeofday,"hh:mm:ss")][prefix]</small> || [message]<br />")

//ADMINVERBS
/client/proc/investigate_show(var/subject in AVAILABLE_INVESTIGATIONS)
	set name = "Investigate"
	set category = "Admin"

	if(!holder)
		to_chat(src, "<span class='warning'>You're not an admin, go away.</span>")
		return

	if(!(subject in investigations))
		to_chat(src, "<span class='warning'>Unable to find that subject.</span>")
		return

	var/datum/log_controller/I = investigations[subject]
	if(!I)
		to_chat(src, "<span class='warning'>No log for [subject] can be found.</span>")
		return

	I.read(usr)
