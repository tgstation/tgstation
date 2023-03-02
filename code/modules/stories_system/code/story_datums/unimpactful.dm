/*
	Unimpactful:
		Stories that will impact a few people. Easily missable by the crew, but those involved will be aware they're involved when the story makes itself known.
*/

/datum/story_type/unimpactful
	impact = STORY_UNIMPACTFUL

/*
	Shore Leave
		Plot Summary:
			A group of 3 NT ensigns are on shore leave and decided to come to the nearest station as their
			place of rest. They might get a bit rowdy, but who wouldn't for their first shore leave in a year?
		Actors:
			Ghost:
				Ensign (3)
*/

/datum/story_type/unimpactful/shore_leave
	name = "Shore Leave"
	desc = "A few Nanotrasen Fleet Ensigns are arriving on the station for shore leave."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/shore_leave = 3,
	)
	maximum_execute_times = 1


/*
	TPS Reports (Multiple Departments):
		Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology and leverage our core competencies in order to holistically
		administrate exceptional synergy. We'll set a brand trajectory using management philosophies to advance our marketshare vis-a-vis via proven methodologies with strong committment to quality effectively enhancing
		corporate synergy. They will transition the department by awareness of functionality to promote viability providing their supply chain with diversity to distill their identity through client-centric solutions and synergy.
		At the end of the day, the department must monetize their assets via the fundamentals of change to visualize a value added experience that will grow the business infrastructure to monetize their assets. These managers
		will bring to the table our capitalized reputation proactively overseeing day to day operations, services and deliverables with cross-platform innovation, and networking will bring seamless integration in a robust and
		scalable bleeding edge and next generation, best of breed, will succeed in the department achieving globalization and gaining traction in the marketplace in a mission critical incentivized flexible solution for our customer
		base with a paradigm shift.
		Actors:
			Ghost:
				Middle Management
*/
// TODO: Condense this into one story
/datum/story_type/unimpactful/tps_reports_security
	name = "TPS Reports (Security)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/security = 1,
	)

/datum/story_type/unimpactful/tps_reports_service
	name = "TPS Reports (Service)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/service = 1,
	)

/datum/story_type/unimpactful/tps_reports_science
	name = "TPS Reports (Science)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/science = 1,
	)

/datum/story_type/unimpactful/tps_reports_engineering
	name = "TPS Reports (Engineering)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/engineering = 1,
	)

/datum/story_type/unimpactful/tps_reports_medbay
	name = "TPS Reports (Medbay)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/medbay = 1,
	)

/datum/story_type/unimpactful/tps_reports_cargo
	name = "TPS Reports (Cargo)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/cargo = 1,
	)
/*
	Medical Students
		Plot Summary:
			As part of a school funding initiative, various schools in the Spinward Stellar Coalition have partnered with Nanotrasen to get first year medical students some real hands on learning.
			Unfortunately for the station, medical students tend to be very, very unexperienced.
		Actors:
			Ghost:
				Medical Student (3)
*/

/datum/story_type/unimpactful/medical_students
	name = "Medical Students"
	desc = "A group of medical students come to the station for some hands-on learning."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/med_student = 3,
	)
	maximum_execute_times = 2

/*
	Ominous Past
	Written by Oscar Gilmour
		Plot Summary:
			No one knows what happened to them… and at this point, people are afraid to ask.
		Actors:
			Crew:
				Ominous (1)
*/

/datum/story_type/unimpactful/ominous
	name = "Ominous Past"
	desc = "No one knows what happened to them… and at this point, people are afraid to ask.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/ominous = 1,
	)
	maximum_execute_times = 1

/*
	Zoldorf’s Apprentice
	Written by Oscar Gilmour
		Plot Summary:
			The future is yours to wield… about 27% of the time.
		Actors:
			Crew:
				Ominous (1)
*/

/datum/story_type/unimpactful/zoldorfs_apprentice
	name = "Zoldorf's Apprentice"
	desc = "The future is yours to wield… about 27% of the time.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/apprentice = 1,
	)
	maximum_execute_times = 1

