/* ----------------------------------------------------------------------------
Function: KISKA_fnc_bases_createFromConfig_turrets

Description:
    Spawns a configed KISKA bases' turrets.

Parameters:
    0: _baseConfig <CONFIG> - The config path of the base config or the string
        className of a config located in `missionConfigFile >> "KISKA_bases"

Returns:
    <HASHMAP> - see KISKA_fnc_bases_getHashmap

Examples:
    (begin example)
        [
            "SomeBaseConfig"
        ] call KISKA_fnc_bases_createFromConfig_turrets;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_bases_createFromConfig_turrets";

params [
    ["_baseConfig",configNull,["",configNull]]
];


if (_baseConfig isEqualType "") then {
    _baseConfig = missionConfigFile >> "KISKA_Bases" >> _baseConfig;
};
if (isNull _baseConfig) exitWith {
    ["A null _baseConfig was passed",true] call KISKA_fnc_log;
    []
};


private _baseMap = [_baseConfig] call KISKA_fnc_bases_getHashmap;
private _base_turretGunners = _baseMap get "turret gunners";
private _base_unitList = _baseMap get "unit list";
private _base_groupList = _baseMap get "group list";

private _baseTurretsConfig = _baseConfig >> "turrets";
private _turretClasses = configProperties [_baseTurretsConfig >> "sets","isClass _x"];

/* ----------------------------------------------------------------------------

    Create Turrets

---------------------------------------------------------------------------- */
_turretClasses apply {
    private _turretConfig = _x;

    private _turretSpawnPositions = [
        "spawnPositions",
        _turretConfig,
        [],
        false,
        false,
        false
    ] call KISKA_fnc_bases_getPropertyValue;

    if (_turretSpawnPositions isEqualType "") then {
        _turretSpawnPositions = [_turretSpawnPositions] call KISKA_fnc_getMissionLayerObjects;
    };
    if (_turretSpawnPositions isEqualTo []) then {
        [["Could not find spawn positions for KISKA bases class: ",_x],true] call KISKA_fnc_log;
        continue;
    };


    private _turretClassNames = ["turretClassNames", _turretConfig,[]] call KISKA_fnc_bases_getPropertyValue;
    if (_turretClassNames isEqualType "") then {
        _turretClassNames = [[_turretConfig],_turretClassNames,false] call KISKA_fnc_callBack;
    };
    if (_turretClassNames isEqualTo []) then {
        [["Could not find classNames for turrets in KISKA bases class: ",_x],true] call KISKA_fnc_log;
        continue;
    };


    private _numberOfTurrets = ["numberOfTurrets", _turretConfig, -1] call KISKA_fnc_bases_getPropertyValue;
    private _totalNumberOfSpawns = count _turretSpawnPositions;
    if (_numberOfTurrets isEqualType "") then {
        _numberOfTurrets = [[_turretConfig,_turretSpawnPositions,_totalNumberOfSpawns],_numberOfTurrets,false] call KISKA_fnc_callBack;
    };
    if (_numberOfTurrets < 0) then {
        _numberOfTurrets = _totalNumberOfSpawns
    };


    private _unitClasses = ["unitClasses", _turretConfig, []] call KISKA_fnc_bases_getPropertyValue;
    if (_unitClasses isEqualType "") then {
        _unitClasses = [[_turretConfig],_unitClasses] call KISKA_fnc_callBack;
    };
    if (_unitClasses isEqualTo []) then {
        [["Found no unitClasses to use for KISKA base class: ",_turretConfig], true] call KISKA_fnc_log;
        continue;
    };


    private _turrets = [];
    for "_i" from 1 to _numberOfTurrets do {
        private _spawnPosition = [_turretSpawnPositions] call KISKA_fnc_deleteRandomIndex;
        private _class = [_turretClassNames,""] call KISKA_fnc_selectRandom;
        
        private ["_direction","_positionToSet"];
        if (_spawnPosition isEqualType objNull) then {
            _direction = getDir _spawnPosition;
            _positionToSet = getPosASL _spawnPosition;

        } else {
            private _isPostionWithDirection = (count _spawnPosition) > 3;
            if (_isPostionWithDirection) then {
                _direction = _spawnPosition deleteAt 3;
            } else {
                _direction = 0;
            };
            _positionToSet = ATLToASL _spawnPosition;

        };

        _turret = createVehicle [_class, _spawnPosition, [], 0, "NONE"];
        _turrets pushBack _turret;
        _turret setPosASL _positionToSet;
        _turret setDir _direction;
    };

    if (_turrets isEqualTo []) then {
        [["Created no turrets for KISKA base class: ",_turretConfig], true] call KISKA_fnc_log;
        continue;
    };

    private _side = ["side", _turretConfig, 0] call KISKA_fnc_bases_getPropertyValue;
    _side = _side call BIS_fnc_sideType;

    private _enableDynamicSim = ["dynamicSim", _turretConfig, true, true] call KISKA_fnc_bases_getPropertyValue;
    private _onGunnerCreated = compile (["onGunnerCreated", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue);
    private _onUnitMovedInGunner = compile (["onUnitMovedInGunner", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue);

    private _maxElevation = ["maxElevation", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue;
    if (_maxElevation isEqualType "") then { _maxElevation = compile _maxElevation };

    private _minElevation = ["minElevation", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue;
    if (_minElevation isEqualType "") then { _minElevation = compile _minElevation };

    private _maxRotation = ["maxRotation", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue;
    if (_maxRotation isEqualType "") then { _maxRotation = compile _maxRotation };

    private _minRotation = ["minRotation", _turretConfig, ""] call KISKA_fnc_bases_getPropertyValue;
    if (_minRotation isEqualType "") then { _minRotation = compile _minRotation };


    private _specifiedTurretLimits = [_minRotation,_maxRotation,_minElevation,_maxElevation];
    private _adjustTurretLimit = [
        _specifiedTurretLimits,
        { (_x isNotEqualTo {}) }
    ] call KISKA_fnc_findIfBool;

    private _hasReinforce = !(isNull (_turretConfig >> "reinforce"));
    _turrets apply {
        private _group = createGroup _side;
        private _unitClass = [_unitClasses,""] call KISKA_fnc_selectRandom;
        private _unit = _group createUnit [_unitClass,[0,0,0],[],0,"NONE"];

        private _eventParams = [_turretConfig,_unit,_x];
        if (_onGunnerCreated isNotEqualto {}) then {
            [
                _onGunnerCreated,
                _eventParams
            ] call CBA_fnc_directCall;
        };


        if (_enableDynamicSim) then {
            [_group, true] remoteExec ["enableDynamicSimulation", 2];
        };
        _unit moveInGunner _x;


        if (_onUnitMovedInGunner isNotEqualto {}) then {
            [
                _onUnitMovedInGunner,
                _eventParams
            ] call CBA_fnc_directCall;
        };


        if (_adjustTurretLimit) then {
            private _turretPath = _x unitTurret _unit;
            private _defaultTurretLimits = _x getTurretLimits _turretPath;
            private _newTurretLimits = +_defaultTurretLimits;
            private _callBackArgs = [_turretConfig,_x,_unit,_defaultTurretLimits];
            {
                private _limitIsDefault = _x isEqualTo {};
                if (_limitIsDefault) then { continue };

                private "_newLimit";
                if (_x isEqualType {}) then {
                    _newLimit = [
                        _x,
                        _callBackArgs
                    ] call CBA_fnc_directCall;
                } else {
                    _newLimit = _x;
                };

                _newTurretLimits set [_forEachIndex,_newLimit];
            } forEach _specifiedTurretLimits;


            _newTurretLimits params ["_minTurn", "_maxTurn", "_minElev", "_maxElev"];
            _x setTurretLimits [
                _turretPath,
                _minTurn,
                _maxTurn,
                _minElev,
                _maxElev
            ];
        };



        _base_turretGunners pushBack _unit;
        _base_unitList pushBack _unit;
        _base_groupList pushBack _group;

        if (_hasReinforce) then { 
            [_group,_turretConfig] call KISKA_fnc_bases_initReinforceFromClass;
        };
    };

};


_baseMap
