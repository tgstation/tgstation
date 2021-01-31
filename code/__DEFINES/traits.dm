#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//mob traits
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT		"knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED		"immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED			"floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING	"forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED		"handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED		"uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED		"pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED		"restrained"
/// Doesn't miss attacks
#define TRAIT_PERFECT_ATTACKER "perfect_attacker"
#define TRAIT_INCAPACITATED		"incapacitated"
#define TRAIT_CRITICAL_CONDITION	"critical-condition" //In some kind of critical condition. Is able to succumb.
#define TRAIT_BLIND 			"blind"
#define TRAIT_MUTE				"mute"
#define TRAIT_EMOTEMUTE			"emotemute"
#define TRAIT_DEAF				"deaf"
#define TRAIT_NEARSIGHT			"nearsighted"
#define TRAIT_FAT				"fat"
#define TRAIT_HUSK				"husk"
#define TRAIT_BADDNA			"baddna"
#define TRAIT_CLUMSY			"clumsy"
#define TRAIT_CHUNKYFINGERS		"chunkyfingers" //means that you can't use weapons with normal trigger guards.
#define TRAIT_DUMB				"dumb"
#define TRAIT_ADVANCEDTOOLUSER	"advancedtooluser" //Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_MONKEYLIKE		"monkeylike" //Antagonizes the above.
#define TRAIT_PACIFISM			"pacifism"
#define TRAIT_IGNORESLOWDOWN	"ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_DEATHCOMA			"deathcoma" //Causes death-like unconsciousness
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_DISFIGURED		"disfigured"
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_STUNIMMUNE		"stun_immunity"
#define TRAIT_STUNRESISTANCE    "stun_resistance"
#define TRAIT_IWASBATONED    	"iwasbatoned" //Anti Dual-baton cooldown bypass exploit.
#define TRAIT_SLEEPIMMUNE		"sleep_immunity"
#define TRAIT_PUSHIMMUNE		"push_immunity"
#define TRAIT_SHOCKIMMUNE		"shock_immunity"
#define TRAIT_TESLA_SHOCKIMMUNE	"tesla_shock_immunity"
#define TRAIT_STABLEHEART		"stable_heart"
#define TRAIT_STABLELIVER		"stable_liver"
#define TRAIT_RESISTHEAT		"resist_heat"
#define TRAIT_RESISTHEATHANDS	"resist_heat_handsonly" //For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTCOLD		"resist_cold"
#define TRAIT_RESISTHIGHPRESSURE	"resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE	"resist_low_pressure"
#define TRAIT_BOMBIMMUNE		"bomb_immunity"
#define TRAIT_RADIMMUNE			"rad_immunity"
#define TRAIT_GENELESS  		"geneless"
#define TRAIT_VIRUSIMMUNE		"virus_immunity"
#define TRAIT_PIERCEIMMUNE		"pierce_immunity"
#define TRAIT_NODISMEMBER		"dismember_immunity"
#define TRAIT_NOFIRE			"nonflammable"
#define TRAIT_NOGUNS			"no_guns"
#define TRAIT_NOHUNGER			"no_hunger"
#define TRAIT_NOMETABOLISM		"no_metabolism"
#define TRAIT_NOCLONELOSS		"no_cloneloss"
#define TRAIT_TOXIMMUNE			"toxin_immune"
#define TRAIT_EASYDISMEMBER		"easy_dismember"
#define TRAIT_LIMBATTACHMENT 	"limb_attach"
#define TRAIT_NOLIMBDISABLE		"no_limb_disable"
#define TRAIT_EASILY_WOUNDED		"easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED		"hard_limb_wound"
#define TRAIT_NEVER_WOUNDED		"never_wounded"
#define TRAIT_TOXINLOVER		"toxinlover"
#define TRAIT_NOBREATH			"no_breath"
#define TRAIT_ANTIMAGIC			"anti_magic"
#define TRAIT_HOLY				"holy"
#define TRAIT_DEPRESSION		"depression"
#define TRAIT_JOLLY				"jolly"
#define TRAIT_NOCRITDAMAGE		"no_crit"
#define TRAIT_NOSLIPWATER		"noslip_water"
#define TRAIT_NOSLIPALL			"noslip_all"
#define TRAIT_NODEATH			"nodeath"
#define TRAIT_NOHARDCRIT		"nohardcrit"
#define TRAIT_NOSOFTCRIT		"nosoftcrit"
#define TRAIT_MINDSHIELD		"mindshield"
#define TRAIT_DISSECTED			"dissected"
#define TRAIT_SIXTHSENSE		"sixth_sense" //I can hear dead people
#define TRAIT_FEARLESS			"fearless"
#define TRAIT_PARALYSIS_L_ARM	"para-l-arm" //These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_R_ARM	"para-r-arm"
#define TRAIT_PARALYSIS_L_LEG	"para-l-leg"
#define TRAIT_PARALYSIS_R_LEG	"para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION    "present-vision"
#define TRAIT_DISK_VERIFIER     "disk-verifier"
#define TRAIT_NOMOBSWAP         "no-mob-swap"
#define TRAIT_XRAY_VISION       "xray_vision"
#define TRAIT_THERMAL_VISION    "thermal_vision"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON           "surgeon"
#define	TRAIT_STRONG_GRABBER	"strong_grabber"
#define	TRAIT_MAGIC_CHOKE		"magic_choke"
#define TRAIT_SOOTHED_THROAT    "soothed-throat"
#define TRAIT_BOOZE_SLIDER      "booze-slider"
#define TRAIT_QUICK_CARRY		"quick-carry"
#define TRAIT_QUICKER_CARRY		"quicker-carry"
#define TRAIT_QUICK_BUILD		"quick-build"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE			"unstable"
#define TRAIT_OIL_FRIED			"oil_fried"
#define TRAIT_MEDICAL_HUD		"med_hud"
#define TRAIT_SECURITY_HUD		"sec_hud"
#define TRAIT_DIAGNOSTIC_HUD	"diag_hud" //for something granting you a diagnostic hud
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot" //Is a medbot healing you
#define TRAIT_PASSTABLE			"passtable"
#define TRAIT_NOFLASH			"noflash" //Makes you immune to flashes
#define TRAIT_XENO_IMMUNE		"xeno_immune"//prevents xeno huggies implanting skeletons
#define TRAIT_FLASH_SENSITIVE	"flash_sensitive"//Makes you flashable from any direction
#define TRAIT_NAIVE				"naive"
#define TRAIT_PRIMITIVE			"primitive"
#define TRAIT_GUNFLIP			"gunflip"
#define TRAIT_SPECIAL_TRAUMA_BOOST	"special_trauma_boost" ///Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_BLOODCRAWL_EAT	"bloodcrawl_eat"
#define TRAIT_SPACEWALK			"spacewalk"
#define TRAIT_GAMERGOD			"gamer-god" //double arcade prizes
#define TRAIT_GIANT				"giant"
#define TRAIT_DWARF				"dwarf"
#define TRAIT_SILENT_FOOTSTEPS	"silent_footsteps" //makes your footsteps completely silent
#define TRAIT_NICE_SHOT			"nice_shot" //hnnnnnnnggggg..... you're pretty good....
#define TRAIT_TUMOR_SUPPRESSED	"brain_tumor_suppressed" //prevents the damage done by a brain tumor
#define TRAIT_PERMANENTLY_ONFIRE	"permanently_onfire" //overrides the update_fire proc to always add fire (for lava)
#define TRAIT_SIGN_LANG				"sign_language" //Galactic Common Sign Language
#define TRAIT_NANITE_MONITORING	"nanite_monitoring" //The mob's nanites are sending a monitoring signal visible on diag HUD
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune" // nobody can use martial arts on this mob
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE			"cant_ride"
#define TRAIT_BLOODY_MESS		"bloody_mess" //from heparin, makes open bleeding wounds rapidly spill more blood
#define TRAIT_COAGULATING		"coagulating" //from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
/// The holder of this trait has antennae or whatever that hurt a ton when noogied
#define TRAIT_ANTENNAE	"antennae"

