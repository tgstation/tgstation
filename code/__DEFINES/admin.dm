//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_ALL		31

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.

#define BANTYPE_ADMIN_PERMA	7
#define BANTYPE_ADMIN_TEMP	8
#define BANTYPE_ANY_JOB		9 //used to remove jobbans

//Please don't edit these values without speaking to Errorage first	~Carn
//Admin Permissions
#define R_BUILDMODE		1
#define R_ADMIN			2
#define R_BAN			4
#define R_FUN			8
#define R_SERVER		16
#define R_DEBUG			32
#define R_POSSESS		64
#define R_PERMISSIONS	128
#define R_STEALTH		256
#define R_POLL			512
#define R_VAREDIT		1024
#define R_SOUNDS		2048
#define R_SPAWN			4096

#if DM_VERSION > 512
#error Remove the flag below , its been long enough
#endif
//legacy , remove post 512, it was replaced by R_POLL
#define R_REJUVINATE	2 

#define R_MAXPERMISSION 4096 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define ADMIN_QUE(user) "(<a href='?_src_=holder;adminmoreinfo=\ref[user]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='?_src_=holder;adminplayeropts=\ref[user]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='?_src_=vars;Vars=\ref[atom]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='?_src_=holder;subtlemessage=\ref[user]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='?_src_=holder;traitor=\ref[user]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='?_src_=holder;boot2=\ref[user]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='?_src_=holder;CentcommReply=\ref[user]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='?_src_=holder;SyndicateReply=\ref[user]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='?_src_=holder;adminspawncookie=\ref[user]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='?_src_=holder;adminsmite=\ref[user]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='?_src_=holder;set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='?_src_=holder;individuallog=\ref[user]'>LOGS</a>)"

#define ADMIN_PUNISHMENT_LIGHTNING "Lightning bolt"
#define ADMIN_PUNISHMENT_BRAINDAMAGE "Brain damage"
#define ADMIN_PUNISHMENT_GIB "Gib"
#define ADMIN_PUNISHMENT_BSA "Bluespace Artillery Device"

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3
