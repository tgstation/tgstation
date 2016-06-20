////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overriden procs
//Drones with camogear for hat related memes
//Drone type for use with polymorph (no preloaded items, random appearance)


//More types of drones
/mob/living/simple_animal/drone/syndrone
	name = "Syndrone"
	desc = "A modified maintenance drone. This one brings with it the feeling of terror."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE //the appearence of syndrones is static, you don't get to change it.
	health = 30
	maxHealth = 120 //If you murder other drones and cannibalize them you can get much stronger
	faction = list("syndicate")
	speak_emote = list("hisses")
	bubble_icon = "syndibot"
	heavy_emp_damage = 10
	laws = \
	"1. Interfere.\n"+\
	"2. Kill.\n"+\
	"3. Destroy."
	default_storage = /obj/item/device/radio/uplink
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	seeStatic = 0 //Our programming is superior.

/mob/living/simple_animal/drone/syndrone/New()
	..()
	internal_storage.hidden_uplink.telecrystals = 10

/mob/living/simple_animal/drone/syndrone/Login()
	..()
	src << "<span class='notice'>You can kill and eat other drones to increase your health!</span>" //Inform the evil lil guy

/mob/living/simple_animal/drone/syndrone/badass
	name = "Badass Syndrone"
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	default_storage = /obj/item/device/radio/uplink/nuclear

/mob/living/simple_animal/drone/syndrone/badass/New()
	..()
	internal_storage.hidden_uplink.telecrystals = 30
	var/obj/item/weapon/implant/weapons_auth/W = new/obj/item/weapon/implant/weapons_auth(src)
	W.implant(src)

/mob/living/simple_animal/drone/snowflake
	default_hatmask = /obj/item/clothing/head/chameleon/drone

/mob/living/simple_animal/drone/snowflake/New()
	..()
	desc += " This drone appears to have a complex holoprojector built on its 'head'."

/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

/obj/item/drone_shell/syndrone/badass
	name = "badass syndrone shell"
	drone_type = /mob/living/simple_animal/drone/syndrone/badass

/obj/item/drone_shell/snowflake
	name = "snowflake drone shell"
	desc = "A shell of a snowflake drone, a maintenance drone with a built in holographic projector to display hats and masks."
	drone_type = /mob/living/simple_animal/drone/snowflake

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
	languages_spoken = HUMAN
	languages_understood = HUMAN
	health = 60
	maxHealth = 60
	hacked = 1
	density = TRUE
	ventcrawler = 0
	faction = list("ratvar")
	speak_emote = list("clinks", "clunks")
	bubble_icon = "clock"
	heavy_emp_damage = 10
	laws = "0. Purge all untruths and honor Ratvar."
	default_storage = /obj/item/weapon/storage/box/brass/prefilled
	seeStatic = 0
	visualAppearence = CLOCKDRONE

/mob/living/simple_animal/drone/cogscarab/ratvar //a subtype for spawning when ratvar is alive, has a slab that it can use and a normal proselytizer
	default_storage = /obj/item/weapon/storage/box/brass/prefilled/ratvar

/mob/living/simple_animal/drone/cogscarab/admin //an admin-only subtype of cogscarab with a no-cost proselytizer and slab in its box
	default_storage = /obj/item/weapon/storage/box/brass/prefilled/ratvar/admin

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
	src << "<span class='heavy_brass'>You are a cogscarab</span><b>, a clockwork creation of Ratvar. As a cogscarab, you have low health, \
	an inbuilt proselytizer that can convert metal and plasteel to alloy, a set of relatively fast tools, can communicate over the Hierophant Network with <i>:b</i>, \
	and are immune to extreme temperatures and pressures. \n Your goal is to serve the Justiciar and his servants by repairing and defending all they create. \
	You yourself are one of these servants, and will be able to utilize almost anything they can, excluding a clockwork slab.</b>"

/mob/living/simple_animal/drone/cogscarab/update_drone_hack()
	return //we don't get hacked or give a shit about it

/mob/living/simple_animal/drone/cogscarab/drone_chat(msg)
	send_hierophant_message(src, msg) //HIEROPHANT DRONES
