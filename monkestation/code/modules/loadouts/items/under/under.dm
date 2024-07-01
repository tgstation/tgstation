
// --- Loadout item datums for under suits ---

/// Underslot - Jumpsuit Items (Deletes overrided items)
GLOBAL_LIST_INIT(loadout_jumpsuits, generate_loadout_items(/datum/loadout_item/under/jumpsuit))

/// Underslot - Formal Suit Items (Deletes overrided items)
GLOBAL_LIST_INIT(loadout_undersuits, generate_loadout_items(/datum/loadout_item/under/formal))

/// Underslot - Misc. Under Items (Deletes overrided items)
GLOBAL_LIST_INIT(loadout_miscunders, generate_loadout_items(/datum/loadout_item/under/miscellaneous))

/datum/loadout_item/under
	category = LOADOUT_ITEM_UNIFORM

/datum/loadout_item/under/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.uniform))
		.. ()
		return TRUE

/datum/loadout_item/under/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.uniform)
			LAZYADD(outfit.backpack_contents, outfit.uniform)
		outfit.uniform = item_path
	else
		outfit.uniform = item_path
	outfit.modified_outfit_slots |= ITEM_SLOT_ICLOTHING

/*
*	JUMPSUITS
*/

/datum/loadout_item/under/jumpsuit

/datum/loadout_item/under/jumpsuit/greyscale
	name = "Greyscale Jumpsuit"
	item_path = /obj/item/clothing/under/color

/datum/loadout_item/under/jumpsuit/greyscale_skirt
	name = "Greyscale Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt

/datum/loadout_item/under/jumpsuit/random
	name = "Random Jumpsuit"
	item_path = /obj/item/clothing/under/color/random
	additional_tooltip_contents = list(TOOLTIP_RANDOM_COLOR)

/datum/loadout_item/under/jumpsuit/random_skirt
	name = "Random Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/random
	additional_tooltip_contents = list(TOOLTIP_RANDOM_COLOR)

/datum/loadout_item/under/jumpsuit/rainbow
	name = "Rainbow Jumpsuit"
	item_path = /obj/item/clothing/under/color/rainbow

/datum/loadout_item/under/jumpsuit/rainbow_skirt
	name = "Rainbow Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/rainbow

/datum/loadout_item/under/jumpsuit/disco
	name = "Superstar Cop Uniform"
	item_path = /obj/item/clothing/under/rank/security/detective/disco
	restricted_roles = list(JOB_DETECTIVE)

/datum/loadout_item/under/jumpsuit/kim
	name = "Aerostatic Suit"
	item_path = /obj/item/clothing/under/rank/security/detective/kim
	restricted_roles = list(JOB_DETECTIVE)


/*
*	MISC UNDERSUITS
*/

/datum/loadout_item/under/miscellaneous

/datum/loadout_item/under/miscellaneous/buttondown
	name = "Recolorable Buttondown Shirt with Slacks"
	item_path = /obj/item/clothing/under/costume/buttondown/slacks

/datum/loadout_item/under/miscellaneous/buttondown_shorts
	name = "Recolorable Buttondown Shirt with Shorts"
	item_path = /obj/item/clothing/under/costume/buttondown/shorts

/datum/loadout_item/under/miscellaneous/slacks
	name = "Recolorable Slacks"
	item_path = /obj/item/clothing/under/pants/slacks

/datum/loadout_item/under/miscellaneous/jeans
	name = "Recolorable Jeans"
	item_path = /obj/item/clothing/under/pants/jeans


/datum/loadout_item/under/miscellaneous/track
	name = "Track Pants"
	item_path = /obj/item/clothing/under/pants/track

/datum/loadout_item/under/miscellaneous/camo
	name = "Camo Pants"
	item_path = /obj/item/clothing/under/pants/camo

/datum/loadout_item/under/miscellaneous/jeanshorts //This doesnt look like a word. Short. Jean-Short. Eugh.
	name = "Recolorable Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/jeanshorts

/datum/loadout_item/under/miscellaneous/shorts
	name = "Recolorable Shorts"
	item_path = /obj/item/clothing/under/shorts

/datum/loadout_item/under/miscellaneous/red_short
	name = "Red Shorts"
	item_path = /obj/item/clothing/under/shorts/red

/datum/loadout_item/under/miscellaneous/green_short
	name = "Green Shorts"
	item_path = /obj/item/clothing/under/shorts/green

/datum/loadout_item/under/miscellaneous/blue_short
	name = "Blue Shorts"
	item_path = /obj/item/clothing/under/shorts/blue

/datum/loadout_item/under/miscellaneous/black_short
	name = "Black Shorts"
	item_path = /obj/item/clothing/under/shorts/black

/datum/loadout_item/under/miscellaneous/grey_short
	name = "Grey Shorts"
	item_path = /obj/item/clothing/under/shorts/grey

