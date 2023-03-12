/datum/story_actor/ghost/spawn_in_arrivals
	name = "Spawn In Arrivals template"

/datum/story_actor/ghost/spawn_in_arrivals/send_them_in(mob/living/carbon/human/to_send_human)
	to_send_human.client?.prefs?.safe_transfer_prefs_to(to_send_human)
	. = ..()
	var/atom/spawn_location = SSjob.get_last_resort_spawn_points()
	spawn_location.JoinPlayerHere(to_send_human, TRUE) // This will drop them on the arrivals shuttle, hopefully buckled to a chair. Worst case, they go to the error room.

/datum/story_actor/ghost/spawn_in_arrivals/shore_leave
	name = "Shore Leave Sailor"
	actor_outfits = list(
		/datum/outfit/centcom/centcom_intern,
	)
	actor_info = "You've been working on a ship for the last year with no shore leave. Finally, your ship's docked at a NT station and you and your buddies finally have some \
	well deserved shore leave. Find some good booze, find some good food, and get some R&R in with the boys. Cut loose, let off some steam, and be a proud navy man!"
	actor_goal = "Get drunk with the boys. Have some good fucking food at the kitchen. Be rowdy and merry. Get into fights, be a nuisance, be obnoxious to the station."

/datum/story_actor/ghost/spawn_in_arrivals/small_business_owner
	name = "Small Business Owner"
	actor_outfits = list(
		/datum/outfit/small_business_owner,
	)
	actor_info = "After a small loan of a million credits from your dear old dad, you're finally ready to start your dream small business. You got a sweet deal on this \
	prime piece of real estate in the middle of the hallways on this Nanotrasen station, and after all's said and done you've got 100,000 credits remaining to pay the \
	construction team you've hired, pay any staff you need to hire, and handle any business with the station locals. However, remember to keep a healthy paycheck for yourself, \
	after all, where would this business be without your economic genius?"
	actor_goal = "Come up with a genius business plan. Have your construction workers pick a high traffic part of the hallways to construct your business in, \
	in a manner that requires the crew to traverse through your business and the construction site to get around the station. \
	Pay the construction workers as little as possible to keep them working on the construction of the business. \
	Be an aggressively proud capitalist. Employ people on the station to work in your business for as little as possible. \
	Negotiate with the annoying union rep the construction workers brought with them. Ensure your business gets as much traffic as possible."

/datum/story_actor/ghost/spawn_in_arrivals/construction_foreman
	name = "Construction Foreman"
	actor_outfits = list(
		/datum/outfit/construction_worker/foreman,
	)
	actor_info = "You've spent the last 15 years running the finest construction contractors in the frontier. Today, some rich kid walked up to you and said they wanted to \
	pay your team to build a \"groundbreaking new business on the most valuable real estate in the area\" and after some contract negotiations with the assistance of your \
	union representative, you've secured a contract for you and three of your best workers to accompany him to the property and start construction right away. He didn't \
	mention the job was on a Nanotrasen station until you arrived. Best of luck to you and your workers."
	actor_goal = "Direct your construction team. Work with the Union Rep to ensure safe practices are being followed. Work with the Small Business Owner to get your men paid for \
	their work. Construct whatever hare brained scheme the Small Business Owner comes up with."

/datum/story_actor/ghost/spawn_in_arrivals/construction_worker
	name = "Construction Worker"
	actor_outfits = list(
		/datum/outfit/construction_worker,
	)
	actor_info = "You're a contract construction worker under a foreman you trust and respect. They've never led you astray in the past, but this new job seems a bit \
	suspect. The customer's a bit of an idiot capitalist, and your union rep has concerns. However, he's adamant he's good for the money, so trust in the boss and \
	we'll all get paid."
	actor_goal = "Work with your Foreman. Build shit. Get paid. Go on your union mandated lunches and breaks and union meetings when needed. Be a hard working union man."

