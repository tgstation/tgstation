//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC (1<<0)
#define MUTE_OOC (1<<1)
#define MUTE_PRAY (1<<2)
#define MUTE_ADMINHELP (1<<3)
#define MUTE_DEADCHAT (1<<4)
#define MUTE_INTERNET_REQUEST (1<<5)
#define MUTE_ALL ALL

//Some constants for DB_Ban
#define BANTYPE_PERMA 1
#define BANTYPE_TEMP 2
#define BANTYPE_JOB_PERMA 3
#define BANTYPE_JOB_TEMP 4
/// used to locate stuff to unban.
#define BANTYPE_ANY_FULLBAN 5

#define BANTYPE_ADMIN_PERMA 7
#define BANTYPE_ADMIN_TEMP 8
/// used to remove jobbans
#define BANTYPE_ANY_JOB 9

//Admin Permissions
/// Used for signifying that all admins can use this regardless of actual permissions
#define R_NONE NONE
#define R_BUILD (1<<0)
#define R_ADMIN (1<<1)
#define R_BAN (1<<2)
#define R_FUN (1<<3)
#define R_SERVER (1<<4)
#define R_DEBUG (1<<5)
#define R_POSSESS (1<<6)
#define R_PERMISSIONS (1<<7)
#define R_STEALTH (1<<8)
#define R_POLL (1<<9)
#define R_VAREDIT (1<<10)
#define R_SOUND (1<<11)
#define R_SPAWN (1<<12)
#define R_AUTOADMIN (1<<13)
#define R_DBRANKS (1<<14)

#define R_DEFAULT R_AUTOADMIN

#define R_EVERYTHING (1<<15)-1 //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='byond://?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_SP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];skill=[REF(user)]'>SP</a>)"
#define ADMIN_KICK(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? src.Admin_Coordinates_Readable() : "nonexistent location"]"
#define AREACOORD(src) "[src ? src.Admin_Coordinates_Readable(TRUE) : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? src.Admin_Coordinates_Readable(FALSE, TRUE) : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? src.Admin_Coordinates_Readable(TRUE, TRUE) : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
#define ADMIN_TAG(datum) "(<A href='byond://?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];tag_datum=[REF(datum)]'>TAG</a>)"
#define ADMIN_LUAVIEW(state) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];lua_state=[REF(state)]'>VIEW STATE</a>)"
#define ADMIN_LUAVIEW_CHUNK(state, log_index) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];lua_state=[REF(state)];log_index=[log_index]'>VIEW CODE</a>)"
/// Displays "(SHOW)" in the chat, when clicked it tries to show atom(paper). First you need to set the request_state variable to TRUE for the paper.
#define ADMIN_SHOW_PAPER(atom) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];show_paper=[REF(atom)]'>SHOW</a>)"
/// Displays "(PRINT)" in the chat, when clicked it will try to print the atom(paper) on the CentCom/Syndicate fax machine.
#define ADMIN_PRINT_FAX(atom, sender, destination) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];print_fax=[REF(atom)];sender_name=[url_encode(sender)];destination=[url_encode(destination)]'>PRINT</a>)"
/// Displays "(PLAY)" in the chat, when clicked it tries to play internet sounds from the request.
#define ADMIN_PLAY_INTERNET(text, credit) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];play_internet=[url_encode(text)];credit=[credit]'>PLAY</a>)"
/// Displays "(SEE Z-LEVEL LAYOUT)" in the chat, when clicked it shows the z-level layouts for the current world state.
#define ADMIN_SEE_ZLEVEL_LAYOUT "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];debug_z_levels=1'>SEE Z-LEVEL LAYOUT</a>)"

/atom/proc/Admin_Coordinates_Readable(area_name, admin_jump_ref)
	var/turf/turf_at_coords = Safe_COORD_Location()
	return turf_at_coords ? "[area_name ? "[get_area_name(turf_at_coords, TRUE)] " : ""]([turf_at_coords.x],[turf_at_coords.y],[turf_at_coords.z])[admin_jump_ref ? " [ADMIN_JMP(turf_at_coords)]" : ""]" : "nonexistent location"

/atom/proc/Safe_COORD_Location()
	var/atom/drop_atom = drop_location()
	if(!drop_atom)
		return //not a valid atom.
	var/turf/drop_turf = get_step(drop_atom, 0) //resolve where the thing is.
	if(!drop_turf) //incase it's inside a valid drop container, inside another container. ie if a mech picked up a closet and has it inside its internal storage.
		var/atom/last_try = drop_atom.loc?.drop_location() //one last try, otherwise fuck it.
		if(last_try)
			drop_turf = get_step(last_try, 0)
	return drop_turf

