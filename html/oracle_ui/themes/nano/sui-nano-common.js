function replaceContent(body) {
    var maincontent = document.getElementById('maincontent');
    if(maincontent) {
      maincontent.innerHTML = body;
    }
}

function updateProgressLabels() {
	var progressBars  = document.getElementsByClassName("progressBar");
	for(var i = 0; i < progressBars.length; i++) {
		var progressBar = progressBars[i];
		if(!progressBar)
			continue;
		var progressFill = progressBar.getElementsByClassName("progressFill")[0];
		if(!progressFill)
			continue;
		var width = parseInt(getComputedStyle(progressFill).width);
	    var maxWidth = parseInt(getComputedStyle(progressBar).width);
		var progressLabel = progressBar.getElementsByClassName("progressLabel")[0];
		if(progressLabel)
			progressLabel.innerHTML = Math.round((width / maxWidth) * 100) + '%';
	}
}

if(getComputedStyle) { setInterval(updateProgressLabels, 50); } //Fallback

function updateFields(json) {
    var fields = JSON.parse(json);
	for (var key in fields) {
		let value = fields[key];
		var element = document.getElementById(key);
		if(element == null) {
			continue;
		} else if(element.classList.contains('progressBar')) {
			var progressFill = element.getElementsByClassName("progressFill")[0];
			if(progressFill)
				progressFill.style["width"] = value;
			if(!getComputedStyle) { //Fallback
				var progressLabel = element.getElementsByClassName("progressLabel")[0];
				if(progressLabel)
					progressLabel.innerHTML = value;
			}
		} else {
			element.innerHTML = value;
		}
	}
}