/*
	Auteurs in Space
	Written by Oscar Gilmour
		Plot Summary:
			Your book tour has brought you to the darkest corner of the galaxy.
		Actors:
			Ghost:
				Author (1)
				Agent (1)
*/

/datum/story_type/unimpactful/auteurs_in_space
	name = "Auteurs in Space"
	desc = "Your book tour has brought you to the darkest corner of the galaxy.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/author = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/agent = 1,
	)
	maximum_execute_times = 1
	/// The list of potential book names.
	var/list/book_names = list(
		"The Monkey Butt Diet - Fifty-two Scented Recipes!",
		"If I Did Done Do It - A Nuclear Operative's Tale",
		"Traits of Traitors - A Study in Antagonism ",
		"Canceling Death - The secrets doctors won't teach you!",
		"Does anybody love me? The Mailman's Tragedy",
		"Honk - A Biography",
		"Oh Captain, My Captain - Tales from the Bridge",
		"Please behave for one fucking shift - A plea from Security",
		"Racked with Guilt - That time I programmed a bad law",
		"Nanotrasen Exposed! You won't believe what they're putting in the drinks!",
	)
	/// The chosen book name, used to populate info on the Author's books.
	var/chosen_book_name = "Variable Defaults And You - A Shocking Tale Of Broken Code"

/datum/story_type/unimpactful/auteurs_in_space/pre_execute()
	chosen_book_name = pick(book_names)

/*
	Sample Smuggler
	Written by Oscar Gilmour
		Plot Summary:
			Smuggle goods off the station for an anonymous client.
		Actors:
			Crew:
				Smuggler (1)
*/

/datum/story_type/unimpactful/sample_smuggler
	name = "Sample Smuggler"
	desc = "Smuggle goods off the station for an anonymous client.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/smuggler = 1,
	)
	maximum_execute_times = 1

/*
	The Quest for the Perfect Brew
	Written by Oscar Gilmour
		Plot Summary:
			Find the perfect blend of coffee that made you feel happy for the first time…
		Actors:
			Crew:
				Coffee Critic (1)
*/

/datum/story_type/unimpactful/the_quest_for_the_perfect_brew
	name = "The Quest for the Perfect Brew"
	desc = "Find the perfect blend of coffee that made you feel happy for the first time…\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/coffee_critic = 1,
	)
	maximum_execute_times = 1


/*
	Alternative Medicine
	Written by Oscar Gilmour
		Plot Summary:
			Who knows what they’re putting in those Medbots? Time for some natural medicine.
		Actors:
			Crew:
				Salesperson (1)
*/

/datum/story_type/unimpactful/alternative_medicine
	name = "Alternative Medicine"
	desc = "Who knows what they’re putting in those Medbots? Time for some natural medicine.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/salesperson = 1,
	)
	maximum_execute_times = 1


/*
	Regulation Station
	Written by Oscar Gilmour
		Plot Summary:
			The hardiest corpo won’t bat an eyelid at the Syndicate, but they’ll quake in fear when you show them the 127 ways they violated Space Law.
		Actors:
			Ghost:
				Inspector (1)
*/

/datum/story_type/unimpactful/regulation_station
	name = "Regulation Station"
	desc = "The hardiest corpo won't bat an eyelid at the Syndicate, but they'll quake in fear when you show them the 127 ways they violated Space Law.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/inspector = 1,
	)
	maximum_execute_times = 1

/*
	Regulation Station
	Written by Oscar Gilmour
		Plot Summary:
			You’ve been here before, and you know disaster is less than ninety minutes away…
		Actors:
			Crew:
				Visionist (1)
*/

/datum/story_type/unimpactful/visions
	name = "Visions"
	desc = "You've been here before, and you know disaster is less than ninety minutes away…\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/crew/visionist = 1,
	)
	maximum_execute_times = 1
