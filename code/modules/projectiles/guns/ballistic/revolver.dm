/obj/item/weapon/gun/ballistic/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo." //usually used by syndicates
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/revolver/Initialize()
	. = ..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs -= /obj/item/weapon/gun/ballistic/revolver/verb/spin

/obj/item/weapon/gun/ballistic/revolver/chamber_round(spin = 1)
	if(spin)
		chambered = magazine.get_round(1)
	else
		chambered = magazine.stored_ammo[1]

/obj/item/weapon/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round(1)

/obj/item/weapon/gun/ballistic/revolver/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>")
		playsound(user, 'sound/weapons/bulletinsert.ogg', 60, 1)
		A.update_icon()
		update_icon()
		chamber_round(0)

/obj/item/weapon/gun/ballistic/revolver/attack_self(mob/living/user)
	var/num_unloaded = 0
	chambered = null
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		if(CB)
			CB.loc = get_turf(src.loc)
			CB.SpinAnimation(10, 1)
			CB.update_icon()
			num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>")
		playsound(user, 'sound/weapons/bulletremove.ogg', 60, 1)
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/weapon/gun/ballistic/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if(do_spin())
		usr.visible_message("[usr] spins [src]'s chamber.", "<span class='notice'>You spin [src]'s chamber.</span>")
	else
		verbs -= /obj/item/weapon/gun/ballistic/revolver/verb/spin

/obj/item/weapon/gun/ballistic/revolver/proc/do_spin()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	. = istype(C)
	if(.)
		C.spin()
		chamber_round(0)

/obj/item/weapon/gun/ballistic/revolver/can_shoot()
	return get_ammo(0,0)

/obj/item/weapon/gun/ballistic/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/ballistic/revolver/examine(mob/user)
	..()
	to_chat(user, "[get_ammo(0,0)] of those are live rounds.")

/obj/item/weapon/gun/ballistic/revolver/detective
	name = "\improper .38 Mars Special"
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	unique_rename = 1
	unique_reskin = 1

/obj/item/weapon/gun/ballistic/revolver/detective/Initialize()
	. = ..()
	options["Default"] = "detective"
	options["Leopard Spots"] = "detective_leopard"
	options["Black Panther"] = "detective_panther"
	options["Gold Trim"] = "detective_gold"
	options["The Peacemaker"] = "detective_peacemaker"
	options["Cancel"] = null

/obj/item/weapon/gun/ballistic/revolver/detective/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override = "")
	if(magazine.caliber != initial(magazine.caliber))
		if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
			playsound(user, fire_sound, 50, 1)
			to_chat(user, "<span class='userdanger'>[src] blows up in your face!</span>")
			user.take_bodypart_damage(0,20)
			user.dropItemToGround(src)
			return 0
	..()

