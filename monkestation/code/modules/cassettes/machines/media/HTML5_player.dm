// IT IS FINALLY TIME.  IT IS HERE.  Converted to HTML5 <audio>  - Leshana
var/const/PLAYER_HTML5_HTML={"<!DOCTYPE html>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=11">
<script type="text/javascript">
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume, balance) {
	var player = document.getElementById('player');
	// IE can't handle us setting the time before it loads, so we must wait for asychronous load
	var setTime = function () {
		player.removeEventListener("canplay", setTime);  // One time only!
		player.volume = volume;
		player.currentTime = time;
		player.play();
	}
	if(url != "") player.addEventListener("canplay", setTime, false);
	player.src = url;
}
</script>
</head>
<body>
	<audio id="player"></audio>
</body>
</html>
"}

// Legacy player using Windows Media Player OLE object.
// I guess it will work in IE on windows, and BYOND uses IE on windows, so alright!
var/const/PLAYER_WMP_HTML={"
	<OBJECT id='player' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' type='application/x-oleobject'></OBJECT>
	<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume, balance) {
	var player = document.getElementById('player');
	player.URL = url;
	player.Controls.currentPosition = +time;
	player.Settings.volume = +volume;
	player.Settings.balance = +balance;
}
function SetVolume(volume, balance) {
	var player = document.getElementById('player');
	player.Settings.volume = +volume;
	player.Settings.balance = +balance;
}
	</script>"}
