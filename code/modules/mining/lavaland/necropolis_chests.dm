//The chests dropped by tendrils and megafauna.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	can_install_electronics = FALSE

/obj/structure/closet/crate/necropolis/megafauna
	var/required_keys = 3
	desc = "It's watching you suspiciously. There are 7 keyholes."
	var/list/loot = list()
	integrity_failure = 0

/obj/structure/closet/crate/necropolis/megafauna/proc/spawn_loot()
	return

/obj/structure/closet/crate/necropolis/megafauna/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/try_spawn_loot)

/obj/structure/closet/crate/necropolis/megafauna/proc/try_spawn_loot(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/skeleton_key) || !required_keys)
		return FALSE

	required_keys -= 1
	qdel(item)
	if(!required_keys && loot)
		to_chat(user, span_notice("You disable the magic lock, revealing the loot."))
		desc = "It's watching you suspiciously."
		spawn_loot()
		return TRUE
	else
		to_chat(user, span_notice("You insert the key into the [src]. There are [required_keys] empty keyholes left."))
		desc = "It's watching you suspiciously. There are [required_keys] keyholes."

/obj/structure/closet/crate/necropolis/megafauna/can_open(mob/living/user, force = FALSE)
	if(required_keys)
		return FALSE
	return ..()

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously. You need a skeleton key to open it."
	integrity_failure = 0 //prevents bust_open from firing
	/// var to check if it got opened by a key
	var/spawned_loot = FALSE

/obj/structure/closet/crate/necropolis/tendril/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/try_spawn_loot)

/obj/structure/closet/crate/necropolis/tendril/proc/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/skeleton_key) || spawned_loot)
		return FALSE
	var/loot = rand(1,20)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/soulstone/anybody/mining(src)
		if(3)
			new /obj/item/organ/cyberimp/arm/katana(src)
		if(4)
			new /obj/item/clothing/glasses/godeye(src)
		if(5)
			new /obj/item/reagent_containers/glass/bottle/potion/flight(src)
		if(6)
			new /obj/item/clothing/gloves/gauntlets(src)
		if(7)
			var/mod = rand(1,4)
			switch(mod)
				if(1)
					new /obj/item/disk/design_disk/modkit_disc/resonator_blast(src)
				if(2)
					new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(src)
				if(3)
					new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(src)
				if(4)
					new /obj/item/disk/design_disk/modkit_disc/bounty(src)
		if(8)
			new /obj/item/rod_of_asclepius(src)
		if(9)
			new /obj/item/organ/heart/cursed/wizard(src)
		if(10)
			new /obj/item/ship_in_a_bottle(src)
		if(11)
			new /obj/item/clothing/suit/hooded/berserker(src)
		if(12)
			new /obj/item/jacobs_ladder(src)
		if(13)
			new /obj/item/guardiancreator/miner(src)
		if(14)
			new /obj/item/warp_cube/red(src)
		if(15)
			new /obj/item/wisp_lantern(src)
		if(16)
			new /obj/item/immortality_talisman(src)
		if(17)
			new /obj/item/book/granter/spell/summonitem(src)
		if(18)
			new /obj/item/book_of_babel(src)
		if(19)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
		if(20)
			new /obj/item/clothing/neck/necklace/memento_mori(src)
	spawned_loot = TRUE
	qdel(item)
	to_chat(user, span_notice("You disable the magic lock, revealing the loot."))
	return TRUE

/obj/structure/closet/crate/necropolis/tendril/can_open(mob/living/user, force = FALSE)
	if(!spawned_loot)
		return FALSE
	return ..()

//Megafauna chests

/obj/structure/closet/crate/necropolis/megafauna/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/megafauna/dragon/spawn_loot()
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
		if(3)
			new /obj/item/book/granter/spell/sacredflame(src)
		if(4)
			new /obj/item/dragons_blood(src)

/obj/structure/closet/crate/necropolis/megafauna/dragon/crusher
	name = "firey dragon chest"

/obj/structure/closet/crate/necropolis/megafauna/dragon/crusher/spawn_loot()
	..()
	new /obj/item/crusher_trophy/tail_spike(src)

/obj/structure/closet/crate/necropolis/megafauna/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/megafauna/bubblegum/spawn_loot()
	new /obj/item/clothing/suit/hooded/hostile_environment(src)
	var/loot = rand(1,2)
	switch(loot)
		if(1)
			new /obj/item/mayhem(src)
		if(2)
			new /obj/item/soulscythe(src)

/obj/structure/closet/crate/necropolis/megafauna/bubblegum/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/megafauna/bubblegum/crusher/spawn_loot()
	..()
	new /obj/item/crusher_trophy/demon_claws(src)

/obj/structure/closet/crate/necropolis/megafauna/colossus
	name = "colossus chest"

/obj/structure/closet/crate/necropolis/megafauna/colossus/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/colossus))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/structure/closet/crate/necropolis/megafauna/colossus/spawn_loot()
	var/list/choices = subtypesof(/obj/machinery/anomalous_crystal)
	var/random_crystal = pick(choices)
	new random_crystal(src)
	new /obj/item/organ/vocal_cords/colossus(src)

/obj/structure/closet/crate/necropolis/megafauna/colossus/crusher
	name = "angelic colossus chest"

/obj/structure/closet/crate/necropolis/megafauna/colossus/crusher/spawn_loot()
	..()
	new /obj/item/crusher_trophy/blaster_tubes(src)

/obj/structure/closet/crate/necropolis/megafauna/hierophant
	name = "hierophant chest"

/obj/structure/closet/crate/necropolis/megafauna/hierophant/spawn_loot()
	new /obj/item/hierophant_club(src)

/obj/structure/closet/crate/necropolis/megafauna/hierophant/crusher
	name = "zealous hierophant chest"

/obj/structure/closet/crate/necropolis/megafauna/hierophant/crusher/spawn_loot()
	new /obj/item/hierophant_club(src)
	new /obj/item/crusher_trophy/vortex_talisman(src)

//Other chests and minor stuff

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/PopulateContents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody/mining(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

/obj/item/skeleton_key
	name = "skeleton key"
	desc = "An artifact usually found in the hands of the natives of lavaland, which NT now holds a monopoly on."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "skeleton_key"
	w_class = WEIGHT_CLASS_SMALL
