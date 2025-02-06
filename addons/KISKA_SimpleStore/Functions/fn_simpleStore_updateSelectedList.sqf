/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_updateSelectedList

Description:
    Triggers a refresh of the data that is in the selected items list box of 
    the given store for the local machine.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    NOTHING

Examples:
    (begin example)
        ["myStore"] call KISKA_fnc_simpleStore_updateSelectedList;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_updateSelectedList";

if !(hasInterface) exitWith {};
disableSerialization;

params [
    ["_storeId","",[""]]
];

if (_storeId isEqualTo "") exitWith {
    ["_storeId is empty!",true] call KISKA_fnc_log;
    nil
};

private _storeDisplay = [_storeId] call KISKA_fnc_simpleStore_getDisplay;
if (isNull _storeDisplay) exitWith {
    [["Store ",_storeId," is not open"],false] call KISKA_fnc_log;
    nil
};

private _selectedItemsListControl = _storeDisplay getVariable ["KISKA_simpleStore_selectedListControl",controlNull];
private _previouslySelectedIndex = lbCurSel _selectedItemsListControl;
lbClear _selectedItemsListControl;

private _fn_getSelectedItems = _storeDisplay getVariable "KISKA_simpleStore_fn_getSelectedItems";
private _selectedItems = call _fn_getSelectedItems;
if (_selectedItems isEqualTo []) exitWith { nil };

{
    _x params [
        ["_text","",[""]],
        ["_picture","",[""]],
        ["_pictureColor",[],[[]],4],
        ["_pictureColorSelected",[],[[]],4],
        ["_tooltip","",[""]],
        ["_data","",[""]]
    ];

    private _element = _poolItemsListControl lbAdd _text;
    _element lbSetValue _forEachIndex; // TODO: NOTE you can use this to determine the original pool item being taken
    _element lbSetTooltip _tooltip;
    _element lbSetData _data;

    if (_picture isNotEqualTo "") then {
        _element lbSetPicture _picture;
    };
    if (_pictureColor isNotEqualTo []) then {
        _element lbSetPictureColor _pictureColor;
    };
    if (_pictureColorSelected isNotEqualTo []) then {
        _element lbSetPictureColor _pictureColorSelected;
    };
} forEach _selectedItems;


private _maxIndex = (count _selectedItems) - 1;
if (_previouslySelectedIndex > _maxIndex) then {
    _previouslySelectedIndex = _maxIndex;
};
_poolItemsListControl lbSetSelected [_previouslySelectedIndex,true];


nil
