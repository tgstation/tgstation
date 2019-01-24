//					  //
// -----Vr Stuff----- //
//					  //

/area/awaymission/vr/miner
	name = "VrMining"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/datum/outfit/job/miner/equipped/vr
	name = "Virtual Reality Miner"
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = SLOT_S_STORE
	backpack_contents = list(
		/obj/item/gun/energy/kinetic_accelerator=2)

/obj/effect/landmark/vr_spawn/miner
	vr_outfit = /datum/outfit/job/miner/equipped/vr

/obj/structure/closet/crate/necropolis/vr_mining_gear
	name = "armory chest"
	desc = "Has some sick nasty respawning gear."
	icon_state = "necrocrate"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	move_resist=INFINITY
	var/respawn_loot = list() // put types and count in here

/obj/structure/closet/crate/necropolis/vr_mining_gear/dump_contents() // respawn loot on the chest
	var/atom/L = drop_location()
	for(var/type in respawn_loot)
		var/count = respawn_loot[type]
		if(!isnum(count))//Default to 1
			count = 1
		for(var/i = 1 to count)
			new type(L)

/obj/structure/closet/crate/necropolis/vr_mining_gear/take_contents() // delete loot on the chest
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM == src || isliving(AM))
			continue
		qdel(AM)

/obj/structure/closet/crate/necropolis/vr_mining_gear/armor
	name = "Armor Chest"
	desc = "Contains an assortment of lavaland armors."
	respawn_loot = list(
		/obj/item/clothing/suit/hooded/cloak/drake=1,
		/obj/item/clothing/suit/space/hostile_environment=1,
		/obj/item/clothing/head/helmet/space/hostile_environment=1,
		/obj/item/clothing/suit/space/hardsuit/cult=1,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker=1,
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor=1,
		/obj/item/stack/sheet/animalhide/goliath_hide=6)

/obj/structure/closet/crate/necropolis/vr_mining_gear/accelerator
	name = "Kinetic Accelerator Chest"
	desc = "Contains an assortment of kinetic accelerator equipment."
	respawn_loot = list(
		/obj/item/gun/energy/kinetic_accelerator=1,
		/obj/item/borg/upgrade/modkit/lifesteal=1,
		/obj/item/borg/upgrade/modkit/aoe/mobs=1,
		/obj/item/borg/upgrade/modkit/tracer=1,
		/obj/item/borg/upgrade/modkit/tracer/adjustable=1,
		/obj/item/borg/upgrade/modkit/chassis_mod=1,
		/obj/item/borg/upgrade/modkit/chassis_mod/orange=1,
		/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs=1,
		/obj/item/borg/upgrade/modkit/cooldown/repeater=1,
		/obj/item/borg/upgrade/modkit/resonator_blasts=1,
		/obj/item/borg/upgrade/modkit/bounty=1,
		/obj/item/borg/upgrade/modkit/range=3,
		/obj/item/borg/upgrade/modkit/damage=3,
		/obj/item/borg/upgrade/modkit/cooldown=3)

/obj/structure/closet/crate/necropolis/vr_mining_gear/crusher
	name = "Kinetic Crusher Chest"
	desc = "Contains an assortment of kinetic crusher equipment."
	respawn_loot = list(
		/obj/item/twohanded/required/kinetic_crusher=1,
		/obj/item/crusher_trophy/vortex_talisman=1,
		/obj/item/crusher_trophy/demon_claws=1,
		/obj/item/crusher_trophy/tail_spike=1,
		/obj/item/crusher_trophy/miner_eye=1,
		/obj/item/crusher_trophy/legion_skull=1,
		/obj/item/crusher_trophy/goliath_tentacle=1,
		/obj/item/crusher_trophy/blaster_tubes/magma_wing=1,
		/obj/item/crusher_trophy/watcher_wing=1,
		/obj/item/crusher_trophy/blaster_tubes=1)

/obj/structure/closet/crate/necropolis/vr_mining_gear/healing
	name = "Healing Chest"
	desc = "Contains an assortment of healing items."
	respawn_loot = list(
		/obj/item/reagent_containers/hypospray/medipen/survival=1,
		/obj/item/storage/firstaid/brute=1,
		/obj/item/hivelordstabilizer=3,
		/obj/item/organ/regenerative_core/legion=3)

/obj/structure/closet/crate/necropolis/vr_mining_gear/food
	name = "Food Chest"
	desc = "Fresh from the virtual cafeteria."
	respawn_loot = list(
		/obj/item/reagent_containers/food/snacks/donkpocket/warm=5)

/obj/structure/closet/crate/necropolis/vr_mining_gear/misc
	name = "Miscellaneous Chest"
	desc = "Contains an assortment of random lavaland items."
	respawn_loot = list(
		/obj/item/warp_cube/red=1,
		/obj/item/reagent_containers/glass/bottle/potion/flight=1,
		/obj/item/organ/heart/cursed/wizard=1,
		/obj/item/immortality_talisman=1,
		/obj/item/book/granter/spell/summonitem=1)

//										//
// -----Virtual Megafauna Spawners ---- //
//										//

/datum/component/spawner/megafauna
	var/spawn_wait_time = 150 // time to next spawn when the megafauna dies, 15 seconds
	var/initial_spawned = FALSE // so we don't clear the arena and open the door on the initial spawn
	var/nest_range = 10

