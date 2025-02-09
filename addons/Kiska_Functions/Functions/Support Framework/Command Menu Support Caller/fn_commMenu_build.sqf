#include "..\..\..\Headers\Support Framework\Command Menu Macros.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_build

Description:
    Creates a showCommandingMenu compatible menu global array to be used with
     KISKA_fnc_commMenu_openTree.

    This will be saved as a missionNamespace global var.

Parameters:
    0: _menuName : <STRING> - The name of the menu global variable
    1: _menuTitle : <STRING> - The title of the menu that will appear when it is openned
    2: _menuParams : <ARRAY> - An array of arrays formatted as:
        
        - 0. <STRING> - The name of the menu option
        - 1. <NUMBER> - The key code for quick menu select (key 1 is code 2, 2 is 3, etc. use 0 for no key)
        - 2. <ANY> - The value to assign to this menu option

Returns:
    <ARRAY> - The created menu array

Examples:
    (begin example)
        _createdMenu = [] call KISKA_fnc_commMenu_build
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_build";

params [
    ["_menuName","",[""]],
    ["_menuTitle","My Menu",[""]],
    ["_menuParams",[],[[]]]
];

if (_menuName isEqualTo "") exitWith {
    ["_menuName is empty string! Exiting..."] call KISKA_fnc_log;
    []
};

if (!isNil _menuName) then {
    [["WARNING: Overwriting ",_menuName," GVAR in missionNamespace!"]] call KISKA_fnc_log;
};

if (_menuParams isEqualTo []) exitWith {
    ["_menuParams is empty array! Exiting..."] call KISKA_fnc_log;
    []
};


private _menuArray = [
    [_menuTitle,false]
];
_menuParams apply {
    STD_LINE(_x select 0,_x select 1,PUSHBACK_AND_PROCEED(_x select 2))
};


SAVE_AND_RETURN
