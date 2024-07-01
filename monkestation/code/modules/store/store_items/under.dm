// --- Loadout item datums for under suits ---

/// Underslot - Jumpsuit Items (Deletes overrided items)
GLOBAL_LIST_INIT(store_jumpsuits, generate_store_items(/datum/store_item/under/jumpsuit))

/// Underslot - Formal Suit Items (Deletes overrided items)
GLOBAL_LIST_INIT(store_undersuits, generate_store_items(/datum/store_item/under/formal))

/// Underslot - Misc. Under Items (Deletes overrided items)
GLOBAL_LIST_INIT(store_miscunders, generate_store_items(/datum/store_item/under/miscellaneous))

/datum/store_item/under
	category = LOADOUT_ITEM_UNIFORM

/datum/store_item/under/jumpsuit
	item_cost = 2500

/datum/store_item/under/jumpsuit/greyscale
	name = "Greyscale Jumpsuit"
	item_path = /obj/item/clothing/under/color

/datum/store_item/under/jumpsuit/greyscale_skirt
	name = "Greyscale Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt

/datum/store_item/under/jumpsuit/random
	name = "Random Jumpsuit"
	item_path = /obj/item/clothing/under/color/random

/datum/store_item/under/jumpsuit/random_skirt
	name = "Random Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/random

/datum/store_item/under/jumpsuit/rainbow
	name = "Rainbow Jumpsuit"
	item_path = /obj/item/clothing/under/color/rainbow

/datum/store_item/under/jumpsuit/rainbow_skirt
	name = "Rainbow Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/rainbow

/datum/store_item/under/jumpsuit/disco
	name = "Superstar Cop Uniform"
	item_path = /obj/item/clothing/under/rank/security/detective/disco

/datum/store_item/under/jumpsuit/kim
	name = "Aerostatic Suit"
	item_path = /obj/item/clothing/under/rank/security/detective/kim


/*
*	MISC UNDERSUITS
*/

/datum/store_item/under/miscellaneous
	item_cost = 3000

/datum/store_item/under/miscellaneous/buttondown
	name = "Recolorable Buttondown Shirt with Slacks"
	item_path = /obj/item/clothing/under/costume/buttondown/slacks

/datum/store_item/under/miscellaneous/buttondown_shorts
	name = "Recolorable Buttondown Shirt with Shorts"
	item_path = /obj/item/clothing/under/costume/buttondown/shorts

/datum/store_item/under/miscellaneous/slacks
	name = "Recolorable Slacks"
	item_path = /obj/item/clothing/under/pants/slacks

/datum/store_item/under/miscellaneous/jeans
	name = "Recolorable Jeans"
	item_path = /obj/item/clothing/under/pants/jeans


/datum/store_item/under/miscellaneous/track
	name = "Track Pants"
	item_path = /obj/item/clothing/under/pants/track

/datum/store_item/under/miscellaneous/camo
	name = "Camo Pants"
	item_path = /obj/item/clothing/under/pants/camo

/datum/store_item/under/miscellaneous/jeanshorts //This doesnt look like a word. Short. Jean-Short. Eugh.
	name = "Recolorable Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/jeanshorts

/datum/store_item/under/miscellaneous/shorts
	name = "Recolorable Shorts"
	item_path = /obj/item/clothing/under/shorts

/datum/store_item/under/miscellaneous/red_short
	name = "Red Shorts"
	item_path = /obj/item/clothing/under/shorts/red

/datum/store_item/under/miscellaneous/green_short
	name = "Green Shorts"
	item_path = /obj/item/clothing/under/shorts/green

/datum/store_item/under/miscellaneous/blue_short
	name = "Blue Shorts"
	item_path = /obj/item/clothing/under/shorts/blue

/datum/store_item/under/miscellaneous/black_short
	name = "Black Shorts"
	item_path = /obj/item/clothing/under/shorts/black

/datum/store_item/under/miscellaneous/grey_short
	name = "Grey Shorts"
	item_path = /obj/item/clothing/under/shorts/grey

/datum/store_item/under/miscellaneous/purple_short
	name = "Purple Shorts"
	item_path = /obj/item/clothing/under/shorts/purple

//TODO: split loadout's miscellaneous to have "Pants/Shorts" and "Dresses/Skirts" as options too. Misc is stupid.

/datum/store_item/under/miscellaneous/dress_striped
	name = "Striped Dress"
	item_path = /obj/item/clothing/under/dress/striped

