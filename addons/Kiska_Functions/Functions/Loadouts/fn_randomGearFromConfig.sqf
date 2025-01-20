/* ----------------------------------------------------------------------------
Function: KISKA_fnc_randomGearFromConfig

Description:
    Randomizes gear based upon input arrays for each slot. See `KISKA_fnc_randomGear`
     for details on behavior.

    Here is an example config class for random gear:
    (begin config example)
        class MyRandomGearConfigClass
        {
            headgear[] = {
				"H_Booniehat_khk_hs",
				"H_HelmetB"
			};
			vests[] = {
				"V_PlateCarrier1_rgr",
				"V_PlateCarrier2_rgr"
			};
			primaryWeapons[] = {
				{"arifle_MX_F",{"optic_Aco","30Rnd_65x39_caseless_mag"}},
				{"arifle_MX_F",{"optic_Hamr","30Rnd_65x39_caseless_mag"}}
			};
			handguns[] = {
				{"hgun_Pistol_heavy_01_F"}
			};
            // Weighted array
			facewear[] = {
				"", 1, // empty
				"G_Shades_Black", 0.5,
				"G_Tactical_Clear", 0.75,
				"G_Tactical_Black", 2
			};
        };
    (end)

Parameters:
    0: _units : <OBJECT or OBJECT[]> - The unit or units to randomize the gear of.
    1: _gearConfig : <CONFIG or STRING> - A config that contains weighted or unweighted arrays
        that match the inputs of `KISKA_fnc_randomGear` ("uniforms", "headgear", etc.).
        If a STRING, it is assumed it is the className that exists in `missionConfigFile >> "KISKA_RandomGear"`

Returns:
    NOTHING

Examples:
    (begin example)
        [
            player,
            missionConfigFile >> "KISKA_randomGear" >> "MyRandomGearConfigClass"
        ] call KISKA_fnc_randomGear;
    (end)

    (begin example)
        [
            [unit_1, unit_2],
            "MyRandomGearConfigClass"
        ] call KISKA_fnc_randomGearFromConfig;
    (end)

Author:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_randomGearFromConfig";

params [
    ["_units",[],[objNull,[]]],
    ["_gearConfig",configNull,["",configNull]]
];

if (_gearConfig isEqualType "") then {
    _gearConfig = missionConfigFile >> "KISKA_RandomGear" >> _gearConfig;
};
if (isNull _gearConfig) exitWith {
    ["Null _gearConfig passed",true] call KISKA_fnc_log;
    nil
};


[
	_units,
	getArray(_gearConfig >> "uniforms"),
	getArray(_gearConfig >> "headgear"),
	getArray(_gearConfig >> "facewear"),
	getArray(_gearConfig >> "vests"),
	getArray(_gearConfig >> "backpacks"),
	getArray(_gearConfig >> "primaryWeapons"),
	getArray(_gearConfig >> "handguns"),
	getArray(_gearConfig >> "secondaryWeapons")
] call KISKA_fnc_randomGear;


nil
