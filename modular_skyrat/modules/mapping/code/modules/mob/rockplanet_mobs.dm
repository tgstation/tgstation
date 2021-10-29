/mob/living/simple_animal/hostile/netherworld/mine_mob
	faction = list("mining")

/mob/living/simple_animal/hostile/ooze/grapes/mine_mob
	faction = list("mining")

/mob/living/simple_animal/hostile/netherworld/migo/mine_mob
	faction = list("mining")

/mob/living/simple_animal/hostile/alien/mine_mob
	faction = list("mining")

/*
//Similar to Zombies, but less green and infection-oriented. Reference to X-COM 2's Lost
/mob/living/simple_animal/hostile/lost_husk
	name = "Lost Husk"
	desc = "Reanimated by forces beyond our understanding, the Lost now wander the wastes they once called home."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_UNDEAD
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 1
	speak = list("Rrrrgh...","Mggghhn...","Hhhlp...","Grragh!!")
	speak_emote = list("groans","growls","cries","moans","howls")
	emote_hear = list("lets out a long moan.","wails out in pain!","groans.")
	emote_see = list("shambles around","stumbles","wanders")
	maxHealth = 75
	health = 75
	stat_attack = HARD_CRIT	//Not quite killing people. Just kicking their shit in.
	harm_intent_damage = 5
	melee_damage_lower = 16
	melee_damage_upper = 19
	attack_verb_continuous = "bites"
	attack_verb_simple = "scratches"
	attack_sound = 'sound/hallucinations/growl3.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)	//Needs just a biiit of oxygen
	status_flags = CANPUSH
	del_on_death = 1
	var/obj/effect/mob_spawn/human/corpse/charredskeleton/corpse

/mob/living/simple_animal/hostile/lost_husk/drop_loot()	//chance the corpse drops, usually just dusts
	. = ..()
	if(pick(1-10) == 1)
		corpse = new(src)
		corpse.outfit = pick(/datum/outfit/Lost_Husk_A, /datum/outfit/Lost_Husk_B, /datum/outfit/Lost_Husk_C) //I wish I could randomly select from uniform options but I guess this works
		corpse.forceMove(drop_location())
		corpse.create()
	else
		dust()
		return

//Also the Lost Husk's outfit is raggy clothes :)

/datum/outfit/Lost_Husk_A
	name = "Lost Husk A"
	uniform = /obj/item/clothing/under/pants/jeanripped
	r_pocket = /obj/item/storage/wallet/random

/datum/outfit/Lost_Husk_B
	name = "Lost Husk B"
	uniform = /obj/item/clothing/under/rank/civilian/linen
	l_pocket = /obj/item/storage/wallet/random
	r_pocket = /obj/item/flashlight/glowstick

/datum/outfit/Lost_Husk_C
	name = "Lost Husk C"
	uniform = /obj/item/clothing/under/pants/khaki
	suit = /obj/item/clothing/suit/hawaiian_green
	l_pocket = /obj/item/lighter/greyscale
	r_pocket = /obj/item/phone //What? There's no proper cellphones in the code, so i get to improvise. Its funny. Laugh.
*/
