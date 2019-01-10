//					  //
// -----Vr Stuff----- //
//					  //

/obj/machinery/vr_sleeper/miner
	name = "mining virtual reality sleeper"
	desc = "A virtual reality training simulator for mining expeditions."
	vr_category = "mining"

/datum/outfit/job/miner/vr_megafauna_fighter
	name = "Megafauna Fighter"
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = SLOT_S_STORE
	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/gun/energy/kinetic_accelerator=2,
		/obj/item/organ/regenerative_core/legion=4)

/datum/outfit/job/miner/vr_megafauna_fighter/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/S = H.wear_suit
		S.ToggleHood()
	var/obj/item/card/id/id_card = H.get_idcard(FALSE)
	if(id_card)
		id_card.mining_points = 50000

/obj/machinery/vr_sleeper/miner/build_virtual_human(mob/living/carbon/human/H, location, var/datum/outfit/outfit, transfer = TRUE)
	if(H)
		cleanup_vr_human()
		vr_human = new /mob/living/carbon/human/virtual_reality(location)
		vr_human.mind_initialize()
		vr_human.vr_sleeper = src
		vr_human.real_mind = H.mind
		H.dna.transfer_identity(vr_human)
		vr_human.name = H.name
		vr_human.real_name = H.real_name
		vr_human.socks = H.socks
		vr_human.undershirt = H.undershirt
		vr_human.underwear = H.underwear
		vr_human.updateappearance(TRUE, TRUE, TRUE)
		if(outfit)
			var/datum/outfit/O = new outfit()
			O.equip(vr_human)
		if(transfer && H.mind)
			SStgui.close_user_uis(H, src)
			vr_human.ckey = H.ckey
		vr_human.equipOutfit(/datum/outfit/job/miner/vr_megafauna_fighter)
		var/turf/on = get_turf(vr_human)
		for(var/obj/item/I in on.contents)
			qdel(I) // clean up junk left over after other spawns unless it was moved
		new /obj/item/clothing/suit/hooded/cloak/drake(vr_human.loc)
		new /obj/item/mining_voucher(vr_human.loc)
		new /obj/item/warp_cube/red(vr_human.loc)
		new /obj/item/clothing/suit/space/hostile_environment(vr_human.loc)
		new /obj/item/clothing/head/helmet/space/hostile_environment(vr_human.loc)

/area/awaymission/vr/miner
	name = "VrMining"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/obj/effect/landmark/vr_spawn/miner
	vr_category = "mining"

//										//
// -----Virtual Megafauna Spawners----- //
//										//

/obj/structure/spawner/megafauna
	name = "generic megafauna spawner"
	desc = "Literally does nothing."
	resistance_flags = INDESTRUCTIBLE
	move_resist = INFINITY
	max_mobs = 1
	icon = 'icons/mob/nest.dmi'
	spawn_text = "appears onto"

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

//							   //
// -----Virtual Megafauna----- //
//							   //

#define MEGAFAUNA_NEST_RANGE 20

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual
	name = "blood-drunk miner hologram"
	desc = "A holographic miner, eternally hunting."
	crusher_loot = null
	loot = null
	medal_type = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/dragon/virtual
	name = "ash drake hologram"
	desc = "A holographic dragon, once weak but now fierce."
	crusher_loot = null
	loot = null
	butcher_results = null
	guaranteed_butcher_results = null
	medal_type = null
	score_type = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/dragon/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/dragon/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual
	name = "bubblegum hologram"
	desc = "A holographic version of the king of the slaughter demons. You get the feeling that the real bubblegum is watching you."
	crusher_loot = null
	loot = null
	medal_type = null
	score_type = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/colossus/virtual
	name = "colossus hologram"
	desc = "A holographic god. One of the strongest creatures that has ever lived."
	medal_type = null
	score_type = null
	crusher_loot = null
	loot = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/colossus/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/colossus/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual
	name = "hierophant hologram"
	desc = "A holographic club. It's said to wipe from existence those who fall to its rhythm."
	loot = null
	crusher_loot = null
	medal_type = null
	score_type = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual/spawn_crusher_loot()
	return

/mob/living/simple_animal/hostile/megafauna/legion/virtual
	name = "Legion Hologram"
	desc = "One of many... holograms."
	medal_type = null
	score_type = null
	loot = null
	del_on_death = 1

/mob/living/simple_animal/hostile/megafauna/legion/virtual/Initialize()
	. = ..()
	qdel(internal)

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual/Moved()
	if(nest && get_dist(src, nest.parent) > MEGAFAUNA_NEST_RANGE)
		health = 0
		death()
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/legion/virtual/death()
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
		..()