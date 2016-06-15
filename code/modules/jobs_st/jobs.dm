var/const/COMMANDJOBS		=(1<<0)
var/const/CO				=(1<<0)
var/const/EO				=(1<<1)

var/const/SECJOBS		    =(1<<1)
var/const/CSO               =(1<<0)
var/const/TACOFFICER		=(1<<1)
var/const/SECOFFICER		=(1<<2)
var/const/ARMORYOFFICER		=(1<<3)

var/const/OPSJOBS		    =(1<<2)
var/const/COO               =(1<<0)
var/const/HELMSMAN			=(1<<1)
var/const/QM				=(1<<2)
var/const/COMMSOFFICER		=(1<<3)
var/const/DUTYOFFICER		=(1<<4)

var/const/ENGJOBS		    =(1<<3)
var/const/CEO	            =(1<<0)
var/const/ASSCEO			=(1<<1)
var/const/ENGINEER			=(1<<2)
var/const/TRANSPORTECH		=(1<<3)
var/const/HOLOTECH			=(1<<4)
//var/const/EEH				=(1<<3)

var/const/SCIJOBS		    =(1<<4)
var/const/RD                =(1<<0)
var/const/SCIOFFICER		=(1<<1)
var/const/ASTROFFICER		=(1<<2)
var/const/BIOLOGIST			=(1<<3)
var/const/SENSORTECH		=(1<<4)

var/const/MEDJOBS		    =(1<<5)
var/const/CMO               =(1<<0)
var/const/MEDOFFICER		=(1<<1)
var/const/NURSE				=(1<<2)
var/const/COUNSELLOR		=(1<<3)
//var/const/EMH				=(1<<3)

var/const/CIVJOBS		    =(1<<6)
var/const/CHEF              =(1<<0)
var/const/BARTENDER			=(1<<1)

var/const/SPECIALJOBS		=(1<<7)
var/const/AI				=(1<<0)
var/const/MORALEOFFICER		=(1<<1)
var/const/INTELOFFICER		=(1<<2)
var/const/DIPLOMAT			=(1<<3)
var/const/JAG				=(1<<4)
var/const/GUEST				=(1<<5)
var/const/TRADER			=(1<<6)

var/list/assistant_occupations = list(
	"Duty Officer",
	"Tactical Officer",
	"Biologist",
	"Chef",
	"Bartender"
)

var/list/command_positions = list(
	"Commanding Officer",
	"Executive Officer",
	"Chief Security Officer",
	"Chief of Operations",
	"Chief Engineering Officer",
	"Research Director",
	"Chief Medical Officer"
)

var/list/engineering_positions = list(
	"Chief Engineering Officer",
	"Assistant Chief Engineer",
	"Engineer",
//	"EEH",
	"Transporter Technician",
	"Holodeck Technician"
)

var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Nurse",
//	"EMH",
	"Counsellor"
)

var/list/science_positions = list(
	"Research Director",
	"Science Officer",
	"Astrometrics Officer",
	"Biologist",
	"Sensor Technician"
)

var/list/civilian_positions = list(
	"Bartender",
	"Chef"
)

var/list/security_positions = list(
	"Chief Security Officer",
	"Tactical Officer",
	"Security Officer",
	"Armory Officer"
)

var/list/special_positions = list(
	"AI"
)

var/list/operations_positions = list(
	"Chief of Operations",
	"Helmsman",
	"Quartermaster",
	"Comms Technician",
	"Duty Officer"
)

/proc/guest_jobbans(job)
	return ((job in command_positions) || (job in special_positions) || (job in security_positions) || (job in operations_positions))

//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(var/job_title)
	if(!job_title)
		return list()

	for(var/datum/job/J in SSjob.occupations)
		if(J.title == job_title)
			return J.department_head //this is a list