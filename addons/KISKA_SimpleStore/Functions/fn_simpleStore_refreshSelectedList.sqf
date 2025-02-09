/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_refreshSelectedList

Description:
    Triggers a refresh of the data that is in the selected items list box of 
    the given store for the local machine.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    NOTHING

Examples:
    (begin example)
        ["myStore"] call KISKA_fnc_simpleStore_refreshSelectedList;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_refreshSelectedList";

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
private _selectedItems = [_storeId] call _fn_getSelectedItems;
if (_selectedItems isEqualTo []) exitWith { nil };

{
    if (isNil "_x") then {continue};
    
    _x params [
        ["_text","",[""]],
        ["_picture","",[""]],
        ["_pictureColor",[],[[]]],
        ["_pictureColorSelected",[],[[]]],
        ["_tooltip","",[""]],
        ["_data","",[""]]
    ];

    private _element = _selectedItemsListControl lbAdd _text;
    _selectedItemsListControl lbSetValue [_element,_forEachIndex];
    _selectedItemsListControl lbSetTooltip [_element,_tooltip];
    _selectedItemsListControl lbSetData [_element,_data];

    if (_picture isNotEqualTo "") then {
        _selectedItemsListControl lbSetPicture [_element,_picture];
    };
    if (_pictureColor isNotEqualTo []) then {
        _selectedItemsListControl lbSetPictureColor [_element,_pictureColor];
    };
    if (_pictureColorSelected isNotEqualTo []) then {
        _selectedItemsListControl lbSetPictureColor [_element,_pictureColorSelected];
    };
} forEach _selectedItems;


private _maxIndex = (count _selectedItems) - 1;
if (_previouslySelectedIndex > _maxIndex) then {
    _previouslySelectedIndex = _maxIndex;
};
_selectedItemsListControl lbSetSelected [_previouslySelectedIndex,true];


nil
