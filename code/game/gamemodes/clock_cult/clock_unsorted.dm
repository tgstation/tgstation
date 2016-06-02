//AI lawset
/datum/ai_laws/ratvar
	name = "Servant of the Justiciar"
	zeroth = ("Purge all untruths and honor Ratvar.")
	inherent = list()

//Clockwork wall: Causes nearby caches to generate components
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	canSmoothWith = list(/turf/closed/wall/clockwork)
	smooth = SMOOTH_MORE

/turf/closed/wall/clockwork/New()
	..()
	PoolOrNew(/obj/effect/overlay/temp/ratvar/wall, src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam, src)
	SSobj.processing += src
	clockwork_construction_value += 5

/turf/closed/wall/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value -= 5
	..()

/turf/closed/wall/clockwork/process()
	for(var/obj/structure/clockwork/cache/C in range(1, src))
		if(prob(5))
			clockwork_component_cache[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++
			playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 20, 1)

/turf/closed/wall/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(!WT.isOn())
			return 0
		user.visible_message("<span class='notice'>[user] begins slowly breaking down [src]...</span>", "<span class='notice'>You begin painstakingly destroying [src]...</span>")
		if(!do_after(user, 120 / WT.toolspeed, target = src))
			return 0
		if(!WT.remove_fuel(1, user))
			return 0
		user.visible_message("<span class='notice'>[user] breaks apart [src]!</span>", "<span class='notice'>You break apart [src]!</span>")
		break_wall()
		return 1
	..()

/turf/closed/wall/clockwork/break_wall()
	new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
	return(new /obj/structure/girder(src))

/turf/closed/wall/clockwork/devastate_wall()
	return break_wall()

//Clockwork floor: Slowly heals conventional damage on nearby servants
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"

/turf/open/floor/clockwork/New()
	..()
	PoolOrNew(/obj/effect/overlay/temp/ratvar/floor, src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam, src)
	SSobj.processing += src
	clockwork_construction_value++

/turf/open/floor/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value--
	..()

/turf/open/floor/clockwork/process()
	for(var/mob/living/L in src)
		if(L.stat == DEAD || !is_servant_of_ratvar(L))
			continue
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)

/turf/open/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
		if(!do_after(user, 70 / I.toolspeed, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src], destroying it in doing so!</span>")
		make_plating()
		return 1
	..()

//Function Call verb: Calls forth a Ratvarian spear.
/mob/living/carbon/human/proc/function_call()
	set name = "Function Call"
	set desc = "Calls forth your Ratvarian spear."
	set category = "Clockwork"

	if(usr.l_hand && usr.r_hand)
		usr << "<span class='warning'>You need an empty to hand to call forth your spear!</span>"
		return 0
	usr.visible_message("<span class='warning'>A strange spear materializes in [usr]'s hands!</span>", "<span class='brass'>You call forth your spear!</span>")
	var/obj/item/clockwork/ratvarian_spear/R = new(get_turf(usr))
	usr.put_in_hands(R)
	usr.verbs -= /mob/living/carbon/human/proc/function_call
	return 1

#define GEAR_SECURE 1 //Construction defines for the pinion airlock
#define GEAR_UNFASTENED 2
#define GEAR_LOOSE 3

/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass."
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	opacity = 1
	hackProof = TRUE
	aiControlDisabled = TRUE
	use_power = FALSE
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction

/obj/machinery/door/airlock/clockwork/New()
	..()
	var/turf/T = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/door, T)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam/door, T)

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	if(istype(I, /obj/item/weapon/screwdriver))
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] begins unfastening [src]'s gear...</span>", "<span class='notice'>You begin unfastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1 //Returns 1 so as not to have extra interactions with the tools used (i.e. prying open)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts slightly with a pop.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins fastening [src]'s gear...</span>", "<span class='notice'>You begin fastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] fastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts back into place.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_SECURE
		else if(construction_state == GEAR_LOOSE)
			user << "<span class='warning'>The gear isn't secure enough to fasten!</span>"
		return 1
	else if(istype(I, /obj/item/weapon/wrench))
		if(construction_state == GEAR_SECURE)
			user << "<span class='warning'>[src] is too tightly secured! Your [I.name] can't get a solid grip!</span>"
			return 0
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins loosening [src]'s gear...</span>", "<span class='notice'>You begin loosening [src]'s gear...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] loosens [src]'s gear!</span>", "<span class='notice'>[src]'s gear pops off and dangles loosely.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins tightening [src]'s gear...</span>", "<span class='notice'>You begin tightening [src]'s gear into place...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] tightens [src]'s gear!</span>", "<span class='notice'>You firmly tighten [src]'s gear into place.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		return 1
	else if(istype(I, /obj/item/weapon/crowbar))
		if(construction_state == GEAR_SECURE || construction_state == GEAR_UNFASTENED)
			user << "<span class='warning'>[src]'s gear is too tightly secured! Your [I.name] can't reach under it!</span>"
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins slowly lifting off [src]'s gear...</span>", "<span class='notice'>You slowly begin lifting off [src]'s gear...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 85 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] lifts off [src]'s gear, causing it to fall apart!</span>", "<span class='notice'>You lift off [src]'s gear, causing it to fall \
			apart!</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
			new/obj/item/clockwork/component/replicant_alloy/pinion_lock(get_turf(src))
			qdel(src)
		return 1
	return 0

