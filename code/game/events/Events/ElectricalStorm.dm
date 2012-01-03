/datum/event/electricalstorm
	var
		list/datum/radio_frequency/DisruptedFrequencies = list( )
		list/obj/machinery/light/Lights = list( )
		list/obj/machinery/light/APCs = list( )
		list/obj/machinery/light/Doors = list( )

	Announce()
		Lifetime = rand(90, 300)
		command_alert("The ship is flying through an electrical storm.  Radio communications may be disrupted", "Anomaly Alert")

		for (var/datum/radio_frequency/Freq in radio_controller.frequencies)
			if(prob(35))
				radio_controller.RegisterScrambler(Freq)
				DisruptedFrequencies += Freq

		for (var/Freq = 1201, Freq <= 1599, Freq += 2)
			if(prob(35))
				ScrambledFrequencies += list ("[Freq]" = Freq)
			else
				UnscrambledFrequencies += list ("[Freq]" = Freq)

		for (var/Freq in DEPT_FREQS)
			if(prob(75))
				ScrambledFrequencies |= list ("[Freq]" = Freq)
				if(UnscrambledFrequencies["[Freq]"])
					UnscrambledFrequencies -= list ("[Freq]" = Freq)

		if(prob(80))
			ScrambledFrequencies |= list ("1459" = 1459)
			if(UnscrambledFrequencies["1459"])
				UnscrambledFrequencies -= list ("1459" = 1459)

		for(var/obj/machinery/light/Light in world)
			if(Light.z == 1)
				Lights += Light

		for(var/obj/machinery/power/apc/APC in world)
			if(APC.z == 1 && !APC.crit)
				APCs += APC

		for(var/obj/machinery/door/airlock/Door in world)
			if(Door.z == 1)
				Doors += Door

		sleep(rand(70,180))

		var/picked = 0
		var/list/SafeTemp = list()
		var/SafeFreq = 0
		if(UnscrambledFrequencies["1459"])
			SafeFreq = 1459
			picked = 1
		else
			while(picked == 0)
				SafeTemp = pick(UnscrambledFrequencies)
				SafeFreq = UnscrambledFrequencies[SafeTemp]
				if(SafeFreq < 1489 && SafeFreq > 1441)
					picked = 1

		command_alert("The radio frequency [SafeFreq/10] has been identified as stable despite the interference.", "Station Central Computer System")

	Tick()
		for(var/x = 0; x < 3; x++)
			if (prob(30))
				BlowLight()
		if (prob(10))
			DisruptAPC()
		if (prob(10))
			DisableDoor()


	Die()
		command_alert("The ship has cleared the electrical storm.  Radio communications restored", "Anomaly Alert")
		for (var/datum/radio_frequency/Freq in ScrambledFrequencies)
			radio_controller.UnregisterScrambler(Freq)
		DisruptedFrequencies = list( )
		UnscrambledFrequencies = list( )
		ScrambledFrequencies = list( )

	proc
		BlowLight() //Blow out a light fixture
			var/obj/machinery/light/Light = null
			var/insanity = 0
			while (Light == null || Light.status != 0)
				Light = pick(Lights)
				insanity++
				if (insanity >= Lights.len)
					return

			spawn(0) //Overload the light, spectacularly.
				//Light.ul_SetLuminosity(10)
				//sleep(2)
				Light.on = 1
				Light.broken()

		DisruptAPC()
			var/insanity = 0
			var/obj/machinery/power/apc/APC
			while (!APC || !APC.operating)
				APC = pick(APCs)
				insanity++
				if (insanity >= APCs.len)
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
