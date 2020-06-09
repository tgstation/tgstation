

/obj/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/obj/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Create trap (Costs 5 Resources)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it. (Costs 5 resources)"

/obj/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/**
  * # SwarmerPylonButton
  *
  * The ui object operating as a button to create pylons.
  */

/obj/screen/swarmer/Pylon
	icon_state = "ui_barricade"
	name = "Create pylon (Costs 25 Resources)"
	desc = "Creates a pylon, which expands the area swarmers may operate in. (Costs 25 resources)"

/obj/screen/swarmer/Pylon/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreatePylon()

/obj/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Create barricade (Costs 5 Resources)"
	desc = "Creates a destructible barricade that will stop any non swarmer from passing it. Also allows disabler beams to pass through. (Costs 5 resources)"

/obj/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/obj/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 50 Resources)"
	desc = "Creates another of our kind."

/obj/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/obj/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Repair self"
	desc = "Repairs damage to our body."

/obj/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/obj/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Toggle light"
	desc = "Toggles our inbuilt light on or off."

/obj/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ToggleLight()

/obj/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact swarmers"
	desc = "Sends a message to all other swarmers, should they exist."

/obj/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/swarmer/FabricateTrap()
	using.screen_loc = ui_swarmer_trap
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/Barricade()
	using.screen_loc = ui_swarmer_barricade
	using.hud = src
	static_inventory += using
	
	using = new /obj/screen/swarmer/Pylon()
	using.screen_loc = ui_swarmer_pylon
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/Replicate()
	using.screen_loc = ui_swarmer_replicate
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/RepairSelf()
	using.screen_loc = ui_swarmer_repair
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/ToggleLight()
	using.screen_loc = ui_swarmer_light
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_swarmer_contact
	using.hud = src
	static_inventory += using
