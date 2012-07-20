
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it, if the light fixture is broken it will replace the
// light fixture with a working light; the broken light is then placed on the floor for the
// user to then pickup with a trash bag. If it's empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// It will need to be manually refilled with lights.
// If it's part of a robot module, it will charge when the Robot is inside a Recharge Station.
//
// EMAGGED FEATURES
//
// NOTICE: The Cyborg cannot use the emagged Light Replacer and the light's explosion was nerfed. It cannot create holes in the station anymore.
//
// I'm not sure everyone will react the emag's features so please say what your opinions are of it.
//
// When emagged it will rig every light it replaces, which will explode when the light is on.
// This is VERY noticable, even the device's name changes when you emag it so if anyone
// examines you when you're holding it in your hand, you will be discovered.
// It will also be very obvious who is setting all these lights off, since only Janitor Borgs and Janitors have easy
// access to them, and only one of them can emag their device.
//
// The explosion cannot insta-kill anyone with 30% or more health.

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


/obj/item/device/lightreplacer

	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."

	icon = 'janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"

	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	origin_tech = "magnets=3;materials=2"

	var/max_uses = 20
	var/uses = 0
	var/emagged = 0
	var/failmsg = ""
	// How much to increase per each glass?
	var/increment = 5
	// How much to take from the glass?
	var/decrement = 1
	var/charge = 1

/obj/item/device/lightreplacer/New()
	uses = max_uses / 2
	failmsg = "The [name]'s refill light blinks red."
	..()

/obj/item/device/lightreplacer/examine()
	set src in view(2)
	..()
	usr << "It has [uses] lights remaining."

/obj/item/device/lightreplacer/attackby(obj/item/W, mob/user)
	if(istype(W,  /obj/item/weapon/card/emag) && emagged == 0)
		Emag()
		return

	if(istype(W, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = W
		if(G.amount - decrement >= 0 && uses < max_uses)
			var/remaining = max(G.amount - decrement, 0)
			if(!remaining && !(G.amount - decrement) == 0)
				user << "There isn't enough glass."
				return
			G.amount = remaining
			if(!G.amount)
				user.drop_item()
				del(G)
			AddUses(increment)
			user << "You insert a piece of glass into the [src.name]. You have [uses] lights remaining."
			return

	if(istype(W, /obj/item/weapon/light))
		var/obj/item/weapon/light/L = W
		if(L.status == 0) // LIGHT OKAY
			if(uses < max_uses)
				AddUses(1)
				user << "You insert the [L.name] into the [src.name]. You have [uses] lights remaining."
				user.drop_item()
				del(L)
				return
		else
			user << "You need a working light."
			return


/obj/item/device/lightreplacer/attack_self(mob/user)
	/* // This would probably be a bit OP. If you want it though, uncomment the code.
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			src.Emag()
			usr << "You shortcircuit the [src]."
			return
	*/
	usr << "It has [uses] lights remaining."

/obj/item/device/lightreplacer/update_icon()
	icon_state = "lightreplacer[emagged]"


/obj/item/device/lightreplacer/proc/Use(var/mob/user)

	playsound(src.loc, 'click.ogg', 50, 1)
	var/pass = 0
	if(do_after(user, 30))
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		AddUses(-1)
		pass = 1
	return pass

// Negative numbers will subtract
/obj/item/device/lightreplacer/proc/AddUses(var/amount = 1)
	uses = min(max(uses + amount, 0), max_uses)

/obj/item/device/lightreplacer/proc/Charge(var/mob/user)
	charge += 1
	if(charge > 7)
		AddUses(1)
		charge = 1

/obj/item/device/lightreplacer/proc/ReplaceLight(var/obj/machinery/light/target, var/mob/living/U)

	if(target.status != LIGHT_OK)
		if(CanUse(U))
			if(!Use(U)) return
			U << "<span class='notice'>You replace the [target.fitting] with the [src].</span>"
			if(target.status != LIGHT_EMPTY)
				var/obj/item/weapon/light/L1 = new target.light_type(src.loc)
				L1.status = target.status
				L1.rigged = target.rigged
				L1.brightness = target.brightness
				L1.switchcount = target.switchcount
				target.switchcount = 0
				L1.update()

				target.status = LIGHT_EMPTY
				target.update()

			var/obj/item/weapon/light/L2 = new target.light_type()

			target.status = L2.status
			target.switchcount = L2.switchcount
			target.rigged = emagged
			target.brightness = L2.brightness
			target.on = target.has_power()
			target.update()
			del(L2)

			 // Leaving this here in case I get the go ahead to make emagged light replacers to insert rigged lights
			if(target.on && target.rigged)
				target.explode()
			return

		else
			U << failmsg
			return
	else
		U << "There is a working [target.fitting] already inserted."
		return

/obj/item/device/lightreplacer/proc/Emag()
	emagged = !emagged
	playsound(src.loc, "sparks", 100, 1)
	if(emagged)
		name = "Shortcircuited [initial(name)]"
	else
		name = initial(name)
	update_icon()

//Can you use it?

/obj/item/device/lightreplacer/proc/CanUse(var/mob/living/user)
	src.add_fingerprint(user)
	//Not sure what else to check for. Maybe if clumsy?
	if(uses > 0)
		return 1
	else
		return 0

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED