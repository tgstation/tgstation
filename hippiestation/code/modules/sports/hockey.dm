#define HOCKEYSTICK_CD	1.3
#define PUCK_STUN_AMT	2

/obj/item/hockeypack
	name = "Ka-Nada Special Sport Forces Hockey Pack"
	desc = "Holds and powers a Ka-Nada SSF Hockey Stick, A devastating weapon capable of knocking men around like toys and batting objects at deadly velocities."
	icon = 'hippiestation/icons/obj/clothing/back.dmi'
	alternate_worn_icon = 'hippiestation/icons/mob/back.dmi'
	icon_state = "hockey_bag"
	item_state = "hockey_bag"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	actions_types = list(/datum/action/item_action/toggle_stick)
	var/obj/item/twohanded/hockeystick/packstick
	var/on = FALSE
	var/volume = 500

/obj/item/hockeypack/equipped(mob/user, slot)
	if(slot == slot_back)
		flags_1 |= NODROP_1

/obj/item/hockeypack/ui_action_click()
	toggle_stick()

/obj/item/hockeypack/Initialize()
	. = ..()
	packstick = make_stick()

/obj/item/hockeypack/verb/toggle_stick()
	set name = "Get Stick"
	set category = "Object"
	if (usr.get_item_by_slot(usr.getHockeypackSlot()) != src)
		to_chat(usr, "<span class='warning'>The pack must be worn properly to use!</span>")
		return
	if(usr.incapacitated())
		return
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		if(!packstick)
			packstick = make_stick()

		if(!user.put_in_hands(packstick))
			on = FALSE
			to_chat(user, "<span class='warning'>You need a free hand to hold the stick!</span>")
			return
		packstick.loc = user
	else
		remove_stick()
	return

/obj/item/hockeypack/proc/make_stick()
	return new /obj/item/twohanded/hockeystick(src)

/obj/item/hockeypack/equipped(mob/user, slot) //The Pack is cursed so this should not happen, but i'm going to play it safe.
	if (slot != slot_back)
		remove_stick()

/obj/item/hockeypack/proc/remove_stick()
	if(ismob(packstick.loc))
		var/mob/M = packstick.loc
		M.temporarilyRemoveItemFromInventory(packstick, TRUE)
	return

/obj/item/hockeypack/Destroy()
	if (on)
		packstick.unwield()
		remove_stick()
		qdel(packstick)
		packstick = null
	return ..()

/obj/item/hockeypack/attack_hand(mob/user)
	if(src.loc == user)
		ui_action_click()
		return
	..()

/obj/item/hockeypack/MouseDrop(obj/over_object)
	var/mob/M = src.loc
	if(istype(M) && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		if(!M.temporarilyRemoveItemFromInventory(src))
			return
		M.put_in_hand(src, H.held_index)

/obj/item/hockeypack/attackby(obj/item/W, mob/user, params)
	if(W == packstick)
		remove_stick()
		return
	..()

/mob/proc/getHockeypackSlot()
	return slot_back

/obj/item/twohanded/hockeystick
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "hockeystick0"
	name = "Ka-Nada SSF Hockey Stick"
	desc = "A Ka-Nada specification Power Stick designed after the implement of a violent sport, it is locked to and powered by the back mounted pack."
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	force_unwielded = 10
	force_wielded = 25
	specthrow_sound = 'sound/weapons/resonator_blast.ogg'
	throwforce = 3
	throw_speed = 4
	flags_1 = NODROP_1
	attack_verb = list("smacked", "thwacked", "bashed", "struck", "battered")
	specthrow_forcemult = 1.4
	specthrow_msg = list("chipped", "shot")
	sharpness = IS_SHARP_ACCURATE
	block_chance = 20
	var/obj/item/hockeypack/pack

/obj/item/twohanded/hockeystick/update_icon()
	icon_state = "hockeystick[wielded]"
	return

/obj/item/twohanded/hockeystick/Initialize(parent_pack)
	. = ..()
	if(check_pack_exists(parent_pack, src))
		pack = parent_pack
		loc = pack

/obj/item/twohanded/hockeystick/attack(mob/living/target, mob/living/user) //Sure it's the powerfist code, right down to the sound effect. Gonna be fun though.

	if(!wielded)
		return ..()

	target.apply_damage(force, BRUTE)	//If it's a mob but not a humanoid, just give it plain brute damage.

	target.visible_message("<span class='danger'>[target.name] was pucked by [user] 'eh!</span>", \
		"<span class='userdanger'>You hear a loud crack 'eh!</span>", \
		"<span class='italics'>You hear the sound of bones crunching 'eh!</span>")

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 10, 1)	//Throws the target 10 tiles

	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)

	add_logs(user, target, "used a hockey stick on", src) //Very unlikeley non-antags are going to get their hands on this but just in case...

	user.changeNext_move(CLICK_CD_MELEE * HOCKEYSTICK_CD)


	return

/obj/item/twohanded/hockeystick/dropped(mob/user) //The Stick is undroppable but just in case they lose an arm better put this here.
		..()
		to_chat(user, "<span class='notice'>The stick is drawn back to the backpack 'eh!</span>")
		pack.on = FALSE
		loc = pack


/proc/check_pack_exists(parent_pack, mob/living/carbon/human/M, obj/O)
	if(!parent_pack || !istype(parent_pack, /obj/item/hockeypack))
		qdel(O)
		return FALSE
	else
		return TRUE

/obj/item/twohanded/hockeystick/Move()
	..()
	if(loc != pack.loc)
		loc = pack.loc

