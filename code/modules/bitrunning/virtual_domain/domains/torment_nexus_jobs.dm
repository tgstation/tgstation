/datum/lazy_template/virtual_domain/janitor_work_test
	name = "Janitorial Work: Test"
	desc = "Cremwmeber causing janitorial issues? Teach them how to clean up."
	help_text = "Test domain for janitorial work."
	key = "janitor_work_test"
	map_name = "janitor_work_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/janitor

/datum/lazy_template/virtual_domain/janitor_work_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

	for(var/obj/item/gun/ballistic/ballistic_gun in created_atoms)
		ballistic_gun.magazine.empty_magazine()

	for(var/obj/item/gun/energy/energy_gun in created_atoms)
		energy_gun.cell.charge = 0
		energy_gun.update_icon()

	for(var/obj/item/ammo_casing/casing in created_atoms)
		casing.loaded_projectile = null
		casing.update_icon_state()

/datum/outfit/job/prisoner/janitor
	name = "Janitor (Prisoner)"
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	ears = null
	shoes = /obj/item/clothing/shoes/galoshes
	skillchips = null
	backpack_contents = null

/datum/lazy_template/virtual_domain/customer_push_test
	name = "Tourist Assistance: Test"
	desc = "Crewmember being rude to our guests? Teach them how to help their fellow tourist."
	help_text = "Test domain for Tourist Assistance."
	key = "customer_push_test"
	map_name = "customer_push_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/waiter

/datum/lazy_template/virtual_domain/customer_push_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

/datum/outfit/job/prisoner/waiter
	name = "Waiter (Prisoner)"
	neck = /obj/item/clothing/neck/bowtie
	suit = /obj/item/clothing/suit/apron
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/collectable/chef
	ears = null
	shoes = /obj/item/clothing/shoes/laceup
	skillchips = null
	backpack_contents = null

/datum/lazy_template/virtual_domain/teleporter_maze_test
	name = "Teleporter Maze Mapping: Test"
	desc = "Crewmember making it hard to get around the station? Teach them how to respect easily navigatable areas."
	help_text = "Test domain for Teleporter Maze."
	key = "teleporter_maze_test"
	map_name = "teleporter_maze_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/scientist

/datum/lazy_template/virtual_domain/teleporter_maze_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

/datum/outfit/job/prisoner/scientist
	name = "Scientist (Prisoner)"
	neck = /obj/item/clothing/neck/tie/horrible
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	uniform = /obj/item/clothing/under/rank/prisoner
	head = null
	glasses = /obj/item/clothing/glasses/science
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/purple
	skillchips = null
	backpack_contents = null

/datum/lazy_template/virtual_domain/pizza_guarding_base
	name = "After-Hours Pizzeria Guarding: Base"
	desc = "Crewmember breaking into places? Teach them how to respect private property."
	help_text = "Watch the cameras. Don't burn too much power. Stay alive through the night. Failure will result in restarting."
	key = "fredingtonfastingbear"
	map_name = "fredingtonfastingbear"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner
	test_only = TRUE // Don't show the base class
	var/list/starting_ai_levels = list(
		/obj/bitrunning/animatronic/standard = 0,
		/obj/bitrunning/animatronic/janitor = 0,
		/obj/bitrunning/animatronic/engineering = 0,
		/obj/bitrunning/animatronic/security = 0,
	)
	var/list/phone_message = list(
		"ay yo the pizza here",
	)

