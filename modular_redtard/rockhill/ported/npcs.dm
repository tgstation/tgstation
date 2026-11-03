/mob/living/carbon/human/species/dwarfskeleton/ambush
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("dundead")
	race = /datum/species/skeleton
	rogue_npc_look = list("name" = "Dwarven Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/dwarfskeleton)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_BREADY, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_MEDIUMARMOR, TRAIT_HEAVYARMOR, TRAIT_CRITICAL_WEAKNESS, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/dwarfskeleton/ambush/knight
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("dundead")
	race = /datum/species/skeleton
	rogue_npc_look = list("name" = "Dwarven Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/dwarfskeleton/ambush/knight)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_BREADY, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_MEDIUMARMOR, TRAIT_HEAVYARMOR, TRAIT_CRITICAL_WEAKNESS, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/elf/dark/drowraider
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("drow")
	race = /datum/species/rogue_drow
	rogue_npc_look = list("random_sex" = TRUE, "skin" = "#5F5F70", "eyes" = "#FFBF00", "hair_color" = "#DDDDDD", "hair_m" = list("Ponytail (Witcher)", "Dave", "Emo (Ratwood)", "Sabitsuki", "Sabitsuki (Ponytail)"), "hair_f" = list("Hime Cut (Ratwood)", "Ponytail (Country Alt)", "Stacy", "Kusanagi (Alt)"), "names_f" = "modular_redtard/rockhill/strings/names/elfdf.txt", "names_m" = "modular_redtard/rockhill/strings/names/elfdm.txt")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/human/species/elf/dark/drowraider)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_LEECHIMMUNE, TRAIT_BREADY, TRAIT_HEAVYARMOR)

/mob/living/carbon/human/species/goblin/cave
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/cave
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/moon
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/moon
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc
	rogue_npc_rude = TRUE
	rogue_npc_jump_chance = 60
	rogue_npc_jump_distance = 3
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/ambush
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/ambush/cave
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/cave
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/ambush/hell
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/hell
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/ambush/moon
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/moon
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/ambush/sea
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/sea
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/cave
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/cave
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/hell
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/hell
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/goblin/npc/moon
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("orcs")
	race = /datum/species/rogue_goblin/moon
	use_random_name = FALSE
	rogue_npc_look = list("name" = "goblin")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/goblin)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_CRITICAL_WEAKNESS, TRAIT_BREADY, TRAIT_LEECHIMMUNE, TRAIT_TOXIMMUNE)

/mob/living/carbon/human/species/human/northern/bog_deserters
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	faction = list("viking", "station")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/human/northern/bog_deserters)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_LEECHIMMUNE, TRAIT_BREADY, TRAIT_MEDIUMARMOR, TRAIT_KNEESTINGER_IMMUNITY)

/mob/living/carbon/human/species/human/northern/bum
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("bums", "station")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/vagrantnpc)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_LEECHIMMUNE, TRAIT_BREADY)

/mob/living/carbon/human/species/human/northern/bum/ambush
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	faction = list("bums", "station")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/vagrantnpc)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_LEECHIMMUNE, TRAIT_BREADY)

/mob/living/carbon/human/species/human/northern/highwayman
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_flee_in_pain = TRUE
	faction = list("viking", "station")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/human/species/human/northern/highwayman)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_LEECHIMMUNE, TRAIT_BREADY, TRAIT_MEDIUMARMOR)

/mob/living/carbon/human/species/npc/deadite
	rogue_npc_jump_chance = 0
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	rogue_def_intent = ROGUE_INTENT_DODGE
	race = /datum/species/zombie
	rogue_npc_look = list("random_sex" = TRUE)
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/deadite)

/mob/living/carbon/human/species/orc/npc/berserker
	rogue_npc_rude = TRUE
	rogue_npc_jump_chance = 25
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("orcs", "station")
	race = /datum/species/rogue_orc
	use_random_name = FALSE
	rogue_npc_look = list("random_sex" = TRUE, "skin" = "#50715C", "eyes" = "#FF0000", "hair_color" = "#31302E", "hair_m" = list("Ponytail (Witcher)", "Braid (Low) (Ratwood)"), "hair_f" = list("Braid (Low) (Ratwood)", "Ponytail (Country Alt)"), "beards" = list("Beard (Viking)", "Beard (Manly)", "Beard (Long) (Ratwood)"), "names_f" = "modular_redtard/rockhill/strings/names/halforcf.txt", "names_m" = "modular_redtard/rockhill/strings/names/halforcm.txt")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/orc/npc/berserker)
	rogue_npc_traits = list(TRAIT_LEECHIMMUNE, TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_BREADY)

