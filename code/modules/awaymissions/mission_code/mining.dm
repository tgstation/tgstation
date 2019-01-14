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

//														   //
// -----Virtual Megafauna Spawners and Linked Portals----- //
//														   //

/obj/structure/spawner/megafauna
	name = "generic megafauna spawner"
	desc = "Literally does nothing."
	resistance_flags = INDESTRUCTIBLE
	move_resist = INFINITY
	max_mobs = 1
	icon = 'icons/mob/nest.dmi'
	spawn_text = "appears onto"

/obj/structure/spawner/megafauna/proc/cleanup_arena()
	for(var/obj/effect/decal/B in urange(10, src, 1))
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

/obj/effect/portal/permanent/megafauna_arena
	name = "megafauna portal"
	desc = "Leads to a place of unspeakable torment."
	mech_sized = TRUE

/obj/effect/portal/permanent/megafauna_arena/attackby(obj/item/W, mob/user, params)
	if(ismegafauna(user))
		return 0
	. = ..()

/obj/effect/portal/permanent/megafauna_arena/Crossed(atom/movable/AM, oldloc)
	if(ismegafauna(AM))
		return 0
	. = ..()

/obj/effect/portal/permanent/megafauna_arena/attack_hand(mob/user)
	if(ismegafauna(user))
		return 0
	. = ..()

/obj/effect/portal/permanent/megafauna_arena/teleport(atom/movable/M, force = FALSE)
	if(ismegafauna(M))
		return 0
	. = ..()

//							   //
// -----Virtual Megafauna----- //
//							   //

#define MEGAFAUNA_SPAWN_DELAY 200 // 20 seconds

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual
	name = "blood-drunk miner hologram"
	desc = "A holographic miner, eternally hunting."
	crusher_loot = list()
	loot = list()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	var/obj/structure/spawner/megafauna/P = nest.parent
	P.cleanup_arena()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return

/mob/living/simple_animal/hostile/megafauna/dragon/virtual
	name = "ash drake hologram"
	desc = "A holographic dragon, once weak, now fierce."
	crusher_loot = list()
	loot = list()

/mob/living/simple_animal/hostile/megafauna/dragon/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/dragon/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	var/obj/structure/spawner/megafauna/P = nest.parent
	P.cleanup_arena()
	. = ..()
	qdel(src)

/mob/living/simple_animal/hostile/megafauna/dragon/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual
	name = "bubblegum hologram"
	desc = "A holographic version of the king of the slaughter demons. You feel something oddly real staring back at you."
	crusher_loot = list()
	loot = list()
	true_spawn = 0

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	var/obj/structure/spawner/megafauna/P = nest.parent
	P.cleanup_arena()
	. = ..()

// need this otherwise bubbles can teleport out of his arena
/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/hallucination_charge_around(var/times = 4, var/delay = 6, var/chargepast = 0, var/useoriginal = 1)
	var/startingangle = rand(1, 360)
	if(!target)
		return
	var/turf/chargeat = get_turf(target)
	var/srcplaced = 0
	for(var/i = 1 to times)
		var/ang = (startingangle + 360/times * i)
		if(!chargeat)
			return
		var/turf/place = locate(chargeat.x + cos(ang) * times, chargeat.y + sin(ang) * times, chargeat.z)
		if(!place)
			continue
		if(!srcplaced && useoriginal && get_dist(nest.parent, place) <= 10)
			forceMove(place)
			srcplaced = 1
			continue
		var/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/B = new /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination(src.loc)
		B.forceMove(place)
		INVOKE_ASYNC(B, .proc/charge, chargeat, delay, chargepast)
	if(useoriginal)
		charge(chargeat, delay, chargepast)

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return

/mob/living/simple_animal/hostile/megafauna/colossus/virtual
	name = "colossus hologram"
	desc = "A holographic god. One of the strongest creatures that has ever lived."
	crusher_loot = list()
	loot = list()

/mob/living/simple_animal/hostile/megafauna/colossus/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/colossus/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	var/obj/structure/spawner/megafauna/P = nest.parent
	P.cleanup_arena()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/colossus/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual
	name = "hierophant hologram"
	desc = "A holographic club. It's said to wipe from existence those who fall to its rhythm."
	loot = list()
	crusher_loot = list()

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/spawn_crusher_loot()
	return

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	var/obj/structure/spawner/megafauna/P = nest.parent
	P.cleanup_arena()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return

/mob/living/simple_animal/hostile/megafauna/legion/virtual
	name = "Legion Hologram"
	desc = "One of many... holograms."
	loot = list()
	virtual = 1

/mob/living/simple_animal/hostile/megafauna/legion/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/legion/virtual/death()
	nest.spawn_delay = world.time + MEGAFAUNA_SPAWN_DELAY
	if(health > 0)
		return
	if(size > 1)
		adjustHealth(-maxHealth) //heal ourself to full in prep for splitting
		var/mob/living/simple_animal/hostile/megafauna/legion/virtual/L = new(loc)

		L.maxHealth = round(maxHealth * 0.6,DAMAGE_PRECISION)
		maxHealth = L.maxHealth

		L.health = L.maxHealth
		health = maxHealth

		size--
		L.size = size

		L.resize = L.size * 0.2
		transform = initial(transform)
		resize = size * 0.2

		L.update_transform()
		update_transform()

		L.faction = faction.Copy()

		L.GiveTarget(target)

		L.nest = nest

		visible_message("<span class='boldannounce'>[src] splits in twain!</span>")
	else
		var/obj/structure/spawner/megafauna/P = nest.parent
		P.cleanup_arena()
		..()

/mob/living/simple_animal/hostile/megafauna/legion/virtual/grant_achievement(medaltype, scoretype, crusher_kill)
	return