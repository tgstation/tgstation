

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	flags = FPRINT|TABLEPASS
	item_state = "centhat"
	siemens_coefficient = 0.9

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS
	siemens_coefficient = 0.9

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	flags = FPRINT | TABLEPASS
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	flags = FPRINT|TABLEPASS
	siemens_coefficient = 0.9

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	siemens_coefficient = 2.0

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state="cueball"
	flags_inv = 0

/obj/item/clothing/head/that
	name = "sturdy top-hat"
	desc = "It's an amish looking armored top hat."
	icon_state = "tophat"
	item_state = "that"
	flags = FPRINT|TABLEPASS
	flags_inv = 0


/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags = FPRINT|TABLEPASS
	flags_inv = 0

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	siemens_coefficient = 0.9

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For that industrial age look."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Like a top hat, but made of beavers."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "Goes well with celery."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A great hat ruined by being within fifty yards of you."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/fedora/OnMobLife(var/mob/living/carbon/human/wearer)
	if(!istype(wearer)) return
	if(wearer.head == src)
		if(prob(1))
			wearer << "<span class=\"warning\">You feel positively euphoric!</span>"

//TIPS FEDORA
/obj/item/clothing/head/fedora/verb/tip_fedora()
	set name = "Tip Fedora"
	set category = "Object"
	set desc = "Show that CIS SCUM who's boss."

	usr << "You tip your fedora."
	usr.visible_message("[usr] tips his fedora.")

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "Put it on your monkey, make lots of cash money."
	flags = FPRINT|TABLEPASS

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	siemens_coefficient = 2.0

/obj/item/clothing/head/batman
	name = "bathelmet"
	desc = "No one cares who you are until you put on the mask."
	icon_state = "bmhead"
	item_state = "bmhead"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/stalhelm
	name = "Stalhelm"
	desc = "Ein Helm, um die Nazi-Interesse an fremden Raumstationen zu sichern."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/head/panzer
	name = "Panzer Cap"
	desc = "Ein Hut passen nur für die größten Tanks."
	icon_state = "panzercap"
	item_state = "panzercap"
	flags = FPRINT | TABLEPASS | BLOCKHAIR

/obj/item/clothing/head/naziofficer
	name = "Officer Cap"
	desc = "Ein Hut von Offizieren in der Nazi-Partei getragen."
	icon_state = "officercap"
	item_state = "officercap"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	flags_inv = HIDEEARS