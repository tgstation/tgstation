/*
	Very Impactful:
		Stories that will likely impact multiple departments and the crew in general. If you don't keep a finger on the station's pulse, you could miss these, but it's
		unlikely the crew won't have some idea this is going on.
*/



/datum/story_type/very_impactful
	impact = STORY_VERY_IMPACTFUL

/*
	Contractors:
		Nanotrasen sold a chunk of the station's hallways to the highest bidder for a tidy sum. As a result, a team of unionized construction workers and their union rep are on the station about to tear up
		a section of your hallways to build a business for their capitalist overlords. The station's engineers and it's crew will have to contend with this construction project, the zoning requirements,
		and all that hassle, all while dodging union recruitment attempts by their union rep.
		Actors:
			Ghost:
				Small Business Owner
				Construction Foreman
				Construction Union Rep
				3x Construction Workers
*/

/datum/story_type/very_impactful/contractors
	name = "Contractors"
	desc = "A small business owner has purchased a chunk of the station's hallways for business development. The buyer has arrived with a unionized construction crew \
	to build their new business right in the middle of traffic on the station."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/small_business_owner = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/construction_foreman = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/union_rep = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/construction_worker = 3,
	)

/*
	Management Overload (Multiple Departments):
		Nanotrasen has seen fit to send A LOT middle management for a department to help efficiently operationalize our strategy to invest in world class technology and leverage our core competencies in order to holistically
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
// TODO: condense this into 1 story type, not sure why I made it 5 separate types
/datum/story_type/very_impactful/tps_reports_security
	name = "Management Overload (Security)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/security = 3,
	)

/datum/story_type/very_impactful/tps_reports_service
	name = "Management Overload (Service)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/service = 3,
	)

/datum/story_type/very_impactful/tps_reports_science
	name = "Management Overload (Science)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/science = 3,
	)

/datum/story_type/very_impactful/tps_reports_engineering
	name = "Management Overload (Engineering)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/engineering = 3,
	)

/datum/story_type/very_impactful/tps_reports_medbay
	name = "Management Overload (Medbay)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/medbay = 3,
	)

/datum/story_type/very_impactful/tps_reports_cargo
	name = "Management Overload (Cargo)"
	desc = "Nanotrasen has seen fit to send middle management for a department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/cargo = 3,
	)
