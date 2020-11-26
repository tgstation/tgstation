/*
transformative extracts:
	apply a permanent effect to a slime and all of its babies
*/
/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It seems to stick to any slime it comes in contact with."
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
	s.effectsapplied++
	to_chat(user,"<span class='notice'>You apply [src] to [target].</span>")
	do_effect(s)

/obj/item/slimecross/transformative/proc/do_effect(mob/living/simple_animal/slime/s)
	qdel(src)

/obj/item/slimecross/transformative/grey
	colour = "grey"
	effect_applied = SLIME_EFFECT_GREY
	effect_desc = "Slimes will get hungry faster but split into one additional slime."

/obj/item/slimecross/transformative/orange
	colour = "orange"
	effect_applied = SLIME_EFFECT_ORANGE
	effect_desc = "Slimes will light people on fire when they shock them."

/obj/item/slimecross/transformative/purple
	colour = "purple"
	effect_applied = SLIME_EFFECT_PURPLE
	effect_desc = "Slimes will regenerate slowly."

/obj/item/slimecross/transformative/blue
	colour = "blue"
	effect_applied = SLIME_EFFECT_BLUE
	effect_desc = "Slime will always retain slime of its original colour when splitting."

/obj/item/slimecross/transformative/metal
	colour = "metal"
	effect_applied = SLIME_EFFECT_METAL
	effect_desc = "Slimes will be able to sustain more damage before dying."

/obj/item/slimecross/transformative/metal/do_effect(mob/living/simple_animal/slime/s)
	s.maxHealth = round(s.maxHealth*1.5)
	qdel(src)

/obj/item/slimecross/transformative/yellow
	colour = "yellow"
	effect_applied = SLIME_EFFECT_YELLOW
	effect_desc = "Slimes will gain electric charge faster."

/obj/item/slimecross/transformative/darkpurple
	colour = "dark purple"
	effect_applied = SLIME_EFFECT_DARK_PURPLE
	effect_desc = "Slimes are permanently under the effects of slime steroids."

/obj/item/slimecross/transformative/darkpurple/do_effect(mob/living/simple_animal/slime/s)
	s.cores = max(s.cores + 1, 5)
	qdel(src)

/obj/item/slimecross/transformative/darkblue
	colour = "dark blue"
	effect_applied = SLIME_EFFECT_DARK_BLUE
	effect_desc = "Slimes won't take damage from water."

/obj/item/slimecross/transformative/silver
	colour = "silver"
	effect_applied = SLIME_EFFECT_SILVER
	effect_desc = "Slimes will no longer lose nutrition over time."

/obj/item/slimecross/transformative/bluespace
	colour = "bluespace"
	effect_applied = SLIME_EFFECT_BLUESPACE
	effect_desc = "Slimes will teleport to targets when they are at full electric charge."

/obj/item/slimecross/transformative/sepia
	colour = "sepia"
	effect_applied = SLIME_EFFECT_SEPIA
	effect_desc = "Slimes eat faster."

/obj/item/slimecross/transformative/cerulean
	colour = "cerulean"
	effect_applied = SLIME_EFFECT_CERULEAN
	effect_desc = "Slime makes another adult rather than splitting, with half the nutrition."

/obj/item/slimecross/transformative/pyrite
	colour = "pyrite"
	effect_applied = SLIME_EFFECT_PYRITE
	effect_desc = "Slime changes colour occasionally."

/obj/item/slimecross/transformative/red
	colour = "red"
	effect_applied = SLIME_EFFECT_RED
	effect_desc = "Slimes move faster."

/obj/item/slimecross/transformative/red/do_effect(mob/living/simple_animal/slime/s)
	s.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_redmod, multiplicative_slowdown = -1)
	qdel(src)

/obj/item/slimecross/transformative/green
	colour = "green"
	effect_applied = SLIME_EFFECT_GREEN
	effect_desc = "Slimes will eat corpses."

/obj/item/slimecross/transformative/pink
	colour = "pink"
	effect_applied = SLIME_EFFECT_PINK
	effect_desc = "Slimes will speak in common rather than in slime."

/obj/item/slimecross/transformative/pink/do_effect(mob/living/simple_animal/slime/s)
	s.grant_language(/datum/language/common, TRUE, TRUE)
	qdel(src)

/obj/item/slimecross/transformative/gold
	colour = "gold"
	effect_applied = SLIME_EFFECT_GOLD
	effect_desc = "Slime extracts from these will sell for double the price."

/obj/item/slimecross/transformative/oil
	colour = "oil"
	effect_applied = SLIME_EFFECT_OIL
	effect_desc = "Slime will split into extracts upon death."

/obj/item/slimecross/transformative/black
	colour = "black"
	effect_applied = SLIME_EFFECT_BLACK
	effect_desc = "Slime will create a baby slime when it kills a monkey."

/obj/item/slimecross/transformative/lightpink
	colour = "light pink"
	effect_applied = SLIME_EFFECT_LIGHT_PINK
	effect_desc = "Slimes will no longer attack humans."

/obj/item/slimecross/transformative/adamantine
	colour = "adamantine"
	effect_applied = SLIME_EFFECT_ADAMANTINE
	effect_desc = "Slimes won't take damage from cold or pressure."

/obj/item/slimecross/transformative/adamantine/do_effect(mob/living/simple_animal/slime/s)
	if (HAS_TRAIT_FROM(s, TRAIT_IMMOBILIZED, SLIME_COLD))
		REMOVE_TRAIT(s, TRAIT_IMMOBILIZED,SLIME_COLD)
		qdel(src)

/obj/item/slimecross/transformative/rainbow
	colour = "rainbow"
	effect_applied = SLIME_EFFECT_RAINBOW
	effect_desc = "Slimes may become possessed by supernatural forces."
