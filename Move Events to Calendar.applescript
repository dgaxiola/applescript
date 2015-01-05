# Move Events to Calendar
# David Gaxiola
#
# Simple script to move events from multiple calendars into a target calendar.
# Change targetCalendar and sourcePrefix in the on run handler to 
# what fits your situation.
#
# When running this, I would occassionally get duplicate entries in 
# the set of returned events. These may apear as the same first or 
# last event or they may be adjecent in order they are returned.  
# I don't believe there's any issue with my logic but it seems odd 
# that Calendar would behave this way.
# 

# toString
# Originally from stackoverflow.com user mklement0.
#
# Converts the specified object - which may be of any type - into a string representation for logging/debugging.
# Tries hard to find a readable representation - sadly, simple conversion with `as text` mostly doesn't work with non-primitive types.
# An attempt is made to list the properties of non-primitive types (does not always work), and the result is prefixed with the type (class) name
# and, if present, the object's name and ID.
# EXAMPLE
#       toString(path to desktop)  # -> "[alias] Macintosh HD:Users:mklement:Desktop:"
# To test this subroutine and see the various representations, use the following:
#   repeat with elem in {42, 3.14, "two", true, (current date), {"one", "two", "three"}, {one:1, two:"deux", three:false}, missing value, me,  path to desktop, front window of application (path to frontmost application as text)}
#       log my toString(contents of elem)
#   end repeat
on toString(anyObj)
	local i, txt, errMsg, orgTids, oName, oId, prefix
	set txt to ""
	repeat with i from 1 to 2
		try
			if i is 1 then
				if class of anyObj is list then
					set {orgTids, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {", "}}
					set txt to ("{" & anyObj as string) & "}"
					set AppleScript's text item delimiters to orgTids # '
				else
					set txt to anyObj as string
				end if
			else
				set txt to properties of anyObj as string
			end if
		on error errMsg
			# Trick for records and record-*like* objects:
			# We exploit the fact that the error message contains the desired string representation of the record, so we extract it from there. This (still) works as of AS 2.3 (OS X 10.9).
			try
				set txt to do shell script "egrep -o '\\{.*\\}' <<< " & quoted form of errMsg
			end try
		end try
		if txt is not "" then exit repeat
	end repeat
	set prefix to ""
	if class of anyObj is not in {text, integer, real, boolean, date, list, record} and anyObj is not missing value then
		set prefix to "[" & class of anyObj
		set oName to ""
		set oId to ""
		try
			set oName to name of anyObj
			if oName is not missing value then set prefix to prefix & " name=\"" & oName & "\""
		end try
		try
			set oId to id of anyObj
			if oId is not missing value then set prefix to prefix & " id=" & oId
		end try
		set prefix to prefix & "] "
	end if
	return prefix & txt
end toString

# extractEventProperties
#
# Creates a new record containing the properties of the
# passed in Calendar Event.  If a property has missing value,
# it will not be included in the returned record.
on extractEventProperties(sourceEvent)
	tell application "Calendar"
		
		# AppleScript doesn't handle marshaling of missing values into text.
		# This is a problem if we create a new event with "missing value" 
		# for some of the properties. As a workaround, we need to manually check 
		# fields and just include those with an actual value. This seemed 
		# to be the most elegant way after some investigation but the code 
		# still looks clunky.
		
		set targetProps to {}
		
		if exists description of sourceEvent then
			set targetProps to targetProps & {description:(description of sourceEvent)}
		end if
		
		if exists summary of sourceEvent then
			set targetProps to targetProps & {summary:(summary of sourceEvent)}
		end if
		
		if exists location of sourceEvent then
			set targetProps to targetProps & {location:(location of sourceEvent)}
		end if
		
		if exists url of sourceEvent then
			set targetProps to targetProps & {url:(url of sourceEvent)}
		end if
		
		if exists (start date of sourceEvent) then
			set targetProps to targetProps & {start date:(start date of sourceEvent)}
		end if
		
		if exists (end date of sourceEvent) then
			set targetProps to targetProps & {end date:(end date of sourceEvent)}
		end if
		
		if exists (allday event of sourceEvent) then
			set targetProps to targetProps & {allday event:(allday event of sourceEvent)}
		end if
		
		if exists recurrence of sourceEvent then
			set targetProps to targetProps & {recurrence:(recurrence of sourceEvent)}
		end if
		
		if exists (excluded dates of sourceEvent) then
			set targetProps to targetProps & {excluded dates:(excluded dates of sourceEvent)}
		end if
		
		if exists status of sourceEvent then
			set targetProps to targetProps & {status:(status of sourceEvent)}
		end if
		
	end tell
	
	return targetProps