/mob/living/carbon/human/species/orc/npc/footsoldier
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("orcs", "station")
	race = /datum/species/rogue_orc
	use_random_name = FALSE
	rogue_npc_look = list("random_sex" = TRUE, "skin" = "#50715C", "eyes" = "#FF0000", "hair_color" = "#31302E", "hair_m" = list("Ponytail (Witcher)", "Braid (Low) (Ratwood)"), "hair_f" = list("Braid (Low) (Ratwood)", "Ponytail (Country Alt)"), "beards" = list("Beard (Viking)", "Beard (Manly)", "Beard (Long) (Ratwood)"), "names_f" = "modular_redtard/rockhill/strings/names/halforcf.txt", "names_m" = "modular_redtard/rockhill/strings/names/halforcm.txt")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/orc/npc/footsoldier)
	rogue_npc_traits = list(TRAIT_LEECHIMMUNE, TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_BREADY)

/mob/living/carbon/human/species/orc/npc/marauder
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("orcs", "station")
	race = /datum/species/rogue_orc
	use_random_name = FALSE
	rogue_npc_look = list("random_sex" = TRUE, "skin" = "#50715C", "eyes" = "#FF0000", "hair_color" = "#31302E", "hair_m" = list("Ponytail (Witcher)", "Braid (Low) (Ratwood)"), "hair_f" = list("Braid (Low) (Ratwood)", "Ponytail (Country Alt)"), "beards" = list("Beard (Viking)", "Beard (Manly)", "Beard (Long) (Ratwood)"), "names_f" = "modular_redtard/rockhill/strings/names/halforcf.txt", "names_m" = "modular_redtard/rockhill/strings/names/halforcm.txt")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/orc/npc/marauder)
	rogue_npc_traits = list(TRAIT_LEECHIMMUNE, TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_BREADY)

/mob/living/carbon/human/species/orc/npc/warlord
	rogue_npc_rude = TRUE
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("orcs", "station")
	race = /datum/species/rogue_orc
	use_random_name = FALSE
	rogue_npc_look = list("random_sex" = TRUE, "skin" = "#50715C", "eyes" = "#FF0000", "hair_color" = "#31302E", "hair_m" = list("Ponytail (Witcher)", "Braid (Low) (Ratwood)"), "hair_f" = list("Braid (Low) (Ratwood)", "Ponytail (Country Alt)"), "beards" = list("Beard (Viking)", "Beard (Manly)", "Beard (Long) (Ratwood)"), "names_f" = "modular_redtard/rockhill/strings/names/halforcf.txt", "names_m" = "modular_redtard/rockhill/strings/names/halforcm.txt")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/orc/npc/warlord)
	rogue_npc_traits = list(TRAIT_LEECHIMMUNE, TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_BREADY)

/mob/living/carbon/human/species/skeleton/npc
	rogue_npc_rude = TRUE
	rogue_npc_jump_chance = 0
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/skeleton)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/bogguard
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/bogguard/master
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard/master)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/cultist
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/cultist)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/dungeon
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/npc/skeleton)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/easy
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/easy)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/hard
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/hard)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/hard/noequip
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/hard_skills_only)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/hardspread
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/hard, /datum/outfit/job/roguetown/skeleton/npc/medium, /datum/outfit/job/roguetown/skeleton/npc/pirate, /datum/outfit/job/roguetown/skeleton/npc/hard)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/hardspread/lich
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("lich", "undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/hard, /datum/outfit/job/roguetown/skeleton/npc/medium, /datum/outfit/job/roguetown/skeleton/npc/pirate, /datum/outfit/job/roguetown/skeleton/npc/hard)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/medium
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/medium)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/medium/noequip
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/medium_skills_only)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/mediumspread
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/supereasy, /datum/outfit/job/roguetown/skeleton/npc/easy, /datum/outfit/job/roguetown/skeleton/npc/medium, /datum/outfit/job/roguetown/skeleton/npc/hard)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/miner
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/miner)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/no_equipment
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)
	rogue_npc_outfits = null

/mob/living/carbon/human/species/skeleton/npc/pirate
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/pirate)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/rockhill
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/rockhill)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/mob/living/carbon/human/species/skeleton/npc/supereasy
	rogue_npc = TRUE
	rogue_aggressive = TRUE
	faction = list("undead")
	use_random_name = FALSE
	rogue_npc_look = list("name" = "Skeleton")
	rogue_npc_outfits = list(/datum/outfit/job/roguetown/skeleton/npc/supereasy)
	rogue_npc_traits = list(TRAIT_NOMOOD, TRAIT_BREADY, TRAIT_NO_VOICEPACK_OVERRIDE, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_NOBREATH, TRAIT_NOPAIN, TRAIT_TOXIMMUNE, TRAIT_LEECHIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_HEAVYARMOR, TRAIT_SILVER_WEAK, TRAIT_EXTREME_TEMPERATURE_IMMUNE)

