/datum/action/cooldown/infection
	name = "Infection Power"
	desc = "New Infection Power"
	icon_icon = 'icons/mob/blob.dmi'
	button_icon_state = "blank_blob"
	cooldown_time = 0
	var/cost = 0 // cost to actually use
	var/upgrade_cost = 0 // cost to buy from the evolution shop

/datum/action/cooldown/infection/New()
	name = name + " ([cost])"
	. = ..()

/datum/action/cooldown/infection/Trigger()
	if(!..())
		return FALSE
	if(!iscommander(owner))
		return FALSE
	var/mob/camera/commander/I = owner
	var/turf/T = get_turf(I)
	if(T)
		fire(I, T)
		return TRUE
	return FALSE

/datum/action/cooldown/infection/proc/fire(mob/camera/commander/I, turf/T)
	return TRUE

/datum/action/cooldown/infection/freecam
	name = "Full Vision"
	desc = "Allows you to move your camera to anywhere, whether or not you have an infection next to it."
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "godeye"
	upgrade_cost = 1

/datum/action/cooldown/infection/freecam/fire(mob/camera/commander/I, turf/T)
	I.freecam = !I.freecam
	to_chat(I, "<span class='notice'>Successfully toggled [name]!</span>")

/datum/action/cooldown/infection/medicalhud
	name = "Medical Hud"
	desc = "Allows you to see the health of creatures on your screen."
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "healthhud"
	upgrade_cost = 1

/datum/action/cooldown/infection/medicalhud/fire(mob/camera/commander/I, turf/T)
	I.toggle_medical_hud()
	to_chat(I, "<span class='notice'>Successfully toggled [name]!</span>")

/datum/action/cooldown/infection/emppulse
	name = "Emp Pulse"
	desc = "Charges up an EMP Pulse centered on the infection you are above."
	icon_icon = 'icons/obj/grenade.dmi'
	button_icon_state = "emp"
	cooldown_time = 300
	upgrade_cost = 1

/datum/action/cooldown/infection/emppulse/fire(mob/camera/commander/I, turf/T)
	if(locate(/obj/structure/infection) in T.contents)
		StartCooldown()
		playsound(T, pick('sound/weapons/ionrifle.ogg'), 300, FALSE, pressure_affected = FALSE)
		new /obj/effect/temp_visual/impact_effect/ion(T)
		sleep(20)
		return empulse(T, 3, 6)
	to_chat(I, "<span class='warning'>You must be above an infection to use this ability!</span>")

/datum/action/cooldown/infection/creator
	name = "Create"
	desc = "New Creation Power"
	var/type_to_create
	var/distance_from_similar = 0
	var/needs_node = FALSE

/datum/action/cooldown/infection/creator/fire(mob/camera/commander/I, turf/T)
	I.createSpecial(cost, type_to_create, distance_from_similar, needs_node, T)
	return TRUE

/datum/action/cooldown/infection/creator/shield
	name = "Create Shield Infection"
	desc = "Create a shield infection, which is harder to kill. Using this on an existing shield blob turns it into a reflective shield, capable of reflecting most projectiles."
	cost = 5
	icon_icon = 'icons/obj/smooth_structures/infection_wall.dmi'
	button_icon_state = "smooth"
	type_to_create = /obj/structure/infection/shield

/datum/action/cooldown/infection/creator/resource
	name = "Create Resource Infection"
	desc = "Create a resource tower which will generate resources for you."
	cost = 10
	button_icon_state = "blob_resource"
	type_to_create = /obj/structure/infection/resource
	distance_from_similar = 4
	needs_node = TRUE

/datum/action/cooldown/infection/creator/node
	name = "Create Node Infection"
	desc = "Create a node, which will power nearby factory and resource structures."
	cost = 15
	button_icon_state = "blob_node"
	type_to_create = /obj/structure/infection/node
	distance_from_similar = 5

/datum/action/cooldown/infection/creator/factory
	name = "Create Factory Infection"
	desc = "Create a spore tower that will spawn spores to harass your enemies."
	cost = 20
	button_icon_state = "blob_factory"
	type_to_create = /obj/structure/infection/factory
	distance_from_similar = 7
	needs_node = TRUE

/datum/action/cooldown/infection/creator/turret
	name = "Create Turret Infection"
	desc = "Create a turret that will automatically fire at your enemies."
	cost = 30
	icon_icon = 'icons/mob/infection/infection.dmi'
	button_icon_state = "infection_turret"
	type_to_create = /obj/structure/infection/turret
	distance_from_similar = 8
	needs_node = TRUE
	upgrade_cost = 1