end extractEventProperties

# eventPropertiesToString
#
# Generates a string representation of the provided
# Calendar Event for debugging purposes.
on eventPropertiesToString(sourceEvent)
	set eventAsStr to "{ "
	
	# The toString handler above will output a string representation 
	# of the event but we'll only get class object names for the 
	# record keys. For debugging, it's better to manually build the
	# string version of the Calendar Event.
	
	tell application "Calendar"
		if exists summary of sourceEvent then
			set eventAsStr to eventAsStr & "summary:\"" & my toString(summary of sourceEvent) & "\""
		end if
		
		if exists description of sourceEvent then
			set eventAsStr to eventAsStr & " , description:\"" & my toString(description of sourceEvent) & "\""
		end if
		
		if exists location of sourceEvent then
			set eventAsStr to eventAsStr & ", location:\"" & my toString(location of sourceEvent) & "\""
		end if
		
		if exists url of sourceEvent then
			set eventAsStr to eventAsStr & ", url:\"" & my toString(url of sourceEvent) & "\""
		end if
		
		if exists (start date of sourceEvent) then
			set eventAsStr to eventAsStr & ", start date:" & my toString(start date of sourceEvent)
		end if
		
		if exists (end date of sourceEvent) then
			set eventAsStr to eventAsStr & ", end date:" & my toString(end date of sourceEvent)
		end if
		
		if exists (allday event of sourceEvent) then
			set eventAsStr to eventAsStr & ", allday event:" & my toString(allday event of sourceEvent)
		end if
		
		if exists recurrence of sourceEvent then
			set eventAsStr to eventAsStr & ", recurrence:\"" & my toString(recurrence of sourceEvent) & "\""
		end if
		
		if exists (excluded dates of sourceEvent) then
			set eventAsStr to eventAsStr & ", excluded dates:" & my toString(excluded dates of sourceEvent)
		end if
		
		if exists status of sourceEvent then
			set eventAsStr to eventAsStr & ", status:" & my toString(status of sourceEvent)
		end if
		
	end tell
	
	set eventAsStr to eventAsStr & " }"
	
	return eventAsStr
end eventPropertiesToString

# Main Entry Point
on run
	tell application "Calendar"
		activate
		set processedCount to 0
		set errorCount to 0
		set targetCalendar to "SDCC"
		set sourcePrefix to "CC - "
		set sourceCalendars to every calendar whose name starts with sourcePrefix
		# Getting an event by index is the most reliable way 
		# but we can't delete the events in progress until everything is moved over.
		# So, we loop through once to duplicate the events and then 
		# do a pass of all the events we duplicated to remove them.
		repeat with myCalendar in sourceCalendars
			set eventCount to (count of events in myCalendar)
			set eventDeletionList to {}
			log ("Working on " & eventCount & " events in calendar " & (name of myCalendar))
			set eventCount to eventCount - 1
			repeat with myIndex from 0 to eventCount
				set myEvent to event myIndex of myCalendar
				set myProps to properties of myEvent
				try
					set myEventDesc to (my toString(summary of myProps) & " in calendar " & (name of myCalendar))
					# Duplicating an event doesn't seem to work reliably so
					# we need to extract the details and create a new event.
					set extractedProps to my extractEventProperties(myEvent)
					make new event at the end of events of calendar targetCalendar with properties extractedProps
					set eventDeletionList to eventDeletionList & {myEvent}
					log ("  Duplicated event #" & myIndex & ": " & myEventDesc & " to " & targetCalendar)
				on error errMsg number errNumber
					set errorCount to (errorCount + 1)
					log ("  Problem with duplicating event #" & myIndex & ": " & myEventDesc & ": " & errNumber & " - " & errMsg)
				end try
			end repeat
			
			log ("Deleting " & (count of eventDeletionList) & " events in calendar " & (name of myCalendar))
			set deletedEventIndex to 0
			repeat with myEventToDelete in eventDeletionList
				set deletedEventName to "not defined"
				try
					set deletedEventName to my toString(summary of myEventToDelete)
					delete myEventToDelete
					set processedCount to (processedCount + 1)
					log ("  Deleted event #" & deletedEventIndex & ": " & deletedEventName)
				on error errMsg number errNumber
					set errorCount to (errorCount + 1)
					log ("  Problem deleting event #" & deletedEventIndex & ": " & deletedEventName & ": " & errNumber & " - " & errMsg)
				end try
			end repeat
		end repeat
		log ("----")
		log ("Moved " & processedCount & " events")
		log ("Errors encounted with " & errorCount & " events")
	end tell
end run