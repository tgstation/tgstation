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
	var/mob/living/simple_animal/slime/S = target
	if(S.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
	if(S.transformeffects & effect_applied)
		to_chat(user,"<span class='warning'>This slime already has the [colour] transformative effect applied!</span>")
		return FALSE
	to_chat(user,"<span class='notice'>You apply [src] to [target].</span>")
	do_effect(S, user)
	S.transformeffects = effect_applied //S.transformeffects |= effect_applied
	qdel(src)

/obj/item/slimecross/transformative/proc/do_effect(mob/living/simple_animal/slime/S, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(S.transformeffects & SLIME_EFFECT_LIGHT_PINK)
		S.remove_form_spawner_menu()
		S.master = null
	if(S.transformeffects & SLIME_EFFECT_METAL)
		S.maxHealth = round(S.maxHealth/1.3)
	if(S.transformeffects & SLIME_EFFECT_BLUESPACE)
		S.remove_verb(/mob/living/simple_animal/slime/proc/teleport)
	if(S.transformeffects & SLIME_EFFECT_PINK)
		var/datum/language_holder/LH = S.get_language_holder()
		LH.selected_language = /datum/language/slime

/obj/item/slimecross/transformative/grey
	colour = "grey"
	effect_applied = SLIME_EFFECT_GREY
	effect_desc = "Slimes split into one additional slime."

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

/obj/item/slimecross/transformative/metal/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.maxHealth = round(S.maxHealth*1.3)

/obj/item/slimecross/transformative/yellow
	colour = "yellow"
	effect_applied = SLIME_EFFECT_YELLOW
	effect_desc = "Slimes will gain electric charge faster."

/obj/item/slimecross/transformative/darkblue
	colour = "dark blue"
	effect_applied = SLIME_EFFECT_DARK_BLUE
	effect_desc = "Slimes takes reduced damage from water."

/obj/item/slimecross/transformative/silver
	colour = "silver"
	effect_applied = SLIME_EFFECT_SILVER
	effect_desc = "Slimes will no longer lose nutrition over time."

/obj/item/slimecross/transformative/cerulean
	colour = "cerulean"
	effect_applied = SLIME_EFFECT_CERULEAN
	effect_desc = "Slime makes another adult rather than splitting, with half the nutrition."

/obj/item/slimecross/transformative/pyrite
	colour = "pyrite"
	effect_applied = SLIME_EFFECT_PYRITE
	effect_desc = "Slime always splits into totally random colors, except rainbow. Can never yield a rainbow slime."

/obj/item/slimecross/transformative/red
	colour = "red"
	effect_applied = SLIME_EFFECT_RED
	effect_desc = "Slimes does 10% more damage when feeding and attacking."

/obj/item/slimecross/transformative/pink
	colour = "pink"
	effect_applied = SLIME_EFFECT_PINK
	effect_desc = "Slimes will speak in common rather than in slime."

/obj/item/slimecross/transformative/pink/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.grant_language(/datum/language/common, TRUE, TRUE)
	var/datum/language_holder/LH = S.get_language_holder()
	LH.selected_language = /datum/language/common

/obj/item/slimecross/transformative/gold
	colour = "gold"
	effect_applied = SLIME_EFFECT_GOLD
	effect_desc = "Slime extracts from these will sell for double the price."

/obj/item/slimecross/transformative/oil
	colour = "oil"
	effect_applied = SLIME_EFFECT_OIL
	effect_desc = "Slime douses anything it feeds on in welding fuel."

/obj/item/slimecross/transformative/black
	colour = "black"
	effect_applied = SLIME_EFFECT_BLACK
	effect_desc = "Slime is nearly transparent."

/obj/item/slimecross/transformative/lightpink
	colour = "light pink"
	effect_applied = SLIME_EFFECT_LIGHT_PINK
	effect_desc = "Slimes may become possessed by supernatural forces."

/obj/item/slimecross/transformative/lightpink/do_effect(mob/living/simple_animal/slime/S, mob/user)
	..()
	GLOB.poi_list |= S
	S.master = user
	LAZYADD(GLOB.mob_spawners["[S.master.real_name]'s slime"], S)

/obj/item/slimecross/transformative/adamantine
	colour = "adamantine"
	effect_applied = SLIME_EFFECT_ADAMANTINE
	effect_desc = "Slimes takes reduced damage from brute attacks."

/obj/item/slimecross/transformative/rainbow
	colour = "rainbow"
	effect_applied = SLIME_EFFECT_RAINBOW
	effect_desc = "Slime randomly changes color periodically."