/datum/store_item/under/miscellaneous/skirt_black
	name = "Black Skirt"
	item_path = /obj/item/clothing/under/dress/skirt

/datum/store_item/under/miscellaneous/skirt_plaid
	name = "Recolorable Plaid Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/plaid

/datum/store_item/under/miscellaneous/skirt_turtleneck
	name = "Recolorable Turtleneck Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/turtleskirt

/datum/store_item/under/miscellaneous/dress_tango
	name = "Recolorable Tango Dress"
	item_path = /obj/item/clothing/under/dress/tango

/datum/store_item/under/miscellaneous/dress_sun
	name = "Recolorable Sundress"
	item_path = /obj/item/clothing/under/dress/sundress

/datum/store_item/under/miscellaneous/kilt
	name = "Kilt"
	item_path = /obj/item/clothing/under/costume/kilt

/datum/store_item/under/miscellaneous/treasure_hunter
	name = "Treasure Hunter"
	item_path = /obj/item/clothing/under/rank/civilian/curator/treasure_hunter

/datum/store_item/under/miscellaneous/overalls
	name = "Overalls"
	item_path = /obj/item/clothing/under/misc/overalls

/datum/store_item/under/miscellaneous/pj_blue
	name = "Mailman Jumpsuit"
	item_path = /obj/item/clothing/under/misc/mailman

/datum/store_item/under/miscellaneous/vice_officer
	name = "Vice Officer Jumpsuit"
	item_path = /obj/item/clothing/under/misc/vice_officer

/datum/store_item/under/miscellaneous/soviet
	name = "Soviet Uniform"
	item_path = /obj/item/clothing/under/costume/soviet

/datum/store_item/under/miscellaneous/redcoat
	name = "Redcoat"
	item_path = /obj/item/clothing/under/costume/redcoat

/datum/store_item/under/miscellaneous/pj_red
	name = "Red PJs"
	item_path = /obj/item/clothing/under/misc/pj/red

/datum/store_item/under/miscellaneous/pj_blue
	name = "Blue PJs"
	item_path = /obj/item/clothing/under/misc/pj/blue


/datum/store_item/under/miscellaneous/maidcostume
	name = "Maid Costume"
	item_path = /obj/item/clothing/under/costume/maid


/datum/store_item/under/miscellaneous/kimono
	name = "Fancy Kimono"
	item_path =  /obj/item/clothing/under/costume/skyrat/kimono


/datum/store_item/under/miscellaneous/dutch
	name = "Dutch Suit"
	item_path = /obj/item/clothing/under/costume/dutch


/datum/store_item/under/miscellaneous/tacticool_turtleneck
	name = "Tacticool Turtleneck"
	item_path = /obj/item/clothing/under/syndicate/tacticool

/datum/store_item/under/miscellaneous/tactical_skirt
	name = "Tacticool Skirtleneck"
	item_path = /obj/item/clothing/under/syndicate/tacticool/skirt


/datum/store_item/under/miscellaneous/gladiator
	name = "Gladiator Uniform"
	item_path = /obj/item/clothing/under/costume/gladiator

/datum/store_item/under/miscellaneous/griffon
	name = "Griffon Uniform"
	item_path = /obj/item/clothing/under/costume/griffin

/datum/store_item/under/miscellaneous/owl
	name = "Owl Uniform"
	item_path = /obj/item/clothing/under/costume/owl

/datum/store_item/under/miscellaneous/villain
	name = "Villain Suit"
	item_path = /obj/item/clothing/under/costume/villain


/datum/store_item/under/miscellaneous/bluescrubs
	name = "Blue Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/blue

/datum/store_item/under/miscellaneous/greenscrubs
	name = "Green Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/green

/datum/store_item/under/miscellaneous/purplescrubs
	name = "Purple Scrubs"
	item_path = /obj/item/clothing/under/rank/medical/scrubs/purple

/datum/store_item/under/miscellaneous/ethereal_tunic
	name = "Ethereal Tunic"
	item_path = /obj/item/clothing/under/ethereal_tunic

/datum/store_item/under/miscellaneous/tragic
	name = "Tragic Mime Suit"
	item_path = /obj/item/clothing/under/costume/tragic

/datum/store_item/under/miscellaneous/bunnysuit
	name = "Colorable Bunny Suit"
	item_path = /obj/item/clothing/under/costume/playbunny
