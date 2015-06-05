
var/const/ENGSEC			=(1<<0)

var/const/CAPTAIN			=(1<<0)
var/const/HOS				=(1<<1)
var/const/WARDEN			=(1<<2)
var/const/DETECTIVE			=(1<<3)
var/const/OFFICER			=(1<<4)
var/const/CHIEF				=(1<<5)
var/const/ENGINEER			=(1<<6)
var/const/AI				=(1<<7)
var/const/CYBORG			=(1<<8)


var/const/MEDSCI			=(1<<1)

var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/CMO				=(1<<2)
var/const/DOCTOR			=(1<<3)


var/const/CIVILIAN			=(1<<2)

var/const/HOP				=(1<<0)
var/const/BARTENDER			=(1<<1)
var/const/BOTANIST			=(1<<2)
var/const/COOK				=(1<<3)
var/const/JANITOR			=(1<<4)
var/const/LIBRARIAN			=(1<<5)
var/const/QUARTERMASTER		=(1<<6)
var/const/LAWYER			=(1<<7)
var/const/CHAPLAIN			=(1<<8)
var/const/CLOWN				=(1<<9)
var/const/MIME				=(1<<10)
var/const/ASSISTANT			=(1<<11)


var/list/assistant_occupations = list(
	"Assistant",
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
	"Station Engineer"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist"
)


var/list/supply_positions = list(
	"Head of Personnel",
	"Quartermaster"
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