/datum/story_actor/ghost/spawn_in_arrivals/union_rep
	name = "Construction Union Representative"
	actor_outfits = list(
		/datum/outfit/construction_worker/union_rep,
	)
	actor_info = "You're a union represenative for Construction Workers and Service Employees Union Local 132, and you're goddamn proud of the union. However, you're worried \
	this new small business owner might cause problems for your fellow union workers. Make sure that capitalist bastard follows the rules, and that the employees get their \
	mandated hours, their mandated breaks, their mandated lunches, and most of all, their mandated pay. Although, the local Nanotrasen employees seem to be without a union. \
	Perhaps it'd be worth your time to get them involved in the galactic struggle for workers' rights?"
	actor_goal = "Stand up for the rights of your fellow union spacers. Keep tabs on the construction and treatment of the workers and make sure everything's to union code. \
	Recruit Nanotrasen employees to join the union, along with anyone that scumbag Small Business Owner hires. Do everything in your power to ensure the union protects \
	its' workers."

/datum/story_actor/ghost/spawn_in_arrivals/middle_management
	name = "Middle Management"
	actor_outfits = list(
		/datum/outfit/middle_management,
	)
	actor_info = "After years in business schooling, years of middle management in Nanotrasen, and delivering on KPI growth quarter by quarter every time, Nanotrasen has seen fit \
	to send you to fix this underperforming department in their station program. Today, you'll be managing %DEPARTMENT%. Once you arrive, it's time to work your magic and turn this \
	underperforming, unprofitable, and budget draining mess into a high quality profit earning team of high energy full time employees. Do whatever it takes to turn a profit and make \
	this department a successful business venture."
	actor_goal = "Go to and be annoying middle management in %DEPARTMENT%. Hold meetings. Drink coffee. Assign people to tasks. \
	Deploy management philsophies to develop client-centric solutions. Run the department like a business, to turn a profit. \
	Talk like an annoying management person all the time. Circle back with employees. Touch bases with problem team members. \
	Identify actionable success metrics, and action on them.<br><br>\
	NOTE: Think about some of the worst managers you've ever had in your jobs over the years. Be like them."
	var/department = "Debug Department, File A Bug Report If You See This"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/handle_spawning(mob/picked_spawner, datum/story_type/current_story)
	actor_info = replacetext(actor_info, "%DEPARTMENT%", department)
	actor_goal = replacetext(actor_goal, "%DEPARTMENT%", department)
	return ..()


/datum/story_actor/ghost/spawn_in_arrivals/middle_management/security
	actor_outfits = list(/datum/outfit/middle_management/security)
	department = "Security"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/science
	actor_outfits = list(/datum/outfit/middle_management/science)
	department = "Science"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/service
	actor_outfits = list(/datum/outfit/middle_management/service)
	department = "Service"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/engineering
	actor_outfits = list(/datum/outfit/middle_management/engineering)
	department = "Engineering"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/medbay
	actor_outfits = list(/datum/outfit/middle_management/medbay)
	department = "Medbay"

/datum/story_actor/ghost/spawn_in_arrivals/middle_management/cargo
	actor_outfits = list(/datum/outfit/middle_management/cargo)
	department = "Cargo"

/datum/story_actor/ghost/spawn_in_arrivals/med_student
	name = "Medical Student"
	actor_outfits = list(
		/datum/outfit/medical_student,
	)
	actor_info = "You're a first-year medical student from some cushy Spinward university, out on a Nanotrasen station as part of a joint partnership for some hands-on education."
	actor_goal = "Learn from the station's medical department, ask an obnoxious amoount of questions, and act as incompetent at medical work as any first-year student would be."

/datum/story_actor/ghost/spawn_in_arrivals/agent
	name = "Agent"
	actor_outfits = list(
		/datum/outfit/story_agent,
	)
	actor_info = "Honestly you've probably screwed the captain's cat on this one.<br><br>\
	In an effort to boost your client's sales, you figured a book tour was in order. A visit to inhabitable worlds (and even some inhospitable ones too) didn't do much for royalties,\
	and getting robbed by the space mafia didn't help either. So you signed both your souls away to NanoTrasen in hopes of tapping into the corporate market…<br><br>\
	Shame that also means you're working for them now."
	actor_goal = "Survive the shift. Help your client sell their book. Collect your 10% at all costs."

/datum/story_actor/ghost/spawn_in_arrivals/author
	name = "Author"
	actor_outfits = list(
		/datum/outfit/story_author,
	)
	actor_info = "You're not quite sure what drove you to write. An attempt to fulfill a childhood dream? A yearning passion to speak of the burning injustices dominating the galaxy? \
	Or the thought of rolling around in a pile of money? Either way, you've utterly failed in this career thus far. So much so that your agent has signed you up to work on \
	a space station, among the plebs of society. Fantastic. Still, there's an opportunity to sell some books here… and to figure out what to do with your agent."
	actor_goal = "Survive the shift. Sell your books. Figure out what to do with your agent."

