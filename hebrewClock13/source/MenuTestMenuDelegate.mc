//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//! Input handler to respond to main menu selections
class MenuTestMenuDelegate extends WatchUi.MenuInputDelegate {
    //! Constructor
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    function onPosition(info) 
    {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (info != null) 
        {
            // you might also display a view to show the status of the fetch...
            System.println("submit request");

            // var view = new Ui.ProgressBar("Fetching Data", null);
            // var delegate = new MyRequestDelegate(view, info, self.method(:onJsonResponse));

            // Ui.pushView(view, delegate, Ui.SLIDE_IMMEDIATE);
        }
    }

    function onJsonResponse(code, data) 
    {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        if (code == 200) {
        // everything went well
        }
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onMenuItem(item as Symbol) as Void {
//        if (item == :Item1) {
//            System.println("Item 1");
//            WatchUi.pushView(new $.Rez.Menus.AuxMenu(), new $.AuxMenuDelegate(), WatchUi.SLIDE_UP);
//        } else if (item == :Item2) {
//            System.println("Item 2");
//        }
        if (item == :item_1) {
            //var view = new WatchUi.ProgressBar("Waiting for GPS", null);
            //var delegate = new MyAcquirePositionDelegate(view, self.method(:onPosition));
            //WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);    
            if(Storage.getValue("showDeath") == false)
            {
                Storage.setValue("showDeath",true);
            }
            else
            {
                Storage.setValue("showDeath",false);
            }
        }
         else if (item == :item_2) {
            latitude = 40.6971494;
         	longitude = -73.6994959;
 		    Storage.setValue("latitude", latitude);
	    	Storage.setValue("longitude", longitude);
            isJustOpened = true; 
        }
         else if (item == :item_3) {
            isMoonClock = false;
 		    Storage.setValue("isMoonClock", false);
            isJustOpened = true; 
        }
         else if (item == :item_4) {
            isMoonClock = true;
 		    Storage.setValue("isMoonClock", true);
            isJustOpened = true; 
        }


    }
}
