#include "..\..\..\Headers\Support Framework\Command Menu Macros.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_buildVehicleSelectPanel

Description:
    Creates an array to be used with showCommandingMenu.
    Specifically, this is to provide class names to the command menu and then
     allow a player to select a class from the menu such as when requesting CAS.

Parameters:
    0: _classes : <STRING[]> - The class names to add to the list (in the order to appear)

Returns:
    <ARRAY> - The created array

Examples:
    (begin example)
        _menuArray = [
            ["B_Heli_Transport_01_F","B_Heli_Attack_01_dynamicLoadout_F"]
        ] call KISKA_fnc_createClassSelectMenu;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_buildVehicleSelectPanel";

#define CLASS_ARRAY(DISPLAY_NAME,CLASS) [DISPLAY_NAME,[0],"",CMD_EXECUTE,[["expression", PUSHBACK_AND_PROCEED(CLASS)]], IS_ACTIVE, IS_VISIBLE]

params ["_classes"];

if (_classes isEqualTo []) exitWith {
    ["_classes is empty array",true] call KISKA_fnc_log;
    []
};

private _formattedArray = [
    ["Vehicle Selection",false]
];
private "_displayName";
_classes apply {
    _displayName = [configFile >> "cfgVehicles" >> _x] call BIS_fnc_displayName;
    _formattedArray pushBack CLASS_ARRAY(_displayName,_x);
};


_formattedArray