/datum/outfit/job/roguetown/deadite

/datum/outfit/job/roguetown/dwarfskeleton
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton

/datum/outfit/job/roguetown/dwarfskeleton/ambush
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton/ambush

/datum/outfit/job/roguetown/dwarfskeleton/ambush/knight
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton/ambush/knight

/datum/outfit/job/roguetown/human/northern/bog_deserters
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/human/northern/bog_deserters
	rogue_traits = list(TRAIT_MEDIUMARMOR, TRAIT_HEAVYARMOR, TRAIT_STEELHEARTED)

/datum/outfit/job/roguetown/human/species/elf/dark/drowraider
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/human/species/elf/dark/drowraider

/datum/outfit/job/roguetown/human/species/human/northern/highwayman
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/human/species/human/northern/highwayman

/datum/outfit/job/roguetown/npc/goblin
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/npc/goblin

/datum/outfit/job/roguetown/npc/skeleton

/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/npc/skeleton/npc/bogguard
	rogue_traits = list(TRAIT_MEDIUMARMOR)

/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard/master
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/npc/skeleton/npc/bogguard/master
	rogue_traits = list(TRAIT_MEDIUMARMOR, TRAIT_HEAVYARMOR)

/datum/outfit/job/roguetown/orc/npc
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/orc/npc

/datum/outfit/job/roguetown/orc/npc/berserker
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/orc/npc/berserker
	rogue_traits = list(TRAIT_NOPAINSTUN, TRAIT_CRITICAL_RESISTANCE)

/datum/outfit/job/roguetown/orc/npc/footsoldier
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/orc/npc/footsoldier

/datum/outfit/job/roguetown/orc/npc/marauder
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/orc/npc/marauder
	rogue_traits = list(TRAIT_MEDIUMARMOR)

/datum/outfit/job/roguetown/orc/npc/warlord
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/orc/npc/warlord
	rogue_traits = list(TRAIT_HEAVYARMOR)

/datum/outfit/job/roguetown/skeleton/npc/cultist
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/cultist

/datum/outfit/job/roguetown/skeleton/npc/easy
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/easy

/datum/outfit/job/roguetown/skeleton/npc/hard
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/hard

/datum/outfit/job/roguetown/skeleton/npc/hard_skills_only
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/hard_skills_only

/datum/outfit/job/roguetown/skeleton/npc/medium
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/medium

/datum/outfit/job/roguetown/skeleton/npc/medium_skills_only
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/medium_skills_only

/datum/outfit/job/roguetown/skeleton/npc/miner
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/miner

/datum/outfit/job/roguetown/skeleton/npc/pirate
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/pirate

/datum/outfit/job/roguetown/skeleton/npc/rockhill
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/rockhill

/datum/outfit/job/roguetown/skeleton/npc/supereasy
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/supereasy

/datum/outfit/job/roguetown/vagrantnpc
	rogue_sheet = /datum/attribute_holder/sheet/rockhill_npc/vagrantnpc

/datum/outfit/job/roguetown/deadite/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	head = null
	r_pocket = null
	l_pocket = null
	if(prob(30))
		cloak = /obj/item/clothing/cloak/raincloak/brown
	else
		cloak = null
	if(prob(10))
		gloves = /obj/item/clothing/gloves/roguetown/fingerless
	else
		gloves = null
	suit = null
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant
	if(prob(50))
		uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	r_hand = null
	l_hand = null

/datum/outfit/job/roguetown/dwarfskeleton/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/black
	if(prob(50))
		cloak = /obj/item/clothing/cloak/raincloak/mortus
	wrists = /obj/item/clothing/wrists/roguetown/bracers/copper
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/copper
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	if(prob(60))
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
		if(prob(10))
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	if(prob(40))
		uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	head = /obj/item/clothing/head/roguetown/helmet
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/helmet/horned
	neck = /obj/item/clothing/neck/roguetown/gorget
	mask = /obj/item/clothing/mask/rogue/facemask
	if(prob(40))
		mask = /obj/item/clothing/mask/rogue/facemask/copper
		if(prob(10))
			mask = /obj/item/clothing/mask/rogue/facemask/steel
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	l_hand = /obj/item/rogueweapon/spear/bronze
	if(prob(50))
		l_hand = /obj/item/rogueweapon/sword/short/gladius
		r_hand = /obj/item/rogueweapon/shield/wood
		if(prob(20))
			gloves = /obj/item/clothing/gloves/roguetown/knuckles/bronze

/datum/outfit/job/roguetown/dwarfskeleton/ambush/knight/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	uniform = /obj/item/clothing/under/roguetown/platelegs
	cloak = /obj/item/clothing/cloak/stabard/dungeon
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather
	l_hand = /obj/item/rogueweapon/greataxe
	r_hand = null

