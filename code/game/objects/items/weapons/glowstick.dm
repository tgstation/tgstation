#define GLOW_GREEN "#00FF00"
#define GLOW_RED "#FF0000"
#define GLOW_BLUE "#0000FF"

/obj/item/weapon/glowstick
	name = "glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is green."
	color = GLOW_GREEN
	icon = 'icons/obj/weapons.dmi'
	icon_state = "glowstick"

	light_color = GLOW_GREEN
	w_class = W_CLASS_SMALL

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is breaking open the [src.name] and eating the liquid inside! It looks like \he's  trying to commit suicide!</span>")
		return (TOXLOSS)


/obj/item/weapon/glowstick/New()
	. = ..()
	set_light(2, l_color = light_color)

/obj/item/weapon/glowstick/red
	desc = "A plastic stick filled with luminescent liquid, this one is red."
	color = GLOW_RED

	light_color = GLOW_RED

/obj/item/weapon/glowstick/blue
	desc = "A plastic stick filled with luminescent liquid, this one is blue."
	color = GLOW_BLUE

	light_color = GLOW_BLUE

/obj/item/weapon/glowstick/yellow
	desc = "A plastic stick filled with luminescent liquid, this one is yellow."
	color = "#FFFF00"

	light_color = "#FFFF00"

/obj/item/weapon/glowstick/magenta
	desc = "A plastic stick filled with luminescent liquid, this one is magenta."
	color = "#FF00FF"

	light_color = "#FF00FF"

#undef GLOW_GREEN
#undef GLOW_RED
#undef GLOW_BLUE
