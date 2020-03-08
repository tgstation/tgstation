#define EMBEDID "embed-[embed_chance]-[fall_chance]-[pain_chance]-[pain_mult]-[fall_pain_mult]-[impact_pain_mult]-[rip_pain_mult]-[rip_time]-[ignore_throwspeed_threshold]-[jostle_chance]-[jostle_pain_mult]-[pain_stam_pct]"

/proc/getEmbeddingBehavior(embed_chance = EMBED_CHANCE,
                  fall_chance = EMBEDDED_ITEM_FALLOUT,
                  pain_chance = EMBEDDED_PAIN_CHANCE,
                  pain_mult = EMBEDDED_PAIN_MULTIPLIER,
                  fall_pain_mult = EMBEDDED_FALL_PAIN_MULTIPLIER,
                  impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
                  rip_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
                  rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
                  ignore_throwspeed_threshold = FALSE,
				  jostle_chance = EMBEDDED_JOSTLE_CHANCE,
				  jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
				  pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)
  . = locate(EMBEDID)
  if (!.)
    . = new /datum/embedding_behavior(embed_chance, fall_chance, pain_chance, pain_mult, fall_pain_mult, impact_pain_mult, rip_pain_mult, rip_time, ignore_throwspeed_threshold, jostle_chance, jostle_pain_mult, pain_stam_pct)

/datum/embedding_behavior
  var/embed_chance
  var/fall_chance
  var/pain_chance
  var/pain_mult //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
  var/fall_pain_mult //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
  var/impact_pain_mult //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
  var/rip_pain_mult //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
  var/rip_time //A time in ticks, multiplied by the w_class.
  var/ignore_throwspeed_threshold //if we don't give a damn about EMBED_THROWSPEED_THRESHOLD
  var/jostle_chance //Chance to cause pain every time the victim moves (1/2 chance if they're walking or crawling)
  var/jostle_pain_mult //The coefficient of multiplication for the damage when jostle damage is applied (this*w_class)
  var/pain_stam_pct //Percentage of all pain damage dealt as stamina instead of brute (none by default)

/datum/embedding_behavior/New(embed_chance = EMBED_CHANCE,
                  fall_chance = EMBEDDED_ITEM_FALLOUT,
                  pain_chance = EMBEDDED_PAIN_CHANCE,
                  pain_mult = EMBEDDED_PAIN_MULTIPLIER,
                  fall_pain_mult = EMBEDDED_FALL_PAIN_MULTIPLIER,
                  impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
                  rip_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
                  rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
                  ignore_throwspeed_threshold = FALSE,
				  jostle_chance = EMBEDDED_JOSTLE_CHANCE,
				  jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
				  pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)
  src.embed_chance = embed_chance
  src.fall_chance = fall_chance
  src.pain_chance = pain_chance
  src.pain_mult = pain_mult
  src.fall_pain_mult = fall_pain_mult
  src.impact_pain_mult = impact_pain_mult
  src.rip_pain_mult = rip_pain_mult
  src.rip_time = rip_time
  src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
  src.jostle_chance = jostle_chance
  src.jostle_pain_mult = jostle_pain_mult
  src.pain_stam_pct = pain_stam_pct
  tag = EMBEDID

/datum/embedding_behavior/proc/setRating(embed_chance, fall_chance, pain_chance, pain_mult, fall_pain_mult, impact_pain_mult, rip_pain_mult, rip_time, ignore_throwspeed_threshold)
  return getEmbeddingBehavior((isnull(embed_chance) ? src.embed_chance : embed_chance),\
                  (isnull(fall_chance) ? src.fall_chance : fall_chance),\
                  (isnull(pain_chance) ? src.pain_chance : pain_chance),\
                  (isnull(pain_mult) ? src.pain_mult : pain_mult),\
                  (isnull(fall_pain_mult) ? src.fall_pain_mult : fall_pain_mult),\
                  (isnull(impact_pain_mult) ? src.impact_pain_mult : impact_pain_mult),\
                  (isnull(rip_pain_mult) ? src.rip_pain_mult : rip_pain_mult),\
                  (isnull(rip_time) ? src.rip_time : rip_time),\
                  (isnull(ignore_throwspeed_threshold) ? src.ignore_throwspeed_threshold : ignore_throwspeed_threshold),\
                  (isnull(jostle_chance) ? src.jostle_chance : jostle_chance),\
                  (isnull(jostle_pain_mult) ? src.jostle_pain_mult : jostle_pain_mult),\
                  (isnull(pain_stam_pct) ? src.pain_stam_pct : pain_stam_pct))

#undef EMBEDID