/datum/outfit/job/roguetown/human/northern/bog_deserters/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	add_random_deserter_cloak(H)
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	belt = /obj/item/storage/belt/rogue/leather
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	add_random_deserter_weapon(H)
	add_random_deserter_beltl_stuff(H)
	add_random_deserter_beltr_stuff(H)

/datum/outfit/job/roguetown/human/species/elf/dark/drowraider/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	suit = /obj/item/clothing/suit/roguetown/armor/plate/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	if(prob(50))
		mask = /obj/item/clothing/mask/rogue/ragmask/black
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored/iron
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	neck = /obj/item/clothing/neck/roguetown/bevor/iron
	if(prob(50))
		neck = /obj/item/clothing/neck/roguetown/gorget
	belt = /obj/item/storage/belt/rogue/leather/black
	if(prob(5))
		l_pocket = /obj/item/storage/belt/rogue/pouch/medicine
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = null
		if(51 to 85)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(86 to 95)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure/lucky
	if(prob(60))
		ring = /obj/item/clothing/ring/silver
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	if(prob(50))
		r_hand = /obj/item/rogueweapon/sword/falx
		l_hand = /obj/item/rogueweapon/shield/tower
	else
		r_hand = /obj/item/rogueweapon/halberd/bardiche

/datum/outfit/job/roguetown/human/species/human/northern/highwayman/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(50))
		mask = /obj/item/clothing/mask/rogue/ragmask/red
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/helmet/leather
	if(prob(30))
		head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
	if(prob(70))
		neck = /obj/item/clothing/neck/roguetown/coif
	gloves = /obj/item/clothing/gloves/roguetown/leather
	belt = /obj/item/storage/belt/rogue/leather
	if(prob(5))
		l_pocket = /obj/item/storage/belt/rogue/pouch/medicine
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(51 to 85)
			r_pocket = null
		if(86 to 95)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure/lucky
	if(prob(10))
		ring = /obj/item/clothing/ring/gold
	if(prob(50))
		r_hand = /obj/item/rogueweapon/sword/short/iron
	else
		r_hand = /obj/item/rogueweapon/mace/cudgel
	if(prob(10))
		r_hand = /obj/item/rogueweapon/sword/falchion/militia
	if(prob(10))
		r_hand = /obj/item/rogueweapon/sword/short/messer/iron
	if(prob(10))
		r_hand = /obj/item/rogueweapon/stoneaxe/handaxe
	if(prob(20))
		r_hand = /obj/item/rogueweapon/pick/militia
	if(prob(25))
		l_hand = /obj/item/rogueweapon/shield/wood
	if(prob(10))
		l_hand = /obj/item/rogueweapon/huntingknife/idagger
		l_hand = /obj/item/rogueweapon/huntingknife/idagger

/datum/outfit/job/roguetown/npc/goblin/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	var/loadout = rand(1,5)
	switch(loadout)
		if(1)
			r_hand = /obj/item/rogueweapon/spear/stone
			suit = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
		if(2)
			r_hand = /obj/item/rogueweapon/stoneaxe
			suit = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
		if(3)
			r_hand = /obj/item/rogueweapon/mace/woodclub
			suit = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
			if(prob(10))
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
		if(4)
			if(prob(50))
				r_hand = /obj/item/rogueweapon/sword/iron
			else
				r_hand = /obj/item/rogueweapon/mace/spiked
			if(prob(30))
				l_hand = /obj/item/rogueweapon/shield/wood
			if(prob(23))
				r_hand = /obj/item/rogueweapon/huntingknife/stoneknife
				l_hand = /obj/item/rogueweapon/huntingknife/stoneknife
			suit = /obj/item/clothing/suit/roguetown/armor/leather/goblin
			if(prob(80))
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
		if(5)
			if(prob(30))
				suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron/goblin
			else
				suit = /obj/item/clothing/suit/roguetown/armor/leather/goblin
			if(prob(80))
				head = /obj/item/clothing/head/roguetown/helmet/goblin
			else
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
			if(prob(50))
				r_hand = /obj/item/rogueweapon/sword/iron
			else
				r_hand = /obj/item/rogueweapon/mace/spiked
			if(prob(20))
				r_hand = /obj/item/rogueweapon/flail
				l_hand = /obj/item/rogueweapon/shield/wood

