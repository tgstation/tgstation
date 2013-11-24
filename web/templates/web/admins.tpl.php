<?php
$ADMIN_FLAGS= $this->ADMIN_FLAGS;

?>
<h1>Administrators</h1>
<b>In Flux</b>
<table>
	<tr>
		<th>
			Name
		</th>
		<th>Rank</th>
		<?foreach($ADMIN_FLAGS as $flag=>$fname):?>
		<th>
			<?=$fname?>
		</th>
		<?endforeach;?>
	</tr>
<?foreach($this->admins as $row):?>
	<tr>
		<td class="clmName">
			<?=$row['ckey']?>
		</td>
		<td class="clmRank">
			<?=$row['rank']?>
		</td>
		<?foreach($ADMIN_FLAGS as $flag=>$name):
			$hasFlag=((intval($row['flags']) & $flag) == $flag);
		?>
		<td class="clm<?=$name?><?=($hasFlag)?' flagset':' flagunset'?> flags">
			<?=$hasFlag?'&#x2713;':'&#x2717;'?>
		</td>
		<?endforeach;?>
	</tr>
<?endforeach;?>
</table>