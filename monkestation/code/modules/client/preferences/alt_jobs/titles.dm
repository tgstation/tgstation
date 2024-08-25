/**
 * This is the file you should use to add alternate titles for each job, just
 * follow the way they're done here, it's easy enough and shouldn't take any
 * time at all to add more or add some for a job that doesn't have any.
 */

/datum/job
	/// The list of alternative job titles people can pick from, null by default.
	var/list/alt_titles = null


/datum/job/ai
	alt_titles = list(
		"AI",
		"Station Intelligence",
		"Automated Overseer"
	)

/datum/job/assistant
	alt_titles = list(
		"Assistant",
		"Civilian",
		"Tourist",
		"Businessman",
		"Businesswoman",
		"Trader",
		"Entertainer",
		"Freelancer",
		"Artist",
		"Off-Duty Staff",
		"Off-Duty Crew",
	)

/datum/job/atmospheric_technician
	alt_titles = list(
		"Atmospheric Technician",
		"Life Support Technician",
		"Emergency Fire Technician",
		"Firefighter",
	)

/datum/job/bartender
	alt_titles = list(
		"Bartender",
		"Mixologist",
		"Barkeeper",
		"Barista",
	)

/datum/job/bitrunner
	alt_titles = list(
		"Bitrunner",
		"Bitdomain Technician",
		"Data Retrieval Specialist",
		"Netdiver",
		"Pod Jockey",
		"Union Bitrunner",
	)

/datum/job/botanist
	alt_titles = list(
		"Botanist",
		"Hydroponicist",
		"Gardener",
		"Botanical Researcher",
		"Herbalist",
		"Florist",
		"Rancher",
	)

/datum/job/brig_physician
	alt_titles = list(
		"Brig Physician",
		"Jail Doctor",
		"Brig Orderly",
		"Prison Medic",
		"Chief Tickler",
		"Navy Corpsman",
	)

/datum/job/captain
	alt_titles = list(
		"Captain",
		"Station Commander",
		"Commanding Officer",
		"Site Manager",
		"Criminally Underpaid Babysitter",
	)

/datum/job/cargo_technician
	alt_titles = list(
		"Cargo Technician",
		"Warehouse Technician",
		"Deck Worker",
		"Mailman",
		"Union Associate",
		"Inventory Associate",
	)

/datum/job/chaplain
	alt_titles = list(
		"Chaplain",
		"Priest",
		"Preacher",
		"Reverend",
		"Oracle",
		"Pontifex",
		"Magister",
		"High Priest",
		"Imam",
		"Rabbi",
		"Monk",
	)

/datum/job/chemist
	alt_titles = list(
		"Chemist",
		"Pharmacist",
		"Pharmacologist",
		"Trainee Pharmacist",
	)

/datum/job/chief_engineer
	alt_titles = list(
		"Chief Engineer",
		"Engineering Foreman",
		"Head of Engineering",
	)

/datum/job/chief_medical_officer
	alt_titles = list(
		"Chief Medical Officer",
		"Medical Director",
		"Head of Medical",
		"Chief Physician",
		"Head Physician",
	)

/datum/job/clown
	alt_titles = list(
		"Clown",
		"Jester",
		"Joker",
		"Comedian",
		"Professional Nuisance",
	)

/datum/job/cook
	alt_titles = list(
		"Cook",
		"Chef",
		"Butcher",
		"Culinary Artist",
		"Sous-Chef",
		"Pizzaiolo",
	)

/datum/job/curator
	alt_titles = list(
		"Curator",
		"Librarian",
		"Journalist",
		"Archivist",
		"Radio Host",
	)

/datum/job/cyborg
	alt_titles = list(
		"Cyborg",
		"Robot",
		"Android",
	)

/datum/job/detective
	alt_titles = list(
		"Detective",
		"Forensic Technician",
		"Private Investigator",
		"Forensic Scientist",
	)

/datum/job/doctor
	alt_titles = list(
		"Medical Doctor",
		"Surgeon",
		"Nurse",
		"General Practitioner",
		"Medical Resident",
		"Physician",
	)

