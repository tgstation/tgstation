

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
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/swarmer/Barricade()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/swarmer/Replicate()
	using.screen_loc = ui_zonesel
	static_inventory += using

	using = new /obj/screen/swarmer/RepairSelf()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /obj/screen/swarmer/ToggleLight()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_inventory
	static_inventory += using
	
	////////////////////////////////////
	
/obj/screen/migo
	icon = 'icons/mob/swarmer.dmi'
	
/obj/screen/migo/Hush
	icon_state = "ui_trap"
	name = "Hush"
	desc = "Toggles passive noises and noises when you talk."

/obj/screen/migo/Hush/Click()
	if(!istype(owner, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = owner
	M.Hush()

/obj/screen/migo/ChangeVoice
	icon_state = "ui_trap"
	name = "Tune Voice"
	desc = "Changes your voice to someone else. You will copy the voice patterns if the name matches them."

/obj/screen/migo/ChangeVoice/Click()
	if(!istype(owner, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = owner
	M.ChangeVoice()

/obj/screen/migo/CreateNoise
	icon_state = "ui_trap"
	name = "Fabricate Noise"
	desc = "Creates a specific noise. Different noises have different cooldowns attached to them."

/obj/screen/migo/CreateNoise/Click()
	if(!istype(owner, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = owner
	M.CreateNoise()

/datum/hud/migo/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/migo/Hush()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/migo/ChangeVoice()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/migo/CreateNoise()
	using.screen_loc = ui_zonesel
	static_inventory += using