/turf/Safe_COORD_Location()
	return src

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

// Page numbers for the Permission Panel
#define PERMISSIONS_PAGE_PERMISSIONS 1
#define PERMISSIONS_PAGE_RANKS 2
#define PERMISSIONS_PAGE_LOGGING 3
#define PERMISSIONS_PAGE_HOUSEKEEPING 4

// Actions that can be logged in the admin_log table, excepting NONE
#define PERMISSIONS_ACTION_ADMIN_ADDED "add admin"
#define PERMISSIONS_ACTION_ADMIN_REMOVED "remove admin"
#define PERMISSIONS_ACTION_ADMIN_RANK_CHANGED "change admin rank"
#define PERMISSIONS_ACTION_RANK_ADDED "add rank"
#define PERMISSIONS_ACTION_RANK_REMOVED "remove rank"
#define PERMISSIONS_ACTION_RANK_CHANGED "change rank flags"
#define PERMISSIONS_ACTION_NONE "none"

// The types of ranks you can have
#define RANK_SOURCE_LOCAL "rank_local"
#define RANK_SOURCE_TXT "rank_txt"
#define RANK_SOURCE_DB "rank_db"
#define RANK_SOURCE_BACKUP "rank_backup"
#define RANK_SOURCE_TEMPORARY "rank_temp"

/// Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_WARNING 5
/// Number of identical messages required before the spam-prevention will automute you
#define SPAM_TRIGGER_AUTOMUTE 10

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
///Max amount of keypress messages per second over two seconds before client is autokicked
#define MAX_KEYPRESS_AUTOKICK 50
///Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15

#define STICKYBAN_DB_CACHE_TIME (10 SECONDS)
#define STICKYBAN_ROGUE_CHECK_TIME 5

/// Reference index for policy.json to locate any policy text applicable to polymorphed/staff of changed mobs.
#define POLICY_POLYMORPH "Polymorph"
/// Reference index for policy.json to locate any policy text that is shown as a header in the OOC > Show Policy verb.
#define POLICY_VERB_HEADER "Policy Verb Header"

//How many things you can spawn at once with spawn verb/create panel
#define ADMIN_SPAWN_CAP 100

// LOG BROWSE TYPES
#define BROWSE_ROOT_ALL_LOGS 1
#define BROWSE_ROOT_CURRENT_LOGS 2

// allowed ghost roles this round, starts as everything allowed
GLOBAL_VAR_INIT(ghost_role_flags, ALL)

//Flags that control what ways ghosts can get back into the round
//ie fugitives, space dragon, etc. also includes dynamic midrounds as it's the same deal
#define GHOSTROLE_MIDROUND_EVENT (1<<0)
//ie ashwalkers, free golems, beach bums
#define GHOSTROLE_SPAWNER (1<<1)
//ie mind monkeys, sentience potion
#define GHOSTROLE_STATION_SENTIENCE (1<<2)
//ie pais, posibrains
#define GHOSTROLE_SILICONS (1<<3)
//ie mafia, ctf
#define GHOSTROLE_MINIGAME (1<<4)

//smite defines

#define LIGHTNING_BOLT_DAMAGE 75
#define LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH 40

/// for [/proc/check_asay_links], if there are any actionable refs in the asay message, this index in the return list contains the new message text to be printed
#define ASAY_LINK_NEW_MESSAGE_INDEX "!asay_new_message"
/// for [/proc/check_asay_links], if there are any admin pings in the asay message, this index in the return list contains a list of admins to ping
#define ASAY_LINK_PINGED_ADMINS_INDEX "!pinged_admins"

/// When passed in as the duration for ban_panel, will make the ban default to permanent
#define BAN_PANEL_PERMANENT "permanent"

/// A value for /datum/admins/cached_feedback_link to indicate empty, rather than unobtained
#define NO_FEEDBACK_LINK "no_feedback_link"

/// State when an interview has been approved
#define INTERVIEW_APPROVED "interview_approved"
/// State when an interview as been denied
#define INTERVIEW_DENIED "interview_denied"
/// State when an interview has had no action on it yet
#define INTERVIEW_PENDING "interview_pending"

/// Used in logging uses of admin verbs (and sometimes some non-admin or debug verbs) to the blackbox
/// Only pass it a string key, the verb being used.
#define BLACKBOX_LOG_ADMIN_VERB(the_verb) SSblackbox.record_feedback("tally", "admin_verb", 1, the_verb)

// Smite flags
/// Plays sfx and adds an overlay to the target
#define SMITE_DIVINE (1<<0)
/// Adds a delay before the effect is applied
#define SMITE_DELAY (1<<1)
/// Stuns the target for a short duration, ignores stun immunity
#define SMITE_STUN (1<<2)