/datum/loadout_item/under/miscellaneous/purple_short
	name = "Purple Shorts"
	item_path = /obj/item/clothing/under/shorts/purple

//TODO: split loadout's miscellaneous to have "Pants/Shorts" and "Dresses/Skirts" as options too. Misc is stupid.

/datum/loadout_item/under/miscellaneous/dress_striped
	name = "Striped Dress"
	item_path = /obj/item/clothing/under/dress/striped

/datum/loadout_item/under/miscellaneous/skirt_black
	name = "Black Skirt"
	item_path = /obj/item/clothing/under/dress/skirt

/datum/loadout_item/under/miscellaneous/skirt_plaid
	name = "Recolorable Plaid Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/plaid

/datum/loadout_item/under/miscellaneous/skirt_turtleneck
	name = "Recolorable Turtleneck Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/turtleskirt

/datum/loadout_item/under/miscellaneous/dress_tango
	name = "Recolorable Tango Dress"
	item_path = /obj/item/clothing/under/dress/tango

/datum/loadout_item/under/miscellaneous/dress_sun
	name = "Recolorable Sundress"
	item_path = /obj/item/clothing/under/dress/sundress

/datum/loadout_item/under/miscellaneous/kilt
	name = "Kilt"
	item_path = /obj/item/clothing/under/costume/kilt

/datum/loadout_item/under/miscellaneous/treasure_hunter
	name = "Treasure Hunter"
	item_path = /obj/item/clothing/under/rank/civilian/curator/treasure_hunter

/datum/loadout_item/under/miscellaneous/overalls
	name = "Overalls"
	item_path = /obj/item/clothing/under/misc/overalls

/datum/loadout_item/under/miscellaneous/pj_blue
	name = "Mailman Jumpsuit"
	item_path = /obj/item/clothing/under/misc/mailman

/datum/loadout_item/under/miscellaneous/vice_officer
	name = "Vice Officer Jumpsuit"
	item_path = /obj/item/clothing/under/misc/vice_officer

/datum/loadout_item/under/miscellaneous/soviet
	name = "Soviet Uniform"
	item_path = /obj/item/clothing/under/costume/soviet

/datum/loadout_item/under/miscellaneous/redcoat
	name = "Redcoat"
	item_path = /obj/item/clothing/under/costume/redcoat

/datum/loadout_item/under/miscellaneous/pj_red
	name = "Red PJs"
	item_path = /obj/item/clothing/under/misc/pj/red

/datum/loadout_item/under/miscellaneous/pj_blue
	name = "Blue PJs"
	item_path = /obj/item/clothing/under/misc/pj/blue


/datum/loadout_item/under/miscellaneous/maidcostume
	name = "Maid Costume"
	item_path = /obj/item/clothing/under/costume/maid


/datum/loadout_item/under/miscellaneous/kimono
	name = "Fancy Kimono"
	item_path =  /obj/item/clothing/under/costume/skyrat/kimono


/datum/loadout_item/under/miscellaneous/dutch
	name = "Dutch Suit"
	item_path = /obj/item/clothing/under/costume/dutch


/datum/loadout_item/under/miscellaneous/tacticool_turtleneck
	name = "Tacticool Turtleneck"
	item_path = /obj/item/clothing/under/syndicate/tacticool //This has been rebalanced in modular_skyrat\master_files\code\modules\clothing\under\syndicate.dm

/datum/loadout_item/under/miscellaneous/tactical_skirt
	name = "Tacticool Skirtleneck"
	item_path = /obj/item/clothing/under/syndicate/tacticool/skirt //This has been rebalanced in modular_skyrat\master_files\code\modules\clothing\under\syndicate.dm


/datum/loadout_item/under/miscellaneous/gladiator
	name = "Gladiator Uniform"
	item_path = /obj/item/clothing/under/costume/gladiator

/datum/loadout_item/under/miscellaneous/griffon
	name = "Griffon Uniform"
	item_path = /obj/item/clothing/under/costume/griffin

/datum/loadout_item/under/miscellaneous/owl
	name = "Owl Uniform"
	item_path = /obj/item/clothing/under/costume/owl

/datum/loadout_item/under/miscellaneous/villain
	name = "Villain Suit"
	item_path = /obj/item/clothing/under/costume/villain


/datum/loadout_item/under/miscellaneous/bluescrubs
	name = "Blue Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/blue
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_GENETICIST, JOB_CHEMIST, JOB_VIROLOGIST, JOB_PARAMEDIC)

/datum/loadout_item/under/miscellaneous/greenscrubs
	name = "Green Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/green
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_GENETICIST, JOB_CHEMIST, JOB_VIROLOGIST, JOB_PARAMEDIC)

