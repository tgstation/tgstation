#define UPGRADED_MEDICELL_PASSFLAGS PASSTABLE | PASSGLASS | PASSGRILLE
#define MINIMUM_TEMP_DIFFERENCE 25
#define TEMP_PER_SHOT 30

/obj/item/ammo_casing/energy/medical
	projectile_type = /obj/projectile/energy/medical/oxygen
	select_name = "oxygen"
	fire_sound = 'sound/effects/stealthoff.ogg'
	e_cost = 120
	delay = 8
	harmful = FALSE
	select_color = "#00d9ffff"
/obj/projectile/energy/medical
	name = "medical heal shot"
	icon_state = "blue_laser"
	damage = 0
/obj/projectile/energy/medical/oxygen
	name = "oxygen heal shot"
	var/amount_healed = 10

/obj/projectile/energy/medical/oxygen/on_hit(mob/living/target)
	. = ..()
	if(!IsLivingHuman(target))
		return FALSE
	target.adjustOxyLoss(-amount_healed)

//PROCS//
//Applies digust by damage thresholds.
/obj/projectile/energy/medical/proc/DamageDisgust(mob/living/target, type_damage)
	if(type_damage >= 100)
		target.adjust_disgust(3)
	if(type_damage >=  50 && type_damage < 100)
		target.adjust_disgust(1.5)
//Applies clone damage by thresholds
/obj/projectile/energy/medical/proc/DamageClone(mob/living/target, type_damage, amount_healed, max_clone)
	if(type_damage >= 50 && type_damage < 100 )
		target.adjustCloneLoss((amount_healed * (max_clone * 0.5)))
	if(type_damage >= 100)
		target.adjustCloneLoss((amount_healed * max_clone))
//Checks to see if the patient is living.
/obj/projectile/energy/medical/proc/IsLivingHuman(mob/living/target)
	if(!istype(target, /mob/living/carbon/human))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	else
		return TRUE
//Heals Brute without safety
/obj/projectile/energy/medical/proc/healBrute(mob/living/target, amount_healed, max_clone, base_disgust)
	if(!IsLivingHuman(target))
		return FALSE
	DamageDisgust(target, target.getBruteLoss())
	target.adjust_disgust(base_disgust)
	DamageClone(target, target.getBruteLoss(), amount_healed, max_clone)
	target.adjustBruteLoss(-amount_healed)
//Heals Burn damage without safety
/obj/projectile/energy/medical/proc/healBurn(mob/living/target, amount_healed, max_clone, base_disgust)
	if(!IsLivingHuman(target))
		return FALSE
	DamageDisgust(target, target.getFireLoss())
	target.adjust_disgust(base_disgust)
	DamageClone(target, target.getFireLoss(), amount_healed, max_clone)
	target.adjustFireLoss(-amount_healed)

/obj/projectile/energy/medical/proc/safeBrute(mob/living/target, amount_healed, base_disgust)
	if(!IsLivingHuman(target))
		return FALSE
	if(target.getBruteLoss() >= 50 )
		return FALSE
	target.adjust_disgust(base_disgust)
	target.adjustBruteLoss(-amount_healed)

/obj/projectile/energy/medical/proc/safeBurn(mob/living/target, amount_healed, base_disgust)
	if(!IsLivingHuman(target))
		return FALSE
	if(target.getFireLoss() >= 50 )
		return FALSE
	target.adjust_disgust(base_disgust)
	target.adjustFireLoss(-amount_healed)

//Heal Toxin damage
/obj/projectile/energy/medical/proc/healTox(mob/living/target, amount_healed)
	if(!IsLivingHuman(target))
		return FALSE
	target.adjustToxLoss(-amount_healed)
	target.radiation = max(target.radiation - (amount_healed * 8), 0)//Rads are treatable, but inefficent//

//T1 Healing Projectiles//
//The Basic Brute Heal Projectile//
/obj/item/ammo_casing/energy/medical/brute1
	projectile_type = /obj/projectile/energy/medical/brute
	select_name = "brute"
	select_color = "#ff0000ff"

/obj/projectile/energy/medical/brute
	name = "brute heal shot"
	icon_state = "red_laser"
	var/amount_healed = 7.5
	var/max_clone = 2/3
	var/base_disgust = 3

/obj/projectile/energy/medical/brute/on_hit(mob/living/target)
	. = ..()
	healBrute(target, amount_healed, max_clone, base_disgust)
//The Basic Burn Heal//
/obj/item/ammo_casing/energy/medical/burn1
	projectile_type = /obj/projectile/energy/medical/burn
	select_name = "burn"
	select_color = "#ffae00ff"

/obj/projectile/energy/medical/burn
	name = "burn heal shot"
	icon_state = "yellow_laser"
	var/amount_healed = 7.5
	var/max_clone = 2/3
	var/base_disgust = 3


/obj/projectile/energy/medical/burn/on_hit(mob/living/target)
	. = ..()
	healBurn(target, amount_healed, max_clone, base_disgust)

