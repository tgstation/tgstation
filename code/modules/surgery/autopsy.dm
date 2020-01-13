/datum/surgery/autopsy
	name = "Autopsy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders,
				 /datum/surgery_step/autopsy, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_tech = FALSE

/datum/surgery/autopsy/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(target.stat != DEAD)
		return FALSE

/datum/surgery_step/autopsy
	name = "analyze cause of death"
	implements = list(/obj/item/detective_scanner = 100, TOOL_HEMOSTAT = 75, /obj/item/pen = 50)
	time = 20
	experience_given = 20

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] starts analyzing [target].</span>", "<span class='notice'>You start analyzing  [target].</span>")

/datum/surgery_step/autopsy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	for(var/O in target.damage_record)
		if(istype(O,/obj/item))
			var/obj/item/I = O
			to_chat(user,"<span class='notice'>Analysis shows that [target] was attacked by a  [I.sharpness == IS_BLUNT ? "blunt" : "sharp"] object causing [I.autopsy_description != null ? "[I.autopsy_description]" : " [I.force > 10 ? "deep wounds" : "shallow wounds" ] "]  for [I.force] of [I.damtype] damage.</span>")
		else if(istype(O,/obj/projectile))
			var/obj/projectile/P = O
			to_chat(user,"<span class='notice'>Analysis shows that [target] was hit by a [P.flag == "bomb" ? "explosion-like projectile" : "[P.flag]" ] dealing [P.damage] [P.damage_type].</span>")
		else if(O > 0)
			to_chat(user,"<span class='notice'>Analysis shows that [target] was brawled for [O] damage.</span>")
	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user]'s finger slips destroying the data!</span>", "<span class='notice'>Your finger slips destroying the data!</span>")
	return FALSE
