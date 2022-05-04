#
#	Copyright ©2020-2021 WellEngineered.us, all rights reserved.
#	Distributed under the MIT license: https://opensource.org/licenses/MIT
#

cls

$root = "D:\development\wellengineered-us\siobhan"

$replace_map = @()


$replace_item = @{}
$replace_item += @{'Old' = 'WellEngineered.Ninnel'}
$replace_item += @{'New' = 'WellEngineered.Siobhan'}

$replace_map += $replace_item


$replace_item = @{}
$replace_item += @{'Old' = 'Ninnel'}
$replace_item += @{'New' = 'Siobhan'}

$replace_map += $replace_item


$replace_item = @{}
$replace_item += @{'Old' = 'ninnel'}
$replace_item += @{'New' = 'siobhan'}

$replace_map += $replace_item


foreach ($replace_item in $replace_map)
{
	$old_value = $replace_item['Old']
	$new_value = $replace_item['New']

	"[DEBUG]: old=" + $old_value + "`r`n[DEBUG]~ new=" + $new_value
}


# container renames
do
{
	$counter = 0

	foreach ($replace_item in $replace_map)
	{
		$old_value = $replace_item['Old']
		$new_value = $replace_item['New']

		"[Container Rename]: old=" + $old_value + "`r`nnew=" + $new_value

		$fs_items = Get-ChildItem $root -Recurse

		foreach ($fs_item in $fs_items)
		{
			$fs_old_item_full_name = $fs_item.FullName

			if($fs_item.PSIsContainer -and $fs_old_item_full_name.IndexOf($old_value) -gt -1)
			{
				$fs_new_item_full_name = $fs_old_item_full_name.Replace($old_value, $new_value)

				"[Container Rename]: from=" + $fs_old_item_full_name + "`r`nto=" + $fs_new_item_full_name

				if (!(Test-Path -Path $fs_new_item_full_name))
				{
					$fs_item.MoveTo($fs_new_item_full_name)
				}

				$counter++
			}
		}
	}
}
while ($counter > 0)

# item renames
do
{
	$counter = 0

	foreach ($replace_item in $replace_map)
	{
		$old_value = $replace_item['Old']
		$new_value = $replace_item['New']

		"[Item Rename]: old=" + $old_value + "`r`nnew=" + $new_value

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
	}
}
while ($counter > 0)


# content renames
$counter = 0

$fs_items = Get-ChildItem $root -Recurse

foreach ($fs_item in $fs_items)
{
	if (-not $fs_item.PSIsContainer)
	{
		$fs_item_extension = $fs_item.Extension
		$fs_item_full_name = $fs_item.FullName

		if ($fs_item_extension -eq ".sln" -or
			$fs_item_extension -eq ".csproj" -or
			$fs_item_extension -eq ".props" -or
			$fs_item_extension -eq ".cs" -or
			$fs_item_extension -eq ".cshtml" -or
			$fs_item_extension -eq ".bat" -or
			$fs_item_extension -eq ".ps1" -or
			$fs_item_extension -eq ".xml" -or
			$fs_item_extension -eq ".sql" -or
			$fs_item_extension -eq ".txt")
		{
			$original_text = [System.IO.File]::ReadAllText($fs_item_full_name)
			$proposed_text = $original_text

			foreach ($replace_item in $replace_map)
			{
				$old_value = $replace_item['Old']
				$new_value = $replace_item['New']

				"[Content Rename]: fn=" + $fs_item_full_name + "old=" + $old_value + "`r`nnew=" + $new_value

				$proposed_text = $proposed_text.Replace($old_value, $new_value)
			}

			if ($proposed_text -ne $original_text)
			{
				if ($fs_item_extension -eq ".cmd" -or $fs_item_extension -eq ".bat")
				{ $proposed_encoding = [System.Text.Encoding]::ASCII }
				else
				{ $proposed_encoding = [System.Text.Encoding]::Unicode }

				$fs_item.IsReadOnly = $false
				[System.IO.File]::WriteAllText($fs_item_full_name, $proposed_text, $proposed_encoding)

				$counter++
			}
		}
	}
}
