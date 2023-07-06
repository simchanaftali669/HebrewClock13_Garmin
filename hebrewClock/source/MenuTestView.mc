//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Application.Storage;


public var timer1;
public var timer2;
public var timer3;
public var count1 = 0;
public var count2 = 0;
public var count3 = 0;
//tekoa location
public var latitude = 31.656466;
public var longitude = 35.228143;
public var isJustOpened = true;

public function setPosition(info as Toybox.Position.Info) as Void
{
	System.println("got in setPosition");
	var myLocation = info.position.toDegrees();
	latitude = myLocation[0];
	longitude = myLocation[1];	  
	Storage.setValue("latitude", latitude);
	Storage.setValue("longitude", longitude);  
	WatchUi.requestUpdate();   
}

//! View for the home screen
class MenuTestView extends WatchUi.View {

 	var posnInfo = null;
    public function setPosition(info as Toybox.Position.Info) as Void
    {
		System.println("got in setPosition");
        var myLocation = info.position.toDegrees();
        latitude = myLocation[0];
        longitude = myLocation[1];	  
        Storage.setValue("latitude", latitude);
        Storage.setValue("longitude", longitude);  
        WatchUi.requestUpdate();   
    }
   
	public var londeg = 35;
	public var lonmin = 0;
	public var latdeg = 32;
	public var latmin = 0; 
 
    //public variables
    var latd = -1, latm = 0;  // lat on earth
    var lngd = -1, lngm = 0;  // long on earth
    var lat = 0, lng = 0;     // sun's location

    var ns, ew; 	// hemisphere
    var nsi, ewi;             
	public var timezone;
 
    var dst = 0; 	        // daylight saving time
    var ampm = false; 	    // am/pm or 24 hour display

    var monCount = [13, 1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366];

    var sunsetH;
    var sunsetM;
    var sunsetS;

	//need to insert to the public function that recive gps location
    var tz; //= (new Date().getTimezoneOffset() / -60); //current time zone

	public var shaa_zmanit_night,shaa_zmanit_day;
	
	public var lbSecond,lbMinute,lbHour; 
	public var displaySecond,displayMinute,displayHour; 
	public var oTimer;

	public var hebrewday;
	public var omer;

	public var tzeit;
	public var alot;
	public var curr_hour;
	public var sunset_hour;
	public var sunrise_hour;

	public var sunset_yasterdate;
	public var sunrise;
	public var sunset;
	public var sunrise_tommorow;

	public var mazalColor;

    //! Constructor
    public function initialize() {
        View.initialize();
    }


   public function callback1() as Void{
        //count1 += 1;
        WatchUi.requestUpdate();
    }