/datum/loadout_item/under/miscellaneous/purplescrubs
	name = "Purple Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/purple
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_GENETICIST, JOB_CHEMIST, JOB_VIROLOGIST, JOB_PARAMEDIC)

/datum/loadout_item/under/miscellaneous/ethereal_tunic
	name = "Ethereal Tunic"
	item_path = /obj/item/clothing/under/ethereal_tunic

/datum/loadout_item/under/miscellaneous/tragic
	name = "Tragic Mime Suit"
	item_path = /obj/item/clothing/under/costume/tragic

/datum/loadout_item/under/miscellaneous/bunnysuit
	name = "Colorable Bunny Suit"
	item_path = /obj/item/clothing/under/costume/playbunny

/*
*	FORMAL UNDERSUITS
*/

/datum/loadout_item/under/formal

/datum/loadout_item/under/formal/amish_suit
	name = "Amish Suit"
	item_path = /obj/item/clothing/under/suit/sl

/datum/loadout_item/under/formal/assistant
	name = "Assistant Formal"
	item_path = /obj/item/clothing/under/misc/assistantformal

/datum/loadout_item/under/formal/beige_suit
	name = "Beige Suit"
	item_path = /obj/item/clothing/under/suit/beige

/datum/loadout_item/under/formal/black_suit
	name = "Black Suit"
	item_path = /obj/item/clothing/under/suit/black

/datum/loadout_item/under/formal/black_suitskirt
	name = "Black Suitskirt"
	item_path = /obj/item/clothing/under/suit/black/skirt

/datum/loadout_item/under/formal/black_twopiece
	name = "Black Two-Piece Suit"
	item_path = /obj/item/clothing/under/suit/blacktwopiece

/datum/loadout_item/under/formal/black_lawyer_suit
	name = "Black Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black

/datum/loadout_item/under/formal/black_lawyer_skirt
	name = "Black Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black/skirt

/datum/loadout_item/under/formal/blue_suit
	name = "Blue Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit

/datum/loadout_item/under/formal/blue_suitskirt
	name = "Blue Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt

/datum/loadout_item/under/formal/blue_lawyer_suit
	name = "Blue Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue

/datum/loadout_item/under/formal/blue_lawyer_skirt
	name = "Blue Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue/skirt

/datum/loadout_item/under/formal/burgundy_suit
	name = "Burgundy Suit"
	item_path = /obj/item/clothing/under/suit/burgundy

/datum/loadout_item/under/formal/charcoal_suit
	name = "Charcoal Suit"
	item_path = /obj/item/clothing/under/suit/charcoal

/datum/loadout_item/under/formal/checkered_suit
	name = "Checkered Suit"
	item_path = /obj/item/clothing/under/suit/checkered

/datum/loadout_item/under/formal/executive_suit
	name = "Executive Suit"
	item_path = /obj/item/clothing/under/suit/black_really

/datum/loadout_item/under/formal/executive_skirt
	name = "Executive Suitskirt"
	item_path = /obj/item/clothing/under/suit/black_really/skirt

/datum/loadout_item/under/formal/navy_suit
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy

/datum/loadout_item/under/formal/maid_outfit
	name = "Maid Outfit"
	item_path = /obj/item/clothing/under/costume/maid

/datum/loadout_item/under/formal/maid_uniform
	name = "Maid Uniform"
	item_path = /obj/item/clothing/under/rank/civilian/janitor/maid

/datum/loadout_item/under/formal/purple_suit
	name = "Purple Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit

/datum/loadout_item/under/formal/purple_suitskirt
	name = "Purple Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt

/datum/loadout_item/under/formal/red_suit
	name = "Red Suit"
	item_path = /obj/item/clothing/under/suit/red


/datum/loadout_item/under/formal/red_lawyer_skirt
	name = "Red Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red

/datum/loadout_item/under/formal/red_lawyer_skirt
	name = "Red Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt

/datum/loadout_item/under/formal/red_gown
	name = "Red Evening Gown"
	item_path = /obj/item/clothing/under/dress/redeveninggown

/datum/loadout_item/under/formal/sailor
	name = "Sailor Suit"
	item_path = /obj/item/clothing/under/costume/sailor

/datum/loadout_item/under/formal/sailor_skirt
	name = "Sailor Dress"
	item_path = /obj/item/clothing/under/dress/sailor

/datum/loadout_item/under/formal/scratch_suit
	name = "Scratch Suit"
	item_path = /obj/item/clothing/under/suit/white_on_white

/datum/loadout_item/under/formal/sensible_suit
	name = "Sensible Suit"
	item_path = /obj/item/clothing/under/rank/civilian/curator

/datum/loadout_item/under/formal/sensible_skirt
	name = "Sensible Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/curator/skirt

/datum/loadout_item/under/formal/tuxedo
	name = "Tuxedo Suit"
	item_path = /obj/item/clothing/under/suit/tuxedo

