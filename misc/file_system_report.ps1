param
(
    [string]$path = ""
)

$use_diff_mode = $false
$shell = New-Object -COMObject Shell.Application
$root_item = Get-Item $path

if ($root_item -ne $null)
{
	$root_item_name = $root_item.Name
	$root_item_full_name = $root_item.FullName
	$root_item_exists = $root_item.Exists
	$root_item_is_directory = $root_item.PSIsContainer

	if ($root_item_is_directory -eq $true -and $root_item_exists -eq $true)
	{
		$child_items = Get-ChildItem $root_item_full_name -Recurse

		if ($child_items -ne $null)
		{
			$output = ""

			$output += "ITEM_EXISTS`t"
			$output += "IS_DIRECTORY`t"

			$output += "ITEM_NAME`t"
			$output += "ITEM_FULL_NAME`t"
			$output += "ITEM_NAME_REL_ROOT`t"
			$output += "ITEM_EXTENSION`t"

			$output += "ITEM_CREATED_UTC`t"
			$output += "ITEM_ACCESSED_UTC`t"
			$output += "ITEM_MODIFIED_UTC`t"

			$output += "PARENT_NAME`t"
			$output += "PARENT_FULL_NAME`t"
			$output += "PARENT_NAME_REL_ROOT`t"

			$output += "FILE_IS_READONLY`t"
			$output += "FILE_SIZE_BYTES`t"
			$output += "FILE_MD5_HASH`t"

			$output += "FILE_DATE_TAKEN"

			"$output"

			foreach ($child_item in $child_items)
			{
				$child_item_exists = $child_item.Exists
				$child_item_is_directory = $child_item.PSIsContainer

				$child_item_name = $child_item.Name
				$child_item_full_name = $child_item.FullName
				$child_item_name_rel_root = $child_item_full_name.Replace([string] $root_item_full_name, [string] "")
				$child_item_extension = $child_item.Extension

				$child_item_created_utc = $child_item.CreationTimeUtc.ToString("O")
				$child_item_accessed_utc = $child_item.LastAccessTimeUtc.ToString("O")
				$child_item_modified_utc = $child_item.LastWriteTimeUtc.ToString("O")


				if ($child_item_is_directory -eq $true)
				{
					$child_item_is_parent_directory = $child_item.Parent
				}
				else
				{
					$child_item_is_parent_directory = $child_item.Directory
				}
				

				if ($child_item_is_parent_directory -ne $null)
				{
					$child_item_parent_name = $child_item_is_parent_directory.Name
					$child_item_parent_full_name = $child_item_is_parent_directory.FullName
					$child_item_parent_name_rel_root = $child_item_parent_full_name.Replace([string] $root_item_full_name, [string] "")
				}
				else
				{
					$child_item_parent_name = $null
					$child_item_parent_full_name = $null
					$child_item_parent_name_rel_root = $null
				}
				
				if ($child_item_is_directory -eq $false)
				{
					$child_item_file_is_readonly = $child_item.IsReadOnly
					$child_item_file_size_bytes = $child_item.Length
					$child_item_file_md5_hash = (Get-FileHash "$child_item_full_name" -Algorithm MD5).Hash


					$shell_folder = $shell.Namespace($child_item_parent_full_name)
					$shell_file = $shell_folder.ParseName($child_item_name)
					$com_date = $shell_folder.GetDetailsOf($shell_file, 12) -replace [char]8206 -replace [char]8207

					if ($com_date -ne $null)
					{
						try
						{
							$shell_file_date_taken = [DateTime]::ParseExact($com_date, "g", $null)
							$shell_file_date_taken = $shell_file_date_taken.ToString("O")
						}
						catch
						{
							$shell_file_date_taken = $null
						}
					}
					else
					{
						$shell_file_date_taken = $null
					}
				}
				else
				{
					$child_item_file_is_readonly = $null
					$child_item_file_size_bytes = $null
					$child_item_file_md5_hash = $null
					$shell_file_date_taken = $null
				}

				$output = ""

				$output += "$child_item_exists`t"
				$output += "$child_item_is_directory`t"

				$output += "$child_item_name`t"
				$output += "$child_item_full_name`t"
				$output += "$child_item_name_rel_root`t"
				$output += "$child_item_extension`t"

				$output += "$child_item_created_utc`t"
				$output += "$child_item_accessed_utc`t"
				$output += "$child_item_modified_utc`t"

				$output += "$child_item_parent_name`t"
				$output += "$child_item_parent_full_name`t"
				$output += "$child_item_parent_name_rel_root`t"

				$output += "$child_item_file_is_readonly`t"
				$output += "$child_item_file_size_bytes`t"
				$output += "$child_item_file_md5_hash`t"

				$output += "$shell_file_date_taken"

				"$output"
			}
		}
	}
}