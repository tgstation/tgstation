/atom/movable/screen/swarmer
	icon = 'icons/hud/swarmer.dmi'

/atom/movable/screen/swarmer/fabricate_trap
	icon_state = "ui_trap"
	name = "Create trap (Costs 4 Resources)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it. (Costs 4 resources)"

/atom/movable/screen/swarmer/fabricate_trap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.create_trap()

/atom/movable/screen/swarmer/barricade
	icon_state = "ui_barricade"
	name = "Create barricade (Costs 4 Resources)"
	desc = "Creates a destructible barricade that will stop any non swarmer from passing it. Also allows disabler beams to pass through. (Costs 4 resources)"

/atom/movable/screen/swarmer/barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.create_barricade()

/atom/movable/screen/swarmer/replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 20 Resources)"
	desc = "Creates a drone."

/atom/movable/screen/swarmer/replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.create_swarmer()

/atom/movable/screen/swarmer/repair_self
	icon_state = "ui_self_repair"
	name = "Repair self"
	desc = "Repairs damage to our body."

/atom/movable/screen/swarmer/repair_self/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.repair_self()

/atom/movable/screen/swarmer/toggle_light
	icon_state = "ui_light"
	name = "Toggle light"
	desc = "Toggles our inbuilt light on or off."

/atom/movable/screen/swarmer/toggle_light/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.toggle_light()

/atom/movable/screen/swarmer/contact_swarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact swarmers"
	desc = "Sends a message to all other swarmers, should they exist."

/atom/movable/screen/swarmer/contact_swarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.contact_swarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/swarmer/fabricate_trap()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/barricade()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/replicate()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/repair_self()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/toggle_light()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/contact_swarmers()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using
