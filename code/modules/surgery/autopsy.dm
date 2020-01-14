#define UNARMED_WOUND "unarmed"
#define WEAPON_WOUND "weapon"
#define PROJECTILE_WOUND "projectile"

/datum/surgery/autopsy
	name = "Autopsy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/incise,/datum/surgery_step/autopsy,/datum/surgery_step/close)

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
	N.info = text("<center><B>Autopsy Record - (AR-[])</B></center><HR><BR>",frNum)
	N.info += "<HR><B>Notes:</B><BR>"

	for(var/datum/autopsy_record/AR in target.damage_record)

		if(AR.wound_type == WEAPON_WOUND)
			N.info += "Analysis shows that [target] was attacked by a  [AR.sharpness == IS_BLUNT ? "blunt" : "sharp"] object [AR.special_description != null ? "dealing [AR.special_description]" : "" ] causing [AR.damage > 10 ? "[AR.damage > 20 ? "devastating" : "deep" ]" : "shallow" ]  [AR.damage_type] damage.<BR><BR>" //double breaks for easier reading

		if(AR.wound_type == PROJECTILE_WOUND)
			N.info +="Analysis shows that [target] was hit by a [AR.ranged_flag == "bomb" ? "explosion-like projectile" : "[AR.ranged_flag]" ] causing [AR.damage > 10 ? "[AR.damage > 20 ? "devastating" : "deep" ]" : "shallow" ] [AR.damage_type] damage. [AR.ranged_flag == "bullet" ? "The bullet holes match with [AR.source_name]s" : "" ] <BR><BR>"

		if(AR.wound_type == UNARMED_WOUND)
			N.info +="Analysis shows that [target] was brawled for [AR.damage > 5 ? "[AR.damage > 10 ? "major" : "moderate" ]" : "minor" ] damage. [AR.source_name != null ? "The attacker shows in depth knowledge of [AR.source_name]": "The attacker's attack pattern is random and chaotic showing lack of in depth martial skills" ]<BR><BR>"

	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user]'s finger slips destroying the data!</span>", "<span class='notice'>Your finger slips destroying the data!</span>")
	return FALSE

/datum/autopsy_record
	var/source_name
	var/source 			//reference to the object that causes the wound. it can be anything.
	var/wound_type = UNARMED_WOUND

	var/damage_type = BRUTE
	var/damage = 0

	var/sharpness
	var/special_description

	var/ranged_flag

/datum/autopsy_record/New(_source,_wound_type,_damage_type,_damage,_name = null,_sharpness,_special_description,_ranged_flag,)

	source = _source
	wound_type = _wound_type
	damage = _damage
	damage_type = _damage_type
	source_name = _name

	if(wound_type == WEAPON_WOUND)
		sharpness = _sharpness
		special_description = _special_description
	if(wound_type == PROJECTILE_WOUND)
		ranged_flag = _ranged_flag

