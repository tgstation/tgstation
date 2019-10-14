/* Code for the Wild West map by Brotemis
 * Contains:
 *		Wish Granter
 *		Meat Grinder
 */

//Areas

/area/awaymission/wildwest/mines
	name = "Wild West Mines"
	icon_state = "away1"
	requires_power = FALSE

/area/awaymission/wildwest/gov
	name = "Wild West Mansion"
	icon_state = "away2"
	requires_power = FALSE

/area/awaymission/wildwest/refine
	name = "Wild West Refinery"
	icon_state = "away3"
	requires_power = FALSE

/area/awaymission/wildwest/vault
	name = "Wild West Vault"
	icon_state = "away3"

/area/awaymission/wildwest/vaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = FALSE


 ////////// wildwest papers

/obj/item/paper/fluff/awaymissions/wildwest/grinder
	info = "meat grinder requires sacri"


/obj/item/paper/fluff/awaymissions/wildwest/journal/page1
	name = "Planer Saul's Journal: Page 1"
	info = "We've discovered something floating in space. We can't really tell how old it is, but it is scraped and bent to hell. There object is the size of about a room with double doors that we have yet to break into.   It is a lot sturdier than we could have imagined.  We have decided to call it 'The Vault' "

/obj/item/paper/fluff/awaymissions/wildwest/journal/page4
	name = "Planer Saul's Journal: Page 4"
	info = " The miners in the town have become sick and almost all production has stopped. They, in a fit of delusion, tossed all of their mining equipment into the furnaces.  They all claimed the same thing. A voice beckoning them to lay down their arms. Stupid miners."

/obj/item/paper/fluff/awaymissions/wildwest/journal/page7
	name = "Planer Sauls' Journal: Page 7"
	info = "The Vault...it just keeps growing and growing.  I went on my daily walk through the garden and now it's just right outside the mansion... a few days ago it was only barely visible. But whatever is inside...it's calling to me."

/obj/item/paper/fluff/awaymissions/wildwest/journal/page8
	name = "Planer Saul's Journal: Page 8"
	info = "The syndicate have invaded.  Their ships appeared out of nowhere and now they likely intend to kill us all and take everything.  On the off-chance that the Vault may grant us sanctuary, many of us have decided to force our way inside and bolt the door, taking as many provisions with us as we can carry.  In case you find this, send for help immediately and open the Vault. Find us inside."
