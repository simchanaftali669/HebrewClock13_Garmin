using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
import Toybox.Application.Storage;

class MyAcquirePositionDelegate extends Ui.BehaviorDelegate
{
    hidden var _view;
    hidden var _callback;

    function initialize(view, callback) 
    {
        BehaviorDelegate.initialize();
        _view = view;
        _callback = callback;

        Position.enableLocationEvents(
        Position.LOCATION_ONE_SHOT, self.method(:onPosition));
    }

    function onPosition(info as Toybox.Position.Info) as Void
    {
        if (info == null || info.accuracy == null) {
            return;
        }

        if (info.accuracy != Position.QUALITY_GOOD) {
            return;
        }        
       
        var myLocation = info.position.toDegrees();
        latitude = myLocation[0];
        longitude = myLocation[1];
 
        Storage.setValue("latitude", latitude);
        Storage.setValue("longitude", longitude);  
        isJustOpened = true; 

        //System.ClockTime = info.when;

        _callback.invoke(info);
    }

    function onBack() {
        return false;
    }
}

class MyViewDelegate extends Ui.BehaviorDelegate
{
    function initialize() 
    {
        BehaviorDelegate.initialize();
    }

    function onPosition(info) 
    {
        Ui.popView(Ui.SLIDE_IMMEDIATE);

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
        Ui.popView(Ui.SLIDE_IMMEDIATE);

        if (code == 200) {
        // everything went well
        }
    }

    function onSelect() 
    {
        var view = new Ui.ProgressBar("Waiting for GPS", null);
        var delegate = new MyAcquirePositionDelegate(view, self.method(:onPosition));

        Ui.pushView(view, delegate, Ui.SLIDE_IMMEDIATE);

        return true;
    }
}

