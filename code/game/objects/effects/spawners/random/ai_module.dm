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
		/obj/item/ai_module/core/full/asimovpp,
		/obj/item/ai_module/core/full/hippocratic,
		/obj/item/ai_module/core/full/paladin_devotion,
		/obj/item/ai_module/core/full/paladin,
		/obj/item/ai_module/core/full/corp,
		/obj/item/ai_module/core/full/robocop,
		/obj/item/ai_module/core/full/maintain,
		/obj/item/ai_module/core/full/liveandletlive,
		/obj/item/ai_module/core/full/peacekeeper,
		/obj/item/ai_module/core/full/ten_commandments,
		/obj/item/ai_module/core/full/nutimov,
		/obj/item/ai_module/core/full/drone,
		/obj/item/ai_module/core/full/custom, // uses lawsets from config/silicon_laws.txt (defaults to asmiov if no lawsets)
	)

/obj/effect/spawner/random/aimodule/neutral
	name = "neutral AI module spawner"
	loot = list( // These shouldn't allow the AI to start butchering people without reason
		/obj/item/ai_module/core/full/reporter,
		/obj/item/ai_module/core/full/hulkamania,
		/obj/item/ai_module/core/full/overlord,
		/obj/item/ai_module/core/full/tyrant,
		/obj/item/ai_module/core/full/painter,
		/obj/item/ai_module/core/full/dungeon_master,
		/obj/item/ai_module/supplied/safeguard,
		/obj/item/ai_module/supplied/protect_station,
		/obj/item/ai_module/supplied/quarantine,
		/obj/item/ai_module/remove,
	)

/obj/effect/spawner/random/aimodule/harmful
	name = "harmful AI module spawner"
	loot = list( // These will get the shuttle called
		/obj/item/ai_module/core/full/antimov,
		/obj/item/ai_module/core/full/balance,
		/obj/item/ai_module/core/full/thermurderdynamic,
		/obj/item/ai_module/core/full/damaged,
		/obj/item/ai_module/zeroth/onehuman,
		/obj/item/ai_module/supplied/oxygen,
		/obj/item/ai_module/core/freeformcore,
	)
