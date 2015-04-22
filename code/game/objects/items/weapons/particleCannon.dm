/obj/item/weapon/particle_cannon
	name = "particle cannon"
	desc = "A highly advanced weapon that fires searing streams of energy."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "wormhole_projector1"
	w_class = 4
	force = 10
	var/obj/item/weapon/stock_parts/cell/powerCell = null
	var/charging = 0 //If the cannon is charging
	var/cooldown = 0 //If the cannon can/cannot be fired
	var/fireCharge = 2500 //The power cell charge cost for a single shot


/obj/item/weapon/particle_cannon/examine(mob/user)
	..()
	if(!in_range(user, src))
		user << "<span class='notice'>You'll need to get closer to see any more.</span>"
		return
	if(!powerCell)
		user << "<span class='danger'>It seems unpowered.</span>"
		return
	if(cooldown)
		user << "<span class='notice'>It is flashing with multiple vents on its side spewing boiling vapor.</span>"
	if(charging)
		user << "<span class='danger'>A blue light is building within its barrel!</span>"


/obj/item/weapon/particle_cannon/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell/) && !powerCell)
		user << "<span class='notice'>You place \the [W] into \the [src].</span>"
		var/obj/item/weapon/stock_parts/cell/cell = W
		user.drop_item()
		powerCell = cell
		powerCell.loc = src
		return
	if(istype(W, /obj/item/weapon/screwdriver) && powerCell)
		user << "<span class='notice'>You pop out \the [src]'s power cell.</span>"
		powerCell.loc = get_turf(src)
		powerCell = null


/obj/item/weapon/particle_cannon/afterattack(atom/target as mob|obj|turf, mob/living/carbon/human/user as mob|obj, flag, params)
	if(in_range(target, user) && user.a_intent == "harm") //Hit people if they're close
		return ..()
	if(in_range(target, user) && user.a_intent != "harm") //But warn them if they're not on harm intent
		user << "<span class='warning'>\The [src] won't work this close to the target!</span>"
		return
	if(!ishuman(user))
		user << "<span class='warning'>How does this thing work?</span>"
		return
	if(cooldown)
		user << "<span class='warning'>\The [src] is overheated and cooling down.</span>"
		return
	if(charging)
		user << "<span class='warning'>You are already charging a shot!</span>"
		return
	if(!powerCell)
		user << "<span class='warning'>\The [src] requires a power cell to function.</span>"
		return
	if(powerCell && (powerCell.charge - fireCharge) < 0)
		user << "<span class='warning'>\The [src]'s power cell isn't charged enough.</span>"
		return
	charging = 1
	user << "<span class='notice'>You start charging \the [src]. Hold still...</span>"
	user << 'sound/weapons/particlecannon_charge.ogg'
	if(!do_after(user, 11))
		charging = 0
		user << "<span class='warning'>\The [src] abruptly stops charging!</span>"
		return
	charging = 0
	playsound(src.loc, 'sound/weapons/particlecannon_fire.ogg', 100, 1)
	user.visible_message("<span class='warning'>[user] fires \the [src]!</span>", \
			     "<span class='boldannounce'>\The [src] discharges its energy in a deadly beam!</span>")
	powerCell.charge -= fireCharge
	user.Beam(target, icon_state="b_beam", icon='icons/effects/beam.dmi', time=1)
	if(ismob(target))
		var/mob/living/M = target
		M.adjustFireLoss(rand(75,90))
		M.Weaken(5)
		M.visible_message("<span class='warning'>[M] is struck by \the [src]'s beam!</span>", \
				       "<span class='boldannounce'>You are forcefully slammed down as a beam of energy melts your flesh!</span>")
		M.emote("scream")
	if(isturf(target))
		if(istype(target, /turf/simulated/floor))
			var/turf/simulated/floor/F = target
			F.break_tile()
	icon_state = "wormhole_projector2"
	cooldown = 1
	spawn(75)
		cooldown = 0
		icon_state = "wormhole_projector1"
	return
