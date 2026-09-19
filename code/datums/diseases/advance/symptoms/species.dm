/* Necrotic Metabolism
 * Increases stealth
 * Reduces resistance
 * Slightly increases stage speed
 * No effect to transmissibility
 * Critical level
 * Bonus: Infected corpses spread disease and undead species are infectable
*/
/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts. Has no effects on its own."
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 0
	level = 3
	severity = 0
	symptom_cure = null
	immunity_proof = TRUE

/datum/symptom/undead_adaptation/OnAdd(datum/disease/advance/A)
	A.process_dead = TRUE
	A.infectable_biotypes |= MOB_UNDEAD

/datum/symptom/undead_adaptation/OnRemove(datum/disease/advance/A)
	A.process_dead = FALSE
	A.infectable_biotypes &= ~MOB_UNDEAD

/* Inorganic Biology
 * Slight stealth reduction
 * Tremendous resistance increase
 * Reduces stage speed
 * Greatly increases transmissibility
 * Critical level
 * Bonus: Enables infection of mineral biotype species
*/
/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate. Has no effects on its own."
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmittable = 3
	level = 3
	severity = 0
	symptom_cure = null
	immunity_proof = TRUE

/datum/symptom/inorganic_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_MINERAL | MOB_ROBOTIC // Plasmamen, golems, and androids.

/datum/symptom/inorganic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes &= ~(MOB_MINERAL | MOB_ROBOTIC)

