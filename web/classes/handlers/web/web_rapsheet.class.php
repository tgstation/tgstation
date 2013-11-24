<?php

class rapsheet_handler extends BaseHandler {
	public $parent = '';
	public $description = "Rapsheet";
	public $image = "/img/admins.png";
	public function OnBody() {
		global $tpl, $db, $ADMIN_FLAGS;
		$types=array(
			'PERMABAN',
			'TEMPBAN',
			'CLUWNE',
			'JOB_PERMABAN',
			'JOB_TEMPBAN'
		);
		
		//$db->debug=true;
		$res = $db->Execute("SELECT * FROM erro_ban
		WHERE
			ckey=?
		ORDER BY ckey",array($_REQUEST['ckey']));
		if(!$res)
			die('MySQL Error: '.$db->ErrorMsg());
		$tpl->assign('bans',$res);
		$tpl->assign('bantypes',$types);
		return $tpl->fetch('web/rapsheet.tpl.php');
	}
	public function OnHeader() {
		$target = fmtAPIURL('findcid');
		$autocomplete=implode("','",Jobs::$KnownJobs);
		return <<<EOF
		 <script type="text/javascript">
$(document).ready(function(){ 
	//-------------------------------
	// Minimal
	//-------------------------------
	$('.jobs').tagit({
		fieldName: 'jobs[]',
		availableTags: ['{$autocomplete}']
	});
	$("button#getlast").click(function(){
		$.post("{$target}",
		{
		  ckey:$("#banCKey").val()
		},
		function(data,status){
		  //alert("Returned: "+status);
		  if(status=="success"){
		  	rows=data.split("\\n");
		  	$("#banIP").val(rows[0]);
		  	$("#banCID").val(rows[1]);
		  } else {
		  	alert("Couldn't find that ckey.");
		  }
		});
	});
});
		</script>
EOF;
	}
}
		
$ACT_HANDLERS['web_rapsheet'] = new rapsheet_handler;