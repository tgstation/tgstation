// tgstation-server DMAPI
// The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in IETF RFC 2119.

#define TGS_DMAPI_VERSION "7.4.0"

// All functions and datums outside this document are subject to change with any version and should not be relied on.

// CONFIGURATION

/// Consumers SHOULD create this define if you want to do TGS configuration outside of this file.
#ifndef TGS_EXTERNAL_CONFIGURATION

// Consumers MUST comment this out once you've filled in the below and are not using [TGS_EXTERNAL_CONFIGURATION].
#error TGS API unconfigured

// Consumers MUST uncomment this if you wish to allow the game to interact with TGS version 3.
// This will raise the minimum required security level of your game to TGS_SECURITY_TRUSTED due to it utilizing call()().
//#define TGS_V3_API

// Required interfaces (fill in with your codebase equivalent):

/// Create a global variable named `Name` and set it to `Value`.
#define TGS_DEFINE_AND_SET_GLOBAL(Name, Value)

/// Read the value in the global variable `Name`.
#define TGS_READ_GLOBAL(Name)

/// Set the value in the global variable `Name` to `Value`.
#define TGS_WRITE_GLOBAL(Name, Value)

/// Disallow ANYONE from reflecting a given `path`, security measure to prevent in-game use of DD -> TGS capabilities.
#define TGS_PROTECT_DATUM(Path)

/// Display an announcement `message` from the server to all players.
#define TGS_WORLD_ANNOUNCE(message)

/// Notify current in-game administrators of a string `event`.
#define TGS_NOTIFY_ADMINS(event)

/// Write an info `message` to a server log.
#define TGS_INFO_LOG(message)

/// Write an warning `message` to a server log.
#define TGS_WARNING_LOG(message)

/// Write an error `message` to a server log.
#define TGS_ERROR_LOG(message)

/// Get the number of connected /clients.
#define TGS_CLIENT_COUNT

#endif

#ifndef TGS_FILE2TEXT_NATIVE
#ifdef file2text
#error Your codebase is re-defining the BYOND proc file2text. The DMAPI requires the native version to read the result of world.Export(). You SHOULD fix this by adding "#define TGS_FILE2TEXT_NATIVE file2text" before your override of file2text to allow the DMAPI to use the native version. This will only be used for world.Export(), not regular file accesses
#endif
#define TGS_FILE2TEXT_NATIVE file2text
#endif

// SpacemanDMM compatibility
#ifndef CAN_BE_REDEFINED
#define CAN_BE_REDEFINED(X)
#endif

// EVENT CODES

/// Before a reboot mode change, extras parameters are the current and new reboot mode enums.
#define TGS_EVENT_REBOOT_MODE_CHANGE -1
/// Before a port change is about to happen, extra parameters is new port.
#define TGS_EVENT_PORT_SWAP -2
/// Before the instance is renamed, extra parameter is the new name.
#define TGS_EVENT_INSTANCE_RENAMED -3
/// After the watchdog reattaches to DD, extra parameter is the new [/datum/tgs_version] of the server.
#define TGS_EVENT_WATCHDOG_REATTACH -4
/// When the watchdog sends a health check to DD. No parameters.
#define TGS_EVENT_HEALTH_CHECK -5

