/obj/structure/tank_holder
	name = "tank holder"
	desc = "A metallic frame that can hold tanks and extinguishers."
	icon = 'icons/obj/tank.dmi'
	icon_state = "holder"

	custom_materials = list(/datum/material/iron = 2000)

	density = FALSE
	anchored = FALSE
	pass_flags = LETPASSTHROW
	max_integrity = 20

	resistance_flags = FIRE_PROOF

	var/obj/item/tank = null

/obj/structure/tank_holder/Initialize()
	. = ..()
	if(tank)
		density = TRUE
		tank = new tank(src)

/obj/structure/tank_holder/Destroy()
	if(tank)
		tank.forceMove(get_turf(src))
		tank = null
	return ..()

/obj/structure/closet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is held together by some <b>screws</b>.</span>"

/obj/structure/tank_holder/attackby(obj/item/W, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(contents.len != 0)
		to_chat(user, "<span class='warning'>There's already something in \the [src].</span>")
		return

	if(!W.tank_holder_icon_state)
		to_chat(user, "<span class='warning'>\The [W] does not fit in \the [src].</span>")
		return

	if(!user.transferItemToLoc(W, src))
		return
	to_chat(user, "<span class='notice'>You put \the [W] into \the [src].</span>")
	tank = W
	icon_state = W.tank_holder_icon_state
	density = TRUE

/obj/structure/tank_holder/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(tank)
		return FALSE
	I.play_tool_sound(src)
	deconstruct(TRUE)
	return TRUE

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new /obj/item/stack/rods(get_turf(src), 2)
	qdel(src)

/obj/structure/tank_holder/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/tank_holder/attack_hand(mob/user)
	if(!tank)
		return ..()
	to_chat(user, "<span class='notice'>You take \the [tank] from \the [src].</span>")
	add_fingerprint(user)
	user.put_in_hands(tank)
	tank = null
	icon_state = "holder"

/obj/structure/tank_holder/oxygen
	icon_state = "holder_oxygen"
	density = TRUE
	tank = /obj/item/tank/internals/oxygen

/obj/structure/tank_holder/anesthetic
	icon_state = "holder_anesthetic"
	density = TRUE
	tank = /obj/item/tank/internals/anesthetic

/obj/structure/tank_holder/oxygen/yellow
	icon_state = "holder_oxygen_f"
	density = TRUE
	tank = /obj/item/tank/internals/oxygen/yellow

/obj/structure/tank_holder/oxygen/red
	icon_state = "holder_oxygen_fr"
	density = TRUE
	tank = /obj/item/tank/internals/oxygen/red

/obj/structure/tank_holder/emergency_oxygen
	icon_state = "holder_emergency"
	density = TRUE
	tank = /obj/item/tank/internals/emergency_oxygen

/obj/structure/tank_holder/emergency_oxygen/engi
	icon_state = "holder_emergency_engi"
	density = TRUE
	tank = /obj/item/tank/internals/emergency_oxygen/engi

/obj/structure/tank_holder/generic
	icon_state = "holder_generic"
	density = TRUE
	tank = /obj/item/tank/internals/generic

/obj/structure/tank_holder/extinguisher
	icon_state = "holder_extinguisher"
	density = TRUE
	tank = /obj/item/extinguisher

/obj/structure/tank_holder/extinguisher/advanced
	icon_state = "holder_foam_extinguisher"
	density = TRUE
	tank = /obj/item/extinguisher/advanced
