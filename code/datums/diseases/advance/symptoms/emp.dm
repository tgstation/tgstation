/datum/symptom/emp
	name = "Electromagnetic Pulse"
	desc = "The virus occasionally emits an electromagnetic pulse, disabling electronics in the host's inventory and on their tile."
	stealth = 0
	resistance = 1
	stage_speed = 1
	transmittable = 1 //eh, screw it, these stats will do
	level = 8
	severity = 3
	base_message_chance = 100
	symptom_delay_min = 30 //1 minute
	symptom_delay_max = 90 //3 minutes
	var/light_radius = 0
	var/heavy_radius = -1
	threshold_desc = "<b>Resistance 8:</b> The center of the EMP will sometimes have an even stronger effect on affected electronics.<br>\
					  <b>Transmission 6:</b> The EMP will affect electronics in tiles within 1 tile of the host's tile as well.<br>\
					  <b>Transmission 12:</b> The EMP will affect electronics in tiles within 2 tiles of the host's tile as well.<br>\
					  <b>Stage Speed 6:</b> The virus emits EMPs twice as often."

/datum/symptom/emp/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 8)
		heavy_radius = 0 //50% chance of delivering a heavy EMP effect instead of a light one to the host's tile
	if(A.properties["transmittable"] >= 6)
		light_radius = 1
	if(A.properties["transmittable"] >= 12)
		light_radius = 2
		if(A.properties["resistance"] >= 8) //increases the radius of the heavy EMP effect as well, but only if the threshold to get the heavy EMP effect has been met
			heavy_radius = 1 //100% chance of delivering a heavy EMP effect instead of a light one to the host's tile and a 50% chance (calculated separately for each tile) of delivering a heavy EMP effect instead of a light one to the tiles adjacent to the host's tile, because the empulse proc is coded weirdly
	if(A.properties["stage_rate"] >= 6)
		symptom_delay_min = 15 //30 seconds
		symptom_delay_max = 45 //90 seconds
   

/datum/symptom/emp/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("Your hairs stand on end.", "Your skin hums with power for a moment.")]</span>")
		else
			empulse(M, light_radius, heavy_radius)
