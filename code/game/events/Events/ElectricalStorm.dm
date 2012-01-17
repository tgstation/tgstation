/datum/event/electricalstorm
	var
		list/obj/machinery/light/Lights = list( )
		list/obj/machinery/light/APCs = list( )
		list/obj/machinery/light/Doors = list( )

	Announce()
		Lifetime = rand(90, 300)
		command_alert("The station is flying through an electrical storm.  Radio communications may be disrupted", "Anomaly Alert")

		for(var/obj/machinery/light/Light in world)
			if(Light.z == 1)
				Lights += Light

		for(var/obj/machinery/power/apc/APC in world)
			if(APC.z == 1 && !APC.crit)
				APCs += APC

		for(var/obj/machinery/door/airlock/Door in world)
			if(Door.z == 1)
				Doors += Door

	Tick()
		for(var/x = 0; x < 3; x++)
			if (prob(30))
				BlowLight()
		if (prob(10))
			DisruptAPC()
		if (prob(10))
			DisableDoor()


	Die()
		command_alert("The station has cleared the electrical storm.  Radio communications restored", "Anomaly Alert")

	proc
		BlowLight() //Blow out a light fixture
			var/obj/machinery/light/Light = null
			var/failed_attempts = 0
			while (Light == null || Light.status != 0)
				Light = pick(Lights)
				failed_attempts++
				if (failed_attempts >= 10)
					return

			spawn(0) //Overload the light, spectacularly.
				//Light.ul_SetLuminosity(10)
				//sleep(2)
				Light.on = 1
				Light.broken()

		DisruptAPC()
			var/failed_attempts = 0
			var/obj/machinery/power/apc/APC
			while (!APC || !APC.operating)
				APC = pick(APCs)
				failed_attempts++
				if (failed_attempts >= 10)
					return

			if (prob(40))
				APC.operating = 0 //Blow its breaker
			if (prob(8))
				APC.set_broken()

		DisableDoor()
			var/obj/machinery/door/airlock/Airlock
			while (!Airlock || Airlock.z != 1)
				Airlock = pick(Doors)
			Airlock.pulse(airlockIndexToWireColor[4])
			for (var/x = 0; x < 2; x++)
				var/Wire = 0
				while(!Wire || Wire == 4)
					Wire = rand(1, 9)
				Airlock.pulse(airlockIndexToWireColor[Wire])
			Airlock.update_icon()
