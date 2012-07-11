
// TARGET STAKE
// TARGET
// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = CONDUCT
	var/obj/item/target/pinned_target // the current pinned target

	Move()
		..()
		// Move the pinned target along with the stake
		if(pinned_target in view(3, src))
			pinned_target.loc = loc

		else // Sanity check: if the pinned target can't be found in immediate view
			pinned_target = null
			density = 1

	attackby(obj/item/W as obj, mob/user as mob)
		// Putting objects on the stake. Most importantly, targets
		if(pinned_target)
			return // get rid of that pinned target first!

		if(istype(W, /obj/item/target))
			density = 0
			W.density = 1
			user.drop_item(src)
			W.loc = loc
			W.layer = 3.1
			pinned_target = W
			user << "You slide the target into the stake."
		return

	attack_hand(mob/user as mob)
		// taking pinned targets off!
		if(pinned_target)
			density = 1
			pinned_target.density = 0
			pinned_target.layer = OBJ_LAYER

			pinned_target.loc = user.loc
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(pinned_target)
					user << "You take the target out of the stake."
			else
				pinned_target.loc = get_turf_loc(user)
				user << "You take the target out of the stake."

			pinned_target = null



// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'objects.dmi'
	icon_state = "target_h"
	density = 0
	var/hp = 1800
	var/icon/virtualIcon
	var/list/bulletholes = list()

	Del()
		// if a target is deleted and associated with a stake, force stake to forget
		for(var/obj/structure/target_stake/T in view(3,src))
			if(T.pinned_target == src)
				T.pinned_target = null
				T.density = 1
				break
		..() // delete target

	Move()
		..()
		// After target moves, check for nearby stakes. If associated, move to target
		for(var/obj/structure/target_stake/M in view(3,src))
			if(M.density == 0 && M.pinned_target == src)
				M.loc = loc

		// This may seem a little counter-intuitive but I assure you that's for a purpose.
		// Stakes are the ones that carry targets, yes, but in the stake code we set
		// a stake's density to 0 meaning it can't be pushed anymore. Instead of pushing
		// the stake now, we have to push the target.



	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				overlays = null
				usr << "You slice off [src]'s uneven chunks of aluminum and scorch marks."
				return


	attack_hand(mob/user as mob)
		// taking pinned targets off!
		var/obj/structure/target_stake/stake
		for(var/obj/structure/target_stake/T in view(3,src))
			if(T.pinned_target == src)
				stake = T
				break

		if(stake)
			if(stake.pinned_target)
				stake.density = 1
				density = 0
				layer = OBJ_LAYER

				loc = user.loc
				if(ishuman(user))
					if(!user.get_active_hand())
						user.put_in_hands(src)
						user << "You take the target out of the stake."
				else
					src.loc = get_turf_loc(user)
					user << "You take the target out of the stake."

				stake.pinned_target = null
				return

		else
			..()

	syndicate
		icon_state = "target_s"
		desc = "A shooting target that looks like a syndicate scum."
		hp = 2600 // i guess syndie targets are sturdier?
	alien
		icon_state = "target_q"
		desc = "A shooting target that looks like a xenomorphic alien."
		hp = 2350 // alium onest too kinda

/obj/item/target/bullet_act(var/obj/item/projectile/Proj)
	var/p_x = Proj.p_x + pick(0,0,0,0,0,-1,1) // really ugly way of coding "sometimes offset Proj.p_x!"
	var/p_y = Proj.p_y + pick(0,0,0,0,0,-1,1)
	var/decaltype = 1 // 1 - scorch, 2 - bullet

	if(istype(/obj/item/projectile/bullet, Proj))
		decaltype = 2


	virtualIcon = new(icon, icon_state)

	if( virtualIcon.GetPixel(p_x, p_y) ) // if the located pixel isn't blank (null)

		hp -= Proj.damage
		if(hp <= 0)
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << "\red [src] breaks into tiny pieces and collapses!"
			del(src)

		// Create a temporary object to represent the damage
		var/obj/bmark = new
		bmark.pixel_x = p_x
		bmark.pixel_y = p_y
		bmark.icon = 'effects.dmi'
		bmark.layer = 3.5
		bmark.icon_state = "scorch"

		if(decaltype == 1)
			// Energy weapons are hot. they scorch!

			// offset correction
			bmark.pixel_x--
			bmark.pixel_y--

			if(Proj.damage >= 20 || istype(Proj, /obj/item/projectile/practice))
				bmark.icon_state = "scorch"
				bmark.dir = pick(NORTH,SOUTH,EAST,WEST) // random scorch design


			else
				bmark.icon_state = "light_scorch"
		else

			// Bullets are hard. They make dents!
			bmark.icon_state = "dent"

		if(Proj.damage >= 10 && bulletholes.len <= 35) // maximum of 35 bullet holes
			if(decaltype == 2) // bullet
				if(prob(Proj.damage+30)) // bullets make holes more commonly!
					new/datum/bullethole(src, bmark.pixel_x, bmark.pixel_y) // create new bullet hole
			else // Lasers!
				if(prob(Proj.damage-10)) // lasers make holes less commonly
					new/datum/bullethole(src, bmark.pixel_x, bmark.pixel_y) // create new bullet hole

		// draw bullet holes
		for(var/datum/bullethole/B in bulletholes)

			virtualIcon.DrawBox(null, B.b1x1, B.b1y,  B.b1x2, B.b1y) // horizontal line, left to right
			virtualIcon.DrawBox(null, B.b2x, B.b2y1,  B.b2x, B.b2y2) // vertical line, top to bottom

		overlays += bmark // add the decal

		icon = virtualIcon // apply bulletholes over decals

		return

	return -1 // the bullet/projectile goes through the target! Ie, you missed


// Small memory holder entity for transparent bullet holes
/datum/bullethole
	// First box
	var/b1x1 = 0
	var/b1x2 = 0
	var/b1y = 0

	// Second box
	var/b2x = 0
	var/b2y1 = 0
	var/b2y2 = 0

	New(var/obj/item/target/Target, var/pixel_x = 0, var/pixel_y = 0)
		if(!Target) return

		// Randomize the first box
		b1x1 = pixel_x - pick(1,1,1,1,2,2,3,3,4)
		b1x2 = pixel_x + pick(1,1,1,1,2,2,3,3,4)
		b1y = pixel_y
		if(prob(35))
			b1y += rand(-4,4)

		// Randomize the second box
		b2x = pixel_x
		if(prob(35))
			b2x += rand(-4,4)
		b2y1 = pixel_y + pick(1,1,1,1,2,2,3,3,4)
		b2y2 = pixel_y - pick(1,1,1,1,2,2,3,3,4)

		Target.bulletholes.Add(src)










