/*
transformative extracts:
	apply a permanent effect to a slime and all of its babies
*/
/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It pulses with a strange hunger."
	icon_state = "transformative"
	effect = "transformative"
	var/effect_applied = SLIME_EFFECT_DEFAULT

/obj/item/slimecross/transformative/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isslime(target))
		return FALSE
	var/mob/living/simple_animal/slime/s = target
	if (s.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
	if (s.transformeffects & effect_applied)
		to_chat(user,"<span class='warning'>This slime already has the [colour] transformative effect applied!</span>")
		return FALSE
	s.transformeffects |= effect_applied
	do_effect(s)

/obj/item/slimecross/transformative/proc/do_effect(mob/living/simple_animal/slime/s)
	qdel(src)

/obj/item/slimecross/transformative/grey
	colour = "grey"
	effect_applied = SLIME_EFFECT_GREY

/obj/item/slimecross/transformative/orange
	colour = "orange"
	effect_applied = SLIME_EFFECT_ORANGE

/obj/item/slimecross/transformative/purple
	colour = "purple"
	effect_applied = SLIME_EFFECT_PURPLE

/obj/item/slimecross/transformative/blue
	colour = "blue"
	effect_applied = SLIME_EFFECT_BLUE

/obj/item/slimecross/transformative/metal
	colour = "metal"
	effect_applied = SLIME_EFFECT_METAL

/obj/item/slimecross/transformative/metal/do_effect(mob/living/simple_animal/slime/s)
	s.maxHealth = round(s.maxHealth*1.5)
	qdel(src)

/obj/item/slimecross/transformative/yellow
	colour = "yellow"
	effect_applied = SLIME_EFFECT_YELLOW

/obj/item/slimecross/transformative/darkpurple
	colour = "dark purple"
	effect_applied = SLIME_EFFECT_DARK_PURPLE

/obj/item/slimecross/transformative/darkpurple/do_effect(mob/living/simple_animal/slime/s)
	s.cores = max(s.cores + 1, 5)
	qdel(src)

/obj/item/slimecross/transformative/darkblue
	colour = "dark blue"
	effect_applied = SLIME_EFFECT_DARK_BLUE

/obj/item/slimecross/transformative/silver
	colour = "silver"
	effect_applied = SLIME_EFFECT_SILVER

/obj/item/slimecross/transformative/bluespace
	colour = "bluespace"
	effect_applied = SLIME_EFFECT_BLUESPACE

/obj/item/slimecross/transformative/sepia
	colour = "sepia"
	effect_applied = SLIME_EFFECT_SEPIA

/obj/item/slimecross/transformative/cerulean
	colour = "cerulean"
	effect_applied = SLIME_EFFECT_CERULEAN

/obj/item/slimecross/transformative/pyrite
	colour = "pyrite"
	effect_applied = SLIME_EFFECT_PYRITE

/obj/item/slimecross/transformative/red
	colour = "red"
	effect_applied = SLIME_EFFECT_RED

/obj/item/slimecross/transformative/red/do_effect(mob/living/simple_animal/slime/s)
	s.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_redmod, multiplicative_slowdown = -1)
	qdel(src)

/obj/item/slimecross/transformative/green
	colour = "green"
	effect_applied = SLIME_EFFECT_GREEN

/obj/item/slimecross/transformative/pink
	colour = "pink"
	effect_applied = SLIME_EFFECT_PINK

/obj/item/slimecross/transformative/pink/do_effect(mob/living/simple_animal/slime/s)
	s.grant_language(/datum/language/common, TRUE, TRUE)
	qdel(src)

/obj/item/slimecross/transformative/gold //turn off the xenobio.dm in cargo when done
	colour = "gold"
	effect_applied = SLIME_EFFECT_GOLD

/obj/item/slimecross/transformative/oil
	colour = "oil"
	effect_applied = SLIME_EFFECT_OIL

/obj/item/slimecross/transformative/black
	colour = "black"
	effect_applied = SLIME_EFFECT_BLACK

/obj/item/slimecross/transformative/lightpink
	colour = "light pink"
	effect_applied = SLIME_EFFECT_LIGHT_PINK

/obj/item/slimecross/transformative/adamantine
	colour = "adamantine"
	effect_applied = SLIME_EFFECT_ADAMANTINE

/obj/item/slimecross/transformative/adamantine/do_effect(mob/living/simple_animal/slime/s)
	if (HAS_TRAIT_FROM(s, TRAIT_IMMOBILIZED, SLIME_COLD))
		REMOVE_TRAIT(s, TRAIT_IMMOBILIZED,SLIME_COLD)
		qdel(src)

/obj/item/slimecross/transformative/rainbow
	colour = "rainbow"
	effect_applied = SLIME_EFFECT_RAINBOW
