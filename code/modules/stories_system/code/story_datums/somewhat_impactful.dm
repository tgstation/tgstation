/*
	Somewhat Impactful:
		Stories that will impact around a department of people or so. People in the group will notice, and people really paying attention to the crew will likely see the results.
		Consider it a B-plot.

*/


/datum/story_type/somewhat_impactful
	impact = STORY_SOMEWHAT_IMPACTFUL


/*
	Central Command Inspector
		Plot Summary:
			CentCom has a funny habit of sending down "surprise" inspectors to see what the station's up to,
			despite them rarely liking the results of said inspection. Regardless, they've sent one to make sure things
			are in... some sort of shape, if not good shape.
		Actors:
			Ghost:
				Central Command Inspector (1)
*/
/datum/story_type/somewhat_impactful/centcom_inspector
	name = "Central Command Inspector"
	desc = "A Central Command inspector has come to make sure the station is in... if not good shape, a shape."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/centcom_inspector = 1,
	)

/datum/story_type/somewhat_impactful/centcom_inspector/execute_story()
	. = ..()
	if(!.)
		return FALSE
	addtimer(CALLBACK(src, .proc/inform_station), 3 MINUTES)

/datum/story_type/somewhat_impactful/centcom_inspector/proc/inform_station()
	print_command_report("Hello, an inspector will be arriving shortly for a surprise inspection, ensure they have a pleasant report.", announce = TRUE)


/*
	Syndicate Central Command Inspector
		Plot Summary:
			CentCom has a funny habit of sending down "surprise" inspectors to see what the station's up to,
			which provides an opening for a Syndicate agent to slip in, knock out the real inspector, and assume
			their identity. Very handy when there's things to do and items of value to be stolen, especially %ITEM%.
		Actors:
			Ghost:
				Syndicate Central Command Inspector (1)
*/
/datum/story_type/somewhat_impactful/centcom_inspector/syndicate
	name = "Syndicate Central Command Inspector"
	desc = "A Syndicate agent has impersonated a CentCom inspector, to steal a high-value item while maintaining their cover."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/centcom_inspector/syndicate = 1,
	)

/*
	Mob Money
		Plot Summary:
			A crewmember, %NAME%, has taken out a loan from the space mafia.
			However, their fundamental issue with the plan is that they never paid back, and now the space mafia's looking to collect,
			so they sent a few goons out to the station to shake 'em down for the 20 grand they owe the boss. Good thing for the collectors,
			immediate skeletal repositioning is a valid method of money collection.
		Actors:
			Ghost:
				Mafioso (2)
			Crew:
				Debtor (1)
*/

/datum/story_type/somewhat_impactful/mob_money
	name = "Mob Money"
	desc = "Some crewman's gotten themselves involved in organized crime, and now owes 20k to some mafiosos."
	actor_datums_to_make = list( // mob_debt needs to be first in the list to populate poor_sod for the mafiosos to get the correct objective text
		/datum/story_actor/crew/mob_debt = 1,
		/datum/story_actor/ghost/mafioso = 2,
	)
	/// Ref of the guy the mafiosos are hunting
	var/mob/living/carbon/human/poor_sod

/datum/story_type/somewhat_impactful/mob_money/Destroy(force, ...)
	poor_sod = null
	return ..()

/datum/story_type/somewhat_impactful/paradigm_shift
	name = "Paradigm Shift"
	desc = "Nanotrasen has seen fit to send middle management to every department to help efficiently operationalize our strategy to invest in world class technology \
	and leverage our core competencies in order to holistically administrate exceptional synergy."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/cargo = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/security = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/science = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/service = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/engineering = 1,
		/datum/story_actor/ghost/spawn_in_arrivals/middle_management/medbay = 1,
	)

/*
	Guardian Angel
	Written by Oscar Gilmour
		Plot Summary:
			An old veteran works to protect their charge from those who would seek to harm them…
		Actors:
			Ghost:
				Veteran (1)
*/

