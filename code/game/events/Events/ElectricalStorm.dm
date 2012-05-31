//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/electricalstorm
	var/list/obj/machinery/light/Lights = list( )
	var/list/obj/machinery/light/APCs = list( )
	var/list/obj/machinery/light/Doors = list( )
	var/list/obj/machinery/light/Comms = list( )

	Announce()
//		command_alert("The station is flying through an electrical storm.  Radio communications may be disrupted", "Anomaly Alert")

		for(var/obj/machinery/light/Light in world)
			if(Light.z == 1 && Light.status != 0)
				Lights += Light

		for(var/obj/machinery/power/apc/APC in world)
			if(APC.z == 1 && !APC.crit)
				APCs += APC

		for(var/obj/machinery/door/airlock/Door in world)
			if(Door.z == 1 && !istype(Door,/obj/machinery/door/airlock/secure))
				Doors += Door

		for(var/obj/machinery/telecomms/processor/T in world)
			if(prob(90) && !(T.stat & (BROKEN|NOPOWER)))
				T.stat |= BROKEN
				Comms |= T

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
		for(var/obj/machinery/telecomms/processor/T in Comms)
			T.stat &= ~BROKEN
		Comms = list()

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
				Lights -= Light

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
			APCs -= APC

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
			Doors -= Airlock
