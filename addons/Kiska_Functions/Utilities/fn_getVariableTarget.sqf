/* ----------------------------------------------------------------------------
Function: KISKA_fnc_getVariableTarget

Description:
    Gets a variable from a remote target object, id, or string (uses remoteExec targets)

    Takes a bit of time and therefore needs to be scheduled.

Parameters:
    0: _variableName : <STRING> - The string name of the varaible to get
    1: _namespace : <NAMESPACE, OBJECT, STRING, CONTROL, GROUP, or LOCATION> - The namespace to get the variable from
    2: _defaultValue : <ANY> - If the variable does not exist for the target, what should be returned instead
    3: _target : <NUMBER, OBJECT, or STRING> - Where the _target is local will be where the variable is taken from 
        (the machine to get the variable from)
    4: _awaitParams : <[NUMBER,NUMBER,BOOL]> - How the get from the target should be awaited

        Parameters:
        - 0: <NUMBER> - The sleep time between each check for the variable being received
        - 1: <NUMBER> - The max time to wait for (this is not total game time but time slept)
        - 2: <BOOL> - Whether or not the sleep time should be exponential (double every iteration)


Returns:
    <ANY> - Whatever the variable is, nil otherwise

Examples:
    (begin example)
        [] spawn {
            // need to call for direct return
            private _serversSomeVariable = [
                "someVariable",
                missionNamespace,
                "",
                2
            ] call KISKA_fnc_getVariableTarget;
        };
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_getVariableTarget";

if (!canSuspend) exitWith {
    ["Must be run in scheduled environment",true] call KISKA_fnc_log;
    nil
};

params [
    ["_variableName","",[""]],
    ["_namespace",missionNamespace,[missionNamespace,objNull,"",controlNull,locationNull,grpNull]],
    ["_defaultValue",nil],
    ["_target",2,[123,objNull,""]],
    ["_awaitParams",[],[[]]]
];

if ((_target isEqualType objNull) AND {isNull _target}) exitWith {
    ["_target is null object!"] call KISKA_fnc_log;
    _defaultValue
};

private _targetIsNetId = false;
private _targetsMultipleUsers = false;
private _exitForMultiUserTarget = false;
private _regularMultiplayer = isMultiplayer AND (!isMultiplayerSolo);
if (_regularMultiplayer) then {
    private _targetsMultipleUsers = (_target isEqualType 123) AND {_target <= 0};
    if (_targetsMultipleUsers) exitWith {
        _exitForMultiUserTarget = true;
    };

    private _targetIsString = _target isEqualType "";
    if (!_targetIsString) exitWith {};

    private _targetIsNetId = _targetIsString AND {
            private _split = _target splitString ":";
            private _splitCount = count _split;
            (_splitCount isEqualTo 2) AND {
                private _splitParsed = _split apply {parseNumber _x};
                private _splitCompare = _splitParsed apply {str _x};
                _splitCompare isEqualTo _split
            }
        };

    if (!_targetIsNetId) exitWith {
        _exitForMultiUserTarget = true;
    };
};

if (_exitForMultiUserTarget) exitWith {
    [["_target: ",_target," is invalid as it will be sent to more then one machine!"],true] call KISKA_fnc_log;
    _defaultValue
};

if (_variableName isEqualTo "") exitWith {
    ["_variableName is empty",true] call KISKA_fnc_log;
    _defaultValue
};

_awaitParams params [
    ["_awaitTime",0.05,[123]],
    ["_maxWaitTime",2,[123]],
    ["_exponentialBackOff",false,[true]]
];

// create a unique variable ID for network tranfer
private _messageNumber = missionNamespace getVariable ["KISKA_getVarTargetQueue_count",0];
_messageNumber = _messageNumber + 1;
missionNamespace setVariable ["KISKA_getVarTargetQueue_count",_messageNumber];
private _saveVariable = ["KISKA_GVT",clientOwner,"_",_messageNumber] joinString "";


[_namespace,_variableName,_saveVariable,_defaultValue,clientOwner] remoteExecCall ["KISKA_fnc_getVariableTarget_sendBack",_target];

private _timeWaited = 0;
waitUntil {
    if (_timeWaited >= _maxWaitTime) then {
        [
            [
                "Max wait time of: ",
                _maxWaitTime,
                " for variable ",
                _saveVariable,
                " from target ",
                _target,
                " was exceeded. Exiting with default value: ",
                _defaultValue
            ],
            false
        ] call KISKA_fnc_log;
        breakWith true;
    };

    if (!isNil _saveVariable) exitWith {
        [["Got variable ",_saveVariable," from target ",_target],false] call KISKA_fnc_log;
        true
    };
    
    sleep _awaitTime;
    _timeWaited = _timeWaited + _awaitTime;
    
    if (_exponentialBackOff) then {
        _awaitTime = _awaitTime * 2;
    };

    [["Waiting for variable from target: ",_target],false] call KISKA_fnc_log;
    false
};

private _return = missionNamespace getVariable [_saveVariable,_defaultValue];
missionNamespace setVariable [_saveVariable,nil];


_return
