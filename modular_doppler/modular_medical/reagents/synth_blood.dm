// Reagent(s) to be used by synthetics and or androids when they are implemented as a selectable species.
//I'm putting the recipes and precursor chems here for ease of use.
/datum/reagent/synth_blood
    name = "Synthetic Thermal Solution"
    description = "A non-reactive liquid commonly utilized by humanoid synthetics to insulate their internal systems and conduct heat away from internal components."
    taste_description = "thick water"
    taste_mult = 1
    color = "#A9FBFB"

/datum/glass_style/drinking_glass/synth_blood
    required_drink_type = /datum/reagent/synth_blood
    name = "glass of water"
    desc = "Doesn't really move around like water - oddly thick."

/datum/chemical_reaction/synth_blood
  results = list(/datum/reagent/synth_blood = 1)
  required_reagents = list(/datum/reagent/toxin/acid/hyflo_acid = 1, /datum/reagent/fuel/oil = 1, /datum/reagent/stable_plasma = 1)
  mix_message = "The solution becomes clear and stabilizes."
  mix_sound = 'sound/effects/bubbles/bubbles.ogg'
  //fermichem
  is_cold_recipe = FALSE
  required_temp = 216
  optimal_temp = 438
  overheat_temp = 540
  optimal_ph_min = 6
  optimal_ph_max = 8
  determin_ph_range = 2
  temp_exponent_factor = 1
  ph_exponent_factor = 1
  thermic_constant = 1.2
  H_ion_release = 0.1
  rate_up_lim = 35
  purity_min = 0
  reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_UNIQUE


/datum/reagent/toxin/acid/hyflo_acid
    name = "Hydrofluoric Acid"
    description = "A highly corrosive solution of hydrogen and fluorine."
    taste_description = "acid"
    taste_mult = 10
    ph = 1.0
    creation_purity = REAGENT_STANDARD_PURITY
    purity = REAGENT_STANDARD_PURITY
    mass = 10
    color = "#AAAAAA77"
    toxpwr = 1
    acidpwr = 10.0
    chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/acid/hyflo_acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
    . = ..()
    if(affected_mob.adjustFireLoss((volume/10) * REM * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype))
        return UPDATE_MOB_HEALTH

/datum/chemical_reaction/hyflo_acid
    results = list(/datum/reagent/toxin/acid/hyflo_acid = 2)
    required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1)
    required_catalysts = list(/datum/reagent/water = 5)
    mix_message = "The mixture bubbles briefly."
   //fermichem
    is_cold_recipe = FALSE
    required_temp = 190
    optimal_temp = 280
    overheat_temp = 292
    optimal_ph_min = 0
    optimal_ph_max = 2
    determin_ph_range = 5
    temp_exponent_factor = 1
    ph_exponent_factor = 10
    thermic_constant = -200
    H_ion_release = -20
    rate_up_lim = 25
    purity_min = 0
    reaction_flags = REACTION_PH_VOL_CONSTANT
    reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_CHEMICAL

