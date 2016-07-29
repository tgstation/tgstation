#define DECORATION	0
#define HOLSTER		1
#define STORAGE		2
#define ARMBAND		4
#define TIE			8

/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands by default
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_accessories.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_accessories.dmi')
	_color = "bluetie"
	flags = FPRINT
	slot_flags = 0
	w_class = W_CLASS_SMALL
	var/accessory_exclusion = DECORATION
	var/obj/item/clothing/attached_to = null
	var/image/inv_overlay

/obj/item/clothing/accessory/New()
	..()
	update_icon()

/obj/item/clothing/accessory/update_icon()
	if(attached_to)
		attached_to.overlays -= inv_overlay
	inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlays.dmi', "icon_state" = "[_color || icon_state]")
	if(attached_to)
		attached_to.overlays += inv_overlay
		if(ishuman(attached_to.loc))
			var/mob/living/carbon/human/H = attached_to.loc
			H.update_inv_by_slot(attached_to.slot_flags)

/obj/item/clothing/accessory/proc/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/under) //By default, accessories can only be attached to jumpsuits

/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/C)
	if(!istype(C))
		return
	attached_to = C
	attached_to.overlays += inv_overlay

/obj/item/clothing/accessory/proc/on_removed(mob/user as mob)
	if(!attached_to)
		return
	attached_to.overlays -= inv_overlay
	attached_to = null
	forceMove(get_turf(user || src))
	if(user)
		user.put_in_hands(src)
		add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_accessory_interact(mob/user, delayed = 0)
	if(!attached_to)
		return
	if(delayed)
		attached_to.remove_accessory(user, src)
		attack_hand(user)
		return 1
	return -1

/obj/item/clothing/accessory/Destroy()
	on_removed(null)
	inv_overlay = null
	return ..()

//Defining this at item level to prevent CASTING HELL
/obj/item/proc/generate_accessory_overlays()
	return

/obj/item/clothing/generate_accessory_overlays(var/obj/Overlays/O)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/accessory in accessories)
			O.overlays += image("icon" = 'icons/mob/clothing_accessories.dmi', "icon_state" = "[accessory._color || accessory.icon_state]")

//Defining this at item level to prevent CASTING HELL
/obj/item/proc/description_accessories()
	return

/obj/item/clothing/description_accessories()
	if(accessories.len)
		. = list()
		for(var/obj/item/clothing/accessory/accessory in accessories)
			. += "[bicon(accessory)] \a [accessory]"
		return " It has [english_list(.)]."

/obj/item/clothing/accessory/pinksquare
	name = "pink square"
	desc = "It's a pink square."
	icon_state = "pinksquare"
	_color = "pinksquare"
/obj/item/clothing/accessory/pinksquare/can_attach_to(obj/item/clothing/C)
	return 1

/obj/item/clothing/accessory/tie/can_attach_to(obj/item/clothing/C)
	if(istype(C))
		return (C.body_parts_covered & UPPER_TORSO) //Sure why not

/obj/item/clothing/accessory/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	_color = "bluetie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/red
	name = "red tie"
	icon_state = "redtie"
	_color = "redtie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	_color = "horribletie"
	accessory_exclusion = TIE

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	_color = "stethoscope"
	origin_tech = "biotech=1"

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == I_HELP)
			var/body_part = parse_zone(user.zone_sel.selecting)
			if(body_part)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.isDead())
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if(LIMB_CHEST)
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if("eyes","mouth")
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [their] [body_part]. You [sound_strength] [sound].")
				return
	return ..(M,user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	_color = "bronze"

/obj/item/clothing/accessory/medal/can_attach_to(obj/item/clothing/C)
	if(istype(C))
		return (C.body_parts_covered & UPPER_TORSO) //Sure why not

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	_color = "silver"

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	_color = "gold"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To recieve such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	_color = "holobadge"
	slot_flags = SLOT_BELT

	var/emagged = 0 //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	_color = "holobadge-cord"
	slot_flags = SLOT_MASK

/obj/item/clothing/accessory/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] displays their Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>","<span class='warning'>You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
			return
		else
			emagged = 1
			to_chat(user, "<span class='warning'>You swipe [O] and crack the holobadge security checks.</span>")
			return

	else if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_security in id_card.access || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return
	..()

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] invades [M]'s personal space, thrusting [src] into their face insistently.</span>","<span class='warning'>You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.</span>")

/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."

/obj/item/weapon/storage/box/holobadge/New()
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	..()
