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
		if (_L?[trait]) { \
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
#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target.status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list?[trait]) { \
			for (var/_trait_source in _traits_list[trait]) { \
				if (!(_trait_source in _sources_list)) { \
					_traits_list[trait] -= _trait_source \
				} \
			};\
			if (!length(_traits_list[trait])) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
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

#define HAS_TRAIT(target, trait) (target.status_traits?[trait] ? TRUE : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits?[trait] && (source in target.status_traits[trait]))
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (target.status_traits?[trait] && (source in target.status_traits[trait]) && (length(target.status_traits[trait]) == 1))
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits?[trait] && (length(target.status_traits[trait] - source) > 0))

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//mob traits
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING "forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"
/// Doesn't miss attacks
#define TRAIT_PERFECT_ATTACKER "perfect_attacker"
#define TRAIT_INCAPACITATED "incapacitated"
/// In some kind of critical condition. Is able to succumb.
#define TRAIT_CRITICAL_CONDITION "critical-condition"
/// Whitelist for mobs that can read or write
#define TRAIT_LITERATE "literate"
/// Blacklist for mobs that can't read or write
#define TRAIT_ILLITERATE "illiterate"
/// Mute. Can't talk.
#define TRAIT_MUTE "mute"
/// Gibs on death and slips like ice.
#define TRAIT_CURSED "cursed"
/// Emotemute. Can't... emote.
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF "deaf"
#define TRAIT_FAT "fat"
#define TRAIT_HUSK "husk"
///Blacklisted from being revived via defibrilator
#define TRAIT_DEFIB_BLACKLISTED "defib_blacklisted"
#define TRAIT_BADDNA "baddna"
#define TRAIT_CLUMSY "clumsy"
/// means that you can't use weapons with normal trigger guards.
#define TRAIT_CHUNKYFINGERS "chunkyfingers"
#define TRAIT_DUMB "dumb"
/// Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_ADVANCEDTOOLUSER "advancedtooluser"
// Antagonizes the above.
#define TRAIT_DISCOORDINATED_TOOL_USER "discoordinated_tool_user"
#define TRAIT_PACIFISM "pacifism"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
/// Makes it so the mob can use guns regardless of tool user status
#define TRAIT_GUN_NATURAL "gunnatural"
/// Causes death-like unconsciousness
#define TRAIT_DEATHCOMA "deathcoma"
/// Makes the owner appear as dead to most forms of medical examination
#define TRAIT_FAKEDEATH "fakedeath"
#define TRAIT_DISFIGURED "disfigured"
/// Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_XENO_HOST "xeno_host"
#define TRAIT_STUNIMMUNE "stun_immunity"
#define TRAIT_BATON_RESISTANCE "baton_resistance"
/// Anti Dual-baton cooldown bypass exploit.
#define TRAIT_IWASBATONED "iwasbatoned"
#define TRAIT_SLEEPIMMUNE "sleep_immunity"
#define TRAIT_PUSHIMMUNE "push_immunity"
/// Are we immune to shocks?
#define TRAIT_SHOCKIMMUNE "shock_immunity"
/// Are we immune to specifically tesla / SM shocks?
#define TRAIT_TESLA_SHOCKIMMUNE "tesla_shock_immunity"
#define TRAIT_AIRLOCK_SHOCKIMMUNE "airlock_shock_immunity"
/// Is this atom being actively shocked? Used to prevent repeated shocks.
#define TRAIT_BEING_SHOCKED "shocked"
#define TRAIT_STABLEHEART "stable_heart"
/// Prevents you from leaving your corpse
#define TRAIT_CORPSELOCKED "corpselocked"
#define TRAIT_STABLELIVER "stable_liver"
#define TRAIT_VATGROWN "vatgrown"
#define TRAIT_RESISTHEAT "resist_heat"
///For when you've gotten a power from a dna vault
#define TRAIT_USED_DNA_VAULT "used_dna_vault"
/// For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTHEATHANDS "resist_heat_handsonly"
#define TRAIT_RESISTCOLD "resist_cold"
#define TRAIT_RESISTHIGHPRESSURE "resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE "resist_low_pressure"
/// This human is immune to the effects of being exploded. (ex_act)
#define TRAIT_BOMBIMMUNE "bomb_immunity"
#define TRAIT_RADIMMUNE "rad_immunity"
#define TRAIT_GENELESS "geneless"
#define TRAIT_VIRUSIMMUNE "virus_immunity"
#define TRAIT_PIERCEIMMUNE "pierce_immunity"
#define TRAIT_NODISMEMBER "dismember_immunity"
#define TRAIT_NOFIRE "nonflammable"
#define TRAIT_NOFIRE_SPREAD "no_fire_spreading"
/// Prevents plasmamen from self-igniting if only their helmet is missing
#define TRAIT_NOSELFIGNITION_HEAD_ONLY "no_selfignition_head_only"
#define TRAIT_NOGUNS "no_guns"
///This carbon doesn't get hungry
#define TRAIT_NOHUNGER "no_hunger"
///This carbon doesn't bleed
#define TRAIT_NOBLOOD "noblood"
#define TRAIT_NOMETABOLISM "no_metabolism"
// Use when you want a mob to be able to metabolize plasma temporarily (e.g. plasma fixation disease symptom)
#define TRAIT_PLASMA_LOVER_METABOLISM "plasma_lover_metabolism"
#define TRAIT_NOCLONELOSS "no_cloneloss"
#define TRAIT_TOXIMMUNE "toxin_immune"
#define TRAIT_EASYDISMEMBER "easy_dismember"
#define TRAIT_LIMBATTACHMENT "limb_attach"
#define TRAIT_NOLIMBDISABLE "no_limb_disable"
#define TRAIT_EASILY_WOUNDED "easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED "hard_limb_wound"
#define TRAIT_NEVER_WOUNDED "never_wounded"
#define TRAIT_TOXINLOVER "toxinlover"
/// Doesn't get overlays from being in critical.
#define TRAIT_NOCRITOVERLAY "no_crit_overlay"
/// Gets a mood boost from being in the hideout.
#define TRAIT_VAL_CORRIN_MEMBER "val_corrin_member"
/// reduces the use time of syringes, pills, patches and medigels but only when using on someone
#define TRAIT_FASTMED "fast_med_use"
#define TRAIT_NOBREATH "no_breath"
#define TRAIT_ANTIMAGIC "anti_magic"
#define TRAIT_HOLY "holy"
/// This allows a person who has antimagic to cast spells without getting blocked
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
#define TRAIT_DEPRESSION "depression"
#define TRAIT_JOLLY "jolly"
#define TRAIT_NOCRITDAMAGE "no_crit"
#define TRAIT_NOSLIPWATER "noslip_water"
#define TRAIT_NOSLIPALL "noslip_all"
#define TRAIT_NODEATH "nodeath"
#define TRAIT_NOHARDCRIT "nohardcrit"
#define TRAIT_NOSOFTCRIT "nosoftcrit"
#define TRAIT_MINDSHIELD "mindshield"
#define TRAIT_DISSECTED "dissected"
/// Lets the user succumb even if they got NODEATH
#define TRAIT_SUCCUMB_OVERRIDE "succumb_override"
/// Can hear observers
#define TRAIT_SIXTHSENSE "sixth_sense"
#define TRAIT_FEARLESS "fearless"
/// Ignores darkness for hearing
#define TRAIT_HEAR_THROUGH_DARKNESS "hear_through_darkness"
/// These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_L_ARM "para-l-arm"
#define TRAIT_PARALYSIS_R_ARM "para-r-arm"
#define TRAIT_PARALYSIS_L_LEG "para-l-leg"
#define TRAIT_PARALYSIS_R_LEG "para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION "present-vision"
#define TRAIT_DISK_VERIFIER "disk-verifier"
#define TRAIT_NOMOBSWAP "no-mob-swap"
/// Can examine IDs to see if they are roundstart.
#define TRAIT_ID_APPRAISER "id_appraiser"
/// Gives us turf, mob and object vision through walls
#define TRAIT_XRAY_VISION "xray_vision"
/// Gives us mob vision through walls and slight night vision
#define TRAIT_THERMAL_VISION "thermal_vision"
/// Gives us turf vision through walls and slight night vision
#define TRAIT_MESON_VISION "meson_vision"
/// Gives us Night vision
#define TRAIT_TRUE_NIGHT_VISION "true_night_vision"
/// Negates our gravity, letting us move normally on floors in 0-g
#define TRAIT_NEGATES_GRAVITY "negates_gravity"
/// Lets us scan reagents
#define TRAIT_REAGENT_SCANNER "reagent_scanner"
/// Lets us scan machine parts and tech unlocks
#define TRAIT_RESEARCH_SCANNER "research_scanner"
/// Can weave webs into cloth
#define TRAIT_WEB_WEAVER "web_weaver"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON "surgeon"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_SOOTHED_THROAT "soothed-throat"
#define TRAIT_BOOZE_SLIDER "booze-slider"
/// We place people into a fireman carry quicker than standard
#define TRAIT_QUICK_CARRY "quick-carry"
/// We place people into a fireman carry especially quickly compared to quick_carry
#define TRAIT_QUICKER_CARRY "quicker-carry"
#define TRAIT_QUICK_BUILD "quick-build"
/// We can handle 'dangerous' plants in botany safely
#define TRAIT_PLANT_SAFE "plant_safe"
/// Prevents the overlay from nearsighted
#define TRAIT_NEARSIGHTED_CORRECTED "fixes_nearsighted"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_MEDICAL_HUD "med_hud"
#define TRAIT_SECURITY_HUD "sec_hud"
/// for something granting you a diagnostic hud
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"
/// Is a medbot healing you
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot"
#define TRAIT_PASSTABLE "passtable"
/// Makes you immune to flashes
#define TRAIT_NOFLASH "noflash"
/// prevents xeno huggies implanting skeletons
#define TRAIT_XENO_IMMUNE "xeno_immune"
/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
#define TRAIT_NO_JUMPSUIT "no_jumpsuit"
#define TRAIT_NAIVE "naive"
/// always detect storms on icebox
#define TRAIT_DETECT_STORM "detect_storm"
#define TRAIT_PRIMITIVE "primitive"
#define TRAIT_GUNFLIP "gunflip"
/// Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost"
#define TRAIT_SPACEWALK "spacewalk"
/// Sanity trait to keep track of when we're in hyperspace and add the appropriate element if we werent
#define TRAIT_HYPERSPACED "hyperspaced"
///Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement"
/// Gets double arcade prizes
#define TRAIT_GAMERGOD "gamer-god"
#define TRAIT_GIANT "giant"
#define TRAIT_DWARF "dwarf"
/// makes your footsteps completely silent
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"
/// hnnnnnnnggggg..... you're pretty good....
#define TRAIT_NICE_SHOT "nice_shot"
/// prevents the damage done by a brain tumor
#define TRAIT_TUMOR_SUPPRESSED "brain_tumor_suppressed"
/// Prevents hallucinations from the hallucination brain trauma (RDS)
#define TRAIT_RDS_SUPPRESSED "rds_suppressed"
/// overrides the update_fire proc to always add fire (for lava)
#define TRAIT_PERMANENTLY_ONFIRE "permanently_onfire"
/// Indicates if the mob is currently speaking with sign language
#define TRAIT_SIGN_LANG "sign_language"
/// This mob is able to use sign language over the radio.
#define TRAIT_CAN_SIGN_ON_COMMS "can_sign_on_comms"
/// nobody can use martial arts on this mob
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune"
/// Immune to being afflicted by time stop (spell)
#define TRAIT_TIME_STOP_IMMUNE "time_stop_immune"
/// Revenants draining you only get a very small benefit.
#define TRAIT_WEAK_SOUL "weak_soul"
/// This mob has no soul
#define TRAIT_NO_SOUL "no_soul"
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE "cant_ride"
/// Prevents a mob from being unbuckled, currently only used to prevent people from falling over on the tram
#define TRAIT_CANNOT_BE_UNBUCKLED "cannot_be_unbuckled"
/// from heparin, makes open bleeding wounds rapidly spill more blood
#define TRAIT_BLOODY_MESS "bloody_mess"
/// from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
#define TRAIT_COAGULATING "coagulating"
/// From anti-convulsant medication against seizures.
#define TRAIT_ANTICONVULSANT "anticonvulsant"
/// The holder of this trait has antennae or whatever that hurt a ton when noogied
#define TRAIT_ANTENNAE "antennae"
/// Blowing kisses actually does damage to the victim
#define TRAIT_KISS_OF_DEATH "kiss_of_death"
/// Used to activate french kissing
#define TRAIT_GARLIC_BREATH "kiss_of_garlic_death"
/// Addictions don't tick down, basically they're permanently addicted
#define TRAIT_HOPELESSLY_ADDICTED "hopelessly_addicted"
/// This mob has a cult halo.
#define TRAIT_CULT_HALO "cult_halo"
/// Their eyes glow an unnatural red colour. Currently used to set special examine text on humans. Does not guarantee the mob's eyes are coloured red, nor that there is any visible glow on their character sprite.
#define TRAIT_UNNATURAL_RED_GLOWY_EYES "unnatural_red_glowy_eyes"
/// Their eyes are bloodshot. Currently used to set special examine text on humans. Examine text is overridden by TRAIT_UNNATURAL_RED_GLOWY_EYES.
#define TRAIT_BLOODSHOT_EYES "bloodshot_eyes"
/// This mob should never close UI even if it doesn't have a client
#define TRAIT_PRESERVE_UI_WITHOUT_CLIENT "preserve_ui_without_client"
/// Lets the mob use flight potions
#define TRAIT_CAN_USE_FLIGHT_POTION "can_use_flight_potion"
/// This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"
/// Someone can safely be attacked with honorbound with ONLY a combat mode check, the trait is assuring holding a weapon and hitting won't hurt them..
#define TRAIT_ALLOWED_HONORBOUND_ATTACK "allowed_honorbound_attack"
/// The user is sparring
#define TRAIT_SPARRING "sparring"
/// The user is currently challenging an elite mining mob. Prevents him from challenging another until he's either lost or won.
#define TRAIT_ELITE_CHALLENGER "elite_challenger"
/// For living mobs. It signals that the mob shouldn't have their data written in an external json for persistence.
#define TRAIT_DONT_WRITE_MEMORY "dont_write_memory"
/// This mob can be painted with the spraycan
#define TRAIT_SPRAY_PAINTABLE "spray_paintable"
/// This person is blushing
#define TRAIT_BLUSHING "blushing"
/// This person is crying
#define TRAIT_CRYING "crying"
/// This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack from bags or lockers as long as any other conditions are met
#define TRAIT_AI_BAGATTACK "bagattack"
/// This mobs bodyparts are invisible but still clickable.
#define TRAIT_INVISIBLE_MAN "invisible_man"
/// Don't draw external organs/species features like wings, horns, frills and stuff
#define TRAIT_HIDE_EXTERNAL_ORGANS "hide_external_organs"
///When people are floating from zero-grav or something, we can move around freely!
#define TRAIT_FREE_FLOAT_MOVEMENT "free_float_movement"
// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment. Present on /mob or /datum/mind
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"
// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures
// and emit less heat. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"

