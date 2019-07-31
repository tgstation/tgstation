//These spawn across the station when the Ark activates. Anyone can walk through one to teleport to Reebe.
/obj/effect/clockwork/city_of_cogs_rift
	name = "celestial rift"
	desc = "A stable bluespace rip. You're not sure it where leads."
	clockwork_desc = "A one-way rift to the City of Cogs. Because it's linked to the Ark, it can't be closed."
	icon_state = "city_of_cogs_rift"
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	light_range = 2
	light_power = 3
	light_color = "#6A4D2F"

/obj/effect/clockwork/city_of_cogs_rift/singularity_act()
	return

/obj/effect/clockwork/city_of_cogs_rift/singularity_pull()
	return

/obj/effect/clockwork/city_of_cogs_rift/Initialize()
	. = ..()
	visible_message("<span class='warning'>The air above [loc] shimmers and pops as a [name] forms there!</span>")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			if(get_dist(src, M) >= 7)
				M.playsound_local(src, 'sound/magic/blink.ogg', 10, FALSE, falloff = 10)
			else
				M.playsound_local(src, 'sound/magic/blink.ogg', 50, FALSE)

/obj/effect/clockwork/city_of_cogs_rift/Destroy()
	visible_message("<span class='warning'>[src] cracks as it destabilizes and breaks apart!</span>")
	return ..()

/obj/effect/clockwork/city_of_cogs_rift/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		to_chat(user, "<span class='warning'>Your [I.name] seems to have no effect on [src]!</span>")
		return
	. = ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/clockwork/city_of_cogs_rift/attack_hand(atom/movable/AM)
	beckon(AM)

/obj/effect/clockwork/city_of_cogs_rift/Bumped(atom/movable/AM)
	if(!QDELETED(AM))
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.client && !L.incapacitated())
				L.visible_message("<span class='notice'>[L] starts climbing through [src]...</span>", \
				"<span class='notice'>You begin climbing through [src]...</span>")
				if(!do_after(L, 30, target = L))
					return
		if(!istype(AM, /obj/effect/))
			beckon(AM)

/obj/effect/clockwork/city_of_cogs_rift/proc/beckon(atom/movable/AM)
	var/turf/T = get_turf(pick(GLOB.city_of_cogs_spawns))
	if(ismob(AM) && is_servant_of_ratvar(AM))
		T = GLOB.ark_of_the_clockwork_justiciar ? get_step(GLOB.ark_of_the_clockwork_justiciar, SOUTH) : get_turf(pick(GLOB.servant_spawns))
	else // Handle mechas and such
		var/list/target_contents = AM.GetAllContents() + AM
		for(var/mob/living/L in target_contents)
			if(is_servant_of_ratvar(L) && L.stat != DEAD) // Having a living cultist in your inventory sends you to the cultist spawn
				T = GLOB.ark_of_the_clockwork_justiciar ? get_step(GLOB.ark_of_the_clockwork_justiciar, SOUTH) : get_turf(pick(GLOB.servant_spawns))
				break
	AM.visible_message("<span class='danger'>[AM] passes through [src]!</span>", null, null, null, AM)
	AM.forceMove(T)
	AM.visible_message("<span class='danger'>[AM] materializes from the air!</span>", \
	"<span class='boldannounce'>You pass through [src] and appear [is_servant_of_ratvar(AM) ? "back at the City of Cogs" : "somewhere unfamiliar. Looks like it was a one-way trip.."].</span>")
	do_sparks(5, TRUE, src)
	do_sparks(5, TRUE, AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		L.clear_fullscreen("flash", 5)
		var/obj/item/transfer_valve/TTV = locate() in L.GetAllContents()
		if(TTV)
			to_chat(L, "<span class='userdanger'>The air resonates with the Ark's presence; your explosives will be significantly dampened here!</span>")
