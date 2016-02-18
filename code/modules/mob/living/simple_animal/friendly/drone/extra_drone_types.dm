////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overriden procs


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


/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

/obj/item/drone_shell/syndrone/badass
	name = "badass syndrone shell"
	drone_type = /mob/living/simple_animal/drone/syndrone/badass


/mob/living/simple_animal/drone/crab
	name = "crab"
	desc = "Free crabs!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	picked = TRUE
	unsuitable_atmos_damage = 0
	wander = 1
	ventcrawler = 2
	healable = 1
	sight = 0
	voice_name = "chitters"
	speak_emote = list("chitters")
	bubble_icon = "default"
	languages = HUMAN
	has_unlimited_silicon_privilege = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 0)
	laws = \
	"You are a crab. Do crab things."
	heavy_emp_damage = 0 //Crab not robotic
	seeStatic = 0 //Crab can see.
	default_storage = null
	dir = 2
	visualAppearence = SCOUTDRONE
	speed = 3
	melee_damage_upper = 5
	melee_damage_lower = 5
	a_intent = "harm"
	attacktext = "pinches"

/mob/living/simple_animal/drone/crab/New()
	..()
	access_card = null //No captain access.
	scanner.Remove(src) //No research scanner.
	verbs -= /mob/living/simple_animal/drone/verb/drone_ping
	verbs -= /mob/living/simple_animal/drone/verb/toggle_light




/mob/living/simple_animal/drone/crab/face_atom()
	dir = 2

/mob/living/simple_animal/drone/crab/Move()
	..()
	dir = 2

/mob/living/simple_animal/drone/crab/update_drone_icon()
	return

/mob/living/simple_animal/drone/crab/emp_act(severity)
	for(var/obj/item/I in contents)
		I.emp_act(severity)

/mob/living/simple_animal/drone/crab/update_drone_hack()
	return