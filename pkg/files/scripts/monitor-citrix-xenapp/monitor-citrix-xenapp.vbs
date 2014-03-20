'On Error Resume Next

Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20

Set objWSH =  CreateObject("WScript.Shell")
Set WshSysEnv = objWSH.Environment("Process") 

strHostname = WshSysEnv("UPTIME_HOSTNAME")
strDomain = WshSysEnv("UPTIME_DOMAIN")
strUser = WshSysEnv("UPTIME_USERNAME")
strPassword = WshSysEnv("UPTIME_PASSWORD")

'WScript.Echo strHostname
'WScript.Echo strDomain
'WScript.Echo strUser
'WScript.Echo strPassword

strDUser = strDomain & "\" & strUser

currentDirectory = left(WScript.ScriptFullName,(Len(WScript.ScriptFullName))-(len(WScript.ScriptName)))
strCmdLine = currentDirectory & "XenAppLogin.exe " & strHostname & " " & strDomain & " " & strUser & " " & strPassword & " 30"
'WScript.Echo strCmdLine

Set objShell = WScript.CreateObject("WScript.Shell")
Set oExec = objShell.Exec(strCmdLine )

' possible values for strXenAppLoginResult are: ConnectionEstablished False OR ConnectionEstablished True
strXenAppLoginResult = oExec.StdOut.ReadLine
intCompare = StrComp(strXenAppLoginResult, "ConnectionEstablished True", vbTextCompare)

'WScript.Echo strXenAppLoginResult
'WScript.Echo intCompare

' can connect to XenApp so continue
If intCompare = 0 Then
	Set objSWbemLocator = CreateObject("WbemScripting.SWbemLocator")
	Set objSWbemServices = objSWbemLocator.ConnectServer(strHostname, "\root\CIMV2", strDUser, strPassword, "MS_409")
	objSWbemServices.Security_.ImpersonationLevel = 3
	
	Set colItems = objSWbemServices.ExecQuery("SELECT * FROM Win32_PerfFormattedData_MetaFrameXP_CitrixMetaFramePresentationServer", "WQL", _
										  wbemFlagReturnImmediately + wbemFlagForwardOnly)
	For Each objItem In colItems
		WScript.Echo "ApplicationResolutionTimems " & objItem.ApplicationResolutionTimems
		WScript.Echo "ApplicationResolutionsPersec " & objItem.ApplicationResolutionsPersec
		WScript.Echo "ApplicationEnumerationsPersec " & objItem.ApplicationEnumerationsPersec
		WScript.Echo "FilteredApplicationEnumerationsPersec " & objItem.FilteredApplicationEnumerationsPersec
		WScript.Echo "DataStoreConnectionFailure " & objItem.DataStoreConnectionFailure
		WScript.Echo "NumberofbusyXMLthreads " & objItem.NumberofbusyXMLthreads
		WScript.Echo "ResolutionWorkItemQueueReadyCount " & objItem.ResolutionWorkItemQueueReadyCount
		WScript.Echo "WorkItemQueueReadyCount " & objItem.WorkItemQueueReadyCount
	Next

	Set colItems = objSWbemServices.ExecQuery("SELECT * FROM Win32_PerfFormattedData_ASPNET_ASPNET", "WQL", _
										  wbemFlagReturnImmediately + wbemFlagForwardOnly)
	For Each objItem In colItems
		WScript.Echo "RequestsQueued " & objItem.RequestsQueued
		WScript.Echo "RequestsRejected " & objItem.RequestsRejected
		WScript.Echo "RequestsCurrent " & objItem.RequestsCurrent
		WScript.Echo "RequestExecutionTime " & objItem.RequestExecutionTime
	Next

	Set colItems = objSWbemServices.ExecQuery("SELECT * FROM Win32_TerminalService", "WQL", _
										  wbemFlagReturnImmediately + wbemFlagForwardOnly)
	For Each objItem In colItems
		WScript.Echo "DisconnectedSessions " & objItem.DisconnectedSessions
		WScript.Echo "TotalSessions " & objItem.TotalSessions
	Next
Else
	WScript.Echo "ConnectionEstablished False"
	Wscript.Quit 2
End If
