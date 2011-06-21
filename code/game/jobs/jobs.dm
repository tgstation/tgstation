var/list/occupations = list(
	//Civilian jobs
	"Head of Personnel"      = 1,
	//soul
	"Clown"                  = 1,
	"Mime"                   = 1,
	"Chaplain"               = 1,
	"Librarian"              = 1,
	"Lawyer"                 = 1,
	//body
	"Bartender"              = 1,
	"Chef"                   = 1,
	"Janitor"                = 1,
	"Quartermaster"          = 1,
	"Cargo Technician"       = 3,
	"Shaft Miner"            = 3,

	//engineering
	"Chief Engineer"         = 1,
	"Station Engineer"       = 5,
	"Atmospheric Technician" = 4,
	"Roboticist"             = 1,

	//red shirts
	"Head of Security"       = 1,
	"Warden"                 = 1,
	"Detective"              = 1,
	"Security Officer"       = 5,

	//medbay
	"Chief Medical Officer"  = 1,
	"Medical Doctor"         = 5,
	"Chemist"                = 2,

	//science dept
	"Research Director"      = 1,
	"Geneticist"             = 2,
	"Scientist"              = 3,
	"Botanist"               = 2,
	"Virologist"             = 1,

	//I afraid I can't do that, Dave
	"AI" = 1,
	"Cyborg" = 1,

)

var/list/assistant_occupations = list(
	"Assistant",
	//"Tourist", //I am not going to implement these jobs at the moment. Just listed it as examples. --rastaf0
	//"Monkey",
	//"Prisoneer",
	//"Lizard",
)

var/list/head_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	//"Monkey",
	//"Lizard",
)

/proc/is_important_job(var/job)
	return (job in head_positions) || (job in list("AI", "Cyborg", "Warden", "Detective"))
