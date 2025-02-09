#include "\KISKA_Functions\Headers\GUI\KISKA GUI Grid.hpp"
#include "\KISKA_Functions\Headers\GUI\KISKA GUI Colors.hpp"
#include "\KISKA_Functions\Headers\GUI\KISKA GUI Styles.hpp"
#include "SimpleStoreCommonDefines.hpp"

class RscText;
class RscListbox;
class ctrlButton;
class KISKA_RscCloseButton;

/* -------------------------------------------------------------------------
    Dialog
------------------------------------------------------------------------- */
class KISKA_simpleStore_dialog
{
    idd = -1;
    enableSimulation = 1;
    movingEnabled = 1;

    class controlsBackground
    {
        class simpleStore_background_frame : RscText
        {
            idc = -1;
            x = KISKA_POS_X(-14.5);
            y = KISKA_POS_Y(-11);
            w = KISKA_POS_W(29);
            h = KISKA_POS_H(22);
            colorBackground[] = KISKA_GREY_COLOR(0,0.5);
        };
        class simpleStore_headerText : RscText
        {
            idc = SIMPLE_STORE_HEADER_TEXT_IDC;
            moving = 1;
            x = KISKA_POS_X(-14.5);
            y = KISKA_POS_Y(-12);
            w = KISKA_POS_W(28);
            h = KISKA_POS_H(1);
        };
        /* -------------------------------------------------------------------------
            Text Controls
        ------------------------------------------------------------------------- */
        class simpleStore_pool_headerText : RscText
        {
            idc = SIMPLE_STORE_POOL_HEADER_TEXT_IDC;
            x = KISKA_POS_X(-14);
            y = KISKA_POS_Y(-10);
            w = KISKA_POS_W(13.5);
            h = KISKA_POS_H(1);
            colorBackground[] = KISKA_GREY_COLOR(0,1);
        };
        class simpleStore_selected_headerText : simpleStore_pool_headerText
        {
            idc = SIMPLE_STORE_SELECTED_HEADER_TEXT_IDC;
            x = KISKA_POS_X(0.5);
        };
    };

    class controls
    {
        /* -------------------------------------------------------------------------
            List Controls
        ------------------------------------------------------------------------- */
        class simpleStore_pool_listBox : RscListbox
        {
            idc = SIMPLE_STORE_POOL_LIST_IDC;
            x = KISKA_POS_X(-14);
            y = KISKA_POS_Y(-9);
            w = KISKA_POS_W(13.5);
            h = KISKA_POS_H(18);
            colorBackground[] = KISKA_GREY_COLOR(0.25,0.35);
            sizeEx = KISKA_GUI_TEXT_SIZE(2.5);
        };
        class simpleStore_selected_listBox : simpleStore_pool_listBox
        {
            idc = SIMPLE_STORE_SELECTED_LIST_IDC;
            x = KISKA_POS_X(0.5);
        };

        /* -------------------------------------------------------------------------
            Button Controls
        ------------------------------------------------------------------------- */
        class simpleStore_take_button : ctrlButton
        {
            idc = SIMPLE_STORE_TAKE_BUTTON_IDC;
            style = KISKA_ST_CENTER;
            text = "Take";
            x = KISKA_POS_X(-10);
            y = KISKA_POS_Y(9.5);
            w = KISKA_POS_W(5);
            h = KISKA_POS_H(1);
        };
        class simpleStore_store_button : simpleStore_take_button
        {
            idc = SIMPLE_STORE_STORE_BUTTON_IDC;
            style = KISKA_ST_CENTER;
            text = "Store";
            x = KISKA_POS_X(5);
        };
        class simpleStore_close_button : KISKA_RscCloseButton
        {
            idc = SIMPLE_STORE_CLOSE_BUTTON_IDC;
            x = KISKA_POS_X(13.5);
            y = KISKA_POS_Y(-12);
            w = KISKA_POS_W(1);
            h = KISKA_POS_H(1);
        };
    };
};