/*
*	FORMAL UNDERSUITS
*/

/datum/store_item/under/formal
	item_cost = 5000

/datum/store_item/under/formal/amish_suit
	name = "Amish Suit"
	item_path = /obj/item/clothing/under/suit/sl

/datum/store_item/under/formal/assistant
	name = "Assistant Formal"
	item_path = /obj/item/clothing/under/misc/assistantformal

/datum/store_item/under/formal/beige_suit
	name = "Beige Suit"
	item_path = /obj/item/clothing/under/suit/beige

/datum/store_item/under/formal/black_suit
	name = "Black Suit"
	item_path = /obj/item/clothing/under/suit/black

/datum/store_item/under/formal/black_suitskirt
	name = "Black Suitskirt"
	item_path = /obj/item/clothing/under/suit/black/skirt

/datum/store_item/under/formal/black_twopiece
	name = "Black Two-Piece Suit"
	item_path = /obj/item/clothing/under/suit/blacktwopiece

/datum/store_item/under/formal/black_lawyer_suit
	name = "Black Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black

/datum/store_item/under/formal/black_lawyer_skirt
	name = "Black Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black/skirt

/datum/store_item/under/formal/blue_suit
	name = "Blue Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit

/datum/store_item/under/formal/blue_suitskirt
	name = "Blue Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt

/datum/store_item/under/formal/blue_lawyer_suit
	name = "Blue Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue

/datum/store_item/under/formal/blue_lawyer_skirt
	name = "Blue Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue/skirt

/datum/store_item/under/formal/burgundy_suit
	name = "Burgundy Suit"
	item_path = /obj/item/clothing/under/suit/burgundy

/datum/store_item/under/formal/charcoal_suit
	name = "Charcoal Suit"
	item_path = /obj/item/clothing/under/suit/charcoal

/datum/store_item/under/formal/checkered_suit
	name = "Checkered Suit"
	item_path = /obj/item/clothing/under/suit/checkered

/datum/store_item/under/formal/executive_suit
	name = "Executive Suit"
	item_path = /obj/item/clothing/under/suit/black_really

/datum/store_item/under/formal/executive_skirt
	name = "Executive Suitskirt"
	item_path = /obj/item/clothing/under/suit/black_really/skirt

/datum/store_item/under/formal/navy_suit
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy

/datum/store_item/under/formal/maid_outfit
	name = "Maid Outfit"
	item_path = /obj/item/clothing/under/costume/maid

/datum/store_item/under/formal/maid_uniform
	name = "Maid Uniform"
	item_path = /obj/item/clothing/under/rank/civilian/janitor/maid

/datum/store_item/under/formal/purple_suit
	name = "Purple Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit

/datum/store_item/under/formal/purple_suitskirt
	name = "Purple Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt

/datum/store_item/under/formal/red_suit
	name = "Red Suit"
	item_path = /obj/item/clothing/under/suit/red


/datum/store_item/under/formal/red_lawyer_skirt
	name = "Red Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red

/datum/store_item/under/formal/red_lawyer_skirt
	name = "Red Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt

/datum/store_item/under/formal/red_gown
	name = "Red Evening Gown"
	item_path = /obj/item/clothing/under/dress/redeveninggown

/datum/store_item/under/formal/sailor
	name = "Sailor Suit"
	item_path = /obj/item/clothing/under/costume/sailor

/datum/store_item/under/formal/sailor_skirt
	name = "Sailor Dress"
	item_path = /obj/item/clothing/under/dress/sailor

/datum/store_item/under/formal/scratch_suit
	name = "Scratch Suit"
	item_path = /obj/item/clothing/under/suit/white_on_white

/datum/store_item/under/formal/sensible_suit
	name = "Sensible Suit"
	item_path = /obj/item/clothing/under/rank/civilian/curator

/datum/store_item/under/formal/sensible_skirt
	name = "Sensible Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/curator/skirt

/datum/store_item/under/formal/tuxedo
	name = "Tuxedo Suit"
	item_path = /obj/item/clothing/under/suit/tuxedo

/datum/store_item/under/formal/waiter
	name = "Waiter's Suit"
	item_path = /obj/item/clothing/under/suit/waiter

/datum/store_item/under/formal/white_suit
	name = "White Suit"
	item_path = /obj/item/clothing/under/suit/white


/datum/store_item/under/formal/trek_command
	name = "Trekkie Command Uniform"
	item_path = /obj/item/clothing/under/trek/command

