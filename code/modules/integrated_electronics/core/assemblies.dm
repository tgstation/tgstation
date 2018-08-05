#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

// Any new types need to be added to ASSEMBLY_PATHS in the integrated_electronics DEFINE file

/*********
 * Items *
 *********/
/obj/item/electronic_assembly
	name = "electronic assembly"
	obj_flags = CAN_BE_HIT
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	item_flags = NOBLUDGEON
	anchored = FALSE
	var/can_anchor = TRUE
	materials = list()		// To be filled later
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD) //diagnostic hud overlays
	max_integrity = 50
	pass_flags = 0
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)

/obj/item/electronic_assembly/attackby(obj/item/I, mob/living/user)
	if(can_anchor && default_unfasten_wrench(user, I, 20))
		return
	return ..()

/obj/item/electronic_assembly/attack_tk(mob/user)
	if(anchored)
		return
	..()

/obj/item/electronic_assembly/attack_hand(mob/user)
	if(anchored)
		attack_self(user)
		return
	..()

/obj/item/electronic_assembly/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, IC_MAX_SIZE_BASE, IC_COMPLEXITY_BASE)

/obj/item/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/electronic_assembly/calc
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case, for building small electronics with. This one resembles a pocket calculator."

/obj/item/electronic_assembly/clam
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case, for building small electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/simple
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case, for building small electronics with. This one has a simple design."

/obj/item/electronic_assembly/hook
	name = "type-e electronic assembly"
	icon_state = "setup_small_hook"
	desc = "It's a case, for building small electronics with. This one looks like it has a belt clip, but it's purely decorative."

/obj/item/electronic_assembly/pda
	name = "type-f electronic assembly"
	icon_state = "setup_small_pda"
	desc = "It's a case, for building small electronics with. This one resembles a PDA."

/obj/item/electronic_assembly/small
	name = "electronic device"
	icon_state = "setup_device"
	desc = "It's a case, for building tiny-sized electronics with."
	w_class = WEIGHT_CLASS_TINY

/obj/item/electronic_assembly/small/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, IC_MAX_SIZE_BASE/2, IC_COMPLEXITY_BASE/2)

/obj/item/electronic_assembly/small/default
	name = "type-a electronic device"

/obj/item/electronic_assembly/small/cylinder
	name = "type-b electronic device"
	icon_state = "setup_device_cylinder"
	desc = "It's a case, for building tiny-sized electronics with. This one has a cylindrical design."

/obj/item/electronic_assembly/small/scanner
	name = "type-c electronic device"
	icon_state = "setup_device_scanner"
	desc = "It's a case, for building tiny-sized electronics with. This one has a scanner-like design."

/obj/item/electronic_assembly/small/hook
	name = "type-d electronic device"
	icon_state = "setup_device_hook"
	desc = "It's a case, for building tiny-sized electronics with. This one looks like it has a belt clip, but it's purely decorative."

/obj/item/electronic_assembly/small/box
	name = "type-e electronic device"
	icon_state = "setup_device_box"
	desc = "It's a case, for building tiny-sized electronics with. This one has a boxy design."

/obj/item/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/electronic_assembly/medium/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 2*IC_MAX_SIZE_BASE, 2*IC_COMPLEXITY_BASE)

/obj/item/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/electronic_assembly/medium/box
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case, for building medium-sized electronics with. This one has a boxy design."

/obj/item/electronic_assembly/medium/clam
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case, for building medium-sized electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/medium/medical
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case, for building medium-sized electronics with. This one resembles some type of medical apparatus."

/obj/item/electronic_assembly/medium/gun
	name = "type-e electronic mechanism"
	icon_state = "setup_medium_gun"
	item_state = "circuitgun"
	desc = "It's a case, for building medium-sized electronics with. This one resembles a gun, or some type of tool, if you're feeling optimistic. It can fire guns and throw items while the user is holding it."
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/electronic_assembly/medium/gun/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 2*IC_MAX_SIZE_BASE, 2*IC_COMPLEXITY_BASE, , TRUE)

/obj/item/electronic_assembly/medium/radio
	name = "type-f electronic mechanism"
	icon_state = "setup_medium_radio"
	desc = "It's a case, for building medium-sized electronics with. This one resembles an old radio."

/obj/item/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY

/obj/item/electronic_assembly/large/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 4*IC_MAX_SIZE_BASE, 4*IC_COMPLEXITY_BASE)

/obj/item/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/electronic_assembly/large/scope
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case, for building large electronics with. This one resembles an oscilloscope."

/obj/item/electronic_assembly/large/terminal
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case, for building large electronics with. This one resembles a computer terminal."

/obj/item/electronic_assembly/large/arm
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case, for building large electronics with. This one resembles a robotic arm."

/obj/item/electronic_assembly/large/tall
	name = "type-e electronic machine"
	icon_state = "setup_large_tall"
	desc = "It's a case, for building large electronics with. This one has a tall design."

/obj/item/electronic_assembly/large/industrial
	name = "type-f electronic machine"
	icon_state = "setup_large_industrial"
	desc = "It's a case, for building large electronics with. This one resembles some kind of industrial machinery."

/********
 * Mobs *
 ********/
