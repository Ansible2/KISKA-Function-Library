/* ----------------------------------------------------------------------------
Function: KISKA_fnc_closeAirSupport_fire

Description:
    Instructs the aircraft to fire its weapons for `KISKA_fnc_closeAirSupport`
     and will guide munitions if needed.

Parameters:
    0: _aircraft : <OBJECT> - The aircraft doing the firing.
    1: _attackTarget : <OBJECT> - The original target that the aircraft is meant to fire at.
    2: _strafeTarget : <OBJECT> - A target that will act as a guide for strafing the target.
    3: _fireOrders : <[STRING,STRING,NUMBER,NUMBER,STRING,NUMBER][]> - List of fire orders.

Returns:
    NOTHING

Examples:
    (begin example)
        Should not be called on its own but in KISKA_fnc_closeAirSupport
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_closeAirSupport_fire";

#define MIN_TIME_BETWEEN_SHOTS 0.01
#define GUIDE_WEAPON_INTERVAL 0.05
#define GUIDED_WEAPON_ACCELERATION_TIME 0.1

params ["_aircraft","_attackTarget","_strafeTarget","_fireOrders"];

_aircraft setVariable ["KISKA_closeAirSupport_isFiring",true];
// CUP planes in particular have an issue with rocket fire not being accurate
// This will guide projectiles to where they should go
_aircraft addEventHandler ["Fired", {
    params ["_aircraft", "_weapon", "", "", "", "", "_projectile"];

    private _weaponClass = toLowerANSI _weapon;
    private _guidance = [
        "KISKA_fnc_closeAirSupport_strafeTargetGuidedWeapons",
        "KISKA_fnc_closeAirSupport_originalTargetGuidedWeapons"
    ] apply {
        private _guideMap = _aircraft getVariable _x;
        private _currentNumberOfRoundsToGuide = _guideMap getOrDefaultCall [_weaponClass,{-1}];
        if (_currentNumberOfRoundsToGuide <= 0) then { continueWith false };
        
        _guideMap set [_weaponClass, _currentNumberOfRoundsToGuide - 1];
        breakWith true;
    };
    _guidance params [
        ["_guideToStrafeTarget",false],
        ["_guideToOriginalTarget",false]
    ];
        
    if (_guideToOriginalTarget OR _guideToStrafeTarget) then {
        private "_targetToGuideTo";
        if (_guideToStrafeTarget) then {
            _targetToGuideTo = _aircraft getVariable ["KISKA_closeAirSupport_strafeTarget",objNull];
        } else {
            _targetToGuideTo = _aircraft getVariable ["KISKA_closeAirSupport_originalTarget",objNull];
        };

        [
            {
                params ["_aircraft","_projectile","_targetToGuideTo"];

                if (isNull _targetToGuideTo) exitWith {};

                private _projectileStartPosWorld = getPosWorldVisual _projectile;
                private _positionToGuideTo = getPosWorldVisual _targetToGuideTo;
                private _vectors = [_projectileStartPosWorld,_positionToGuideTo] call KISKA_fnc_getVectorToTarget;

                private _speed = speed _projectile;
                _projectile setVectorDirAndUp _vectors;
                _projectile setVelocityModelSpace [0,_speed,0];

                _vectors params ["_vectorDir","_vectorUp"];
                private _vectorDistanceToTarget = _positionToGuideTo vectorDistance _projectileStartPosWorld;
                private _flightTime = _vectorDistanceToTarget / _speed;
                private _startTime = time;
                private _timeAfterFlight = _startTime + _flightTime;

                [
                    {
                        params ["_args","_id"];

                        _args params [
                            "_projectile",
                            "_projectileStartPosWorld",
                            "_vectorDir",
                            "_vectorUp",
                            "_startTime",
                            "_timeAfterFlight",
                            "_positionToGuideTo"
                        ];

                        private _time = time;
                        if ((isNull _projectile) OR (_time > (_timeAfterFlight + 60))) exitWith {
                            [_id] call CBA_fnc_removePerFrameHandler;
                        };

                        private _interval = linearConversion [_startTime,_timeAfterFlight,_time,0,1];
                        private _velocity = velocity _projectile;
                        _projectile setVelocityTransformation [
                            _projectileStartPosWorld, _positionToGuideTo,
                            _velocity, _velocity,
                            _vectorDir,_vectorDir,
                            _vectorUp, _vectorUp,
                            _interval
                        ];
                    },
                    GUIDE_WEAPON_INTERVAL,
                    [
                        _projectile,
                        _projectileStartPosWorld,
                        _vectorDir,
                        _vectorUp,
                        _startTime,
                        _timeAfterFlight,
                        _positionToGuideTo
                    ]
                ] call CBA_fnc_addPerFrameHandler;
            },
            [_aircraft, _projectile, _targetToGuideTo],
            GUIDED_WEAPON_ACCELERATION_TIME
        ] call CBA_fnc_waitAndExecute;
    };
}];

private _fireIntervalTotal = 0;
private _lastOrderIndex = (count _fireOrders) - 1;
private _pilot = currentPilot _aircraft;

private _guideToStrafeTargetWeaponClasses = createHashMap;
_aircraft setVariable ["KISKA_fnc_closeAirSupport_strafeTargetGuidedWeapons",_guideToStrafeTargetWeaponClasses];
private _guideToOriginalTargetWeaponClasses = createHashMap;
_aircraft setVariable ["KISKA_fnc_closeAirSupport_originalTargetGuidedWeapons",_guideToOriginalTargetWeaponClasses];


{
    private _isFinalOrder = _forEachIndex isEqualTo _lastOrderIndex;
    _x params [
        "_weaponClass",
        "_magazineClass",
        "_numberOfTriggerPulls",
        "_timeBetweenShots",
        "_weaponProfile",
        "_strafeIncrement"
    ];

    _timeBetweenShots = _timeBetweenShots max MIN_TIME_BETWEEN_SHOTS;

    private _key = toLowerANSI _weaponClass;
    switch (toLowerANSI _weaponProfile) do
    {
        case "guide_to_original_target": {
            private _currentNumberOfRoundsToGuide = _guideToOriginalTargetWeaponClasses getOrDefault [_key,0];
            _guideToOriginalTargetWeaponClasses set [_key,_currentNumberOfRoundsToGuide + _numberOfTriggerPulls];
        };
        case "guide_to_strafe_target": { 
            private _currentNumberOfRoundsToGuide = _guideToStrafeTargetWeaponClasses getOrDefault [_key,0];
            _guideToStrafeTargetWeaponClasses set [_key,_currentNumberOfRoundsToGuide + _numberOfTriggerPulls];
        };
        default {};
    };

    private _fireModes = getArray(configFile >> "CfgWeapons" >> _weaponClass >> "modes");
    private _primaryFireMode = _fireModes param [0,""];
    for "_i" from 1 to _numberOfTriggerPulls do {
        [
            {
                params [
                    "_aircraft",
                    "_attackTarget",
                    "_weaponClass",
                    "_primaryFireMode",
                    "_pilot",
                    ["_strafeIncrement",-1],
                    "_isDoneFiring"
                ];


                if (_aircraft getVariable ["KISKA_closeAirSupport_complete",false]) exitWith {};

                // certain vehicles seem to not work with fireAtTarget on the cannon ("vn_b_air_f4c_cas" from CDLC SOGPF)
                if (_strafeIncrement >= 0) then {
                    _aircraft setVariable ["KISKA_closeAirSupport_strafeIncrement",_strafeIncrement];
                };

                private _canFireAtTarget = _pilot fireAtTarget [_attackTarget,_weaponClass];
                if !(_canFireAtTarget) then {
                    _pilot forceWeaponFire [_weaponClass,_primaryFireMode];
                };

                if (_isDoneFiring) then {
                    _aircraft setVariable ["KISKA_closeAirSupport_isFiring",true];
                    _aircraft setVariable ["KISKA_closeAirSupport_complete",true];
                };
            },
            [
                _aircraft,
                _attackTarget,
                _weaponClass,
                _primaryFireMode,
                _pilot,
                _strafeIncrement,
                _isFinalOrder && (_i isEqualTo _numberOfTriggerPulls)
            ],
            _fireIntervalTotal
        ] call CBA_fnc_waitAndExecute;

        _fireIntervalTotal = _fireIntervalTotal + _timeBetweenShots;
    };

} forEach _fireOrders;

nil