/// `do_teleport` will not allow this atom to teleport
#define TRAIT_NO_TELEPORT "no-teleport"
/// This atom is a secluded location, which is counted as out of bounds.
/// Anything that enters this atom's contents should react if it wants to stay in bounds.
#define TRAIT_SECLUDED_LOCATION "secluded_loc"

/// Trait used by fugu glands to avoid double buffing
#define TRAIT_FUGU_GLANDED "fugu_glanded"

/// When someone with this trait fires a ranged weapon, their fire delays and click cooldowns are halved
#define TRAIT_DOUBLE_TAP "double_tap"

/// Trait applied to [/datum/mind] to stop someone from using the cursed hot springs to polymorph more than once.
#define TRAIT_HOT_SPRING_CURSED "hot_spring_cursed"

/// If something has been engraved/cannot be engraved
#define TRAIT_NOT_ENGRAVABLE "not_engravable"

/// Whether or not orbiting is blocked or not
#define TRAIT_ORBITING_FORBIDDEN "orbiting_forbidden"
/// Trait applied to mob/living to mark that spiders should not gain further enriched eggs from eating their corpse.
#define TRAIT_SPIDER_CONSUMED "spider_consumed"
/// Whether we're sneaking, from the alien sneak ability.
/// Maybe worth generalizing into a general "is sneaky" / "is stealth" trait in the future.
#define TRAIT_ALIEN_SNEAK "sneaking_alien"

