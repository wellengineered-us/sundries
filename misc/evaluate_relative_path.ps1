#
#	Copyright ©2020-2021 WellEngineered.us, all rights reserved.
#	Distributed under the MIT license: http://www.opensource.org/licenses/mit-license.php
#

function EvaluateRelativePath($mainDirPath, $absoluteFilePath)
{
	$firstPathParts = $mainDirPath.Trim([System.IO.Path]::DirectorySeparatorChar).Split([System.IO.Path]::DirectorySeparatorChar)
	$secondPathParts = $absoluteFilePath.Trim([System.IO.Path]::DirectorySeparatorChar).Split([System.IO.Path]::DirectorySeparatorChar)
	$sameCounter = 0

	for ($i = 0; $i -lt [System.Math]::Min($firstPathParts.Length, $secondPathParts.Length); $i++)
	{
		if (-not $firstPathParts[$i].ToLower().Equals($secondPathParts[$i].ToLower()))
		{
			break
		}

		$sameCounter++
	}

	if ($sameCounter -eq 0)
	{
		return $absoluteFilePath
	}

	$newPath = ""

	for ($i = $sameCounter; $i -lt $firstPathParts.Length; $i++)
	{
		if ($i -gt $sameCounter)
		{
			$newPath += [System.IO.Path]::DirectorySeparatorChar
		}

		$newPath += ".."
	}

	if ($newPath.Length -eq 0)
	{
		$newPath = "."
	}

	for ($i = $sameCounter; $i -lt $secondPathParts.Length; $i++)
	{
		$newPath += [System.IO.Path]::DirectorySeparatorChar
		$newPath += $secondPathParts[$i]
	}

	return $newPath	
}

function EvaluateRelativePath2($mainDirPath, $absoluteFilePath)
{
	$p = EvaluateRelativePath -mainDirPath $mainDirPath -absoluteFilePath $absoluteFilePath

	if ($p.StartsWith(".\") -eq $true)
	{
		$p = $p.Substring(2)
	}

	return $p
}

# main()

cls

if($args.Length -eq 1)
{
	$searchpath = "."
	$searchpattern = $args[0]
	$searchoption = [System.IO.SearchOption]::AllDirectories.ToString()
	$relativetodir = "."
}
elseif($args.Length -eq 4)
{
	$searchpath = $args[0]
	$searchpattern = $args[1]
	$searchoption = $args[2]
	$relativetodir = $args[3]
}
else
{ exit -1 }

# canonicalize
$searchpath = [System.IO.Path]::GetFullPath($searchpath)
$searchpattern = $searchpattern
$searchoption = [Enum]::Parse([System.IO.SearchOption], $searchoption)
$relativetodir = [System.IO.Path]::GetFullPath($relativetodir)

$fileNames = [System.IO.Directory]::GetFiles($searchpath, $searchpattern, $searchoption)

foreach ($fileName in $fileNames)
{
	$fileName = [System.IO.Path]::GetFullPath($fileName)
	$fileName = EvaluateRelativePath2 -mainDirPath $relativetodir -absoluteFilePath $fileName
	"*" + $fileName
}

$directoryNames = [System.IO.Directory]::GetDirectories($searchpath, $searchpattern, $searchoption)

foreach ($directoryName in $directoryNames)
{
	$directoryName = [System.IO.Path]::GetFullPath($directoryName)
	$directoryName = EvaluateRelativePath2 -mainDirPath $relativetodir -absoluteFilePath $directoryName
	":" + $directoryName
}

