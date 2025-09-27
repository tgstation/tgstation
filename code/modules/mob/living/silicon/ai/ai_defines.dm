/mob/living/silicon/ai
	name = "AI"
	real_name = "AI"
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai"
	move_resist = MOVE_FORCE_OVERPOWERING
	density = TRUE
	status_flags = CANSTUN|CANPUSH
	combat_mode = TRUE //so we always get pushed instead of trying to swap
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	hud_type = /datum/hud/ai
	mob_size = MOB_SIZE_LARGE
	can_buckle_to = FALSE

	silicon_huds = list(TRAIT_MEDICAL_HUD_SENSOR_ONLY, TRAIT_SECURITY_HUD_ID_ONLY, TRAIT_DIAGNOSTIC_HUD, TRAIT_BOT_PATH_HUD)
	radio = /obj/item/radio/headset/silicon/ai
	radiomod = ";" //AIs will, by default, state their laws on the internal radio.


	/* INITIALIZATION */
	/// If FALSE, attempts to [obj/item/aicard][card] the AI will be rejected
	var/can_be_carded = TRUE
	/// If TRUE, the AI will explode when killed
	var/explodes_on_death = FALSE
	/// Whether its MMI is a posibrain or regular MMI, used when being [obj/structure/ai_core][deconstructed]
	var/posibrain_inside = TRUE
	/// Whether other AIs get a "new host" announcement text. Syndicate AIs get to be sneaky and won't send the message.
	var/announce_init_to_others = TRUE


	/* STATE */
	/// If this AI can use their radio
	var/radio_enabled = TRUE
	/// Whether its cover is opened, so you can wirecut it for deconstruction
	var/opened = FALSE
	/// If the AI is currently anchored to the ground, used for checks. Distinct from [atom/movable/anchored]
	var/is_anchored = TRUE

	/// Raw HTML containing the last page that was loaded from a held-up PDA
	VAR_FINAL/last_tablet_note_seen = null
	/// The last attempted VOX announcement. Exists so that failed VOXes can be retried easily
	VAR_FINAL/last_announcement = ""
	/// AI core icon_state selected by the AI through [verb/pick_icon]
	var/display_icon_override


	/* ROBOTS */
	/// List of robots currently synced to the AI
	VAR_FINAL/list/mob/living/silicon/robot/connected_robots = list()


	/* POWER */
	/// Reserve emergency power, consumed when the AI has no [var/power_requirement][power source]
	var/battery = 200
	/// The conditions the AI will check to see if it's powered, can be set to NONE (0) to disable requirements
	var/power_requirement = POWER_REQ_ALL
	/// Current stage of the AI's power restoration routine
	VAR_FINAL/aiRestorePowerRoutine = POWER_RESTORATION_OFF
	/// The APC the AI is powered from, set when the AI has no power in order to access their APC
	VAR_FINAL/obj/machinery/power/apc/apc_override


	/* CAMERA */
	/// The network that the AI is currently viewing
	var/list/network = list(CAMERANET_NETWORK_SS13)
	/// If the AI has their camera light enabled
	var/camera_light_on = FALSE
	/// List of cameras that have been illuminated by the AI's camera light
	VAR_FINAL/list/obj/machinery/camera/lit_cameras = list()
	/// List of atoms that the AI's camera can quickly jump to through keys 1-9
	VAR_FINAL/list/atom/cam_hotkeys = new/list(9)
	/// The camera's last location before jumping
	VAR_FINAL/atom/cam_prev


	/* CAMERA EYE */
	/// The AI's **main** eye
	VAR_FINAL/mob/eye/camera/ai/eyeobj
	/// List of [mob/eye/camera/ai][camera eyes] that the AI has created, including the [var/eyeobj][main eye]
	VAR_FINAL/list/mob/eye/camera/ai/all_eyes = list()
	/// The internal tool used to track players visible through cameras
	VAR_FINAL/datum/trackable/ai_tracking_tool
	/// The current movement speed of the camera, it's definition being the base speed. Moves 1 more tile for every 10 sprint.
	var/sprint = 10
	/// Time since the AI [proc/AIMove][last moved their camera eye], uses world.timeofday
	VAR_FINAL/last_moved = 0
	/// If the camera eye [proc/AIMove][moves progressively faster] when looking around
	var/acceleration = TRUE


	/* MALFUNCTION */
	/// UI for picking malfunction modules
	VAR_FINAL/datum/module_picker/malf_picker
	/// Opens the [datum/module_picker][malf module UI]
	VAR_FINAL/datum/action/innate/choose_modules/modules_action
	/// Modules that the AI has already unlocked
	VAR_FINAL/list/datum/ai_module/current_modules = list()
	/// Cooldown between malf module usages
	COOLDOWN_DECLARE(malf_cooldown)

	/// Timer used when hacking an APC
	VAR_FINAL/malfhacking = FALSE //--NeoFite was here
	/// APC that we are currently hacking
	VAR_FINAL/obj/machinery/power/apc/malfhack
	/// APCs that the AI has already hacked
	VAR_FINAL/list/hacked_apcs = list()

	/// If TRUE, the AI can take control over mechs
	var/can_dominate_mechs = FALSE
	/// If TRUE, the AI can shunt themselves into APCs
	var/can_shunt = TRUE
	/// TRUE if the AI is currently shunted, used to differentiate between shunted and ghosted/braindead
	VAR_FINAL/shunted = FALSE
	/// If the AI has enabled doomsday
	VAR_FINAL/nuking = FALSE
	/// Reference to the doomsday device
	VAR_FINAL/obj/machinery/doomsday_device/doomsday_device
	/// Reference to machine that holds the voicechanger
	VAR_FINAL/obj/machinery/ai_voicechanger/ai_voicechanger


	/* REMOTE CONTROL */
	/// Equipment that the AI is controlling remotely, to determine whether to relaymove or use the AI eye
	VAR_FINAL/obj/controlled_equipment
	/// AI core that this AI is linked to, used when put into an exosuit
	VAR_FINAL/obj/structure/ai_core/deactivated/linked_core
	/// Robot that this AI is currently using
	VAR_FINAL/mob/living/silicon/robot/deployed_shell
	/// Action to deploy to a shell from a list of options
	VAR_FINAL/datum/action/innate/deploy_shell/deploy_action = new()
	/// Action to deploy to the last shell the AI used
	VAR_FINAL/datum/action/innate/deploy_last_shell/redeploy_action = new()


	/* MULTICAMERA */
	/// If the AI is in multicamera mode
	VAR_FINAL/multicam_on = FALSE
	/// Maximum multicamera windows the AI can have open
	var/max_multicams = 6
	/// The multicamera window that the AI is currently using
	VAR_FINAL/atom/movable/screen/movable/pic_in_pic/ai/master_multicam
	/// All of the AI's currently open multicamera windows
	VAR_FINAL/list/atom/movable/screen/movable/pic_in_pic/ai/multicam_screens = list()


	/* ROBOT CONTROL */
	/// UI for robot controls
	VAR_FINAL/datum/robot_control/robot_control
	/// Weakref to the bot the AI is currently commanding
	VAR_FINAL/datum/weakref/bot_ref
	/// If TRUE, the AI will send it's [var/bot_ref][commanded bot] to the next clicked atom
	VAR_FINAL/setting_waypoint = FALSE


	/* HOLOGRAM */
	/// The AI eye's last location, used when answering a hologram request
	VAR_FINAL/atom/lastloc
	/// The AI's hologram appearance, can be set by a client and is assigned on AI creation
	VAR_FINAL/mutable_appearance/hologram_appearance
	/// The AI's currently used holopad
	VAR_FINAL/obj/machinery/holopad/current

	/* UI */
	/// UI for station alerts
	VAR_FINAL/datum/station_alert/alert_control

	/* I'M DUMB AND CAN'T SORT */
	/// Used as a fake multitool in tcomms machinery
	VAR_FINAL/obj/item/multitool/aiMulti
	/// Helper effect that creates sparks when the AI is damaged
	VAR_FINAL/datum/effect_system/spark_spread/spark_system
