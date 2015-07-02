
#define ENGSEC		(1<<0)

#define CAPTAIN		(1<<0)
#define HOS			(1<<1)
#define WARDEN		(1<<2)
#define DETECTIVE	(1<<3)
#define OFFICER		(1<<4)
#define CHIEF		(1<<5)
#define ENGINEER	(1<<6)
#define ATMOSTECH	(1<<7)
#define ROBOTICIST	(1<<8)
#define AI			(1<<9)
#define CYBORG		(1<<10)


#define MEDSCI		(1<<1)

#define RD			(1<<0)
#define SCIENTIST	(1<<1)
#define CHEMIST		(1<<2)
#define CMO			(1<<3)
#define DOCTOR		(1<<4)
#define GENETICIST	(1<<5)
#define VIROLOGIST	(1<<6)


#define CIVILIAN	(1<<2)

#define HOP			(1<<0)
#define BARTENDER	(1<<1)
#define BOTANIST	(1<<2)
#define COOK		(1<<3)
#define JANITOR		(1<<4)
#define LIBRARIAN	(1<<5)
#define QUARTERMASTER (1<<6)
#define CARGOTECH	(1<<7)
#define MINER		(1<<8)
#define LAWYER		(1<<9)
#define CHAPLAIN	(1<<10)
#define CLOWN		(1<<11)
#define MIME		(1<<12)
#define ASSISTANT	(1<<13)


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
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Virologist",
	"Chemist"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Roboticist"
)


var/list/supply_positions = list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
)


var/list/civilian_positions = list(
	"Bartender",
	"Botanist",
	"Cook",
	"Janitor",
	"Librarian",
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
