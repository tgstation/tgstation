//Modular Map marker
/obj/modular_map_root/caves
	config_file = "strings/modular_maps/caves.toml"

//Mech used by the clockwork miners
/obj/vehicle/sealed/mecha/working/ripley/mk2/clockcult
	icon_state = "ripleyclockcult"
	base_icon_state = "ripleyclockcult"
	silicon_icon_state = "ripleyclockcult-empty"
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2/clockcult
	desc = "Autonomous Power Loader Unit MK-II. This one seems adorned with strange pieces of bronze metal."
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/structure/mecha_wreckage/ripley/mk2/clockcult
	name = "\improper Ripley MK-II wreckage"
	icon_state = "ripleyclockcult-broken"
	parts = list(
				/obj/item/mecha_parts/part/ripley_torso,
				/obj/item/mecha_parts/part/ripley_left_arm,
				/obj/item/mecha_parts/part/ripley_right_arm,
				/obj/item/mecha_parts/part/ripley_left_leg,
				/obj/item/mecha_parts/part/ripley_right_leg,
				/obj/item/stack/sheet/bronze)

//Mobs specific to the caves mission
/mob/living/simple_animal/hostile/syndicate/mecha_pilot/clockminer //who gave the cultists a RIPLEY?
	name = "Clockwork Servant Mecha Pilot"
	desc = "Death to those who oppose His Gracious Light. This variant comes in MECHA DEATH flavour."
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	icon_state = "clockminer"
	icon_living = "clockminer"
	faction = list("clockwork")
	footstep_type = FOOTSTEP_MOB_HEAVY
	spawn_mecha_type = /obj/vehicle/sealed/mecha/working/ripley/mk2/clockcult

/mob/living/simple_animal/hostile/syndicate/mecha_pilot/no_mech/clockminer
	name = "Clockwork Servant Mecha Pilot"
	desc = "Death to those who oppose His Gracious Light. This variant comes in MECHA DEATH flavour."
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	icon_state = "clockminer"
	icon_living = "clockminer"
	footstep_type = FOOTSTEP_MOB_HEAVY
	faction = list("clockwork")

/mob/living/simple_animal/hostile/clockminer
	name = "Clockwork Servant"
	desc = "A miner adorned with shining bronze armor. They look particularly angry with you."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clockminer"
	icon_living = "clockminer"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 100
	emote_taunt = list("Uvf Tenpvbhf Yvtug jvyy qnja hcba guvf qnex jbeyq bapr zber! Bear witness, Heretic!", "I will show you His Gracious One's guiding light, either willing or by force!", 
			"Znl Uvf Tenpvbhf Yvtug fuvar bire zr va guvf onggyr. Prepare to be enlightened, Heretic!", "You dare tread upon His Gracious One's sacred resting grounds??")
	var/death_phrases = list("Ratvar... forgive me", "So.. close...", "Where is His Light? Its so.. dark...", "You've forsaken us.. Heretic...")
	turns_per_move = 5
	speed = 2
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 150
	health = 150
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("clockwork")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1
	dodging = TRUE
	dodge_prob = 15
	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/clockminer/death()
	if(prob(25))
		say(pick(death_phrases))
		..()

/obj/effect/mob_spawn/corpse/human/clockminer
	name = "Clock Cult Miner"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/clockminer

/datum/outfit/clockminer
	name = "Clock Cult Miner"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/bronze
	shoes = /obj/item/clothing/shoes/bronze
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/bronze
	mask = /obj/item/clothing/mask/gas/explorer

//Areas
/area/awaymission/caves/bmp_asteroid
	name = "Outpost Region Delta"
	icon_state = "awaycontent1"
	sound_environment = SOUND_AREA_LAVALAND

/area/awaymission/caves/bmp_asteroid/level_two
	name = "Outpost Region Echo"
	icon_state = "awaycontent2"

/area/awaymission/caves/bmp_asteroid/level_three
	name = "Uncharted Depths"
	icon_state = "awaycontent3"

/area/awaymission/caves/bmp_asteroid/level_four
	name = "-INFORMATION REDACTED-"
	icon_state = "awaycontent4"

/area/awaymission/caves/main_outpost
	name = "Mining Outpost Delta"
	icon_state = "awaycontent1"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/caves/main_outpost/storage
	name = "Mining Outpost Delta Suit Storage"

/area/awaymission/caves/main_outpost/dorm
	name = "Mining Outpost Delta Living Quarters"

/area/awaymission/caves/main_outpost/engineering
	name = "Mining Outpost Delta Power Wing"

/area/awaymission/caves/main_outpost/depo
	name = "Mining Outpost Delta Ore Processing"

/area/awaymission/caves/main_outpost/rec
	name = "Mining Outpost Delta Mess Hall"

/area/awaymission/caves/main_outpost/seconadry/storage
	name = "Delta Outpost Storage Lot"

/area/awaymission/caves/main_outpost/seconadry/engineering
	name = "Delta Outpost Life Support"

/area/awaymission/caves/main_outpost/seconadry/mecha
	name = "Delta Outpost Mecha Bay"

/area/awaymission/caves/main_outpost/seconadry/recycle
	name = "Delta Outpost Recycling Post"

/area/awaymission/caves/main_outpost/seconadry/mecha/living
	name = "Delta Outpost Mecha Bay Living Quarters"