/// When the repository is reset to its origin reference. Parameters: Reference name, Commit SHA.
#define TGS_EVENT_REPO_RESET_ORIGIN 0
/// When the repository performs a checkout. Parameters: Checkout git object.
#define TGS_EVENT_REPO_CHECKOUT 1
/// When the repository performs a fetch operation. No parameters.
#define TGS_EVENT_REPO_FETCH 2
/// When the repository test merges. Parameters: PR Number, PR Sha, (Nullable) Comment made by TGS user.
#define TGS_EVENT_REPO_MERGE_PULL_REQUEST 3
/// Before the repository makes a sychronize operation. Parameters: Absolute repostiory path.
#define TGS_EVENT_REPO_PRE_SYNCHRONIZE 4
/// Before a engine install operation begins. Parameters: Version string of the installing engine.
#define TGS_EVENT_ENGINE_INSTALL_START 5
/// When a engine install operation fails. Parameters: Error message
#define TGS_EVENT_ENGINE_INSTALL_FAIL 6
/// When the active engine version changes. Parameters: (Nullable) Version string of the current engine, version string of the new engine.
#define TGS_EVENT_ENGINE_ACTIVE_VERSION_CHANGE 7
/// When the compiler starts running. Parameters: Game directory path, origin commit SHA.
#define TGS_EVENT_COMPILE_START 8
/// When a compile is cancelled. No parameters.
#define TGS_EVENT_COMPILE_CANCELLED 9
/// When a compile fails. Parameters: Game directory path, [TRUE]/[FALSE] based on if the cause for failure was DMAPI validation.
#define TGS_EVENT_COMPILE_FAILURE 10
/// When a compile operation completes. Note, this event fires before the new .dmb is loaded into the watchdog. Consider using the [TGS_EVENT_DEPLOYMENT_COMPLETE] instead. Parameters: Game directory path.
#define TGS_EVENT_COMPILE_COMPLETE 11
/// When an automatic update for the current instance begins. No parameters.
#define TGS_EVENT_INSTANCE_AUTO_UPDATE_START 12
/// When the repository encounters a merge conflict: Parameters: Base SHA, target SHA, base reference, target reference.
#define TGS_EVENT_REPO_MERGE_CONFLICT 13
/// When a deployment completes. No Parameters.
#define TGS_EVENT_DEPLOYMENT_COMPLETE 14
/// Before the watchdog shuts down. Not sent for graceful shutdowns. No parameters.
#define TGS_EVENT_WATCHDOG_SHUTDOWN 15
/// Before the watchdog detaches for a TGS update/restart. No parameters.
#define TGS_EVENT_WATCHDOG_DETACH 16
// We don't actually implement these 4 events as the DMAPI can never receive them.
// #define TGS_EVENT_WATCHDOG_LAUNCH 17
// #define TGS_EVENT_WATCHDOG_CRASH 18
// #define TGS_EVENT_WORLD_END_PROCESS 19
// #define TGS_EVENT_WORLD_REBOOT 20
/// Watchdog event when TgsInitializationComplete() is called. No parameters.
#define TGS_EVENT_WORLD_PRIME 21
// DMAPI also doesnt implement this
// #define TGS_EVENT_DREAM_DAEMON_LAUNCH 22
/// After a single submodule update is performed. Parameters: Updated submodule name.
#define TGS_EVENT_REPO_SUBMODULE_UPDATE 23
/// After CodeModifications are applied, before DreamMaker is run. Parameters: Game directory path, origin commit sha, version string of the used engine.
#define TGS_EVENT_PRE_DREAM_MAKER 24
/// Whenever a deployment folder is deleted from disk. Parameters: Game directory path.
#define TGS_EVENT_DEPLOYMENT_CLEANUP 25

// OTHER ENUMS

/// The server will reboot normally.
#define TGS_REBOOT_MODE_NORMAL 0
/// The server will stop running on reboot.
#define TGS_REBOOT_MODE_SHUTDOWN 1
/// The watchdog will restart on reboot.
#define TGS_REBOOT_MODE_RESTART 2

// Note that security levels are currently meaningless in OpenDream
/// DreamDaemon Trusted security level.
#define TGS_SECURITY_TRUSTED 0
/// DreamDaemon Safe security level.
#define TGS_SECURITY_SAFE 1
/// DreamDaemon Ultrasafe security level.
#define TGS_SECURITY_ULTRASAFE 2

/// DreamDaemon public visibility level.
#define TGS_VISIBILITY_PUBLIC 0
/// DreamDaemon private visibility level.
#define TGS_VISIBILITY_PRIVATE 1
/// DreamDaemon invisible visibility level.
#define TGS_VISIBILITY_INVISIBLE 2