#define TRAIT_NOBLEED "nobleed" //This carbon doesn't bleed

// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_MADNESS_IMMUNE "supermatter_madness_immune"

// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures
// and emit less heat. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"
/*
* Trait granted by various security jobs, and checked by [/obj/item/food/donut]
* When present in the mob's mind, they will always love donuts.
*/
#define TRAIT_DONUT_LOVER "donut_lover"

// METABOLISMS
// Various jobs on the station have historically had better reactions
// to various drinks and foodstuffs. Security liking donuts is a classic
// example. Through years of training/abuse, their livers have taken
// a liking to those substances. Steal a sec officer's liver, eat donuts good.

// These traits are applied to /obj/item/organ/liver
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_GREYTIDE_METABOLISM "greytide_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"

// If present on a mob or mobmind, allows them to "suplex" an immovable rod
// turning it into a glorified potted plant, and giving them an
// achievement. Can also be used on rod-form wizards.
// Normally only present in the mind of a Research Director.
#define TRAIT_ROD_SUPLEX "rod_suplex"

//SKILLS
#define TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE "underwater_basketweaving"
#define TRAIT_WINE_TASTER "wine_taster"
#define TRAIT_BONSAI "bonsai"
#define TRAIT_LIGHTBULB_REMOVER "lightbulb_remover"
#define TRAIT_KNOW_CYBORG_WIRES "know_cyborg_wires"
#define TRAIT_KNOW_ENGI_WIRES "know_engi_wires"
#define TRAIT_ENTRAILS_READER "entrails_reader"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND		"move_ground"
#define TRAIT_MOVE_FLYING		"move_flying"
#define TRAIT_MOVE_VENTCRAWLING	"move_ventcrawling"
#define TRAIT_MOVE_FLOATING		"move_floating"
#define TRAIT_MOVE_PHASING		"move_phasing"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM		"no-floating-animation"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS				"paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND		"disabled-by-wound"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER 	"keep-together"

