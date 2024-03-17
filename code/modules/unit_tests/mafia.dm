///Checks if a Mafia game with a Modular Computer and a Ghost will run with 'basic_setup', which is the default
///way the game is ran, without admin-intervention.
///The game should immediately end in a Town Victory due to lack of evils, but we can verify that both the PDA and the ghost
///successfully managed to get into the round.
/datum/unit_test/mafia
	///Boolean on whether the Mafia game started or not. Will Fail if it hasn't.
	var/mafia_game_started = FALSE

/datum/unit_test/mafia/Run()
	RegisterSignal(SSdcs, COMSIG_MAFIA_GAME_START, PROC_REF(on_mafia_start))
	var/datum/mafia_controller/controller = GLOB.mafia_game || new()

	TEST_ASSERT(controller, "No Mafia game was found, nor was it able to be created properly.")

	//spawn human and give them a laptop.
	var/mob/living/carbon/human/consistent/living_player = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/modular_computer/laptop/preset/mafia/modpc_player = allocate(/obj/item/modular_computer/laptop/preset/mafia)
	living_player.put_in_active_hand(modpc_player, TRUE)

	//make the laptop run Mafia app.
	var/datum/computer_file/program/mafia/mafia_program = locate() in modpc_player.stored_files
	TEST_ASSERT(mafia_program, "Mafia program was unable to be found on [modpc_player].")
	modpc_player.active_program = mafia_program

	//Spawn a ghost and make them eligible to use the Mafia UI (just to be safe).
	var/mob/dead/observer/ghost_player = allocate(/mob/dead/observer)
	var/datum/client_interface/mock_client = new()
	ghost_player.mock_client = mock_client
	mock_client.mob = ghost_player
	ADD_TRAIT(ghost_player, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)

	//First make the human sign up for Mafia, then the ghost, then we'll auto-start it.
	controller.signup_mafia(living_player, modpc = modpc_player)
	controller.signup_mafia(ghost_player, ghost_client = mock_client)

	controller.basic_setup()

	TEST_ASSERT(mafia_game_started, "Mafia game did not start despite basic_setup being called.")
	TEST_ASSERT_NOTNULL(controller.player_role_lookup[modpc_player], "The Modular Computer was unable to join a game of Mafia.")
	TEST_ASSERT_NOTNULL(controller.player_role_lookup[mock_client.ckey], "The Mock client wasn't put into a game of Mafia.")

	mock_client.mob = null

	qdel(controller)

/datum/unit_test/mafia/proc/on_mafia_start(datum/controller/subsystem/processing/dcs/source, datum/mafia_controller/game)
	SIGNAL_HANDLER
	mafia_game_started = TRUE
