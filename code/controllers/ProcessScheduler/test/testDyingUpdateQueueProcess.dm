/** 
 * testDyingUpdateQueueProcess
 * This process is an example of a process using an updateQueue.
 * The datums updated by this process behave badly and block the update loop
 * by sleeping. If you #define UPDATE_QUEUE_DEBUG, you will see the updateQueue
 * killing off its worker processes and spawning new ones to work around slow 
 * updates. This means that if you have a code path that sleeps for a long time
 * in mob.Life once in a blue moon, the mob update loop will not hang.
 */
/datum/slowTestDatum/proc/wackyUpdateProcessName()
	sleep(rand(0,20)) // Randomly REALLY slow :|
	
/datum/controller/process/testDyingUpdateQueueProcess
	var/tmp/datum/updateQueue/updateQueueInstance
	var/tmp/list/testDatums = list()
	
/datum/controller/process/testDyingUpdateQueueProcess/setup()
	name = "Dying UpdateQueue Process"
	schedule_interval = 30 // every 3 seconds
	updateQueueInstance = new
	for(var/i = 1, i < 30, i++)
		testDatums.Add(new /datum/slowTestDatum)
	
/datum/controller/process/testDyingUpdateQueueProcess/doWork()
	updateQueueInstance.init(testDatums, "wackyUpdateProcessName")
	updateQueueInstance.Run()
	