/mob/living/integrated_drone
	name = "electronic drone"
	desc = "It's a case, for building mobile electronics with."
	icon_state = "setup_drone"
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	mob_biotypes = list(MOB_ROBOTIC)
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD)

/mob/living/integrated_drone/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 3*IC_MAX_SIZE_BASE, 3*IC_COMPLEXITY_BASE, IC_ACTION_MOVEMENT|IC_ACTION_COMBAT|IC_ACTION_LONG_RANGE)

/mob/living/integrated_drone/med_hud_set_health()
	return //we use a different hud

/mob/living/integrated_drone/med_hud_set_status()
	return //we use a different hud

/mob/living/integrated_drone/death(gibbed)
	. = ..()
	GET_COMPONENT(assembly, /datum/component/integrated_electronic)
	if(!assembly.opened)
		assembly.opened = TRUE
		assembly.update_icon()
	STOP_PROCESSING(SScircuit, assembly)

/mob/living/integrated_drone/default
	name = "type-a electronic drone"

/mob/living/integrated_drone/arms
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case, for building mobile electronics with. This one is armed and dangerous."

/mob/living/integrated_drone/secbot
	name = "type-c electronic drone"
	icon_state = "setup_drone_secbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Securitron."

/mob/living/integrated_drone/medbot
	name = "type-d electronic drone"
	icon_state = "setup_drone_medbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Medibot."

/mob/living/integrated_drone/genbot
	name = "type-e electronic drone"
	icon_state = "setup_drone_genbot"
	desc = "It's a case, for building mobile electronics with. This one has a generic bot design."

/mob/living/integrated_drone/android
	name = "type-f electronic drone"
	icon_state = "setup_drone_android"
	desc = "It's a case, for building mobile electronics with. This one has a hominoid design."

/**************
 * Wallframes *
 **************/
/obj/item/wallframe/integrated_screen
	name = "wall-mounted electronic assembly"
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_wallmount_medium"
	desc = "It's a case, for building medium-sized electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to close it first."
	obj_flags = CAN_BE_HIT
	item_flags = NOBLUDGEON
	materials = list()		// To be filled later
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD) //diagnostic hud overlays
	max_integrity = 50
	pass_flags = 0
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	result_path = /obj/mounted_integrated_screen
	pixel_shift = 31
	inverse = TRUE

/obj/item/wallframe/integrated_screen/tiny
	name = "tiny wall-mounted electronic assembly"
	icon_state = "setup_wallmount_tiny"
	desc = "It's a case, for building tiny electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to close it first."
	w_class = WEIGHT_CLASS_TINY

/obj/item/wallframe/integrated_screen/tiny/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, IC_MAX_SIZE_BASE/2, IC_COMPLEXITY_BASE/2)

/obj/item/wallframe/integrated_screen/light
	name = "light wall-mounted electronic assembly"
	icon_state = "setup_wallmount_small"
	desc = "It's a case, for building small electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to close it first."
	w_class = WEIGHT_CLASS_SMALL

/obj/item/wallframe/integrated_screen/light/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, IC_MAX_SIZE_BASE, IC_COMPLEXITY_BASE)

/obj/item/wallframe/integrated_screen/medium
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wallframe/integrated_screen/medium/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 2*IC_MAX_SIZE_BASE, 2*IC_COMPLEXITY_BASE)

/obj/item/wallframe/integrated_screen/heavy
	name = "heavy wall-mounted electronic assembly"
	icon_state = "setup_wallmount_large"
	desc = "It's a case, for building large electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to close it first."
	w_class = WEIGHT_CLASS_BULKY

/obj/item/wallframe/integrated_screen/ComponentInitialize()
	AddComponent(/datum/component/integrated_electronic, 4*IC_MAX_SIZE_BASE, 4*IC_COMPLEXITY_BASE)

/obj/item/wallframe/integrated_screen/try_build(turf/on_wall, mob/user)
	if(..())
		GET_COMPONENT(IE, /datum/component/integrated_electronic)
		if(!IE.opened)
			return TRUE
		to_chat(user, "<span class='warning'>[src] must be closed before you can mount it on a wall.</span>")
	return FALSE

/obj/item/wallframe/integrated_screen/after_attach(var/obj/O)
	..()
	TransferComponents(O)
	O.name = name
	O.desc = desc
	O.obj_integrity = obj_integrity
	//so that we don't need multiple objects
	O.icon_state = icon_state
	var/obj/mounted_integrated_screen/mounted = O
	mounted.assembly_path = type

//the object that the wallframe turns into
/obj/mounted_integrated_screen
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_wallmount_medium"
	var/assembly_path = /obj/item/wallframe/integrated_screen
	obj_flags = CAN_BE_HIT
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD) //diagnostic hud overlays
	max_integrity = 50
	pass_flags = 0
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)

/obj/mounted_integrated_screen/screwdriver_act(mob/living/user, obj/item/W)
	if(W.use_tool(src, user, 50))
		var/obj/O = new assembly_path(loc)
		TransferComponents(O)
		O.name = name
		O.desc = desc
		O.obj_integrity = obj_integrity
		user.visible_message("[user.name] has removed [src] from the wall with [W].", "<span class='notice'>You removed [src] from the wall.</span>")
		qdel(src)
	return TRUE