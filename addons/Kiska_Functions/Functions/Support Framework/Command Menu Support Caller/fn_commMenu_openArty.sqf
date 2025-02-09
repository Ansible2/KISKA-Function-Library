#include "..\..\..\Headers\Support Framework\Arty Ammo Classes.hpp"
#include "..\..\..\Headers\Support Framework\Command Menu Macros.hpp"
#include "..\..\..\Headers\Support Framework\Support Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_commMenu_openArty

Description:
   Opens a commanding menu that will allow the player to select the parameters
   of an artillery strike.

Parameters:
    0: _supportConfig <CONFIG> - The support config.
    1: _commMenuArgs <ARRAY> - The arguements passed by the CfgCommunicationMenu entry

        - 0. _caller <OBJECT> - The player calling for support
        - 1. _targetPosition <ARRAY> - The position (AGLS) at which the call is being made
            (where the player is looking or if in the map, the position where their cursor is)
        - 2. _target <OBJECT> - The cursorTarget object of the player
        - 3. _is3d <BOOL> - False if in map, true if not
        - 4. _commMenuId <NUMBER> The ID number of the Comm Menu added by BIS_fnc_addCommMenuItem
        - 5. _supportType <NUMBER> - The Support Type ID

    2: _numberOfRoundsLeft <NUMBER> - Used for keeping track of how many of a count a support has left (such as rounds)

Returns:
    NOTHING

Examples:
    (begin example)
        [
            
        ] call KISKA_fnc_commMenu_openArty;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_commMenu_openArty";

#define AMMO_TYPE_MENU_GVAR "KISKA_menu_ammoSelect"
#define ROUND_COUNT_MENU_GVAR "KISKA_menu_roundCount"
#define RADIUS_MENU_GVAR "KISKA_menu_radius"
#define MIN_RADIUS 0


params ["_supportConfig", "_commMenuArgs", "_numberOfRoundsLeft"];

if (isNull _supportConfig) exitWith {
    ["null _supportConfig used!",true] call KISKA_fnc_log;
    nil
};

private _menuPathArray = [];
private _menuVariables = []; // keeps track of global variable names to set to nil when done
private _thisArgs = _this; // just for readability

/* ----------------------------------------------------------------------------
    Ammo Menu
---------------------------------------------------------------------------- */
private _ammoMenu = [
    ["Select Ammo",false] // menu title
];
// get allowed ammo types from config
private _supportDetailsConfig = _supportConfig >> "KISKA_supportDetails";
private _ammoIds = getArray(_supportDetailsConfig >> "ammoTypes");

// create formatted array to use in menu
private ["_ammoClass","_ammoTitle","_keyCode"];
{
    if (_forEachIndex <= MAX_KEYS) then {
        // key codes are offset by 2 (1 on the number bar is key code 2)
        _keyCode = _forEachIndex + 2;
    } else {
        _keyCode = 0;
    };

    // handling custom ammo types
    if (_x isEqualType []) then {
        _ammoClass = _x select 0;
        _ammoTitle = _x select 1;

    } else {
        _ammoClass = [_x] call KISKA_fnc_supportConfigs_getAmmoClassFromId;
        _ammoTitle = [_x] call KISKA_fnc_supportConfigs_getAmmoTitleFromId;

    };


    _ammoMenu pushBack STD_LINE_PUSH(_ammoTitle,_keyCode,_ammoClass);
} forEach _ammoIds;

SAVE_AND_PUSH(AMMO_TYPE_MENU_GVAR,_ammoMenu)


/* ----------------------------------------------------------------------------
    Radius Menu
---------------------------------------------------------------------------- */
private _selectableRadiuses = getArray(_supportDetailsConfig >> "radiuses");
if (_selectableRadiuses isEqualTo []) then {
    _selectableRadiuses = missionNamespace getVariable ["KISKA_CBA_supp_radiuses_arr",[]];

    if (_selectableRadiuses isEqualTo []) then {
        _selectableRadiuses = [200];
    };
};

private _radiusMenu = [
    ["Area Spread",false] // title
];
private _keyCode = 0;
private _pushedMinRadius = false;
private _lasUsedIndex = 0;
{
    private _isMinRadius = _x <= MIN_RADIUS;
    if (_pushedMinRadius AND _isMinRadius) then {
        continue;
    };

    if (_lasUsedIndex <= MAX_KEYS) then {
        // key codes are offset by 2 (1 on the number bar is key code 2)
        _keyCode = _lasUsedIndex + 2;
        _lasUsedIndex = _lasUsedIndex + 1;

    } else {
        // zero key code means that it has no key to press to activate it
        _keyCode = 0;

    };


    if (_isMinRadius) then {
        _pushedMinRadius = true;
        _radiusMenu pushBack DISTANCE_LINE(MIN_RADIUS,_keyCode);
        continue;
    };

    _radiusMenu pushBack DISTANCE_LINE(_x,_keyCode);

} forEach _selectableRadiuses;

SAVE_AND_PUSH(RADIUS_MENU_GVAR,_radiusMenu)


/* ----------------------------------------------------------------------------
    Round Count Menu
---------------------------------------------------------------------------- */
private _roundsMenu = [
    ["Number of Rounds",false]
];
private _canSelectRounds = (_supportDetailsConfig >> "canSelectRounds") call BIS_fnc_getCfgDataBool;
private _roundsString = "";
if (_canSelectRounds) then {
    for "_i" from 1 to _numberOfRoundsLeft do {
        if (_i <= MAX_KEYS) then {
            _keyCode = _i + 1;
        } else {
            _keyCode = 0;
        };
        _roundsString = [_i,"Round(s)"] joinString " ";
        _roundsMenu pushBack STD_LINE_PUSH(_roundsString,_keyCode,_i);
    };

} else {
    _roundsString = [_numberOfRoundsLeft,"Round(s)"] joinString " ";
    _roundsMenu pushBack STD_LINE_PUSH(_roundsString,2,_numberOfRoundsLeft);

};

SAVE_AND_PUSH(ROUND_COUNT_MENU_GVAR,_roundsMenu)


/* ----------------------------------------------------------------------------
    Create Menu
---------------------------------------------------------------------------- */
_thisArgs pushBack _menuVariables;


[
    _menuPathArray,
    [_thisArgs, {
        params ["_ammo","_radius","_numberOfRounds"];

        private _roundsAvailable = _thisArgs select 2;
        // if a ctrl key is held and one left clicks to select the support while in the map, they can call in an infinite number of the support
        if (
            visibleMap AND
            (missionNamespace getVariable ["KISKA_ctrlDown",false])
        ) exitWith {
            ["You can't call in a support while holding down a crtl key and in the map. It causes a bug with the support menu."] call KISKA_fnc_errorNotification;
            ADD_SUPPORT_BACK(_roundsAvailable)
        };

        private _commMenuArgs = _thisArgs select 1;
        private _targetPosition = _commMenuArgs select 1;
        [_targetPosition,_ammo,_radius,_numberOfRounds] spawn KISKA_fnc_virtualArty;

        [SUPPORT_TYPE_ARTY] call KISKA_fnc_supports_genericNotification;

        // if support still has rounds available, add it back with the new round count
        if (_numberOfRounds < _roundsAvailable) then {
            _roundsAvailable = _roundsAvailable - _numberOfRounds;
            ADD_SUPPORT_BACK(_roundsAvailable)
        };

        UNLOAD_GLOBALS
    }],
    [_thisArgs, {
        ADD_SUPPORT_BACK(_thisArgs select 2)
        UNLOAD_GLOBALS
    }]
] spawn KISKA_fnc_commMenu_openTree;


nil
