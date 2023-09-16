/* ----------------------------------------------------------------------------
Function: KISKA_fnc_timeline_isRunning

Description:
    Checks if a timeline has either fully been complete (_checkForFullCompletion = true) 
     or is simply qued for end at the start of its next event (_checkForFullCompletion = false).

Parameters:
    0: _timelineId <NUMBER> - The id of the timeline to check
    1: _checkForFullCompletion <BOOL> - Check if the timeline's onComplete function has 
        completed and the timeline is fully done.

Returns:
    <BOOL> - The state of the timeline

Examples:
    (begin example)
        private _isRunning = [123,false] call KISKA_fnc_timeline_isRunning;
    (end)

    (begin example)
        private _timelineIsNotComplete = [123,true] call KISKA_fnc_timeline_isRunning;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_timeline_isRunning";

params [
    ["_timelineId","",[""]],
    ["_checkForFullCompletion",true,[true]]
];


if (_checkForFullCompletion) exitWith {
    private _timelineMap = call KISKA_fnc_timeline_getMainMap;
    _timelineId in _timelineMap
};


private _isRunningMap = call KISKA_fnc_timeline_getIsRunningMap;
_isRunningMap getOrDefault [_timelineId,false]
