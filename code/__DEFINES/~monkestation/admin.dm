#define ADMIN_APPROVE_TOKEN(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];approve_antag_token=[REF(user)]'>Yes</a>)"
#define ADMIN_REJECT_TOKEN(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];reject_antag_token=[REF(user)]'>No</a>)"
#define ADMIN_OPEN_REVIEW(id) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];open_music_review=[id]'>Open Review</a>)"
#define ADMIN_APPROVE_TOKEN_EVENT(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];approve_token_event=[REF(user)]'>Yes</a>)"
#define ADMIN_REJECT_TOKEN_EVENT(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];reject_token_event=[REF(user)]'>No</a>)"

///Sends all admins the chosen sound
#define SEND_ADMINS_NOTFICATION_SOUND(sound) for(var/client/X in GLOB.admins){X << sound;}
///Sends a message in adminchat
#define SEND_ADMINCHAT_MESSAGE(message) to_chat(GLOB.admins, type = MESSAGE_TYPE_ADMINCHAT, html = message, confidential = TRUE)
///Sends a message in adminchat with the chosen notfication sound
#define SEND_NOTFIED_ADMIN_MESSAGE(sound, message) SEND_ADMINS_NOTFICATION_SOUND(sound); SEND_ADMINCHAT_MESSAGE(message)
