//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.WatchUi;

//! Handle input for the home view
class MenuTestDelegate extends WatchUi.BehaviorDelegate {

    var mView;
    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //! Handle the menu event
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
		var deviceSettings = System.getDeviceSettings();
		// it is safe to access the language
		if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
		{
           WatchUi.pushView(new $.Rez.Menus.MainMenuHeb(), new $.MenuTestMenuDelegate(), WatchUi.SLIDE_UP);
		}
		else
		{
            WatchUi.pushView(new $.Rez.Menus.MainMenuEng(), new $.MenuTestMenuDelegate(), WatchUi.SLIDE_UP);
		}        
        return true;
    }
}
