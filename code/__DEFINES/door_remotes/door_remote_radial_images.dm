// WAND_HANDLE_REQUESTS is the odd one out but it's a radial that every remote uses so it's here
#define DOOR_REMOTE_RADIAL_IMAGES list( \
	REGION_ALL_STATION = GENERIC_REMOTE_RADIALS, \
	DEPARTMENT_COMMAND = COMMAND_REMOTE_RADIALS, \
	DEPARTMENT_ENGINEERING = ENGINEERING_REMOTE_RADIALS, \
	DEPARTMENT_SECURITY = SECURITY_REMOTE_RADIALS, \
	DEPARTMENT_MEDICAL = MEDBAY_REMOTE_RADIALS, \
	DEPARTMENT_SCIENCE = RESEARCH_REMOTE_RADIALS, \
	DEPARTMENT_SERVICE = SERVICE_REMOTE_RADIALS, \
	DEPARTMENT_CARGO = CARGO_REMOTE_RADIALS, \
	WAND_HANDLE_REQUESTS = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_request_decision"), \
	WAND_HANDLE_CONFIG = image(icon = 'icons/obj/signs.dmi', icon_state = "nanotrasen"), \
)

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

#define CARGO_REMOTE_RADIALS list( \
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
	REMOTE_RESPONSE_EA = image(icon = 'icons/obj/signs.dmi', icon_state = "securearea"), \
	REMOTE_RESPONSE_SHOCK = image(icon = 'icons/mob/human/human.dmi', icon_state = "electrocuted_generic"), \
)

GLOBAL_LIST_INIT(door_remote_radial_images, DOOR_REMOTE_RADIAL_IMAGES)
