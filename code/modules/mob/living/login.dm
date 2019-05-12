/mob/living/Login()
	if(!loc)
		message_admins("DEBUG: A mob has been logged in to while in null space. mob name: \"[name]\" mob type: \"[type]\". The key logging in was [client.ckey]. This is a bug, Report this to Falaskian.")
		log_game("DEBUG: A mob has been logged in to while in null space. mob name: \"[name]\" mob type: \"[type]\". The key logging in was [client.ckey]. This is a bug, Report this to Falaskian.")
	..()
	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)

	//Round specific stuff
	if(SSticker.mode)
		switch(SSticker.mode.name)
			if("sandbox")
				CanBuild()

	update_damage_hud()
	update_health_hud()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, "<span class='notice'>You currently have <b>[ranged_ability]</b> active!</span>")