/datum/job/engineering_guard //see orderly

/datum/job/geneticist
	alt_titles = list(
		"Geneticist",
		"Mutation Researcher",
	)

/datum/job/head_of_personnel
	alt_titles = list(
		"Head of Personnel",
		"Executive Officer",
		"Employment Officer",
		"Crew Supervisor",
	)

/datum/job/head_of_security
	alt_titles = list(
		"Head of Security",
		"Security Commander",
		"Chief Constable",
		"Chief of Security",
		"Sheriff",
	)

/datum/job/janitor
	alt_titles = list(
		"Janitor",
		"Custodian",
		"Custodial Technician",
		"Sanitation Technician",
		"Maintenance Technician",
		"Concierge",
		"Maid",
	)

/datum/job/lawyer
	alt_titles = list(
		"Lawyer",
		"Internal Affairs Agent",
		"Human Resources Agent",
		"Defence Attorney",
		"Public Defender",
		"Barrister",
		"Prosecutor",
		"Legal Clerk",
	)

/datum/job/mime
	alt_titles = list(
		"Mime",
		"Pantomimist",
	)

/datum/job/paramedic
	alt_titles = list(
		"Paramedic",
		"Emergency Medical Technician",
		"Search and Rescue Technician",
	)

/datum/job/prisoner
	alt_titles = list(
		"Prisoner",
		"Minimum Security Prisoner",
		"Maximum Security Prisoner",
		"SuperMax Security Prisoner",
		"Protective Custody Prisoner",
		"Convict",
		"Felon",
		"Inmate",
		"Gamer",
	)

/datum/job/psychologist
	alt_titles = list(
		"Psychologist",
		"Psychiatrist",
		"Therapist",
		"Counsellor",
	)

/datum/job/quartermaster
	alt_titles = list(
		"Quartermaster",
		"Union Requisitions Officer",
		"Deck Chief",
		"Warehouse Supervisor",
		"Supply Foreman",
		"Pretend Head of Supply",
		"Logistics Coordinator",
		"Cargyptian Overseer",
	)

/datum/job/research_director
	alt_titles = list(
		"Research Director",
		"Silicon Administrator",
		"Lead Researcher",
		"Biorobotics Director",
		"Research Supervisor",
		"Chief Science Officer",
	)

/datum/job/roboticist
	alt_titles = list(
		"Roboticist",
		"Biomechanical Engineer",
		"Mechatronic Engineer",
		"Apprentice Roboticist",
	)

/datum/job/science_guard //See orderly

/datum/job/scientist
	alt_titles = list(
		"Scientist",
		"Circuitry Designer",
		"Xenobiologist",
		"Cytologist",
		"Plasma Researcher",
		"Anomalist",
		"Lab Technician",
		"Theoretical Physicist",
		"Ordnance Technician",
		"Xenoarchaeologist",
		"Research Assistant",
		"Graduate Student",
	)

/datum/job/security_officer
	alt_titles = list(
		"Security Officer",
		"Security Operative",
		"Peacekeeper",
		"Security Cadet",
	)

/datum/job/shaft_miner
	alt_titles = list(
		"Shaft Miner",
		"Union Miner",
		"Excavator",
		"Spelunker",
		"Drill Technician",
		"Prospector",
	)

/datum/job/station_engineer
	alt_titles = list(
		"Station Engineer",
		"Emergency Damage Control Technician",
		"Electrician",
		"Engine Technician",
		"EVA Technician",
		"Mechanic",
		"Apprentice Engineer",
		"Engineering Trainee",
	)

/datum/job/virologist
	alt_titles = list(
		"Pathologist",
		"Fish Doctor",
		"Junior Pathologist",
		"Plague Doctor",
	)

/datum/job/warden
	alt_titles = list(
		"Warden",
		"Brig Sergeant",
		"Dispatch Officer",
		"Brig Governor",
		"Jailer",
	)