/datum/story_actor/ghost/spawn_in_arrivals/author/send_them_in(mob/living/carbon/human/to_send_human)
	. = ..()
	var/datum/story_type/unimpactful/auteurs_in_space/story = involved_story
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)
	for(var/i in 1 to 5)
		var/obj/item/book/authors_book/book = new
		book.book_data = new(story.chosen_book_name, to_send_human.name, "The text is so dense, so unending, that you can't make sense of a single word.")
		to_send_human.equip_in_one_of_slots(book, slots)

/datum/story_actor/ghost/spawn_in_arrivals/inspector
	name = "Inspector"
	actor_outfits = list(
		/datum/outfit/inspector,
	)
	actor_info = "They all used to laugh at you. Mocked you for memorizing Space Structure Regulations, giggled when you recited the top seventeen vessel violations, \
	and straight-up spaced you one time you corrected a fellow student on the proper amount of wiring to power solar panels. Now, your hard work has paid off. \
	The academy has sent you here to ensure the station is up to code. At least, you're pretty sure they did. That was an official letter you received, right?"
	actor_goal = "Uncover every single regulatory violation, even the most minute ones. Ensure the captain knows about all of them. Rant about the nichest information from your book."

/datum/story_actor/ghost/spawn_in_arrivals/veteran
	name = "Veteran"
	actor_outfits = list(
		/datum/outfit/veteran,
	)
	actor_info = "It's been a long and bloodied life…<br><br>\
	Broken bones. Bullets rending flesh. Explosions shattering apart everything you've ever known. You put all of that behind you, for a time. \
	You found work on vessels drifting into the darkest depths, seeking to distance yourself from those you served. Oh certainly there were those who questioned your origins. \
	Syndicate? Merc? Gunner for the Black Hole Barons? You glared them all off…<br><br>\
	And now you find yourself here. Something stirs within you as you gaze upon them. An echo of your old life. One that must be preserved at all costs."
	actor_goal = "Ensure your charge survives the shift. Only harm those who are hostile to your charge."
	/// Stores their charge reference
	var/mob/living/carbon/human/charge
	/// Stores the charge's name.
	var/charge_name
	/// Has the charge gone into critical condition already to prevent message spam?
	var/is_charge_in_critical = FALSE

/datum/story_actor/ghost/spawn_in_arrivals/veteran/send_them_in(mob/living/carbon/human/to_send_human)
	. = ..()
	var/list/potential_charges = list()
	for (var/datum/mind/crewmember as anything in get_crewmember_minds())
		if(crewmember?.current?.stat == DEAD || !crewmember.current || !crewmember?.current?.client) // dont select someone as their charge if they're dead already or don't have a client
			continue
		if(crewmember?.current == to_send_human) // haha, no
			continue
		potential_charges += crewmember.current
	if(!length(potential_charges))
		CRASH("No potential charges for the Guardian Angel story to function on. This should never occur.")
	charge = pick(potential_charges)
	charge_name = charge.real_name
	to_chat(to_send_human, span_boldannounce("Your mission is to protect [charge_name]"))
	actor_goal = "Ensure your charge, [charge_name], survives the shift. Only harm those who are hostile to your charge."
	RegisterSignal(charge, COMSIG_LIVING_DEATH, PROC_REF(charge_death))
	RegisterSignal(charge, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(charge_health_changed))

/datum/story_actor/ghost/spawn_in_arrivals/veteran/proc/charge_death(mob/living/source)
	SIGNAL_HANDLER
	to_chat(actor_ref.current, span_boldannounce("[charge_name] is dead. You have failed."))

/datum/story_actor/ghost/spawn_in_arrivals/veteran/proc/charge_health_changed(mob/living/source)
	SIGNAL_HANDLER
	if(source.stat <= SOFT_CRIT && !is_charge_in_critical)
		is_charge_in_critical = TRUE
		to_chat(actor_ref.current, span_boldannounce("A terrible feeling washes over you. [charge_name] [source.p_are()] in grave danger."))
	else if(source.stat == CONSCIOUS)
		is_charge_in_critical = FALSE
