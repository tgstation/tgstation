#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"
#define WAND_HANDLE_REQUESTS "requests"
#define WAND_SHOCK "shock"

// WAND_HANDLE_REQUESTS is the odd one out but it's a radial that every remote uses so it's here
#define DOOR_REMOTE_RADIAL_IMAGES list( \
	REGION_ALL_STATION = GENERIC_REMOTE_RADIALS, \
	REGION_COMMAND = COMMAND_REMOTE_RADIALS, \
	REGION_ENGINEERING = ENGINEERING_REMOTE_RADIALS, \
	REGION_SECURITY = SECURITY_REMOTE_RADIALS, \
	REGION_MEDBAY = MEDBAY_REMOTE_RADIALS, \
	REGION_RESEARCH = RESEARCH_REMOTE_RADIALS, \
	REGION_GENERAL = SERVICE_REMOTE_RADIALS, \
	REGION_SUPPLY = SUPPLY_REMOTE_RADIALS, \
	WAND_HANDLE_REQUESTS = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_request_decision") \
)
// For responses to remote requests
#define REMOTE_RESPONSE_APPROVE "response_approve"
#define REMOTE_RESPONSE_DENY "response_deny"
#define REMOTE_RESPONSE_BOLT "response_bolt"
#define REMOTE_RESPONSE_BLOCK "response_block"
#define REMOTE_RESPONSE_EA "response_emergency"
#define REMOTE_RESPONSE_CLEAR "response_clear"
#define REMOTE_RESPONSE_ESCALATE "response_escalate"
#define REMOTE_RESPONSE_SHOCK "response_shock"

#define GENERIC_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "closed"), \
)

#define COMMAND_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/command.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/command.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/command.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/command.dmi', icon_state = "closed"), \
)

#define ENGINEERING_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/engineering.dmi', icon_state = "closed"), \
)

#define SECURITY_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/security.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/security.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/security.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/security.dmi', icon_state = "closed"), \
)

#define MEDBAY_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/medical.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/medical.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/medical.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/medical.dmi', icon_state = "closed"), \
)

#define RESEARCH_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/research.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/research.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/research.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/research.dmi', icon_state = "closed"), \
)

#define SERVICE_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/bananium.dmi', icon_state = "closed"), \
)

#define SUPPLY_REMOTE_RADIALS list( \
    WAND_OPEN = image(icon = 'icons/obj/doors/airlocks/station/mining.dmi', icon_state = "opening"), \
    WAND_BOLT = image(icon = 'icons/obj/doors/airlocks/station/mining.dmi', icon_state = "closed"), \
    WAND_EMERGENCY = image(icon = 'icons/obj/doors/airlocks/station/mining.dmi', icon_state = "closed"), \
    WAND_SHOCK = image(icon = 'icons/obj/doors/airlocks/station/mining.dmi', icon_state = "closed"), \
)

#define REMOTE_RESPONSE_RADIALS list( \
	REMOTE_RESPONSE_APPROVE = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_big_yes"), \
	REMOTE_RESPONSE_DENY = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_big_no"), \
	REMOTE_RESPONSE_BOLT = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_padlock"), \
	REMOTE_RESPONSE_BLOCK = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_fuck_off"), \
	REMOTE_RESPONSE_EMERGENCY = image(icon = 'icons/obj/signs.dmi', icon_state = "secure_area"), \
	REMOTE_RESPONSE_CLEAR = image(icon = 'icons/obj/service/bureaucracy.dmi', icon_state = "paper_onfire"), \
	REMOTE_RESPONSE_ESCALATE = image(icon = 'icons/mob/landmarks.dmi', icon_state = "Captain"), \
	REMOTE_RESPONSE_SHOCK = image(icon = 'icons/mob/human/human.dmi', icon_state = "electrocuted_generic"), \
)

GLOBAL_LIST_INIT(door_remote_radial_images, DOOR_REMOTE_RADIAL_IMAGES)