/// Item still allows you to examine items while blind and actively held.
#define TRAIT_BLIND_TOOL "blind_tool"

/// The person with this trait always appears as 'unknown'.
#define TRAIT_UNKNOWN "unknown"

/// If the mob has this trait and die, their bomb implant doesn't detonate automatically. It must be consciously activated.
#define TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION "prevent_implant_auto_explosion"

/// If applied to a mob, nearby dogs will have a small chance to nonharmfully harass said mob
#define TRAIT_HATED_BY_DOGS "hated_by_dogs"

// METABOLISMS
// Various jobs on the station have historically had better reactions
// to various drinks and foodstuffs. Security liking donuts is a classic
// example. Through years of training/abuse, their livers have taken
// a liking to those substances. Steal a sec officer's liver, eat donuts good.

// These traits are applied to /obj/item/organ/internal/liver
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"
#define TRAIT_BALLMER_SCIENTIST "ballmer_scientist"

//LUNG TRAITS
/// Lungs always breathe normally when in vacuum/space.
#define TRAIT_SPACEBREATHING "spacebreathing"

/// This mob can strip other mobs.
#define TRAIT_CAN_STRIP "can_strip"
/// Can use the nuclear device's UI, regardless of a lack of hands
#define TRAIT_CAN_USE_NUKE "can_use_nuke"