///Marks the item as having been transmuted. Functionally blacklists the item from being recycled or sold for materials.
#define TRAIT_MAT_TRANSMUTED	"transmuted"

// item traits
#define TRAIT_NODROP			"nodrop"
#define TRAIT_NO_STORAGE_INSERT	"no_storage_insert" //cannot be inserted in a storage.
#define TRAIT_T_RAY_VISIBLE		"t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_NO_TELEPORT		"no-teleport" //you just can't
#define TRAIT_FOOD_GRILLED 		"food_grilled"
#define TRAIT_NEEDS_TWO_HANDS	"needstwohands" //The items needs two hands to be carried
#define TRAIT_FISH_SAFE_STORAGE "fish_case" //Fish in this won't die
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile" //Stuff that can go inside fish cases

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"
#define TRAIT_AGEUSIA			"ageusia"
#define TRAIT_HEAVY_SLEEPER		"heavy_sleeper"
#define TRAIT_NIGHT_VISION		"night_vision"
#define TRAIT_LIGHT_STEP		"light_step"
#define TRAIT_SPIRITUAL			"spiritual"
#define TRAIT_FAN_CLOWN			"fan_clown"
#define TRAIT_FAN_MIME			"fan_mime"
#define TRAIT_VORACIOUS			"voracious"
#define TRAIT_SELF_AWARE		"self_aware"
#define TRAIT_FREERUNNING		"freerunning"
#define TRAIT_SKITTISH			"skittish"
#define TRAIT_POOR_AIM			"poor_aim"
#define TRAIT_PROSOPAGNOSIA		"prosopagnosia"
#define TRAIT_DRUNK_HEALING		"drunk_healing"
#define TRAIT_TAGGER			"tagger"
#define TRAIT_PHOTOGRAPHER		"photographer"
#define TRAIT_MUSICIAN			"musician"
#define TRAIT_LIGHT_DRINKER		"light_drinker"
#define TRAIT_EMPATH			"empath"
#define TRAIT_FRIENDLY			"friendly"
#define TRAIT_GRABWEAKNESS		"grab_weakness"
#define TRAIT_SNOB				"snob"
#define TRAIT_BALD				"bald"
#define TRAIT_BADTOUCH			"bad_touch"
#define TRAIT_EXTROVERT			"extrovert"
#define TRAIT_INTROVERT			"introvert"
///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
//Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"

