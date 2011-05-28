var/list/occupations = list(
	"Station Engineer", "Station Engineer", "Station Engineer", "Station Engineer", "Station Engineer",
	"Shaft Miner", "Shaft Miner", "Shaft Miner",
	"Security Officer", "Security Officer", "Security Officer", "Security Officer", "Security Officer",
	"Detective",
	"Warden",
	"Geneticist", "Geneticist",
	"Scientist",	"Scientist", "Scientist",
	"Atmospheric Technician", "Atmospheric Technician", "Atmospheric Technician", "Atmospheric Technician",
	"Medical Doctor", "Medical Doctor", "Medical Doctor", "Medical Doctor", "Medical Doctor",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chaplain",
	"Roboticist",
	"Cyborg",//"Cyborg","Cyborg","Cyborg","Cyborg", < Fuck that. Seriously. -- Urist
	"AI",
	"Bartender",
	"Chef",
	"Janitor",
	"Clown", "Mime",
	"Chemist", "Chemist",
	"Quartermaster",
	"Cargo Technician","Cargo Technician","Cargo Technician",
	"Botanist", "Botanist",
	"Librarian",
	"Lawyer",
	"Virologist",
	"Chief Medical Officer")

var/list/assistant_occupations = list(
	"Assistant")

var/list/head_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
)

/proc/is_important_job(var/job)
	return (job in head_positions) || (job in list("AI", "Cyborg", "Warden", "Detective"))