/obj/item/twohanded/hockeystick/IsReflect()
	return (wielded)

/obj/item/storage/belt/hippie/hockey
	name = "Holopuck Generator"
	desc = "A Belt mounted device that quickly fabricates hard-light holopucks that when thrown will stall and slow down foes dealing minor damage. Has a pouch to store a pair of spare pucks"
	icon_state = "hockey_belt"
	item_state = "hockey_belt"
	actions_types = list(/datum/action/item_action/make_puck)
	storage_slots = 2
	can_hold = list(/obj/item/holopuck)
	var/recharge_time = 100
	var/charged = TRUE
	var/obj/item/holopuck/newpuck

/obj/item/storage/belt/hippie/hockey/equipped(mob/user, slot)
	if(slot == slot_belt)
		flags_1 |= NODROP_1

/obj/item/storage/belt/hippie/hockey/ui_action_click()
	make_puck()

/obj/item/storage/belt/hippie/hockey/verb/make_puck()
	set name = "Produce Puck"
	set category = "Object"
	if (usr.get_item_by_slot(usr.getHockeybeltSlot()) != src)
		to_chat(usr, "<span class='warning'>The belt must be worn properly to use!</span>")
		return
	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/user = usr

	if(!charged)
		to_chat(user, "<span class='warning'>The generator is still charging!</span>")
		return

	newpuck = build_puck()
	addtimer(CALLBACK(src,.proc/reset_puck),recharge_time)
	if(!user.put_in_hands(newpuck))
		to_chat(user, "<span class='warning'>You need a free hand to hold the puck!</span>")
		return

	charged = FALSE

/obj/item/storage/belt/hippie/hockey/proc/build_puck()
	return new /obj/item/holopuck(src)

/mob/proc/getHockeybeltSlot()
	return slot_belt

/obj/item/storage/belt/hippie/hockey/proc/reset_puck()
	charged = TRUE
	var/mob/M = get(src, /mob)
	to_chat(M, "<span class='notice'>The belt is now ready to fabricate another holopuck!</span>")

/obj/item/holopuck
	name = "HoloPuck"
	desc = "A small disk of hard light energy that's been electrically charged, will daze and damage a foe on impact."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "eshield0"
	item_state = "eshield0"
	w_class = 1
	force = 3
	throwforce = 10 //As good as a floor tile, three of these should knock someone out.

/obj/item/holopuck/throw_impact(atom/hit_atom)
	if(..() || !iscarbon(hit_atom))
		return
	var/mob/living/carbon/C = hit_atom
	C.apply_effect(PUCK_STUN_AMT, STUN)
	C.apply_damage((throwforce * 2), STAMINA) //This way the stamina damage is ALSO buffed by special throw items, the hockey stick for example.
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	visible_message("<span class='danger'>[C] has been dazed by a holopuck!</span>", \
						"<span class='userdanger'>[C] has been dazed by a holopuck!</span>")
	qdel(src)

/obj/item/clothing/suit/hippie/hockey
	name = "Ka-Nada winter sport combat suit"
	desc = "A suit of armour used by Ka-Nada Special Sport Forces teams. Protects you from the elements as well as your opponents."
	icon_state = "hockey_suit"
	item_state = "hockey_suit"
	allowed = list(/obj/item/tank/internals)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_1 = THICKMATERIAL_1 | STOPSPRESSUREDMAGE_1
	armor = list(melee = 70, bullet = 45, laser = 80, energy = 45, bomb = 75, bio = 0, rad = 30, fire = 80, acid = 100)
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/hippie/hockey/equipped(mob/user, slot)
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1

/obj/item/clothing/shoes/hippie/hockey
	name = "Ka-Nada Hyperblades"
	desc = "A pair of all terrain techno-skates, enabling a skilled skater to move freely and quickly."
	icon_state = "hockey_shoes"
	item_state = "hockey_shoes"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	slowdown = -1

/obj/item/clothing/shoes/hippie/hockey/equipped(mob/user, slot)
	if(slot == slot_shoes)
		flags_1 |= NODROP_1

/obj/item/clothing/mask/hippie/hockey
	name = "Ka-Nada Hockey Mask"
	desc = "The iconic mask of the Ka-Nada special sports forces, guaranteed to strike terror into the hearts of men and goalies."
	icon_state = "hockey_mask"
	item_state = "hockey_mask"
	flags_1 = BLOCK_GAS_SMOKE_EFFECT_1 | MASKINTERNALS_1 | NODROP_1
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/mask/hippie/hockey/equipped(mob/user, slot)
	if(slot == slot_wear_mask)
		flags_1 |= NODROP_1

/obj/item/clothing/head/hippie/hockey
	name = "Ka-Nada winter sport combat helmet."
	desc = "A combat helmet used by Ka-Nada extreme environment teams. Protects you from the elements as well as your opponents."
	icon_state = "hockey_helmet"
	item_state = "hockey_helmet"
	armor = list(melee = 80, bullet = 40, laser = 80,energy = 45, bomb = 50, bio = 10, rad = 0, fire = 80, acid = 100)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	flags_1 = STOPSPRESSUREDMAGE_1 | NODROP_1
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/mask/head/hockey/equipped(mob/user, slot)
	if(slot == slot_head)
		flags_1 |= NODROP_1

/datum/action/item_action/toggle_stick
	name = "Get Stick"

/datum/action/item_action/make_puck
	name = "Produce Puck"

#undef HOCKEYSTICK_CD
#undef PUCK_STUN_AMT
