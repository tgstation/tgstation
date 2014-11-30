/datum/event/blob
	announceWhen	= 30
	endWhen			= 150

	var/obj/effect/blob/core/Blob
	var/list/datum/mind/infected_crew=list()


/datum/event/blob/announce()
	burst_blobs()


#define ROLE_TYPE_FACE 0
#define ROLE_TYPE_HEEL 1
/proc/get_minds_in_role(var/roletype)
	var/antagonist_list[] = list()//The main bad guys. Evil minds that plot destruction.
	var/protagonist_list[] = ticker.mode.get_living_heads()//The good guys. Mostly Heads. Who are alive.

	//var/xeno_list[] = list()//Aliens.
	//var/commando_list[] = list()//Commandos.

	var/datum/mind/current_mind

	var/possible_bad_dudes[] = list(
		ticker.mode.traitors,
		ticker.mode.head_revolutionaries,
		ticker.mode.head_revolutionaries,
	    ticker.mode.cult,
	    ticker.mode.wizards,
	    ticker.mode.changelings,
	    ticker.mode.syndicates)
	for(var/list in possible_bad_dudes)//For every possible antagonist type.
		for(current_mind in list)//For each mind in that list.
			if(current_mind.current&&current_mind.current.stat!=2 && current_mind.current.client && !current_mind.current.client.is_afk())//If they are not destroyed and not dead.
				antagonist_list += current_mind//Add them.

	if(protagonist_list.len)//If the mind is both a protagonist and antagonist.
		for(current_mind in protagonist_list)
			if(current_mind in antagonist_list)
				protagonist_list -= current_mind//We only want it in one list.

	if(roletype==ROLE_TYPE_FACE)
		return protagonist_list
	else
		return antagonist_list

/datum/event/blob/start()
	var/list/possible_blobs = get_minds_in_role(ROLE_TYPE_FACE)
	if (!possible_blobs.len)
		return
	for(var/mob/living/G in possible_blobs)
		if(G.client && !G.client.holder && !G.client.is_afk() && G.client.desires_role(ROLE_BLOB))
			var/datum/mind/blob = pick(possible_blobs)
			infected_crew += blob
			blob.special_role = "Blob"
			log_game("[blob.key] (ckey) has been selected as a Blob")
			possible_blobs -= blob
			greetblob(blob)
			return

	//Blob = new /obj/effect/blob/core(T, 200)
	//for(var/i = 1; i < rand(3, 6), i++)
	//	Blob.process()

/datum/event/blob/proc/burst_blobs()
	spawn(0)
		for(var/datum/mind/blob in infected_crew)
			blob.current.show_message("<span class='alert'>You feel tired and bloated.</span>")

		sleep(600) // 60s

		for(var/datum/mind/blob in infected_crew)
			blob.current.show_message("<span class='alert'>You feel like you are about to burst.</span>")

		sleep(300) // 30s

		for(var/datum/mind/blob in infected_crew)

			var/client/blob_client = null
			var/turf/location = null

			if(iscarbon(blob.current))
				var/mob/living/carbon/C = blob.current
				if(directory[ckey(blob.key)])
					blob_client = directory[ckey(blob.key)]
					location = get_turf(C)
					if(location.z != 1 || istype(location, /turf/space))
						location = null
					C.gib()


			if(blob_client && location)
				var/obj/effect/blob/core/core = new(location, 200, blob_client, 3)
				if(core.overmind && core.overmind.mind)
					core.overmind.mind.name = blob.name
					infected_crew -= blob
					infected_crew += core.overmind.mind

		sleep(100) // 10s
		biohazard_alert()

/datum/event/blob/proc/greetblob(user)
	user << {"<B>\red You are infected by the Blob!</B>
<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>
<b>Find a good location to spawn the core and then take control and overwhelm the station!</b>
<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>
<b>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</b>"}

/datum/event/blob/tick()
	if(!Blob && infected_crew.len == 0)
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.process()