/datum/store_item/under/formal/trek_engsec
	name = "Trekkie Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec

/datum/store_item/under/formal/trek_medsci
	name = "Trekkie Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci

/datum/store_item/under/formal/trek_next_command
	name = "Trekkie TNG Command Uniform"
	item_path = /obj/item/clothing/under/trek/command/next

/datum/store_item/under/formal/trek_next_engsec
	name = "Trekkie TNG Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec/next

/datum/store_item/under/formal/trek_next_medsci
	name = "Trekkie TNG Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci/next

/datum/store_item/under/formal/trek_ent_command
	name = "Trekkie ENT Command Uniform"
	item_path = /obj/item/clothing/under/trek/command/ent

/datum/store_item/under/formal/trek_ent_engsec
	name = "Trekkie ENT Engsec Uniform"
	item_path = /obj/item/clothing/under/trek/engsec/ent

/datum/store_item/under/formal/trek_ent_medsci
	name = "Trekkie ENT Medsci Uniform"
	item_path = /obj/item/clothing/under/trek/medsci/ent

/datum/store_item/under/formal/the_q
	name = "French Marshall's Uniform"
	item_path = /obj/item/clothing/under/trek/q

//FAMILIES GEAR
/datum/store_item/under/formal/osi
	name = "OSI Uniform"
	item_path = /obj/item/clothing/under/costume/osi
	item_cost = 7500

/datum/store_item/under/formal/tmc
	name = "TMC Uniform"
	item_path = /obj/item/clothing/under/costume/tmc
	item_cost = 7500

/datum/store_item/under/formal/driscoll
	name = "O'Driscoll outfit"
	item_path = /obj/item/clothing/under/driscoll
	item_cost = 7500

/datum/store_item/under/formal/morningstar
	name = "Morningstar suit"
	item_path = /obj/item/clothing/under/morningstar
	item_cost = 7500

/datum/store_item/under/formal/saints
	name = "Saints outfit"
	item_path = /obj/item/clothing/under/saints
	item_cost = 7500

/datum/store_item/under/formal/phantom
	name = "Phantom Thief outfit"
	item_path = /obj/item/clothing/under/phantom
	item_cost = 7500

/datum/store_item/under/miscellaneous/bloodred
	name = "Blood-red pajamas"
	item_path = /obj/item/clothing/under/bloodred
	item_cost = 3000

/datum/store_item/under/miscellaneous/shrine
	name = "Shrine Priestess Kimono"
	item_path = /obj/item/clothing/under/dress/shrine_priestess
	item_cost = 5000

/// EVERYTHING NOVA RELATED

/datum/store_item/under/jumpsuit/imperial_police_uniform //BUYABLE
	name = "Imperial Police Uniform"
	item_path = /obj/item/clothing/under/colonial/nri_police
	item_cost = 4000

/datum/store_item/under/jumpsuit/sol_peacekeeper //BUYABLE
	name = "Sol Peacekeeper Uniform"
	item_path = /obj/item/clothing/under/sol_peacekeeper
	item_cost = 4000

/datum/store_item/under/jumpsuit/utility	//BUYABLE
	name = "Utility Uniform"
	item_path = /obj/item/clothing/under/misc/nova/utility
	item_cost = 3000

/datum/store_item/under/miscellaneous/vicvest //BUYABLE
	name = "Recolorable Buttondown Shirt with Double-Breasted Vest"
	item_path = /obj/item/clothing/under/pants/nova/vicvest
	item_cost = 1500

/datum/store_item/under/miscellaneous/slacks //BUYABLE
	name = "Recolorable Slacks"
	item_path = /obj/item/clothing/under/pants/slacks //BUYABLE
	item_cost = 2500

/datum/store_item/under/miscellaneous/jeans //BUYABLE
	name = "Recolorable Jeans"
	item_path = /obj/item/clothing/under/pants/jeans
	item_cost = 2500

/datum/store_item/under/miscellaneous/jeansripped //BUYABLE
	name = "Recolorable Ripped Jeans"
	item_path = /obj/item/clothing/under/pants/nova/jeans_ripped //BUYABLE
	item_cost = 2500

/datum/store_item/under/miscellaneous/yoga //BUYABLE
	name = "Recolorable Yoga Pants"
	item_path = /obj/item/clothing/under/pants/nova/yoga
	item_cost = 1500

