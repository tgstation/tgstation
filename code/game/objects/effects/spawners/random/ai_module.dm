/obj/effect/spawner/random/aimodule
	name = "AI module spawner"
	desc = "State laws human."
	icon_state = "circuit"

/obj/effect/spawner/random/aimodule/harmless
	name = "harmless AI module spawner"
	loot = list( // These shouldn't allow the AI to start butchering people
		/obj/item/ai_module/core/full/asimov,
		/obj/item/ai_module/core/full/asimovpp,
		/obj/item/ai_module/core/full/hippocratic,
		/obj/item/ai_module/core/full/paladin_devotion,
		/obj/item/ai_module/core/full/paladin,
	)

/obj/effect/spawner/random/aimodule/neutral
	name = "neutral AI module spawner"
	loot = list( // These shouldn't allow the AI to start butchering people without reason
		/obj/item/ai_module/core/full/corp,
		/obj/item/ai_module/core/full/maintain,
		/obj/item/ai_module/core/full/drone,
		/obj/item/ai_module/core/full/peacekeeper,
		/obj/item/ai_module/core/full/reporter,
		/obj/item/ai_module/core/full/robocop,
		/obj/item/ai_module/core/full/liveandletlive,
		/obj/item/ai_module/core/full/hulkamania,
	)

/obj/effect/spawner/random/aimodule/harmful
	name = "harmful AI module spawner"
	loot = list( // These will get the shuttle called
		/obj/item/ai_module/core/full/antimov,
		/obj/item/ai_module/core/full/balance,
		/obj/item/ai_module/core/full/tyrant,
		/obj/item/ai_module/core/full/thermurderdynamic,
		/obj/item/ai_module/core/full/damaged,
		/obj/item/ai_module/reset/purge,
	)
