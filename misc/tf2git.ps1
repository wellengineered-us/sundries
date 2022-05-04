$tf = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"
$git = "git"
$path = ".\TestTFSPathInWorkspace"

$is_stub = $false

$ErrorActionPreference = "Stop"


if ($is_stub -ne $true)
{
	Set-Location $path
	$history = & $tf history . /noprompt /format:brief /recursive
}
else
{
	$history = cat "tfs2git_sample.txt"
}

$history = $history[2..($history.Length - 1)]
$changeset_count = $history.Length

"Changeset count: {0}." -f $changeset_count

if ($is_stub -ne $true)
{
	if (Test-Path '.git')
	{
		Remove-Item '.git' -Recurse -Force
	}

	& $git init
}
else
{
}

$changeset_counter = 0
$changeset_no_match_counter = 0
$changeset_ok_match_counter = 0

$history | Sort-Object -Descending {(++$script:i)} | foreach {
	$changeset_counter += 1

	if ($_ -match "^([0-9 ]{9,9})[ ](.{17,17})[ ]([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4,4})[ ](.*)$")
	{
		$changeset_ok_match_counter += 1
		#"OK match: |" + $matches[1] + "|" + $matches[2] + "|" + $matches[3] + "|" + $matches[4] + "| --> [$changeset_counter]"

		$changeset = [System.Int32]::Parse($matches[1].Trim())
		$user = $matches[2].Trim()
		$date = [System.DateTime]::Parse($matches[3].Trim()).ToString('s')
		$comment = $matches[4].Trim()

		$narrative = "*** Migrated from TFS changeset " + $changeset.ToString("000000000") + " by " + $user + " on " + $date + "...`r`n" + $comment

		if ($is_stub -ne $true)
		{
			if (Test-Path '.commit')
			{
				Remove-Item '.commit'
			}
			
			do
			{
				& $tf get . /noprompt /version:$changeset /recursive /overwrite
				
				"$tf (" + $LastExitCode + "): changeset " + $changeset.ToString("000000000") + " by " + $user + " on " + $date + " --> [$changeset_counter]"
			}
			while ($LastExitCode -ne 0)
			
        	& $git add -A

			"$git add (" + $LastExitCode + "): changeset " + $changeset.ToString("000000000") + " by " + $user + " on " + $date + " --> [$changeset_counter]"
			
			New-Item .commit -type file -value $narrative
			
			& $git commit --date=$date -F .commit
			
			"$git commit (" + $LastExitCode + "): changeset " + $changeset.ToString("000000000") + " by " + $user + " on " + $date + " --> [$changeset_counter]"
			
			if (Test-Path '.commit')
			{
				Remove-Item '.commit'
			}
		}
		else
		{
			$narrative
		}
	}
	else
	{
		$changeset_no_match_counter += 1
		"NO match: " + $_ + " --> [$changeset_counter]"
	}
}

"Changeset counters: all={0};no={1};ok={2}." -f $changeset_counter, $changeset_no_match_counter, $changeset_ok_match_counter
