#
#	Copyright ©2020-2021 WellEngineered.us, all rights reserved.
#	Distributed under the MIT license: https://opensource.org/licenses/MIT
#

cls

$root = "F:\_archive_root_\camera_roll"

$old_value = ".."
$new_value = "."

$fs_items = Get-ChildItem $root -Recurse

foreach ($fs_item in $fs_items)
{
	$fs_old_item_full_name = $fs_item.FullName

	if(-not $fs_item.PSIsContainer -and $fs_old_item_full_name.IndexOf($old_value) -gt -1)
	{
		$fs_new_item_full_name = $fs_old_item_full_name.Replace($old_value, $new_value)

		"[Item Rename]: from=" + $fs_old_item_full_name + "`r`nto=" + $fs_new_item_full_name

		if (!(Test-Path -Path $fs_new_item_full_name))
		{
			$fs_item.MoveTo($fs_new_item_full_name)
		}

		$counter++
	}
}

