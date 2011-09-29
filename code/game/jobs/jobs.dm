var/list/occupations = list(
	"Captain"				= 1,

	//civilian
	"Head of Personnel"		= 1,

	"Bartender"				= 1,
	"Botanist"				= 2,
	"Chef"					= 1,
	"Janitor"				= 1,
	"Librarian"				= 1,
	"Quartermaster"			= 1,
	"Cargo Technician"		= 3,
	"Shaft Miner"			= 3,
	"Lawyer" 				= 2,
	"Chaplain" 				= 1,
	"Clown"					= 1,
	"Mime"					= 1,


	//engineering
	"Chief Engineer"		= 1,

	"Station Engineer"		= 5,
	"Atmospheric Technician"= 4,
	"Roboticist"			= 1,

	//medical
	"Chief Medical Officer"	= 1,

	"Medical Doctor"		= 5,
	"Geneticist"			= 2,
	"Virologist"			= 1,


	//science
	"Research Director"		= 1,

	"Scientist"				= 3,
	"Chemist"				= 2,


	//security
	"Head of Security"		= 1,

	"Warden"				= 1,
	"Detective"				= 1,
	"Security Officer"		= 5,


	//silicon
	"AI"					= 1,
	"Cyborg"				= 1,

	"Assistant"				= -1
)


var/list/assistant_occupations = list(
	"Assistant",
	"Atmospheric Technician",
	"Cargo Technician",
	"Chaplain",
	"Lawyer",
	"Librarian"
)


var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)


var/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician",
	"Roboticist"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Virologist"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Chemist"
)


var/list/civilian_positions = list(
	"Head of Personnel",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Lawyer",
	"Chaplain",
	"Clown",
	"Mime",
	"Assistant"
)


var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer"
)


var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)


/proc/guest_jobbans(var/job)
	return ((job in command_positions) || (job in nonhuman_positions) || (job in security_positions))
