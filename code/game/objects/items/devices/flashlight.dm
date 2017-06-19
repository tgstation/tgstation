/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	actions_types = list(/datum/action/item_action/toggle_light)
	var/on = 0
	var/brightness_on = 4 //range of light when on
	var/flashlight_power //strength of the light when on. optional

/obj/item/device/flashlight/Initialize()
	..()
	update_brightness()

/obj/item/device/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(flashlight_power)
			set_light(l_range = brightness_on, l_power = flashlight_power)
		else
			set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/device/flashlight/attack_self(mob/user)
	on = !on
	update_brightness(user)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return 1

/obj/item/device/flashlight/suicide_act(mob/living/carbon/human/user)
	user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)



/obj/item/device/flashlight/attack(mob/living/carbon/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if(istype(M) && on && user.zone_selected in list("eyes", "mouth"))

		if((user.disabilities & CLUMSY || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!user.IsAdvancedToolUser())
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return

		if(!M.get_bodypart("head"))
			to_chat(user, "<span class='warning'>[M] doesn't have a head!</span>")
			return

		if(flashlight_power < 1)
			to_chat(user, "<span class='warning'>\The [src] isn't bright enough to see anything!</span> ")
			return

		switch(user.zone_selected)
			if("eyes")
				if((M.head && M.head.flags_cover & HEADCOVERSEYES) || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) || (M.glasses && M.glasses.flags_cover & GLASSESCOVERSEYES))
					to_chat(user, "<span class='notice'>You're going to need to remove that [(M.head && M.head.flags_cover & HEADCOVERSEYES) ? "helmet" : (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) ? "mask": "glasses"] first.</span>")
					return

				var/obj/item/organ/eyes/E = M.getorganslot("eye_sight")
				if(!E)
					to_chat(user, "<span class='danger'>[M] doesn't have any eyes!</span>")
					return

				if(M == user)	//they're using it on themselves
					if(M.flash_act(visual = 1))
						M.visible_message("[M] directs [src] to [M.p_their()] eyes.", "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
					else
						M.visible_message("[M] directs [src] to [M.p_their()] eyes.", "<span class='notice'>You wave the light in front of your eyes.</span>")
				else
					user.visible_message("<span class='warning'>[user] directs [src] to [M]'s eyes.</span>", \
										 "<span class='danger'>You direct [src] to [M]'s eyes.</span>")
					if(M.stat == DEAD || (M.disabilities & BLIND) || !M.flash_act(visual = 1)) //mob is dead or fully blind
						to_chat(user, "<span class='warning'>[M]'s pupils don't react to the light!</span>")
					else if(M.dna && M.dna.check_mutation(XRAY))	//mob has X-RAY vision
						to_chat(user, "<span class='danger'>[M]'s pupils give an eerie glow!</span>")
					else //they're okay!
						to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")

			if("mouth")

				if((M.head && M.head.flags_cover & HEADCOVERSMOUTH) || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSMOUTH))
					to_chat(user, "<span class='notice'>You're going to need to remove that [(M.head && M.head.flags_cover & HEADCOVERSMOUTH) ? "helmet" : "mask"] first.</span>")
					return

				var/their = M.p_their()

				var/list/mouth_organs = new
				for(var/obj/item/organ/O in M.internal_organs)
					if(O.zone == "mouth")
						mouth_organs.Add(O)
				var/organ_list = ""
				var/organ_count = LAZYLEN(mouth_organs)
				if(organ_count)
					for(var/I in 1 to organ_count)
						if(I > 1)
							if(I == mouth_organs.len)
								organ_list += ", and "
							else
								organ_list += ", "
						var/obj/item/organ/O = mouth_organs[I]
						organ_list += (O.gender == "plural" ? O.name : "\an [O.name]")

				var/pill_count = 0
				for(var/datum/action/item_action/hands_free/activate_pill/AP in M.actions)
					pill_count++

				if(M == user)
					var/can_use_mirror = FALSE
					if(isturf(user.loc))
						var/obj/structure/mirror/mirror = locate(/obj/structure/mirror, user.loc)
						if(mirror)
							switch(user.dir)
								if(NORTH)
									can_use_mirror = mirror.pixel_y > 0
								if(SOUTH)
									can_use_mirror = mirror.pixel_y < 0
								if(EAST)
									can_use_mirror = mirror.pixel_x > 0
								if(WEST)
									can_use_mirror = mirror.pixel_x < 0

					M.visible_message("[M] directs [src] to [their] mouth.", \
					"<span class='notice'>You point [src] into your mouth.</span>")
					if(!can_use_mirror)
						to_chat(user, "<span class='notice'>You can't see anything without a mirror.</span>")
						return
					if(organ_count)
						to_chat(user, "<span class='notice'>Inside your mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>")
					else
						to_chat(user, "<span class='notice'>There's nothing inside your mouth.</span>")
					if(pill_count)
						to_chat(user, "<span class='notice'>You have [pill_count] implanted pill[pill_count > 1 ? "s" : ""].</span>")

				else
					user.visible_message("<span class='notice'>[user] directs [src] to [M]'s mouth.</span>",\
										 "<span class='notice'>You direct [src] to [M]'s mouth.</span>")
					if(organ_count)
						to_chat(user, "<span class='notice'>Inside [their] mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>")
					else
						to_chat(user, "<span class='notice'>[M] doesn't have any organs in [their] mouth.</span>")
					if(pill_count)
						to_chat(user, "<span class='notice'>[M] has [pill_count] pill[pill_count > 1 ? "s" : ""] implanted in [their] teeth.")

	else
		return ..()

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff. It can also be used to create a hologram to alert people of incoming medical assistance."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	brightness_on = 2
	var/holo_cooldown = 0

/obj/item/device/flashlight/pen/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		if(holo_cooldown > world.time)
			to_chat(user, "<span class='warning'>[src] is not ready yet!</span>")
			return
		var/T = get_turf(target)
		if(locate(/mob/living) in T)
			new /obj/effect/temp_visual/medical_holosign(T,user) //produce a holographic glow
			holo_cooldown = world.time + 100
			return
	..()

/obj/effect/temp_visual/medical_holosign
	name = "medical holosign"
	desc = "A small holographic glow that indicates a medic is coming to treat a patient."
	icon_state = "medi_holo"
	duration = 30

/obj/effect/temp_visual/medical_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/machines/ping.ogg', 50, 0) //make some noise!
	if(creator)
		visible_message("<span class='danger'>[creator] created a medical hologram!</span>")


/obj/item/device/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	force = 9 // Not as good as a stun baton.
	brightness_on = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	materials = list()
	on = 1


// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"



/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

//Bananalamp
/obj/item/device/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	item_state = "bananalamp"

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 7 // Pretty bright.
	icon_state = "flare"
	item_state = "flare"
	actions_types = list()
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	heat = 1000
	light_color = LIGHT_COLOR_FLARE

/obj/item/device/flashlight/flare/New()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	..()

/obj/item/device/flashlight/flare/process()
	open_flame(heat)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/ignition_effect(atom/A, mob/user)
	if(fuel && on)
		. = "<span class='notice'>[user] lights [A] with [src] like a real \
			badass.</span>"
	else
		. = ""

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

/obj/item/device/flashlight/flare/update_brightness(mob/user = null)
	..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already on.</span>")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] lights \the [src].</span>", "<span class='notice'>You light \the [src]!</span>")
		force = on_damage
		damtype = "fire"
		START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/is_hot()
	return on * heat

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	w_class = WEIGHT_CLASS_BULKY
	brightness_on = 4
	icon_state = "torch"
	item_state = "torch"
	on_damage = 10
	slot_flags = null

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	item_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on


