/** 
 * testUpdateQueueProcess
 * This process is an example of a process using an updateQueue.
 * The datums updated by this process behave nicely and do not block.
 */

/datum/fastTestDatum/proc/wackyUpdateProcessName()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/fastTestDatum/proc/wackyUpdateProcessName() called tick#: [world.time]")
	sleep(prob(10)) // Pretty quick, usually instant
	
/datum/controller/process/testUpdateQueueProcess
	var/tmp/datum/updateQueue/updateQueueInstance
	var/tmp/list/testDatums = list()
	
/datum/controller/process/testUpdateQueueProcess/setup()
	name = "UpdateQueue Process"
	schedule_interval = 20 // every 2 seconds
	updateQueueInstance = new
	for(var/i = 1, i < 30, i++)
		testDatums.Add(new /datum/fastTestDatum)
	
/datum/controller/process/testUpdateQueueProcess/doWork()
	updateQueueInstance.init(testDatums, "wackyUpdateProcessName")
	updateQueueInstance.Run()
	