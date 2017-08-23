/obj/item/device/firing_pin
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	origin_tech = "materials=2;combat=4"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("poked")
	var/emagged = FALSE
	var/fail_message = "<span class='warning'>INVALID USER.</span>"
	var/selfdestruct = 0 // Explode when user check is failed.
	var/force_replace = 0 // Can forcefully replace other pins.
	var/pin_removeable = 0 // Can be replaced by any pin.
	var/obj/item/gun/gun


/obj/item/device/firing_pin/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun))
		gun = newloc

/obj/item/device/firing_pin/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/gun))
			var/obj/item/gun/G = target
			if(G.pin && (force_replace || G.pin.pin_removeable))
				G.pin.loc = get_turf(G)
				G.pin.gun_remove(user)
				to_chat(user, "<span class ='notice'>You remove [G]'s old pin.</span>")

			if(!G.pin)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, "<span class ='notice'>You insert [src] into [G].</span>")
			else
				to_chat(user, "<span class ='notice'>This firearm already has a firing pin installed.</span>")

/obj/item/device/firing_pin/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	to_chat(user, "<span class='notice'>You override the authentication mechanism.</span>")

/obj/item/device/firing_pin/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.pin = src
	return

/obj/item/device/firing_pin/proc/gun_remove(mob/living/user)
	gun.pin = null
	gun = null
	return

/obj/item/device/firing_pin/proc/pin_auth(mob/living/user)
	return 1

/obj/item/device/firing_pin/proc/auth_fail(mob/living/user)
	user.show_message(fail_message, 1)
	if(selfdestruct)
		user.show_message("<span class='danger'>SELF-DESTRUCTING...</span><br>", 1)
		to_chat(user, "<span class='userdanger'>[gun] explodes!</span>")
		explosion(get_turf(gun), -1, 0, 2, 3)
		if(gun)
			qdel(gun)



/obj/item/device/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."


// Test pin, works only near firing range.
/obj/item/device/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."
	fail_message = "<span class='warning'>TEST RANGE CHECK FAILED.</span>"
	pin_removeable = 1
	origin_tech = "combat=2;materials=2"

/obj/item/device/firing_pin/test_range/pin_auth(mob/living/user)
	for(var/obj/machinery/magnetic_controller/M in range(user, 3))
		return 1
	return 0


// Implant pin, checks for implant
/obj/item/device/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	fail_message = "<span class='warning'>IMPLANT CHECK FAILED.</span>"
	var/obj/item/implant/req_implant = null

/obj/item/device/firing_pin/implant/pin_auth(mob/living/user)
	if(istype(user))
		for(var/obj/item/implant/I in user.implants)
			if(req_implant && I.type == req_implant)
				return 1
	return 0

/obj/item/device/firing_pin/implant/mindshield
	name = "mindshield firing pin"
	desc = "This Security firing pin authorizes the weapon for only mindshield-implanted users."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/implant/mindshield

/obj/item/device/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/implant/weapons_auth



// Honk pin, clown's joke item.
// Can replace other pins. Replace a pin in cap's laser for extra fun!
/obj/item/device/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = "#FFFF00"
	fail_message = "<span class='warning'>HONK!</span>"
	force_replace = 1

/obj/item/device/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
	return 0

// Ultra-honk pin, clown's deadly joke item.
// A gun with ultra-honk pin is useful for clown and useless for everyone else.
/obj/item/device/firing_pin/clown/ultra/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
	if(!(user.disabilities & CLUMSY) && !(user.mind && user.mind.assigned_role == "Clown"))
		return 0
	return 1

/obj/item/device/firing_pin/clown/ultra/gun_insert(mob/living/user, obj/item/gun/G)
	..()
	G.clumsy_check = 0

/obj/item/device/firing_pin/clown/ultra/gun_remove(mob/living/user)
	gun.clumsy_check = initial(gun.clumsy_check)
	..()

// Now two times deadlier!
/obj/item/device/firing_pin/clown/ultra/selfdestruct
	desc = "Advanced clowntech that can convert any firearm into a far more useful object. It has a small nitrobananium charge on it."
	selfdestruct = 1


// DNA-keyed pin.
// When you want to keep your toys for youself.
/obj/item/device/firing_pin/dna
	name = "DNA-keyed firing pin"
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link."
	icon_state = "firing_pin_dna"
	fail_message = "<span class='warning'>DNA CHECK FAILED.</span>"
	var/unique_enzymes = null

/obj/item/device/firing_pin/dna/afterattack(atom/target, mob/user, proximity_flag)
	..()
	if(proximity_flag && iscarbon(target))
		var/mob/living/carbon/M = target
		if(M.dna && M.dna.unique_enzymes)
			unique_enzymes = M.dna.unique_enzymes
			to_chat(user, "<span class='notice'>DNA-LOCK SET.</span>")

/obj/item/device/firing_pin/dna/pin_auth(mob/living/carbon/user)
	if(istype(user) && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == unique_enzymes)
			return 1

	return 0

/obj/item/device/firing_pin/dna/auth_fail(mob/living/carbon/user)
	if(!unique_enzymes)
		if(istype(user) && user.dna && user.dna.unique_enzymes)
			unique_enzymes = user.dna.unique_enzymes
			to_chat(user, "<span class='notice'>DNA-LOCK SET.</span>")
	else
		..()

/obj/item/device/firing_pin/dna/dredd
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link. It has a small explosive charge on it."
	selfdestruct = 1


// Laser tag pins
/obj/item/device/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	fail_message = "<span class='warning'>SUIT CHECK FAILED.</span>"
	var/obj/item/clothing/suit/suit_requirement = null
	var/tagcolor = ""

/obj/item/device/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return 1
	to_chat(user, "<span class='warning'>You need to be wearing [tagcolor] laser tag armor!</span>")
	return 0

/obj/item/device/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag
	tagcolor = "red"

/obj/item/device/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
	tagcolor = "blue"

/obj/item/device/firing_pin/Destroy()
	if(gun)
		gun.pin = null
	return ..()
