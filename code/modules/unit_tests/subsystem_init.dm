/// Tests that all subsystems that need to properly initialize.
/datum/unit_test/subsystem_init

/datum/unit_test/subsystem_init/Run()
	for(var/datum/controller/subsystem/subsystem as anything in Master.subsystems)
		if(subsystem.flags & SS_NO_INIT)
			continue
		if(subsystem.initialized)
			continue

		var/should_fail = !(subsystem.flags & SS_OK_TO_FAIL_INIT)
		var/list/message_strings = list("[subsystem] ([subsystem.type]) is a subsystem meant to initialize but could not get initialized.")

		if(!isnull(subsystem.initialization_failure_message))
			message_strings += "The subsystem reported the following: [subsystem.initialization_failure_message]"

		if(should_fail)
			TEST_FAIL(jointext(message_strings, "\n"))
			continue

		message_strings += "This subsystem is marked as SS_OK_TO_FAIL_INIT. This is still a bug, but it is non-blocking."
		TEST_NOTICE(src, jointext(message_strings, "\n"))

