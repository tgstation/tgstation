/obj/effect/spawner/lootdrop/aimodule
name = "AI module spawner"
desc = "State laws human."

/obj/effect/spawner/lootdrop/aimodule/harmless // These shouldn't allow the AI to start butchering people
	name = "harmless AI module spawner"
	loot = list(
	/obj/item/ai_module/core/full/asimov,
	/obj/item/ai_module/core/full/asimovpp,
	/obj/item/ai_module/core/full/hippocratic,
	/obj/item/ai_module/core/full/paladin_devotion,
	/obj/item/ai_module/core/full/paladin,
	)

/obj/effect/spawner/lootdrop/aimodule/neutral // These shouldn't allow the AI to start butchering people without reason
	name = "neutral AI module spawner"
	loot = list(
	/obj/item/ai_module/core/full/corp,
	/obj/item/ai_module/core/full/maintain,
	/obj/item/ai_module/core/full/drone,
	/obj/item/ai_module/core/full/peacekeeper,
	/obj/item/ai_module/core/full/reporter,
	/obj/item/ai_module/core/full/robocop,
	/obj/item/ai_module/core/full/liveandletlive,
	/obj/item/ai_module/core/full/hulkamania,
	)

/obj/effect/spawner/lootdrop/aimodule/harmful // These will get the shuttle called
	name = "harmful AI module spawner"
	loot = list(
	/obj/item/ai_module/core/full/antimov,
	/obj/item/ai_module/core/full/balance,
	/obj/item/ai_module/core/full/tyrant,
	/obj/item/ai_module/core/full/thermurderdynamic,
	/obj/item/ai_module/core/full/damaged,
	/obj/item/ai_module/reset/purge,
	)
