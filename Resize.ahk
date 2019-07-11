#SingleInstance, Force
^!LButton::

;; Set coordinate mode to absolute
CoordMode, Mouse, Screen

;; Get the active window
WinGetActiveTitle, windowTitle

;; Create global dimensions
dimensions := {}

;; Instantiate the GUI
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, 0277D4
WinSet, Transparent, 125

;; Get starting mouse position
startingMousePosition := GetMousePosition()

;; Show the GUI
Update()

SetTimer, Update, 50
return

^!LButton UP::
SetTimer, Update, off
Gui Destroy
MoveWindow()
return

Update:
Update()
return

DetermineGrid(startPosition, endPosition, widthStep, heightStep)
{
	x := Floor(startPosition.x / widthStep) * widthStep
	y := Floor(startPosition.y / heightStep) * heightStep

	w := (Floor((endPosition.x - x) / widthStep) + 1) * widthStep
	h := (Floor((endPosition.y - y) / heightStep) + 1) * heightStep

	return {"x": x, "y": y, "w": w, "h": h}
}

Update()
{
	global startingMousePosition
	;; Get screen dimensions and grid steps
	monitorNumber := GetMouseScreenNumber()
	SysGet, screenSize, MonitorWorkArea, %monitorNumber%
	widthStep := (screenSizeRight - screenSizeLeft) / 8
	heightStep := (screenSizeBottom - screenSizeTop) / 8

	;; Get the dimensions of the grid to cover
	global dimensions := DetermineGrid(startingMousePosition, GetMousePosition(), widthStep, heightStep)

	;; Check that the left mouse button is down
	if (GetKeyState("LButton", "P") == "0")
	{
		;; Mouse button has been released, so move the window
		MoveWindow()
	}
	
	Gui, Show, % "x" . dimensions.x . " y" . dimensions.y . " W" . dimensions.w . " H" . dimensions.h
	return
}

MoveWindow()
{
	global windowTitle
	global dimensions

	WinMove, % windowTitle, , dimensions.x - 7, dimensions.y, dimensions.w + 14, dimensions.h + 8
	Exit
}

GetMousePosition()
{
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX, mouseY
	return {"x": mouseX, "y": mouseY}
}

GetMouseScreenNumber()
{
	;; Get mouse position
	mouse := GetMousePosition()

	;; Get the monitor the mouse is on
	MonitorNumber := 1
	Loop {
		;; Get monitor size
		SysGet, Mon, Monitor, %MonitorNumber%

		;; If the mouse is within those bounds, return this monitor number
		if (mouse.x > MonLeft && mouse.x <= MonRight && mouse.y > MonTop && mouse.y <= MonBottom) {
			return MonitorNumber
		}

		;; Increment to the next monitor
		MonitorNumber++
	}
}