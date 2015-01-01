var/global/list/updateQueueTestCount = list()

/datum/updateQueueTests
	var/start
	proc
		runTests()
			world << "<b>Running 9 tests...</b>"
			testUpdateQueuePerformance()
			sleep(1)
			testInplace()
			sleep(1)
			testInplaceUpdateQueuePerformance()
			sleep(1)
			testUpdateQueueReinit()
			sleep(1)
			testCrashingQueue()
			sleep(1)
			testEmptyQueue()
			sleep(1)
			testManySlowItemsInQueue()
			sleep(1)
			testVariableWorkerTimeout()
			sleep(1)
			testReallySlowItemInQueue()
			sleep(1)
			world << "<b>Finished!</b>"
		
		beginTiming()
			start = world.time
			
		endTiming(text)
			var/time = (world.time - start) / world.tick_lag
			world << {"<b><font color="blue">Performance - [text] - <font color="green">[time]</font> ticks</font></b>"}
		
		getCount()
			return updateQueueTestCount[updateQueueTestCount.len]
		
		incrementTestCount()
			updateQueueTestCount.len++
			updateQueueTestCount[updateQueueTestCount.len] = 0
		
		assertCountEquals(count, text)
			assertThat(getCount() == count, text)
		
		assertCountLessThan(count, text)
			assertThat(getCount() < count, text)
		
		assertCountGreaterThan(count, text)
			assertThat(getCount() > count, text)
		
		assertThat(condition, text)
			if (condition)
				world << {"<font color="green"><b>PASS</b></font>: [text]"}
			else
				world << {"<b><font color="red">FAIL</font>: [text]</b>"}
			
		testUpdateQueuePerformance()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=100000,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			
			var/datum/updateQueue/uq = new(objs)
			
			beginTiming()
			uq.Run()
			endTiming("updating 100000 simple objects")
			
			assertCountEquals(100000, "test that update queue updates all objects expected")
			del(objs)
			del(uq)

		testUpdateQueueReinit()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=100,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))

			var/datum/updateQueue/uq = new(objs)
			uq.Run()
			objs = new

			for(var/i=1,i<=100,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			uq.init(objs)
			uq.Run()
			assertCountEquals(200, "test that update queue reinitializes properly and updates all objects as expected.")
			del(objs)
			del(uq)

		testInplace()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=100,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			var/datum/updateQueue/uq = new(objects = objs, inplace = 1)
			uq.Run()
			assertThat(objs.len == 0, "test that update queue inplace option really works inplace")
			assertCountEquals(100, "test that inplace update queue updates the right number of objects")
			del(objs)
			del(uq)
					
		testInplaceUpdateQueuePerformance()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=100000,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			
			var/datum/updateQueue/uq = new(objs)
			
			beginTiming()
			uq.Run()
			endTiming("updating 100000 simple objects in place")
			del(objs)
			del(uq)

		testCrashingQueue()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=10,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			objs.Add(new /datum/uqTestDatum/crasher(updateQueueTestCount.len))
			for(var/i=1,i<=10,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			
			var/datum/updateQueue/uq = new(objs)
			uq.Run()
			assertCountEquals(20, "test that update queue handles crashed update procs OK")
			del(objs)
			del(uq)

		testEmptyQueue()
			incrementTestCount()
			var/list/objs = new
			var/datum/updateQueue/uq = new(objs)
			uq.Run()
			assertCountEquals(0, "test that update queue doesn't barf on empty lists")
			del(objs)
			del(uq)

		testManySlowItemsInQueue()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=30,i++)
				objs.Add(new /datum/uqTestDatum/slow(updateQueueTestCount.len))
			var/datum/updateQueue/uq = new(objs)
			uq.Run()
			assertCountEquals(30, "test that update queue slows down execution if too many objects are slow to update")
			del(objs)
			del(uq)
			
		testVariableWorkerTimeout()			
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=20,i++)
				objs.Add(new /datum/uqTestDatum/slow(updateQueueTestCount.len))
			var/datum/updateQueue/uq = new(objs, workerTimeout=6)
			uq.Run()
			assertCountEquals(20, "test that variable worker timeout works properly")			
			del(objs)
			del(uq)

		testReallySlowItemInQueue()
			incrementTestCount()
			var/list/objs = new
			for(var/i=1,i<=10,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			objs.Add(new /datum/uqTestDatum/reallySlow(updateQueueTestCount.len))
			for(var/i=1,i<=10,i++)
				objs.Add(new /datum/uqTestDatum/fast(updateQueueTestCount.len))
			var/datum/updateQueue/uq = new(objs)
			uq.Run()
			assertCountEquals(20, "test that update queue skips objects that are too slow to update")
			del(objs)
			del(uq)



datum/uqTestDatum
	var/testNum
	New(testNum)
		..()
		src.testNum = testNum
	proc/update()
		updateQueueTestCount[testNum]++
	proc/lag(cycles)
		set background = 1
		for(var/i=0,i<cycles,)
			i++
datum/uqTestDatum/fast

datum/uqTestDatum/slow
	update()
		set background = 1
		var/start = world.timeofday
		while(world.timeofday - start < 5) // lag 4 deciseconds
		..()
		
datum/uqTestDatum/reallySlow
	update()
		set background = 1
		var/start = world.timeofday
		while(world.timeofday - start < 300) // lag 30 seconds
		..()

datum/uqTestDatum/crasher
	update()
		CRASH("I crashed! (I am supposed to crash XD)")
		..() // This should do nothing lol