#define GLOW_GREEN "#00FF00"
#define GLOW_RED "#FF0000"
#define GLOW_BLUE "#0000FF"

/obj/item/weapon/glowstick
	name = "glowstick"
	desc = "A plastic stick filled with luminescent liquid, this one is green."
	color = GLOW_GREEN
	icon = 'icons/obj/weapons.dmi'
	icon_state = "glowstick"

	l_color = GLOW_GREEN
	w_class = 2
	
	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is breaking open the [src.name] and eating the liquid inside! It looks like \he's  trying to commit suicide!</b>"
		return (TOXLOSS)


/obj/item/weapon/glowstick/New()
	. = ..()
	SetLuminosity(2)

/obj/item/weapon/glowstick/red
	desc = "A plastic stick filled with luminescent liquid, this one is red."
	color = GLOW_RED

	l_color = GLOW_RED

/obj/item/weapon/glowstick/blue
	desc = "A plastic stick filled with luminescent liquid, this one is blue."
	color = GLOW_BLUE

	l_color = GLOW_BLUE

/obj/item/weapon/glowstick/yellow
	desc = "A plastic stick filled with luminescent liquid, this one is yellow."
	color = "#FFFF00"

	l_color = "#FFFF00"

/obj/item/weapon/glowstick/magenta
	desc = "A plastic stick filled with luminescent liquid, this one is magenta."
	color = "#FF00FF"

	l_color = "#FF00FF"

#undef GLOW_GREEN
#undef GLOW_RED
#undef GLOW_BLUE