//Medical Categories for quirks
#define CAT_QUIRK_ALL 0
#define CAT_QUIRK_NOTES 1
#define CAT_QUIRK_MINOR_DISABILITY 2
#define CAT_QUIRK_MAJOR_DISABILITY 3

// common trait sources
#define TRAIT_GENERIC "generic"
#define GENERIC_ITEM_TRAIT "generic_item"
#define UNCONSCIOUS_TRAIT "unconscious"
#define EYE_DAMAGE "eye_damage"
#define EAR_DAMAGE "ear_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_TRAIT "magic"
#define TRAUMA_TRAIT "trauma"
#define DISEASE_TRAIT "disease"
#define SPECIES_TRAIT "species"
#define ORGAN_TRAIT "organ"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define JOB_TRAIT "job"
#define CYBORG_ITEM_TRAIT "cyborg-item"
#define ADMIN_TRAIT "admin" // (B)admins only.
#define CHANGELING_TRAIT "changeling"
#define CULT_TRAIT "cult"
#define CURSED_ITEM_TRAIT "cursed-item" // The item is magically cursed
#define ABSTRACT_ITEM_TRAIT "abstract-item"
#define STATUS_EFFECT_TRAIT "status-effect"
#define CLOTHING_TRAIT "clothing"
#define HELMET_TRAIT "helmet"
#define MASK_TRAIT "mask" //inherited from the mask
#define SHOES_TRAIT "shoes" //inherited from your sweet kicks
#define GLASSES_TRAIT "glasses"
#define VEHICLE_TRAIT "vehicle" // inherited from riding vehicles
#define INNATE_TRAIT "innate"
#define CRIT_HEALTH_TRAIT "crit_health"
#define OXYLOSS_TRAIT "oxyloss"
#define TURF_TRAIT "turf"
#define BUCKLED_TRAIT "buckled" //trait associated to being buckled
#define CHOKEHOLD_TRAIT "chokehold" //trait associated to being held in a chokehold
#define RESTING_TRAIT "resting" //trait associated to resting
#define STAT_TRAIT "stat" //trait associated to a stat value or range of
#define MAPPING_HELPER_TRAIT "mapping-helper" //obtained from mapping helper
/// Trait associated to wearing a suit
#define SUIT_TRAIT "suit"
/// Trait associated to lying down (having a [lying_angle] of a different value than zero).
#define LYING_DOWN_TRAIT "lying-down"
/// Trait associated to lacking electrical power.
#define POWER_LACK_TRAIT "power-lack"