/datum/component/spawner/megafauna/try_spawn_mob()
	STOP_PROCESSING(SSprocessing, src)
	if(spawned_mobs.len < max_mobs && initial_spawned)
		var/obj/structure/spawner/megafauna/MS = parent
		MS.cleanup_arena()
		spawn_delay = world.time + spawn_wait_time
		var/turf/check = get_ranged_target_turf(get_turf(MS), SOUTH, nest_range + 1)
		if(istype(check, /turf/closed/indestructible/fakedoor))
			check.ChangeTurf(/turf/open/floor/plating/asteroid/basalt/lava_land_surface)
			sleep(spawn_wait_time)
			check.ChangeTurf(/turf/closed/indestructible/fakedoor)
		else
			sleep(spawn_wait_time)
	. = ..()
	initial_spawned = TRUE
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/megafauna
	name = "generic megafauna spawner"
	desc = "Literally does nothing."
	resistance_flags = INDESTRUCTIBLE
	move_resist = INFINITY
	max_mobs = 1
	icon = 'icons/mob/nest.dmi'
	spawn_text = "appears onto"
	density = FALSE
	spawner_type = /datum/component/spawner/megafauna
	var/nest_range = 10

/obj/structure/spawner/megafauna/proc/cleanup_arena()
	for(var/obj/effect/decal/B in urange(nest_range, src))
		qdel(B) // go away blood and garbage shit

/obj/structure/spawner/megafauna/blood_drunk
	name = "drunken beacon"
	desc = "Creates holographic versions of a blood drunken miner."
	icon_state = "blood_drunk"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual)

/obj/structure/spawner/megafauna/dragon
	name = "flame beacon"
	desc = "Creates holographic versions of a fire breathing drake."
	icon_state = "dragon"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/dragon/virtual)

/obj/structure/spawner/megafauna/bubblegum
	name = "bloody beacon"
	desc = "Creates holographic versions of the king of the slaughter demons."
	icon_state = "bubblegum"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual)

/obj/structure/spawner/megafauna/colossus
	name = "radiant beacon"
	desc = "Creates holographic versions of a godlike creature."
	icon_state = "colossus"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/colossus/virtual)

/obj/structure/spawner/megafauna/hierophant
	name = "beacon beacon"
	desc = "Creates holographic versions of a destructive magical club."
	icon_state = "hierophant"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/hierophant/virtual)

/obj/structure/spawner/megafauna/legion
	name = "skull beacon"
	desc = "Creates holographic versions of a gigantic skull demon guarding the necropolis."
	icon_state = "legion"
	mob_types = list(/mob/living/simple_animal/hostile/megafauna/legion/virtual)

//							 //
// ----- Recall Portals ---- //
//							 //

/obj/effect/proc_holder/spell/portal_recall
	name = "Portal Recall"
	desc = "This will teleport you back to your previously used portal. One use only."
	clothes_req = FALSE
	action_icon_state = "blink"
	var/list/recall_portals = list()

/obj/effect/proc_holder/spell/portal_recall/Click(mob/user = usr)
	if(!recall_portals.len)
		user.mind.RemoveSpell(src) // remove spell if no portals left
	var/turf/recall_turf = get_turf(recall_portals[recall_portals.len])
	if(recall_turf)
		do_teleport(user, recall_turf, 0, no_effects = FALSE, channel = TELEPORT_CHANNEL_BLUESPACE)
		recall_portals -= recall_portals[recall_portals.len]
		if(!recall_portals.len)
			user.mind.RemoveSpell(src) // remove spell if no portals left

/obj/effect/portal/permanent/one_way/recall
	name = "recall portal"
	desc = "Gives you a one time ability to return to this portal once you have entered."
	mech_sized = TRUE
	keep = TRUE

/obj/effect/portal/permanent/one_way/recall/Crossed(atom/movable/AM, oldloc)
	if(ismob(AM))
		var/mob/user = AM
		var/check = locate(/obj/effect/proc_holder/spell/portal_recall) in user.mind.spell_list
		if(check)
			var/obj/effect/proc_holder/spell/portal_recall/mob_recall = check
			for(var/obj/effect/portal/permanent/one_way/recall/P in mob_recall.recall_portals)
				if(src == P)
					return ..(AM, oldloc, force_stop = 1) // don't teleport if they have a recall spell with this portal already (or have just teleported onto it)
	return ..()

/obj/effect/portal/permanent/one_way/recall/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(ismob(M))
		var/mob/user = M
		var/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in user.mind.spell_list
		var/obj/effect/proc_holder/spell/portal_recall/personal_recall = findspell ? findspell : new
		personal_recall.recall_portals += src
		if(!findspell)
			user.mind.AddSpell(personal_recall)

//							   //
// -----Virtual Megafauna----- //
//							   //

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual
	name = "blood-drunk miner hologram"
	desc = "A holographic miner, eternally hunting."
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/dragon/virtual
	name = "ash drake hologram"
	desc = "A holographic dragon, once weak, now fierce."
	del_on_death = 1 // goodbye corpse
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual
	name = "bubblegum hologram"
	desc = "A holographic version of the king of the slaughter demons. You feel something oddly real staring back at you."
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/colossus/virtual
	name = "colossus hologram"
	desc = "A holographic god. One of the strongest creatures that has ever lived."
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual
	name = "hierophant hologram"
	desc = "A holographic club. It's said to wipe from existence those who fall to its rhythm."
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/legion/virtual
	name = "Legion Hologram"
	desc = "One of many... holograms."
	crusher_loot = list()
	loot = list()
	true_spawn = 0