/obj/item/device/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "Extract from a yellow slime. It emits a strong light when squeezed."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime"
	item_state = "slime"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list()
	brightness_on = 6 //luminosity when on

/obj/item/device/flashlight/emp
	origin_tech = "magnets=3;syndicate=1"
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0


/obj/item/device/flashlight/emp/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/device/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/device/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(on && user.zone_selected in list("eyes", "mouth")) // call original attack when examining organs
		..()
	return

/obj/item/device/flashlight/emp/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return

	if(emp_cur_charges > 0)
		emp_cur_charges -= 1

		if(ismob(A))
			var/mob/M = A
			add_logs(user, M, "attacked", "EMP-light")
			M.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].", \
								"<span class='userdanger'>[user] blinks \the [src] at you.")
		else
			A.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].")
		to_chat(user, "\The [src] now has [emp_cur_charges] charge\s.")
		A.emp_act(1)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
	return

// Glowsticks, in the uncomfortable range of similar to flares,
// but not similar enough to make it worth a refactor
/obj/item/device/flashlight/glowstick
	name = "glowstick"
	desc = "A military-grade glowstick."
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	var/fuel = 0

/obj/item/device/flashlight/glowstick/Initialize()
	fuel = rand(1600, 2000)
	light_color = color
	..()

/obj/item/device/flashlight/glowstick/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/device/flashlight/glowstick/process()
	fuel = max(fuel - 1, 0)
	if(!fuel)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/item/device/flashlight/glowstick/proc/turn_off()
	on = 0
	update_icon()

