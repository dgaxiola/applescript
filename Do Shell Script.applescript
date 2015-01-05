-- Do Shell Script
-- Runs a shell script dropped onto it.
on open fileList
	repeat with currentScript in fileList
		set scriptPath to quoted form of POSIX path of (currentScript as alias)
		do shell script scriptPath
	end repeat
end open

on run
	display dialog "To run a shell script, drop one or more files onto this application." buttons "Ok" with icon 0
end run