/// The Build Your Own Net Dream engine.
#define TGS_ENGINE_TYPE_BYOND 0
/// The OpenDream engine.
#define TGS_ENGINE_TYPE_OPENDREAM 1

//REQUIRED HOOKS

/**
 * Consumers MUST call this somewhere in [/world/proc/New] that is always run. This function may sleep!
 *
 * * event_handler - Optional user defined [/datum/tgs_event_handler].
 * * minimum_required_security_level: The minimum required security level to run the game in which the DMAPI is integrated. Can be one of [TGS_SECURITY_ULTRASAFE], [TGS_SECURITY_SAFE], or [TGS_SECURITY_TRUSTED].
 * * http_handler - Optional user defined [/datum/tgs_http_handler].
 */
/world/proc/TgsNew(datum/tgs_event_handler/event_handler, minimum_required_security_level = TGS_SECURITY_ULTRASAFE, datum/tgs_http_handler/http_handler)
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Consumers MUST call this when world initializations are complete and the game is ready to play before any player interactions happen.
 *
 * This may use [/world/var/sleep_offline] to make this happen so ensure no changes are made to it while this call is running.
 * Afterwards, consider explicitly setting it to what you want to avoid this BYOND bug: http://www.byond.com/forum/post/2575184
 * This function should not be called before ..() in [/world/proc/New].
 */
/world/proc/TgsInitializationComplete()
	CAN_BE_REDEFINED(TRUE)
	return

/// Consumers MUST run this macro at the start of [/world/proc/Topic].
#define TGS_TOPIC var/tgs_topic_return = TgsTopic(args[1]); if(tgs_topic_return) return tgs_topic_return

/// Consumers MUST call this as late as possible in [world/proc/Reboot] (BEFORE ..()).
/world/proc/TgsReboot()
	CAN_BE_REDEFINED(TRUE)
	return

// DATUM DEFINITIONS
// All datums defined here should be considered read-only

/// Represents git revision information.
/datum/tgs_revision_information
	/// Full SHA of the commit.
	var/commit
	/// ISO 8601 timestamp of when the commit was created.
	var/timestamp
	/// Full sha of last known remote commit. This may be null if the TGS repository is not currently tracking a remote branch.
	var/origin_commit

/// Represents a version.
/datum/tgs_version
	/// The suite/major version number.
	var/suite

	// This group of variables can be null to represent a wild card.
	/// The minor version number. null for wildcards.
	var/minor
	/// The patch version number. null for wildcards.
	var/patch

	/// Legacy version number. Generally null.
	var/deprecated_patch

	/// Unparsed string value.
	var/raw_parameter
	/// String value minus prefix.
	var/deprefixed_parameter

/**
 * Returns [TRUE]/[FALSE] based on if the [/datum/tgs_version] contains wildcards.
 */
/datum/tgs_version/proc/Wildcard()
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Returns [TRUE]/[FALSE] based on if the [/datum/tgs_version] equals some other version.
 *
 * other_version - The [/datum/tgs_version] to compare against.
 */
/datum/tgs_version/proc/Equals(datum/tgs_version/other_version)
	CAN_BE_REDEFINED(TRUE)
	return

/// Represents a merge of a GitHub pull request.
/datum/tgs_revision_information/test_merge
	/// The test merge number.
	var/number
	/// The test merge source's title when it was merged.
	var/title
	/// The test merge source's body when it was merged.
	var/body
	/// The Username of the test merge source's author.
	var/author
	/// An http URL to the test merge source.
	var/url
	/// The SHA of the test merge when that was merged.
	var/head_commit
	/// Optional comment left by the TGS user who initiated the merge.
	var/comment