/obj/item/device/flashlight/glowstick/update_icon()
	item_state = "glowstick"
	overlays.Cut()
	if(!fuel)
		icon_state = "glowstick-empty"
		cut_overlays()
		set_light(0)
	else if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		add_overlay(glowstick_overlay)
		item_state = "glowstick-on"
		set_light(brightness_on)
	else
		icon_state = "glowstick"
		cut_overlays()

/obj/item/device/flashlight/glowstick/attack_self(mob/user)
	if(!fuel)
		to_chat(user, "<span class='notice'>[src] is spent.</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already lit.</span>")
		return

	. = ..()
	if(.)
		user.visible_message("<span class='notice'>[user] cracks and shakes [src].</span>", "<span class='notice'>You crack and shake [src], turning it on!</span>")
		activate()

/obj/item/device/flashlight/glowstick/proc/activate()
	if(!on)
		on = TRUE
		START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED

/obj/item/device/flashlight/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE

/obj/item/device/flashlight/glowstick/cyan
	name = "cyan glowstick"
	color = LIGHT_COLOR_CYAN

/obj/item/device/flashlight/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE

/obj/item/device/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW

/obj/item/device/flashlight/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK

/obj/item/device/flashlight/glowstick/random
	name = "random colored glowstick"

/obj/item/device/flashlight/glowstick/random/Initialize()
	var/list/glowtypes = typesof(/obj/item/device/flashlight/glowstick)
	glowtypes -= /obj/item/device/flashlight/glowstick/random

	var/obj/item/device/flashlight/glowstick/glowtype = pick(glowtypes)

	name = initial(glowtype.name)
	color = initial(glowtype.color)
	. = ..()

/obj/item/device/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_color = null
	brightness_on = 0
	light_range = 0
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	var/range = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/device/flashlight/flashdark
	name = "flashdark"
	desc = "A strange device manufactured with mysterious elements that somehow emits darkness. Or maybe it just sucks in light? Nobody knows for sure."
	icon_state = "flashdark"
	item_state = "flashdark"
	brightness_on = 2.5
	flashlight_power = -3

/obj/item/device/flashlight/eyelight
	name = "eyelight"
	desc = "This shouldn't exist outside of someone's head, how are you seeing this?"
	brightness_on = 15
	flashlight_power = 1
	flags = CONDUCT | DROPDEL
	actions_types = list()
