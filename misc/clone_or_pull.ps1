#
#	Copyright ©2020-2021 WellEngineered.us, all rights reserved.
#	Distributed under the MIT license: https://opensource.org/licenses/MIT
#

cls

$git_host = "github.com"
$org_repo_map = @{}

$org_repo_map.Add('wellengineered-us', @('keymaps', 'cruisecontrol', 'sundries', 'solder', 'siobhan', 'ninnel', 'textmetal'))

foreach ($org in $org_repo_map.Keys)
{
	$org_path = ".\$org"

	if ((Test-Path $org_path -pathType container) -eq $false)
	{ mkdir $org_path }

	Push-Location -Path $org_path

	foreach ($repo in $org_repo_map[$org])
	{
		$repo_path = "$repo"
		$dotgit_path = "$repo_path\.git"

		$url = "https://" + $git_host + "/" + $org + "/" + $repo + ".git"

		if ((Test-Path $repo_path -pathType container) -eq $false -or
			(Test-Path $dotgit_path -pathType container) -eq $false)
		{ git clone $url }
		else
		{
			Push-Location -Path $repo_path
			git pull
			Pop-Location
		}
	}

	Pop-Location
}

echo("The operation completed successfully.")