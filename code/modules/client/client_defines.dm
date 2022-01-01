
/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	/// hides the byond verb panel as we use our own custom version
	show_verb_panel = FALSE
	///Contains admin info. Null if client is not an admin.
	var/datum/admins/holder = null
	///Needs to implement InterceptClickOn(user,params,atom) proc
	var/datum/click_intercept = null
	///Time when the click was intercepted
	var/click_intercept_time = 0
	///Used for admin AI interaction
	var/AI_Interact = FALSE

	///Used to cache this client's bans to save on DB queries
	var/ban_cache = null
	///Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message = ""
	///contins a number of how many times a message identical to last_message was sent.
	var/last_message_count = 0
	///How many messages sent in the last 10 seconds
	var/total_message_count = 0
	///Next tick to reset the total message counter
	var/total_count_reset = 0
	///Internal counter for clients sending external (IRC/Discord) relay messages via ahelp to prevent spamming. Set to a number every time an admin reply is sent, decremented for every client send.
	var/externalreplyamount = 0
	///Tracks say() usage for ic/dchat while slowmode is enabled
	COOLDOWN_DECLARE(say_slowmode)
	/// The last urgent ahelp that this player sent
	COOLDOWN_DECLARE(urgent_ahelp_cooldown)

		/////////
		//OTHER//
		/////////
	///Player preferences datum for the client
	var/datum/preferences/prefs = null
	///last turn of the controlled mob, I think this is only used by mechs?
	var/last_turn = 0
	///Move delay of controlled mob, related to input handling
	var/move_delay = 0
	///Current area of the controlled mob
	var/area = null

		///////////////
		//SOUND STUFF//
		///////////////

		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	///Used to determine how old the account is - in days.
	var/player_age = -1
	///Date that this account was first seen in the server
	var/player_join_date = null
	///So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"
	///So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"
	///Date of byond account creation in ISO 8601 format
	var/account_join_date = null
	///Age of byond account in days
	var/account_age = -1

	preload_rsc = PRELOAD_RSC

	var/atom/movable/screen/click_catcher/void

	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_up_icon = null
	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_down_icon = null
	///used to override the mouse cursor so it doesnt get reset
	var/mouse_override_icon = null

	///Used for ip intel checking to identify evaders, disabled because of issues with traffic
	var/ip_intel = "Disabled"

	///datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	///Last ping of the client
	var/lastping = 0
	///Average ping of the client
	var/avgping = 0
	///world.time they connected
	var/connection_time
	///world.realtime they connected
	var/connection_realtime
	///world.timeofday they connected
	var/connection_timeofday

	///If the client is currently in player preferences
	var/inprefs = FALSE
	///Used for limiting the rate of topic sends by the client to avoid abuse
	var/list/topiclimiter
	///Used for limiting the rate of clicks sends by the client to avoid abuse
	var/list/clicklimiter

	///lazy list of all credit object bound to this client
	var/list/credits

	///these persist between logins/logouts during the same round.
	var/datum/player_details/player_details

	///Should only be a key-value list of north/south/east/west = atom/movable/screen.
	var/list/char_render_holders

	///Amount of keydowns in the last keysend checking interval
	var/client_keysend_amount = 0
	///World tick time where client_keysend_amount will reset
	var/next_keysend_reset = 0
	///World tick time where keysend_tripped will reset back to false
	var/next_keysend_trip_reset = 0
	///When set to true, user will be autokicked if they trip the keysends in a second limit again
	var/keysend_tripped = FALSE
	///custom movement keys for this client
	var/list/movement_keys = list()

	///Autoclick list of two elements, first being the clicked thing, second being the parameters.
	var/list/atom/selected_target[2]
	///Autoclick variable referencing the associated item.
	var/obj/item/active_mousedown_item = null
	///Used in MouseDrag to preserve the original mouse click parameters
	var/mouseParams = ""
	///Used in MouseDrag to preserve the last mouse-entered location.
	var/mouseLocation = null
	///Used in MouseDrag to preserve the last mouse-entered object.
	var/mouseObject = null
	//Middle-mouse-button click dragtime control for aimbot exploit detection.
	var/middragtime = 0
	//Middle-mouse-button clicked object control for aimbot exploit detection.
	var/atom/middragatom

	/// Messages currently seen by this client
	var/list/seen_messages

	/// datum wrapper for client view
	var/datum/view_data/view_size

	/// our current tab
	var/stat_tab

	/// whether our browser is ready or not yet
	var/statbrowser_ready = FALSE

	/// list of all tabs
	var/list/panel_tabs = list()
	/// list of tabs containing spells and abilities
	var/list/spell_tabs = list()
	///A lazy list of atoms we've examined in the last RECENT_EXAMINE_MAX_WINDOW (default 2) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	var/list/recent_examines

	var/list/parallax_layers
	var/list/parallax_layers_cached
	///this is the last recorded client eye by SSparallax/fire()
	var/atom/movable/movingmob
	var/turf/previous_turf
	///world.time of when we can state animate()ing parallax again
	var/dont_animate_parallax
	///world.time of last parallax update
	var/last_parallax_shift
	///ds between parallax updates
	var/parallax_throttle = 0
	var/parallax_movedir = 0
	var/parallax_layers_max = 4
	var/parallax_animate_timer
	///Are we locking our movement input?
	var/movement_locked = FALSE

	/**
	 * Assoc list with all the active maps - when a screen obj is added to
	 * a map, it's put in here as well.
	 *
	 * Format: list(<mapname> = list(/atom/movable/screen))
	 */
	var/list/screen_maps = list()

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

	/// rate limiting for the crew manifest
	var/crew_manifest_delay

	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub

	/// If the client is currently under the restrictions of the interview system
	var/interviewee = FALSE

	/// Whether or not this client has standard hotkeys enabled
	var/hotkeys = TRUE

	/// Whether or not this client has the combo HUD enabled
	var/combo_hud_enabled = FALSE

	/// A list of active music
	var/list/active_music = list()
	/// The current playing music datum
	var/datum/music/playing_music = null
