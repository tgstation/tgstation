/mob/living/basic/giant_spider/tarantula/wasteland
	faction = list(FACTION_WASTELAND)
/mob/living/basic/giant_spider/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/basic/giant_spider/wasteland/Initialize(mapload)
	. = ..()
	ai_controller.set_blackboard_key(BB_SPIDER_WEB_ACTION, null)

/mob/living/basic/giant_spider/tarantula/wasteland/Initialize(mapload)
	. = ..()
	ai_controller.set_blackboard_key(BB_SPIDER_WEB_ACTION, null)