/datum/loadout_item/under/formal/waiter
	name = "Waiter's Suit"
	item_path = /obj/item/clothing/under/suit/waiter

/datum/loadout_item/under/formal/white_suit
	name = "White Suit"
	item_path = /obj/item/clothing/under/suit/white


/datum/loadout_item/under/formal/trek_command
	name = "Trekkie Command Uniform"
	item_path = /obj/item/clothing/under/trek/command

/datum/loadout_item/under/formal/trek_engsec
	name = "Trekkie Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec

/datum/loadout_item/under/formal/trek_medsci
	name = "Trekkie Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci

/datum/loadout_item/under/formal/trek_next_command
	name = "Trekkie TNG Command Uniform"
	item_path = /obj/item/clothing/under/trek/command/next

/datum/loadout_item/under/formal/trek_next_engsec
	name = "Trekkie TNG Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec/next

/datum/loadout_item/under/formal/trek_next_medsci
	name = "Trekkie TNG Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci/next

/datum/loadout_item/under/formal/trek_ent_command
	name = "Trekkie ENT Command Uniform"
	item_path = /obj/item/clothing/under/trek/command/ent

/datum/loadout_item/under/formal/trek_ent_engsec
	name = "Trekkie ENT Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec/ent

/datum/loadout_item/under/formal/trek_ent_medsci
	name = "Trekkie ENT Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci/ent

/datum/loadout_item/under/formal/the_q
	name = "French Marshall's Uniform"
	item_path = /obj/item/clothing/under/trek/q

//FAMILIES GEAR
/datum/loadout_item/under/formal/osi
	name = "OSI Uniform"
	item_path = /obj/item/clothing/under/costume/osi

/datum/loadout_item/under/formal/tmc
	name = "TMC Uniform"
	item_path = /obj/item/clothing/under/costume/tmc

/datum/loadout_item/under/formal/driscoll
	name = "O'Driscoll outfit"
	item_path = /obj/item/clothing/under/driscoll

/datum/loadout_item/under/formal/morningstar
	name = "Morningstar suit"
	item_path = /obj/item/clothing/under/morningstar

/datum/loadout_item/under/formal/saints
	name = "Saints outfit"
	item_path = /obj/item/clothing/under/saints

/datum/loadout_item/under/formal/phantom
	name = "Phantom Thief outfit"
	item_path = /obj/item/clothing/under/phantom

/datum/loadout_item/under/miscellaneous/bloodred
	name = "Blood-red pajamas"
	item_path = /obj/item/clothing/under/bloodred

/// DONATOR
/datum/loadout_item/under/donator
	donator_only = TRUE
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/shrine
	name = "Shrine Priestess Kimono"
	item_path = /obj/item/clothing/under/dress/shrine_priestess

/// EVERYTHING NOVA RELATED
//NOTES
//Jumpskirt prefs overrides jumpsuits (ex.qm's formal jumpsuit becomes a skirt)
//From now on I'm marking every new purchasable item as BUYABLE for my own sanity
//Here be dragons (literally)

