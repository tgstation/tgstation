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

//Free Golems

/obj/item/weapon/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/weapon/disk/design_disk/golem_shell/New()
	..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	req_tech = list("materials" = 12)
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/species
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/O = I

		if(istype(O, /obj/item/stack/sheet/metal))
			species = /datum/species/golem

		if(istype(O, /obj/item/stack/sheet/mineral/plasma))
			species = /datum/species/golem/plasma

		if(istype(O, /obj/item/stack/sheet/mineral/diamond))
			species = /datum/species/golem/diamond

		if(istype(O, /obj/item/stack/sheet/mineral/gold))
			species = /datum/species/golem/gold

		if(istype(O, /obj/item/stack/sheet/mineral/silver))
			species = /datum/species/golem/silver

		if(istype(O, /obj/item/stack/sheet/mineral/uranium))
			species = /datum/species/golem/uranium

		if(species)
			if(O.use(10))
				user << "You finish up the golem shell with ten sheets of [O]."
				var/obj/effect/mob_spawn/human/golem/G = new(get_turf(src))
				G.mob_species = species
				qdel(src)
			else
				user << "You need at least ten sheets to finish a golem."
		else
			user << "You can't build a golem out of this kind of material."
