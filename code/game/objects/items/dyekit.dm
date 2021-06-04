/obj/item/dyespray
	name = "hair dye spray"
	desc = "A spray to dye your hair any gradients you'd like."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/dyespray/attack_self(mob/user)

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/new_grad_style = input(user, "Choose a color pattern for your hair:", "Character Preference")  as null|anything in GLOB.hair_gradients_list
	if(!new_grad_style)
		return

	var/new_grad_color = input(user, "Choose your character's secondary hair color:", "Character Preference","#"+H.grad_color) as color|null
	if(!new_grad_color)
		return

	H.grad_style = new_grad_style
	H.grad_color = sanitize_hexcolor(new_grad_color)
	to_chat(H, "<span class='notice'>You apply the hair dye to your hair...</span>")
	if(!do_after(user, 3 SECONDS, target = user))
		return
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	H.update_hair()