//Basic Toxin Heal//
/obj/item/ammo_casing/energy/medical/toxin1
	projectile_type = /obj/projectile/energy/medical/toxin
	select_name = "toxin"
	select_color = "#15ff00ff"

/obj/projectile/energy/medical/toxin
	name = "toxin heal shot"
	icon_state = "green_laser"
	var/amount_healed = 5

/obj/projectile/energy/medical/toxin/on_hit(mob/living/target)
	. = ..()
	healTox(target, amount_healed)

//SAFE MODES
/obj/item/ammo_casing/energy/medical/brute1/safe
	projectile_type = /obj/projectile/energy/medical/safe/brute

/obj/projectile/energy/medical/safe/brute
	name = "safe brute heal shot"
	icon_state = "red_laser"
	var/amount_healed = 7.5
	var/base_disgust = 3


/obj/projectile/energy/medical/safe/brute/on_hit(mob/living/target)
	. = ..()
	safeBrute(target, amount_healed, base_disgust)

/obj/item/ammo_casing/energy/medical/burn1/safe
	projectile_type = /obj/projectile/energy/medical/safe/burn

/obj/projectile/energy/medical/safe/burn
	name = "safe burn heal shot"
	icon_state = "yellow_laser"
	var/amount_healed = 7.5
	var/base_disgust = 3

/obj/projectile/energy/medical/safe/burn/on_hit(mob/living/target)
	. = ..()
	safeBurn(target, amount_healed, base_disgust)
//T2 Healing Projectiles//
//Tier II Brute Projectile//
/obj/item/ammo_casing/energy/medical/brute2
	projectile_type = /obj/projectile/energy/medical/brute/better
	select_name = "brute II"
	select_color = "#ff0000ff"

/obj/projectile/energy/medical/brute/better
	name = "strong brute heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 11.25
	max_clone = 1/3
	base_disgust = 2

//Tier II Burn Projectile//
/obj/item/ammo_casing/energy/medical/burn2
	projectile_type = /obj/projectile/energy/medical/burn/better
	select_name = "burn II"
	select_color = "#ffae00ff"

/obj/projectile/energy/medical/burn/better
	name = "strong burn heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 11.25
	max_clone = 1/3
	base_disgust = 2

//Tier II Oxy Projectile//
/obj/item/ammo_casing/energy/medical/oxy2
	projectile_type = /obj/projectile/energy/medical/oxygen/better
	select_name = "oxygen II"
	select_color = "#00d9ffff"

/obj/projectile/energy/medical/oxygen/better
	name = "strong oxygen heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 20

//Tier II Toxin Projectile//
/obj/item/ammo_casing/energy/medical/toxin2
	projectile_type = /obj/projectile/energy/medical/toxin/better
	select_name = "toxin II"
	select_color = "#15ff00ff"

/obj/projectile/energy/medical/toxin/better
	name = "strong toxin heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 7.5

//SAFE MODES
/obj/item/ammo_casing/energy/medical/brute2/safe
	projectile_type = /obj/projectile/energy/medical/safe/brute/better

/obj/projectile/energy/medical/safe/brute/better
	name = "safe strong brute heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 11.25
	base_disgust = 2

/obj/item/ammo_casing/energy/medical/burn2/safe
	projectile_type = /obj/projectile/energy/medical/safe/burn/better

/obj/projectile/energy/medical/safe/burn/better
	name = "safe strong burn heal shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS
	amount_healed = 11.25
	base_disgust = 2

//T3 Healing Projectiles//
//Tier III Brute Projectile//
/obj/item/ammo_casing/energy/medical/brute3
	projectile_type = /obj/projectile/energy/medical/brute/better/best
	select_name = "brute III"
	select_color = "#ff0000ff"

/obj/projectile/energy/medical/brute/better/best
	name = "powerful brute heal shot"
	amount_healed = 15
	max_clone = 1/9
	base_disgust = 1

//Tier III Burn Projectile//
/obj/item/ammo_casing/energy/medical/burn3
	projectile_type = /obj/projectile/energy/medical/burn/better/best
	select_name = "burn III"
	select_color = "#ffae00ff"

/obj/projectile/energy/medical/burn/better/best
	name = "powerful burn heal shot"
	amount_healed = 15
	max_clone = 1/9
	base_disgust = 1

//Tier III Oxy Projectile//
/obj/item/ammo_casing/energy/medical/oxy3
	projectile_type = /obj/projectile/energy/medical/oxygen/better/best
	select_name = "oxygen III"
	select_color = "#00d9ffff"

/obj/projectile/energy/medical/oxygen/better/best
	name = "powerful oxygen heal shot"
	amount_healed = 30

//Tier III Toxin Projectile//
/obj/item/ammo_casing/energy/medical/toxin3
	projectile_type = /obj/projectile/energy/medical/toxin/better/best
	select_name = "toxin III"
	select_color = "#15ff00ff"

