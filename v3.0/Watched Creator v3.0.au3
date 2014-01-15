#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=C:\Users\Stuart\My Dropbox\YAMJ\Graphics\Logo (New)\YAMJ_Logo.ico
#AutoIt3Wrapper_outfile=Watched Creator v3.0.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=n
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <Debug.au3>
#include <String.au3>
#include <File.au3>

Opt('MustDeclareVars', 1)

Global $gTitle = "Watched Creator v3.0"
Global $gFilesToProcess[1]
Global $gIniFile = "Watched Creator.ini"
Global $gBaseDir
Global $gOutputDir
Global $gCustomOutputDir
Global $gFileTypes
Global $gIncludeBluRay
Global $gIncludeVideoTS

;_DebugSetup($gTitle & " debug")
_Main()
Exit

Func _Main()
	Local $mReturn = True, $mDirectory, $mFilename

	; Read settings file
	iniFileRead()

	; Look for a parameter on the command line to see what directory to use
	If $CmdLine[0] > 0 Then
		; This will overwrite the ini file
		$gBaseDir = $CmdLine[1]
	EndIf

	While $mReturn = True
		Dim $gFilesToProcess[1] ; Clear the array
		$gFilesToProcess[0] = 0

		If StringCompare(StringLeft(@WorkingDir, StringLen($gBaseDir)), $gBaseDir) <> 0 Then
			FileChangeDir($gBaseDir)
		EndIf

		$mDirectory = FileSelectFolder("Select film folder to mark watched", $gBaseDir)
		If $mDirectory = "" Then
			Return
		EndIf

		processDirectory($mDirectory)
		createWatchedFiles()
	WEnd

EndFunc   ;==>_Main