/datum/story_type/somewhat_impactful/guardian_angel
	name = "Guardian Angel"
	desc = "An old veteran works to protect their charge from those who would seek to harm them…\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_arrivals/veteran = 1,
	)
	maximum_execute_times = 1

/*
	Guardnapped!
	Written by Oscar Gilmour
		Plot Summary:
			After an incident involving a guard and a baton, a fugitive must now hide from the law… as the law.
		Actors:
			Ghost:
				Fugitive (1)
				Real Guard (1)
*/

/datum/story_type/somewhat_impactful/guardnapped
	name = "Guardnapped!"
	desc = "After an incident involving a guard and a baton, a fugitive must now hide from the law… as the law.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/spawn_in_maint/fugitive = 1,
	)
	maximum_execute_times = 1
	num_of_acts = 2

/datum/story_type/somewhat_impactful/guardnapped/update_act()
	. = ..()
	switch(current_act)
		if(2)
			var/succeeded = add_actors(list(/datum/story_actor/ghost/spawn_in_maint/real_guard = 1))
			if(!succeeded)
				message_admins("STORY: Guardnapped! failed to spawn the real guard due to a lack of candidates. Restarting act timer to try again.")
				current_act--
				addtimer(CALLBACK(src, .proc/update_act), time_between_acts) // since it was at 2 the timer wasn't already running, so we'll try it again.
				CRASH("STORY: Guardnapped! failed to spawn the real guard due to a lack of candidates. Restarting act timer to try again.")

/*
	Worldjumper
	Written by Oscar Gilmour
		Plot Summary:
			A visitor from another universe must adjust to the insanity of Space Station 13.
		Actors:
			Ghost:
				Worldjumper (1)
				Second Jumper (1)
			Crew:
				Multiverse Researcher (1)
*/

/datum/story_type/somewhat_impactful/worldjumper
	name = "Worldjumper"
	desc = "A visitor from another universe must adjust to the insanity of Space Station 13.\n\
	Written by Oscar Gilmour."
	actor_datums_to_make = list(
		/datum/story_actor/ghost/teleporting_spawn/worldjumper = 1,
		/datum/story_actor/crew/multiverse_researcher = 1,
	)
	maximum_execute_times = 1
	num_of_acts = 2
	/// What's the name of the Worldjumper?
	var/worldjumper_name = "Arnold Schwarzenegger"
	/// What's the reference to the Worldjumper's mob?
	var/mob/living/carbon/human/worldjumper_human

/datum/story_type/somewhat_impactful/worldjumper/update_act()
	. = ..()
	switch(current_act)
		if(2)
			var/datum/story_actor/crew/multiverse_researcher/multiverse_researcher
			var/succeeded = add_actors(list(/datum/story_actor/ghost/teleporting_spawn/second_jumper = 1))
			if(!succeeded)
				message_admins("STORY: Worldjumper failed to spawn the second jumper due to a lack of candidates. Restarting the act timer to try again.")
				current_act--
				addtimer(CALLBACK(src, .proc/update_act), time_between_acts) // since it was at 2 the timer wasn't already running, so we'll try it again.
				CRASH("STORY: Worldjumper failed to spawn the second jumper due to a lack of candidates. Restarting the act timer to try again.")
			for(var/datum/mind/actor_mind as anything in mind_actor_list)
				var/datum/story_actor/actor_datum = mind_actor_list[actor_mind]
				switch(actor_datum.type)
					if(/datum/story_actor/crew/multiverse_researcher)
						multiverse_researcher = actor_datum
			multiverse_researcher.actor_info = "This new visitor has certainly made things more interesting… but there's now an issue to address.\n\n\
			Your scanner has burst into life once more. Someone else has arrived. Yet that little itch in the back of your mind is telling you this visitor isn't here to contribute \
			to your research. They might be here to bring [worldjumper_name] back to where they came from. You can't let that happen."
			multiverse_researcher.actor_goal = "Ensure [worldjumper_name] stays in your world."
			multiverse_researcher.ui_interact(multiverse_researcher.actor_ref.current)