/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(prob(50))
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(10))
		suit = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
		if(prob(15))
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			if(prob(15))
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	if(prob(50))
		uniform = /obj/item/clothing/under/roguetown/tights/vagrant
		if(prob(25))
			uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
			if(prob(25))
				uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	if(prob(50))
		head = /obj/item/clothing/neck/roguetown/coif
		if(prob(30))
			head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	if(prob(50))
		neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	if(prob(50))
		cloak = /obj/item/clothing/cloak/stabard/bog
	switch(rand(1, 3))
		if(1)
			r_hand = /obj/item/rogueweapon/sword/iron
		if(2)
			r_hand = /obj/item/rogueweapon/spear
		if(3)
			r_hand = /obj/item/rogueweapon/mace

/datum/outfit/job/roguetown/npc/skeleton/npc/bogguard/master/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull
	gloves = /obj/item/clothing/gloves/roguetown/plate
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	cloak = /obj/item/clothing/cloak/stabard/bog
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather
	r_hand = /obj/item/rogueweapon/halberd
	return

/datum/outfit/job/roguetown/orc/npc/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	suit = /obj/item/clothing/suit/roguetown/armor/leather/hide
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	head = /obj/item/clothing/head/roguetown/helmet/leather
	shoes = /obj/item/clothing/shoes/roguetown/gladiator
	r_hand = /obj/item/rogueweapon/stoneaxe/boneaxe
	l_hand = /obj/item/rogueweapon/shield/wood
	belt = /obj/item/storage/belt/rogue/leather/rope
	if(prob(5))
		l_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = null
		if(51 to 95)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/gold

/datum/outfit/job/roguetown/orc/npc/berserker/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	suit = /obj/item/clothing/suit/roguetown/armor/leather/hide
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	head = /obj/item/clothing/head/roguetown/helmet/leather
	neck = /obj/item/clothing/neck/roguetown/coif
	mask = /obj/item/clothing/mask/rogue/facemask
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/rope
	if(prob(5))
		l_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(51 to 95)
			r_pocket = null
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/gold
	var/wepchoice = rand(1, 2)
	switch(wepchoice)
		if(1)
			l_hand = /obj/item/rogueweapon/huntingknife/idagger
		if(2)
			l_hand = /obj/item/rogueweapon/pick/militia

/datum/outfit/job/roguetown/orc/npc/footsoldier/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(50))
		suit = /obj/item/clothing/suit/roguetown/armor/leather/hide
	else
		suit = /obj/item/clothing/suit/roguetown/armor/leather
	uniform = /obj/item/clothing/under/roguetown/loincloth
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/helmet/leather
	shoes = /obj/item/clothing/shoes/roguetown/gladiator
	var/wepchoice = rand(1, 3)
	switch(wepchoice)
		if(1)
			l_hand = /obj/item/rogueweapon/stoneaxe/boneaxe
		if(2)
			l_hand = /obj/item/rogueweapon/spear/bonespear
			r_hand = /obj/item/rogueweapon/shield/wood
		if(3)
			l_hand = /obj/item/rogueweapon/mace/cudgel/copper
	belt = /obj/item/storage/belt/rogue/leather/rope
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(51 to 95)
			r_pocket = null
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure

/datum/outfit/job/roguetown/orc/npc/marauder/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	neck = /obj/item/clothing/neck/roguetown/coif
	head = /obj/item/clothing/head/roguetown/helmet/leather
	mask = /obj/item/clothing/mask/rogue/facemask
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	var/wepchoice = rand(1, 5)
	switch(wepchoice)
		if(1)
			l_hand = /obj/item/rogueweapon/spear
		if(2)
			l_hand = /obj/item/rogueweapon/sword/short/falchion
			r_hand = /obj/item/rogueweapon/shield/wood
		if(3)
			l_hand = /obj/item/rogueweapon/mace
		if(4)
			l_hand = /obj/item/rogueweapon/greataxe
		if(5)
			l_hand = /obj/item/rogueweapon/pick/militia
	belt = /obj/item/storage/belt/rogue/leather/rope
	if(prob(5))
		l_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(1 to 95)
			r_pocket = null
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/gold

/datum/outfit/job/roguetown/orc/npc/warlord/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	head = /obj/item/clothing/head/roguetown/helmet/skullcap
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	mask = /obj/item/clothing/mask/rogue/facemask
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	if(prob(30))
		l_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
	switch(rand(1, 100))
		if(1 to 50)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(51 to 95)
			r_pocket = null
		if(96 to 100)
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(50))
		ring = /obj/item/clothing/ring/gold
	var/wepchoice = rand(1, 6)
	switch(wepchoice)
		if(1)
			l_hand = /obj/item/rogueweapon/halberd/bardiche
		if(2)
			l_hand = /obj/item/rogueweapon/greatsword/zwei
		if(3)
			l_hand = /obj/item/rogueweapon/greataxe
		if(4)
			l_hand = /obj/item/rogueweapon/eaglebeak/lucerne
		if(5)
			l_hand = /obj/item/rogueweapon/mace/goden
		if(6)
			l_hand = /obj/item/rogueweapon/sword/short/falchion
			r_hand = /obj/item/rogueweapon/sword/short/falchion