Func processDirectory($lSearchDirectory)
	Dim $lDirArray[1]
	Local $lCurrentDir = @WorkingDir

	;$lDirArray = _FileListToArray($lSearchDirectory)
	;_ArrayDisplay($lDirArray)

	FileChangeDir($lSearchDirectory)
	_DebugOut("Changed directory to " & @WorkingDir)

	$lDirArray = _FileListToArray(@WorkingDir, "*", 2)

	If IsArray($lDirArray) Then
		_DebugOut("Found " & $lDirArray[0] & " directories in " & $lSearchDirectory & " to process")
		;_ArrayDisplay($lDirArray)

		If $lDirArray[0] > 0 Then
			For $lLoop = 1 To $lDirArray[0]
				_DebugOut("Processing directory #" & $lLoop & " of " & $lSearchDirectory & " - >" & $lDirArray[$lLoop] & "<")

				; Check for VIDEO_TS folder and don't process. Add a record if needed
				If StringCompare($lDirArray[$lLoop], "VIDEO_TS", 0) = 0 Then
					_DebugOut("VIDEO_TS Detected: >" & $lSearchDirectory & "\" & $lDirArray[$lLoop] & "<")
					If ($gCustomOutputDir) Then
						_ArrayAdd($gFilesToProcess, $gOutputDir & "\" & $lSearchDirectory)
					Else
						_ArrayAdd($gFilesToProcess, $lCurrentDir & "\" & $lSearchDirectory & "\" & $lSearchDirectory)
					EndIf
					$gFilesToProcess[0] += 1
					ContinueLoop
				EndIf

				If StringCompare($lDirArray[$lLoop], "BDMV") = 0 Then
					_DebugOut("BDMV Detected: >" & $lCurrentDir & "\" & $lDirArray[$lLoop] & "<")
					If ($gCustomOutputDir) Then
						_ArrayAdd($gFilesToProcess, $gOutputDir & "\" & $lSearchDirectory)
					Else
						_ArrayAdd($gFilesToProcess, $lCurrentDir & "\" & $lSearchDirectory & "\" & $lSearchDirectory)
					EndIf
					$gFilesToProcess[0] += 1
					ContinueLoop
				EndIf

				processDirectory($lDirArray[$lLoop])
			Next
		EndIf
	EndIf

	_DebugOut("Check for directories in " & $lSearchDirectory & " done, now checking for files")

	For $lLoop = 0 To UBound($gFileTypes) - 1
		processFiles(@WorkingDir, "*." & $gFileTypes[$lLoop])
	Next

	FileChangeDir($lCurrentDir)
	Return

EndFunc   ;==>processDirectory

Func processFiles($lSearchDirectory, $lFilter)
	Local $lDirArray = _FileListToArray($lSearchDirectory, $lFilter, 1)

	_DebugOut("Processing " & $lSearchDirectory & " for " & $lFilter & " files")

	If IsArray($lDirArray) Then
		;_ArrayDisplay($lDirArray, $lSearchDirectory & "\" & $lFilter)
		For $lLoop = 1 To $lDirArray[0]
			_DebugOut("Found file >" & $lSearchDirectory & "\" & $lDirArray[$lLoop] & "<")
			_DebugOut($gCustomOutputDir & "-" & $gOutputDir)
			If ($gCustomOutputDir) Then
				_DebugOut("Custom dir")
				_ArrayAdd($gFilesToProcess, $gOutputDir & "\" & $lDirArray[$lLoop])
			Else
				_DebugOut("Standard dir")
				_ArrayAdd($gFilesToProcess, $lSearchDirectory & "\" & $lDirArray[$lLoop])
			EndIf
		Next
		$gFilesToProcess[0] += $lDirArray[0]
	EndIf
EndFunc   ;==>processFiles

Func createWatchedFiles()
	Local $lAnswer, $lOutput = "", $lMaxOutput

	If $gFilesToProcess[0] = 0 Then
		Return
		Return
	EndIf

	If ($gFilesToProcess[0] > 5) Then
		$lMaxOutput = 5;
	Else
		$lMaxOutput = $gFilesToProcess[0]
	EndIf

	For $lLoop = 1 To $lMaxOutput
		$lOutput = $lOutput & $lLoop & ") " & $gFilesToProcess[$lLoop] & @CRLF
	Next

	If ($gFilesToProcess[0] > 5) Then
		$lMaxOutput = $gFilesToProcess[0] - 5
		$lOutput = $lOutput & @CRLF & "There are " & $lMaxOutput & " other watched files to create" & @CRLF
	EndIf

	$lAnswer = MsgBox(3 + 32, $gTitle, "Do you want to create watched files for the following video files? " & @CRLF & $lOutput)
	If $lAnswer <> 6 Then
		Return
	EndIf

	;_ArrayDisplay($gFilesToProcess, "Files to process")

	If $gCustomOutputDir Then
		_DebugOut("Creating output directory >" & $gOutputDir & "<")
		DirCreate($gOutputDir)
	EndIf

	For $lLoop = 1 To $gFilesToProcess[0]
		_DebugOut("Created watched file: " & $gFilesToProcess[$lLoop] & ".watched")
		FileWriteLine($gFilesToProcess[$lLoop] & ".watched", "Watched file for " & $gFilesToProcess[$lLoop])
	Next

	;MsgBox(0, $gTitle, "Created watched files for: " & @CRLF & $lOutput)
EndFunc   ;==>createWatchedFiles

Func iniFileWrite()
	FileWriteLine($gIniFile, "****************************************")
	FileWriteLine($gIniFile, "*** Omertron's Watch File Creator")
	FileWriteLine($gIniFile, "*** For use with YAMJ")
	FileWriteLine($gIniFile, "****************************************")

	IniWrite($gIniFile, "Settings", "StartDir", "T:\Films\")
	IniWrite($gIniFile, "Settings", "FileTypes", "AVI,MKV,MPG,ISO")
	IniWrite($gIniFile, "Settings", "IncludeBluRay", "True")
	IniWrite($gIniFile, "Settings", "IncludeVideoTS", "True")
	IniWrite($gIniFile, "Settings", "CustomOutputDir", "False")
	IniWrite($gIniFile, "Settings", "OutputDir", "T:\Jukebox\Watched")

EndFunc   ;==>iniFileWrite

Func iniFileRead()
	If Not FileExists($gIniFile) Then
		iniFileWrite()
	EndIf

	Local $lFileList, $lTemp

	$gBaseDir = IniRead($gIniFile, "Settings", "StartDir", "T:\Films\")
	$lFileList = IniRead($gIniFile, "Settings", "FileTypes", "AVI,MKV,MPG,ISO")
	$gIncludeBluRay = parseBoolean(IniRead($gIniFile, "Settings", "IncludeBluRay", "True"))
	$gIncludeVideoTS = parseBoolean(IniRead($gIniFile, "Settings", "IncludeVideoTS", "True"))
	$gCustomOutputDir = parseBoolean(IniRead($gIniFile, "Settings", "CustomOutputDir", "False"))
	$gOutputDir = IniRead($gIniFile, "Settings", "OutputDir", "T:\Jukebox\Watched")

	_DebugOut("Base Dir  : " & $gBaseDir)
	_DebugOut("File Types: " & $lFileList)
	_DebugOut("BluRay    : " & $gIncludeBluRay)
	_DebugOut("VideoTS   : " & $gIncludeVideoTS)
	_DebugOut("Custom Dir: " & $gCustomOutputDir)
	_DebugOut("Output Dir: " & $gOutputDir)

	$gFileTypes = _StringExplode($lFileList, ",")

EndFunc   ;==>iniFileRead

Func parseBoolean($lTest)
	If (StringCompare("true", $lTest, 2) = 0) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>parseBoolean
