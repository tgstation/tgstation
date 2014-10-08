/obj/item/weapon/table_parts/old
	name = "old table parts"
	desc = "Somehow still hasn't fallen apart yet."
	icon_state = "table_parts"
	table_type = /obj/structure/table/old
	flags = CONDUCT

/obj/machinery/nuclearbomb/old
	name = "old nuclear fission explosive"
	desc = "You consider running, but assume it's probably defused due to how old it is."
	icon_state = "oldbomb0"
	bombtype = "oldbomb"

/obj/machinery/computer/crew/oldstation
	name = "ancient computer"
	desc = "It seems to be unable to get a connection to the databases. The program running says it's copyright 1995. The computer looks old as fuck."
	icon_state = "oldstation"

/obj/machinery/door/airlock/oldstation
	icon = 'icons/obj/doors/Dooroldstation.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_mai

/obj/item/device/multitool/old
	icon = 'icons/obj/items.dmi'
	icon_state = "oldmultitool"

/obj/item/device/radio/off/old
	icon = 'icons/obj/items.dmi'
	icon_state = "oldradio"

/obj/item/weapon/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "oldlarge"

/obj/item/weapon/shard/old/New()
	icon_state = pick("oldlarge", "oldmedium", "oldsmall")
	switch(icon_state)
		if("oldsmall")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("oldmedium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("oldlarge")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/storage/toolbox/old
	name = "old toolbox"
	icon_state = "oldtoolbox"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/old/New()
	..()
	new /obj/item/weapon/screwdriver/old(src)
	new /obj/item/weapon/wrench/old(src)
	new /obj/item/weapon/crowbar/old(src)
	new /obj/item/weapon/wirecutters/old(src)
	new /obj/item/device/multitool/old(src)
	new /obj/item/device/radio/off/old(src)

/obj/item/weapon/wrench/old
	icon_state = "oldwrench"

/obj/item/weapon/screwdriver/old
	icon_state = "oldscrewdriver"

/obj/item/weapon/screwdriver/old/New()
	return

/obj/item/weapon/wirecutters/old
	icon_state = "oldcutters"

/obj/item/weapon/wirecutters/old/New()
	return

/obj/item/weapon/crowbar/old
	icon_state = "oldcrowbar"

/obj/structure/table/old
	name = "old table"
	desc = "Somehow, this table is still intact after all these years."
	icon_state = "oldtable"
	parts = /obj/item/weapon/table_parts/old

/mob/living/simple_animal/hostile/ancient
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "ancient_assistant"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "robusts"
	speed = 0
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	var/drop1
	var/drop2
	attacktext = "punches"
	a_intent = "harm"
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atmos_damage = 15
	faction = list("ancient")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/ancient/Die()
	..()
	if(drop1)
		new drop1 (src.loc)
	if(drop2)
		new drop2 (src.loc)
	return

/mob/living/simple_animal/hostile/ancient/security
	name = "Security Officer"
	desc = "An ancient security officer from times long past. He doesn't like you very much."
	icon_state = "ancient_security"
	icon_living = "ancient_security"
	icon_dead = "ancient_security_dead"
	drop1 = /obj/item/weapon/gun/energy/taser/old
	drop2 = /obj/item/device/multitool/old
/mob/living/simple_animal/hostile/ancient/assistant
	name = "Assistant"
	desc = "An ancient assistant from times long past. He doesn't like you very much."
	icon_state = "ancient_assistant"
	icon_living = "ancient_assistant"
	icon_dead = "ancient_assistant_dead"
	drop1 = /obj/item/device/multitool/old
/mob/living/simple_animal/hostile/ancient/spaceman
	name = "Spaceman"
	desc = "An ancient spaceman from times long past. He doesn't like you very much."
	icon_state = "ancient_spaceman"
	icon_living = "ancient_spaceman"
	icon_dead = "ancient_spaceman_dead"
	drop1 = /obj/item/weapon/gun/energy/taser/old
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/obj/structure/closet/ancient
	name = "old closet"
	desc = "An old as fuck closet."
	icon_state = "oldcloset"
	icon_opened = "oldclosetopen"
	icon_closed = "oldcloset"

/obj/structure/closet/ancientsec
	name = "old closet"
	desc = "An old as fuck closet."
	icon_state = "oldseccloset"
	icon_opened = "oldsecclosetopen"
	icon_closed = "oldseccloset"

/obj/structure/window/basic/old
	icon_state = "oldwindow"
	shardtype = /obj/item/weapon/shard/old

/obj/structure/window/reinforced/old
	icon_state = "oldrwindow"
	shardtype = /obj/item/weapon/shard/old

/turf/simulated/floor/oldstation
	name = "floor"
	desc = "The fuck is this shit? It looks old as hell."
	icon_state = "oldfloor"

/turf/unsimulated/wall/oldspace
	name = "solidified space"
	desc = "The laws of physics don't seem to apply to this. No one knows why."
	icon = 'icons/turf/space.dmi'
	icon_state = "oldspace"
	opacity = 0
	density = 1
	blocks_air = 1

/turf/simulated/wall/oldstation
	name = "wall"
	desc = "You try to comprehend how old these walls seem to be. You can't manage it."
	icon_state = "old_wall"
	walltype = "oldstation"

/turf/simulated/wall/r_wall/oldstation
	name = "reinforced wall"
	desc = "You try to comprehend how old these walls seem to be. You can't manage it."
	icon_state = "old_r_wall"
	walltype = "reinforcedoldstation"

/turf/space/oldstation
	name = "space"
	desc = "Somehow, this space feels old."
	icon_state = "oldspace"

/obj/item/weapon/gun/energy/taser/old
	icon_state = "t_gun"