/datum/outfit/job/roguetown/skeleton/npc/cultist/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(prob(80))
		suit = /obj/item/clothing/suit/roguetown/shirt/robe/noc
	else
		suit = /obj/item/clothing/suit/roguetown/shirt/robe/black
	wrists = /obj/item/clothing/wrists/roguetown/nocwrappings
	if(prob(20))
		head = /obj/item/clothing/head/roguetown/nochood
	if(prob(30))
		head = /obj/item/clothing/head/roguetown/roguehood/black
	if(prob(50))
		uniform = /obj/item/clothing/under/roguetown/tights/random
	else
		uniform = /obj/item/clothing/under/roguetown/loincloth
	if(prob(20))
		belt = /obj/item/storage/belt/rogue/leather/rope
		if(prob(20))
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
		else
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit
	var/weapon_choice = rand(1, 4)
	switch(weapon_choice)
		if(1)
			r_hand = /obj/item/rogueweapon/sickle/decrepit
		if(2)
			r_hand = /obj/item/rogueweapon/woodstaff
		if(3)
			r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/ancient/decrepit
		if(4)
			r_hand = /obj/item/rogueweapon/mace/woodclub

/datum/outfit/job/roguetown/skeleton/npc/easy/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/ancient/decrepit
	uniform = /obj/item/clothing/under/roguetown/chainlegs/kilt/ancient/decrepit
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/ancient/decrepit
	if(prob(20))
		belt = /obj/item/storage/belt/rogue/leather/rope
		switch(rand(1, 100))
			if(1 to 50)
				r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
			if(51 to 95)
				r_pocket = null
			if(96 to 100)
				r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit
	var/weapon_choice = rand(1, 4)
	switch(weapon_choice)
		if(1)
			r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/steel/ancient/decrepit
		if(2)
			r_hand = /obj/item/rogueweapon/sword/short/ancient/decrepit
		if(3)
			r_hand = /obj/item/rogueweapon/spear/ancient/decrepit
		if(4)
			r_hand = /obj/item/rogueweapon/mace/steel/ancient/decrepit

/datum/outfit/job/roguetown/skeleton/npc/hard/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	cloak = /obj/item/clothing/cloak/tabard/blkknight
	head = /obj/item/clothing/head/roguetown/helmet/heavy/guard/ancient/decrepit
	suit = /obj/item/clothing/suit/roguetown/armor/plate/ancient/decrepit
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ancient/decrepit
	wrists = /obj/item/clothing/wrists/roguetown/bracers/ancient/decrepit
	uniform = /obj/item/clothing/under/roguetown/platelegs/ancient/decrepit
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/ancient/decrepit
	neck = /obj/item/clothing/neck/roguetown/gorget/steel/ancient/decrepit
	gloves = /obj/item/clothing/gloves/roguetown/plate/ancient/decrepit
	belt = /obj/item/storage/belt/rogue/leather
	if(prob(15))
		l_pocket = /obj/item/repair_kit/metal/bad
	if(prob(50))
		r_hand = /obj/item/rogueweapon/greatsword/ancient/decrepit
	else
		r_hand = /obj/item/rogueweapon/mace/goden/steel/ancient/decrepit
	if(prob(60))
		belt = /obj/item/storage/belt/rogue/leather/rope
		switch(rand(1, 100))
			if(1 to 50)
				r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
			if(51 to 95)
				r_pocket = null
			if(96 to 100)
				r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit

/datum/outfit/job/roguetown/skeleton/npc/medium/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	head = /obj/item/clothing/head/roguetown/helmet/heavy/ancient/decrepit
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/ancient/decrepit
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/ancient/decrepit
	wrists = /obj/item/clothing/wrists/roguetown/bracers/ancient/decrepit
	uniform = /obj/item/clothing/under/roguetown/chainlegs/kilt/ancient/decrepit
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/ancient/decrepit
	neck = /obj/item/clothing/neck/roguetown/chaincoif/ancient/decrepit
	gloves = /obj/item/clothing/gloves/roguetown/chain/ancient/decrepit
	belt = /obj/item/storage/belt/rogue/leather
	if(prob(15))
		l_pocket = /obj/item/repair_kit/bad
	if(prob(30))
		switch(rand(1, 100))
			if(1 to 50)
				r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
			if(51 to 95)
				r_pocket = null
			if(96 to 100)
				r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit
	if(prob(33))
		l_hand = /obj/item/rogueweapon/shield/tower/metal/ancient/decrepit
	if(prob(33))
		r_hand = /obj/item/rogueweapon/spear/ancient/decrepit
	else if(prob(33))
		r_hand = /obj/item/rogueweapon/sword/short/gladius/ancient/decrepit
	else
		r_hand = /obj/item/rogueweapon/flail/sflail/ancient/decrepit

