/*
EXTRA EXAMINE MODULE

This is the module for handling items with special examine stats,
like syndicate items having information in their description that
would only be recognisable with someone that had the syndicate trait.
*/

// Give the detective the ability to see this stuff.
/datum/job/detective
	mind_traits = list(TRAIT_DETECTIVE)

/obj/item
	//The special description that is triggered when special_desc_requirements are met. Make sure you set the correct EXAMINE_CHECK!
	var/special_desc = ""

	//The special affiliation type, basically overrides the "Syndicate Affiliation" for SYNDICATE check types. It will show whatever organisation you put here instead of "Syndicate Affiliation"
	var/special_desc_affiliation = ""

	//The requirement setting for special descriptions. See examine_defines.dm for more info.
	var/special_desc_requirement = EXAMINE_CHECK_NONE

	//The ROLE requirement setting if EXAMINE_CHECK_ROLE is set. E.g. ROLE_SYNDICATE. As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_roles

	//The JOB requirement setting if EXAMINE_CHECK_JOB is set. E.g. JOB_SECURITY_OFFICER. As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_jobs

	//The FACTION requirement setting if EXAMINE_CHECK_FACTION is set. E.g. "Syndicate". As you can see, it's a list. So when setting it, ensure you do = list(shit1, shit2)
	var/list/special_desc_factions


/obj/item/examine(mob/user)
	. = ..()
	if(special_desc_requirement == EXAMINE_CHECK_NONE && special_desc)
		. += span_notice("This item could be examined further...")

/obj/item/examine_more(mob/user)
	. = ..()
	if(special_desc)
		var/composed_message
		switch(special_desc_requirement)
			//Will always show if set
			if(EXAMINE_CHECK_NONE)
				composed_message = "You note the following: <br>"
				composed_message += special_desc
				. += composed_message
			//Mindshield checks
			if(EXAMINE_CHECK_MINDSHIELD)
				if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
					composed_message = "You note the following because of your <span class='blue'><b>mindshield</b></span>: <br>"
					composed_message += special_desc
					. += composed_message
			//Standard syndicate checks
			if(EXAMINE_CHECK_SYNDICATE)
				if(user.mind)
					var/datum/mind/M = user.mind
					if((M.special_role == ROLE_TRAITOR) || (ROLE_SYNDICATE in user.faction))
						composed_message = "You note the following because of your <span class='red'><b>[special_desc_affiliation ? special_desc_affiliation : "Syndicate Affiliation"]</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else if(HAS_TRAIT(M, TRAIT_DETECTIVE))  //Useful detective!
						composed_message = "You note the following because of your brilliant <span class='blue'><b>Detective skills</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
			//As above, but with a toy desc for those looking at it
			if(EXAMINE_CHECK_SYNDICATE_TOY)
				if(user.mind)
					var/datum/mind/M = user.mind
					if((M.special_role == ROLE_TRAITOR) || (ROLE_SYNDICATE in user.faction))
						composed_message = "You note the following because of your <span class='red'><b>[special_desc_affiliation ? special_desc_affiliation : "Syndicate Affiliation"]</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else if(HAS_TRAIT(M, TRAIT_DETECTIVE)) //Useful detective!
						composed_message = "You note the following because of your brilliant <span class='blue'><b>detective skills</b></span>: <br>"
						composed_message += special_desc
						. += composed_message
					else
						composed_message = "The popular toy resembling [src] from your local arcade, suitable for children and adults alike."
						. += composed_message
			//Standard role checks
			if(EXAMINE_CHECK_ROLE)
				if(user.mind)
					var/datum/mind/M = user.mind
					for(var/role_i in special_desc_roles)
						if(M.special_role == role_i)
							composed_message = "You note the following because of your <b>[role_i]</b> role: <br>"
							composed_message += special_desc
							. += composed_message
			//Standard job checks
			if(EXAMINE_CHECK_JOB)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					for(var/job_i in special_desc_jobs)
						if(H.job == job_i)
							composed_message = "You note the following because of your job as a <b>[job_i]</b>: <br>"
							composed_message += special_desc
							. += composed_message
			//Standard faction checks
			if(EXAMINE_CHECK_FACTION)
				for(var/faction_i in special_desc_factions)
					if(faction_i in user.faction)
						composed_message = "You note the following because of your loyalty to <b>[faction_i]</b>: <br>"
						composed_message += special_desc
						. += composed_message

/*
*	EXAMPLES
*/

/obj/item/storage/backpack/duffelbag/syndie
	name = "duffel bag"
	desc = "A large duffel bag for holding extra supplies."
	special_desc_requirement = EXAMINE_CHECK_SYNDICATE
	special_desc = "This bag is used to store tactical equipment and is manufactured by the syndicate."