/obj/projectile/energy/medical/toxin/better/best
	name = "powerful toxin heal shot"
	amount_healed = 10

/obj/projectile/energy/medical/upgraded/toxin3/on_hit(mob/living/target)
	. = ..()
	healTox(target, 10)
//SAFE MODES
/obj/item/ammo_casing/energy/medical/brute3/safe
	projectile_type = /obj/projectile/energy/medical/safe/brute/better/best

/obj/projectile/energy/medical/safe/brute/better/best
	name = "safe powerful brute heal shot"
	amount_healed = 15
	base_disgust = 1
/obj/item/ammo_casing/energy/medical/burn3/safe
	projectile_type = /obj/projectile/energy/medical/safe/burn/better/best
/obj/projectile/energy/medical/safe/burn/better/best
	name = "safe powerful burn heal shot"
	amount_healed = 15
	base_disgust = 1

//End of Basic Tiers of cells.//
//Utility Cells
//Base of utility
/obj/projectile/energy/medical/utility
	name = "utility medical shot"
	pass_flags =  UPGRADED_MEDICELL_PASSFLAGS

//CLotting
/obj/item/ammo_casing/energy/medical/utility/clotting
	projectile_type = /obj/projectile/energy/medical/utility/clotting
	select_name = "clotting"
	select_color = "#ff00eaff"

/obj/projectile/energy/medical/utility/clotting
	name = "clotting agent shot"

/obj/projectile/energy/medical/utility/clotting/on_hit(mob/living/target)
	if(!IsLivingHuman(target))
		return FALSE
	if(target.reagents.get_reagent_amount(/datum/reagent/medicine/coagulant/fabricated) < 5) //injects the target with a weaker coagulant agent
		target.reagents.add_reagent(/datum/reagent/medicine/coagulant/fabricated, 1)
		target.reagents.add_reagent(/datum/reagent/iron, 2) //adds in iron to help compensate for the relatively weak blood clotting
	else
		return

//Temprature Adjustment
/obj/item/ammo_casing/energy/medical/utility/temperature
	projectile_type = /obj/projectile/energy/medical/utility/temperature
	select_name = "temperature"
	select_color = "#fbff00ff"

/obj/projectile/energy/medical/utility/temperature
	name = "temperature adjustment shot"

/obj/projectile/energy/medical/utility/temperature/on_hit(mob/living/target)
	if(!IsLivingHuman(target))
		return FALSE
	var/ideal_temp = target.get_body_temp_normal(apply_change=FALSE) //Gets the temperature we should be aiming for.
	var/current_temp = target.bodytemperature //Retrieves the targets body temperature
	var/difference = ideal_temp - current_temp
	if(abs(difference) <= MINIMUM_TEMP_DIFFERENCE) //It won't adjust temperature if the difference is too low
		return FALSE
	target.adjust_bodytemperature(difference < 0 ? -TEMP_PER_SHOT : TEMP_PER_SHOT)

//Surgical Gown Medicell.
/obj/item/ammo_casing/energy/medical/utility/gown
	projectile_type = /obj/projectile/energy/medical/utility/gown
	select_name = "gown"
	select_color = "#00ffbf"

/obj/projectile/energy/medical/utility/gown
	name = "hardlight surgical gown field"

/obj/projectile/energy/medical/utility/gown/on_hit(mob/living/target)
	if(!istype(target, /mob/living/carbon/human)) //Dead check isn't fully needed, since it'd be reasonable for this to work on corpses.
		return
	var/mob/living/carbon/wearer = target
	var/obj/item/clothing/gown = new /obj/item/clothing/suit/toggle/labcoat/hospitalgown/hardlight
	if(wearer.equip_to_slot_if_possible(gown, ITEM_SLOT_OCLOTHING, 1, 1, 1))
		wearer.visible_message(span_notice("The [gown] covers [wearer] body"), span_notice("The [gown] wraps around your body, covering you"))
		return
	else
		wearer.visible_message(span_notice("The [gown] fails to fit on [wearer], instantly disentagrating away"), span_notice("The [gown] unable to fit on you, disentagrates into nothing"))
		return FALSE


//Objects Used by medicells.
/obj/item/clothing/suit/toggle/labcoat/hospitalgown/hardlight
	name = "Hardlight Hospital Gown"
	desc = "A hospital Gown made out of hardlight, you can barely feel it on your body"
	icon_state = "lgown"

/obj/item/clothing/suit/toggle/labcoat/hospitalgown/hardlight/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/wearer = user
	if((wearer.get_item_by_slot(ITEM_SLOT_OCLOTHING)) == src && !QDELETED(src))
		to_chat(wearer, span_notice("The [src] disappeared after being removed"))
		qdel(src)
		return

//End of utility
#undef UPGRADED_MEDICELL_PASSFLAGS
#undef MINIMUM_TEMP_DIFFERENCE
#undef TEMP_PER_SHOT
