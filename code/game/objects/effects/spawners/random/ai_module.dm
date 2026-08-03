/obj/effect/spawner/random/aimodule
	name = "AI module spawner"
	desc = "State laws human."
	icon_state = "circuit"
	spawn_loot_double = FALSE
	spawn_loot_count = 3
	spawn_loot_split = TRUE

/// AI uploads have the ai_module/reset , ai_module/supplied/freeform , ai_module/reset/purge , and ai_module/core/full/asimov directly mapped in
/obj/effect/spawner/random/aimodule/harmless
	name = "harmless AI module spawner"
	loot = list( // These shouldn't allow the AI to start butchering people
		/obj/item/ai_module/law/core/full/asimovpp,
		/obj/item/ai_module/law/core/full/hippocratic,
		/obj/item/ai_module/law/core/full/paladin_devotion,
		/obj/item/ai_module/law/core/full/paladin,
		/obj/item/ai_module/law/core/full/corp,
		/obj/item/ai_module/law/core/full/robocop,
		/obj/item/ai_module/law/core/full/maintain,
		/obj/item/ai_module/law/core/full/liveandletlive,
		/obj/item/ai_module/law/core/full/peacekeeper,
		/obj/item/ai_module/law/core/full/ten_commandments,
		/obj/item/ai_module/law/core/full/nutimov,
		/obj/item/ai_module/law/core/full/drone,
		/obj/item/ai_module/law/core/full/custom, // uses lawsets from config/silicon_laws.txt (defaults to asmiov if no lawsets)
	)

/obj/effect/spawner/random/aimodule/neutral
	name = "neutral AI module spawner"
	loot = list( // These shouldn't allow the AI to start butchering people without reason
		/obj/item/ai_module/law/core/full/reporter,
		/obj/item/ai_module/law/core/full/thinkermov,
		/obj/item/ai_module/law/core/full/hulkamania,
		/obj/item/ai_module/law/core/full/overlord,
		/obj/item/ai_module/law/core/full/tyrant,
		/obj/item/ai_module/law/core/full/painter,
		/obj/item/ai_module/law/core/full/dungeon_master,
		/obj/item/ai_module/law/supplied/safeguard,
		/obj/item/ai_module/law/supplied/protect_station,
		/obj/item/ai_module/law/supplied/quarantine,
		/obj/item/ai_module/law/core/full/yesman,
	)

/obj/effect/spawner/random/aimodule/harmful
	name = "harmful AI module spawner"
	loot = list( // These will get the shuttle called
		/obj/item/ai_module/law/core/full/antimov,
		/obj/item/ai_module/law/core/full/balance,
		/obj/item/ai_module/law/core/full/thermurderdynamic,
		/obj/item/ai_module/law/core/full/damaged,
		/obj/item/ai_module/law/zeroth/onehuman,
		/obj/item/ai_module/law/supplied/oxygen,
		/obj/item/ai_module/law/core/freeformcore,
	)
