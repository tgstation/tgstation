<<<<<<< HEAD
/obj/item/weapon/gun/projectile/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo." //usually used by syndicates
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"

/obj/item/weapon/gun/projectile/revolver/New()
	..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs -= /obj/item/weapon/gun/projectile/revolver/verb/spin

/obj/item/weapon/gun/projectile/revolver/chamber_round(var/spin = 1)
	if(spin)
		chambered = magazine.get_round(1)
	else
		chambered = magazine.stored_ammo[1]
	return

/obj/item/weapon/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round(1)

/obj/item/weapon/gun/projectile/revolver/process_chamber()
	return ..(0, 1)

/obj/item/weapon/gun/projectile/revolver/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>"
		A.update_icon()
		update_icon()
		chamber_round(0)

	if(unique_rename)
		if(istype(A, /obj/item/weapon/pen))
			rename_gun(user)

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/living/user)
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
		user << "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>"
	else
		user << "<span class='warning'>[src] is empty!</span>"

/obj/item/weapon/gun/projectile/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if(istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
		C.spin()
		chamber_round(0)
		usr.visible_message("[usr] spins [src]'s chamber.", "<span class='notice'>You spin [src]'s chamber.</span>")
	else
		verbs -= /obj/item/weapon/gun/projectile/revolver/verb/spin


/obj/item/weapon/gun/projectile/revolver/can_shoot()
	return get_ammo(0,0)

/obj/item/weapon/gun/projectile/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/projectile/revolver/examine(mob/user)
	..()
	user << "[get_ammo(0,0)] of those are live rounds."

/obj/item/weapon/gun/projectile/revolver/detective
	name = "\improper .38 Mars Special"
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	unique_rename = 1
	unique_reskin = 1

/obj/item/weapon/gun/projectile/revolver/detective/New()
	..()
	options["Default"] = "detective"
	options["Leopard Spots"] = "detective_leopard"
	options["Black Panther"] = "detective_panther"
	options["Gold Trim"] = "detective_gold"
	options["The Peacemaker"] = "detective_peacemaker"
	options["Cancel"] = null

/obj/item/weapon/gun/projectile/revolver/detective/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override = "")
	if(magazine.caliber != initial(magazine.caliber))
		if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
			playsound(user, fire_sound, 50, 1)
			user << "<span class='userdanger'>[src] blows up in your face!</span>"
			user.take_organ_damage(0,20)
			user.unEquip(src)
			return 0
	..()

/obj/item/weapon/gun/projectile/revolver/detective/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/weapon/screwdriver))
		if(magazine.caliber == "38")
			user << "<span class='notice'>You begin to reinforce the barrel of [src]...</span>"
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='userdanger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30/A.toolspeed, target = src))
				if(magazine.ammo_count())
					user << "<span class='warning'>You can't modify it!</span>"
					return
				magazine.caliber = "357"
				desc = "The barrel and chamber assembly seems to have been modified."
				user << "<span class='notice'>You reinforce the barrel of [src]. Now it will fire .357 rounds.</span>"
		else
			user << "<span class='notice'>You begin to revert the modifications to [src]...</span>"
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='userdanger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30/A.toolspeed, target = src))
				if(magazine.ammo_count())
					user << "<span class='warning'>You can't modify it!</span>"
					return
				magazine.caliber = "38"
				desc = initial(desc)
				user << "<span class='notice'>You remove the modifications on [src]. Now it will fire .38 rounds.</span>"


/obj/item/weapon/gun/projectile/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."
	icon_state = "mateba"

/obj/item/weapon/gun/projectile/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/projectile/revolver/nagant
	name = "nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	origin_tech = "combat=3"
	can_suppress = 1
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762


// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/revolver/russian
	name = "\improper russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism requiring you to spin the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/rus357
	var/spun = 0

/obj/item/weapon/gun/projectile/revolver/russian/New()
	..()
	Spin()
	update_icon()

/obj/item/weapon/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(0,0))
		chamber_round()
	spun = 1

