/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_openTree

Description:
    Opens a command menu tree dynamically instead of needing to define sub menus.

    Such as one built with `KISKA_fnc_commMenu_build`.

Parameters:
    0: _menuPath <ARRAY> - The menu global variable paths (in order)
    1: _endExpression <STRING, CODE, or ARRAY> - The code to be executed at the end of the path.
        It receives all menu parameters in _this. (see KISKA_fnc_callBack)
    2: _exitExpression <STRING, CODE, or ARRAY> - The code to be executed in the event that
        the menu is closed by the player. It gets all added params up to that point in _this.
        (see KISKA_fnc_callBack)

Returns:
    NOTHING

Examples:
    (begin example)
        [
            ["#USER:myMenu_1","#USER:myMenu_2"],
            "hint str _this"
        ] spawn KISKA_fnc_commMenu_openTree
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_openTree";

if (!hasInterface) exitWith {
    ["Can only run on machines with interface",false] call KISKA_fnc_log;
    nil
};

if (!canSuspend) exitWith {
    ["Must be run in scheduled, exiting to scheduled",true] call KISKA_fnc_log;
    _this spawn KISKA_fnc_commMenu_openTree;
};

params [
    ["_menuPath",[],[[]]],
    ["_endExpression","",["",{},[]]],
    ["_exitExpression","",["",{},[]]]
];

// create a container for holding params from menu
localNamespace setVariable ["KISKA_commMenuTree_params",[]];

private _menuWasClosed = false;
_menuPath apply {
    // proceed immediatetly if only one option is in custom menu
    private _menuName = toLower _x;

    // #user: prepended on the menu name denotes a custom menu
    // The menu options are saved to a global variable in the missionNamespace
    /// that is the menu's name, minus the "#user:"
    /// e.g. a menu with the name "#USER:MY_SUBMENU_inCommunication" would be
    /// saved to a global variable MY_SUBMENU_inCommunication
    _menuName = _menuName trim ["#user:",1];
    if (_menuName != _x) then {
        private _menuOptions = missionNamespace getVariable [_menuName,[]];
        // _menuOptions will include the title at the start of the array, therefore, multiple actual options means at least 3 entries
        if (count _menuOptions < 3) then {
            // format of an option
            // ["Submenu", [3], "#USER:MY_SUBMENU_inCommunication", -5, [["expression", "player sidechat ""Submenu"" "]], "1", "1"]
            private _singleMenuOption = _menuOptions select 1;
            private _expression = ((_singleMenuOption select 4) select 0) select 1;
            [] call (compile _expression);

            continue;
        };
    };

    // keeps track of whether or not to open the next menu
    localNamespace setVariable ["KISKA_commMenuTree_proceedToNextMenu",false];
    showCommandingMenu _x;
    // wait for player to select and option from the current menu or for them to close the menu
    waitUntil {
        if (localNamespace getVariable "KISKA_commMenuTree_proceedToNextMenu") exitWith {true};
        _menuWasClosed = commandingMenu isEqualTo "";
        _menuWasClosed
    };
    if (_menuWasClosed) then {break};
};

private _params = localNamespace getVariable "KISKA_commMenuTree_params";
private "_expression";
if (_menuWasClosed) then {
    _expression = _exitExpression;
} else {
    _expression = _endExpression;
};

[_params, _expression] call KISKA_fnc_callBack;


localNamespace setVariable ["KISKA_commMenuTree_params",nil];
localNamespace setVariable ["KISKA_commMenuTree_proceedToNextMenu",nil];