/datum/store_item/under/miscellaneous/track //BUYABLE
	name = "Track Pants"
	item_path = /obj/item/clothing/under/pants/track
	item_cost = 1500

/datum/store_item/under/miscellaneous/camo //BUYABLE
	name = "Camo Pants"
	item_path = /obj/item/clothing/under/pants/camo
	item_cost = 1500

/datum/store_item/under/miscellaneous/jeanshorts //BUYABLE
	name = "Recolorable Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/jeanshorts
	item_cost = 2500

/datum/store_item/under/miscellaneous/pants_blackshorts //BUYABLE
	name = "Recolorable Ripped Jean Shorts"
	item_path = /obj/item/clothing/under/shorts/nova/shorts_ripped
	item_cost = 2500

/datum/store_item/under/miscellaneous/shortershorts //BUYABLE
	name = "Recolorable Shorter Shorts"
	item_path = /obj/item/clothing/under/shorts/nova/shortershorts
	item_cost = 1500

/datum/store_item/under/miscellaneous/shorts //BUYABLE
	name = "Recolorable Shorts"
	item_path = /obj/item/clothing/under/shorts
	item_cost = 2500

/datum/store_item/under/miscellaneous/red_short //BUYABLE
	name = "Red Shorts"
	item_path = /obj/item/clothing/under/shorts/red
	item_cost = 1500

/datum/store_item/under/miscellaneous/green_short //BUYABLE
	name = "Green Shorts"
	item_path = /obj/item/clothing/under/shorts/green
	item_cost = 1500

/datum/store_item/under/miscellaneous/blue_short //BUYABLE
	name = "Blue Shorts"
	item_path = /obj/item/clothing/under/shorts/blue
	item_cost = 1500

/datum/store_item/under/miscellaneous/black_short //BUYABLE
	name = "Black Shorts"
	item_path = /obj/item/clothing/under/shorts/black
	item_cost = 1500

/datum/store_item/under/miscellaneous/grey_short //BUYABLE
	name = "Grey Shorts"
	item_path = /obj/item/clothing/under/shorts/grey
	item_cost = 1500

/datum/store_item/under/miscellaneous/purple_short //BUYABLE
	name = "Purple Shorts"
	item_path = /obj/item/clothing/under/shorts/purple
	item_cost = 1500

/datum/store_item/under/miscellaneous/recolorable_kilt //BUYABLE
	name = "Recolorable Kilt"
	item_path = /obj/item/clothing/under/pants/nova/kilt
	item_cost = 2000

/datum/store_item/under/miscellaneous/dress_striped //BUYABLE
	name = "Striped Dress"
	item_path = /obj/item/clothing/under/dress/striped
	item_cost = 1500

/datum/store_item/under/miscellaneous/skirt_cableknit //BUYABLE
	name = "Recolorable Cableknit Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/turtleskirt_knit
	item_cost = 1500

/datum/store_item/under/miscellaneous/straplessdress //BUYABLE
	name = "Recolorable Strapless Dress"
	item_path = /obj/item/clothing/under/dress/nova/strapless
	item_cost = 1500

/datum/store_item/under/miscellaneous/pentagramdress //BUYABLE
	name = "Recolorable Pentagram Strapped Dress"
	item_path = /obj/item/clothing/under/dress/nova/pentagram
	item_cost = 2000

/datum/store_item/under/miscellaneous/jacarta_dress //BUYABLE
	name = "Jacarta Dress"
	item_path = /obj/item/clothing/under/dress/nova/jute
	item_cost = 1500

/datum/store_item/under/miscellaneous/red_skirt //BUYABLE
	name = "Red Bra and Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/red_skirt
	item_cost = 1500

/datum/store_item/under/miscellaneous/striped_skirt //BUYABLE
	name = "Red Bra and Striped Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/striped_skirt
	item_cost = 1500

/datum/store_item/under/miscellaneous/black_skirt //BUYABLE
	name = "Black Bra and Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/black_skirt
	item_cost = 1500

/datum/store_item/under/miscellaneous/swept_skirt //BUYABLE
	name = "Swept Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/swept
	item_cost = 1500

/datum/store_item/under/miscellaneous/lone_skirt //BUYABLE
	name = "Recolorable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/lone_skirt
	item_cost = 1500

/datum/store_item/under/miscellaneous/medium_skirt //BUYABLE
	name = "Medium Colourable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/medium
	item_cost = 1500

