#
#	Copyright ©2020-2021 WellEngineered.us, all rights reserved.
#	Distributed under the MIT license: https://opensource.org/licenses/MIT
#

cls

get-childitem "*.m4a" -recurse | sort | foreach {
	$algorithm = "MD5"
	$old_path = $_.Fullname
	$file_hash = (Get-FileHash "$old_path" -Algorithm "$algorithm").Hash
	$new_path = $_.Directory.FullName +"\$algorithm(" + $file_hash + ")" + $_.Extension
	
	echo "$old_path => $new_path"

	Move-Item -Path $old_path -Destination $new_path
}