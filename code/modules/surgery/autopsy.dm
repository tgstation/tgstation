/datum/surgery/autopsy
	name = "Autopsy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/incise,

	target_mobtypes = list(/mob/living)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_tech = FALSE

/datum/surgery/autopsy/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(target.stat != DEAD)
		return FALSE

/datum/surgery_step/autopsy
	name = "analyze cause of death"
	implements = list(/obj/item/detective_scanner = 100, TOOL_HEMOSTAT = 50, /obj/item/pen = 25)
	time = 20
	experience_given = 20
	var/autopsyPrintCount = 0

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] starts analyzing [target].</span>", "<span class='notice'>You start analyzing  [target].</span>")

/datum/surgery_step/autopsy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/paper/N = new(get_turf(target))
	var frNum = ++autopsyPrintCount

	N.name = text("AR-[] 'Autopsy Record'",frNum)
	N.info = text("<center><B>Autopsy Record - (FR-[])</B></center><HR><BR>",frNum)
	N.info += "<HR><B>Notes:</B><BR>"

	for(var/O in target.damage_record)

		if(istype(O,/obj/item))
			var/obj/item/I = O
			N.info += "Analysis shows that [target] was attacked by a  [I.sharpness == IS_BLUNT ? "blunt" : "sharp"] object [I.autopsy_description != null ? "dealing [I.autopsy_description]" : "" ] causing [I.force > 10 ? "[I.force > 20 ? "devastating" : "deep" ]" : "shallow" ]  [I.damtype] damage.<BR><BR>" //double breaks for easier reading

		else if(istype(O,/obj/projectile))
			var/obj/projectile/P = O
			N.info +="Analysis shows that [target] was hit by a [P.flag == "bomb" ? "explosion-like projectile" : "[P.flag]" ] causing [P.damage > 10 ? "[P.damage > 20 ? "devastating" : "deep" ]" : "shallow" ] [P.damage_type] damage.[P.flag == "bullet" ? "The bullet holes match with [P.name]s" : "" ]<BR><BR>"

		else if(O > 0)
			N.info +="Analysis shows that [target] was brawled for [O > 5 ? "[O > 10 ? "major" : "moderate" ]" : "minor" ] damage.<BR><BR>"

	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user]'s finger slips destroying the data!</span>", "<span class='notice'>Your finger slips destroying the data!</span>")
	return FALSE