/datum/store_item/under/miscellaneous/long_skirt //BUYABLE
	name = "Long Colourable Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/long
	item_cost = 1500

/datum/store_item/under/miscellaneous/denim_skirt //BUYABLE
	name = "Jean Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/nova/jean
	item_cost = 1000

/datum/store_item/under/miscellaneous/littleblack //BUYABLE
	name = "Short Black Dress"
	item_path = /obj/item/clothing/under/dress/nova/short_dress
	item_cost = 1000

/datum/store_item/under/miscellaneous/pinktutu //BUYABLE
	name = "Pink Tutu"
	item_path = /obj/item/clothing/under/dress/nova/pinktutu
	item_cost = 1000

/datum/store_item/under/miscellaneous/flowerdress //BUYABLE
	name = "Flower Dress"
	item_path = /obj/item/clothing/under/dress/nova/flower
	item_cost = 1000

/datum/store_item/under/miscellaneous/tactical_hawaiian_orange //BUYABLE
	name = "Tactical Hawaiian Outfit - Orange"
	item_path = /obj/item/clothing/under/tachawaiian
	item_cost = 3000

/datum/store_item/under/miscellaneous/tactical_hawaiian_blue //BUYABLE
	name = "Tactical Hawaiian Outfit - Blue"
	item_path = /obj/item/clothing/under/tachawaiian/blue
	item_cost = 3000

/datum/store_item/under/miscellaneous/tactical_hawaiian_purple //BUYABLE
	name = "Tactical Hawaiian Outfit - Purple"
	item_path = /obj/item/clothing/under/tachawaiian/purple
	item_cost = 3000

/datum/store_item/under/miscellaneous/tactical_hawaiian_green //BUYABLE
	name = "Tactical Hawaiian Outfit - Green"
	item_path = /obj/item/clothing/under/tachawaiian/green
	item_cost = 3000

/datum/store_item/under/miscellaneous/yukata //BUYABLE
	name = "Yukata"
	item_path = /obj/item/clothing/under/costume/nova/yukata
	item_cost = 2500

/datum/store_item/under/miscellaneous/qipao_black //BUYABLE
	name = "Qipao"
	item_path = /obj/item/clothing/under/costume/nova/qipao
	item_cost = 2500

/datum/store_item/under/miscellaneous/qipao_recolorable //BUYABLE
	name = "Qipao, Custom Trim"
	item_path = /obj/item/clothing/under/costume/nova/qipao/customtrim
	item_cost = 2500

/datum/store_item/under/miscellaneous/cheongsam //BUYABLE
	name = "Cheongsam"
	item_path = /obj/item/clothing/under/costume/nova/cheongsam
	item_cost = 2500

/datum/store_item/under/miscellaneous/cheongsam_recolorable //BUYABLE
	name = "Cheongsam, Custom Trim"
	item_path = /obj/item/clothing/under/costume/nova/cheongsam/customtrim
	item_cost = 2500

/datum/store_item/under/miscellaneous/kimono //BUYABLE
	name = "Fancy Kimono"
	item_path =  /obj/item/clothing/under/costume/nova/kimono
	item_cost = 2500

/datum/store_item/under/miscellaneous/chaps //BUYABLE
	name = "Black Chaps"
	item_path = /obj/item/clothing/under/pants/nova/chaps
	item_cost = 1500

/datum/store_item/under/miscellaneous/tracky //BUYABLE
	name = "Blue Tracksuit"
	item_path = /obj/item/clothing/under/misc/bluetracksuit
	item_cost = 1500

/datum/store_item/under/miscellaneous/cybersleek //BUYABLE
	name = "Sleek Modern Coat"
	item_path = /obj/item/clothing/under/costume/cybersleek
	item_cost = 4000

/datum/store_item/under/miscellaneous/cybersleek_long //BUYABLE
	name = "Long Modern Coat"
	item_path = /obj/item/clothing/under/costume/cybersleek/long
	item_cost = 4000

/datum/store_item/under/miscellaneous/dutch //BUYABLE
	name = "Dutch Suit"
	item_path = /obj/item/clothing/under/costume/dutch
	item_cost = 5000

/datum/store_item/under/miscellaneous/cavalry //BUYABLE
	name = "Cavalry Uniform"
	item_path = /obj/item/clothing/under/costume/nova/cavalry
	item_cost = 5000

