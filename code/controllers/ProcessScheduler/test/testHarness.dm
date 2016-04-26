/*
	These are simple defaults for your project.
 */
#define DEBUG

var/global/datum/processSchedulerView/processSchedulerView

world
	loop_checks = 0
	New()
		..()
		processScheduler = new
		processSchedulerView = new

mob
	step_size = 8

	New()
		..()


	verb
		startProcessScheduler()
			set name = "Start Process Scheduler"
			processScheduler.setup()
			processScheduler.start()

		getProcessSchedulerContext()
			set name = "Get Process Scheduler Status Panel"
			processSchedulerView.getContext()

		runUpdateQueueTests()
			set name = "Run Update Queue Testsuite"
			var/datum/updateQueueTests/t = new
			t.runTests()