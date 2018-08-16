/*
//	PUMP-ACTION ENERGY GUNS
*/

/obj/item/gun/energy/pumpaction		//parent object with all procs defined under. Useless in-game, but VERY important codewise
	icon_state = "blaster"
	name = "pump-action particle blaster"
	desc = "A pump action energy gun that requires manual racking to charge supercapacitors."
	icon = 'modular_citadel/icons/obj/guns/pumpactionblaster.dmi'
	cell_type = /obj/item/stock_parts/cell/pumpaction
	var/recentpump = 0 // to prevent spammage

/obj/item/gun/energy/pumpaction/emp_act(severity)	//makes it not rack itself when emp'd
	cell.use(round(cell.charge / severity))
	chambered = null //we empty the chamber
	update_icon()

/obj/item/gun/energy/pumpaction/process()	//makes it not rack itself when self-charging
	if(selfcharge)
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return
		cell.give(100)
	update_icon()

/obj/item/gun/energy/pumpaction/attack_self(mob/living/user)	//makes clicking on it in hand pump it
	if(recentpump > world.time)
		return
	pump(user)
	recentpump = world.time + 10
	return

/obj/item/gun/energy/pumpaction/process_chamber()	//makes it so that it doesn't rack itself after firing
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot

/obj/item/gun/energy/pumpaction/select_fire(mob/living/user)	//makes it so that it doesn't rack itself when changing firing modes unless already racked
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	if(chambered)
		chambered = null
		recharge_newshot(1)
	update_icon()
	if(ismob(loc))		//forces inhands to update
		var/mob/M = loc
		M.update_inv_hands()
	return

/obj/item/gun/energy/pumpaction/update_icon()	//adds racked indicators
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(chambered)
		add_overlay("[icon_state]_rack_[shot.select_name]")
	else
		add_overlay("[icon_state]_rack_empty")

/obj/item/gun/energy/pumpaction/proc/pump(mob/M)	//pumping proc. Checks if the gun is empty and plays a different sound if it is.
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge < shot.e_cost)
		playsound(M, 'modular_citadel/sound/weapons/laserPumpEmpty.ogg', 100, 1)	//Ends with three beeps made from highly processed knife honing noises
	else
		playsound(M, 'modular_citadel/sound/weapons/laserPump.ogg', 100, 1)		//Ends with high pitched charging noise
	recharge_newshot() //try to charge a new shot
	update_icon()
	return 1

/obj/item/gun/energy/pumpaction/AltClick(mob/living/user)	//for changing firing modes since attackself is already used for pumping
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()

/obj/item/gun/energy/pumpaction/examine(mob/user)	//so people don't ask HOW TO CHANGE FIRING MODE
	..()
	to_chat(user, "<span class='notice'>Alt-click to change firing modes.</span>")

/obj/item/gun/energy/pumpaction/worn_overlays(isinhands, icon_file)	//ammo counter for inhands
	. = ..()
	var/ratio = CEILING((cell.charge / cell.maxcharge) * charge_sections, 1)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(isinhands)
		if(cell.charge < shot.e_cost)
			var/mutable_appearance/ammo_inhand = mutable_appearance(icon_file, "[item_state]_empty")
			. += ammo_inhand
		else
			var/mutable_appearance/ammo_inhand = mutable_appearance(icon_file, "[item_state]_charge_[shot.select_name][ratio]")
			. += ammo_inhand
		if(chambered)
			var/mutable_appearance/rack_inhand = mutable_appearance(icon_file, "[item_state]_rack_[shot.select_name]")
			. += rack_inhand
		else
			var/mutable_appearance/rack_inhand = mutable_appearance(icon_file, "[item_state]_rack_empty")
			. += rack_inhand

/obj/item/stock_parts/cell/pumpaction	//nice number to achieve the amount of shots wanted
	name = "pump action particle blaster power supply"
	maxcharge = 1200

//PUMP ACTION DISABLER

/obj/item/gun/energy/pumpaction/blaster
	icon_state = "blaster"
	name = "pump-action particle blaster"
	desc = "A non-lethal pump-action particle blaster with an overdrive firing mode. Requires manual racking after every shot to charge an integral bank of supercapacitors."
	item_state = "particleblaster"
	lefthand_file = 'modular_citadel/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler/pump, /obj/item/ammo_casing/energy/disabler/slug)
	ammo_x_offset = 2
	modifystate = 1

//WARDEN'S SPECIAL vERSION

/obj/item/gun/energy/pumpaction/defender
	icon_state = "defender"
	name = "particle defender"
	desc = "A pump-action particle blaster with a unique particle focusing chamber optimized for decisive de-escalation. Requires manual racking after every shot to charge an integral bank of supercapacitors."
	item_state = "particleblaster"
	lefthand_file = 'modular_citadel/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/pump, /obj/item/ammo_casing/energy/laser/pump)
	ammo_x_offset = 2
	modifystate = 1

//AMMO CASINGS (fire modes)

/obj/item/ammo_casing/energy/laser/scatter/disabler/pump
	projectile_type = /obj/item/projectile/beam/disabler/weak
	e_cost = 150
	pellets = 4
	variance = 30
	fire_sound = 'modular_citadel/sound/weapons/ParticleBlaster.ogg'
	select_name  = "disable"

/obj/item/ammo_casing/energy/disabler/slug
	projectile_type = /obj/item/projectile/beam/disabler/slug
	select_name  = "overdrive"
	e_cost = 200
	fire_sound = 'modular_citadel/sound/weapons/LaserSlugv3.ogg'

/obj/item/ammo_casing/energy/laser/pump
	projectile_type = /obj/item/projectile/beam/weak
	e_cost = 200
	select_name = "kill"
	pellets = 3
	variance = 15
	fire_sound = 'modular_citadel/sound/weapons/ParticleBlaster.ogg'

/obj/item/ammo_casing/energy/electrode/pump
	projectile_type = /obj/item/projectile/energy/electrode/pump
	select_name = "stun"
	fire_sound = 'modular_citadel/sound/weapons/LaserSlugv3.ogg'
	e_cost = 300
	pellets = 3
	variance = 20

//PROJECTILES

/obj/item/projectile/beam/disabler/weak
	name = "particle blast"
	damage = 13
	icon_state = "disablerpellet"
	icon = 'modular_citadel/icons/obj/projectiles.dmi'

/obj/item/projectile/beam/disabler/slug
	name = "positron blast"
	damage = 80
	range = 14
	speed = 0.6
	icon_state = "disablerslug"
	icon = 'modular_citadel/icons/obj/projectiles.dmi'

/obj/item/projectile/energy/electrode/pump
	name = "electron blast"
	icon_state = "stunjectile"
	icon = 'modular_citadel/icons/obj/projectiles.dmi'
	color = null
	nodamage = 1
	knockdown = 100
	stamina = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7