/obj/item/weapon/gun/ballistic/revolver/detective/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/weapon/screwdriver))
		if(magazine.caliber == "38")
			to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src]...</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='userdanger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30*A.toolspeed, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='warning'>You can't modify it!</span>")
					return
				magazine.caliber = "357"
				desc = "The barrel and chamber assembly seems to have been modified."
				to_chat(user, "<span class='notice'>You reinforce the barrel of [src]. Now it will fire .357 rounds.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to revert the modifications to [src]...</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='userdanger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30*A.toolspeed, target = src))
				if(magazine.ammo_count())
					to_chat(user, "<span class='warning'>You can't modify it!</span>")
					return
				magazine.caliber = "38"
				desc = initial(desc)
				to_chat(user, "<span class='notice'>You remove the modifications on [src]. Now it will fire .38 rounds.</span>")


/obj/item/weapon/gun/ballistic/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."
	icon_state = "mateba"

/obj/item/weapon/gun/ballistic/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/revolver/nagant
	name = "nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	origin_tech = "combat=3"
	can_suppress = 1
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762


// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/ballistic/revolver/russian
	name = "\improper russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism requiring you to spin the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = FALSE

/obj/item/weapon/gun/ballistic/revolver/russian/Initialize()
	. = ..()
	do_spin()
	spun = TRUE
	update_icon()

/obj/item/weapon/gun/ballistic/revolver/russian/attackby(obj/item/A, mob/user, params)
	..()
	if(get_ammo() > 0)
		spin()
		spun = TRUE
	update_icon()
	A.update_icon()
	return

/obj/item/weapon/gun/ballistic/revolver/russian/attack_self(mob/user)
	if(!spun && can_shoot())
		spin()
		spun = TRUE
		return
	..()

/obj/item/weapon/gun/ballistic/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == INTENT_HARM) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			to_chat(user, "<span class='warning'>A mechanism prevents you from shooting anyone but yourself!</span>")
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!spun)
			to_chat(user, "<span class='warning'>You need to spin the revolver's chamber first!</span>")
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire_casing(user, user))
				playsound(user, fire_sound, 50, 1)
				var/zone = check_zone(user.zone_selected)
				var/obj/item/bodypart/affecting = H.get_bodypart(zone)
				if(zone == "head" || zone == "eyes" || zone == "mouth")
					shoot_self(user, affecting)
				else
					user.visible_message("<span class='danger'>[user.name] cowardly fires [src] at [user.p_their()] [affecting.name]!</span>", "<span class='userdanger'>You cowardly fire [src] at your [affecting.name]!</span>", "<span class='italics'>You hear a gunshot!</span>")
				chambered = null
				return

		user.visible_message("<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/ballistic/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = "head")
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message("<span class='danger'>[user.name] fires [src] at [user.p_their()] head!</span>", "<span class='userdanger'>You fire [src] at your head!</span>", "<span class='italics'>You hear a gunshot!</span>")

/obj/item/weapon/gun/ballistic/revolver/russian/soul
	name = "cursed russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/weapon/gun/ballistic/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/device/soulstone/anybody/SS = new /obj/item/device/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message("<span class='danger'>[user.name]'s soul is captured by \the [src]!</span>", "<span class='userdanger'>You've lost the gamble! Your soul is forfiet!</span>")

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/weapon/gun/ballistic/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	unique_rename = 1
	unique_reskin = 1

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/Initialize()
	. = ..()
	options["Default"] = "dshotgun"
	options["Dark Red Finish"] = "dshotgun-d"
	options["Ash"] = "dshotgun-f"
	options["Faded Grey"] = "dshotgun-g"
	options["Maple"] = "dshotgun-l"
	options["Rosewood"] = "dshotgun-p"
	options["Cancel"] = null

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/gun/energy/plasmacutter))
		sawoff(user)

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class='notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

// IMPROVISED SHOTGUN //

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "I'm just here for the gasoline."
	unique_rename = 0
	unique_reskin = 0
	var/slung = 0

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = SLOT_BACK
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>")
			slung = 1
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/update_icon()
	..()
	if(slung)
		icon_state += "sling"

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_icon()

/obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/sawn
	name = "sawn-off improvised shotgun"
	desc = "A single-shot shotgun, better not miss"
	icon_state = "ishotgun"
	item_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	sawn_state = SAWN_OFF
	slot_flags = SLOT_BELT


/obj/item/weapon/gun/ballistic/revolver/reverse //Fires directly at its user... unless the user is a clown, of course.
	clumsy_check = 0

/obj/item/weapon/gun/ballistic/revolver/reverse/can_trigger_gun(mob/living/user)
	if((user.disabilities & CLUMSY) || (user.mind && user.mind.assigned_role == "Clown"))
		return ..()
	if(process_fire(user, user, 0, zone_override = "head"))
		user.visible_message("<span class='warning'>[user] somehow manages to shoot [user.p_them()]self in the face!</span>", "<span class='userdanger'>You somehow shoot yourself in the face! How the hell?!</span>")
		user.emote("scream")
		user.drop_item()
		user.Weaken(4)
