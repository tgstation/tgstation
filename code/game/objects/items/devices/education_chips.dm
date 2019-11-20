//This is for electronic versions of learning, for now solely martial arts

/obj/item/clothing/head/AED
  name = "Automatic Education Device"
  desc = "A complex assortment of metal, electrodes, and wires. Simply put the headset on, insert an education chip, and turn it on to instantly learn the contents of said chip."
  icon_state = "electrode_helmet"
  actions_types = list(/datum/action/item_action/instant_learn)
  pocket_storage_component_path = /datum/component/storage/concrete/pockets/tiny/AED

/obj/item/clothing/head/AED/item_action_slot_check(slot)
  if(slot == ITEM_SLOT_HEAD)
    return 1

/obj/item/clothing/head/AED/ui_action_click(mob/user, action)
  if(!src.contents.len)
    to_chat(user, "<span class='warning'>There is nothing loaded in the [src]!</span>")
    return
  for(var/obj/item/education_chip/E in src.contents)
    if(!E.subject)
      to_chat(user, "<span class='warning'>The Education Chip doesn't have a subject!</span>")
      return
    var/datum/martial_art/MA = new E.subject
    if(user.mind.has_martialart(initial(MA.id)))
      to_chat(user,"<span class='warning'>You already know [E.subject_name]!</span>")
      return
    to_chat(user, "<span class='boldannounce'>Your head whirls with a sudden rush of information as you instantly learn about [E.subject_name]!</span>")
    if(E.greet)
      to_chat(user, "[E.greet]")
    MA.teach(user)
    user.log_message("learned the subject [E.subject_name] ([MA])", LOG_ATTACK, color="orange")
    if(!E.unlimited)
      qdel(E)
      new /obj/item/education_chip(src)

/obj/item/clothing/head/AED/old
  name = "Rusty Automatic Education Device"
  desc = "A battered AED, it seems very old. Simply put the headset on, insert an education chip, and turn it on to instantly learn the contents of said chip."
  icon_state = "electrode_helmet_old"

////Education Chips////

/obj/item/education_chip
  name = "Empty Education Chip"
  desc = "An empty education chip. Who knows what information it could have contained?"
  icon = 'icons/obj/device.dmi'
  icon_state = "edchip"
  lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
  righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
  w_class = WEIGHT_CLASS_TINY
  var/subject
  var/subject_name
  var/greet
  var/unlimited = FALSE //for admins if they want unlimited uses
  var/overlay

/obj/item/education_chip/Initialize()
  . = ..()
  update_icon()

/obj/item/education_chip/update_overlays()
  . = ..()
  if(overlay)
    . += overlay
    add_overlay(overlay)

/obj/item/education_chip/cqc
  name = "Close-Quarters-Combat Education Chip"
  desc = "An education chip containing the martial art of CQC. Insert into an Automatic Education Device to learn."
  subject = /datum/martial_art/cqc
  subject_name = "Close-Quarters-Combat"
  greet = "<span class='boldannounce'>You've mastered the basics of CQC.</span>"
  overlay = "edchip_cqc"

/obj/item/education_chip/carp
  name = "the Sleeping Carp Education Chip"
  desc = "An education chip containing the martial art of Sleeping Carp. Insert into an Automatic Education Device to learn."
  subject = /datum/martial_art/the_sleeping_carp
  subject_name = "The Sleeping Carp"
  greet = "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
	directed toward you. However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>"
  overlay = "edchip_carp"

/obj/item/education_chip/plasma_fist
  name = "Plasma Fist Education Chip"
  desc = "An education chip containing the martial art of Plasma Fist. Insert into an Automatic Education Device to learn."
  subject = /datum/martial_art/plasma_fist
  subject_name = "Plasma Fist"
  greet = "<span class='boldannounce'>You have learned the ancient martial art of Plasma Fist. Your combos are extremely hard to pull off, but include some of the most deadly moves ever seen including \
	the plasma fist, which when pulled off will make someone violently explode.</span>"
  overlay = "edchip_pfist"

/obj/item/education_chip/krav_maga
  name = "Krava Maga Education Chip"
  desc = "An education chip containing the martial art of Krav Maga. Insert into an Automatic Education Device to learn."
  subject = /datum/martial_art/krav_maga
  subject_name = "Krav Maga"
  overlay = "edchip_cqc"