/datum/outfit/job/roguetown/skeleton/npc/miner/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	uniform = /obj/item/clothing/under/roguetown/loincloth/brown
	if(prob(40))
		uniform = /obj/item/clothing/under/roguetown/trou
	if(prob(25))
		head = /obj/item/clothing/head/roguetown/helmet
	if(prob(25))
		head = /obj/item/clothing/head/roguetown/helmet/horned
	neck = /obj/item/clothing/neck/roguetown/collar/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	r_hand = /obj/item/rogueweapon/pick/decrepit
	if(prob(20))
		r_hand = /obj/item/rogueweapon/shovel/decrepit
	if(prob(40))
		belt = /obj/item/storage/belt/rogue/leather/rope
		if(prob(10))
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
		else
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit

/datum/outfit/job/roguetown/skeleton/npc/pirate/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/tricorn
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/ancient/decrepit
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/ancient/decrepit
	uniform = /obj/item/clothing/under/roguetown/tights/sailor
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/ancient/decrepit
	if(prob(50))
		r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/ancient/decrepit
	else
		gloves = /obj/item/clothing/gloves/roguetown/knuckles/decrepit
	if(prob(20))
		belt = /obj/item/storage/belt/rogue/leather/rope
		switch(rand(1, 100))
			if(1 to 50)
				r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
			if(51 to 95)
				r_pocket = null
			if(96 to 100)
				r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit

/datum/outfit/job/roguetown/skeleton/npc/rockhill/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(prob(10))
		head = /obj/item/clothing/head/roguetown/helmet/heavy/ancient/decrepit
	if(prob(10))
		suit = /obj/item/clothing/suit/roguetown/armor/plate/half/ancient/decrepit
	if(prob(25))
		shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/ancient/decrepit
	if(prob(90))
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(90))
		uniform = /obj/item/clothing/under/roguetown/trou/leather
	if(prob(80))
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	if(prob(70))
		neck = /obj/item/clothing/neck/roguetown/coif
	if(prob(70))
		gloves = /obj/item/clothing/gloves/roguetown/chain/ancient/decrepit
	if(prob(20))
		l_hand = /obj/item/rogueweapon/shield/tower/metal/ancient/decrepit
	if(prob(25))
		r_hand = /obj/item/rogueweapon/spear/ancient/decrepit
	else if(prob(25))
		r_hand = /obj/item/rogueweapon/mace/steel/ancient/decrepit
	else if(prob(25))
		r_hand = /obj/item/rogueweapon/sword/short/ancient/decrepit
	else
		r_hand = /obj/item/rogueweapon/flail/sflail/ancient/decrepit
	if(prob(40))
		belt = /obj/item/storage/belt/rogue/leather/rope
		if(prob(10))
			r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
		else
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit

/datum/outfit/job/roguetown/skeleton/npc/supereasy/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/shirt/rags
	else
		shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	if(prob(50))
		uniform = /obj/item/clothing/under/roguetown/tights/random
	else
		uniform = /obj/item/clothing/under/roguetown/loincloth
	if(prob(5))
		belt = /obj/item/storage/belt/rogue/leather/rope
		switch(rand(1, 100))
			if(1 to 50)
				r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
			if(51 to 95)
				r_pocket = null
			if(96 to 100)
				r_pocket = /obj/item/storage/belt/rogue/pouch/treasure
	if(prob(5))
		ring = /obj/item/clothing/ring/decrepit
	var/weapon_choice = rand(1, 4)
	switch(weapon_choice)
		if(1)
			r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/steel/ancient/decrepit
		if(2)
			r_hand = /obj/item/rogueweapon/sword/short/ancient/decrepit
		if(3)
			r_hand = /obj/item/rogueweapon/spear/ancient/decrepit
		if(4)
			r_hand = /obj/item/rogueweapon/mace/steel/ancient/decrepit

/datum/outfit/job/roguetown/vagrantnpc/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant
	if(prob(50))
		uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	if(prob(20))
		head = /obj/item/clothing/head/roguetown/knitcap
	if(prob(10))
		cloak = /obj/item/clothing/cloak/raincloak/brown
	if(prob(10))
		gloves = /obj/item/clothing/gloves/roguetown/fingerless
	if(prob(33))
		cloak = /obj/item/clothing/cloak/raincloak/brown
		gloves = /obj/item/clothing/gloves/roguetown/fingerless
	if(prob(5))
		r_hand = /obj/item/rogueweapon/mace/woodclub
	else if(prob(5))
		r_hand = /obj/item/rogueweapon/huntingknife/stoneknife
	else if(prob(5))
		r_hand = /obj/item/rogueweapon/woodstaff
	else if(prob(5))
		r_hand = /obj/item/rogueweapon/mace/wsword

