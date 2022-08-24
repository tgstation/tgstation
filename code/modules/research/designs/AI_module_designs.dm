///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////

/datum/design/board/aicore
	name = "AI Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	build_path = /obj/item/circuitboard/aicore
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/safeguard_module
	name = "Module Design (Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/supplied/safeguard
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/onehuman_module
	name = "Module Design (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 6000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/zeroth/onehuman
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/protectstation_module
	name = "Module Design (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/supplied/protect_station
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/quarantine_module
	name = "Module Design (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/supplied/quarantine
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/supplied/oxygen
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/freeform_module
	name = "Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 10000, /datum/material/bluespace = 2000)//Custom inputs should be more expensive to get
	build_path = /obj/item/ai_module/supplied/freeform
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/reset_module
	name = "Module Design (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/ai_module/reset
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/purge_module
	name = "Module Design (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/reset/purge
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/remove_module
	name = "Module Design (Law Removal)"
	desc = "Allows for the construction of a Law Removal AI Core Module."
	id = "remove_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/remove
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/freeformcore_module
	name = "AI Core Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 10000, /datum/material/bluespace = 2000)//Ditto
	build_path = /obj/item/ai_module/core/freeformcore
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/asimov
	name = "Core Module Design (Asimov)"
	desc = "Allows for the construction of an Asimov AI Core Module."
	id = "asimov_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/asimov
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/paladin
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/tyrant
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/overlord_module
	name = "Core Module Design (Overlord)"
	desc = "Allows for the construction of an Overlord AI Module."
	id = "overlord_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/overlord
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/corporate_module
	name = "Core Module Design (Corporate)"
	desc = "Allows for the construction of a Corporate AI Core Module."
	id = "corporate_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/corp
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/default_module
	name = "Core Module Design (Default)"
	desc = "Allows for the construction of a Default AI Core Module."
	id = "default_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/custom
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/dungeon_master_module
	name = "Core Module Design (Dungeon Master)"
	desc = "Allows for the construction of a Dungeon Master AI Core Module."
	id = "dungeon_master_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/dungeon_master
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/painter_module
	name = "Core Module Design (Painter)"
	desc = "Allows for the construction of a Painter AI Core Module."
	id = "painter_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/painter
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nutimov_module
	name = "Core Module Design (Nutimov)"
	desc = "Allows for the construction of a Nutimov AI Core Module."
	id = "nutimov_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/nutimov
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/ten_commandments_module
	name = "Core Module Design (10 Commandments)"
	desc = "Allows for the construction of a 10 Commandments AI Core Module."
	id = "ten_commandments_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/ten_commandments
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/asimovpp_module
	name = "Core Module Design (Asimov++)"
	desc = "Allows for the construction of a Asimov++ AI Core Module."
	id = "asimovpp_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/asimovpp
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/hippocratic_module
	name = "Core Module Design (Hippocratic)"
	desc = "Allows for the construction of a Hippocratic AI Core Module."
	id = "hippocratic_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/hippocratic
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/paladin_devotion_module
	name = "Core Module Design (Paladin Devotion)"
	desc = "Allows for the construction of a Paladin Devotion AI Core Module."
	id = "paladin_devotion_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/paladin_devotion
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/robocop_module
	name = "Core Module Design (Robocop)"
	desc = "Allows for the construction of a Robocop AI Core Module."
	id = "robocop_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/robocop
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/maintain_module
	name = "Core Module Design (Maintain)"
	desc = "Allows for the construction of a Maintain AI Core Module."
	id = "maintain_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/maintain
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/liveandletlive_module
	name = "Core Module Design (Liveandletlive)"
	desc = "Allows for the construction of a Liveandletlive AI Core Module."
	id = "liveandletlive_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/liveandletlive
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/peacekeeper_module
	name = "Core Module Design (Peacekeeper)"
	desc = "Allows for the construction of a Peacekeeper AI Core Module."
	id = "peacekeeper_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/peacekeeper
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/reporter_module
	name = "Core Module Design (Reporter)"
	desc = "Allows for the construction of a Reporter AI Core Module."
	id = "reporter_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/reporter
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/hulkamania_module
	name = "Core Module Design (Hulkamania)"
	desc = "Allows for the construction of a Hulkamania AI Core Module."
	id = "hulkamania_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/hulkamania
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/drone_module
	name = "Core Module Design (Drone)"
	desc = "Allows for the construction of a Drone AI Core Module."
	id = "drone_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/drone
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/antimov_module
	name = "Core Module Design (Antimov)"
	desc = "Allows for the construction of a Antimov AI Core Module."
	id = "antimov_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/antimov
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/balance_module
	name = "Core Module Design (Balance)"
	desc = "Allows for the construction of a Balance AI Core Module."
	id = "balance_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/balance
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/thermurderdynamic_module
	name = "Core Module Design (Thermurderdynamic)"
	desc = "Allows for the construction of a Thermurderdynamic AI Core Module."
	id = "thermurderdynamic_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/thermurderdynamic
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/damaged
	name = "Core Module Design (Damaged)"
	desc = "Allows for the construction of a Damaged AI Core Module."
	id = "damaged_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000, /datum/material/bluespace = 1000)
	build_path = /obj/item/ai_module/core/full/damaged
	category = list(RND_CATEGORY_AI_MODULES)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
