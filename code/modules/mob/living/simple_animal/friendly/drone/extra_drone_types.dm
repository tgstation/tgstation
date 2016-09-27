////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overriden procs
//Drones with camogear for hat related memes
//Drone type for use with polymorph (no preloaded items, random appearance)

/mob/living/simple_animal/drone/polymorphed
	default_storage = null
	default_hatmask = null
	picked = TRUE

/mob/living/simple_animal/drone/polymorphed/New()
	. = ..()
	liberate()
	visualAppearence = pick(MAINTDRONE, REPAIRDRONE, SCOUTDRONE)
	if(visualAppearence == MAINTDRONE)
		var/colour = pick("grey", "blue", "red", "green", "pink", "orange")
		icon_state = "[visualAppearence]_[colour]"
	else
		icon_state = visualAppearence

	icon_living = icon_state
	icon_dead = "[visualAppearence]_dead"

/mob/living/simple_animal/drone/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	picked = TRUE
	languages_spoken = RATVAR
	languages_understood = HUMAN|RATVAR
	pass_flags = PASSTABLE
	health = 50
	maxHealth = 50
	density = TRUE
	speed = 1
	ventcrawler = 0
	faction = list("ratvar")
	speak_emote = list("clinks", "clunks")
	bubble_icon = "clock"
	heavy_emp_damage = 10
	laws = "0. Purge all untruths and honor Ratvar."
	default_storage = /obj/item/weapon/storage/toolbox/brass/prefilled
	seeStatic = 0
	hacked = TRUE
	visualAppearence = CLOCKDRONE

/mob/living/simple_animal/drone/cogscarab/ratvar //a subtype for spawning when ratvar is alive, has a slab that it can use and a normal proselytizer
	default_storage = /obj/item/weapon/storage/toolbox/brass/prefilled/ratvar

/mob/living/simple_animal/drone/cogscarab/New()
	. = ..()
	SetLuminosity(2,1)
	qdel(access_card) //we don't have free access
	access_card = null
	verbs -= /mob/living/simple_animal/drone/verb/check_laws
	verbs -= /mob/living/simple_animal/drone/verb/toggle_light
	verbs -= /mob/living/simple_animal/drone/verb/drone_ping

/mob/living/simple_animal/drone/cogscarab/Login()
	..()
	add_servant_of_ratvar(src, TRUE)
	src << "<span class='heavy_brass'>You are a cogscarab</span><b>, a clockwork creation of Ratvar. As a cogscarab, you have low health, an inbuilt proselytizer that can convert rods, \
	metal, and plasteel to alloy, a set of relatively fast tools, can communicate over the Hierophant Network with </b><span class='heavy_brass'>:b</span><b>, and are immune to extreme \
	temperatures and pressures. \nYour goal is to serve the Justiciar and his servants by repairing and defending all they create. \
	\nYou yourself are one of these servants, and will be able to utilize almost anything they can, excluding a clockwork slab.</b>"

/mob/living/simple_animal/drone/cogscarab/binarycheck()
	return FALSE

/mob/living/simple_animal/drone/cogscarab/update_drone_hack()
	return //we don't get hacked or give a shit about it

/mob/living/simple_animal/drone/cogscarab/drone_chat(msg)
	titled_hierophant_message(src, msg, "heavy_alloy") //HIEROPHANT DRONES
