#define CMD_EXECUTE -5
#define IS_ACTIVE "1"
#define IS_VISIBLE "1"
#define EXPRESSION(CODE) [["expression", CODE]]
#define KEY_SHORTCUT(KEY) [KEY]

#define SAVE_MENU missionNamespace setVariable [_menuName,_menuArray];
#define SAVE_AND_RETURN SAVE_MENU _menuArray
#define UNLOAD_GLOBALS (_thisArgs select 3) apply {missionNamespace setVariable [_x,nil]};
#define WITH_USER(GVAR) "#USER:" + GVAR
#define SAVE_AND_PUSH(GVAR,MENU_ARRAY) \
	missionNamespace setVariable [GVAR,MENU_ARRAY]; \
	_menuVariables pushBack GVAR; \
	_menuPathArray pushBack WITH_USER(GVAR);


#define STD_LINE(TITLE, KEY, CODE) [TITLE, KEY_SHORTCUT(KEY), "", CMD_EXECUTE, EXPRESSION(CODE), IS_ACTIVE, IS_VISIBLE]
#define PUSHBACK_AND_PROCEED(VALUE) "(localNamespace getVariable 'KISKA_commMenuTree_params') pushBack " + ([VALUE] call KISKA_fnc_str) + "; localNamespace setVariable ['KISKA_commMenuTree_proceedToNextMenu',true];"
#define STD_LINE_PUSH(TITLE, KEY, VALUE) [TITLE, KEY_SHORTCUT(KEY), "", CMD_EXECUTE, EXPRESSION(PUSHBACK_AND_PROCEED(VALUE)), IS_ACTIVE, IS_VISIBLE]
#define DISTANCE_LINE(DIS, KEY) STD_LINE((str DIS) + "m",KEY,PUSHBACK_AND_PROCEED(DIS))
#define BEARING_LINE(BEARING, DIR, KEY) STD_LINE((str BEARING) + DIR,KEY,PUSHBACK_AND_PROCEED(BEARING))


#define ADD_SUPPORT_BACK(COUNT) [_thisArgs select 0,COUNT] call KISKA_fnc_commMenu_addSupport;
#define MAX_KEYS 9

#define BEARING_MENU \
	[ \
		["Move To Bearing", false], \
		BEARING_LINE(0," - N",2), \
		BEARING_LINE(45," - NE",3), \
		BEARING_LINE(90," - E",4), \
		BEARING_LINE(135," - SE",5), \
		BEARING_LINE(180," - S",6), \
		BEARING_LINE(225," - SW",7), \
		BEARING_LINE(270," - W",8), \
		BEARING_LINE(315," - NW",9) \
	]

#define VEHICLE_SELECT_MENU_STR "KISKA_vehicleSelect_menu"
#define RADIUS_MENU_STR "KISKA_menu_radius"
#define FLYIN_HEIGHT_MENU_STR "KISKA_flyInHeight_menu"
#define BEARING_MENU_STR "KISKA_bearing_menu"
#define ATTACK_TYPE_MENU_STR "KISKA_attackType_menu"
