/obj/item/device/firing_pin
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm reciever to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	flags =  CONDUCT
	w_class = 1
	attack_verb = list("poked")
	var/emagged = 0

/obj/item/device/firing_pin/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/weapon/gun))
			var/obj/item/weapon/gun/G = target
			if(!G.pin)
				user.drop_item()
				G.pin = src
				loc = G
			else
				user << "<span class ='notice'>This firearm already has a firing pin installed.</span>"

/obj/item/device/firing_pin/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		user << "<span class='notice'>You override the authentication mechanism.</span>"

/obj/item/device/firing_pin/proc/pin_auth(mob/living/user)
	return 1

/obj/item/device/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."

/obj/item/device/firing_pin/test_range/pin_auth(mob/living/user)
	for(var/obj/machinery/magnetic_controller/M in range(user, 3))
		return 1
	return 0

/obj/item/device/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."

/obj/item/device/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	var/obj/item/weapon/implant/req_implant = null

/obj/item/device/firing_pin/implant/pin_auth(mob/living/user)
	for(var/obj/item/weapon/implant/I in user)
		if(req_implant &&  I.imp_in == user && I.type == req_implant)
			return 1
	return 0

/obj/item/device/firing_pin/implant/loyalty
	name = "loyalty firing pin"
	desc = "This is a security firing pin which only authorizes users who are loyalty-implanted."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/weapon/implant/loyalty

/obj/item/device/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/weapon/implant/weapons_auth


/obj/item/device/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = "yellow"

/obj/item/device/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
	return 0

//muh laser tag
/obj/item/device/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	var/obj/item/clothing/suit/suit_requirement = null

/obj/item/device/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return 1
	user << "<span class='warning'>You need to be wearing [suit_requirement.name]!</span>"
	return 0

/obj/item/device/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag

/obj/item/device/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