/// Represents a connected chat channel.
/datum/tgs_chat_channel
	/// TGS internal channel ID.
	var/id
	/// User friendly name of the channel.
	var/friendly_name
	/// Name of the chat connection. This is the IRC server address or the Discord guild.
	var/connection_name
	/// [TRUE]/[FALSE] based on if the server operator has marked this channel for game admins only.
	var/is_admin_channel
	/// [TRUE]/[FALSE] if the channel is a private message channel for a [/datum/tgs_chat_user].
	var/is_private_channel
	/// Tag string associated with the channel in TGS.
	var/custom_tag
	/// [TRUE]/[FALSE] if the channel supports embeds.
	var/embeds_supported

// Represents a chat user
/datum/tgs_chat_user
	/// TGS internal user ID.
	var/id
	/// The user's display name.
	var/friendly_name
	/// The string to use to ping this user in a message.
	var/mention
	/// The [/datum/tgs_chat_channel] the user was from.
	var/datum/tgs_chat_channel/channel

/// User definable handler for TGS events This abstract version SHOULD be overridden to be used.
/datum/tgs_event_handler
	/// If the handler receieves [TGS_EVENT_HEALTH_CHECK] events.
	var/receive_health_checks = FALSE

/**
 * User definable callback for handling TGS events.
 *
 * event_code - One of the TGS_EVENT_ defines. Extra parameters will be documented in each.
 */
/datum/tgs_event_handler/proc/HandleEvent(event_code, ...)
	set waitfor = FALSE
	return

/// User definable handler for HTTP calls. This abstract version MUST be overridden to be used.
/datum/tgs_http_handler

/**
 * User definable callback for executing HTTP GET requests.
 * MUST perform BYOND sleeps while the request is in flight.
 * MUST return a [/datum/tgs_http_result].
 * SHOULD log its own errors
 *
 * url - The full URL to execute the GET request for including query parameters.
 */
/datum/tgs_http_handler/proc/PerformGet(url)
	CRASH("[type]/PerformGet not implemented!")

/// Result of a [/datum/tgs_http_handler] call. MUST NOT be overridden.
/datum/tgs_http_result
	/// HTTP response as text
	var/response_text
	/// Boolean request success flag. Set for any 2XX response code.
	var/success

/**
 * Create a [/datum/tgs_http_result].
 *
 * * response_text - HTTP response as text. Must be provided in New().
 * * success - Boolean request success flag. Set for any 2XX response code. Must be provided in New().
 */
/datum/tgs_http_result/New(response_text, success)
	if(response_text && !istext(response_text))
		CRASH("response_text was not text!")

	src.response_text = response_text
	src.success = success

/// User definable chat command. This abstract version MUST be overridden to be used.
/datum/tgs_chat_command
	/// The string to trigger this command on a chat bot. e.g `@bot name ...` or `!tgs name ...`.
	var/name = ""
	/// The help text displayed for this command.
	var/help_text = ""
	/// If this command should be available to game administrators only.
	var/admin_only = FALSE
	/// A subtype of [/datum/tgs_chat_command] that is ignored when enumerating available commands. Use this to create shared base /datums for commands.
	var/ignore_type

/**
 * Process command activation. Should return a [/datum/tgs_message_content] to respond to the issuer with.
 * MUST be implemented
 *
 * * sender - The [/datum/tgs_chat_user] who issued the command.
 * * params - The trimmed string following the command `/datum/tgs_chat_command/var/name].
 */
/datum/tgs_chat_command/proc/Run(datum/tgs_chat_user/sender, params)
	CRASH("[type] has no implementation for Run()")

/// User definable chat message. MUST NOT be overridden.
/datum/tgs_message_content
	/// The string content of the message. Must be provided in New().
	var/text

	/// The [/datum/tgs_chat_embed] to embed in the message. Not supported on all chat providers.
	var/datum/tgs_chat_embed/structure/embed

/**
 * Create a [/datum/tgs_message_content].
 *
 * * text - The string content of the message.
 */
