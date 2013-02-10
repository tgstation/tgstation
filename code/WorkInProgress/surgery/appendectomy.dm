/datum/surgery/appendectomy
	name = "appendectomy"
	steps = list(/datum/surgery_step/open, /datum/surgery_step/close)
	location = "groin"


/datum/surgery_step/open
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 65, /obj/item/weapon/shard = 45)
	time = 12

/datum/surgery_step/open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to cut open [target].</span>")


/datum/surgery_step/close
	implements = list(/obj/item/weapon/cautery = 100, /obj/item/weapon/weldingtool = 70, /obj/item/weapon/lighter = 45, /obj/item/weapon/match = 20)
	time = 8

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to mend [target].</span>")