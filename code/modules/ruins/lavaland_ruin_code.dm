//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

/obj/machinery/lavaland_controller
	name = "weather control machine"
	desc = "Controls the weather."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"
	var/datum/weather/ongoing_weather = FALSE
	var/weather_cooldown = 0

/obj/machinery/lavaland_controller/process()
	if(ongoing_weather || weather_cooldown > world.time)
		return
	weather_cooldown = world.time + rand(3500, 6500)
	var/datum/weather/ash_storm/LAVA
	if(prob(10)) //10% chance for the ash storm to miss the area entirely
		LAVA = new /datum/weather/ash_storm/false_alarm
	else
		LAVA = new /datum/weather/ash_storm
	ongoing_weather = LAVA
	LAVA.weather_start_up()
	ongoing_weather = null

/obj/machinery/lavaland_controller/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE


/obj/structure/fans/tiny/invisible //For blocking air in ruin doorways
	invisibility = INVISIBILITY_ABSTRACT

//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry = 15,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)
