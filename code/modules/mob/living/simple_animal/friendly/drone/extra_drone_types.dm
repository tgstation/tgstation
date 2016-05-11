////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overriden procs
//Drones with camogear for hat related memes


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

/mob/living/simple_animal/drone/snowflake/bardrone
	name = "Bardrone"
	desc = "A barkeeping drone, an indestructible robot built to tend bars."
	seeStatic = FALSE
	laws = "1. Serve drinks.\n\
		2. Talk to patrons.\n\
		3. Don't get messed up in their affairs."
	languages = ALL
	status_flags = GODMODE // Please don't punch the barkeeper
	unique_name = FALSE // disables the (123) number suffix

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