#undef GEAR_SECURE
#undef GEAR_UNFASTENED
#undef GEAR_LOOSE

/obj/structure/window/reinforced/clockwork
	name = "ratvarian window"
	desc = "A reinforced yellow-glass window, gently luminous."
	icon = 'icons/obj/clockwork_objects.dmi'

/obj/structure/window/reinforced/clockwork/New()
	..()
	spawn(1)
		if(!fulltile)
			var/obj/effect/E = PoolOrNew(/obj/effect/overlay/temp/ratvar/window/single, get_turf(src))
			E.dir = dir
			icon_state = "clockwork_window_single"
		else
			PoolOrNew(/obj/effect/overlay/temp/ratvar/window, get_turf(src))
			icon_state = "clockwork_window"

/*

The Ratvarian Language

	In the lore of the Servants of Ratvar, the Ratvarian tongue is a timeless language and full of power. It sounds like gibberish, much like Nar-Sie's language, but is in fact derived from
aforementioned language, and may induce miracles when spoken in the correct way with an amplifying tool (similar to runes used by the Nar-Sian cult).

	While the canon states that the language of Ratvar and his servants is incomprehensible to the unenlightened as it is a derivative of the most ancient known language, in reality it is
actually very simple. To translate a plain English sentence to Ratvar's tongue, simply move all of the letters thirteen places ahead, starting from "a" if the end of the alphabet is reached.
This cipher is known as "rot13" for "rotate 13 places" and there are many sites online that allow instant translation between English and rot13 - one of the benefits is that moving the translated
sentence thirteen places ahead changes it right back to plain English.

	There are, however, a few parts of the Ratvarian tongue that aren't typical and are implemented for fluff reasons. Some words may have apostrophes, hyphens, and spaces, making the plain
English translation apparent but disjoined (for instance, "Oru`byq zl-cbjre!" translates directly to "Beh'old my-power!") although this can be ignored without impacting overall quality. When
translating from Ratvar's tongue to plain English, simply remove the disjointments and use the finished sentence. This would make "Oru`byq zl-cbjre!" into "Behold my power!" after removing the
abnormal spacing, hyphens, and grave accents.

List of nuances:

- Any time the word "of" occurs, it is linked to the previous word by a hyphen. If it is the first word, nothing is done. (i.e. "V nz-bs Ratvar." directly translates to "I am-of Ratvar.")
- Although "Ratvar" translates to "Engine" in English, the word "Ratvar" is used regardless of language as it is a proper noun.
 - The same rule applies to Ratvar's four generals: Nezbere (Armorer), Sevtug (Fright), Nzcrentr (Amperage), and Inath-Neq (Vangu-Ard), although these words can be used in proper context if one is
   not referring to the four generals and simply using the words themselves.

*/
