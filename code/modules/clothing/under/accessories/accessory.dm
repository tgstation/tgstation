#define DECORATION	0
#define HOLSTER		1
#define STORAGE		2
#define ARMBAND		4
#define TIE			8

/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	_color = "bluetie"
	flags = FPRINT
	slot_flags = 0
	w_class = 2.0
	var/accessory_exclusion = DECORATION
	var/obj/item/clothing/under/has_suit = null
	var/image/inv_overlay


/obj/item/clothing/accessory/New()
	..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[_color? "[_color]" : "[icon_state]"]")

/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/S, mob/user as mob)
	if(!istype(S))
		return
	has_suit = S
	if(user)
		user.drop_item(has_suit)
		user << "<span class='notice'>You attach [src] to [has_suit].</span>"
		src.add_fingerprint(user)
	else
		loc = has_suit
	has_suit.overlays += inv_overlay

/obj/item/clothing/accessory/proc/on_removed(mob/user as mob)
	if(!has_suit)
		return
	has_suit.overlays -= inv_overlay
	has_suit = null
	src.loc = get_turf(user)
	user.put_in_hands(src)
	src.add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_accessory_interact(mob/user, delayed = 0)
	if(!has_suit)
		return
	if(delayed)
		has_suit.remove_accessory(user, src)
		attack_hand(user)
		return 1
	return -1

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

				if(M.stat == DEAD || (M.status_flags&FAKEDEATH))
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if("chest")
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
		user << "Waving around a badge before swiping an ID would be pretty pointless."
		return
	if(isliving(user))
		user.visible_message("\red [user] displays their NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.","\red You display your NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.")

/obj/item/clothing/accessory/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "\red [src] is already cracked."
			return
		else
			emagged = 1
			user << "\red You swipe [O] and crack the holobadge security checks."
			return

	else if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_security in id_card.access || emagged)
			user << "You imprint your ID details onto the badge."
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			user << "[src] rejects your insufficient access rights."
		return
	..()

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("\red [user] invades [M]'s personal space, thrusting [src] into their face insistently.","\red You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.")

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