// If present on a mob or mobmind, allows them to "suplex" an immovable rod
// turning it into a glorified potted plant, and giving them an
// achievement. Can also be used on rod-form wizards.
// Normally only present in the mind of a Research Director.
#define TRAIT_ROD_SUPLEX "rod_suplex"
/// The mob has an active mime vow of silence, and thus is unable to speak and has other mime things going on
#define TRAIT_MIMING "miming"

/// This mob is phased out of reality from magic, either a jaunt or rod form
#define TRAIT_MAGICALLY_PHASED "magically_phased"

//SKILLS
#define TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE "underwater_basketweaving"
#define TRAIT_WINE_TASTER "wine_taster"
#define TRAIT_BONSAI "bonsai"
#define TRAIT_LIGHTBULB_REMOVER "lightbulb_remover"
#define TRAIT_KNOW_CYBORG_WIRES "know_cyborg_wires"
#define TRAIT_KNOW_ENGI_WIRES "know_engi_wires"
#define TRAIT_ENTRAILS_READER "entrails_reader"
#define TRAIT_SABRAGE_PRO "sabrage_pro"
/// this skillchip trait lets you wash brains in washing machines to heal them
#define TRAIT_BRAINWASHING "brainwashing"
/// Allows chef's to chefs kiss their food, to make them with love
#define TRAIT_CHEF_KISS "chefs_kiss"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENTCRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no-floating-animation"

/// Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune" //Used by lava turfs and The Floor Is Lava.
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
#define TRAIT_SNOWSTORM_IMMUNE "snowstorm_immune"
#define TRAIT_RADSTORM_IMMUNE "radstorm_immune"
#define TRAIT_VOIDSTORM_IMMUNE "voidstorm_immune"
#define TRAIT_WEATHER_IMMUNE "weather_immune" //Immune to ALL weather effects.

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND "disabled-by-wound"
/// This movable atom has the explosive block element
#define TRAIT_BLOCKING_EXPLOSIVES "blocking_explosives"

/// Mobs with this trait can't send the mining shuttle console when used outside the station itself
#define TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION "forbid_mining_shuttle_console_outside_station"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"
///every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

/// Climbable trait, given and taken by the climbable element when added or removed. Exists to be easily checked via HAS_TRAIT().
#define TRAIT_CLIMBABLE "trait_climbable"

/// Used by the honkspam element to avoid spamming the sound. Amusing considering its name.
#define TRAIT_HONKSPAMMING "trait_honkspamming"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"

///Marks the item as having been transmuted. Functionally blacklists the item from being recycled or sold for materials.
#define TRAIT_MAT_TRANSMUTED "transmuted"

// cargo traits
///If the item will block the cargo shuttle from flying to centcom
#define TRAIT_BANNED_FROM_CARGO_SHUTTLE "banned_from_cargo_shuttle"
///If the item's contents are immune to the missing item manifest error
#define TRAIT_NO_MISSING_ITEM_ERROR "no_missing_item_error"

///SSeconomy trait, if the market is crashing and people can't withdraw credits from ID cards.
#define TRAIT_MARKET_CRASHING "market_crashing"

// item traits
#define TRAIT_NODROP "nodrop"
/// cannot be inserted in a storage.
#define TRAIT_NO_STORAGE_INSERT "no_storage_insert"
/// Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_T_RAY_VISIBLE "t-ray-visible"
/// If this item's been grilled
#define TRAIT_FOOD_GRILLED "food_grilled"
/// If this item's been fried
#define TRAIT_FOOD_FRIED "food_fried"
/// This is a silver slime created item
#define TRAIT_FOOD_SILVER "food_silver"
/// If this item's been made by a chef instead of being map-spawned or admin-spawned or such
#define TRAIT_FOOD_CHEF_MADE "food_made_by_chef"
/// The items needs two hands to be carried
#define TRAIT_NEEDS_TWO_HANDS "needstwohands"
/// Can't be catched when thrown
#define TRAIT_UNCATCHABLE "uncatchable"
/// Fish in this won't die
#define TRAIT_FISH_SAFE_STORAGE "fish_case"
/// Stuff that can go inside fish cases
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile"
/// Plants that were mutated as a result of passive instability, not a mutation threshold.
#define TRAIT_PLANT_WILDMUTATE "wildmutation"
/// If you hit an APC with exposed internals with this item it will try to shock you
#define TRAIT_APC_SHOCKING "apc_shocking"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"
/// Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"
/// Disallows this item from being pricetagged with a barcode
#define TRAIT_NO_BARCODES "no_barcode"
/// Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"
/// Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"
/// Prevents the same person from being chosen multiple times for kidnapping objective
#define TRAIT_HAS_BEEN_KIDNAPPED "has_been_kidnapped"
/// An item still plays its hitsound even if it has 0 force, instead of the tap
#define TRAIT_CUSTOM_TAP_SOUND "no_tap_sound"

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE "alcohol_tolerance"
#define TRAIT_AGEUSIA "ageusia"
#define TRAIT_HEAVY_SLEEPER "heavy_sleeper"
#define TRAIT_NIGHT_VISION "night_vision"
#define TRAIT_LIGHT_STEP "light_step"
#define TRAIT_SPIRITUAL "spiritual"
#define TRAIT_CLOWN_ENJOYER "clown_enjoyer"
#define TRAIT_MIME_FAN "mime_fan"
#define TRAIT_VORACIOUS "voracious"
#define TRAIT_SELF_AWARE "self_aware"
#define TRAIT_FREERUNNING "freerunning"
#define TRAIT_SKITTISH "skittish"
#define TRAIT_POOR_AIM "poor_aim"
#define TRAIT_PROSOPAGNOSIA "prosopagnosia"
#define TRAIT_TAGGER "tagger"
#define TRAIT_PHOTOGRAPHER "photographer"
#define TRAIT_MUSICIAN "musician"
#define TRAIT_LIGHT_DRINKER "light_drinker"
#define TRAIT_EMPATH "empath"
#define TRAIT_FRIENDLY "friendly"
#define TRAIT_GRABWEAKNESS "grab_weakness"
#define TRAIT_SNOB "snob"
#define TRAIT_BALD "bald"
#define TRAIT_SHAVED "shaved"
#define TRAIT_BADTOUCH "bad_touch"
#define TRAIT_EXTROVERT "extrovert"
#define TRAIT_INTROVERT "introvert"
#define TRAIT_ANXIOUS "anxious"
#define TRAIT_SMOKER "smoker"
#define TRAIT_POSTERBOY "poster_boy"
#define TRAIT_THROWINGARM "throwing_arm"

