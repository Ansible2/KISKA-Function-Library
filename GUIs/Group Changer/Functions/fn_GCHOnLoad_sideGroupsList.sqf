/* ----------------------------------------------------------------------------
Function: KISKA_fnc_GCHOnLoad_sideGroupList

Description:
	Adds eventhandler to the listbox.

Parameters:
	0: _control <CONTROL> - The control for the list box

Returns:
	NOTHING

Examples:
    (begin example)
        [_control] call KISKA_fnc_GCHOnLoad_sideGroupList;
    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
disableSerialization;
scriptName "KISKA_fnc_GCHOnLoad_sideGroupList";

#define REFRESH_SPEED (missionNamespace getVariable ["KISKA_CBA_GCH_updateFreq",1])
#define PLAYER_GROUP_COLOR [0,1,0,0.6] // Green
#define GET_CACHED_GROUPS _allGroupsCached select {(side _x) isEqualTo _playerSide AND {!(_x getVariable ["KISKA_GCH_exclude",false])}}

params ["_control"];

// add event handler
_control ctrlAddEventHandler ["LBSelChanged",{
	params ["_control", "_selectedIndex"];

	// get selected group
	private _sideGroups = uiNamespace getVariable "KISKA_GCH_sideGroupsArray";
	private _sideGroupsIndex = _control lbValue _selectedIndex;
	private _selectedGroup = _sideGroups select _sideGroupsIndex;
	uiNamespace setVariable ["KISKA_GCH_selectedGroup",_selectedGroup];

	[true,true,true,true,true] call KISKA_fnc_GCH_updateCurrentGroupSection;
}];


private _playerSide = side player;
private _allGroupsCached = allGroups;
private _sideGroups = GET_CACHED_GROUPS;


uiNamespace setVariable ["KISKA_GCH_sideGroupsArray",_sideGroups];


private _fn_updateSideGroupList = {
	lbClear _control;

	// add to listbox
	private "_index";
	private _playerGroup = group player;
	{
		_index = _control lbAdd (groupId _x);
		// saving the index as a value so that it can be referenced against the _sideGroups array
		_control lbSetValue [_index,_forEachIndex];

		// highlight the player group
		if (_x isEqualTo _playerGroup) then {
			_control lbSetColor [_index, PLAYER_GROUP_COLOR];
		};
	} forEach _sideGroups;

	// sort list alphabetically
	lbSort _control;
};

call _fn_updateSideGroupList;


private _allGroupsCompare = [];
// loop to update list
while {!isNull (uiNamespace getVariable "KISKA_GCH_display")} do {
	// if the group list changed, then update
	if (allGroups isNotEqualTo _allGroupsCached) then {
		_allGroupsCached = allGroups;

		// check to see if players side groups actually needs to be updated
		// if no group was added to the side, no need to update
		private _sideGroups_compare = GET_CACHED_GROUPS;

		if (_sideGroups_compare isNotEqualTo _sideGroups) then {
			_sideGroups = +_sideGroups_compare;
			uiNamespace setVariable ["KISKA_GCH_sideGroupsArray",_sideGroups];
			call _fn_updateSideGroupList;
		};
	};

	sleep REFRESH_SPEED;
};


nil
