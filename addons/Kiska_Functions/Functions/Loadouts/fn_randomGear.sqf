/* ----------------------------------------------------------------------------
Function: KISKA_fnc_randomGear

Description:
    Randomizes gear based upon input arrays for each slot. Be aware that this function
     is very slow (can take >1ms for a single unit) and should be used ideally 
     on initialization for large numbers of units. 

    The units must be local to the machine where this function is executed.

    All gear arrays can be weighted or unweighted arrays.

Parameters:
    0: _units : <OBJECT or OBJECT[]> - The units to randomize the gear of
    1: _uniforms : <STRING[] or (STRING,NUMBER)[]> - Potential uniforms to wear
    2: _headgear : <STRING[] or (STRING,NUMBER)[]> - Potential headgear to wear
    3: _facewear : <STRING[] or (STRING,NUMBER)[]> - Potential facewear (goggles) to wear
    4: _vests : <STRING[] or (STRING,NUMBER)[]> - Potential vests to wear
    5: _backpacks : <STRING[] or (STRING,NUMBER)[]> - Potential backpacks to wear
    6: _primaryWeapons : <[STRING,(STRING[] | (STRING,NUMBER)[])][]> - Primary weapons and items to add to them (see example)
    7: _handguns : <[STRING,(STRING[] | (STRING,NUMBER)[])][]> - Handgun weapons and items to add to them
    8: _secondaryWeapons : <[STRING,(STRING[] | (STRING,NUMBER)[])][]> - Secondary (launcher) weapons and items to add to them

Returns:
    NOTHING

Examples:
    (begin example)
        private _uniforms = ["U_B_CombatUniform_mcam_vest"];
        private _headgear = [];
        private _facewear = [];
        private _vests = [];
        private _backpacks = [];
        private _primaryWeapons = [
            // add a mag an optic to rifle
            ["arifle_MXC_F",["optic_Aco","30Rnd_65x39_caseless_mag"]]
        ];

        [
            _units,
            _uniforms,
            _headgear,
            _facewear,
            _vests,
            _backpacks,
            _primaryWeapons
        ] call KISKA_fnc_randomGear;
    (end)

    (begin example)
        // Weighted array 
        private _uniforms = [
            "U_B_CombatUniform_mcam_vest", 0.5,
            "U_B_CombatUniform_mcam_tshirt", 0.25,
            "U_B_CombatUniform_mcam", 0.25
        ];

        [
            _units,
            _uniforms
        ] call KISKA_fnc_randomGear;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_randomGear";

params [
	["_units",objNull,[objNull]],
	["_uniforms",[],[[]]],
	["_headgear",[],[[]]],
	["_facewear",[],[[]]],
	["_vests",[],[[]]],
	["_backpacks",[],[[]]],
	["_primaryWeapons",[],[[]]],
	["_handguns",[],[[]]],
	["_secondaryWeapons",[],[[]]]
];

if (_units isEqualType objNull) then {
    _units = [_units];
};

private _gearSelectors = [
    [_uniforms, { params ["_gear","_unit"]; _unit forceAddUniform _gear }],
    [_headgear, { params ["_gear","_unit"]; _unit addHeadgear _gear; }],
    [_facewear, { params ["_gear","_unit"]; _unit addGoggles _gear; }],
    [_vests, { params ["_gear","_unit"]; _unit addVest _gear; }],
    [_backpacks, { params ["_gear","_unit"]; _unit addBackpack _gear; }],
    [
        _primaryWeapons, 
        {
            params ["_gear","_unit"];
            _gear params [
                "_weapon",
                ["_weaponItems",[]]
            ];
            _unit addWeapon _weapon;
            _weaponItems apply { _unit addPrimaryWeaponItem _x };
        },
        []
    ],
    [
        _handguns, 
        { 
            params ["_gear","_unit"];
            _gear params [
                "_weapon",
                ["_weaponItems",[]]
            ];
            _unit addWeapon _weapon;
            _weaponItems apply { _unit addHandgunItem _x };
        },
        []
    ],
    [
        _secondaryWeapons, 
        { 
            params ["_gear","_unit"];
            _gear params [
                "_weapon",
                ["_weaponItems",[]]
            ];
            _unit addWeapon _weapon;
            _weaponItems apply { _unit addSecondaryWeaponItem _x };
        },
        []
    ]
];

_units apply {
    private _unit = _x;

    if (isNull _unit) then {
        ["Null unit was passed",true] call KISKA_fnc_log;
        continue;
    };

    if (!local _unit) then {
        [[_unit," is not a local unit; must be executed where unit is local!"],true] call KISKA_fnc_log;
        continue;
    };

    // remove all existing stuff
    removeAllWeapons _unit;
    removeAllItems _unit;
    removeAllAssignedItems _unit;
    removeUniform _unit;
    removeVest _unit;
    removeBackpack _unit;
    removeHeadgear _unit;
    removeGoggles _unit;

    _gearSelectors apply {
        _x params [
            "_availableGear",
            "_fn_addGear",
            ["_valueType",""]
        ];

        if (_availableGear isEqualTo []) then { continue };
        
        private _randomlySelectedGear = [_availableGear,_valueType] call KISKA_fnc_selectRandom;
        [_randomlySelectedGear, _unit] call _fn_addGear;
    };

};


nil
