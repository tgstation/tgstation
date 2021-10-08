
// Skill levels
#define SKILL_LEVEL_NONE 1
#define SKILL_LEVEL_NOVICE 2
#define SKILL_LEVEL_APPRENTICE 3
#define SKILL_LEVEL_JOURNEYMAN 4
#define SKILL_LEVEL_EXPERT 5
#define SKILL_LEVEL_MASTER 6
#define SKILL_LEVEL_LEGENDARY 7

#define SKILL_LVL 1
#define SKILL_EXP 2

// Level experience requirements
#define SKILL_EXP_NONE 0
#define SKILL_EXP_NOVICE 100
#define SKILL_EXP_APPRENTICE 250
#define SKILL_EXP_JOURNEYMAN 500
#define SKILL_EXP_EXPERT 900
#define SKILL_EXP_MASTER 1500
#define SKILL_EXP_LEGENDARY 2500

//Allows us to get EXP from level, or level from EXP
#define SKILL_EXP_LIST list(SKILL_EXP_NONE, SKILL_EXP_NOVICE, SKILL_EXP_APPRENTICE, SKILL_EXP_JOURNEYMAN, SKILL_EXP_EXPERT, SKILL_EXP_MASTER, SKILL_EXP_LEGENDARY)

//Skill modifier types
#define SKILL_SPEED_MODIFIER "skill_speed_modifier"//ideally added/subtracted in speed calculations to make you do stuff faster
#define SKILL_PROBS_MODIFIER "skill_probability_modifier"//ideally added/subtracted where beneficial in prob(x) calls
#define SKILL_RANDS_MODIFIER "skill_randomness_modifier"//ideally added/subtracted where beneficial in rand(x,y) calls

// Gets the reference for the skill type that was given
#define GetSkillRef(A) (SSskills.all_skills[A])

//number defines
#define CLEAN_SKILL_BEAUTY_ADJUSTMENT -15//It's a denominator so no 0. Higher number = less cleaning xp per cleanable. Negative value means cleanables with negative beauty give xp.
#define CLEAN_SKILL_GENERIC_WASH_XP 1.5//Value. Higher number = more XP when cleaning non-cleanables (walls/floors/lips)