/obj/item/weapon/gun/projectile/revolver/russian/attackby(obj/item/A, mob/user, params)
	var/num_loaded = ..()
	if(num_loaded)
		user.visible_message("[user] loads a single bullet into the revolver and spins the chamber.", "<span class='notice'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("[user] spins the chamber of the revolver.", "<span class='notice'>You spin the revolver's chamber.</span>")
	if(get_ammo() > 0)
		Spin()
	update_icon()
	A.update_icon()
	return

/obj/item/weapon/gun/projectile/revolver/russian/attack_self(mob/user)
	if(!spun && can_shoot())
		user.visible_message("[user] spins the chamber of the revolver.", "<span class='notice'>You spin the revolver's chamber.</span>")
		Spin()
	else
		var/num_unloaded = 0
		while (get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round()
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.update_icon()
			num_unloaded++
		if (num_unloaded)
			user << "<span class='notice'>You unload [num_unloaded] shell\s from [src].</span>"
		else
			user << "<span class='notice'>[src] is empty.</span>"

/obj/item/weapon/gun/projectile/revolver/russian/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == "harm") // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			user << "<span class='warning'>A mechanism prevents you from shooting anyone but yourself!</span>"
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!spun)
			user << "<span class='warning'>You need to spin the revolver's chamber first!</span>"
			return

		spun = 0

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire(user, user))
				playsound(user, fire_sound, 50, 1)
				var/zone = check_zone(user.zone_selected)
				var/obj/item/bodypart/affecting = H.get_bodypart(zone)
				if(zone == "head" || zone == "eyes" || zone == "mouth")
					shoot_self(user, affecting)
				else
					user.visible_message("<span class='danger'>[user.name] cowardly fires [src] at \his [affecting.name]!</span>", "<span class='userdanger'>You cowardly fire [src] at your [affecting.name]!</span>", "<span class='italics'>You hear a gunshot!</span>")
				return

		user.visible_message("<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/projectile/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = "head")
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='userdanger'>You fire [src] at your head!</span>", "<span class='italics'>You hear a gunshot!</span>")

/obj/item/weapon/gun/projectile/revolver/russian/soul
	name = "cursed russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/weapon/gun/projectile/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/device/soulstone/anybody/SS = new /obj/item/device/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message("<span class='danger'>[user.name]'s soul is captured by \the [src]!</span>", "<span class='userdanger'>You've lost the gamble! Your soul is forfiet!</span>")



/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = 4
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	unique_rename = 1
	unique_reskin = 1

/obj/item/weapon/gun/projectile/revolver/doublebarrel/New()
	..()
	options["Default"] = "dshotgun"
	options["Dark Red Finish"] = "dshotgun-d"
	options["Ash"] = "dshotgun-f"
	options["Faded Grey"] = "dshotgun-g"
	options["Maple"] = "dshotgun-l"
	options["Rosewood"] = "dshotgun-p"
	options["Cancel"] = null

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/gun/energy/plasmacutter))
		sawoff(user)

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		user << "<span class='notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>"
	else
		user << "<span class='warning'>[src] is empty!</span>"




// IMPROVISED SHOTGUN //

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = 4
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "I'm just here for the gasoline."
	unique_rename = 0
	unique_reskin = 0
	var/slung = 0

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = SLOT_BACK
			user << "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>"
			slung = 1
			update_icon()
		else
			user << "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/update_icon()
	..()
	if(slung)
		icon_state += "sling"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_icon()
=======
/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	max_shells = 6
	caliber = list("38" = 1, "357" = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_casing/c38"
	var/perfect = 0

	special_check(var/mob/living/carbon/human/M) //to see if the gun fires 357 rounds safely. A non-modified revolver randomly blows up
		if(getAmmo()) //this is a good check, I like this check
			var/obj/item/ammo_casing/AC = loaded[1]
			if(caliber["38"] == 0) //if it's been modified, this is true
				return 1
			if(istype(AC, /obj/item/ammo_casing/a357) && !perfect && prob(70 - (getAmmo() * 10)))	//minimum probability of 10, maximum of 60
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return 0
		return 1

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(src,M))
			name = input
			to_chat(M, "You name the gun [input]. Say hello to your new friend.")
			return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		..()
		if(isscrewdriver(A) || istype(A, /obj/item/weapon/conversion_kit))
			var/obj/item/weapon/conversion_kit/CK
			if(istype(A, /obj/item/weapon/conversion_kit))
				CK = A
				if(!CK.open)
					to_chat(user, "<span class='notice'>This [CK.name] is useless unless you open it first. </span>")
					return
			if(caliber["38"])
				to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//you know the drill
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 0
					desc = "The barrel and chamber assembly seems to have been modified."
					to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
					if(CK && istype(CK))
						perfect = 1
			else
				to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//and again
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 1
					desc = initial(desc)
					to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")
					perfect = 0




/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"


// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.
// Makes liberal use of cut() to move around the rounds after firing.

