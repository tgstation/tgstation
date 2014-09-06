/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */

#define ACT_BBCODE_IMG /datum/speech_filter_action/bbcode/img
#define ACT_BBCODE_VIDEO /datum/speech_filter_action/bbcode/video
#define CHECK_NANO /obj/item/weapon/pen
// MACROS
#define REG_NOTBB "\[^\\\[\]+"    // [^\]]+

// This WAS a macro, but BYOND a shit.
/proc/REG_BBTAG(x)
	return "\\\[[x]\\\]"

// [x]blah[/x]
/proc/REG_BETWEEN_BBTAG(x)
	return "[REG_BBTAG(x)]([REG_NOTBB])[REG_BBTAG("/[x]")]"

/datum/speech_filter_action/bbcode/Run(var/text, var/mob/user, var/atom/movable/P)
	return

/datum/speech_filter_action/bbcode/img/Run(var/text, var/mob/user, var/atom/movable/P)
	expr.index=1
	while(expr.FindNext(text))
		message_admins("[key_name_admin(user)] added an image ([html_encode(expr.GroupText(1))]) to [P] at [formatJumpTo(get_turf(P))]")
		var/rtxt="<img src=\"[html_encode(expr.GroupText(1))]\" />"
		text=copytext(text,1,expr.match)+rtxt+copytext(text,expr.index)
		expr.index=expr.match+length(rtxt)
	return text

/datum/speech_filter_action/bbcode/video/Run(var/text, var/mob/user, var/atom/movable/P)
	expr.index=1
	while(expr.FindNext(text))
		message_admins("[key_name_admin(user)] added a video ([html_encode(expr.GroupText(1))]) to [P] at [formatJumpTo(get_turf(P))]")
		var/rtxt="<embed src=\"[html_encode(expr.GroupText(1))]\" width=\"420\" height=\"344\" type=\"x-ms-wmv\" volume=\"85\" autoStart=\"0\" autoplay=\"true\" />"
		text=copytext(text,1,expr.match)+rtxt+copytext(text,expr.index)
		expr.index=expr.match+length(rtxt)
	return text

// Attached to writing instrument. (pen/pencil/etc)
/datum/writing_style
	parent_type = /datum/speech_filter

	var/style      = "font-family:Verdana, sans;"
	var/style_sign = "font-family:'Times New Roman', monospace;text-style:italic;"

/datum/writing_style/New()
	..()

	addReplacement(REG_BBTAG("center"), "<center>")
	addReplacement(REG_BBTAG("/center"),"</center>")
	addReplacement(REG_BBTAG("br"),     "<BR>")
	addReplacement(REG_BBTAG("b"),      "<B>")
	addReplacement(REG_BBTAG("/b"),     "</B>")
	addReplacement(REG_BBTAG("i"),      "<I>")
	addReplacement(REG_BBTAG("/i"),     "</I>")
	addReplacement(REG_BBTAG("u"),      "<U>")
	addReplacement(REG_BBTAG("/u"),     "</U>")
	addReplacement(REG_BBTAG("large"),  "<font size=\"4\">")
	addReplacement(REG_BBTAG("/large"), "</font>")
	//addReplacement(REG_BBTAG("sign"),   "<span style=\"[style_sign]\"><USERNAME /</span>")
	addReplacement(REG_BBTAG("field"),  "<span class=\"paper_field\"></span>")

	// Fallthrough just fucking kills the tag
	addReplacement(REG_BBTAG("\[^\\\]\]"), "")
	return

/datum/writing_style/proc/Format(var/t, var/obj/item/weapon/pen/P, var/mob/user, var/obj/item/weapon/paper/paper)
	if(expressions.len)
		for(var/key in expressions)
			var/datum/speech_filter_action/SFA = expressions[key]
			if(SFA && !SFA.broken)
				t = SFA.Run(t,user,paper)
	t = replacetext(t, "\[sign\]", "<font face=\"Times New Roman\"><i>[user.real_name]</i></font>")

	return "<span style=\"[style];color:[P.colour]\">[t]</span>"

/datum/writing_style/pen/New()
	addReplacement(REG_BBTAG("*"), "<li>")
	addReplacement(REG_BBTAG("hr"), "<HR>")
	addReplacement(REG_BBTAG("small"), "<font size = \"1\">")
	addReplacement(REG_BBTAG("/small"), "</font>")
	addReplacement(REG_BBTAG("list"), "<ul>")
	addReplacement(REG_BBTAG("/list"), "</ul>")

	// : is our delimiter, gi = global search, case-insensitive.
	addExpression(":"+REG_BBTAG("img")+"("+REG_NOTBB+")"+REG_BBTAG("/img")+":gi", ACT_BBCODE_IMG,list())

	..() // Order of operations

/datum/writing_style/pen/nano_paper/New()
	// : is our delimiter, gi = global search, case-insensitive.
	addExpression(":"+REG_BBTAG("video")+"("+REG_NOTBB+")"+REG_BBTAG("/video")+":gi", ACT_BBCODE_VIDEO,list())

	..()

/datum/writing_style/crayon
	style = "font-family:'Comic Sans MS';font-weight:bold"


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT | slot_ears
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	w_type = RECYK_MISC
	pressure_resistance = 2

	var/colour = "black"	//what colour the ink is!
	var/style_type = /datum/writing_style/pen
	var/nano_style_type = /datum/writing_style/pen/nano_paper
	var/datum/writing_style/style
	var/datum/writing_style/nano_style // stlyle when used on nano_paper

/obj/item/weapon/pen/New()
	..()

	style = new style_type
	nano_style = new nano_style_type

// checks if its used on nano paper, if it is, use the nano paper formatting
/obj/item/weapon/pen/proc/Format(var/mob/user, var/text, var/obj/item/weapon/paper/P)
	if(istype(P,/obj/item/weapon/paper/nano))
		return nano_style.Format(text,src,user,P)
	else
		return style.Format(text,src,user,P)

/obj/item/weapon/pen/suicide_act(mob/user)
	viewers(user) << "\red <b>[user]is jamming the [src.name]into \his ear! It looks like \he's trying to commit suicide.</b>"
	return(OXYLOSS)

/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "<span class='warning'>You stab [M] with the pen.</span>"
	M << "\red You feel a tiny prick!"
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
	return


/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/New()
	. = ..()
	create_reagents(30) // Used to be 300
	reagents.add_reagent("chloralhydrate", 22) // Used to be 100 sleep toxin // 30 Chloral seems to be fatal, reducing it to 22. /N

/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50)
	return


/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("impedrezene", 25)
	R.add_reagent("cryptobiolin", 15)
	..()
	return