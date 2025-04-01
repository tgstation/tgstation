function doRick() {
	const obj = document.getElementById('rickroll');
	if(typeof obj === 'undefined') {
		console.log('Undefined!!!')
		return
	}

	if(obj.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA) {
		obj.volume = 0.4;
		obj.play()
	}
	else {
		obj.addEventListener("loadeddata", () => {
		if (obj.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA) {
			obj.volume = 0.4;
			obj.play();
		}})
	};
}