/datum/tgs_message_content/New(text)
	..()
	if(!istext(text))
		TGS_ERROR_LOG("[/datum/tgs_message_content] created with no text!")
		text = null

	src.text = text

/// User definable chat embed. Currently mirrors Discord chat embeds. See https://discord.com/developers/docs/resources/message#embed-object for details.
/datum/tgs_chat_embed/structure
	var/title
	var/description
	var/url

	/// Timestamp must be encoded as: time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss"). Use the active timezone.
	var/timestamp

	/// Colour must be #AARRGGBB or #RRGGBB hex string.
	var/colour

	/// See https://discord.com/developers/docs/resources/message#embed-object-embed-image-structure for details.
	var/datum/tgs_chat_embed/media/image

	/// See https://discord.com/developers/docs/resources/message#embed-object-embed-thumbnail-structure for details.
	var/datum/tgs_chat_embed/media/thumbnail

	/// See https://discord.com/developers/docs/resources/message#embed-object-embed-video-structure for details.
	var/datum/tgs_chat_embed/media/video

	var/datum/tgs_chat_embed/footer/footer
	var/datum/tgs_chat_embed/provider/provider
	var/datum/tgs_chat_embed/provider/author/author

	var/list/datum/tgs_chat_embed/field/fields

/// Common datum for similar Discord embed medias.
/datum/tgs_chat_embed/media
	/// Must be set in New().
	var/url
	var/width
	var/height
	var/proxy_url

/// Create a [/datum/tgs_chat_embed].
/datum/tgs_chat_embed/media/New(url)
	..()
	if(!istext(url))
		CRASH("[/datum/tgs_chat_embed/media] created with no url!")

	src.url = url

/// See https://discord.com/developers/docs/resources/message#embed-object-embed-footer-structure for details.
/datum/tgs_chat_embed/footer
	/// Must be set in New().
	var/text
	var/icon_url
	var/proxy_icon_url

/// Create a [/datum/tgs_chat_embed/footer].
/datum/tgs_chat_embed/footer/New(text)
	..()
	if(!istext(text))
		CRASH("[/datum/tgs_chat_embed/footer] created with no text!")

	src.text = text

/// See https://discord.com/developers/docs/resources/message#embed-object-embed-provider-structure for details.
/datum/tgs_chat_embed/provider
	var/name
	var/url

/// See https://discord.com/developers/docs/resources/message#embed-object-embed-author-structure for details. Must have name set in New().
/datum/tgs_chat_embed/provider/author
	var/icon_url
	var/proxy_icon_url

/// Create a [/datum/tgs_chat_embed/footer].
/datum/tgs_chat_embed/provider/author/New(name)
	..()
	if(!istext(name))
		CRASH("[/datum/tgs_chat_embed/provider/author] created with no name!")

	src.name = name

/// See https://discord.com/developers/docs/resources/message#embed-object-embed-field-structure for details.
/datum/tgs_chat_embed/field
	/// Must be set in New().
	var/name
	/// Must be set in New().
	var/value
	var/is_inline

/// Create a [/datum/tgs_chat_embed/field].
/datum/tgs_chat_embed/field/New(name, value)
	..()
	if(!istext(name))
		CRASH("[/datum/tgs_chat_embed/field] created with no name!")

	if(!istext(value))
		CRASH("[/datum/tgs_chat_embed/field] created with no value!")

	src.name = name
	src.value = value

// API FUNCTIONS

/// Returns the maximum supported [/datum/tgs_version] of the DMAPI.
/world/proc/TgsMaximumApiVersion()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the minimum supported [/datum/tgs_version] of the DMAPI.
/world/proc/TgsMinimumApiVersion()
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Returns [TRUE] if DreamDaemon was launched under TGS, the API matches, and was properly initialized. [FALSE] will be returned otherwise.
 */
/world/proc/TgsAvailable()
	CAN_BE_REDEFINED(TRUE)
	return

// No function below this succeeds if it TgsAvailable() returns FALSE or if TgsNew() has yet to be called.

