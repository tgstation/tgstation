/**
 * The mob, usually meant to be a creature of some type
 *
 * Has a client attached that is a living person (most of the time), although I have to admit
 * sometimes it's hard to tell they're sentient
 *
 * Has a lot of the creature game world logic, such as health etc
 */
/mob
	density = TRUE
	layer = MOB_LAYER
	plane = GAME_PLANE_FOV_HIDDEN
	animate_movement = SLIDE_STEPS
	hud_possible = list(ANTAG_HUD)
	pressure_resistance = 8
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	throwforce = 10
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	pass_flags_self = PASSMOB
	/// The current client inhabiting this mob. Managed by login/logout
	/// This exists so we can do cleanup in logout for occasions where a client was transfere rather then destroyed
	/// We need to do this because the mob on logout never actually has a reference to client
	/// We also need to clear this var/do other cleanup in client/Destroy, since that happens before logout
	/// HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	var/client/canon_client

	var/shift_to_open_context_menu = TRUE

	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	var/datum/mind/mind
	var/static/next_mob_id = 0

	/// List of movement speed modifiers applying to this mob
	var/list/movespeed_modification //Lazy list, see mob_movespeed.dm
	/// List of movement speed modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/movespeed_mod_immunities //Lazy list, see mob_movespeed.dm
	/// The calculated mob speed slowdown based on the modifiers list
	var/cached_multiplicative_slowdown
	/// List of action speed modifiers applying to this mob
	var/list/actionspeed_modification //Lazy list, see mob_movespeed.dm
	/// List of action speed modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/actionspeed_mod_immunities //Lazy list, see mob_movespeed.dm
	/// The calculated mob action speed slowdown based on the modifiers list
	var/cached_multiplicative_actions_slowdown
	/// List of action hud items the user has
	var/list/datum/action/actions
	/// A list of chameleon actions we have specifically
	/// This can be unified with the actions list
	var/list/datum/action/item_action/chameleon/chameleon_item_actions
	///Cursor icon used when holding shift over things
	var/examine_cursor_icon = 'icons/effects/mouse_pointers/examine_pointer.dmi'

	///Whether this mob has or is in the middle of committing suicide.
	var/suiciding = FALSE

	/// Whether a mob is alive or dead. TODO: Move this to living - Nodrak (2019, still here)
	var/stat = CONSCIOUS

	/* A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/

	/// The zone this mob is currently targeting
	var/zone_selected = BODY_ZONE_CHEST

	var/computer_id = null
	var/list/logging = list()

	/// The machine the mob is interacting with (this is very bad old code btw)
	var/obj/machinery/machine = null

	/// Tick time the mob can next move
	var/next_move = null

	/**
	  * Magic var that stops you moving and interacting with anything
	  *
	  * Set when you're being turned into something else and also used in a bunch of places
	  * it probably shouldn't really be
	  */
	var/notransform = null //Carbon

	/// What is the mobs real name (name is overridden for disguises etc)
	var/real_name = null

	/**
	  * back up of the real name during admin possession
	  *
	  * If an admin possesses an object it's real name is set to the admin name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/name_archive //For admin things like possession

	/// Default body temperature
	var/bodytemperature = BODYTEMP_NORMAL //310.15K / 98.6F
	/// Our body temperatue as of the last process, prevents pointless work when handling alerts
	var/old_bodytemperature = 0

	/// Hunger level of the mob
	var/nutrition = NUTRITION_LEVEL_START_MIN // randomised in Initialize
	/// Satiation level of the mob
	var/satiety = 0//Carbon

	/// How many ticks this mob has been over reating
	var/overeatduration = 0 // How long this guy is overeating //Carbon

	/// The movement intent of the mob (run/wal)
	var/m_intent = MOVE_INTENT_RUN//Living

	/// The last known IP of the client who was in this mob
	var/lastKnownIP = null

	/// movable atom we are buckled to
	var/atom/movable/buckled = null//Living

	//Hands
	///What hand is the active hand
	var/active_hand_index = 1
	/**
	  * list of items held in hands
	  *
	  * len = number of hands, eg: 2 nulls is 2 empty hands, 1 item and 1 null is 1 full hand
	  * and 1 empty hand.
	  *
	  * NB: contains nulls!
	  *
	  * `held_items[active_hand_index]` is the actively held item, but please use
	  * [get_active_held_item()][/mob/proc/get_active_held_item] instead, because OOP
	  */
	var/list/held_items = list()

	//HUD things

	/// Storage component (for mob inventory)
	var/datum/storage/active_storage
	/// Active hud
	var/datum/hud/hud_used = null

	/// Is the mob throw intent on
	var/throw_mode = THROW_MODE_DISABLED

	/// What job does this mob have
	var/job = null//Living

	/// A list of factions that this mob is currently in, for hostile mob targetting, amongst other things
	var/list/faction = list(FACTION_NEUTRAL)

	/// Can this mob enter shuttles
	var/move_on_shuttle = 1

	///A weakref to the last mob/living/carbon to push/drag/grab this mob (exclusively used by slimes friend recognition)
	var/datum/weakref/LAssailant = null

	/// bitflags defining which status effects can be inflicted (replaces canknockdown, canstun, etc)
	var/status_flags = CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH

	/// Can they interact with station electronics
	var/has_unlimited_silicon_privilege = FALSE

	///Used by admins to possess objects. All mobs should have this var
	var/obj/control_object

	///Calls relay_move() to whatever this is set to when the mob tries to move
	var/atom/movable/remote_control

	///the current turf being examined in the stat panel
	var/turf/listed_turf = null

	///The list of people observing this mob.
	var/list/observers = null

	///List of progress bars this mob is currently seeing for actions
	var/list/progressbars = null //for stacking do_after bars

	///For storing what do_after's someone has, key = string, value = amount of interactions of that type happening.
	var/list/do_afters

	///Allows a datum to intercept all click calls this mob is the source of
	var/datum/click_intercept

	///THe z level this mob is currently registered in
	var/registered_z = null

	var/memory_throttle_time = 0

	/// Contains [/atom/movable/screen/alert] only.
	///
	/// On [/mob] so clientless mobs will throw alerts properly.
	var/list/alerts = list()
	var/list/screens = list()
	var/list/client_colours = list()
	var/hud_type = /datum/hud

	var/datum/focus //What receives our keyboard inputs. src by default

	/// Used for tracking last uses of emotes for cooldown purposes
	var/list/emotes_used

	///Whether the mob is updating glide size when movespeed updates or not
	var/updating_glide_size = TRUE

	///Override for sound_environments. If this is set the user will always hear a specific type of reverb (Instead of the area defined reverb)
	var/sound_environment_override = SOUND_ENVIRONMENT_NONE

	/// A mock client, provided by tests and friends
	var/datum/client_interface/mock_client

	var/interaction_range = 0 //how far a mob has to be to interact with something without caring about obsctruction, defaulted to 0 tiles

	///the icon currently used for the typing indicator's bubble
	var/active_typing_indicator
	///the icon currently used for the thinking indicator's bubble
	var/active_thinking_indicator
	/// User is thinking in character. Used to revert to thinking state after stop_typing
	var/thinking_IC = FALSE

	///how much gravity is slowing us down
	var/gravity_slowdown = 0