/obj/item/weapon/gun/projectile/russian
	name = "russian revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has six slots for ammo."
	max_shells = 6
	origin_tech = "combat=2;materials=2"
	fire_delay = 1

/obj/item/weapon/gun/projectile/russian/New()
	loaded = new/list(6) //imperative that this keeps 6 entries at all times
	loaded[1] = new ammo_type(src)
	Spin() //randomize where the first round is located
	update_icon()

/obj/item/weapon/gun/projectile/russian/proc/Spin()
	loaded = shuffle(loaded)

/obj/item/weapon/gun/projectile/russian/attackby(var/obj/item/A as obj, mob/user as mob)

	if(!A) return

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_casing)) //loading rounds one by one
		var/obj/item/ammo_casing/AC = A
		if(src.getAmmo() >= max_shells)
			to_chat(user, "<span class='warning'>It's already full of ammo.</span>")
			return
		if(caliber[AC.caliber])
			user.drop_item(AC)
			AC.loc = src
			loaded += AC
			loaded -= null //ensure that the list constantly has 6 entries
			num_loaded++

	if(istype(A, /obj/item/ammo_storage)) //loading rounds from a box, still one by one
		var/obj/item/ammo_storage/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(src.getAmmo() >= max_shells)
				to_chat(user, "<span class='warning'>It's already full of ammo.</span>")
				return
			if(caliber[AC.caliber] && getAmmo() < max_shells)
				AC.loc = src
				AM.stored_ammo -= AC
				loaded += AC
				loaded -= null //same here
				num_loaded++
			break //one at a time
		A.update_icon()

	if(num_loaded)
		user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")


	if(getAmmo() > 0)
		Spin()
	playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
	update_icon()
	return

/obj/item/weapon/gun/projectile/russian/attack_self(mob/user as mob)

	user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
	if(getAmmo() > 0)
		Spin()

/obj/item/weapon/gun/projectile/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	var/obj/item/ammo_casing/AC = loaded[1]
	if(isliving(target) && isliving(user) && target == user)
		if(mouthshoot)
			to_chat(user, "<span class='warning'>You're already doing that.</span>")
			return
		var/datum/organ/external/affecting = user.zone_sel.selecting
		if(affecting == LIMB_HEAD || affecting == "mouth")
			user.visible_message("<span class='danger'>[user.name] puts \the [src] [affecting == LIMB_HEAD ? "against their head" : "in their mouth"], ready to pull the trigger...</span>")
			mouthshoot = 1
			if(!do_after(user,src, 40))
				user.visible_message("<span class='warning'>[user.name] chickened out.</span>")
				mouthshoot = 0
				return
			mouthshoot = 0
			if(!AC || !AC.BB)
				user.visible_message("<span class='warning'>*click*</span>")
				playsound(user, 'sound/weapons/empty.ogg', 100, 1)
				loaded.Cut(1,2)
				loaded += AC
				return
			if(AC.BB)
				in_chamber = AC.BB //Load projectile into chamber.
				AC.BB.loc = src //Set projectile loc to gun.
				AC.BB = null //Empty casings
				AC.update_icon()
			if(!in_chamber)
				return
			var/obj/item/projectile/P = new AC.projectile_type
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>[user.name] fires \the [src]!</span>", "<span class='danger'>You fire \the [src]!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
			if(!P.nodamage)
				affecting = LIMB_HEAD
				user.apply_damage(300, BRUTE, affecting, used_weapon = "Shot self with [src].") // You are dead, dead, dead.
			in_chamber = null
			loaded.Cut(1,2)
			loaded += AC //to make it more realistic, empty casings remain in until you empty the gun
		else
			to_chat(user, "<span class='warning'>Aim for your head or put it in your mouth.</span>")
			return

	..()

/obj/item/weapon/gun/projectile/russian/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	var/obj/item/ammo_casing/AC = loaded[1]
	if(!AC || !AC.BB)
		user.visible_message("<span class='warning'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		loaded.Cut(1,2)
		loaded += AC
		return

	..()
	loaded += AC
	AC.forceMove(src) //get back in there you

/obj/item/weapon/gun/projectile/russian/force_removeMag()
	if(getAmmo() > 0)
		for(var/obj/item/ammo_casing/AC in loaded)
			AC.forceMove(get_turf(src))
			loaded -= AC
			loaded += null
	src.loc.visible_message("<span class='warning'>[src] empties onto the ground!</span>")


/obj/item/weapon/gun/projectile/russian/empty/New()
	update_icon()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
