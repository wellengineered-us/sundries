param
(
    [string]$path = ""
)

$use_diff_mode = $false
$shell = New-Object -COMObject Shell.Application
$root_item = Get-Item $path

$visuals_dir_path = "$root_item\.visuals"

if ($root_item -ne $null)
{
	$root_item_name = $root_item.Name
	$root_item_full_name = $root_item.FullName
	$root_item_exists = $root_item.Exists
	$root_item_is_directory = $root_item.PSIsContainer

	if ($root_item_is_directory -eq $true -and $root_item_exists -eq $true)
	{
		if ((Test-Path $visuals_dir_path -pathType container) -eq $false)
		{ mkdir $visuals_dir_path }

		$child_items = Get-ChildItem $root_item_full_name -Recurse

		if ($child_items -ne $null)
		{
			foreach ($child_item in $child_items)
			{
				$child_item_exists = $child_item.Exists
				$child_item_is_directory = $child_item.PSIsContainer

				$child_item_name = $child_item.Name
				$child_item_full_name = $child_item.FullName
				$child_item_name_rel_root = $child_item_full_name.Replace([string] $root_item_full_name, [string] "")
				$child_item_extension = $child_item.Extension # BUG: .Replace([string] ".", [string] "")

				$child_item_created_utc = $child_item.CreationTimeUtc
				$child_item_accessed_utc = $child_item.LastAccessTimeUtc
				$child_item_modified_utc = $child_item.LastWriteTimeUtc


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


					####################

					if ($shell_file_date_taken -ne $null)
					{
						$viz_date = $shell_file_date_taken;
					}
					else
					{
						$viz_date = $child_item_created_utc
					}

					if ($viz_date -ne $null)
					{
						$viz_dir_path = $visuals_dir_path + "\" + $viz_date.Year.ToString("0000") + "\" + $viz_date.Month.ToString("00") + "\" + $viz_date.Day.ToString("00")
					
						if ((Test-Path $viz_dir_path -pathType container) -eq $false)
						{ mkdir $viz_dir_path }
					}

					$viz_file_name = "$child_item_file_md5_hash.$child_item_extension"
					$viz_file_path = "$viz_dir_path\$viz_file_name"


					if ((Test-Path $viz_file_path -pathType leaf) -eq $false)
					{ Move-Item -Path $child_item_full_name -Destination $viz_file_path }
					else
					{ Remove-Item $child_item_full_name }
				}
				else
				{
					$child_item_file_is_readonly = $null
					$child_item_file_size_bytes = $null
					$child_item_file_md5_hash = $null
					$shell_file_date_taken = $null
				}
			}
		}
	}
}