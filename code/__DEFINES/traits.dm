#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

//trait accessor defines.
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
				if ((!_S && (_T != SOURCE_ROUNDSTART)) || (_T in _S)) { \
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

//Mob traits.

//Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"

//Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"

//Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"

//Forces user to stay standing.
#define TRAIT_FORCED_STANDING "forcedstanding"

//Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"

//Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"

//Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"

//Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"

//Doesn't miss attacks
#define TRAIT_PERFECT_ATTACKER "perfect_attacker"
#define TRAIT_INCAPACITATED "incapacitated"

//In some kind of critical condition. Is able to succumb.
#define TRAIT_CRITICAL_CONDITION "critical_condition"

//Whitelist for mobs that can read or write.
#define TRAIT_LITERATE "literate"

//Blacklist for mobs that can't read or write.
#define TRAIT_ILLITERATE "illiterate"
#define TRAIT_BLIND "blind"
#define TRAIT_MUTE "mute"
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF "deaf"
#define TRAIT_NEARSIGHTED "nearsighted"
#define TRAIT_FAT "fat" //Do we need 2 traits for fat? There is also TRAIT_OBESE...
#define TRAIT_HUSK "husk"

///Blacklisted from being revived via defibrilator.
#define TRAIT_DEFIB_BLACKLISTED "defib_blacklisted"
#define TRAIT_BADDNA "baddna"
#define TRAIT_CLUMSY "clumsy"

//means that you can't use weapons with normal trigger guards.
#define TRAIT_CHUNKY_FINGERS "chunky_fingers"
#define TRAIT_DUMB "dumb"

//Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_ADVANCED_TOOL_USER "advanced_tool_user"

//Antagonizes the above.
#define TRAIT_DISCOORDINATED_TOOL_USER "discoordinated_tool_user"
#define TRAIT_PACIFISM "pacifism"
#define TRAIT_IGNORE_SLOWDOWN "ignore_slowdown"
#define TRAIT_IGNORE_DAMAGE_SLOWDOWN "ignore_damage_slowdown"

//Makes it so the mob can use guns regardless of tool user status.
#define TRAIT_GUN_NATURAL "gun_natural"

//Causes death-like unconsciousness
#define TRAIT_DEATH_COMA "death_coma"

//Makes the owner appear as dead to most forms of medical examination
#define TRAIT_FAKE_DEATH "fake_death"
#define TRAIT_DISFIGURED "disfigured"

//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_XENO_HOST "xeno_host"
#define TRAIT_STUN_IMMUNE "stun_immunity"
#define TRAIT_BATON_RESISTANCE "baton_resistance"

//Anti Dual-baton cooldown bypass exploit.
#define TRAIT_BATON_COOLDOWN "batoned_cooldown"
#define TRAIT_SLEEP_IMMUNE "sleep_immunity"
#define TRAIT_PUSH_IMMUNE "push_immunity"
#define TRAIT_SHOCK_IMMUNE "shock_immunity"
#define TRAIT_TESLA_SHOCK_IMMUNE "tesla_shock_immunity"
/// Is this atom being actively shocked? Used to prevent repeated shocks.
#define TRAIT_BEING_SHOCKED "shocked"
#define TRAIT_STABLE_HEART "stable_heart"
//Prevents you from leaving your corpse.
#define TRAIT_CORPSE_LOCKED "corpse_locked"
#define TRAIT_STABLE_LIVER "stable_liver"
#define TRAIT_VATGROWN "vatgrown"
#define TRAIT_RESISTHEAT "resist_heat"

///For when you've gotten a power from a dna vault.
#define TRAIT_USED_DNA_VAULT "used_dna_vault"

//For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESIST_HEAT_HANDS "resist_heat_hands_only"
#define TRAIT_RESIST_COLD "resist_cold"
#define TRAIT_RESIST_HIGH_PRESSURE "resist_high_pressure"
#define TRAIT_RESIST_LOW_PRESSURE "resist_low_pressure"

//This human is immune to the effects of being exploded. (ex_act).
#define TRAIT_BOMB_IMMUNE "bomb_immunity"
#define TRAIT_RAD_IMMUNE "rad_immunity"
#define TRAIT_GENELESS "geneless"
#define TRAIT_VIRUS_IMMUNE "virus_immunity"
#define TRAIT_PIERCE_IMMUNE "pierce_immunity"
#define TRAIT_NO_DISMEMBER "dismember_immunity"
#define TRAIT_FLAME_IMMUNE "fire_immunity"
#define TRAIT_NO_FIRE_SPREAD "no_fire_spreading"

//Prevents plasmamen from self-igniting if only their helmet is missing.
#define TRAIT_HEAD_IGNITION_IMMUNE "head_self_ignition_immune"
#define TRAIT_NO_GUNS "no_guns"
#define TRAIT_NO_HUNGER "no_hunger"
#define TRAIT_NO_METABOLISM "no_metabolism"
#define TRAIT_NO_CLONE_LOSS "no_clone_loss"
#define TRAIT_TOX_IMMUNE "toxin_immune"
#define TRAIT_EASY_DISMEMBER "easy_dismember"
#define TRAIT_LIMB_ATTACHMENT "limb_attachment"
#define TRAIT_NO_LIMB_DISABLE "no_limb_disable"
#define TRAIT_EASILY_WOUNDED "easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED "hard_limb_wound"
#define TRAIT_NEVER_WOUNDED "never_wounded"
#define TRAIT_TOXIN_LOVER "toxin_lover"

//Gets a mood boost from being in the hideout.
#define TRAIT_VAL_CORRIN_MEMBER "val_corrin_member"

//reduces the use time of syringes, pills, patches and medigels but only when using on someone.
#define TRAIT_FAST_MED "fast_med_use"
#define TRAIT_NO_BREATH "no_breath"
#define TRAIT_ANTI_MAGIC "anti_magic"
#define TRAIT_HOLY "holy"

//This allows a person who has antimagic to cast spells without getting blocked.
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
#define TRAIT_DEPRESSION "depression"
#define TRAIT_JOLLY "jolly"
#define TRAIT_NO_CRIT_DAMAGE "no_crit"
#define TRAIT_NO_SLIP_WATER "no_slip_water"
#define TRAIT_NOSLIPALL "noslip_all"
#define TRAIT_NO_DEATH "no_death"
#define TRAIT_NO_HARD_CRIT "no_hard_crit"
#define TRAIT_NO_SOFT_CRIT "no_soft_crit"
#define TRAIT_MINDSHIELD "mindshield"
#define TRAIT_DISSECTED "dissected"

//Can hear observers.
#define TRAIT_SIXTH_SENSE "sixth_sense"
#define TRAIT_FEARLESS "fearless"

//Ignores darkness for hearing.
#define TRAIT_HEAR_THROUGH_DARKNESS "hear_through_darkness"

//These are used for brain-based paralysis, where replacing the limb won't fix it.
#define TRAIT_PARALYSIS_L_ARM "para_l_arm"
#define TRAIT_PARALYSIS_R_ARM "para_r_arm"
#define TRAIT_PARALYSIS_L_LEG "para_l_leg"
#define TRAIT_PARALYSIS_R_LEG "para_r_leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot_open_presents"
#define TRAIT_PRESENT_VISION "present_vision"
#define TRAIT_DISK_VERIFIER "disk_verifier"
#define TRAIT_NO_MOB_SWAP "no_mob_swap"

//Can examine IDs to see if they are roundstart.
#define TRAIT_ID_APPRAISER "id_appraiser"

//Gives us turf, mob and object vision through walls.
#define TRAIT_XRAY_VISION "xray_vision"

//Gives us mob vision through walls and slight night vision.
#define TRAIT_THERMAL_VISION "thermal_vision"

//Gives us turf vision through walls and slight night vision.
#define TRAIT_MESON_VISION "meson_vision"

//Gives us Night vision.
#define TRAIT_TRUE_NIGHT_VISION "true_night_vision"

//Negates our gravity, letting us move normally on floors in 0-g.
#define TRAIT_NEGATE_GRAVITY "negates_gravity"

//Lets us scan reagents.
#define TRAIT_REAGENT_SCANNER "reagent_scanner"

//Lets us scan machine parts and tech unlocks.
#define TRAIT_RESEARCH_SCANNER "research_scanner"

//Can weave webs into cloth.
#define TRAIT_WEB_WEAVER "web_weaver"
#define TRAIT_ABDUCTOR_TRAINING "abductor_training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor_scientist_training"
#define TRAIT_SURGEON "surgeon"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_SOOTHED_THROAT "soothed_throat"
#define TRAIT_BOOZE_SLIDER "booze_slider"

//We place people into a fireman carry quicker than standard.
#define TRAIT_QUICK_CARRY "quick_carry"

//We place people into a fireman carry even faster than quick_carry.
#define TRAIT_QUICKER_CARRY "quicker_carry"
#define TRAIT_QUICK_BUILD "quick_build"

//We can handle 'dangerous' plants in botany safely.
#define TRAIT_PLANT_SAFE "plant_safe"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible_speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_MEDICAL_HUD "med_hud"
#define TRAIT_SECURITY_HUD "sec_hud"

//For something granting you a diagnostic hud.
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"

//Is a medbot healing you
#define TRAIT_MEDIBOT_GOTO_PATIENT "medbot_goto_patient"
#define TRAIT_PASSTABLE "passtable"

//Makes you immune to flashes.
#define TRAIT_NO_FLASH "no_flash"

//Prevents xeno huggies implanting skeletons
#define TRAIT_XENO_IMMUNE "xeno_immune"
#define TRAIT_NAIVE "naive"
#define TRAIT_PRIMITIVE "primitive"
#define TRAIT_GUNFLIP "gunflip"

//Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost"
#define TRAIT_SPACEWALK "spacewalk"

//Gets double arcade prizes
#define TRAIT_GAMERGOD "gamer_god"
#define TRAIT_GIANT "giant"
#define TRAIT_DWARF "dwarf"

//Makes your footsteps completely silent
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"

//Hnnnnnnnggggg..... you're pretty good....
#define TRAIT_NICE_SHOT "nice_shot"

//Prevents the damage done by a brain tumor.
#define TRAIT_TUMOR_SUPPRESSED "brain_tumor_suppressed"
/// overrides the update_fire proc to always add fire (for lava)
#define TRAIT_PERMANENTLY_ONFIRE "permanently_onfire"

//Galactic Common Sign Language.
#define TRAIT_SIGN_LANG "sign_language"

//This mob is able to use sign language over the radio.
#define TRAIT_CAN_SIGN_ON_COMMS "can_sign_on_comms"

//Nobody can use martial arts on this mob.
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune"

//You've been cursed with a living duffelbag, and can't have more added.
#define TRAIT_DUFFEL_CURSE_PROOF "duffel_cursed"

//Immune to being afflicted by time stop (spell).
#define TRAIT_TIME_STOP_IMMUNE "time_stop_immune"

//Revenants draining you only get a very small benefit.
#define TRAIT_WEAK_SOUL "weak_soul"

//This mob has no soul.
#define TRAIT_NO_SOUL "no_soul"

//Prevents mob from riding mobs when buckled onto something.
#define TRAIT_CANT_RIDE "cant_ride"

//Prevents a mob from being unbuckled, currently only used to prevent people from falling over on the tram.
#define TRAIT_CANNOT_BE_UNBUCKLED "cannot_be_unbuckled"

//From heparin, makes open bleeding wounds rapidly spill more blood.
#define TRAIT_BLOODY_MESS "bloody_mess"

//From coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages.
#define TRAIT_COAGULATING "coagulating"

//From anti-convulsant medication against seizures.
#define TRAIT_ANTI_CONVULSANT "anticonvulsant"

//The holder of this trait has antennae or whatever that hurt a ton when noogied.
#define TRAIT_ANTENNAE "antennae"

//Blowing kisses actually does damage to the victim.
#define TRAIT_KISS_OF_DEATH "kiss_of_death"

//Used to activate french kissing.
#define TRAIT_GARLIC_BREATH "kiss_of_garlic_death"

//Used on limbs in the process of turning a human into a plasmaman while in plasma lava.
#define TRAIT_PLASMA_BURNT "plasma_burnt"

//Addictions don't tick down, basically they're permanently addicted.
#define TRAIT_HOPELESSLY_ADDICTED "hopelessly_addicted"

//This mob has a cult halo.
#define TRAIT_CULT_HALO "cult_halo"

//Their eyes glow an unnatural red colour. Currently used to set special examine text on humans. Does not
//guarantee the mob's eyes are coloured red, nor that there is any visible glow on their character sprite.
#define TRAIT_GLOWING_RED_EYES "glowing_red_eyes"

//Their eyes are bloodshot. Currently used to set special examine text on humans. Examine text is overridden by TRAIT_GLOWING_RED_EYES.
#define TRAIT_BLOODSHOT_EYES "bloodshot_eyes"

//This mob should never close UI even if it doesn't have a client
#define TRAIT_PRESERVE_UI "preserve_ui_without_client"

//Lets the mob use flight potions
#define TRAIT_ALLOW_FLIGHT_POTION "allow_flight_potion"

//This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"

//Someone can safely be attacked with honorbound with ONLY a combat mode check, the trait is assuring holding a weapon and hitting won't hurt them..
#define TRAIT_ALLOWED_HONORBOUND_ATTACK "allowed_honorbound_attack"

//The user is sparring
#define TRAIT_SPARRING "sparring"

//The user is currently challenging an elite mining mob. Prevents him from challenging another until he's either lost or won.
#define TRAIT_ELITE_CHALLENGER "elite_challenger"

//For living mobs. It signals that the mob shouldn't have their data written in an external json for persistence.
#define TRAIT_DONT_WRITE_MEMORY "dont_write_memory"

//This mob can be painted with the spraycan. If you see this, please make it so i can spraypain the engi-borg.
#define TRAIT_SPRAY_PAINTABLE "spray_paintable"

//This person is blushing. Probobly me.
#define TRAIT_BLUSHING "blushing"

//This person is crying. Also me probobly.
#define TRAIT_CRYING "crying"

//For simple mobs controlled by a player. Sends a death alert in deadchat, used by space dragons, morphs,
//revenants, elite lavaland mobs, and brood spiders.
#define TRAIT_ALERT_GHOSTS_ON_DEATH "trait_alert_ghosts_on_death"

//This carbon doesn't bleed
#define TRAIT_NO_BLEED "no_bleed"

//This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack
//from bags or lockers as long as any other conditions are met.
#define TRAIT_AI_BAGATTACK "bagattack"

//This mobs bodyparts are invisible but still clickable.
#define TRAIT_INVISIBLE_MAN "invisible_man"

//Don't draw external organs/species features like wings, horns, frills and stuff.
#define TRAIT_HIDE_EXTERNAL_ORGANS "hide_external_organs"

///When people are floating from zero-grav or something, we can move around freely!
#define TRAIT_FREE_FLOAT_MOVEMENT "free_float_movement"

//You're immune to the hallucination effect of the supermatter, either
//through force of will, or equipment. Present on /mob or /datum/mind.
#define TRAIT_MADNESS_IMMUNE "madness_immune"

//Being close enough to the supermatter makes it heal at higher temperatures
//and emit less heat. Present on /mob or /datum/mind.
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"
/*
* Trait granted by various security jobs, and checked by [/obj/item/food/donut]
* When present in the mob's mind, they will always love donuts.
*/
#define TRAIT_DONUT_LOVER "donut_lover"

//`do_teleport` will not allow this atom to teleport.
#define TRAIT_NO_TELEPORT "no_teleport"

//Trait used by fugu glands to avoid double buffing.
#define TRAIT_FUGU_GLANDED "fugu_glanded"

//When someone with this trait fires a ranged weapon, their fire delays and click cooldowns are halved.
#define TRAIT_DOUBLE_TAP "double_tap"

//Trait applied to [/datum/mind] to stop someone from using the cursed hot springs to polymorph more than once.
#define TRAIT_HOT_SPRING_CURSED "hot_spring_cursed"

//If something has been engraved/cannot be engraved.
#define TRAIT_NOT_ENGRAVABLE "not_engravable"

//Whether or not orbiting is blocked or not.
#define TRAIT_ORBITING_FORBIDDEN "orbiting_forbidden"

//Whether a spider's consumed this mob.
#define TRAIT_SPIDER_CONSUMED "spider_consumed"

//Whether we're sneaking, from the alien sneak ability.

//Maybe worth generalizing into a general "is sneaky".
//"is stealth" trait in the future.
#define TRAIT_ALIEN_SNEAK "sneaking_alien"

//Item still allows you to examine items while blind and actively held.
#define TRAIT_BLIND_TOOL "blind_tool"

//Metabolisms

//Various jobs on the station have historically had better reactions
//to various drinks and foodstuffs. Security liking donuts is a classic
//example. Through years of training/abuse, their livers have taken
//a liking to those substances. Steal a sec officer's liver, eat donuts good.
//These traits are applied to /obj/item/organ/internal/liver.
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"
#define TRAIT_BALLMER_SCIENTIST "ballmer_scientist"

//This mob can strip other mobs.
#define TRAIT_CAN_STRIP "can_strip"

//Can use the nuclear device's UI, regardless of a lack of hands.
#define TRAIT_CAN_USE_NUKE "can_use_nuke"

//If present on a mob or mobmind, allows them to "suplex" an immovable rod
//turning it into a glorified potted plant, and giving them an
//achievement. Can also be used on rod-form wizards.
//Normally only present in the mind of a Research Director.
#define TRAIT_ROD_SUPLEX "rod_suplex"

//This mob is phased out of reality from magic, either a jaunt or rod form.
#define TRAIT_MAGICALLY_PHASED "magically_phased"

//Skills
#define TRAIT_UNDERWATER_BASKETWEAVER "underwater_basketweaver"
#define TRAIT_WINE_TASTER "wine_taster"
#define TRAIT_BONSAI "bonsai"
#define TRAIT_LIGHTBULB_REMOVER "lightbulb_remover"
#define TRAIT_KNOW_CYBORG_WIRES "know_cyborg_wires"
#define TRAIT_KNOW_ENGI_WIRES "know_engi_wires"
#define TRAIT_ENTRAILS_READER "entrails_reader"

//this skillchip trait lets you wash brains in washing machines to heal them.
#define TRAIT_BRAINWASHING "brainwashing"

///Movement type traits for movables. See elements/movetype_handler.dm.
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENT_CRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"

//Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no_floating_animation"

//Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune"

//Used by lava turfs and The Floor Is Lava.
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
#define TRAIT_SNOWSTORM_IMMUNE "snowstorm_immune"
#define TRAIT_RADSTORM_IMMUNE "radstorm_immune"
#define TRAIT_VOIDSTORM_IMMUNE "voidstorm_immune"
#define TRAIT_WEATHER_IMMUNE "weather_immune"

//Immune to ALL weather effects.

//Non-mob traits

//Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"

//Used for limbs.
#define TRAIT_DISABLED_BY_WOUND "disabled_by_wound"

//Mobs with this trait can't send the mining shuttle console when used outside the station itself.
#define TRAIT_DENY_MINING_SHUTTLE_CONTROL "deny_access_mining_shuttle_console"

//important_recursive_contents traits
//Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
//Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
#define TRAIT_AREA_SENSITIVE "area_sensitive"

//every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"

//every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

//Climbable trait, given and taken by the climbable element when added or removed. Exists to be easily checked via HAS_TRAIT().
#define TRAIT_CLIMBABLE "trait_climbable"

//Used by the honkspam element to tune the playback interval.
#define TRAIT_HONK_SPAM_LIMITER "honk_spam_limiter"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep_together"

///Marks the item as having been transmuted. Functionally blacklists the item from being recycled or sold for materials.
#define TRAIT_MAT_TRANSMUTED "was_transmuted"

///If the item will block the cargo shuttle from flying to centcom
#define TRAIT_BANNED_FROM_CARGO_SHUTTLE "banned_from_cargo_shuttle"

///SSeconomy trait, if the market is crashing and people can't withdraw credits from ID cards.
#define TRAIT_MARKET_CRASHING "market_crashing"
//item traits
#define TRAIT_NODROP "no_drop"

//cannot be inserted in a storage.
#define TRAIT_NO_STORAGE_INSERT "no_storage_insert"

//Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_T_RAY_VISIBLE "t_ray_visible"
#define TRAIT_GRILLED_FOOD "grilled_food"

//The items needs two hands to be carried
#define TRAIT_REQUIRES_TWO_HANDS "requires_two_hands"

//Can't be catched when thrown
#define TRAIT_UNCATCHABLE "uncatchable"

//Fish in this won't die
#define TRAIT_FISH_SAFE_STORAGE "fish_case"

//Stuff that can go inside fish cases
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile"

//Plants that were mutated as a result of passive instability, not a mutation threshold.
#define TRAIT_PLANT_WILDMUTATE "wildmutation"

//If you hit an APC with exposed internals with this item it will try to shock you
#define TRAIT_APC_SHOCKING "apc_shocking"

//Properly wielded two handed item
#define TRAIT_TWO_HANDED "two_handed"

//Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"

//Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"

//Disallows this item from being pricetagged with a barcode
#define TRAIT_NO_BARCODES "no_barcode"

//Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"

//Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"

//Prevents the same person from being chosen multiple times for kidnapping objective
#define TRAIT_KIDNAPPED "kidnapped"

//Quirk traits.
#define TRAIT_ALCOHOL_TOLERANCE "alcohol_tolerance"
#define TRAIT_AGEUSIA "ageusia"
#define TRAIT_HEAVY_SLEEPER "heavy_sleeper"
#define TRAIT_QUIRK_NIGHT_VISION "night_vision"
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
#define TRAIT_GRAB_WEAKNESS "grab_weakness"
#define TRAIT_SNOB "snob"
#define TRAIT_BALD "bald"
#define TRAIT_BADTOUCH "bad_touch"
#define TRAIT_EXTROVERT "extrovert"
#define TRAIT_INTROVERT "introvert"
#define TRAIT_ANXIOUS "anxious"
#define TRAIT_INSANITY "insanity"
#define TRAIT_SMOKER "smoker"
/// Gives you the Shifty Eyes quirk, rarely making people who examine you think you examined them back even when you didn't
#define TRAIT_SHIFTY_EYES "shifty_eyes"

//Trait for the gamer quirk.
#define TRAIT_GAMER "gamer"

//Trait for dryable items.
#define TRAIT_DRYABLE "trait_dryable"

//Trait for dried items.
#define TRAIT_DRIED "trait_dried"

//Trait for customizable reagent holder.
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"

//Used to prevent multiple floating blades from triggering over the same target.
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"

//Traits for ventcrawling.
//Both give access to ventcrawling, but *_NUDE requires the user to be
//wearing no clothes and holding no items. If both present, *_ALWAYS
//takes precedence.
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

//Minor trait used for beakers, or beaker-ishes. [/obj/item/reagent_containers], to show that they've been used in a reagent grinder.
#define TRAIT_MAY_CONTAIN_BLENDED_DUST "may_contain_blended_dust"

//Trait put on [/mob/living/carbon/human]. If that mob has a crystal core, also known as an ethereal heart, it will not try
//to revive them if the mob dies.
#define TRAIT_CANNOT_CRYSTALIZE "cannot_crystalize"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

//Trait applied when the MMI component is added to an [/obj/item/integrated_circuit].
#define TRAIT_COMPONENT_MMI "component_mmi"

//Trait applied when an integrated circuit/module is unable to be reproduced.
#define TRAIT_NO_CIRCUIT_REPLICATION "no_circuit_replication"

//Hearing source that is from the hearing component.
#define SOURCE_HEAR_CIRCUIT "circuit_hear"

//PDA Traits. This one makes PDAs explode if the user opens the messages menu.
#define TRAIT_PDA_MESSAGE_MENU_RIGGED "pda_message_menu_rigged"

//This one denotes a PDA has received a rigged message and will explode when the user tries to reply to a rigged PDA message.
#define TRAIT_PDA_CAN_EXPLODE "pda_can_explode"

//If present on a [/mob/living/carbon], will make them appear to have a medium level disease on health HUDs.
#define TRAIT_DISEASE_SEVERITY_MEDIUM "disease_severity_medium"

//Trait denoting someone will crawl faster in soft crit.
#define TRAIT_TENACIOUS "tenacious"

//Trait denoting someone will sometimes recover out of crit.
#define TRAIT_UNBREAKABLE "unbreakable"

//Trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"

///Turf trait for when a turf is transparent
#define TRAIT_TURF_Z_TRANSPARENT "turf_z_transparent"

//Common trait sources
#define SOURCE_GENERIC "generic"
#define SOURCE_UNCONSCIOUS "unconscious"
#define SOURCE_EYE_DAMAGE "eye_damage"
#define SOURCE_EAR_DAMAGE "ear_damage"
#define SOURCE_GENETIC_MUTATION "genetic"
#define SOURCE_OBESITY "obesity"
#define SOURCE_MAGIC "magic"
#define SOURCE_TRAUMA "trauma"
#define SOURCE_FLIGHT_POTION "flight_potion"

//Trait inherited by experimental surgeries.
#define SOURCE_EXPERIMENTAL_SURGERY "experimental_surgery"
#define SOURCE_DISEASE "disease"
#define SOURCE_SPECIES "species"
#define SOURCE_ORGAN "organ"

//cannot be removed without admin intervention.
#define SOURCE_ROUNDSTART "roundstart"
#define SOURCE_JOB "job"
#define SOURCE_CYBORG_ITEM "cyborg_item"

//Any traits granted by quirks.
#define SOURCE_QUIRK "quirk_trait"

//(B)admins only.
#define SOURCE_ADMIN "admin"

//Any traits given through a smite.
#define SOURCE_SMITE "smite"
#define SOURCE_CHANGELING "changeling"
#define SOURCE_CULT "cult"
#define SOURCE_LICH "lich"

//The item is magically cursed.
#define SOURCE_CURSED_ITEM(item_type) "cursed_item_[item_type]"
#define SOURCE_ABSTRACT_ITEM "abstract_item"

//A trait given by any status effect.
#define SOURCE_STATUS_EFFECT "status_effect"

//A trait given by a specific status effect (not sure why we need both but whatever!)
#define SOURCE_STATUS_EFFECT_ID(effect_id) "[effect_id]_trait"
#define SOURCE_CLOTHING "clothing"
#define SOURCE_HELMET "helmet"

//inherited from the mask.
#define SOURCE_MASK "mask"

//inherited from your sweet kicks.
#define SOURCE_SHOES "shoes"

//Trait inherited by implants.
#define SOURCE_IMPLANT "implant"
#define SOURCE_GLASSES "glasses"

//inherited from riding vehicles.
#define SOURCE_VEHICLE "vehicle"
#define SOURCE_INNATE "innate"
#define SOURCE_CRIT_HEALTH "crit_health"
#define SOURCE_OXYLOSS "oxyloss"
#define SOURCE_TURF "turf"

//trait associated to being buckled.
#define SOURCE_BUCKLED "buckled"

//trait associated to being held in a chokehold.
#define SOURCE_CHOKEHOLD "chokehold"

//trait associated to resting
#define SOURCE_RESTING "resting"

//trait associated to a stat value or range of.
#define SOURCE_STAT "stat"
#define SOURCE_STATION "station_trait"

//obtained from mapping helper
#define SOURCE_MAPPING_HELPER "mapping_helper"

//Trait associated to wearing a suit.
#define SOURCE_SUIT "suit"

//Trait associated to lying down (having a [lying_angle] of a different value than zero).
#define SOURCE_LYING_DOWN "lying_down"

//Trait associated to lacking electrical power.
#define SOURCE_POWER_LACK "power_lack"

//Trait associated to lacking motor movement.
#define SOURCE_MOTOR_LACK "motor_lack"

//Trait associated with mafia.
#define SOURCE_MAFIA "mafia"

///Generic atom traits.

//Trait from [/datum/element/rust]. Its rusty and should be applying a special overlay to denote this.
#define TRAIT_RUSTY "rust_trait"

///Stops someone from splashing their reagent_container on an object with this trait.
#define TRAIT_NO_SPLASH "no_splash"

//Marks an atom when the cleaning of it is first started, so that the cleaning overlay doesn't get removed prematurely.
#define TRAIT_ACTIVE_CLEANING "actively_cleaning"

//unique trait sources, still defines.
#define TRAIT_HULK "hulk"

//Denotes that this id card was given via the job outfit, aka the first ID this player got.
#define TRAIT_JOB_FIRST_ID_CARD "job_first_id_card"

///Traits given by station traits.
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
#define SOURCE_STATUE_MUTE "statue"
#define SOURCE_CHANGELING_DRAIN "drain"
#define SOURCE_ABYSSAL_GAZE_BLIND "abyssal_gaze"
#define SOURCE_HIGHLANDER "highlander"
#define SOURCE_STASIS_MUTE "stasis"
#define SOURCE_EYES_COVERED "eyes_covered"
#define SOURCE_HYPNOCHAIR "hypnochair"
#define SOURCE_FLASHLIGHT_EYES "flashlight_eyes"
#define SOURCE_IMPURE_OCULINE "impure_oculine"
#define SOURCE_BLINDFOLD "blindfolded"
#define SOURCE_SANTA "santa"
#define SOURCE_SCRYING "scrying_orb"
#define SOURCE_ABDUCTOR_ANTAGONIST "abductor_antagonist"
#define SOURCE_MEGAFAUNA "megafauna"
#define SOURCE_CLOWN_NUKE "clown_nuke"
#define SOURCE_STICKY_MOUSTACHE "sticky_moustache"
#define SOURCE_CHAINSAW_FRENZY "chainsaw_frenzy"
#define SOURCE_REVERSE_BEAR_TRAP "reverse_bear_trap"
#define SOURCE_CURSED_MASK "cursed_mask"
#define SOURCE_HIS_GRACE "his_grace"
#define SOURCE_HAND_REPLACEMENT "magic_hand"
#define SOURCE_HOT_POTATO "hot_potato"
#define SOURCE_SABRE_SUICIDE "sabre_suicide"
#define SOURCE_ABDUCTOR_VEST "abductor_vest"
#define SOURCE_CTF "capture_the_flag"
#define SOURCE_EYE_OF_GOD "eye_of_god"
#define SOURCE_SHAMEBRERO "shamebrero"
#define SOURCE_LOCKED_HELMET "locked_helmet"
#define SOURCE_SLEEPING_CARP "sleeping_carp"
#define SOURCE_TIMESTOP "timestop"
#define SOURCE_LIFECANDLE "lifecandle"
#define SOURCE_VENTCRAWLING "ventcrawling"
#define SOURCE_SPECIES_FLIGHT "species_flight"
#define SOURCE_FROSTMINER_ENRAGE "frostminer_enrage"
#define SOURCE_NO_GRAVITY "no_gravity"
#define SOURCE_LEAPING "leaping"
#define SOURCE_LEAPER_BUBBLE "leaper_bubble"
#define SOURCE_DNA_VAULT "dna_vault"

//sticky nodrop sounds like a bad soundcloud rapper's name.
#define SOURCE_STICKY_NO_DROP "sticky_no_drop"
#define SOURCE_SKILLCHIP "skillchip"
#define SOURCE_BUSY_FLOORBOT "busy_floorbot"
#define SOURCE_BUSY_PULLED_WHILE_SOFTCRIT "pulled_while_softcrit"
#define SOURCE_LOCKED_BORG "locked_borg"

//trait associated to not having locomotion appendages nor the ability to fly or float.
#define SOURCE_NO_LOCOMOTION_APPENDAGES "no_locomotion_appengades"
#define SOURCE_CRYO "cryo"

//trait associated to not having fine manipulation appendages such as hands.
#define SOURCE_NO_MANIPULATION_APPENDAGES "no_manipulation_appengades"
#define SOURCE_HANDCUFFED "handcuffed"

//Trait granted by [/obj/item/warp_whistle]
#define SOURCE_WARP_WHISTLE "warpwhistle"

//Trait applied by [/datum/component/soulstoned]
#define SOURCE_SOULSTONE "soulstone"

//Trait applied to slimes by low temperature.
#define SOURCE_SLIME_COLD "slime_cold"

//Trait applied to mobs by being tipped over.
#define SOURCE_TIPPED_OVER "tipped_over"

//Trait applied to PAIs by being folded.
#define SOURCE_PAI_FOLDED "pai_folded"

//Trait applied to brain mobs when they lack external aid for locomotion, such as being inside a mech.
#define SOURCE_BRAIN_UNAIDED "brain_unaided"

//Trait applied by MODsuits.
#define SOURCE_MOD "mod"

//Trait applied by element.
#define SOURCE_ELEMENT(source) "element_trait_[source]"

//Trait granted by the berserker hood.
#define SOURCE_BERSERK "berserk_trait"

//Trait granted by [/obj/item/rod_of_asclepius]
#define SOURCE_HIPPOCRATIC_OATH "hippocratic_oath"

//Trait granted by [/datum/status_effect/blooddrunk]
#define SOURCE_BLOOD_DRUNK "blood_drunk"

//Trait granted by lipstick
#define SOURCE_LIPSTICK "lipstick_trait"

//Self-explainatory.
#define SOURCE_BEAUTY_ELEMENT "beauty_element"
#define SOURCE_MOOD_DATUM "mood_datum"
#define SOURCE_DRONE_SHY "drone_shy"

//Pacifism trait given by stabilized light pink extracts.
#define SOURCE_STABILIZED_LIGHT_PINK "stabilized_light_pink"

//Given by the multiple_lives component to the previous body of the mob upon death.
#define SOURCE_EXPIRED_LIFE "expired_life"

//Trait given to an atom/movable when they orbit something.
#define SOURCE_ORBITING "orbiting"

//From the item_scaling element
#define SOURCE_ITEM_SCALING "item_scaling"

//Trait given by Objects that provide blindsight
#define SOURCE_ITEM_BLIND "blind_item_trait"
/**
* Trait granted by [/mob/living/carbon/Initialize] and
* granted/removed by [/obj/item/organ/internal/tongue]
* Used for ensuring that carbons without tongues cannot taste anything
* so it is added in Initialize, and then removed when a tongue is inserted
* and readded when a tongue is removed.
*/
#define SOURCE_NO_TONGUE "no_tongue"

//Trait granted by [/mob/living/silicon/robot]

//Traits applied to a silicon mob by their model.
#define SOURCE_MODEL "model_trait"

//Trait granted by [mob/living/silicon/ai]

//Applied when the ai anchors itself
#define SOURCE_AI_ANCHOR "ai_anchor"

//Trait from [/datum/antagonist/nukeop/clownop]
#define SOURCE_AI_CLOWNOP "clownop"

///From the market_crash event
#define SOURCE_MARKET_CRASH_EVENT "crashed_market_event"

//ID cards with this trait will attempt to forcibly occupy the front-facing ID card slot in wallets.
#define TRAIT_MAGNETIC_ID_CARD "magnetic_id_card"

//ID cards with this trait have special appraisal text.
#define TRAIT_TASTEFULLY_THICK_ID_CARD "impressive_very_nice"

//Traits granted to items due to their chameleon properties.
#define SOURCE_CHAMELEON_ITEM "chameleon_item_trait"

//This human wants to see the color of their glasses, for some reason
#define TRAIT_SEE_GLASS_COLORS "see_glass_colors"
//Radiation defines

//Marks that this object is irradiated
#define TRAIT_IRRADIATED "iraddiated"

//Harmful radiation effects, the toxin damage and the burns, will not occur while this trait is active
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

//This clothing protects the user from radiation.

//This should not be used on clothing_traits, but should be applied to the clothing itself.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

//Whether or not this item will allow the radiation SS to go through standard

//radiation processing as if this wasn't already irradiated.

//Basically, without this, COMSIG_IN_RANGE_OF_IRRADIATION won't fire once the object is irradiated.
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"
//Traits to heal for

//This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

//This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

//Ignore Crew monitor Z levels
#define TRAIT_MULTIZ_SUIT_SENSORS "multiz_suit_sensors"

//Ignores body_parts_covered during the add_fingerprint() proc. Works both on the person and the item in the glove slot.
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"

//this object has been frozen
#define TRAIT_FROZEN "frozen"

//Currently fishing
#define TRAIT_GONE_FISHING "fishing"

//Makes a species be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

//Makes a species be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

//Makes a species be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"
