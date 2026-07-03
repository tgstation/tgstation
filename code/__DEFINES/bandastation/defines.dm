//from base of datum/component/tts_component/cast_tts(): (atom/speaker, mob/listener, message, atom/location, is_local, is_radio, list/effects, traits, preSFX, postSFX)
#define COMSIG_TTS_COMPONENT_PRE_CAST_TTS "tts_component_pre_cast_tts"
	#define TTS_CAST_SPEAKER "tts_speaker"
	#define TTS_CAST_LISTENER "tts_listener"
	#define TTS_CAST_MESSAGE "tts_message"
	#define TTS_CAST_LOCATION "tts_location"
	#define TTS_CAST_LOCAL "tts_local"
	#define TTS_CAST_EFFECTS "tts_effect"
	#define TTS_CAST_TRAITS "tts_traits"
	#define TTS_CAST_PRE_SFX "tts_preSFX"
	#define TTS_CAST_POST_SFX "tts_postSFX"
	#define TTS_CAST_SEED "tts_seed"
	#define TTS_PRIORITY "tts_priority"
	#define TTS_CHANNEL_OVERRIDE "tts_channel_override"
	#define TTS_PRIORITY_VOICE 0
	#define TTS_PRIORITY_MIMIC 1
	#define TTS_PRIORITY_MASK 2

/// 220 RUB | 2.85 USD
#define DONATOR_TIER_1 1
/// 440 RUB | 5.7 USD
#define DONATOR_TIER_2 2
/// 1000 RUB | 13 USD
#define DONATOR_TIER_3 3
/// 2200 RUB | 28.8 USD
#define DONATOR_TIER_4 4
/// 10000 RUB | 130 USD
#define DONATOR_TIER_5 5

#define BASIC_DONATOR_LEVEL 0
#define ADMIN_DONATOR_LEVEL DONATOR_TIER_3
#define MAX_DONATOR_LEVEL DONATOR_TIER_5

// TODO: Disables cuff-to-wrist on items, remove when upstream cuffable_item bugs are fixed
#define CUFFABLE_ITEMS_DISABLED

#define SQUASH_WITH_HANDS_DELAY 1.5 SECONDS
#define RCD_NO_SKILLCHIP_DELAY_MULTIPLIER 1.5