/datum/outfit/job/roguetown/human/northern/bog_deserters/proc/add_random_deserter_beltl_stuff(mob/living/carbon/human/H)
	var/add_random_deserter_beltl_stuff = rand(1,9)
	switch(add_random_deserter_beltl_stuff)
		if(1)
			l_pocket = /obj/item/storage/belt/rogue/pouch/food
		if(2)
			l_pocket = /obj/item/storage/belt/rogue/pouch/medicine
		if(3)
			l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(4)
			l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
		if(5)
			l_pocket = /obj/item/reagent_containers/glass/bottle/waterskin
		if(6)
			l_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
		if(7)
			l_pocket = /obj/item/rogueweapon/scabbard/sheath
		if(8)
			l_pocket = /obj/item/storage/belt/rogue/pouch/treasure/lucky
		if(9)
			l_pocket = /obj/item/storage/belt/rogue/pouch/treasure

/datum/outfit/job/roguetown/human/northern/bog_deserters/proc/add_random_deserter_beltr_stuff(mob/living/carbon/human/H)
	var/add_random_deserter_beltr_stuff = rand(1,7)
	switch(add_random_deserter_beltr_stuff)
		if(1)
			r_pocket = /obj/item/storage/belt/rogue/pouch/food
		if(2)
			r_pocket = /obj/item/storage/belt/rogue/pouch/medicine
		if(3)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
		if(4)
			r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
		if(5)
			r_pocket = /obj/item/reagent_containers/glass/bottle/waterskin
		if(6)
			r_pocket = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
		if(7)
			r_pocket = /obj/item/rogueweapon/scabbard/sword

/datum/outfit/job/roguetown/human/northern/bog_deserters/proc/add_random_deserter_cloak(mob/living/carbon/human/H)
	var/random_deserter_cloak = rand(1,4)
	switch(random_deserter_cloak)
		if(1)
			cloak = /obj/item/clothing/cloak/stabard/bog
		if(2)
			cloak = /obj/item/clothing/cloak/stabard/dungeon
		if(3)
			cloak = /obj/item/clothing/suit/roguetown/armor/longcoat/brown

/datum/outfit/job/roguetown/human/northern/bog_deserters/proc/add_random_deserter_weapon(mob/living/carbon/human/H)
	var/random_deserter_weapon = rand(1,3)
	switch(random_deserter_weapon)
		if(1)
			r_hand = /obj/item/rogueweapon/sword/iron
			l_hand = /obj/item/rogueweapon/shield/heater
		if(2)
			r_hand = /obj/item/rogueweapon/spear
		if(3)
			r_hand = /obj/item/rogueweapon/stoneaxe/woodcut

/datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton/ambush
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/dwarfskeleton/ambush/knight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 4,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 6,
		ROGUE_STAT_WILLPOWER = 4,
		/datum/attribute/skill/combat/axes = 60,
		/datum/attribute/skill/combat/maces = 60,
		/datum/attribute/skill/combat/polearms = 60,
		/datum/attribute/skill/combat/shields = 60,
		/datum/attribute/skill/combat/swords = 60,
		/datum/attribute/skill/combat/unarmed = 60,
		/datum/attribute/skill/combat/wrestling = 60,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/attribute_holder/sheet/rockhill_npc/human/northern/bog_deserters
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/human/species/elf/dark/drowraider
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 4,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/human/species/human/northern/highwayman
	raw_attribute_list = list(
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/npc/goblin
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -6,
		ROGUE_STAT_SPEED = 4,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/npc/skeleton/npc/bogguard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -6,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/npc/skeleton/npc/bogguard/master
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_STRENGTH = 8,
		ROGUE_STAT_WILLPOWER = 6,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		)

/datum/attribute_holder/sheet/rockhill_npc/orc/npc
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 5,
		ROGUE_STAT_INTELLIGENCE = -4,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 6,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/orc/npc/berserker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/orc/npc/footsoldier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = -6,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/orc/npc/marauder
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -6,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/orc/npc/warlord
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_STRENGTH = 4,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/cultist
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_STRENGTH = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/easy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -6,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/hard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/hard_skills_only
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/medium
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/medium_skills_only
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/miner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 4,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/pirate
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -6,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/rockhill
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -4,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 4,
		ROGUE_STAT_WILLPOWER = 5,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/attribute_holder/sheet/rockhill_npc/skeleton/npc/supereasy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -6,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -2,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/attribute_holder/sheet/rockhill_npc/vagrantnpc
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -9,
		ROGUE_STAT_SPEED = -4,
		ROGUE_STAT_WILLPOWER = 2,
		)