/**
 * Forces a hard reboot of DreamDaemon by ending the process. This function may sleep!
 *
 * Unlike del(world) clients will try to reconnect.
 * If TGS has not requested a [TGS_REBOOT_MODE_SHUTDOWN] DreamDaemon will be launched again.
 */
/world/proc/TgsEndProcess()
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Send a message to connected chats. This function may sleep!
 * If TGS is offline when called, the message may be placed in a queue to be sent and this function will return immediately. Your message will be sent when TGS reconnects to the game.
 *
 * message - The [/datum/tgs_message_content] to send.
 * admin_only: If [TRUE], message will be sent to admin connected chats. Vice-versa applies.
 */
/world/proc/TgsTargetedChatBroadcast(datum/tgs_message_content/message, admin_only = FALSE)
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Send a private message to a specific user. This function may sleep!
 * If TGS is offline when called, the message may be placed in a queue to be sent and this function will return immediately. Your message will be sent when TGS reconnects to the game.
 *
 * message - The [/datum/tgs_message_content] to send.
 * user: The [/datum/tgs_chat_user] to PM.
 */
/world/proc/TgsChatPrivateMessage(datum/tgs_message_content/message, datum/tgs_chat_user/user)
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Send a message to connected chats that are flagged as game-related in TGS. This function may sleep!
 * If TGS is offline when called, the message may be placed in a queue to be sent and this function will return immediately. Your message will be sent when TGS reconnects to the game.
 *
 * message - The [/datum/tgs_message_content] to send.
 * channels - Optional list of [/datum/tgs_chat_channel]s to restrict the message to.
 */
/world/proc/TgsChatBroadcast(datum/tgs_message_content/message, list/channels = null)
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the current [/datum/tgs_version] of TGS if it is running the server, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsVersion()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the running engine type
/world/proc/TgsEngine()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the current [/datum/tgs_version] of the DMAPI being used if it was activated, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsApiVersion()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the name of the TGS instance running the game if TGS is present, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsInstanceName()
	CAN_BE_REDEFINED(TRUE)
	return

/// Return the current [/datum/tgs_revision_information] of the running server if TGS is present, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsRevision()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the current BYOND security level as a TGS_SECURITY_ define if TGS is present, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsSecurityLevel()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns the current BYOND visibility level as a TGS_VISIBILITY_ define if TGS is present, null otherwise. Requires TGS to be using interop API version 5 or higher otherwise the string "___unimplemented" wil be returned. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsVisibility()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns a list of active [/datum/tgs_revision_information/test_merge]s if TGS is present, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsTestMerges()
	CAN_BE_REDEFINED(TRUE)
	return

/// Returns a list of connected [/datum/tgs_chat_channel]s if TGS is present, null otherwise. This function may sleep if the call to [/world/proc/TgsNew] is sleeping!
/world/proc/TgsChatChannelInfo()
	CAN_BE_REDEFINED(TRUE)
	return

/**
 * Trigger an event in TGS. Requires TGS version >= 6.3.0. Returns [TRUE] if the event was triggered successfully, [FALSE] otherwise. This function may sleep!
 *
 * event_name - The name of the event to trigger
 * parameters - Optional list of string parameters to pass as arguments to the event script. The first parameter passed to a script will always be the running game's directory followed by these parameters.
 * wait_for_completion - If set, this function will not return until the event has run to completion.
 */
/world/proc/TgsTriggerEvent(event_name, list/parameters, wait_for_completion = FALSE)
	CAN_BE_REDEFINED(TRUE)
	return
	

/// Trigger a TGS deployment for the current instance. The current state of the repository will not be changed.
/world/proc/TgsTriggerDeployment()
	CAN_BE_REDEFINED(TRUE)
	return

/*
The MIT License

Copyright (c) 2017-2026 Jordan Brown

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"), to
deal in the Software without restriction, including
without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom
the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