/datum/lazy_template/virtual_domain/pizza_guarding_base/mischief
	name = "After-Hours Pizzeria Guarding: Mischief"
	desc = "Welcome to your first night as a night guard at the Nanotrasen Pizza Express!"
	key = "fredingtonfastingbear_mischief"
	difficulty = BITRUNNER_DIFFICULTY_NONE
	test_only = FALSE
	reward_points = BITRUNNER_REWARD_MIN
	starting_ai_levels = list(
			/obj/bitrunning/animatronic/standard = 0,
			/obj/bitrunning/animatronic/janitor = 0,
			/obj/bitrunning/animatronic/engineering = 0,
			/obj/bitrunning/animatronic/security = 0,
	)
	phone_message = list(
		"Hello? Hello hello?",
		"Uh, I wanted to record a message for you, to help you get settled in on your first night. ",
		"Um, I actually worked in that office before you, I'm finishing up my last week now as a matter of fact. ",
		"So, I know it can be a bit overwhelming, but I'm here to tell you there's nothing to worry about, Uh, you'll do fine. ",
		"So, let's just focus on getting you through your first week, okay?",
		"Uh, let's see, first there's an introductory greeting from the corporation, that I'm supposed to read. ",
		"Uh, it's kind of a legal thing, you know.",
		"Um, welcome to the Nanotrasen Pizza Express, a science-fiction filled place for bored crewmembers and friends slash family of crew alike, where science and pizza come to life. ",
		"Nanotrasen is not responsible for damage to property or person. ",
		"Upon discovering that damage or death has occurred, a missing person report will be filed with Central Command within 90 days, or as soon property and premises have been thoroughly cleaned and bleached, and the floor tiles have been replaced.",
		"Blah blah blah.",
		"Now that might sound bad, I know. ",
		"But, there's really nothing to worry about.",
		"Uh, the retrofitted cyborgs here, do get a bit quirky at night, but do I blame them? ",
		"No. If I were forced to run those same subroutines for twenty years and I never got a vacation?",
		"I'd probably be a bit irritable at night too.",
		"So, remember, these cyborg models hold a special place in the hearts of Nanotrasen's board members and we need to show them a little respect, right?",
		"Okay.",
		"So, just be aware, the cyborgs do tend to wander a bit.",
		"Uh, they're left in some kind of free roaming mode at night, uh, something about their MMIs getting corrupted if they get turned off for too long?",
		"Uh, they used to be allowed to walk around during the day too, but then there was the Law 1 Incident. ",
		"Yeah. ",
		"I-It's amazing that the human body can live after twenty harmbatons to the skull, you know?",
		"Uh, now concerning your safety. ",
		"The only real risk to you as a night watchman here, if any, is the fact that these cyborgs, uh, if they happen to see you after hours probably won't recognize you as an employee.",
		"They'll pr-They'll most likely see you as a potential Syndicate operative.",
		"Now, since Nanotrasen and the Syndicate are officially at war, they'll probably try to, uh, robust you. ",
		"Heh.",
		"Yeah, they don't tell you these things when you sign up.",
		"But hey, first night should be a breeze.",
		"I'll chat with you tomorrow.",
		"Uh, check those cameras, and remember to close the doors only if absolutely necessary.",
		"Gotta conserve power.",
		"Alright, good night.",
	)
/datum/lazy_template/virtual_domain/pizza_guarding_base/misdemeanor
	name = "After-Hours Pizzeria Guarding: Misdemeanor"
	desc = "Welcome to your second night as a night guard at the Nanotrasen Pizza Express!"
	reward_points = BITRUNNER_REWARD_LOW
	key = "fredingtonfastingbear_misdemeanor"
	difficulty = BITRUNNER_DIFFICULTY_LOW
	test_only = FALSE
	starting_ai_levels = list(
			/obj/bitrunning/animatronic/standard = 0,
			/obj/bitrunning/animatronic/janitor = 3,
			/obj/bitrunning/animatronic/engineering = 1,
			/obj/bitrunning/animatronic/security = 1,
	)
	phone_message = list(
		"Uhh, Hello? Hello?",
		"Uh, well, if you're hearing this and you made it to night two, uh, congrats!",
		"I-I won't talk quite as long this time, since the cyborgs tend to become more active as the week progresses.",
		"Uh, it might be a good idea to peek at those cameras while I talk, just to make sure everyone's in their proper place.",
		"You know.",
		"Uh, interestingly enough, the Standard module doesn't come off stage very often.",
		"I heard it becomes a lot more active in the dark though, so, hey, I guess that's one more reason not to run out of power, right?",
		"I-I also want to emphasize the importance of using your door lights.",
		"Uh, there are blind spots in your camera views, and those blind spots happen to be right outside your doors.",
		"So if you can't find something, or someone, on your cameras, be sure to check the door lights.",
		"Uh, you might only have a few seconds to react.",
		"Uh, not that you would be in any danger, of course.",
		"I'm not implying that.",
		"Also, check on the curtain in Security Cove from time to time.",
		"The cyborg in there seems unique in that, it becomes more active if the cameras remain off for long periods of time.",
		"I guess it doesn't like being watched. I don't know.",
		"Uh, anyway, I'm sure you have everything under control!",
		"Uh, talk to you soon!",
	)

/datum/lazy_template/virtual_domain/pizza_guarding_base/felony
	name = "After-Hours Pizzeria Guarding: Felony"
	desc = "Welcome to your third night as a night guard at the Nanotrasen Pizza Express!"
	test_only = FALSE
	key = "fredingtonfastingbear_felony"
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	reward_points = BITRUNNER_REWARD_MEDIUM
	starting_ai_levels = list(
			/obj/bitrunning/animatronic/standard = 1,
			/obj/bitrunning/animatronic/janitor = 0,
			/obj/bitrunning/animatronic/engineering = 5,
			/obj/bitrunning/animatronic/security = 2,
	)
	phone_message = list(
		"Hello, hello?",
		"Hey you're doing great!",
		"Most people don't last this long!",
		"I mean, you know, they usually move on to other things by now.",
		"I'm not implying that they died.",
		"Th-th-that's not what I meant.",
		"Uh, anyway, I better not take up too much of your time.",
		"Things start getting real tonight.",
		"Uh, Hey, listen.",
		"I had an idea.",
		"If you happen to get caught and want to avoid getting robusted, uh, try playing dead!",
		"You know, go limp. Then there's a chance that, uh, maybe they'll think that you're already robusted.",
		"Then again if they think you're dead, they might try to, take you to a medical cyborg.",
		"I wonder how that would work.",
		"Y-Yeah, never mind, scratch that.",
		"I-It's best just, not to get caught.",
		"Uh, ok, I'll leave you to it.",
		"See you on the flip side!",
	)

