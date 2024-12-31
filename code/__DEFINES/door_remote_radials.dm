#define DOOR_REMOTE_RADIAL_IMAGES list( \
	REGION_ALL_STATION = GENERIC_REMOTE_RADIALS, \
	REGION_COMMAND = COMMAND_REMOTE_RADIALS, \
	REGION_ENGINEERING = ENGINEERING_REMOTE_RADIALS, \
	REGION_SECURITY = SECURITY_REMOTE_RADIALS, \
	REGION_MEDBAY = MEDBAY_REMOTE_RADIALS, \
	REGION_RESEARCH = RESEARCH_REMOTE_RADIALS, \
	REGION_GENERAL = SERVICE_REMOTE_RADIALS, \
	REGION_SUPPLY = SUPPLY_REMOTE_RADIALS, \
)
// For the remote-mode radial
#define DOOR_REMOTE_RADIAL_OPERATION_OPENING_INDEX 1
#define DOOR_REMOTE_RADIAL_OPERATION_BOLTING_INDEX 2
#define DOOR_REMOTE_RADIAL_OPERATION_EA_INDEX 3
#define DOOR_REMOTE_RADIAL_OPERATION_SHOCK_INDEX 4
// For responses to remote requests
#define DOOR_REMOTE_RADIAL_RESPONSE_APPROVE_INDEX 1
#define DOOR_REMOTE_RADIAL_RESPONSE_DENY_INDEX 2
#define DOOR_REMOTE_RADIAL_RESPONSE_BOLT_INDEX 3
#define DOOR_REMOTE_RADIAL_RESPONSE_BLOCK_INDEX 4
#define DOOR_REMOTE_RADIAL_RESPONSE_EA_INDEX 5
#define DOOR_REMOTE_RADIAL_RESPONSE_CLEAR_INDEX 6
#define DOOR_REMOTE_RADIAL_RESPONSE_ESCALATE_INDEX 7
#define DOOR_REMOTE_RADIAL_RESPONSE_SHOCK 8
// Odd one out, the same for all remotes but technically an operation, not a response
#define DOOR_REMOTE_RADIAL_OPERATION_HANDLE_REQUESTS_INDEX 9

#define GENERIC_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/public.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/public.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/public.dmi'), \
)

#define COMMAND_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/command.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/command.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/command.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/command.dmi'), \
)

#define ENGINEERING_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi'), \
)

#define SECURITY_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/security.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/security.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/security.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/security.dmi'), \
)

#define MEDBAY_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/medical.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/medical.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/medical.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/medical.dmi'), \
)

#define RESEARCH_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/research.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/research.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/research.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/research.dmi'), \
)

#define SERVICE_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi'), \
)

#define SUPPLY_REMOTE_RADIALS list( \
    image(icon = 'icons/obj/doors/airlocks/station/mining.dmi', icon_state = "opening"), \
    image(icon = 'icons/obj/doors/airlocks/station/mining.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/mining.dmi'), \
    image(icon = 'icons/obj/doors/airlocks/station/mining.dmi'), \
)

#define REMOTE_RESPONSE_RADIALS list( \
    image(icon = 'icons/hud/radial.dmi', icon_state = "radial_big_yes"), \
    image(icon = 'icons/hud/radial.dmi', icon_state = "radial_big_no"), \
    image(icon = 'icons/hud/radial.dmi', icon_state = "radial_padlock"), \
    image(icon = 'icons/hud/radial.dmi', icon_state = "radial_fuck_off"), \
    image(icon = 'icons/obj/signs.dmi', icon_state = "secure_area"), \
    image(icon = 'icons/obj/service/bureaucracy.dmi', icon_state = "paper_onfire"), \
    image(icon = 'icons/mob/landmarks.dmi', icon_state = "Captain"), \
    image(icon = 'icons/mob/human/human.dmi', icon_state = "electrocuted_generic"), \
    image(icon = 'icons/hud/radial.dmi', icon_state = "radial_big_yes") \
)

GLOBAL_LIST_INIT(door_remote_radial_images, DOOR_REMOTE_RADIAL_IMAGES)

/datum/controller/subsystem/id_access/proc/setup_door_remote_radials()
	for(var/list/image_set in GLOB.door_remote_radial_images)
		var/image/bolt_radial = image_set[DOOR_REMOTE_RADIAL_OPERATION_BOLTING_INDEX]
		var/image/EA_radial = image_set[DOOR_REMOTE_RADIAL_OPERATION_EA_INDEX]
		var/image/shock_radial = image_set[DOOR_REMOTE_RADIAL_OPERATION_SHOCK_INDEX]
		bolt_radial.add_overlay(image(icon = bolt_radial.icon, icon_state = "lights_bolts"))
		EA_radial.add_overlay(image(icon = EA_radial.icon, icon_state = "lights_emergency"))
		shock_radial.add_overlay(image(icon = 'icons/mob/huds/hud.dmi', icon_state = "electrified"))