// unique trait sources, still defines
#define CLONING_POD_TRAIT "cloning-pod"
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
#define CHANGELING_HIVEMIND_MUTE "ling_mute"
#define ABYSSAL_GAZE_BLIND "abyssal_gaze"
#define HIGHLANDER "highlander"
#define TRAIT_HULK "hulk"
#define STASIS_MUTE "stasis"
#define GENETICS_SPELL "genetics_spell"
#define EYES_COVERED "eyes_covered"
#define CULT_EYES "cult_eyes"
#define TRAIT_SANTA "santa"
#define SCRYING_ORB "scrying-orb"
#define ABDUCTOR_ANTAGONIST "abductor-antagonist"
#define JUNGLE_FEVER_TRAIT "jungle_fever"
#define MEGAFAUNA_TRAIT "megafauna"
#define CLOWN_NUKE_TRAIT "clown-nuke"
#define STICKY_MOUSTACHE_TRAIT "sticky-moustache"
#define CHAINSAW_FRENZY_TRAIT "chainsaw-frenzy"
#define CHRONO_GUN_TRAIT "chrono-gun"
#define REVERSE_BEAR_TRAP_TRAIT "reverse-bear-trap"
#define CURSED_MASK_TRAIT "cursed-mask"
#define HIS_GRACE_TRAIT "his-grace"
#define HAND_REPLACEMENT_TRAIT "magic-hand"
#define HOT_POTATO_TRAIT "hot-potato"
#define SABRE_SUICIDE_TRAIT "sabre-suicide"
#define ABDUCTOR_VEST_TRAIT "abductor-vest"
#define CAPTURE_THE_FLAG_TRAIT "capture-the-flag"
#define EYE_OF_GOD_TRAIT "eye-of-god"
#define SHAMEBRERO_TRAIT "shamebrero"
#define CHRONOSUIT_TRAIT "chronosuit"
#define LOCKED_HELMET_TRAIT "locked-helmet"
#define NINJA_SUIT_TRAIT "ninja-suit"
#define ANTI_DROP_IMPLANT_TRAIT "anti-drop-implant"
#define SLEEPING_CARP_TRAIT "sleeping_carp"
#define MADE_UNCLONEABLE "made-uncloneable"
#define TIMESTOP_TRAIT "timestop"
#define LIFECANDLE_TRAIT "lifecandle"
#define VENTCRAWLING_TRAIT "ventcrawling"
#define SPECIES_FLIGHT_TRAIT "species-flight"
#define FROSTMINER_ENRAGE_TRAIT "frostminer-enrage"
#define NO_GRAVITY_TRAIT "no-gravity"
#define LEAPER_BUBBLE_TRAIT "leaper-bubble"
#define STICKY_NODROP "sticky-nodrop" //sticky nodrop sounds like a bad soundcloud rapper's name
#define SKILLCHIP_TRAIT "skillchip"
#define BUSY_FLOORBOT_TRAIT "busy-floorbot"
#define PULLED_WHILE_SOFTCRIT_TRAIT "pulled-while-softcrit"
#define LOCKED_BORG_TRAIT "locked-borg"
#define LACKING_LOCOMOTION_APPENDAGES_TRAIT "lacking-locomotion-appengades" //trait associated to not having locomotion appendages nor the ability to fly or float
#define CRYO_TRAIT "cryo"
#define LACKING_MANIPULATION_APPENDAGES_TRAIT "lacking-manipulation-appengades" //trait associated to not having fine manipulation appendages such as hands
#define HANDCUFFED_TRAIT "handcuffed"
/// Trait granted by [/obj/item/warpwhistle]
#define WARPWHISTLE_TRAIT "warpwhistle"
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"
/// Trait applied by by [/datum/component/soulstoned]
#define SOULSTONE_TRAIT "soulstone"
/// Trait applied to slimes by low temperature
#define SLIME_COLD "slime-cold"
/// Trait applied to bots by being tipped over
#define BOT_TIPPED_OVER "bot-tipped-over"
/// Trait applied to PAIs by being folded
#define PAI_FOLDED "pai-folded"
/// Trait applied to brain mobs when they lack external aid for locomotion, such as being inside a mech.
#define BRAIN_UNAIDED "brain-unaided"
/// Trait applied by element
#define ELEMENT_TRAIT "element_trait"
/// Trait granted by [/obj/item/clothing/head/helmet/space/hardsuit/berserker]
#define BERSERK_TRAIT "berserk_trait"

/**
* Trait granted by [/mob/living/carbon/Initialize] and
* granted/removed by [/obj/item/organ/tongue]
* Used for ensuring that carbons without tongues cannot taste anything
* so it is added in Initialize, and then removed when a tongue is inserted
* and readded when a tongue is removed.
*/
#define NO_TONGUE_TRAIT "no_tongue_trait"

/// Trait granted by [/mob/living/silicon/robot]
/// Traits applied to a silicon mob by their model.
#define MODEL_TRAIT "model_trait"

/// Trait from [/datum/antagonist/nukeop/clownop]
#define CLOWNOP_TRAIT "clownop"
