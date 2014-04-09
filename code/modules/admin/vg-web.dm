#ifdef __OPENBYOND
#define VGPanel(...) link(getVGPanel(__VA_ARGS__))
#endif
/datum/admins/proc/getVGPanel(var/route,var/list/query=list(),var/admin=0)
	checkSessionKey()
	var/url="[config.vgws_base_url]/index.php/[route]"

	//usr << link("[config.vgws_base_url]/index.php/rapsheet/?s=[sessKey]&ckey=[ckey]")

	if(admin)
		query["s"]=sessKey
	url += buildurlquery(query)
	return url