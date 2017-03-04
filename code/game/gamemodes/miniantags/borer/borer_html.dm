
/mob/living/simple_animal/borer/proc/get_html_template(content)
	var/html = {"<!DOCTYPE html">
		<html>
		<head>
			<title>Borer Chemicals</title>
			<link rel='stylesheet' type='text/css' href='icons.css'>
			<link rel='stylesheet' type='text/css' href='shared.css'>
			<style type='text/css'>

			body {
				padding: 10;
				margin: 0;
				font-size: 12px;
				color: #ffffff;
				line-height: 170%;
				font-family: Verdana, Geneva, sans-serif;
				background: #272727 url(uiBackground.png) 50% 0 repeat-x;
				overflow-x: hidden;
			}

			a, a:link, a:visited, a:active, .link, .linkOn, .linkOff, .selected, .disabled {
				color: #ffffff;
				text-decoration: none;
				background: #40628a;
				border: 1px solid #161616;
				padding: 2px 2px 2px 2px;
				margin: 2px 2px 2px 2px;
				cursor: pointer;
				display: inline-block;
			}

			a:hover, .linkActive:hover {
				background: #507aac;
				cursor: pointer;
			}

			img {
				border: 0px;
			}

			p {
				padding: 4px;
				margin: 0px;
			}

			h1, h2, h3, h4, h5, h6 {
				margin: 0;
				padding: 16px 0 8px 0;
				color: #517087;
				clear: both;
			}

			h1 {
				font-size: 15px;
			}

			h2 {
				font-size: 14px;
			}

			h3 {
				font-size: 13px;
			}

			h4 {
				font-size: 12px;
			}

			#header {
				margin: 3px;
				padding: 0px;
			}

			table {
				width: 570px;
				margin: 10px;
			}

			td {
				border: solid 1px #000;
				width: 560px;
			}

			.chem-select {
				width: 560px;
				margin: 5px;
				text-align: center;
			}

			.enabled {
				background-color: #0a0;
			}

			.disabled {
				background-color: #a00;
			}

			.shown {
				display: block;
			}

			.hidden {
				display: none;
			}
			</style>

			<script src="jquery.min.js"></script>
			<script type='text/javascript'>
				function update_chemicals(chemicals) {
					$('#chemicals').text(chemicals);
				}

				$(function() {
				});
			</script>
		</head>
		<body scroll='yes'><div id='content'>
		<h1 id='header'>Borer Chemicals</h1>
		<br />

		[content]

		</div></body></html>"}
	return html