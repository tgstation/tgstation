#define OPFOR_BACKSTORY_MIN_CHARS 100
#define OPFOR_BACKSTORY_MAX_CHARS 500

#define OPFOR_MAX_OBJECTIVES 5

#define OPFOR_STATUS_NOT_SUBMITTED "Not submitted"
#define OPFOR_STATUS_APPROVED "Approved"
#define OPFOR_STATUS_DENIED "Denied"
#define OPFOR_STATUS_AWAITING_APPROVAL "Awaiting approval"
#define OPFOR_STATUS_CHANGES_REQUESTED "Changes requested"

#define OPFOR_OBJECTIVE_STATUS_NOT_REVIEWED "Not Reviewed"
#define OPFOR_OBJECTIVE_STATUS_APPROVED "Approved"
#define OPFOR_OBJECTIVE_STATUS_DENIED "Denied"

#define OPFOR_OBJECTIVE_INTENSITY_1 "1 - Minor theft or basic antagonizing"
#define OPFOR_OBJECTIVE_INTENSITY_2 "2 - Kidnapping / Theft"
#define OPFOR_OBJECTIVE_INTENSITY_3 "3 - Assassination / Grand Theft"
#define OPFOR_OBJECTIVE_INTENSITY_4 "4 - Mass sabotage (engine delamination)"
#define OPFOR_OBJECTIVE_INTENSITY_5 "5 - Mass destruction or mass killings"

#define OPFOR_SUBSYSTEM_REJECT_CAP "OPFOR application system has reached the maximum number of applications"
#define OPFOR_SUBSYSTEM_REJECT_CLOSED "OPFOR application system is not accepting new applications"
#define OPFOR_SUBSYSTEM_READY "OPFOR application system is ready to accept new applications"

#define OPFOR_REQUEST_UPDATE_COOLDOWN (5 MINUTES)
#define OPFOR_PING_COOLDOWN (1 MINUTES)

#define OPFOR_TEXT_LIMIT_TITLE 40
#define OPFOR_TEXT_LIMIT_BACKSTORY 2000
#define OPFOR_TEXT_LIMIT_DESCRIPTION 1000
#define OPFOR_TEXT_LIMIT_JUSTIFICATION 1000
#define OPFOR_TEXT_LIMIT_MESSAGE 300

#define OPFOR_EQUIPMENT_LIMIT 10
#define OPFOR_EQUIPMENT_COUNT_LIMIT 5

#define OPFOR_EQUIPMENT_STATUS_NOT_REVIEWED "Not Reviewed"
#define OPFOR_EQUIPMENT_STATUS_APPROVED "Approved"
#define OPFOR_EQUIPMENT_STATUS_DENIED "Denied"

/// EQUIPMENT CATEGORIES
// Uplink Items
#define OPFOR_EQUIPMENT_CATEGORY_CLOTHING_UPLINK "1. Uplink Services"
// Clothing
#define OPFOR_EQUIPMENT_CATEGORY_CLOTHING_SYNDICATE "2. Syndicate Outfits"
#define OPFOR_EQUIPMENT_CATEGORY_CLOTHING_SOL "3. Sol-Federation Outfits"
#define OPFOR_EQUIPMENT_CATEGORY_CLOTHING_PIRATE "4. Piracy Outfits"
#define OPFOR_EQUIPMENT_CATEGORY_CLOTHING_MAGIC "5. Spellcaster Outfits"
// MODsuits
#define OPFOR_EQUIPMENT_CATEGORY_MODSUIT "6. MOD Suits"
#define OPFOR_EQUIPMENT_CATEGORY_MODSUIT_MODULES "7. MOD Modules"
// Implants
#define OPFOR_EQUIPMENT_CATEGORY_IMPLANTS "8. Implants"
#define OPFOR_EQUIPMENT_CATEGORY_IMPLANTS_ILLEGAL "9. Illegal Implants"
// Guns
#define OPFOR_EQUIPMENT_CATEGORY_RANGED "10. Ranged Weapons"
#define OPFOR_EQUIPMENT_CATEGORY_RANGED_STEALTH "11. Stealthy Ranged Weapons"
// Ammo
#define OPFOR_EQUIPMENT_CATEGORY_AMMO_EXOTIC "12. Exotic Ammunition"
// Melee
#define OPFOR_EQUIPMENT_CATEGORY_MELEE "13. Melee Weapons"
#define OPFOR_EQUIPMENT_CATEGORY_MELEE_STEALTH "14. Stealthy Melee Weapons"
// Medical items
#define OPFOR_EQUIPMENT_CATEGORY_MEDICAL "15. Medical Items"
// Gadgets
#define OPFOR_EQUIPMENT_CATEGORY_GADGET "16. Gadgets"
#define OPFOR_EQUIPMENT_CATEGORY_GADGET_STEALTH "17. Stealthy Gadgets"
// Bombs
#define OPFOR_EQUIPMENT_CATEGORY_BOMB_CHEM "18. Chemical Grenades"
#define OPFOR_EQUIPMENT_CATEGORY_BOMB_PAYLOAD "19. Dirty Bombs"
// Spells and scrolls (martial arts)
#define OPFOR_EQUIPMENT_CATEGORY_SPELLS "20. Spells"
#define OPFOR_EQUIPMENT_CATEGORY_SCROLLS "21. Martial Art Scrolls"
// Language and biology
#define OPFOR_EQUIPMENT_CATEGORY_LANGUAGE "22. Language"
#define OPFOR_EQUIPMENT_CATEGORY_ORGANS "23. Organs"
// Category for uncategorized items
#define OPFOR_EQUIPMENT_CATEGORY_OTHER "Other"

#define ROLE_OPFOR_CANDIDATE "OPFOR Candidate"
#define BAN_OPFOR "OPFOR ban"
#define ADMIN_PASS_OPFOR(src) "(<a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];pass_opfor_candidate=1'>PASS</a>)"
