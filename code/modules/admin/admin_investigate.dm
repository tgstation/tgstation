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
#define AVAILABLE_INVESTIGATIONS list("hrefs","notes","ntsl","singulo","atmos")

// Actual list of global controllers.
var/global/list/investigations=list(
	"hrefs"   = null, // Set on world.New()
	"notes"   = new /datum/log_controller("notes"),
	"ntsl"    = new /datum/log_controller("ntsl"),
	"singulo" = new /datum/log_controller("singulo"),
	"atmos"   = new /datum/log_controller("atmos"),
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
	return "<small>[time2text(world.timeofday,"hh:mm")] \ref[src] ([x],[y],[z])</small> || [src] [message]<br />"

//ADMINVERBS
/client/proc/investigate_show(var/subject in AVAILABLE_INVESTIGATIONS)
	set name = "Investigate"
	set category = "Admin"

	if(!holder)
		src << "<span class='warning'>You're not an admin, go away.</span>"
		return

	if(!(subject in investigations))
		src << "<span class='warning'>Unable to find that subject.</span>"
		return

	var/datum/log_controller/I = investigations[subject]
	if(!I)
		src << "<span class='warning'>No log for [subject] can be found.</span>"
		return

	I.read(usr)