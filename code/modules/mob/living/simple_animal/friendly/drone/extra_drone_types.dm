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
	initial_language_holder = /datum/language_holder/drone/syndicate
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
	hacked = TRUE
	flavortext = null

/mob/living/simple_animal/drone/syndrone/Initialize()
	..()
	internal_storage.hidden_uplink.telecrystals = 10

/mob/living/simple_animal/drone/syndrone/Login()
	..()
	to_chat(src, "<span class='notice'>You can kill and eat other drones to increase your health!</span>" )

/mob/living/simple_animal/drone/syndrone/badass
	name = "Badass Syndrone"
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	default_storage = /obj/item/device/radio/uplink/nuclear

/mob/living/simple_animal/drone/syndrone/badass/Initialize()
	..()
	internal_storage.hidden_uplink.telecrystals = 30
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(src)
	W.implant(src)

/mob/living/simple_animal/drone/snowflake
	default_hatmask = /obj/item/clothing/head/chameleon/drone

/mob/living/simple_animal/drone/snowflake/Initialize()
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

/mob/living/simple_animal/drone/polymorphed/Initialize()
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

/obj/item/drone_shell/dusty
	name = "derelict drone shell"
	desc = "A long-forgotten drone shell. It seems kind of... Space Russian."
	drone_type = /mob/living/simple_animal/drone/derelict

/mob/living/simple_animal/drone/derelict
	name = "derelict drone"
	default_hatmask = /obj/item/clothing/head/ushanka


/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver) && stat == DEAD)
		try_reactivate(user)
	else
		..()