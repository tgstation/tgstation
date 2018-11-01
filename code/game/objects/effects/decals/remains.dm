/obj/effect/decal/remains
	name = "remains"
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'

/obj/effect/decal/remains/acid_act()
	visible_message("<span class='warning'>[src] dissolve[gender==PLURAL?"":"s"] into a puddle of sizzling goop!</span>")
	playsound(src, 'sound/items/welder.ogg', 150, 1)
	new /obj/effect/decal/cleanable/greenglow(drop_location())
	qdel(src)

/obj/effect/decal/remains/human
	desc = "They look like human remains. They have a strange aura about them."
	icon_state = "remains"

/obj/effect/decal/remains/plasma
	icon_state = "remainsplasma"

/obj/effect/decal/remains/xeno
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	icon_state = "remainsxeno"

/obj/effect/decal/remains/xeno/larva
	icon_state = "remainslarva"

/obj/effect/decal/remains/robot
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"

/obj/effect/decal/cleanable/robot_debris/old
	name = "dusty robot debris"
	desc = "Looks like nobody has touched this in a while."

/obj/effect/decal/remains/human/haunted
	desc = "Was this always here ?"
	move_resist = MOVE_RESIST_DEFAULT // ???
	anchored = FALSE
	color = "purple"

/obj/effect/decal/remains/human/haunted/Initialize()
	. = ..()
	invisibility = SEE_INVISIBLE_OBSERVER
	RegisterSignal(src,COMSIG_EXORCISM_REVEAL,.proc/reveal)
	RegisterSignal(src,COMSIG_EXORCISM_STEP,.proc/exostep)
	RegisterSignal(src,COMSIG_EXORCISM_SUCCESS,.proc/bye)

/obj/effect/decal/remains/human/haunted/proc/reveal(datum/source)
	invisibility = 0

/obj/effect/decal/remains/human/haunted/proc/exostep(datum/source)
	playsound(src,'sound/effects/pray.ogg',50)
	visible_message("<span class='haunt'>[src] start [pick("rattling","moaning","whispering","glowing","smoking")].</span>")

/obj/effect/decal/remains/human/haunted/proc/bye()
	playsound(src,'sound/effects/pray.ogg',80)
	visible_message("<span class='haunt big'>[src] uncanny aura disappears.</span>")
	color = null

/obj/effect/decal/remains/human/haunted/acid_act()
	return

/obj/effect/decal/remains/human/haunted/can_be_pulled(user, grab_state, force)
	if(istype(user,/mob/living/simple_animal/hostile/haunt))
		return FALSE
	return ..()