/datum/loadout_item/under/jumpsuit/frontier
	name = "Frontier Jumpsuit"
	item_path = /obj/item/clothing/under/frontier_colonist
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impcap
	name = "Captain's Naval Jumpsuit"
	item_path = /obj/item/clothing/under/rank/captain/nova/imperial
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/imphop
	name = "Head of Personnel's Naval Jumpsuit"
	item_path = /obj/item/clothing/under/rank/civilian/head_of_personnel/nova/imperial
	restricted_roles = list(JOB_HEAD_OF_PERSONNEL)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/imphos
	name = "Head of Security's Naval Uniform"
	item_path = /obj/item/clothing/under/rank/security/head_of_security/nova/imperial
	restricted_roles = list(JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impcmo
	name = "Chief Medical Officer's Naval Uniform"
	item_path = /obj/item/clothing/under/rank/medical/chief_medical_officer/nova/imperial
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impce
	name = "Chief Engineer's Naval Uniform"
	item_path = /obj/item/clothing/under/rank/engineering/chief_engineer/nova/imperial
	restricted_roles = list(JOB_CHIEF_ENGINEER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/imprd
	name = "Research Director's Naval Uniform"
	item_path = /obj/item/clothing/under/rank/rnd/research_director/nova/imperial
	restricted_roles = list(JOB_RESEARCH_DIRECTOR)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impcommand
	name = "Light Grey Officer's Naval Jumpsuit"
	item_path = /obj/item/clothing/under/rank/captain/nova/imperial/generic
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impcom
	name = "Grey Officer's Naval Jumpsuit"
	item_path = /obj/item/clothing/under/rank/captain/nova/imperial/generic/grey
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impred
	name = "Red Officer's Naval Jumpsuit"
	item_path = /obj/item/clothing/under/rank/captain/nova/imperial/generic/red
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/impcomtrous
	name = "Grey Officer's Naval Jumpsuit (Trousers)"
	item_path = /obj/item/clothing/under/rank/captain/nova/imperial/generic/pants
	restricted_roles = list(JOB_CAPTAIN)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_dress
	name = "Security Battle Dress"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/dress
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_trousers
	name = "Security Trousers"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/trousers
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_shorts
	name = "Security Shorts"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/trousers/shorts
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_jumpskirt
	name = "Security Jumpskirt"
	item_path = /obj/item/clothing/under/rank/security/officer/skirt
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_plain_skirt
	name = "Security Plain Skirt"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/plain_skirt
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_miniskirt
	name = "Security Miniskirt"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/miniskirt
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_jumpsuit
	name = "Security Jumpsuit"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper/jumpsuit
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/security_peacekeeper
	name = "Security Peacekeeper Uniform"
	item_path = /obj/item/clothing/under/rank/security/peacekeeper
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_WARDEN, JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/imperial_police_uniform //BUYABLE
	name = "Imperial Police Uniform"
	item_path = /obj/item/clothing/under/colonial/nri_police

/datum/loadout_item/under/jumpsuit/sol_peacekeeper //BUYABLE
	name = "Sol Peacekeeper Uniform"
	item_path = /obj/item/clothing/under/sol_peacekeeper

/datum/loadout_item/under/jumpsuit/sol_emt
	name = "Sol Emergency Medical Uniform"
	item_path = /obj/item/clothing/under/sol_emt
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC, JOB_CHEMIST, JOB_VIROLOGIST, JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/paramed_light
	name = "Light Paramedic Uniform"
	item_path = /obj/item/clothing/under/rank/medical/paramedic/nova/light
	restricted_roles = list(JOB_PARAMEDIC)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/paramed_light_skirt
	name = "Light Paramedic Skirt"
	item_path = /obj/item/clothing/under/rank/medical/paramedic/nova/light/skirt
	restricted_roles = list(JOB_PARAMEDIC)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/chemist_formal
	name = "Chemist's Formal Jumpsuit"
	item_path = /obj/item/clothing/under/rank/medical/chemist/nova/formal
	restricted_roles = list(JOB_CHEMIST)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/chemist_formal_skirt
	name = "Chemist's Formal Jumpskirt"
	item_path = /obj/item/clothing/under/rank/medical/chemist/nova/formal/skirt
	restricted_roles = list(JOB_CHEMIST)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/hlscientist
	name = "Ridiculous Scientist Outfit"
	item_path = /obj/item/clothing/under/rank/rnd/scientist/nova/hlscience
	restricted_roles = list(JOB_SCIENTIST)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility	//BUYABLE
	name = "Utility Uniform"
	item_path = /obj/item/clothing/under/misc/nova/utility

/datum/loadout_item/under/jumpsuit/utility_eng
	name = "Engineering Utility Uniform"
	item_path = /obj/item/clothing/under/rank/engineering/engineer/nova/utility
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility_med
	name = "Medical Utility Uniform"
	item_path = /obj/item/clothing/under/rank/medical/doctor/nova/utility
	restricted_roles = list(JOB_PARAMEDIC, JOB_MEDICAL_DOCTOR, JOB_CHEMIST, JOB_VIROLOGIST, JOB_GENETICIST ,JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility_sci
	name = "Science Utility Uniform"
	item_path = /obj/item/clothing/under/rank/rnd/scientist/nova/utility
	restricted_roles = list(JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST, JOB_RESEARCH_DIRECTOR)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility_cargo
	name = "Supply Utility Uniform"
	item_path = /obj/item/clothing/under/rank/cargo/tech/nova/utility
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility_sec
	name = "Security Utility Uniform"
	item_path = /obj/item/clothing/under/rank/security/nova/utility
	restricted_roles = list(JOB_SECURITY_OFFICER, JOB_DETECTIVE, JOB_WARDEN, JOB_BRIG_PHYSICIAN, JOB_SECURITY_ASSISTANT, JOB_HEAD_OF_SECURITY) //i dunno about the blueshield, they're a weird combo of sec and command, thats why they arent in the loadout pr im making
	requires_purchase = FALSE

/datum/loadout_item/under/jumpsuit/utility_com
	name = "Command Utility Uniform"
	item_path = /obj/item/clothing/under/rank/captain/nova/utility
	restricted_roles = list(JOB_CAPTAIN, JOB_HEAD_OF_PERSONNEL, JOB_HEAD_OF_SECURITY, JOB_RESEARCH_DIRECTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CHIEF_ENGINEER)
	requires_purchase = FALSE

/*
 *	MISC UNDERSUITS
 */

/datum/loadout_item/under/miscellaneous


/datum/loadout_item/under/miscellaneous/vicvest //BUYABLE
	name = "Recolorable Buttondown Shirt with Double-Breasted Vest"
	item_path = /obj/item/clothing/under/pants/nova/vicvest

/datum/loadout_item/under/miscellaneous/slacks //BUYABLE
	name = "Recolorable Slacks"
	item_path = /obj/item/clothing/under/pants/slacks //BUYABLE

/datum/loadout_item/under/miscellaneous/jeans //BUYABLE
	name = "Recolorable Jeans"
	item_path = /obj/item/clothing/under/pants/jeans

/datum/loadout_item/under/miscellaneous/jeansripped //BUYABLE
	name = "Recolorable Ripped Jeans"
	item_path = /obj/item/clothing/under/pants/nova/jeans_ripped //BUYABLE

/datum/loadout_item/under/miscellaneous/yoga //BUYABLE
	name = "Recolorable Yoga Pants"
	item_path = /obj/item/clothing/under/pants/nova/yoga

/datum/loadout_item/under/miscellaneous/track //BUYABLE
	name = "Track Pants"
	item_path = /obj/item/clothing/under/pants/track

/datum/loadout_item/under/miscellaneous/camo //BUYABLE
	name = "Camo Pants"
	item_path = /obj/item/clothing/under/pants/camo

/datum/loadout_item/under/miscellaneous/jeanshorts //BUYABLE
	name = "Recolorable Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/jeanshorts

/datum/loadout_item/under/miscellaneous/pants_blackshorts //BUYABLE
	name = "Recolorable Ripped Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/nova/shorts_ripped

/datum/loadout_item/under/miscellaneous/shortershorts //BUYABLE
	name = "Recolorable Shorter Shorts"
	item_path = /obj/item/clothing/under/shorts/nova/shortershorts

/datum/loadout_item/under/miscellaneous/shorts //BUYABLE
	name = "Recolorable Shorts"
	item_path = /obj/item/clothing/under/shorts

/datum/loadout_item/under/miscellaneous/red_short //BUYABLE
	name = "Red Shorts"
	item_path = /obj/item/clothing/under/shorts/red

/datum/loadout_item/under/miscellaneous/green_short //BUYABLE
	name = "Green Shorts"
	item_path = /obj/item/clothing/under/shorts/green

/datum/loadout_item/under/miscellaneous/blue_short //BUYABLE
	name = "Blue Shorts"
	item_path = /obj/item/clothing/under/shorts/blue

/datum/loadout_item/under/miscellaneous/black_short //BUYABLE
	name = "Black Shorts"
	item_path = /obj/item/clothing/under/shorts/black

/datum/loadout_item/under/miscellaneous/grey_short //BUYABLE
	name = "Grey Shorts"
	item_path = /obj/item/clothing/under/shorts/grey

/datum/loadout_item/under/miscellaneous/purple_short //BUYABLE
	name = "Purple Shorts"
	item_path = /obj/item/clothing/under/shorts/purple

/datum/loadout_item/under/miscellaneous/recolorable_kilt //BUYABLE
	name = "Recolorable Kilt"
	item_path = /obj/item/clothing/under/pants/nova/kilt

/datum/loadout_item/under/miscellaneous/dress_striped //BUYABLE
	name = "Striped Dress"
	item_path = /obj/item/clothing/under/dress/striped

/datum/loadout_item/under/miscellaneous/skirt_cableknit //BUYABLE
	name = "Recolorable Cableknit Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/turtleskirt_knit

/datum/loadout_item/under/miscellaneous/straplessdress //BUYABLE
	name = "Recolorable Strapless Dress"
	item_path = /obj/item/clothing/under/dress/nova/strapless

/datum/loadout_item/under/miscellaneous/pentagramdress //BUYABLE
	name = "Recolorable Pentagram Strapped Dress"
	item_path = /obj/item/clothing/under/dress/nova/pentagram

/datum/loadout_item/under/miscellaneous/jacarta_dress //BUYABLE
	name = "Jacarta Dress"
	item_path = /obj/item/clothing/under/dress/nova/jute

/datum/loadout_item/under/miscellaneous/red_skirt //BUYABLE
	name = "Red Bra and Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/red_skirt

/datum/loadout_item/under/miscellaneous/striped_skirt //BUYABLE
	name = "Red Bra and Striped Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/striped_skirt

/datum/loadout_item/under/miscellaneous/black_skirt //BUYABLE
	name = "Black Bra and Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/black_skirt

/datum/loadout_item/under/miscellaneous/swept_skirt //BUYABLE
	name = "Swept Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/swept

/datum/loadout_item/under/miscellaneous/lone_skirt //BUYABLE
	name = "Recolorable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/lone_skirt

/datum/loadout_item/under/miscellaneous/medium_skirt //BUYABLE
	name = "Medium Colourable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/medium

/datum/loadout_item/under/miscellaneous/long_skirt //BUYABLE
	name = "Long Colourable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/long

/datum/loadout_item/under/miscellaneous/denim_skirt //BUYABLE
	name = "Jean Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/jean

/datum/loadout_item/under/miscellaneous/littleblack //BUYABLE
	name = "Short Black Dress"
	item_path = /obj/item/clothing/under/dress/nova/short_dress

/datum/loadout_item/under/miscellaneous/pinktutu //BUYABLE
	name = "Pink Tutu"
	item_path = /obj/item/clothing/under/dress/nova/pinktutu

/datum/loadout_item/under/miscellaneous/flowerdress //BUYABLE
	name = "Flower Dress"
	item_path = /obj/item/clothing/under/dress/nova/flower

/datum/loadout_item/under/miscellaneous/tactical_hawaiian_orange //BUYABLE
	name = "Tactical Hawaiian Outfit - Orange"
	item_path = /obj/item/clothing/under/tachawaiian

/datum/loadout_item/under/miscellaneous/tactical_hawaiian_blue //BUYABLE
	name = "Tactical Hawaiian Outfit - Blue"
	item_path = /obj/item/clothing/under/tachawaiian/blue

/datum/loadout_item/under/miscellaneous/tactical_hawaiian_purple //BUYABLE
	name = "Tactical Hawaiian Outfit - Purple"
	item_path = /obj/item/clothing/under/tachawaiian/purple

/datum/loadout_item/under/miscellaneous/tactical_hawaiian_green //BUYABLE
	name = "Tactical Hawaiian Outfit - Green"
	item_path = /obj/item/clothing/under/tachawaiian/green

/datum/loadout_item/under/miscellaneous/yukata //BUYABLE
	name = "Yukata"
	item_path = /obj/item/clothing/under/costume/nova/yukata

/datum/loadout_item/under/miscellaneous/qipao_black //BUYABLE
	name = "Qipao"
	item_path = /obj/item/clothing/under/costume/nova/qipao

/datum/loadout_item/under/miscellaneous/qipao_recolorable //BUYABLE
	name = "Qipao, Custom Trim"
	item_path = /obj/item/clothing/under/costume/nova/qipao/customtrim

/datum/loadout_item/under/miscellaneous/cheongsam //BUYABLE
	name = "Cheongsam"
	item_path = /obj/item/clothing/under/costume/nova/cheongsam

/datum/loadout_item/under/miscellaneous/cheongsam_recolorable //BUYABLE
	name = "Cheongsam, Custom Trim"
	item_path = /obj/item/clothing/under/costume/nova/cheongsam/customtrim

/datum/loadout_item/under/miscellaneous/kimono //BUYABLE
	name = "Fancy Kimono"
	item_path =  /obj/item/clothing/under/costume/nova/kimono

/datum/loadout_item/under/miscellaneous/chaps //BUYABLE
	name = "Black Chaps"
	item_path = /obj/item/clothing/under/pants/nova/chaps

/datum/loadout_item/under/miscellaneous/tracky //BUYABLE
	name = "Blue Tracksuit"
	item_path = /obj/item/clothing/under/misc/bluetracksuit

/datum/loadout_item/under/miscellaneous/cybersleek //BUYABLE
	name = "Sleek Modern Coat"
	item_path = /obj/item/clothing/under/costume/cybersleek

/datum/loadout_item/under/miscellaneous/cybersleek_long //BUYABLE
	name = "Long Modern Coat"
	item_path = /obj/item/clothing/under/costume/cybersleek/long

/datum/loadout_item/under/miscellaneous/dutch //BUYABLE
	name = "Dutch Suit"
	item_path = /obj/item/clothing/under/costume/dutch

/datum/loadout_item/under/miscellaneous/cavalry //BUYABLE
	name = "Cavalry Uniform"
	item_path = /obj/item/clothing/under/costume/nova/cavalry

/datum/loadout_item/under/miscellaneous/expeditionary_corps //BUYABLE
	name = "Expeditionary Corps Uniform"
	item_path = /obj/item/clothing/under/rank/expeditionary_corps

/datum/loadout_item/under/miscellaneous/tactical_pants //BUYABLE
	name = "Tactical Pants"
	item_path = /obj/item/clothing/under/pants/tactical

/datum/loadout_item/under/miscellaneous/jabroni //BUYABLE
	name = "Jabroni Outfit"
	item_path = /obj/item/clothing/under/costume/jabroni

/datum/loadout_item/under/miscellaneous/blacknwhite
	name = "Classic Prisoner Jumpsuit"
	item_path = /obj/item/clothing/under/rank/prisoner/classic
	restricted_roles = list(JOB_PRISONER)

/datum/loadout_item/under/miscellaneous/redscrubs
	name = "Red Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/nova/red
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC, JOB_VIROLOGIST, JOB_GENETICIST ,JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/whitescrubs
	name = "White Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/nova/white
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC, JOB_VIROLOGIST, JOB_GENETICIST ,JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/taccas //BUYABLE
	name = "Tacticasual Uniform"
	item_path = /obj/item/clothing/under/misc/nova/taccas

/datum/loadout_item/under/miscellaneous/cargo_casual
	name = "Cargo Tech Casualwear"
	item_path = /obj/item/clothing/under/rank/cargo/tech/nova/casualman
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/cargo_turtle
	name = "Cargo Turtleneck"
	item_path = /obj/item/clothing/under/rank/cargo/tech/nova/turtleneck
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/cargo_gorka
	name = "Cargo Gorka"
	item_path = /obj/item/clothing/under/rank/cargo/tech/nova/gorka
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/cargo_skirtle
	name = "Cargo Skirtleneck"
	item_path = /obj/item/clothing/under/rank/cargo/tech/nova/turtleneck/skirt
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/qm_skirtle
	name = "Quartermaster's Skirtleneck"
	item_path = /obj/item/clothing/under/rank/cargo/qm/nova/turtleneck/skirt
	restricted_roles = list(JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/under/miscellaneous/qm_gorka
	name = "Quartermaster's Gorka Uniform"
	item_path = /obj/item/clothing/under/rank/cargo/qm/nova/gorka
	restricted_roles = list(JOB_QUARTERMASTER)
	requires_purchase = FALSE

/*
*	FORMAL UNDERSUITS
*/

/datum/loadout_item/under/formal

/datum/loadout_item/under/formal/formaldressred //BUYABLE
	name = "Formal Red Dress"
	item_path = /obj/item/clothing/under/dress/nova/redformal

/datum/loadout_item/under/formal/countessdress //BUYABLE
	name = "Countess Dress"
	item_path = /obj/item/clothing/under/dress/nova/countess

/datum/loadout_item/under/formal/executive_suit_alt //BUYABLE
	name = "Wide-collared Executive Suit"
	item_path = /obj/item/clothing/under/suit/nova/black_really_collared

/datum/loadout_item/under/formal/executive_skirt_alt //BUYABLE
	name = "Wide-collared Executive Suitskirt"
	item_path = /obj/item/clothing/under/suit/nova/black_really_collared/skirt

/datum/loadout_item/under/formal/navy_suit //BUYABLE
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy

/datum/loadout_item/under/formal/helltaker //BUYABLE
	name = "Red Shirt with White Trousers"
	item_path = /obj/item/clothing/under/suit/nova/helltaker

/datum/loadout_item/under/formal/helltaker/skirt //BUYABLE
	name = "Red Shirt with White Skirt"
	item_path = /obj/item/clothing/under/suit/nova/helltaker/skirt

/datum/loadout_item/under/formal/fancy_suit //BUYABLE
	name = "Fancy Suit"
	item_path = /obj/item/clothing/under/suit/fancy

/datum/loadout_item/under/formal/recolorable_suit //BUYABLE
	name = "Recolorable Formal Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable

/datum/loadout_item/under/formal/recolorable_suitskirt //BUYABLE
	name = "Recolorable Formal Suitskirt"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/skirt

/datum/loadout_item/under/formal/recolorable_suit/casual //BUYABLE
	name = "Office Casual Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/casual

/datum/loadout_item/under/formal/recolorable_suit/executive //BUYABLE
	name = "Executive Casual Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/executive

/datum/loadout_item/under/formal/pencil //BUYABLE
	name = "Pencilskirt with Shirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil

/datum/loadout_item/under/formal/pencil/noshirt //BUYABLE
	name = "Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/noshirt

/datum/loadout_item/under/formal/pencil/black_really //BUYABLE
	name = "Executive Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/black_really

/datum/loadout_item/under/formal/pencil/charcoal //BUYABLE
	name = "Charcoal Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/charcoal

/datum/loadout_item/under/formal/pencil/navy //BUYABLE
	name = "Navy Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/navy

/datum/loadout_item/under/formal/pencil/burgandy //BUYABLE
	name = "Burgandy Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/burgandy

/datum/loadout_item/under/formal/pencil/checkered //BUYABLE
	name = "Checkered Pencilskirt with Shirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/checkered

/datum/loadout_item/under/formal/pencil/checkered/noshirt //BUYABLE
	name = "Checkered Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/checkered/noshirt

/datum/loadout_item/under/formal/pencil/tan //BUYABLE
	name = "Tan Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/tan

/datum/loadout_item/under/formal/pencil/green //BUYABLE
	name = "Green Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/green

