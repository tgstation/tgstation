SUBSYSTEM_DEF(tgui)
	name = "tgui"
	wait = 9
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_TGUI
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/currentrun = list()
	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.
	var/basehtml // The HTML base used for all UIs.

/datum/controller/subsystem/tgui/PreInit()
	//basehtml = file2text("tgui/tgui.html")
	basehtml = {"
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'/>
    <meta charset='utf-8'/>
    <script>
      window.update = function (dataString) {
        var data = JSON.parse(dataString);
        if (window.tgui) {
          window.tgui.set("config", data.config);
          if (typeof data.data !== 'undefined') {
            window.tgui.set("data", data.data);
            window.tgui.animate("adata", data.data);
          }
        }
      };
    </script>
    <link rel='stylesheet' href='tgui.css'/>
    <script id='data' type='application/json' data-ref='\[ref]'>{}</script>
    <script defer src='tgui.js'></script>
  </head>
  <body class='\[style]'>
    <div id='container' class='container'>
      <div class='notice'>
        <span>Loading...</span><br/>
      </div>
    </div>
    <noscript>
      <div class='notice'>
        <span>Javascript is required in order to use this interface.</span>
        <span>Please enable Javascript and restart the game.</span>
      </div>
    </noscript>
  </body>
</html>
"}

/datum/controller/subsystem/tgui/Shutdown()
	close_all_uis()

/datum/controller/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/controller/subsystem/tgui/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/tgui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if (MC_TICK_CHECK)
			return

