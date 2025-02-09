/* ----------------------------------------------------------------------------
Function: KISKA_fnc_simpleStore_refreshPoolList

Description:
    Triggers a refresh of the data that is in the pool list box of the given
    store.

Parameters:
    0: _storeId <STRING> - The id for the particular simple store.

Returns:
    NOTHING

Examples:
    (begin example)
        ["myStore"] call KISKA_fnc_simpleStore_refreshPoolList;
    (end)

Authors:
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_simpleStore_refreshPoolList";

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


private _poolItemsListControl = _storeDisplay getVariable ["KISKA_simpleStore_poolListControl",controlNull];
private _previouslySelectedIndex = lbCurSel _poolItemsListControl;
lbClear _poolItemsListControl;

private _poolItems = [_storeId] call KISKA_fnc_simpleStore_getPoolItems;
if (_poolItems isEqualTo []) exitWith { nil };


private _fn_poolItemToListboxItem = _storeDisplay getVariable "KISKA_simpleStore_fn_poolItemToListboxItem";
{
    private _listBoxItem = [_x,_forEachIndex] call _fn_poolItemToListboxItem;
    if (isNil "_listBoxItem") then {continue};

    _listBoxItem params [
        ["_text","",[""]],
        ["_picture","",[""]],
        ["_pictureColor",[],[[]]],
        ["_pictureColorSelected",[],[[]]],
        ["_tooltip","",[""]],
        ["_data","",[""]]
    ];

    private _element = _poolItemsListControl lbAdd _text;
    _poolItemsListControl lbSetValue [_element,_forEachIndex]; // TODO: NOTE you can use this to determine the original pool item being taken
    _poolItemsListControl lbSetTooltip [_element,_tooltip];
    _poolItemsListControl lbSetData [_element,_data];

    if (_picture isNotEqualTo "") then {
        _poolItemsListControl lbSetPicture [_element,_picture];
    };
    if (_pictureColor isNotEqualTo []) then {
        _poolItemsListControl lbSetPictureColor [_element,_pictureColor];
    };
    if (_pictureColorSelected isNotEqualTo []) then {
        _poolItemsListControl lbSetPictureColor [_element,_pictureColorSelected];
    };
} forEach _poolItems;

private _maxIndex = (count _poolItems) - 1;
if (_previouslySelectedIndex > _maxIndex) then {
    _previouslySelectedIndex = _maxIndex;
};
_poolItemsListControl lbSetSelected [_previouslySelectedIndex,true];

lbSort _poolItemsListControl;


nil
