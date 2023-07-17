/mob/living/basic/heretic_summon
    name = "Eldritch Heresy"
    desc = "Shouldn't be in the game, but since it can be spawned i'm just having a little fun."
	faction = list(FACTION_HERETIC)
	basic_mob_flags = DEL_ON_DEATH
	death_message = "implodes into itself."
	combat_mode = TRUE
	ai_controller = null
    speak_emote = list("errors") // should it be here even