    public function callback2() {
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:setPosition));
        WatchUi.requestUpdate();
    }

    public function callback3() {
        count3 += 1;
        WatchUi.requestUpdate();
    }


    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.MainLayout(dc));
        timer1 = new Timer.Timer();
        timer1.start(method(:callback1), 1000, true);
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    public function onShow() as Void {
    }

	public function drawChristianClock()
	{			
   		var view = View.findDrawableById("ChristianClock") as Text;
		//view.setColor(Application.getApp().getProperty("color#mazal_02"));
		//view.setColor(Application.getApp().getProperty("ForegroundColor"));
		var myTime = System.getClockTime();
		view.setText( myTime.hour.format("%02d") + ":" + 
					  myTime.min.format("%02d") + ":" + 
					  myTime.sec.format("%02d"));		
	}

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {

    	//Application.Storage.clearValues();
    	if(Storage.getValue("latitude") != null)
    	{
    	    latitude = Application.Storage.getValue("latitude");
    		//latitude = str_latitude.toDouble();
			longitude = Application.Storage.getValue("longitude");
			//longitude = str_longitude.toDouble();
			//System.println("storage latitude:" + latitude);
		}
	
    	//initializeListener();
   		drawChristianClock();	
   		
   		//set the latitude and longtiude minutes and time zone for calculations
   		//list_pos();
   		
   		//activate the clock
   		oTimerclock();

        // Call the parent onUpdate public function to redraw the layout
        View.onUpdate(dc);
    }

	//my personal utils -- naftali bilig
	public function getYasterday(today)
	{
		var currentYear = today.year;
		var currentMonth = today.month;
		var currentDay = today.day;

		//current date
		var options = 
    	{
  		  :year   => today.year,
  		  :month  => today.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
   		  :day    => today.day,
          :hour   => 0
		};
				
		//yasterDay
		if(currentDay != 1)
		{
		 	options = 
	    	{
	  		  :year   => today.year,
	  		  :month  => today.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
	   		  :day    => today.day - 1,
	          :hour   => 0
			};
		}
		else
		{
			if(	currentMonth != 1)
			{
			 	options = 
		    	{
		  		  :year   => today.year,
		  		  :month  => today.month - 1, // 3.x devices can also use :month => Gregorian.MONTH_MAY
		   		  :day    => getLastDayOfMonth(today.year,today.month - 1),
		          :hour   => 0
				};			
			}
			else
			{
			 	options = 
		    	{
		  		  :year   => today.year - 1,
		  		  :month  => 12, // 3.x devices can also use :month => Gregorian.MONTH_MAY
		   		  :day    => getLastDayOfMonth(today.year - 1,12), //31
		          :hour   => 0
				};			
				
			}
		}
		
		var date = Gregorian.moment(options);
		var yasterday = Gregorian.info(date, Time.FORMAT_SHORT);
		
		return yasterday;    
	}
	
	
	public function getTomorrow(today)
	{
		var currentYear = today.year;
		var currentMonth = today.month;
		var currentDay = today.day;

		//current date
		var options = 
    	{
  		  :year   => today.year,
  		  :month  => today.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
   		  :day    => today.day,
          :hour   => 0
		};
				
		
		//tommorow
		if(!isLastDayOfMonth(today.year,today.month,today.day))
		{
		 	options = 
	    	{
	  		  :year   => today.year,
	  		  :month  => today.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
	   		  :day    => today.day + 1,
	          :hour   => 0
			};
		}
		else
		{
			if(	currentMonth != 12)
			{
			 	options = 
		    	{
		  		  :year   => today.year,
		  		  :month  => today.month + 1, // 3.x devices can also use :month => Gregorian.MONTH_MAY
		   		  :day    => 1,
		          :hour   => 0
				};			
			}
			else
			{
			 	options = 
		    	{
		  		  :year   => today.year + 1,
		  		  :month  => 1, // 3.x devices can also use :month => Gregorian.MONTH_MAY
		   		  :day    => 1, 
		          :hour   => 0
				};			
				
			}
		}
		
		var date = Gregorian.moment(options);
		var tomorrow = Gregorian.info(date, Time.FORMAT_SHORT);
		
		return tomorrow;	
	}

	public function isLastDayOfMonth(year,month,day)
	{
		return (day == getLastDayOfMonth(year,month));
	}

	public function getLastDayOfMonth(year,month)
	{
        var returnValue = 0;
		switch(month)
		{
			case 1:
				returnValue = 31;
				break;
			case 2:
				 if(leap(year))
				 {
				 	returnValue = 29;
				 }
				 else
				 {
				 	returnValue = 28;
				 } 
				 break;
			case 3:
				returnValue = 31;
				break;
			case 4:
				returnValue = 30;
				break;
			case 5:
				returnValue = 31;
				break;
			case 6:
				returnValue = 30;
				break;
			case 7:
				returnValue = 31;
				break;
			case 8:
				returnValue = 31;
				break;
			case 9:
				returnValue = 30;
				break;
			case 10:
				returnValue = 31;
				break;
			case 11:
				returnValue = 30;
				break;
			case 12:
				returnValue = 31;
				break;
		}

        return returnValue;
	}
	//----------------naftali bilig end------------------

	//my addition
	public function initializeListener() 
	{	
    	//Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );
	   	//Position.enableLocationEvents( Position.LOCATION_ONE_SHOT, method( :onPosition ) );
	 	//System.println(latitude);
	}
    
	public function onPosition( info ) 
	{
	    var myLocation = info.position.toDegrees();
	    latitude = myLocation[1];
	    longitude = myLocation[0];	    
	    //System.println("real latitude:" + latitude);
	    //System.println("real longitude:" + longitude);
	    
	    //hebrewClock();
	    //var latitude = 31.6622381;
		//var longitude = 35.217081;
	    //var view = View.findDrawableById("TimeLabel");
		//view.setColor(Application.getApp().getProperty("color#mazal_02"));
		//view.setColor(Application.getApp().getProperty("ForegroundColor"));
		//view.setText("22:1079:75");
	    
	    
	    //hebrewclock();
	    //_HebrewClockView.setLocation(myLocation[1], myLocation[0]);
	    //println(myLocation[0]);
	    //println(myLocation[0]);
	    //aa.latitude = myLocation[0];
	    //location.latitude = myLocation[0];
	    //_HebrewClockView.latitude = myLocation[0];
	    //_HebrewClockView.longitude = myLocation[1];
	    //location.longitude = myLocation[1];
 	}


    //------calculate public function----------
    //Dates.js
    //---get Date---
	/*
    public function set_default_date() 
	{
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

	    month = today.month;
	    day = today.day - 1;
	    year = today.year;

	    set_date_vars();
	}

	public function set_date_vars() 
	{	
	    var len = civMonthLength(month + 1, year);
	    if (day >= len) 
	    {
	        day = len - 1;
	    }
	}
*/

	public function civMonthLength(_month, _year) 
	{
	    if(_month == 2)
	    {
	        return (28 + _year);
	    }
	    else if (_month == 4 || _month == 6 || _month == 9 || _month == 11)
	    {
	        return 30;
	    }
	    else
	    {
	        return 31;
	    }
	}
    
	// Dst.js
	// daylight saving time
	public function set_dst() 
	{
   	 	dst = 0;    //the time zone is changes be default due to the year period	
	}
	