/// Gives you the Shifty Eyes quirk, rarely making people who examine you think you examined them back even when you didn't
#define TRAIT_SHIFTY_EYES "shifty_eyes"

///Trait for the gamer quirk.
#define TRAIT_GAMER "gamer"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
/// Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
/// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

/// Used to prevent multiple floating blades from triggering over the same target
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

/// Minor trait used for beakers, or beaker-ishes. [/obj/item/reagent_containers], to show that they've been used in a reagent grinder.
#define TRAIT_MAY_CONTAIN_BLENDED_DUST "may_contain_blended_dust"

/// Trait put on [/mob/living/carbon/human]. If that mob has a crystal core, also known as an ethereal heart, it will not try to revive them if the mob dies.
#define TRAIT_CANNOT_CRYSTALIZE "cannot_crystalize"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// Trait applied when the MMI component is added to an [/obj/item/integrated_circuit]
#define TRAIT_COMPONENT_MMI "component_mmi"

/// Trait applied when an integrated circuit/module becomes undupable
#define TRAIT_CIRCUIT_UNDUPABLE "circuit_undupable"

/// Hearing trait that is from the hearing component
#define CIRCUIT_HEAR_TRAIT "circuit_hear"

/// PDA Traits. This one makes PDAs explode if the user opens the messages menu
#define TRAIT_PDA_MESSAGE_MENU_RIGGED "pda_message_menu_rigged"
/// This one denotes a PDA has received a rigged message and will explode when the user tries to reply to a rigged PDA message
#define TRAIT_PDA_CAN_EXPLODE "pda_can_explode"

/// If present on a [/mob/living/carbon], will make them appear to have a medium level disease on health HUDs.
#define TRAIT_DISEASELIKE_SEVERITY_MEDIUM "diseaselike_severity_medium"

/// trait denoting someone will crawl faster in soft crit
#define TRAIT_TENACIOUS "tenacious"

/// trait denoting someone will sometimes recover out of crit
#define TRAIT_UNBREAKABLE "unbreakable"

/// trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"

/// this is used to bypass tongue language restrictions but not tongue disabilities
#define TRAIT_TOWER_OF_BABEL "tower_of_babel"

/// This target has recently been shot by a marksman coin and is very briefly immune to being hit by one again to prevent recursion
#define TRAIT_RECENTLY_COINED "recently_coined"

/// Receives echolocation images.
#define TRAIT_ECHOLOCATION_RECEIVER "echolocation_receiver"
/// Echolocation has a higher range.
#define TRAIT_ECHOLOCATION_EXTRA_RANGE "echolocation_extra_range"

// common trait sources
#define TRAIT_GENERIC "generic"
#define UNCONSCIOUS_TRAIT "unconscious"
#define EYE_DAMAGE "eye_damage"
#define EAR_DAMAGE "ear_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_TRAIT "magic"
#define TRAUMA_TRAIT "trauma"
#define FLIGHTPOTION_TRAIT "flightpotion"
/// Trait inherited by experimental surgeries
#define EXPERIMENTAL_SURGERY_TRAIT "experimental_surgery"
#define DISEASE_TRAIT "disease"
#define SPECIES_TRAIT "species"
#define ORGAN_TRAIT "organ"
/// cannot be removed without admin intervention
#define ROUNDSTART_TRAIT "roundstart"
#define JOB_TRAIT "job"
#define CYBORG_ITEM_TRAIT "cyborg-item"
/// Any traits granted by quirks.
#define QUIRK_TRAIT "quirk_trait"
/// (B)admins only.
#define ADMIN_TRAIT "admin"
/// Any traits given through a smite.
#define SMITE_TRAIT "smite"
#define CHANGELING_TRAIT "changeling"
#define CULT_TRAIT "cult"
#define LICH_TRAIT "lich"
/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"
#define ABSTRACT_ITEM_TRAIT "abstract-item"
/// A trait given by any status effect
#define STATUS_EFFECT_TRAIT "status-effect"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

