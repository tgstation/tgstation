function toggle_other_checkboxes(source, copycats_str, our_index_str) {
    const copycats = parseInt(copycats_str);
    const our_index = parseInt(our_index_str);
    for (var i = 1; i <= copycats; i++) {
        if(i === our_index) {
            continue;
        }
        document.getElementById(source.id.slice(0, -1) + i).checked = source.checked;
    }
}

function header_click_all_checkboxes(source) {
	var checkboxes = document.getElementsByClassName(source.name);
	for(var i = 0, n = checkboxes.length; i < n; i++) {
		if(checkboxes[i].checked != source.checked && checkboxes[i] != source) {
			checkboxes[i].click();
		}
	}
}