//	var dy;
//	var mn;
//	var yr;
//	var sundeg;
//	var sunmin; 
//	var londeg;
//	var lonmin;
//	//var ew, 
//	var latdeg;
//	var latmin; 
//	//var ns, 
//	var timezone;
	
	//SunTime.js
	public function suntime(dy,mn,yr,sundeg,sunmin,latitude,longitude) 
	{
	    //yr = 119;
	    //nsi = 0;
	    //lonmin = 51;
	    //latmin = 2.76;
	    
	    
  		//System.println("dy: " + dy + ", mn: " + mn + ", yr: " + yr);
    	//System.println("sundeg: " + sundeg + ", sunmin: " + sunmin);
    	//System.println("londeg: " + londeg + ", lonmin: " + lonmin + ", ewi:" + ewi);
    	//System.println("latdeg: " + latdeg + ", latmin: " + latmin + ", nsi:" + nsi);
    	//System.println("timezone: " + timezone);

	    var ret = [0, 0, 0, 0];
	
	    var invalid = 0;	// start out as OK
	
		//System.println("timezone:" + timezone);
		
		//longitude = longitude * ((ewi == 0) ? -1 : 1);
		//latitude = latitude * ((nsi == 0) ? 1 : -1);


		
		//var longitude = (londeg + lonmin / 60.0) * ((ewi == 0) ? -1 : 1);
		//var latitude = (latdeg + latmin / 60.0) * ((nsi == 0) ? 1 : -1);
	
	    var yday = doy(dy, mn, yr);
	
	    var A = 1.5708;
	    var B = 3.14159;
	    var C = 4.71239;
	    var D = 6.28319;
	    var E = 0.0174533 * latitude;
	    var F = 0.0174533 * longitude;
	    var G = 0.261799 * timezone;
	
	    var R = Math.cos(0.01745 * (sundeg + sunmin / 60.0));
	
	    var J;
	
	    var sr = 0, ss = 0;
	
	    // two times through the loop
	    //    i=0 is for sunrise
	    //    i=1 is for sunset
	    for (var i = 0; i < 2; i++) {
	
	        if (i == 0)
	       	{
	            J = A;	// sunrise
	        }
	        else
	        {
	            J = C;	// sunset
			}
			
	        var K = yday + ((J - F) / D);
	        var L = (K * .017202) - .0574039;              // Solar Mean Anomoly
	        var M = L + .0334405 * Math.sin(L);            // Solar True Longitude
	        M += 4.93289 + (3.49066E-04) * Math.sin(2 * L);
	
	        // Quadrant Determination
	        if (D == 0) {
	            //MessageBox.Show("Trying to normalize with zero offset...");
	            return ret;
	        }
	
	        while (M < 0)
	        {
	            M = (M + D);
			}
	        
	        while (M >= D)
	        {
	            M = (M - D);
			}
	        
	        if ((M / A) - Math.floor(M / A) == 0)
	        {
	            M += 4.84814E-06;
			}
			
	        var P = Math.sin(M) / Math.cos(M);                   // Solar Right Ascension
	        P = Math.atan2(.91746 * P, 1);
	
	        // Quadrant Adjustment
	        if (M > C)
	        {
	            P += D;
	        }
	        else 
	        {
	            if (M > A)
	            {
	                P += B;
	            }
	        }
	
	        var Q = .39782 * Math.sin(M);      // Solar Declination
	        Q = Q / Math.sqrt(-Q * Q + 1);     // This is how the original author wrote it!
	        Q = Math.atan2(Q, 1);
	
	        var S = R - (Math.sin(Q) * Math.sin(E));
	        S = S / (Math.cos(Q) * Math.cos(E));
	
	        if (S.abs() > 1)
	        {
	            invalid = 1;	// uh oh! no sunrise/sunset
			}	
			
	        S = S / Math.sqrt(-S * S + 1);
	        S = A - Math.atan2(S, 1);
	
	        if (i == 0)
	        {
	            S = D - S;	// sunrise
			}
			
	        var T = S + P - 0.0172028 * K - 1.73364;  // Local apparent time
	        var U = T - F;                            // Universal timer
	        var V = U + G;                            // Wall clock time
	
	        // Quadrant Determination
	        if (D == 0) 
	        {
	            //MessageBox.Show("Trying to normalize with zero offset...");
	            return ret;
	        }
	
	        while (V < 0)
	        {
	            V = V + D;
	        }
	        while (V >= D)
	        {
	            V = V - D;
	        }
	        V = V * 3.81972;
	
	        if (i == 0)
	        {
	            sr = V;	// sunrise
	        }
	        else
	        {
	            ss = V;	// sunset
	        }
	    }
	
		//System.println("sr: " + sr + ", ss: " + ss);
		

	
	    ret[1] = invalid;
	    ret[2] = sr;
	    ret[3] = ss;
	    return ret;
	}

	public function doy(d, m, y) 
	{
	    var num = (m > 2 && leap(y)) ? 1 : 0;
	
	    return monCount[m] + d + num;
	}
	
	public function leap(y) 
	{
	    return ((y % 400 == 0) || (y % 100 != 0 && y % 4 == 0));
	}
	
	//TimeAdj.js
	public function timeadj(t) 
	{
	    return timeadj_real(t, false);
	}
	
	public function timeadj_real(t, ampm) 
	{
	    var hour;
	    var min;
	
	    var time = t;
	
	    hour = Math.floor(time);
	    min = Math.floor((time - hour) * 60.0 + 0.5);
	
	    if (min >= 60) 
	    {
	        hour += 1;
	        min -= 60;
	    }
	
	    if (hour < 0)
	    {
	        hour += 24;
		}
		
	    var ampm_str;
	    if (ampm) 
	    {
	        ampm_str = (hour > 11) ? " PM" : " AM";
	        hour %= 12;
	        hour = (hour < 1) ? 12 : hour;
	    }
	    else
	    {
	        ampm_str = "";
		}
		
	    if (hour > 23)
	    {
	        hour -= 24;
		}
		
	    var str = hour + ":" + ((min < 10) ? "0" : "") + min + ampm_str;
	
	    return str;
	}
	
	public function timeadj1(t) 
	{
	    return timeadj1_real(t, false);
	}
	
	public function timeadj1_real(t, ampm) 
	{
	    var hour;
	    var min;
	    var sec;
		var milisec;
	
	    var time = t;
	
	    hour = Math.floor(time);
	    min = Math.floor((time - hour) * 60.0);
	    sec = Math.floor((((time - hour) * 60.0) - min) * 60.0);
	    milisec = Math.floor((((((time - hour) * 60.0) - min) * 60.0)-sec)*1000);
		
		//milisec = 2000;
		if(milisec >= 1000)
		{
			sec += 1;
			milisec /= 1000;
		}
			
	    if (sec >= 60) {
	        min += 1;
	        sec -= 60;
	    }
	
	    if (min >= 60) {
	        hour += 1;
	        min -= 60;
	    }
	
	    if (hour < 0)
	    {
	        hour += 24;
		}
		
	    var ampm_str;
	    if (ampm) {
	        ampm_str = (hour > 11) ? " PM" : " AM";
	        hour %= 12;  
	        hour = (hour < 1) ? 12 : hour;
	    }
	    else
	    {
	        ampm_str = "";
		}
		
	    if (hour > 23)
	    {
	        hour -= 24;
		}
		
		var milisec_str = ((milisec < 10) ? "000" + milisec : (milisec<100) ? "00" + milisec : "0" + milisec);
		var str = hour + ":" + ((min < 10) ? "0" : "") + min + ":" + ((sec < 10) ? "0" : "") + sec + ":" + milisec_str;
	    return str;
	}

	
	//set the sunset and sunrise
	public function doit() 
	{
	    //var nsi, ewi;
	    var i;
	
	
	    if (ns != "N")
	    {
	        nsi = 1;
	    }
	    else
	    {
	        nsi = 0;
		}
		
	    if (ns != "W")
	    {
	        ewi = 1;
	    }
	    else
	    {
	        ewi = 0;
		}
		
		
		//need to set it back to time zone
		var myTime = System.getClockTime(); // ClockTime object
		tz = myTime.timeZoneOffset/3600 + myTime.dst;

		//System.println("timeZoneOffset: " + );

		//tz = 2;
		//System.println("tzXXX: " + tz);

	    
	    //var adj = -(12 - tz);
	    //adj += 2;
		timezone = tz;
		
		//timezone = tz + 2;
	
	
	    var sunrise = 0, sunset, sunrise_tommorow, sunset_yasterdate;
	    var shaa_zmanit = 0;
	    var hour = [0,0,0,0]; //29
	
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var yasterday = getYasterday(today); //Gregorian.info(Time.now() - 1, Time.FORMAT_SHORT);	
	    var tomorrow = getTomorrow(today); //Gregorian.info(Time.now() + 1, Time.FORMAT_SHORT);
	
		
	
	
	    //the time of yasterday
	    var time_yasterday = [0, 0, 0, 0];
	    time_yasterday = suntime(yasterday.day, yasterday.month, yasterday.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);
	
	    //the time of the current day
	    var time_today = [0, 0, 0, 0];
	    time_today = suntime(today.day, today.month, today.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

//	    //the time of the next day
	    var time_tommorow = [0, 0, 0, 0];
	    time_tommorow = suntime(tomorrow.day, tomorrow.month, tomorrow.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

	    if (time_today[1] == 0) {
	        //sunrise_yasterdate = time_yasterday[2];
	        sunrise = time_today[2];
	        sunrise_tommorow = time_tommorow[2];
	        sunset_yasterdate = time_yasterday[3];
	        sunset = time_today[3];
	        
	        //System.println("sunrise: " + sunrise);
	        var sunset_tommorow = time_tommorow[3];
	
			hour[0] = sunset_yasterdate;
			hour[1] = sunrise;
			hour[2] = sunset;
			hour[3] = sunrise_tommorow;
			
	        shaa_zmanit = (sunset - sunrise) / 12;
	
	        //using current time in the computer to adjust the right secdule...
	        //get the time right now
			var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	        //var date = new Date();
	
	        var h = date.hour;
	        var minute = date.min;
	        var s = date.sec;
			var m = 500; //Sys.getTimer();
	        curr_hour = m + (s*1000) + (minute*60*1000) + (h*60*60*1000); 
	
	        var str = timeadj1(sunset);
	        var sunsetArray = splitStr(str,":");//str.split(":");
	        
	        
	        sunsetH = sunsetArray[0];
	        sunsetM = sunsetArray[1];
	        sunsetS = sunsetArray[2];
			var sunsetMili = sunsetArray[3];
	        
	        //System.println("sunsetH: " + sunsetArray[0] + ": sunsetM: " + sunsetArray[1] + ": sunsetS:" + sunsetArray[2] + ": sunsetMili:" + sunsetArray[3]);
	        sunset_hour =  sunsetMili.toNumber() + (sunsetS.toNumber())*1000 + (sunsetM.toNumber())*60*1000 + (sunsetH.toNumber())*60*60*1000;
			//-----------------------------------------------------------------
	
	        //document.getElementById("Masechet").value = shaa_zmanit_night;
	
	        //legnth of the shaa zmanit - night
	        //if (h > sunsetH || (h == sunsetH && minute > sunsetM) || (h == sunsetH && minute == sunsetM && s > sunsetS))
		    
			//document.getElementById("Sefer").value = sunrise_tommorow; 
			if(curr_hour > sunset_hour)
			{
				shaa_zmanit_night = (sunrise_tommorow + (24 - sunset)) / 12;
				sunrise_hour = sunrise_tommorow ;
	        }
	        else
	        {
	            shaa_zmanit_night = (sunrise + (24 - sunset_yasterdate)) / 12;
				sunrise_hour = sunrise;
			}
			//hour[25] = shaa_zmanit_night;
	
	        //legnth of the shaa zmanit - day
	        if(curr_hour > sunset_hour)
	        {
				shaa_zmanit_day = (sunset_tommorow - sunrise_tommorow) / 12;
	        }
	        else
	        {
				shaa_zmanit_day = (sunset - sunrise) / 12;
			}
			
		 
			var time_alot = [0, 0, 0, 0];
	 		//עלות השחר
			if( curr_hour > sunset_hour )
			{
				time_alot = suntime(tomorrow.day, tomorrow.month, tomorrow.year, 106, 6, latitude,longitude);
			}
			else
			{
				time_alot = suntime(today.day, today.month, today.year, 106, 6, latitude,longitude);
	        }
	        
	        if (time_alot[1] == 0)
	        {
	        	alot = time_alot[2];
			}
		   
		    var time_tzeit = [0, 0, 0, 0];
			//צאת הכוכבים
			time_tzeit= suntime(today.day, today.month, today.year, 96, 0,latitude,longitude);
			tzeit = time_tzeit[3];
			
	    }
	
	
	
	    return hour;
	
	}
	
    public function splitStr(str,delimiter)
    {
    	str = str + delimiter;
    	var strSplited = [0,0,0,0];
    	var strBeginIdx = 0;
    	var strSplitedCounter = 0;
		
		var i=0;
		var indexStart = 0;
		while(true)
		{
			if(i==4)
			{
				break;
			}
			
			var indexEnd = str.find(":"); 
	
			//System.println("indexStart:"  + indexStart  + "indexEnd: " +indexEnd); 
			var temp_str = str.substring(0, indexEnd-1);
			
		
			//System.println("temp_str: " + temp_str +"indexStart:"  + indexStart  + "indexEnd: " +indexEnd);
		
		
			var mySubString = temp_str;
			strSplited[i] = mySubString;
			i = i+1;
	
			indexStart = indexEnd+1;	
			str = str.substring(indexStart,str.length());
		}
				
		return strSplited;
    }
        
    //hebrewclock.js
	public function hebrewclock()
	{
        // Update the view
        //var view = View.findDrawableById("TimeLabel");
		//view.setColor(Application.getApp().getProperty("color#mazal_02"));
		//view.setColor(Application.getApp().getProperty("ForegroundColor"));
		//view.setText("23:1079:75");
		
		if(isJustOpened || lbMinute == 0)
		{
			var zmanit_hour = doit();       //get the 24 shaaotzmaniot
			
			sunset_yasterdate = zmanit_hour[0];
			sunrise = zmanit_hour[1];
			sunset = zmanit_hour[2];
			sunrise_tommorow = zmanit_hour[3];
		}

		var shaa_zmanit_night, shaa_zmanit_day;
	    
	    var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
		//var milisec = date.getMilliseconds();
	
		var curr_hour = /*milisec +*/ ((s.toNumber())*1000) + ((m.toNumber())*60*1000) + ((h.toNumber())*60*60*1000);
		
		curr_hour = curr_hour.toDouble()/(1000 * 3600);		
		
		//System.println("sunrise: " + sunrise + ", sunset:" + sunset);
		//System.println("curr_hour: " + curr_hour);
								
		//day
		if(curr_hour > sunrise && curr_hour < sunset)
		{
			var length = sunset - sunrise;
			var curr_hour_offset = curr_hour - sunrise;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
		    //System.println("minute : " + minute );
		    
			lbHour = hour+12;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
		}
		//night before 00:00
		else if( curr_hour > sunset)
		{
			var length = sunrise_tommorow + 24 - sunset;
			var curr_hour_offset = curr_hour - sunset;
			
			var hour = Math.floor(12* (curr_hour_offset/length));
			var minute = Math.floor(12 * 1080 * (curr_hour_offset / length)) - hour*1080;
			var second = Math.floor(12 * 1080 * 76 * (curr_hour_offset / length)) - (hour * 1080 * 76) - (minute * 76);
	
			lbHour = hour;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
		}
		//night after 00:00
		else if(curr_hour < sunrise)
		{
			var length = sunrise + 24 - sunset_yasterdate;
			var curr_hour_offset = curr_hour + 24 - sunset_yasterdate;
			
			var hour = Math.floor(12* (curr_hour_offset/length));
			var minute = Math.floor(12 * 1080 * (curr_hour_offset / length)) - hour*1080;
			var second = Math.floor(12 * 1080 * 76 * (curr_hour_offset / length)) - (hour * 1080 * 76) - (minute * 76);
			
			lbHour = hour;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
		}
		
		display_time();
		
		if(isJustOpened)
		{
			setmazal();
			isJustOpened = false;
		}
		
		if(lbMinute == 0)
	    {
			setmazal();	
		}
		
		MarkTime();
	    //if(lbMinute == 0 || lbMinute == 360 || lbMinute == 720)
	    //    tick_sound();
	}

	public function MarkTime()
	{
		var view = View.findDrawableById("HebrewClock") as Text;

 		System.println("curr_hour: " + curr_hour.toDouble()/(1000 * 3600));
 		System.println("tzeit: " + tzeit);
 		System.println("alot: " + alot);



		if(curr_hour.toDouble()/(1000 * 3600) > tzeit  || 
		   curr_hour.toDouble()/(1000 * 3600) < alot)
		{
			view.setColor(Graphics.COLOR_LT_GRAY);
			//viewMazal.setText("Marriv");
			//viewMazal.setText("ערבית - " + text);
		}
		else if(curr_hour.toDouble() < sunset_hour.toDouble() && 
		        curr_hour.toDouble()/(1000 * 3600) > alot/*curr_hour.toDouble() > sunrise_hour.toDouble()*/ )
		{
			view.setColor(Graphics.COLOR_BLUE);

			if(curr_hour.toDouble() < sunrise_hour.toDouble() || lbHour.toNumber() < 6)
			{ 
				//viewMazal.setText("Shacharit");			
				//viewMazal.setText("שחרית - " + text);
			}
			else if(lbHour.toNumber() > 6 || (lbHour.toNumber() == 6 && lbMinute.toNumber() >= 540)) 
			{
				//viewMazal.setText("Mincha");
				//viewMazal.setText("מנחה - " + text);
			}			
		}
	}	
	
	//---clock timer---
	public function oTimerclock() 
	{
		//initializeListener();
		hebrewclock();
		//oTimer = new Timer.Timer();
    	//oTimer.start(method(:hebrewclock), 1000, true);
	}
	
	
	public function display_time()
	{
	
		//setmazal();
		//---displaying the clock---
		//second
	    if (lbSecond < 10)
	    {
	        displaySecond = "0" + lbSecond.toNumber();
	    }
	    else
	    {
	        displaySecond = lbSecond.toNumber();
		}
	    //minute
	    if (lbMinute < 10)
	    {
	        displayMinute = "000" + lbMinute.toNumber();
	    }
	    else if (lbMinute < 100)
	    {
	        displayMinute = "00" + lbMinute.toNumber();
	    }
	    else if (lbMinute < 1000)
	    {
	        displayMinute = "0" + lbMinute.toNumber();
	    }
	    else
	    {
	        displayMinute = lbMinute.toNumber();
		}
		
		var templbHour = lbHour; 		
		lbHour = lbHour.toNumber() % 12;
		
		//hour
	    if (lbHour < 10)
	    { 
	        displayHour = "0" + lbHour.toNumber();
	    }
	    else
	    {
	        displayHour = lbHour.toNumber();
		}
	
		lbHour = templbHour;
			
		var view = View.findDrawableById("HebrewClock") as Text;
		view.setText(displayHour + ":" + displayMinute +  ":" + displaySecond);
		
	}
 
 	public function getDayOfWeekInNumber(day)
 	{
 		//System.println("day: " + day);
        var returnValue = 0;
 		switch(day)
 		{
  			case "א'":
  			case "Sun":
 				returnValue = 1;
 				break;
 			case "ב'":
 			case "Mon":
 				returnValue = 2;
 				break;
 			case "ג'":
 			case "Tue":
 				returnValue = 3;
 				break;
 			case "ד'":
 			case "Wed":
 				returnValue = 4;
 				break;
 			case "ה'":
 			case "Thu":
 				returnValue = 5;
 				break;
 			case "ו'":
 			case "Fri":
 				returnValue = 6;
 				break;
  			case "ז'":
  			case "Sat":
 				returnValue = 7;
 				break; 		
 		}

        return returnValue;
 	
 	}
 
 
    //mazal of the hour
	public function setmazal() {
	    var date =  Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
	
	    var day = getDayOfWeekInNumber(date.day_of_week);
	    var clockHour = lbHour;
	    if (clockHour == 24)
	    {
	        clockHour = 0;
		}
		
	    if ((h.toNumber() == sunsetH.toNumber() && m.toNumber() == sunsetM.toNumber() && s.toNumber() >= sunsetS.toNumber()) ||    // אחרי שקיעה
	        (h.toNumber() == sunsetH.toNumber() && m.toNumber() > sunsetM.toNumber()) ||
	        (h.toNumber() > sunsetH.toNumber())
	       )
	    {
	        if ((h.toNumber() == 23 && m.toNumber() == 23 && s.toNumber() <= 59) ||    // לפני חצות
	            (h.toNumber() == 23 && m.toNumber() < 59) ||
	            (h.toNumber() < 23)
	           )
	        {
	            day = day + 1;
	        }
		}
	    
	
	    //document.getElementById("test").value = h > sunsetH;
	
	    if (day == 8)
	    {
	        day = 1;
		}
		
		//day = mazal_offset(day);
		//System.println("clockHour: " + clockHour);
		
	    hebrewday = day;
	
		var mida;
		var deviceSettings = System.getDeviceSettings();
		// it is safe to access the language
		if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
		{
	    	mida = ["שבתאי", "צדק", "מאדים", "חמה", "נוגה", "כוכב", "לבנה"];
		}
		else
		{
	    	mida = ["Saturn", "Jupiter", "Mars", "Sun", "Venus", "Mercury", "Moon"];
		}

		var x = 0;
	    if (hebrewday == 1)
	    {
	        x = (6 + clockHour.toNumber()) % 7;
	    }
	    if (hebrewday == 2)
	    {
	        x = (2 + clockHour.toNumber()) % 7;
	    }
	    if (hebrewday == 3)
	    {
	        x = (5 + clockHour.toNumber()) % 7;
	    }
	    if (hebrewday == 4)
	    {
	        x = (1 + clockHour.toNumber()) % 7 ;
	    }
	    if (hebrewday == 5)
	    {
	        x = (4 + clockHour.toNumber()) % 7 ;
	    }
	    if (hebrewday == 6)
	    {
	        x = (7 + clockHour.toNumber()) % 7 ;
	    }
	    if (hebrewday == 7)
	    {
	        x = (3 + clockHour.toNumber()) % 7;
        }	
		var view = View.findDrawableById("HebrewClock") as Text;
		var viewMazal = View.findDrawableById("MazalLabel") as Text;
		
		//System.println("hebrewday: " + hebrewday);
		//System.println("x: " + x);
		
		//System.println("day: " + day);
		
		var text = "";
		switch (x) 
		{
			case (0):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("#0070c0");
				//mazalColor = "#0070c0";
				//view.setColor(Application.getApp().getProperty("color#mazal_07"));		
				//viewMazal.setText("Moon");
				viewMazal.setText(mida[6]);
			 	text = mida[6];
				//document.body.style.backgroundImage = "url('pic/1.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 1;
				break;
			case (1):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("red");
				//mazalColor ="red";
				//view.setColor(Application.getApp().getProperty("color#mazal_01"));
				//viewMazal.setText("Saturn");
				viewMazal.setText(mida[0]);
				text = mida[0];
				//document.body.style.backgroundImage = "url('pic/2.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 2;
				break;
			case (2):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("#800cb0")
				//mazalColor = "#800cb0";
				//document.body.style.backgroundImage = "url('pic/3.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 3;
				//view.setColor(Application.getApp().getProperty("color#mazal_02"));
				//viewMazal.setText("Jupiter");				
				viewMazal.setText(mida[1]);
				text = mida[1];
				break;
			case (3):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("#00b050");
				//document.body.style.backgroundImage = "url('pic/4.jpg')";
				//mazalColor = "#00b050";
				//omer = ((day.toNumber() - 1) * 7) + 4;
				//view.setColor(Application.getApp().getProperty("color#mazal_03"));
				//viewMazal.setText("Mars");
				viewMazal.setText(mida[2]);
				text = mida[2];
				break;
			case (4):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("#fff82b");
				//mazalColor = "#fff82b";
				//document.body.style.backgroundImage = "url('pic/5.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 5;
				//view.setColor(Application.getApp().getProperty("color#mazal_04"));
				//viewMazal.setText("Sun");
				viewMazal.setText(mida[3]);
				text = mida[3];
				break;
			case (5):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("orange");
				//mazalColor = "orange";
				//document.body.style.backgroundImage = "url('pic/6.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 6;
				//view.setColor(Application.getApp().getProperty("color#mazal_05"));
				//viewMazal.setText("Venus");
				viewMazal.setText(mida[4]);
				text = mida[4];
				break;
			case (6):
				//document.getElementById("Mazal").innerText = day_mida[day - 1];
				//paintText("#929292");
				//mazalColor = "#929292";
				//document.body.style.backgroundImage = "url('pic/7.jpg')";
				//omer = ((day.toNumber() - 1) * 7) + 7;
				//view.setColor(Application.getApp().getProperty("color#mazal_06"));
				//viewMazal.setText("Mercury");
				viewMazal.setText(mida[5]);
				text = mida[5];
				break;
			default:
				break;
		}
						
		//viewMazal.setText("");
//		System.println("curr_hour: " + curr_hour.toDouble()/(1000 * 3600));
//		System.println("tzeit: " + tzeit  );
//		System.println("alot: " + alot);
		//view.setColor(mazalColor);
		//viewMazal.setText(date.day_of_week);
	}
	
	public function paintText(p_color)
	{
//		var clockInputs = document.getElementsByClassName("clock");
//		for(var i=0 ; i< clockInputs.length ; i++)
//			clockInputs[i].style.color = p_color;
	}


	//Location.js
	//set the latitude and longtiude minutes and time zone for calculations
	public function list_pos() 
    {
        if (latitude > 0)
        {
            ns = "N";
        }
        else
        {
            ns = "S";
        }
        latd = Math.floor(latitude);
        latm = ((latitude - latd) * 60);
        if (longitude > 0)
        {
            ew = "E";
        }
        else
        {
            ew = "W";
        }
        lngd = Math.floor(longitude);
        lngm = ((longitude - lngd) * 60);
        //    var _tz = tz;
        //
        //
        //    if ((latd != -1) && (lngd != -1)) {
        //        tz = 12 + _tz;
        //        //doit();
        //    }
        }


    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    public function onHide() as Void {
    }
}