#define CLOTHING_TRAIT "clothing"
#define HELMET_TRAIT "helmet"
/// inherited from the mask
#define MASK_TRAIT "mask"
/// inherited from your sweet kicks
#define SHOES_TRAIT "shoes"
/// Trait inherited by implants
#define IMPLANT_TRAIT "implant"
#define GLASSES_TRAIT "glasses"
/// inherited from riding vehicles
#define VEHICLE_TRAIT "vehicle"
#define INNATE_TRAIT "innate"
#define CRIT_HEALTH_TRAIT "crit_health"
#define OXYLOSS_TRAIT "oxyloss"
/// Trait sorce for "was recently shocked by something"
#define WAS_SHOCKED "was_shocked"
#define TURF_TRAIT "turf"
/// trait associated to being buckled
#define BUCKLED_TRAIT "buckled"
/// trait associated to being held in a chokehold
#define CHOKEHOLD_TRAIT "chokehold"
/// trait associated to resting
#define RESTING_TRAIT "resting"
/// trait associated to a stat value or range of
#define STAT_TRAIT "stat"
#define STATION_TRAIT "station-trait"
/// obtained from mapping helper
#define MAPPING_HELPER_TRAIT "mapping-helper"
/// Trait associated to wearing a suit
#define SUIT_TRAIT "suit"
/// Trait associated to lying down (having a [lying_angle] of a different value than zero).
#define LYING_DOWN_TRAIT "lying-down"
/// Trait associated to lacking electrical power.
#define POWER_LACK_TRAIT "power-lack"
/// Trait associated to lacking motor movement
#define MOTOR_LACK_TRAIT "motor-lack"
/// Trait associated with mafia
#define MAFIA_TRAIT "mafia"
/// Trait associated with highlander
#define HIGHLANDER_TRAIT "highlander"
/// Trait given from playing pretend with baguettes
#define SWORDPLAY_TRAIT "swordplay"
/// Trait given by being recruited as a nuclear operative
#define NUKE_OP_MINION_TRAIT "nuke-op-minion"

///generic atom traits
/// Trait from [/datum/element/rust]. Its rusty and should be applying a special overlay to denote this.
#define TRAIT_RUSTY "rust_trait"
///stops someone from splashing their reagent_container on an object with this trait
#define TRAIT_DO_NOT_SPLASH "do_not_splash"
/// Marks an atom when the cleaning of it is first started, so that the cleaning overlay doesn't get removed prematurely
#define TRAIT_CURRENTLY_CLEANING "currently_cleaning"

// unique trait sources, still defines
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
/// changelings with this trait can no longer talk over the hivemind
#define CHANGELING_HIVEMIND_MUTE "ling_mute"
#define HIGHLANDER "highlander"
#define TRAIT_HULK "hulk"
#define STASIS_MUTE "stasis"
#define GENETICS_SPELL "genetics_spell"
#define EYES_COVERED "eyes_covered"
#define NO_EYES "no_eyes"
#define HYPNOCHAIR_TRAIT "hypnochair"
#define FLASHLIGHT_EYES "flashlight_eyes"
#define IMPURE_OCULINE "impure_oculine"
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
#define SLEEPING_CARP_TRAIT "sleeping_carp"
#define TIMESTOP_TRAIT "timestop"
#define LIFECANDLE_TRAIT "lifecandle"
#define VENTCRAWLING_TRAIT "ventcrawling"
#define SPECIES_FLIGHT_TRAIT "species-flight"
#define FROSTMINER_ENRAGE_TRAIT "frostminer-enrage"
#define NO_GRAVITY_TRAIT "no-gravity"
#define LEAPING_TRAIT "leaping"
#define LEAPER_BUBBLE_TRAIT "leaper-bubble"
#define DNA_VAULT_TRAIT "dna_vault"
/// sticky nodrop sounds like a bad soundcloud rapper's name
#define STICKY_NODROP "sticky-nodrop"
#define SKILLCHIP_TRAIT "skillchip"
#define BUSY_FLOORBOT_TRAIT "busy-floorbot"
#define PULLED_WHILE_SOFTCRIT_TRAIT "pulled-while-softcrit"
#define LOCKED_BORG_TRAIT "locked-borg"
/// trait associated to not having locomotion appendages nor the ability to fly or float
#define LACKING_LOCOMOTION_APPENDAGES_TRAIT "lacking-locomotion-appengades"
#define CRYO_TRAIT "cryo"
/// trait associated to not having fine manipulation appendages such as hands
#define LACKING_MANIPULATION_APPENDAGES_TRAIT "lacking-manipulation-appengades"
#define HANDCUFFED_TRAIT "handcuffed"
/// Trait granted by [/obj/item/warp_whistle]
#define WARPWHISTLE_TRAIT "warpwhistle"
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"
/// Trait applied by [/datum/component/soulstoned]
#define SOULSTONE_TRAIT "soulstone"
/// Trait applied to slimes by low temperature
#define SLIME_COLD "slime-cold"
/// Trait applied to mobs by being tipped over
#define TIPPED_OVER "tipped-over"
/// Trait applied to PAIs by being folded
#define PAI_FOLDED "pai-folded"
/// Trait applied to brain mobs when they lack external aid for locomotion, such as being inside a mech.
#define BRAIN_UNAIDED "brain-unaided"
/// Trait applied by MODsuits.
#define MOD_TRAIT "mod"
/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"
/// Trait granted by the berserker hood.
#define BERSERK_TRAIT "berserk_trait"
/// Trait granted by [/obj/item/rod_of_asclepius]
#define HIPPOCRATIC_OATH_TRAIT "hippocratic_oath"
/// Trait granted by [/datum/status_effect/blooddrunk]
#define BLOODDRUNK_TRAIT "blooddrunk"
/// Trait granted by lipstick
#define LIPSTICK_TRAIT "lipstick_trait"
/// Self-explainatory.
#define BEAUTY_ELEMENT_TRAIT "beauty_element"
#define MOOD_DATUM_TRAIT "mood_datum"
#define DRONE_SHY_TRAIT "drone_shy"
/// Pacifism trait given by stabilized light pink extracts.
#define STABILIZED_LIGHT_PINK_TRAIT "stabilized_light_pink"
/// Given by the multiple_lives component to the previous body of the mob upon death.
#define EXPIRED_LIFE_TRAIT "expired_life"
/// Trait given to an atom/movable when they orbit something.
#define ORBITING_TRAIT "orbiting"
/// From the item_scaling element
#define ITEM_SCALING_TRAIT "item_scaling"
/// Trait given by choking
#define CHOKING_TRAIT "choking_trait"
/// Trait given by hallucinations
#define HALLUCINATION_TRAIT "hallucination_trait"

