# Script that synchronizes zlib.
#
# Version: 20150118

Function DownloadFile($Url, $Destination)
{
	$Client = New-Object Net.WebClient
	${Client}.DownloadFile(${Url}, ${Destination})
}

Function ExtractZip($Filename)
{
	# AppVeyor does not seem to support extraction using "native ZIP" so we use 7z instead.
	$SevenZip = "C:\Program Files\7-Zip\7z.exe"

	If (Test-Path ${SevenZip})
	{
		# PowerShell will raise NativeCommandError if 7z writes to stdout or stderr
		# therefore 2>&1 is added and the output is stored in a variable.
		# The leading & and single quotes are necessary to compensate for the spaces in the path.
		$Output = Invoke-Expression -Command "& '${SevenZip}' -y x ${Filename} 2>&1"
	}
	else
	{
		$Shell = New-Object -ComObject Shell.Application
		$Archive = ${Shell}.NameSpace(${Filename})
		$Directory = ${Shell}.Namespace("${pwd}")

		ForEach($FileEntry in ${Archive}.items())
		{
			${Directory}.CopyHere(${FileEntry})
		}
	}
}

$Filename = "${pwd}\zlib128.zip"
$Url = "http://zlib.net/zlib128.zip"
$ExtractedPath = "zlib-1.2.8"
$DestinationPath = "..\zlib"

If (Test-Path ${Filename})
{
	Remove-Item -Path ${Filename} -Force
}
DownloadFile -Url ${Url} -Destination ${Filename}

If (Test-Path ${ExtractedPath})
{
	Remove-Item -Path ${ExtractedPath} -Force -Recurse
}
ExtractZip -Filename ${Filename}

If (Test-Path ${DestinationPath})
{
	Remove-Item -Path ${DestinationPath} -Force -Recurse
}
Move-Item ${ExtractedPath} ${DestinationPath}

