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
	/// If this is FALSE, attempts to [obj/item/aicard][card] the AI will be rejected.
	var/can_be_carded = TRUE
	/// If the AI dies while this is TRUE, it will create a devastating explosion.
	var/explodes_on_death = FALSE
	/// Whether its mmi is a posibrain or regular mmi when going ai mob to ai core structure
	var/posibrain_inside = TRUE

	/* STATE */
	/// If this AI can use their radio.
	var/radio_enabled = TRUE
	/// Whether its cover is opened, so you can wirecut it for deconstruction
	var/opened = FALSE
	/// Whether AI is anchored or not, used for checks
	var/is_anchored = TRUE

	/* POWER */
	/// Reserve emergency power, used when the AI loses power
	var/battery = 200
	/// Current stage of the AI's power restoration routine.
	var/aiRestorePowerRoutine = POWER_RESTORATION_OFF
	/// The type of conditions the AI needs to stay powered. see
	var/power_requirement = POWER_REQ_ALL
	/// The APC the AI is powered from, set when the AI has no power in order to access their APC.
	var/obj/machinery/power/apc/apc_override

	/* CAMERA */
	/// The network that the AI is currently viewing
	var/list/network = list(CAMERANET_NETWORK_SS13)
	/// The AI's current... holopad?
	var/obj/machinery/camera/current
	/// List of cyborgs currently synced to the AI
	var/list/connected_robots = list()
	/// A piece of equipment, to determine whether to relaymove or use the AI eye.
	var/obj/controlled_equipment
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever

	/* MALFUNCTION */
	/// **MALFUNCTION:** UI for picking malfunction modules.
	var/datum/module_picker/malf_picker
	/// **MALFUNCTION:** Modules that the AI has already unlocked.
	var/list/datum/ai_module/current_modules = list()
	var/can_dominate_mechs = FALSE
	var/can_shunt = TRUE
	var/shunted = FALSE //1 if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead
	var/obj/machinery/ai_voicechanger/ai_voicechanger = null // reference to machine that holds the voicechanger
	var/malfhacking = FALSE // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	/// APCs that the AI has already hacked.
	var/list/hacked_apcs = list()
	///Cooldown var for malf modules, stores a worldtime + cooldown
	var/malf_cooldown = 0
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/obj/machinery/power/apc/malfhack

	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	///The internal tool used to track players visible through cameras.
	var/datum/trackable/ai_tracking_tool

	var/last_tablet_note_seen = null
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = FALSE //Waypoint mode is for selecting a turf via clicking.
	var/call_bot_cooldown = 0 //time of next call bot command

	var/mob/eye/camera/ai/eyeobj
	var/sprint = 10
	var/last_moved = 0
	var/acceleration = TRUE

	/* REMOTE CONTROL */
	var/obj/structure/ai_core/deactivated/linked_core //For exosuit control
	var/mob/living/silicon/robot/deployed_shell = null //For shell control
	var/datum/action/innate/deploy_shell/deploy_action = new
	var/datum/action/innate/deploy_last_shell/redeploy_action = new
	var/datum/action/innate/choose_modules/modules_action
	var/chnotify = 0

	/* MULTICAMERA */
	var/multicam_on = FALSE
	var/atom/movable/screen/movable/pic_in_pic/ai/master_multicam
	var/list/multicam_screens = list()
	var/list/all_eyes = list()
	var/max_multicams = 6
	var/display_icon_override

	var/list/cam_hotkeys = new/list(9)
	var/atom/cam_prev

	/* ROBOT CONTROL */
	/// UI for robot controls.
	var/datum/robot_control/robot_control
	///Weakref to the bot the ai's commanding right now
	var/datum/weakref/bot_ref
	///remember AI's last location
	var/atom/lastloc

	/* I'M DUMB AND CAN'T SORT */
	/// The last attempted VOX announcement. Exists so that failed VOXes can be retried easily.
	var/last_announcement = ""
	/// The AI's hologram appearance.
	var/mutable_appearance/hologram_appearance //Default is assigned when AI is created.
	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control
	var/atom/movable/screen/ai/modpc/interfaceButton
	///Used as a fake multitoool in tcomms machinery
	var/obj/item/multitool/aiMulti