/datum/store_item/under/miscellaneous/expeditionary_corps //BUYABLE
	name = "Expeditionary Corps Uniform"
	item_path = /obj/item/clothing/under/rank/expeditionary_corps
	item_cost = 3000

/datum/store_item/under/miscellaneous/tactical_pants //BUYABLE
	name = "Tactical Pants"
	item_path = /obj/item/clothing/under/pants/tactical
	item_cost = 1500

/datum/store_item/under/miscellaneous/jabroni //BUYABLE
	name = "Jabroni Outfit"
	item_path = /obj/item/clothing/under/costume/jabroni
	item_cost = 1500

/datum/store_item/under/miscellaneous/taccas //BUYABLE
	name = "Tacticasual Uniform"
	item_path = /obj/item/clothing/under/misc/nova/taccas
	item_cost = 3000

/datum/store_item/under/formal/formaldressred //BUYABLE
	name = "Formal Red Dress"
	item_path = /obj/item/clothing/under/dress/nova/redformal
	item_cost = 3000

/datum/store_item/under/formal/countessdress //BUYABLE
	name = "Countess Dress"
	item_path = /obj/item/clothing/under/dress/nova/countess
	item_cost = 5000

/datum/store_item/under/formal/executive_suit_alt //BUYABLE
	name = "Wide-collared Executive Suit"
	item_path = /obj/item/clothing/under/suit/nova/black_really_collared
	item_cost = 5000

/datum/store_item/under/formal/executive_skirt_alt //BUYABLE
	name = "Wide-collared Executive Suitskirt"
	item_path = /obj/item/clothing/under/suit/nova/black_really_collared/skirt
	item_cost = 5000

/datum/store_item/under/formal/navy_suit //BUYABLE
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy
	item_cost = 5000

/datum/store_item/under/formal/helltaker //BUYABLE
	name = "Red Shirt with White Trousers"
	item_path = /obj/item/clothing/under/suit/nova/helltaker
	item_cost = 1500

/datum/store_item/under/formal/helltaker/skirt //BUYABLE
	name = "Red Shirt with White Skirt"
	item_path = /obj/item/clothing/under/suit/nova/helltaker/skirt
	item_cost = 1500

/datum/store_item/under/formal/fancy_suit //BUYABLE
	name = "Fancy Suit"
	item_path = /obj/item/clothing/under/suit/fancy
	item_cost = 1500

/datum/store_item/under/formal/recolorable_suit //BUYABLE
	name = "Recolorable Formal Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable
	item_cost = 4000

/datum/store_item/under/formal/recolorable_suitskirt //BUYABLE
	name = "Recolorable Formal Suitskirt"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/skirt
	item_cost = 4000

/datum/store_item/under/formal/recolorable_suit/casual //BUYABLE
	name = "Office Casual Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/casual
	item_cost = 2000

/datum/store_item/under/formal/recolorable_suit/executive //BUYABLE
	name = "Executive Casual Suit"
	item_path = /obj/item/clothing/under/suit/nova/recolorable/executive
	item_cost = 2000

/datum/store_item/under/formal/pencil //BUYABLE
	name = "Pencilskirt with Shirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil
	item_cost = 1500

/datum/store_item/under/formal/pencil/noshirt //BUYABLE
	name = "Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/noshirt
	item_cost = 1500

/datum/store_item/under/formal/pencil/black_really //BUYABLE
	name = "Executive Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/black_really
	item_cost = 1500

/datum/store_item/under/formal/pencil/charcoal //BUYABLE
	name = "Charcoal Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/charcoal
	item_cost = 1500

/datum/store_item/under/formal/pencil/navy //BUYABLE
	name = "Navy Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/navy
	item_cost = 1500

/datum/store_item/under/formal/pencil/burgandy //BUYABLE
	name = "Burgandy Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/burgandy
	item_cost = 1500

/datum/store_item/under/formal/pencil/checkered //BUYABLE
	name = "Checkered Pencilskirt with Shirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/checkered
	item_cost = 1500

/datum/store_item/under/formal/pencil/checkered/noshirt //BUYABLE
	name = "Checkered Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/checkered/noshirt
	item_cost = 1500

/datum/store_item/under/formal/pencil/tan //BUYABLE
	name = "Tan Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/tan
	item_cost = 1500

/datum/store_item/under/formal/pencil/green //BUYABLE
	name = "Green Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil/green
	item_cost = 1500
