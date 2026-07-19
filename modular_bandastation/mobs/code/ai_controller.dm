
// Как выставлять контроллер:
//	ai_controller = /datum/ai_controller/basic_controller/base_animal

// =========== Базовый контроллер животного ===========
/datum/ai_controller/basic_controller/base_animal
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

	behavior_nodes = list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/subtree/simple_skittish_combat),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/random_speech/base_animal),
		),
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"repeat_secondary_delay" = 1 SECONDS,
		"finish_on_primary" = TRUE,
	)

/datum/bt_node/ai_behavior/random_speech/base_animal
	speech_chance = 3
	speak = list("Вэх!", "Вэх.") // Что говорит
	emote_hear = list("говорит.") // Что показывается когда говорит
	emote_see = list("трясет головой.", "гонится за хвостом.", "пялится.", "озирается.") // Случайная эмоция

// =========== Петух ===========
/datum/ai_controller/basic_controller/chicken/cock
	behavior_nodes = list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/subtree/simple_capricious_combat),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/random_speech_blackboard),
		),
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"repeat_secondary_delay" = 1 SECONDS,
		"finish_on_primary" = TRUE,
	)

// =========== Опоссум ===========
/datum/ai_controller/basic_controller/possum
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

	behavior_nodes = list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/subtree/simple_capricious_combat),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/random_speech/possum),
		),
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"repeat_secondary_delay" = 1 SECONDS,
		"finish_on_primary" = TRUE,
	)

/datum/bt_node/ai_behavior/random_speech/possum
	speech_chance = 3
	emote_hear = list("Хсаааа!", "Хссс!")
	emote_see = list("трясет головой.", "гонится за хвостом.", "пялится.", "озирается.")
	speak = list("Хссс...", "Хиссс...")

// =========== Большие ящерицы ===========
/datum/ai_controller/basic_controller/lizard/big
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

	behavior_nodes = list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/selector,
				BT_DESC_CHILDREN = list(
					list(BT_DESC_TYPE = /datum/bt_node/subtree/escape_captivity),
					list(BT_DESC_TYPE = /datum/bt_node/subtree/simple_hostile_combat),
				),
			),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/random_speech/lizard/big),
		),
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"repeat_secondary_delay" = 1 SECONDS,
		"finish_on_primary" = TRUE,
	)

/datum/bt_node/ai_behavior/random_speech/lizard/big
	speech_chance = 1
	speak = list("ГРРР!", "Гррр!", "Рыр!", "Грх!")
	emote_hear = list("рычит.", "ворчит.", "грохочет.")
	emote_see = list("топает.", "свирепо пялится.")
	sound = list('modular_bandastation/mobs/sound/lizard_angry1.ogg', 'modular_bandastation/mobs/sound/lizard_angry2.ogg', 'modular_bandastation/mobs/sound/lizard_angry3.ogg')

// =========== Крысы ===========
/datum/bt_node/ai_behavior/random_speech/mouse/rat
	sound = list('modular_bandastation/mobs/sound/rat_talk.ogg')

/datum/ai_controller/basic_controller/mouse/rat/syndi
	behavior_nodes = list()

/datum/bt_node/ai_behavior/random_speech/mouse/rat/syndi
	speech_chance = 2
	speak = list("Слава Синдикату!", "Смерть НаноТрейзен!", "Отдавайте сыр!", "Слава Сыркату!", "Смерть за сыр!")

// =========== Хряки ===========
/datum/ai_controller/basic_controller/pig/big
	behavior_nodes = list()

/datum/bt_node/ai_behavior/random_speech/pig/big
	sound = list('modular_bandastation/mobs/sound/pig_talk1.ogg', 'modular_bandastation/mobs/sound/pig_talk2.ogg')

// =========== Зомби звуки ===========

/datum/bt_node/ai_behavior/random_speech/zombie
	sound = list('modular_bandastation/mobs/sound/zombie_idle1.ogg', 'modular_bandastation/mobs/sound/zombie_idle3.ogg')

/datum/bt_node/ai_behavior/random_speech/zombie/fast
	sound = list('modular_bandastation/mobs/sound/fast_zombie_idle1.ogg', 'modular_bandastation/mobs/sound/fast_zombie_idle2.ogg')

// =========== ... ===========
