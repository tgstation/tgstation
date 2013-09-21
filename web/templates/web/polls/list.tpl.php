<?php
$polls=array();
foreach($this->polls as $row) {
	$polls[] = new Poll($row);
}
?>
<h1>Polls</h1>
<form action="<?=fmtURL('poll')?>" method="post">
	<?if($this->session):?>
	<input type="hidden" name="s" value="<?=$this->session->id?>" />
	<?endif;?>
<table class="fancy">
	<tr>
		<th>
			ID
		</th>
		<th>
			Question
		</th>
		<th>
			Expires
		</th>
		<?if($this->session!=false):?>
		<th>
			Controls
		</th>
		<?endif;?>
	</tr>
	
<?foreach($polls as $poll):
	?>
	<tr>
		<td class="clmID">
			<?=$poll->ID?>
		</td>
		<td class="clmQuestion">
			<?if(in_array($poll->type,$this->validPollTypes)):?>
			<a href="<?=fmtURL('poll',$poll->ID)?>">
			<?endif;?>
				<?=nl2br(htmlentities($poll->question))?>
			<?if(in_array($poll->type,$this->validPollTypes)):?>
			</a>
			<?else:?>
			<i>(Unknown polltype '<?=$poll->type?>')</i>
			<?endif;?>
		</td>
		<td class="clmExpires">
			<?=$poll->end?>
		</td>
		<?if($this->session!=false):?>
		<td class="clmControls">
			<button name="remove" value="<?=$poll->ID?>" type="submit">
				Remove
			</button>
		</td>
		<?endif;?>
	</tr>
<?endforeach;?>
</table>
</form>