/datum/lazy_template/virtual_domain/pizza_guarding_base/grand_felony
	name = "After-Hours Pizzeria Guarding: Grand Felony"
	desc = "Welcome to your fourth night as a night guard at the Nanotrasen Pizza Express!"
	test_only = FALSE
	key = "fredingtonfastingbear_grand_felony"
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	reward_points = BITRUNNER_REWARD_HIGH
	starting_ai_levels = list(
			/obj/bitrunning/animatronic/standard = 3,
			/obj/bitrunning/animatronic/janitor = 5,
			/obj/bitrunning/animatronic/engineering = 7,
			/obj/bitrunning/animatronic/security = 5,
	)
	phone_message = list(
		"Hello hello?",
		"Hey!",
		"Hey, wow, night four.",
		"I knew you could do it.",
		"Uh, hey, listen, I may not be around to send you a message tomorrow.",
		"It's-It's been a bad night here for me.",
		"Um, I-I'm kinda glad that I recorded my messages for you, uh, when I did.",
		"Uh, hey, do me a favour.",
		"Maybe sometime, uh, you could check inside the arcade machines in the back?",
		"The janitor cyborg, it's always interested in them.",
		"Maybe it's important.",
		"Uh, I-I-I-I always wondered how many credits are in those machines, back there.",
		"You know-",
		"Oh, no-*BZZT*",
	)

/datum/lazy_template/virtual_domain/pizza_guarding_base/capital
	name = "After-Hours Pizzeria Guarding: Capital"
	desc = "Welcome to your fifth and final night as a night guard at the Nanotrasen Pizza Express!"
	test_only = FALSE
	key = "fredingtonfastingbear_capital"
	difficulty = BITRUNNER_DIFFICULTY_OVERKILL
	reward_points = BITRUNNER_REWARD_EXTREME
	starting_ai_levels = list( // GOOD LUCK
			/obj/bitrunning/animatronic/standard = 20,
			/obj/bitrunning/animatronic/janitor = 20,
			/obj/bitrunning/animatronic/engineering = 20,
			/obj/bitrunning/animatronic/security = 20,
	)
	phone_message = list(
		"Thank you for calling Nanotrasen Pizza Express.",
		"We are currently closed.",
		"Please call back within normal business hours.",
		"Leave a message at the beep.",
		"*BEEP*",
	)

/datum/lazy_template/virtual_domain/pizza_guarding_base/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner
	var/obj/bitrunning/animatronic_controller/our_controller = locate(/obj/bitrunning/animatronic_controller) in created_atoms
	if(!our_controller)
		CRASH("No Animatronic Controller!!!")
	our_controller.starting_ai_levels = src.starting_ai_levels
	for(var/obj/bitrunning/animatronic/robot in created_atoms)
		var/obj/bitrunning/animatronic_movement_node/starter_node = locate(/obj/bitrunning/animatronic_movement_node) in get_turf(robot)
		if(!starter_node)
			CRASH("[robot] MISSING STARTER NODE ON ITS TURF")
		robot.current_node = starter_node
		robot.starting_node = starter_node
		our_controller.animatronics += robot
	var/obj/machinery/computer/security/bitrunner/camera_console = locate(/obj/machinery/computer/security/bitrunner) in created_atoms
	var/obj/bitrunning/animatronic_phone/our_phone = locate(/obj/bitrunning/animatronic_phone) in created_atoms
	var/obj/machinery/door/poddoor/left_door = locate(/obj/machinery/door/poddoor/bitrunner_left) in created_atoms
	var/obj/machinery/door/poddoor/right_door = locate(/obj/machinery/door/poddoor/bitrunner_right) in created_atoms
	var/obj/machinery/light/small/dim/left_light = locate(/obj/machinery/light/small/dim/bitrunner_left) in created_atoms
	var/obj/machinery/light/small/dim/right_light = locate(/obj/machinery/light/small/dim/bitrunner_right) in created_atoms
	if(!camera_console || !our_phone || !left_door || !right_door || !left_light || !right_light)
		CRASH("Missing critical items for the domain!")
	our_controller.camera_console = camera_console
	camera_console.network = list("[REF(our_controller)]")
	our_controller.our_phone = our_phone
	our_phone.lines = phone_message
	our_phone.our_controller = our_controller
	our_controller.left_door = left_door
	our_controller.right_door = right_door
	our_controller.left_light = left_light
	our_controller.right_light = right_light

	for(var/obj/machinery/camera/active_camera in created_atoms)
		active_camera.network = list("[REF(our_controller)]")

	for(var/obj/bitrunning/animatronic_movement_node/node in created_atoms)
		our_controller.pathfinding_nodes[node.node_id] = node

	for(var/obj/bitrunning/door_button/button in created_atoms)
		button.our_controller = our_controller

	for(var/obj/bitrunning/light_button/button in created_atoms)
		button.our_controller = our_controller