/**
* Trait granted by [/mob/living/carbon/Initialize] and
* granted/removed by [/obj/item/organ/internal/tongue]
* Used for ensuring that carbons without tongues cannot taste anything
* so it is added in Initialize, and then removed when a tongue is inserted
* and readded when a tongue is removed.
*/
#define NO_TONGUE_TRAIT "no_tongue_trait"

/// Trait granted by [/mob/living/silicon/robot]
/// Traits applied to a silicon mob by their model.
#define MODEL_TRAIT "model_trait"

/// Trait granted by [mob/living/silicon/ai]
/// Applied when the ai anchors itself
#define AI_ANCHOR_TRAIT "ai_anchor"
/// Trait from [/datum/antagonist/nukeop/clownop]
#define CLOWNOP_TRAIT "clownop"

///Traits given by station traits
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_UNNATURAL_ATMOSPHERE "station_trait_unnatural_atmosphere"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_CYBERNETIC_REVOLUTION "station_trait_cybernetic_revolution"
#define STATION_TRAIT_BIGGER_PODS "station_trait_bigger_pods"
#define STATION_TRAIT_SMALLER_PODS "station_trait_smaller_pods"

///From the market_crash event
#define MARKET_CRASH_EVENT_TRAIT "crashed_market_event"

/// Denotes that this id card was given via the job outfit, aka the first ID this player got.
#define TRAIT_JOB_FIRST_ID_CARD "job_first_id_card"
/// ID cards with this trait will attempt to forcibly occupy the front-facing ID card slot in wallets.
#define TRAIT_MAGNETIC_ID_CARD "magnetic_id_card"
/// ID cards with this trait have special appraisal text.
#define TRAIT_TASTEFULLY_THICK_ID_CARD "impressive_very_nice"

/// Traits granted to items due to their chameleon properties.
#define CHAMELEON_ITEM_TRAIT "chameleon_item_trait"

/// This human wants to see the color of their glasses, for some reason
#define TRAIT_SEE_GLASS_COLORS "see_glass_colors"

/// this mob is under the effects of the power chord
#define TRAIT_POWER_CHORD "power_chord"

// Radiation defines

/// Marks that this object is irradiated
#define TRAIT_IRRADIATED "iraddiated"

/// Harmful radiation effects, the toxin damage and the burns, will not occur while this trait is active
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

/// This clothing protects the user from radiation.
/// This should not be used on clothing_traits, but should be applied to the clothing itself.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

/// Whether or not this item will allow the radiation SS to go through standard
/// radiation processing as if this wasn't already irradiated.
/// Basically, without this, COMSIG_IN_RANGE_OF_IRRADIATION won't fire once the object is irradiated.
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"

// Traits to heal for

/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

/// Ignore Crew monitor Z levels
#define TRAIT_MULTIZ_SUIT_SENSORS "multiz_suit_sensors"

/// Ignores body_parts_covered during the add_fingerprint() proc. Works both on the person and the item in the glove slot.
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

/// Currently fishing
#define TRAIT_GONE_FISHING "fishing"

/// Makes a species be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

/// Makes a species be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

/// Makes a species be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"

/// Is runechat for this atom/movable currently disabled, regardless of prefs or anything?
#define TRAIT_RUNECHAT_HIDDEN "runechat_hudden"

/// some trait sorces dirived from bodyparts BODYPART_TRAIT is generic.
#define BODYPART_TRAIT "bodypart"
#define HEAD_TRAIT "head"
#define CHEST_TRAIT "chest"
#define RIGHT_ARM_TRAIT "right_arm"
#define LEFT_ARM_TRAIT "left_arm"
#define RIGHT_LEG_TRAIT "right_leg"
#define LEFT_LEG_TRAIT "left_leg"

/// Trait given by echolocation component.
#define ECHOLOCATION_TRAIT "echolocation"

///without a human having this trait, they speak as if they have no tongue.
#define TRAIT_SPEAKS_CLEARLY "speaks_clearly"

// specific sources for TRAIT_SPEAKS_CLEARLY

///trait source that tongues should use
#define SPEAKING_FROM_TONGUE "tongue"
///trait source that sign language should use
#define SPEAKING_FROM_HANDS "hands"
