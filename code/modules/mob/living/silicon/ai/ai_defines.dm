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

	silicon_huds = list(DATA_HUD_MEDICAL_BASIC, DATA_HUD_SECURITY_BASIC, DATA_HUD_DIAGNOSTIC, DATA_HUD_BOT_PATH)
	radio = /obj/item/radio/headset/silicon/ai
	radiomod = ";" //AIs will, by default, state their laws on the internal radio.


	/* INITIALIZATION */
	/// If FALSE, attempts to [obj/item/aicard][card] the AI will be rejected
	var/can_be_carded = TRUE
	/// If TRUE when the AI dies, it will create a devastating explosion
	var/explodes_on_death = FALSE
	/// Whether its MMI is a posibrain or regular MMI, used when being [obj/structure/ai_core][deconstructed]
	var/posibrain_inside = TRUE


	/* STATE */
	/// If this AI can use their radio
	var/radio_enabled = TRUE
	/// Whether its cover is opened, so you can wirecut it for deconstruction
	var/opened = FALSE
	/// If the AI is currently anchored to the ground, used for checks. Distinct from [atom/movable/anchored]
	var/is_anchored = TRUE


	/* POWER */
	/// Reserve emergency power, consumed when the AI has no [var/power_requirement][power source]
	var/battery = 200
	/// The type of conditions the AI needs to stay powered
	var/power_requirement = POWER_REQ_ALL
	/// Current stage of the AI's power restoration routine
	var/aiRestorePowerRoutine = POWER_RESTORATION_OFF
	/// The APC the AI is powered from, set when the AI has no power in order to access their APC
	var/obj/machinery/power/apc/apc_override


	/* CAMERA */
	/// The network that the AI is currently viewing
	var/list/network = list(CAMERANET_NETWORK_SS13)
	/// The AI's current... holopad?
	var/obj/machinery/camera/current
	/// If the AI has their camera light enabled
	var/camera_light_on = FALSE
	/// List of cameras that have been illuminated by the AI's [var/camera_light][camera light]
	var/final/list/obj/machinery/camera/lit_cameras = list()
	/// List of atoms that the AI can quickly jump to through keys 1-9
	var/final/list/atom/cam_hotkeys = new/list(9)
	/// The last camera hotkey we jumped to
	var/final/atom/cam_prev


	/* CAMERA EYE */
	/// The AI's **main** eye (bars)
	var/mob/eye/camera/ai/eyeobj = null
	/// List of [mob/eye/camera/ai][camera eyes] that the AI has created, including the [var/eyeobj][main eye]
	var/final/list/mob/eye/camera/ai/all_eyes = list()
	/// The internal tool used to track players visible through cameras
	var/datum/trackable/ai_tracking_tool
	/// [var/acceleration][Incrementing] value used in [proc/AIMove][movement]
	var/sprint = 10
	/// Time since the AI [proc/AIMove][last moved their camera eye], uses world.timeofday
	var/final/last_moved = 0
	/// If the camera eye [proc/AIMove][moves progressively faster] when looking around
	var/acceleration = TRUE


	/* MALFUNCTION */
	/// UI for picking malfunction modules
	var/datum/module_picker/malf_picker
	/// Opens the [datum/module_picker][module UI]
	var/datum/action/innate/choose_modules/modules_action
	/// Modules that the AI has already unlocked
	var/list/datum/ai_module/current_modules = list()
	/// Cooldown between malf module usages
	COOLDOWN_DECLARE(malf_cooldown)

	/// Timer used when hacking an APC
	var/malfhacking = FALSE //--NeoFite was here
	/// APC that we are currently hacking.
	var/obj/machinery/power/apc/malfhack = null
	/// APCs that the AI has hacked.
	var/list/hacked_apcs = list()

	/// If TRUE, the AI can take control over mechs
	var/can_dominate_mechs = FALSE
	/// If TRUE, the AI can shunt themselves into APCs
	var/can_shunt = TRUE
	/// TRUE if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead
	var/shunted = FALSE
	/// If the AI has enabled doomsday.
	var/nuking = FALSE
	/// Reference to the doomsday device.
	var/obj/machinery/doomsday_device/doomsday_device = null
	/// Reference to machine that holds the voicechanger
	var/obj/machinery/ai_voicechanger/ai_voicechanger = null


	/* REMOTE CONTROL */
	/// Equipment that the AI is controlling remotely, to determine whether to relaymove or use the AI eye
	var/obj/controlled_equipment = null
	/// AI core that this AI is linked to, used when put into an exosuit
	var/obj/structure/ai_core/deactivated/linked_core = null
	/// Robot that this AI is currently using
	var/mob/living/silicon/robot/deployed_shell = null
	var/datum/action/innate/deploy_shell/deploy_action = new()
	var/datum/action/innate/deploy_last_shell/redeploy_action = new()


	/* MULTICAMERA */
	/// If the AI is in multicamera mode
	var/multicam_on = FALSE
	/// Maximum multicamera windows the AI can have open
	var/max_multicams = 6
	var/final/atom/movable/screen/movable/pic_in_pic/ai/master_multicam = null
	var/final/list/atom/movable/screen/movable/pic_in_pic/ai/multicam_screens = list()


	/* ROBOT CONTROL */
	/// UI for robot controls
	var/datum/robot_control/robot_control
	/// Weakref to the bot the AI is currently commanding
	var/datum/weakref/bot_ref
	/// If TRUE, the AI will send it's [var/bot_ref][commanded bot] to
	var/waypoint_mode = FALSE
	/// Cooldown for bot summoning
	COOLDOWN_DECLARE(call_bot_cooldown)


	/* I'M DUMB AND CAN'T SORT */
	/// remember AI's last location
	var/atom/lastloc
	var/last_tablet_note_seen = null
	/// The last attempted VOX announcement. Exists so that failed VOXes can be retried easily.
	var/last_announcement = ""
	/// The AI's hologram appearance
	var/mutable_appearance/hologram_appearance //Default is assigned when AI is created.
	/// UI for station alerts
	var/datum/station_alert/alert_control
	var/atom/movable/screen/ai/modpc/interfaceButton
	///Used as a fake multitoool in tcomms machinery
	var/obj/item/multitool/aiMulti
	/// List of cyborgs currently synced to the AI
	var/list/connected_robots = list()
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever
	/// AI core display selected by the AI through [verb/pick_icon]
	var/display_icon_override
