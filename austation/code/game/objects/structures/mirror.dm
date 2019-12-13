/obj/structure/mirror/attack_hand(mob/user)
  . = ..()
  if(.)
    return

  if(ishuman(user))
    var/mob/living/carbon/human/H = user

    var/new_hair_color = input(H, "Choose your hair color", "Hair Color","#"+H.hair_color) as color|null
    if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
      return
    if(new_hair_color)
      H.hair_color = sanitize_hexcolor(new_hair_color)
      H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
    if(H.gender == "male")
      var/new_face_color = input(H, "Choose your facial hair color", "Hair Color","#"+H.facial_hair_color) as color|null
      if(new_face_color)
        H.facial_hair_color = sanitize_hexcolor(new_face_color)
        H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
    H.update_hair()
