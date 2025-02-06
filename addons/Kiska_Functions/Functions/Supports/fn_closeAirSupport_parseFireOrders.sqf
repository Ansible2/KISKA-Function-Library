/* ----------------------------------------------------------------------------
Function: KISKA_fnc_closeAirSupport_fire

Description:
    Parses and validates a list of fire orders for an aircraft to follow to do CAS
     with `KISKA_fnc_closeAirSupport`

Parameters:
    0: _aircraft : <OBJECT> - The aircraft that will be following the fire orders
    1: _fireOrders : <[STRING,STRING,NUMBER,NUMBER,STRING,NUMBER][]> - List of fire orders.

        A fire single fire order can consist of the following arguments:
            - 0. <STRING> - The weapon to fire's className. If this is to be 
                a pylon weapon, simply set to `pylon`.
            - 1. <STRING> - The weapon to fire's magazine className. If this is
                to be a pylon magazine, ensure you've set the weapon className to
                "pylon". If no magazine is provided but a weapon is, the default
                magazine for the weapon will be used.
            - 2. <NUMBER> - The number of trigger pulls. If less than 0, all rounds
                in the magazine will be fired.
            - 3. <NUMBER> - The amount of seconds between each time the AI pulls the trigger.
            - 4. <STRING> - Either `"guide_to_original_target"`, `"guide_to_strafe_target"`, or `""`.
                `guide_to_original_target` will guide each round of the weapon fired directly to the
                attack position specified. `guide_to_strafe_target` will guide each round onto the
                stafing target giving the illusion of strafing. Leave empty if no guidance is necessary.
                This can be performance intensive.
            - 5. <NUMBER> - For every 0.01 seconds the aircraft is firing these munitions,
                how much space should there be added to the aicraft's nose position? This
                will help with strafing a target.

Returns:
    <[STRING,STRING,NUMBER,NUMBER,STRING,NUMBER][]> - a parsed list of fire orders.

Examples:
    (begin example)
        // Should not be called on its own but in `KISKA_fnc_closeAirSupport`
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_closeAirSupport_parseFireOrders"

params [
    ["_aircraft",objNull,[objNull]],
    ["_fireOrders",[],[[]]]
];

private _allVehiclePylonNames = (getAllPylonsInfo _aircraft) apply { 
    private _pylon = _x select 1;
    _aircraft setPylonLoadout [_pylon,""];
    _pylon
};
private "_invalidFireOrdersMessage";
private _fireOrdersParsed = [];
{
    _x params [
        ["_weapon",""],
        ["_mag",""],
        ["_numberOfTriggerPulls",-1],
        ["_timeBetweenShots",0.05],
        ["_weaponProfile",""],
        ["_strafeIncrement",0]
    ];

    if !(_weapon isEqualType "") then {
        _invalidFireOrdersMessage = ["_weapon must be a string in fire order index ", _forEachIndex];
        break;
    };
    if !(_mag isEqualType "") then {
        _invalidFireOrdersMessage = ["_mag must be a string in fire order index ", _forEachIndex];
        break;
    };
    if !(_numberOfTriggerPulls isEqualType 123) then {
        _invalidFireOrdersMessage = ["_numberOfTriggerPulls must be a number in fire order index ", _forEachIndex];
        break;
    };
    if !(_timeBetweenShots isEqualType 123) then {
        _invalidFireOrdersMessage = ["_timeBetweenShots must be a number in fire order index ", _forEachIndex];
        break;
    };
    if !(_weaponProfile isEqualType "") then {
        _invalidFireOrdersMessage = ["_weaponProfile must be a string in fire order index ", _forEachIndex];
        break;
    };
    if !(_strafeIncrement isEqualType 123) then {
        _invalidFireOrdersMessage = ["_strafeIncrement must be a number in fire order index ", _forEachIndex];
        break;
    };

    if (_mag isEqualTo "") then {
        private _defaultMags = getArray(configFile >> "CfgWeapons" >> _weapon >> "magazines");
        _mag = _defaultMags select 0;
        if (_mag isEqualTo "") then {
            _invalidFireOrdersMessage = ["could not find default mag class for fire order index ", _forEachIndex];
            break;
        };
    };

    if (_numberOfTriggerPulls < 0) then {
        private _configedNumberOfRoundsInMag = getNumber(configFile >> "CfgMagazines" >> _mag >> "count");
        if (_configedNumberOfRoundsInMag isEqualTo 0) then {
            [["Fire order index ",_forEachIndex," had no mag count defined for ",_mag],false] call KISKA_fnc_log;
            _numberOfTriggerPulls = 1;
        } else {
            _numberOfTriggerPulls = _configedNumberOfRoundsInMag;
        };
    };

    if (_weapon == "pylon") then {
        if (_allVehiclePylonNames isEqualTo []) then {
            _invalidFireOrdersMessage = [
                "_aircraft ",
                typeOf _aircraft,
                " has no pylons configured"
            ];
            break;
        };

        _weapon = getText(configFile >> "cfgMagazines" >> _mag >> "pylonWeapon");
        if (_weapon isEqualTo "") then {
            _invalidFireOrdersMessage = [
                "Magazine '", _mag,
                "' has no `pylonWeapon` defined in fire order index ",
                _forEachIndex
            ];
            break;
        };

        
        private _pylon = _allVehiclePylonNames deleteAt 0;
        _aircraft setPylonLoadout [_pylon,_mag,true,[]];
    };

    _fireOrdersParsed pushBack [_weapon,_mag,_numberOfTriggerPulls,_timeBetweenShots,_weaponProfile,_strafeIncrement];
} forEach _fireOrders;

if !(isNil "_invalidFireOrdersMessage") exitWith {
    [_invalidFireOrdersMessage,true] call KISKA_fnc_log;
    []
};


_fireOrdersParsed
