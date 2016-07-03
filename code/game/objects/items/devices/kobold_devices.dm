//Used by kobolds in lavaland in place of CQC combat if possible.
/obj/item/device/kobold_device
	name = "kobold trap"
	desc = "This shouldn't exist. You should probably ahelp this immediately."
	var/kobold_desc = "This shouldn't exist. You should probably ahelp this immediately." //Shown to kobolds upon examining
	flags = CONDUCT
	w_class = 3
	force = 5
	throw_range = 3
	materials = list(MAT_METAL = 250)
	origin_tech = "combat=3;engineering=5"

/obj/item/device/kobold_device/examine(mob/user)
	if(iskobold(user))
		desc = kobold_desc
	..()
	desc = initial(desc)


/obj/item/weapon/storage/bag/trapper //Trapper's bags hold traps and the materials to craft them
	name = "trapper's bag"
	desc = "A large goliath-hide bag fitted for storing traps."
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftbag2"
	storage_slots = 15
	max_w_class = 3
	max_combined_w_class = 30 //Ten traps
	can_hold = list(/obj/item/device/kobold_device)

/obj/item/weapon/storage/bag/trapper/full/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/device/kobold_device/goliath_snare(src)
	for(var/i in 1 to 2)
		new/obj/item/device/kobold_device/sinew_net(src)


/obj/item/device/kobold_device/goliath_snare //Goliath snares are tooth-lined rings of metal that rapidly contract when something enters it. This stuns and damages most land-bound creatures.
	name = "goliath snare"
	desc = "A metal ring lined with spikes."
	kobold_desc = "A tooth-lined proximity trap, designed to heavily wound goliath tentacles."
	icon_state = "goliath_snare_contracted"
	breakouttime = 600 //For carbon mobs that step on the snare. Takes a long time to break free because it's meant for goliaths and you just stepped on it, you dumb human you.
	var/contracted = TRUE //If the snare has already been used

/obj/item/device/kobold_device/goliath_snare/attack_self(mob/living/user)
	if(!iskobold(user))
		if(contracted)
			user << "<span class='warning'>You have no idea how this thing works.</span>"
			return
		user.visible_message("<span class='warning'>[user] sets off [src]!</span>", "<span class='userdanger'>You touch [src]'s teeth, causing it to snap onto your hand!</span>")
		playsound(user, 'sound/effects/snap.ogg', 50, 1)
		flags |= NODROP //Nice job buddy
		user.emote("scream")
		user.Stun(3)
		user.apply_damage(20, BRUTE, pick("l_arm", "r_arm"))
		contracted = TRUE
		icon_state = "goliath_snare_contracted_bloody"
		return
	if(!contracted)
		user << "<span class='warning'>[src] doesn't need to be reset!</span>"
		return
	user.visible_message("<span class='notice'>[user] deftly resets [src].</span>", "<span class='notice'>You slide your fingers between [src]'s teeth and push them back into place.</span>")
	playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
	icon_state = initial(icon_state)
	contracted = FALSE

/obj/item/device/kobold_device/goliath_snare/Crossed(atom/movable/AM)
	contract(AM)

/obj/item/device/kobold_device/goliath_snare/dropped(mob/living/user)
	..()
	alpha = 100 //Harder to see when placed

/obj/item/device/kobold_device/goliath_snare/pickup(mob/living/user)
	..()
	alpha = initial(alpha)

/obj/item/device/kobold_device/goliath_snare/proc/contract(atom/movable/AM)
	if(contracted || AM.type == type)
		return
	contracted = TRUE
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	icon_state = "[icon_state]_contracted"
	alpha = initial(alpha)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.visible_message("<span class='warning'>[src] quickly contracts around [AM]'s foot!</span>", "<span class='userdanger'>You trigger a [name]!</span>")
		C.Stun(3)
		C.emote("scream")
		C.apply_damage(20, BRUTE, pick("l_leg", "r_leg"))
		C.legcuffed = src
		loc = C
		C.update_inv_legcuffed()
		icon_state = "goliath_snare_contracted_bloody"
	else if(iskobold(AM))
		var/mob/living/simple_animal/hostile/kobold/K = AM
		K.visible_message("<span class='warning'>[src] quickly contracts around [AM]'s foot!</span>", "<span class='userdanger'>You trigger a [name], but your foot is too small for it to contract around!</span>")
		K.emote("gasp")
	else if(isliving(AM))
		var/mob/living/L = AM
		L.visible_message("<span class='warning'>[src] quickly contracts around [L]!</span>", "<span class='userdanger'>You trigger a [name]!</span>")
		L.adjustBruteLoss(20)
		icon_state = "goliath_snare_contracted_bloody"
	else if(istype(AM, /obj/effect/goliath_tentacle))
		var/obj/effect/goliath_tentacle/G = AM
		G.visible_message("<span class='warning'>[src] contracts around [G], holding it in place!</span>")
		G.owner.visible_message("<span class='warning'>[G.owner] bellows in pain!</span>", "<span class='userdanger'>A [name] heavily wounds you!</span>")
		G.owner.adjustBruteLoss(100) //1/3 of max health by default
		icon_state = "goliath_snare_contracted_bloody"


/obj/item/device/kobold_device/sinew_net //Sinew nets are made of watcher sinew and effectively stun anything trapped in them. Non-injured creatures can break free easily.
	name = "sinew net"
	desc = "A fibrous mesh made of sinewy material."
	kobold_desc = "A strong net made of watcher sinew. Throwing it at large creatures will snare them and make them vulnerable to attack."
	icon_state = "sinew_net"
	force = 0
	throw_range = 7

/obj/item/device/kobold_device/sinew_net/throw_impact(atom/movable/AM)
	if(istype(AM, /mob/living/simple_animal/hostile/asteroid))
		var/mob/living/simple_animal/hostile/asteroid/A = AM
		A.entrap(src)
	else
		..()