/area/awaymission/caves/main_outpost/seconadry/secpost
	name = "Delta Outpost Security Post"

/area/awaymission/caves/main_outpost/seconadry/research
	name = "Delta Outpost Research Post"

/area/awaymission/caves/main_outpost/seconadry/research/living
	name = "Delta Outpost Research Post Living Quarters"

/area/awaymission/caves/main_outpost/seconadry/data
	name = "Delta Outpost Research Post Data Center"

/area/awaymission/caves/main_outpost/seconadry/engineering
	name = "Delta Outpost Research Post Life Support"

/area/awaymission/caves/main_outpost/seconadry/gateway
	name = "Gateway Terminal Delta"

/area/awaymission/caves/main_outpost/seconadry/between_access
	name = "Level Transit Delta"

/area/awaymission/caves/second_outpost
	name = "Mining Outpost Echo"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/caves/second_outpost/tunnel
	name = "Transit Tunnel Access"

/area/awaymission/caves/second_outpost/rest
	name = "Mining Outpost Echo Rest Area"

/area/awaymission/caves/second_outpost/researchcenter
	name = "Research Outpost Echo Research Center"

/area/awaymission/caves/second_outpost/researchcenter/dorm
	name = "Research Outpost Echo Research Center Dorms"

/area/awaymission/caves/second_outpost/researchcenter/work
	name = "Research Outpost Echo Research Center Offices"

/area/awaymission/caves/second_outpost/researchcenter/messhall
	name = "Research Outpost Echo Research Center Mess Hall"

/area/awaymission/caves/second_outpost/researchcenter/sitedirector
	name = "Research Outpost Echo Research Center Site Director's Office"

/area/awaymission/caves/second_outpost/researchcenter/engineering
	name = "Research Outpost Echo Research Center Life Support"

/area/awaymission/caves/second_outpost/researchcenter/maint
	name = "Research Outpost Echo Research Center Maintenance"


//Lore Papers n' Stuff

/obj/item/paper/crumpled/awaymissions/caves/unsafe_area
	info = "<center><b>WARNING</center></b><br><br><center>Majority of this area is considered 'unsafe' past this point. Theres an outpost directly south of here where you can get your bearing and travel further down if needed. Traveling in groups is HIGHLY advised, the shit out there can be extremely deadly if you're alone.</center>"

/obj/item/paper/fluff/awaymissions/caves/omega
	name = "Subject Omega Notes"
	info = "<b><center>Testing Notes</b></center><br><br><center>Subject appears unresponsive to most interactions, refusing to move away from the corners or face any scientists. Subject appears to move between the two back corners every observation. A strange humming can be heard from inside the cell, appears to be originating from the subject itself, further testing is necessary to confirm or deny this.</center>"

/obj/item/paper/fluff/awaymissions/caves/magma
	info = "<center> Mining is hell down here, you can feel the heat of the magma no matter how thick the suit is. Conditions are barely manageable as is, restless nights and horrid work conditions. The ore maybe rich down here, but we've already lost a few men to the faults shifting, god knows how much longer till it all just collapses down and consumes everyone with it.</center>"

/obj/item/paper/fluff/awaymissions/caves/work_notice
	name = "work notice"
	info = "<center><b>Survival Info For Miners</b></center><br><br><center>The caves are an unforgiving place, the only thing you'll have to traverse is the supplies in your locker and your own wit. Travel in packs when mining and try to shut down the monster dens before they overwhelm you. The job is dangerous but the haul is good, so remember this information and hopefully we'll all go home alive.</center>"

/obj/item/paper/fluff/awaymissions/caves/shipment_notice
	name = "shipment notice"
	info = "<center>We were supposed to get a shipment of these special laser rifles and a couple 'nades to help combat the wildlife down here, but it's been weeks since we last heard from the caravan carrying the shit down here. At this point we can only assume they fell victim to one of the monster nests or the dumbasses managed to trip into the lava. So much for that shipment, I guess.</center>"

/obj/item/paper/fluff/awaymissions/caves/safety_notice
	name = "safety notice"
	info = "<center>Some of the miners have gone to laying some mine traps among the lower levels of the mine to keep the monsters at bay.  This probably isn't the smartest idea in a cavern like this but the boys seem to get a chuckle out of every distant blast they hear go off, so I guess it works </center>"

/obj/item/paper/fluff/awaymissions/caves/shipment_receipt
	name = "Shipment Receipt"
	info = "<center><b>CARAVAN SERVICES</b></center><br><center><i>Quality service since 2205</i></center><br><br><center><b>SHIPMENT CONTENTS:</b></center><br><br>4 scattershot rifles<br>6 grenades<br>1 laser rifle<br>1 blowup doll"

/obj/item/paper/fluff/awaymissions/caves/mech_notice
	name = "NOTICE!! paper"
	info = "<center><b>NOTICE!!</center></b><br><br><center>Although you may seem indestructible in a mech, remember, THIS SHIT ISN'T LAVA PROOF!! The boys have already had to deal with loosing the last two to salvage because the dumbass thought he could just wade through the lower lakes like it was nothing. The fact he even managed to get back without being fused with what was left of the mech is a miracle in itself. They're built to be resistant against extreme heat, not heat PROOF!</center><br><br><i>Robotics Team</i>"
