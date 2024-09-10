/*
These are the defines for controlling what conditions are required to display
an items special description.

See the examinemore module for information.
*/

#define EXAMINE_CHECK_NONE "none"			//Displays the special_desc regardless if it's set.
#define EXAMINE_CHECK_SYNDICATE "syndicate"		//For displaying descriptors for those with the SYNDICATE faction assigned.
#define EXAMINE_CHECK_SYNDICATE_TOY "syndicate_toy" //Ditto, only instead of displaying nothing for heathens, it shows "The src looks like a toy, not the real thing."
#define EXAMINE_CHECK_MINDSHIELD "mindshield"	//For displaying descriptors for those with a mindshield implant.
#define EXAMINE_CHECK_ROLE "role"			//For displaying description information based on a specific ROLE, e.g. traitor. Remember to set the special_desc_role var on the item.
#define EXAMINE_CHECK_JOB "job"			//For displaying descriptors for specific jobs, e.g scientist. Remember to set the special_desc_job var on the item.
#define EXAMINE_CHECK_FACTION "faction"		//For displaying descriptors for mob factions, e.g. a zombie, or... turrets. Or syndicate. Remember to set special_desc_factions.
