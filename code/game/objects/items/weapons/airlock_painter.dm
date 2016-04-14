/obj/item/weapon/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = 2

	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=1"

	flags = CONDUCT
	slot_flags = SLOT_BELT

	var/obj/item/device/toner/ink = null

/obj/item/weapon/airlock_painter/New()
	ink = new /obj/item/device/toner(src)

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/weapon/airlock_painter/proc/use(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1)
		return 1
	else
		return 0

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/weapon/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		user << "<span class='notice'>There is no toner cartridge installed installed in \the [name]!</span>"
		return 0
	else if(ink.charges < 1)
		user << "<span class='notice'>\The [name] is out of ink!</span>"
		return 0
	else
		return 1

/obj/item/weapon/airlock_painter/suicide_act(mob/user)
	var/obj/item/organ/internal/lungs/L = user.getorganslot("lungs")

	if(can_use(user) && L)
		user.visible_message("<span class='suicide'>[user] is inhaling toner from \the [name]! It looks like \he's trying to commit suicide.</span>")
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!istype(T, /turf/open))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent("colorful_reagent", 10)
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message("<span class='suicide'>[user] vomits out their [L]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, 1)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message("<span class='suicide'>[user] is spraying toner on \himself from \the [name]! It looks like \he's trying to commit suicide.</span>")
		user.reagents.add_reagent("colorful_reagent", 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS
		
	else
		user.visible_message("<span class='suicide'>[user] is trying to inhale toner from \the [name]! It might be a suicide attempt if \the [name] had any toner.</span>")
		return SHAME


/obj/item/weapon/airlock_painter/examine(mob/user)
	..()
	if(!ink)
		user << "<span class='notice'>It doesn't have a toner cardridge installed.</span>"
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	user << "<span class='notice'>Its ink levels look [ink_level].</span>"


/obj/item/weapon/airlock_painter/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/device/toner))
		if(ink)
			user << "<span class='notice'>\the [name] already contains \a [ink].</span>"
			return
		if(!user.unEquip(W))
			return
		W.loc = src
		user << "<span class='notice'>You install \the [W] into \the [name].</span>"
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)


/obj/item/weapon/airlock_painter/attack_self(mob/user)
	if(ink)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		ink.loc = user.loc
		user.put_in_hands(ink)
		user << "<span class='notice'>You remove \the [ink] from \the [name].</span>"
		ink = null
