// forgottenship ruin
GLOBAL_VAR_INIT(fscpassword, generate_password())

/proc/generate_password()
	return "[pick(GLOB.phonetic_alphabet)] [rand(1,1000)]"

///////////	forgottenship objects

/obj/machinery/door/password/voice/sfc
	name = "Voice-activated Vault door"
	desc = "You'll need special syndicate passcode to open this one."
/obj/machinery/door/password/voice/sfc/Initialize(mapload)
	. = ..()
	password = "[GLOB.fscpassword]"

///////////	forgottenship lore

/obj/item/paper/fluff/ruins/forgottenship/password
	name = "Old pamphlet"

/obj/item/paper/fluff/ruins/forgottenship/password/Initialize(mapload)
	. = ..()
	info = "Welcome to most advanced cruiser owned by Cyber Sun Industries!<br>You might notice, that this cruiser is equipped with 12 prototype laser turrets making any hostile boarding attempts futile.<br>Other facilities built on the ship are: Simple atmospheric system, Camera system with built-in X-ray visors and Safety module, enabling emergency engines in case of... you know, emergency.<br>Emergency system will bring you to nearest syndicate pod containing everything needed for human life.<br><br><b>In case of emergency, you must remember the pod-door activation code - [GLOB.fscpassword]</b><br><br>Cyber Sun Industries (C) 2484."
	icon_state = "paper_words"
	item_state = "paper"

/obj/item/paper/fluff/ruins/forgottenship/powerissues
	name = "Power issues"
	info = "Welcome to battle cruiser SCSBC-12!<br>Our most advanced systems allow you to fly in space and never worry about power issues!<br>However, emergencies occur, and in case of power loss, <b>you must</b> enable emergency generator using uranium as fuel and enable turrets in bridge afterwards.<br><br><b>REMEMBER! CYBERSUN INDUSTRIES ARE NOT RESPONSIBLE FOR YOUR DEATH OR SHIP LOSS WHEN TURRETS ARE DISABLED!</b><br><br>Cyber Sun Industries (C) 2484."

///////////	forgottenship areas

/area/ruin/space/has_grav/syndicate_forgotten_ship
	name = "Syndicate Forgotten Ship"
	icon_state = "syndie-ship"

/area/ruin/space/has_grav/syndicate_forgotten_cargopod
	name = "Syndicate Forgotten Cargo pod"
	icon_state = "syndie-ship"

/area/ruin/space/has_grav/powered/syndicate_forgotten_vault
	name = "Syndicate Forgotten Vault"
	icon_state = "syndie-ship"

	//Cybersun hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/cybersun
	name = "cybersun hardsuit helmet"
	desc = "Prototype hardsuit helmet with experimental armor plates, protecting from laser-based weapons very well, while giving limited protection against anything else."
	icon_state = "cybersun"
	item_state = "cybersun"
	hardsuit_type = "cybersun"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 70, "energy" = 50, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	strip_delay = 600
	actions_types = list()


/obj/item/clothing/suit/space/hardsuit/cybersun
	icon_state = "cybersun"
	item_state = "cybersun"
	hardsuit_type = "cybersun"
	name = "cybersun hardsuit"
	desc = "Prototype hardsuit with experimental armor plates, protecting from laser-based weapons very well, while giving limited protection against anything else. Requires the user to activate the inner mechanism in order to unequip it, making it nearly impossible to take it off from somebody else."
	armor = list("melee" = 35, "bullet" = 35, "laser" = 70, "energy" = 50, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	strip_delay = 600
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cybersun
	actions_types = list(/datum/action/item_action/toggle_helmet)
	jetpack = /obj/item/tank/jetpack/suit