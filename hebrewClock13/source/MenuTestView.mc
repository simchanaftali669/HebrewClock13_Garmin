//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Graphics;
import Toybox.Lang;
//import Toybox.Sensor;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Application.Storage;
import Toybox.System;


public var timer1;
public var timer2;
public var timer3;
public var count1 = 0;
public var count2 = 0;
public var count3 = 0;

//Jerusalem
public var latitude = 31.7768514;
public var longitude = 35.2331664;

public var isJustOpened = true;
public var isMoonClock = false;

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
class MenuTestView extends WatchUi.View 
{
	private var _hrString as String = "";

	var sunCalc = new SunCalc();
	var isMoonClock = false;

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
   
    public function showBirth() as Void
    {
		isBirth = true;
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	

		var language = language();
		var hebrew_month_name = hebrewDateFunc(today.year, today.month, today.day, language());
		var viewHebrewDate = View.findDrawableById("ChristianClock") as Text;		
		viewHebrewDate.setText(hebrew_month_name[2] + hebrew_month_name[3]);	

		//var birthHebrewHour = View.findDrawableById("HebrewClock") as Text;
		var birthHebrewMazal = View.findDrawableById("MazalLabel") as Text;
		
		System.println("birth measure: " + hebrew_month_name[2] + hebrew_month_name[3]);
		System.println("birth measure: " + display_time());
		System.println("birth measure: " + setmazal());

		Storage.setValue("birthHebrewDate", hebrew_month_name[2] + hebrew_month_name[3]);
		Storage.setValue("birthHebrewHour", display_time());
		Storage.setValue("birthHebrewMazal", setmazal());
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

	var sunsetH_man;
	var sunsetM_man;
	var sunsetS_man;

    var sunsetH;
    var sunsetM;
    var sunsetS;

	//need to insert to the public function that recive gps location
    var tz; //= (new Date().getTimezoneOffset() / -60); //current time zone


	public var shaa_zmanit_night,shaa_zmanit_day;
	public var lbSecond,lbMinute,lbHour; 
	public var lbSecond_man, lbMinute_man,lbHour_man;
	public var displaySecond,displayMinute,displayHour; 
	public var oTimer;

	public var hebrewday_man;
	public var hebrewday;
	public var omer;

	public var curr_hour_man;

	public var fajar;
	public var atzer;
	public var isha;

	public var tzeit;
	public var alot;
	public var misheyakir;
	public var curr_hour;
	public var sunset_hour;
	public var sunrise_hour;

	public var sunrise_yasterday_man;
	public var sunrise_man;
	public var sunrise_tommorow_man;
	public var sunset_yasterday_man;
	public var sunset_man;
	public var sunset_tommorow_man;

	public var sunrise_yasterday;
	public var sunrise;
	public var sunrise_tommorow;
	public var sunset_yasterday;
	public var sunset;
	public var sunset_tommorow;

	public var mazalColor;

/*1*/ public var birkutHashahar; // -- ברכות השחר  
/*2*/ public var patachEliyaou;  // -- פתח אליהו
/*3*/ public var korbanot;		// -- קורבנות
/*4*/ public var psokeiDzimra;	// -- פסוקי דזמרה
/*5*/ public var nishmat = -1; 		// -- נשמת כל חי
/*6*/ public var yozerOr;		//  -- יוצר אור
/*7*/ public var kriyahtShema;	//  -- קריאת שמע

	public var SOLAR_DECLINATION;

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


		if(Storage.getValue("showBirth") == true && !isJustOpened)
		{
			showBirth();
			var birthHebrewDate_val = Storage.getValue("birthHebrewDate");
			var birthHebrewHour_val = Storage.getValue("birthHebrewHour");
			var birthHebrewMazal_val = Storage.getValue("birthHebrewMazal");
            

			var viewHebrewDate = View.findDrawableById("ChristianClock") as Text;		
			var birthHebrewHour = View.findDrawableById("HebrewClockHour") as Text;

			var birthHebrewMazal = View.findDrawableById("MazalLabel") as Text;

            viewHebrewDate.setText(birthHebrewDate_val);
            birthHebrewHour.setText(birthHebrewHour_val);
            birthHebrewMazal.setText(birthHebrewMazal_val);

			if(Storage.getValue("isMoonClock") != null && Application.Storage.getValue("isMoonClock") == true)
			{
				switch(birthHebrewMazal)
				{
					case "Jupiter":
					case "צדק":
						birthHebrewHour.setColor(Graphics.COLOR_BLUE);
						break;
					case "Mars":
					case "מאדים":
						birthHebrewHour.setColor(Graphics.COLOR_RED);
						break;
					case "Sun":
					case "חמה":
						birthHebrewHour.setColor(Graphics.COLOR_PURPLE);
						break;
					case "Saturn":
					case "שבתאי":
						birthHebrewHour.setColor(Graphics.COLOR_GREEN);
						break;
					case "Venus":
					case "נוגה":
						birthHebrewHour.setColor(0xFFFF00);
						break;
					case "Mercury":
					case "כוכב":
						birthHebrewHour.setColor(Graphics.COLOR_ORANGE);
						break;
					case "Moon":
					case "לבנה":
						birthHebrewHour.setColor(Graphics.COLOR_LT_GRAY);
						break;
				}
			}
		}
		else
		{
			isBirth = false;
		}

    	if(Storage.getValue("isMoonClock") != null)
    	{
    	    isMoonClock = Application.Storage.getValue("isMoonClock");
		}

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
		if(!isBirth)
   		{
			drawChristianClock();	
		}
   		//set the latitude and longtiude minutes and time zone for calculations
   		//list_pos();
   		
   		//activate the clock
   		oTimerclock();

        // Call the parent onUpdate public function to redraw the layout
        View.onUpdate(dc);
    }

	//my personal utils -- naftali bilig
	public function getYasterday(today, type)
	{
		var currentYear = today.year;
		var currentMonth = today.month;
		var currentDay = today.day;

		var options = null;

		//current date
		options = 
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
		

		if(type == "Moment")
		{
			return Gregorian.moment(options);    
		}
		else 
		{
			var date = Gregorian.moment(options);
			var yasterday = Gregorian.info(date, Time.FORMAT_SHORT);
			return yasterday;
		}
	}

	public function getToday(today, type)
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

		if(type == "Moment")
		{
			return Gregorian.moment(options);    
		}
		else 
		{
			var date = Gregorian.moment(options);
			var yasterday = Gregorian.info(date, Time.FORMAT_SHORT);
			return yasterday;
		}
	}

	public function getTomorrow(today,type)
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
		
		if(type == "Moment")
		{
			return Gregorian.moment(options);    
		}
		else 
		{
			var date = Gregorian.moment(options);
			var tomorrow = Gregorian.info(date, Time.FORMAT_SHORT);
			return tomorrow;
		}	
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
	
	// // פונקציה לדימוי חישוב זמן חצות שמשי
    // function getSolarNoon(latitude, longitude, date) {
    //     return Time.Gregorian.info(date).toLocal(12, 0, 0);
    // }
    
    // // פונקציה לחישוב נטיית השמש (declination)
    // function getSolarDeclination(latitude, longitude, time) {
    //     // כאן ניתן לשלב חישוב אסטרונומי מדויק יותר
    //     return 23.44 * Math.sin(degreesToRadians((360/365) * (Time.Gregorian.getDayOfYear(time) - 81)));
    // }

	// function calculateAsrAngle(latitude, longitude, date) {
    //     var noonTime = getSolarNoon(latitude, longitude, date);
    //     var solarDeclination = getSolarDeclination(latitude, longitude, noonTime);
        
    //     // חישוב זווית השמש בזמן תפילת עצ'ר
    //     var shadowLength = 1.0; // לפי ההגדרה: אורך הצל = אורך הגוף
    //     var tangent = Math.abs(latitude - solarDeclination);
    //     var inverse = shadowLength + Math.tan(degreesToRadians(tangent));
    //     var thetaAsr = radiansToDegrees(Math.atan(1.0 / inverse));
        
    //     return thetaAsr;
    // }

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
		Storage.setValue("tz", tz);

		//timezone = tz + 2;
	
	
		var sunrise_yasterday;
        var sunrise;
        var sunrise_tommorow;
        var sunset_yasterday;
        var sunset;
        var sunset_tommorow;

	    var shaa_zmanit = 0;
	    var hour = [0,0,0,0,0,0]; //29

		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var yasterday = getYasterday(today,"info"); //Gregorian.info(Time.now() - 1, Time.FORMAT_SHORT);	
	    var tomorrow = getTomorrow(today,"info"); //Gregorian.info(Time.now() + 1, Time.FORMAT_SHORT);

		//var yasterday = sunCalc.getMoonTimes(yasterday,latitude,longitude);
	
	    //the time of yasterday
	    var time_yasterday = [0, 0, 0, 0];
	    var time_today = [0, 0, 0, 0];
	    var time_tommorow = [0, 0, 0, 0];

		if(!isMoonClock)
		{
			time_yasterday = suntime(yasterday.day, yasterday.month, yasterday.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

			//the time of the current day
			time_today = suntime(today.day, today.month, today.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

		    //the time of the next day
			time_tommorow = suntime(tomorrow.day, tomorrow.month, tomorrow.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);
		}	
		else	
		{
			Storage.setValue("year", yasterday.year);
			Storage.setValue("month", yasterday.month);
			Storage.setValue("day", yasterday.day);
			time_yasterday = sunCalc.getMoonTimes(latitude,longitude,false);

			Storage.setValue("year", today.year);
			Storage.setValue("month", today.month);
			Storage.setValue("day", today.day);
			//the time of the current day
			time_today = sunCalc.getMoonTimes(latitude,longitude,false);//, lngd, lngm, ewi, latd, latm, nsi, adj);

			Storage.setValue("year", tomorrow.year);
			Storage.setValue("month", tomorrow.month);
			Storage.setValue("day", tomorrow.day);
		    //the time of the next day
			time_tommorow = sunCalc.getMoonTimes(latitude,longitude,false);//, lngd, lngm, ewi, latd, latm, nsi, adj);
		}

			System.println(time_today[3]);
	    //if (time_today[1] == 0) {
	        //sunrise_yasterdate = time_yasterday[2];
			sunrise_yasterday = time_yasterday[2];
			sunrise = time_today[2];
			sunrise_tommorow = time_tommorow[2];
			sunset_yasterday = time_yasterday[3];
			sunset = time_today[3];
			sunset_tommorow = time_tommorow[3];
	        
	        //System.println("sunrise: " + sunrise);	
			hour[0] = sunrise_yasterday;
			hour[1] = sunrise;
			hour[2] = sunrise_tommorow;
			hour[3] = sunset_yasterday;
			hour[4] = sunset;
			hour[5] = sunset_tommorow;
			
	        System.println("hour[0]: " + hour[0]);	
	        System.println("hour[1]: " + hour[1]);	
	        System.println("hour[2]: " + hour[2]);	
	        System.println("hour[3]: " + hour[3]);	
	        System.println("hour[4]: " + hour[4]);	
	        System.println("hour[5]: " + hour[5]);	


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
				shaa_zmanit_night = ((sunrise_tommorow + (24 - sunset)) / 12).abs();
				sunrise_hour = sunrise_tommorow ;
	        }
	        else
	        {
	            shaa_zmanit_night = ((sunrise + (24 - sunset_yasterday)) / 12).abs();
				sunrise_hour = sunrise;
			}
			//hour[25] = shaa_zmanit_night;
	
	        //legnth of the shaa zmanit - day
	        if(curr_hour > sunset_hour)
	        {
				shaa_zmanit_day = ((sunset_tommorow - sunrise_tommorow) / 12).abs();
	        }
	        else
	        {
				shaa_zmanit_day = ((sunset - sunrise) / 12).abs();
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

			var time_misheyakir = [0,0,0,0];
			//משיכיר
			if( curr_hour > sunset_hour )
			{
				time_misheyakir = suntime(tomorrow.day, tomorrow.month, tomorrow.year, 101, 0, latitude, longitude);
			}
			else
			{
				time_misheyakir = suntime(today.day, today.month, today.year, 101, 0, latitude, longitude);
			}

			if (time_misheyakir[1] == 0)
			{
				misheyakir = time_misheyakir[2];
			}
		    
			var time_tzeit = [0, 0, 0, 0];
			//צאת הכוכבים
			time_tzeit= suntime(today.day, today.month, today.year, 96, 0,latitude,longitude);
			tzeit = time_tzeit[3];
			
			var time_fajar = [0, 0, 0, 0];
			//פאג'אר
			time_fajar= suntime(tomorrow.day, tomorrow.month, tomorrow.year, 108, 0,latitude,longitude);
			fajar = time_fajar[2];

			//עצ'ר
			var yday = doy(today.day,today.month, today.year);
			var atzerAngle = 90 - calculateAsrAngle(latitude,longitude,yday);

			var time_atzer = [0, 0, 0, 0];
			time_atzer= suntime(today.day, today.month, today.year, atzerAngle, 0,latitude,longitude);
			atzer = time_atzer[3];

			var time_isha = [0, 0, 0, 0];
			//אשעא
			time_isha= suntime(today.day, today.month, today.year, 108, 0,latitude,longitude);
			isha = time_isha[3];

			var shortDate =  Gregorian.info(Time.now(), Time.FORMAT_SHORT);

			//System.println(day);
			if (shortDate.day_of_week == 7 || IsMoed())
			{ 
				System.println("Shabat");
				birkutHashahar = sunrise - 1; // 	 60 regular minutes before sunrise -- ברכות השחר
				patachEliyaou = sunrise - (56.toDouble())/(60.toDouble());// =  timeadj(s2 - 38/60, ampm); // 56 regular minutes before sunrise -- פתח אליהו
				korbanot = sunrise - (53.toDouble())/(60.toDouble());// = 		 timeadj(s2 - 35/60, ampm);	// 53 regular minutes before sunrise -- קורבנות
				psokeiDzimra = sunrise - (40.toDouble())/(60.toDouble());// =   timeadj(s2 - 22/60, ampm); // 40 regular minutes before sunrise -- פסוקי דזמרה
				nishmat = sunrise - (15.toDouble())/(60.toDouble()); // =   	 timeadj(s2 - 15/60, ampm); // 15 regular minutes before sunrise -- נשמת כל חי
				yozerOr = sunrise - (10.toDouble())/(60.toDouble());// =	     timeadj(s2 - 8/60, ampm);  // 10 regular minutes before sunrise -- יוצר אור
				kriyahtShema = sunrise - (4.toDouble())/(60.toDouble());// =    timeadj(s2 - 4/60, ampm);	// 04 regular minutes before sunrise -- קריאת שמע
			}
			else
			{
				System.println("Chol");
				birkutHashahar = sunrise - (42.toDouble())/(60.toDouble()); //  42 regular minutes before sunrise -- ברכות השחר
				patachEliyaou = sunrise - (38.toDouble())/(60.toDouble());// =  timeadj(s2 - 38/60, ampm); // 38 regular minutes before sunrise -- פתח אליהו
				korbanot = sunrise - (35.toDouble())/(60.toDouble());// = 		 timeadj(s2 - 35/60, ampm);	// 35 regular minutes before sunrise -- קורבנות
				psokeiDzimra = sunrise - (22.toDouble())/(60.toDouble());// =   timeadj(s2 - 22/60, ampm); // 22 regular minutes before sunrise -- פסוקי דזמרה
				nishmat = -1;
				yozerOr = sunrise - (8.toDouble())/(60.toDouble());// =	     timeadj(s2 - 8/60, ampm);  // 08 regular minutes before sunrise -- יוצר אור
				kriyahtShema = sunrise - (4.toDouble())/(60.toDouble());// =    timeadj(s2 - 4/60, ampm);	// 04 regular minutes before sunrise -- קריאת שמע
				
				//window.location.href = "en/Shabat/index.html";
			}
	    //}
	
	
	
	    return hour;
	
	}
	
	function abs(val)
	{
		if(val<0)
		{
			return val * -1;
		}
		else
		{
			return val;
		}
	}

    // חישוב זווית השמש בזמן תפילת עצ'ר ליום נתון
    function calculateAsrAngle(latitude, longitude, dayOfYear) {
        var declination = 23.44 * Math.sin(Math.toRadians((360.0 / 365.0) * (dayOfYear - 81)));
        var thetaNoon = 90.0 - abs(latitude - declination);
        var shadowLength = 1.0; // ההגדרה של עצ'ר: אורך הצל שווה לגובה הגוף
        var S0 = 1.0 /  Math.tan(Math.toRadians(thetaNoon));
        var thetaAsr = Math.toDegrees( Math.atan(1.0 / (shadowLength + S0)));
        
        return thetaAsr;
    }

	function IsMoed()
	{
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	
		var hebrew_month_name = hebrewDateFunc(today.year, today.month, today.day, "Hebrew");
		
		var isMoed = false;
		
		//System.println(hebrew_month_name[3]);
		// System.println(hebrew_month_name[3].equals(" בסיוון"));
		//System.println( hebrew_month_name[2].find("ב'") >= 0);
		// System.println(hebrew_month_name[2].equals("ו'"));

		isMoed = isMoed || (hebrew_month_name[3].equals(" בניסן") && 
							(hebrew_month_name[2].equals("ט\"ו") || hebrew_month_name[2].equals("כ\"א")));
		isMoed = isMoed || (hebrew_month_name[3].equals(" בסיוון") && 
		                    (hebrew_month_name[2].equals("ו'")) );
		isMoed = isMoed || (hebrew_month_name[3].equals(" בתשרי") && 
							(hebrew_month_name[2].equals("ט\"ו") || hebrew_month_name[2].equals("כ\"א") || hebrew_month_name[2].equals("כ\"ב") || hebrew_month_name[2].equals("א'") || hebrew_month_name[2].equals("ב'") || hebrew_month_name[2].equals("י'")));
		
		return isMoed;
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
        
	public function language()
	{
		var deviceSettings = System.getDeviceSettings();
		// it is safe to access the language
		var inputLang = "English";
		if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
		{
			inputLang = "Hebrew";
		}
		else
		{
			inputLang = "English";
		}

		return inputLang;
	}

	var isBirth = false;
	var isNight = false;
    //hebrewclock.js
	public function hebrewclock()
	{
		if(isBirth)
		{
			return;
		}
        // Update the view
        //var view = View.findDrawableById("TimeLabel");
		//view.setColor(Application.getApp().getProperty("color#mazal_02"));
		//view.setColor(Application.getApp().getProperty("ForegroundColor"));
		//view.setText("23:1079:75");



		if(isJustOpened || lbMinute == 0 || lbHour ==11 || lbHour == 0)
		{
			var zmanit_hour = doit();       //get the 24 shaaotzmaniot
			
			sunrise_yasterday = zmanit_hour[0];
			sunrise = zmanit_hour[1];
			sunrise_tommorow = zmanit_hour[2];
			sunset_yasterday = zmanit_hour[3];
			sunset = zmanit_hour[4];
			sunset_tommorow = zmanit_hour[5];

			System.println("zmanit_hour[0]: " + zmanit_hour[0]);
			System.println("zmanit_hour[1]: " + zmanit_hour[1]);
			System.println("zmanit_hour[2]: " + zmanit_hour[2]);
			System.println("zmanit_hour[3]: " + zmanit_hour[3]);
			System.println("zmanit_hour[4]: " + zmanit_hour[4]);
			System.println("zmanit_hour[5]: " + zmanit_hour[5]);
		}

		var shaa_zmanit_night, shaa_zmanit_day;
	    
	    var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
		//var milisec = date.getMilliseconds();
	
		var curr_hour = /*milisec +*/ ((s.toNumber())*1000) + ((m.toNumber())*60*1000) + ((h.toNumber())*60*60*1000);
		curr_hour = curr_hour.toDouble()/(1000 * 3600);		

		if(curr_hour > birkutHashahar && curr_hour < sunrise)
		{
			var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	

			var language = language();
			var hebrew_month_name = hebrewDateFunc(today.year, today.month, today.day, language());
			var viewHebrewDate = View.findDrawableById("ChristianClock") as Text;		
			viewHebrewDate.setText(hebrew_month_name[2] + hebrew_month_name[3]);	


			isNight = true;

			MarkTime();

			Tefila();
			return;
		}

		System.println("sunrise: " + sunrise + ", sunset:" + sunset);
		System.println("curr_hour: " + curr_hour);

		//month days 23-7						
		//case 1:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour between them.
		if(sunset > sunrise && curr_hour < sunset)
		{
			var length = sunset - sunrise;
			var curr_hour_offset = curr_hour - sunrise;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour+12;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = false;
		}
		//case 2:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour earlier.
		if(sunset > sunrise && curr_hour < sunrise)
		{
			var length = sunrise + 24-sunset_yasterday;
			var curr_hour_offset = curr_hour + 24-sunset_yasterday;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = true;
		}
		//case 3:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour after moonset.
		if(sunset > sunrise && curr_hour > sunset)
		{
			var length = sunrise_tommorow + 24-sunset;
			var curr_hour_offset = curr_hour - sunset;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = true;
		}
		//month days 07-23	
		//case 1:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour between them.
		if(sunset < sunrise  && curr_hour < sunrise)
		{
			var length = sunrise - sunset;
			var curr_hour_offset = curr_hour - sunset;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = true;
		}
		//case 2:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour earlier.
		if(sunset < sunrise && curr_hour < sunset)
		{
			var length = sunset + 24-sunrise_yasterday;
			var curr_hour_offset = curr_hour + 24-sunrise_yasterday;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour+12;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = false;
		}
		//case 3:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour after moonset.
		if(sunset < sunrise && curr_hour > sunrise)
		{
			var length = sunset_tommorow + 24-sunrise;
			var curr_hour_offset = curr_hour - sunrise;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour = hour+12;
			displayHour = lbHour;
			lbMinute = minute;
			displayMinute = lbMinute;
			lbSecond = second;
			displaySecond = lbSecond;
			
			isNight = false;
		}

		display_time();
		
		if(isJustOpened)
		{
			setmazal();
			isJustOpened = false;
		}
		
		//System.println("curr_hour : " + curr_hour);
		//System.println("tzeit : " + tzeit);

		if(lbMinute == 0 || (curr_hour >= tzeit && curr_hour < tzeit + 0.001))
	    {
			//System.println("setMazal");
			setmazal();	
		}
		
		MarkTime();
	    //if(lbMinute == 0 || lbMinute == 360 || lbMinute == 720)
	    //    tick_sound();

		/* preformance issue
		if(lbMinute == 0 || lbMinute == 270 || lbMinute == 540 || lbMinute == 810)
		{
			// Enable the heart rate sensor
			Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE] as Array<SensorType>);
			
			// Enable sensor events for one-time check
			Sensor.enableSensorEvents(method(:onSnsr));			
		}
		*/
	}

	//! Handle sensor updates
    //! @param sensorInfo Updated sensor data
    /*
	public function onSnsr(sensorInfo as Toybox.Sensor.Info) as Void 
	{
        var heartRate = sensorInfo.heartRate;
		
		if(heartRate != null && (heartRate < 25 || heartRate > 126)) 
		{
			isDeath = true;
			var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	

			var language = language();
			var hebrew_month_name = hebrewDateFunc(today.year, today.month, today.day, language());
			var viewHebrewDate = View.findDrawableById("ChristianClock") as Text;		
			viewHebrewDate.setText(hebrew_month_name[2] + hebrew_month_name[3]);	


			var deathHebrewHour = View.findDrawableById("HebrewClock") as Text;
			var deathHebrewMazal = View.findDrawableById("MazalLabel") as Text;
			
			System.println("death measure: " + hebrew_month_name[2] + hebrew_month_name[3]);
			System.println("death measure: " + display_time());
			System.println("death measure: " + setmazal());

			Storage.setValue("deathHebrewDate", hebrew_month_name[2] + hebrew_month_name[3]);
			Storage.setValue("deathHebrewHour", display_time());
			Storage.setValue("deathHebrewMazal", setmazal());
		}	

		// Disable the sensor by clearing the enabled sensors list
		Sensor.setEnabledSensors([]);  // Disable all sensors
    }
    */

	public function MarkTime()
	{
		//return;
		var viewHour = View.findDrawableById("HebrewClockHour") as Text;
		var viewMin = View.findDrawableById("HebrewClockMin") as Text;
		var viewSec = View.findDrawableById("HebrewClockSec") as Text;


		if(isMoonClock)
		{
			if(isNight)
			{
				var view1 = View.findDrawableById("MazalLabel") as Text;
				view1.setColor(Graphics.COLOR_LT_GRAY);
			}
			else
			{
				var view1 = View.findDrawableById("MazalLabel") as Text;
				view1.setColor(Graphics.COLOR_WHITE);
			}
			return;
		}

 		//System.println("curr_hour: " + curr_hour.toDouble()/(1000 * 3600));
 		//System.println("tzeit: " + tzeit);
 		//System.println("alot: " + alot);

		if(curr_hour.toDouble()/(1000 * 3600) > tzeit  || 
		   curr_hour.toDouble()/(1000 * 3600) < misheyakir)
		{
			viewHour.setColor(Graphics.COLOR_LT_GRAY);
			//viewMazal.setText("Marriv");
			//viewMazal.setText("ערבית - " + text);
		}
		else if(curr_hour.toDouble() < sunset_hour.toDouble() && 
		        curr_hour.toDouble()/(1000 * 3600) > misheyakir/*curr_hour.toDouble() > sunrise_hour.toDouble()*/ )
		{
			viewHour.setColor(Graphics.COLOR_BLUE);

			// if(curr_hour.toDouble() < sunrise_hour.toDouble() || lbHour.toNumber() < 6)
			// { 
			// 	//viewMazal.setText("Shacharit");			
			// 	//viewMazal.setText("שחרית - " + text);
			// }
			// else if(lbHour.toNumber() > 6 || (lbHour.toNumber() == 6 && lbMinute.toNumber() >= 540)) 
			// {
			// 	//viewMazal.setText("Mincha");
			// 	//viewMazal.setText("מנחה - " + text);
			// }			
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
		var displayMinute = 0;
		var displaySecond = 0;
		    
		//displayHour = 0;
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

		var viewHour = View.findDrawableById("HebrewClockHour") as Text;
		var viewMin = View.findDrawableById("HebrewClockMin") as Text;
		var viewSec = View.findDrawableById("HebrewClockSec") as Text;

		viewHour.setText(displayHour);
		viewMin.setText(displayMinute.toString());
		viewSec.setText(displaySecond.toString());
		//view.setText(displayHour + ":" + displayMinute +  ":" + displaySecond);
		return displayHour + ":" + displayMinute +  ":" + displaySecond;
	}
 
 	public function getDayOfWeekInNumber(day)
 	{
 		//System.println("day: " + day);
        var returnValue = 0;
 		switch(day)
 		{
  			case "א'":
  			case "Sun":
			case "Sunday":
 				returnValue = 1;
 				break;
 			case "ב'":
 			case "Mon":
			case "Monday":
 				returnValue = 2;
 				break;
 			case "ג'":
 			case "Tue":
			case "Tuesday":
 				returnValue = 3;
 				break;
 			case "ד'":
 			case "Wed":
			case "Wednesday":
 				returnValue = 4;
 				break;
 			case "ה'":
 			case "Thu":
			case "Thursday":
 				returnValue = 5;
 				break;
 			case "ו'":
 			case "Fri":
			case "Friday":
 				returnValue = 6;
 				break;
  			case "ז'":
  			case "Sat":
			case "Saturday":
 				returnValue = 7;
 				break; 		
 		}

        return returnValue;
 	
 	}
 
 
    //mazal of the hour
	public function setmazal() 
	{
		if(isMoonClock)
		{
			var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	
			var hebrew_month_name = hebrewDateFunc(today.year, today.month, today.day, language());
			var viewHebrewDate = View.findDrawableById("MazalLabel") as Text;
			viewHebrewDate.setText(hebrew_month_name[2] + hebrew_month_name[3]);
			//return;	
		}


	    var date =  Gregorian.info(Time.now(), Time.FORMAT_SHORT);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
	
	    var day = date.day_of_week;//getDayOfWeekInNumber(date.day_of_week);
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
	
	    if (!isMoonClock && day == 8)
	    {
	        day = 1;
		}
		
		//day = mazal_offset(day);
		//System.println("clockHour: " + clockHour);
		
	    hebrewday = day;
		
		if(isMoonClock)
		{
			hebrewday += hebrewDayOffset();
			if(hebrewday == 0)
			{
				hebrewday = 7;
			}
		}
		
		System.println("hebrewday: " + hebrewday);
		System.println("clockHour: " + clockHour);

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
		//var view = View.findDrawableById("HebrewClock") as Text;
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
				//viewMazal.setText(mida[6]);
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
				//viewMazal.setText(mida[0]);
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
				//viewMazal.setText(mida[1]);
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
				//viewMazal.setText(mida[2]);
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
				//viewMazal.setText(mida[3]);
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
				//viewMazal.setText(mida[4]);
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
				//viewMazal.setText(mida[5]);
				text = mida[5];
				break;
			default:
				break;
		}


		if(isMoonClock)
		{
			var colors = [	Graphics.COLOR_LT_GRAY,//Graphics.COLOR_LT_GRAY,
							Graphics.COLOR_GREEN,//Graphics.COLOR_GREEN,
							Graphics.COLOR_BLUE,//Graphics.COLOR_BLUE,
							Graphics.COLOR_RED,//Graphics.COLOR_RED,
							Graphics.COLOR_PURPLE,//Graphics.COLOR_PURPLE,
							0xFFFF00,//Graphics.COLOR_YELLOW,
							Graphics.COLOR_ORANGE];//Graphics.COLOR_ORANGE];
			
			var viewHour = View.findDrawableById("HebrewClockHour") as Text;
			viewHour.setColor(colors[x]);
			var viewMin = View.findDrawableById("HebrewClockMin") as Text;
			viewMin.setColor(colors[x]);
			var viewSec = View.findDrawableById("HebrewClockSec") as Text;
			viewSec.setColor(colors[x]);
			
			var viewHebrewDate = View.findDrawableById("MazalLabel") as Text;
			var viewChristianClock = View.findDrawableById("ChristianClock") as Text;
			if(isNight)
			{
				viewHebrewDate.setColor(Graphics.COLOR_LT_GRAY);
				viewChristianClock.setColor(Graphics.COLOR_LT_GRAY);
			}
			else
			{
				//viewHebrewDate.setColor(Graphics.COLOR_BLUE);
				//viewChristianClock.setColor(Graphics.COLOR_BLUE);
			}
		}
		else 
		{
			viewMazal.setText(text);	
		}

		return text;
		//viewMazal.setText("");
//		System.println("curr_hour: " + curr_hour.toDouble()/(1000 * 3600));
//		System.println("tzeit: " + tzeit  );
//		System.println("alot: " + alot);
		//view.setColor(mazalColor);
		//viewMazal.setText(date.day_of_week);
	}
	
	public function hebrewDayOffset()
	{
		hebrewclock4man();
		setmazal4man();

		//Man is leading
		if((hebrewday > hebrewday_man) || (hebrewday == 1 && hebrewday_man == 7))
		{
			return -1;
		}
		if((hebrewday == hebrewday_man) &&
			((lbHour > lbHour_man) || (lbHour == lbHour_man && lbMinute > lbMinute_man)))
		{
			return -1;
		}
		
		return 0;
	}

	public function setmazal4man()
	{
	    var date =  Gregorian.info(Time.now(), Time.FORMAT_SHORT);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
	
	    var day = date.day_of_week;//getDayOfWeekInNumber(date.day_of_week);
	    var clockHour = lbHour;
	    if (clockHour == 24)
	    {
	        clockHour = 0;
		}
		
	    if ((h.toNumber() == sunsetH_man.toNumber() && m.toNumber() == sunsetM_man.toNumber() && s.toNumber() >= sunsetS_man.toNumber()) ||    // אחרי שקיעה
	        (h.toNumber() == sunsetH_man.toNumber() && m.toNumber() > sunsetM_man.toNumber()) ||
	        (h.toNumber() > sunsetH_man.toNumber())
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
		
	    hebrewday_man= day;
	}

	public function doit4man() 
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
	
	
		var sunrise_yasterday;
        var sunrise;
        var sunrise_tommorow;
        var sunset_yasterday;
        var sunset;
        var sunset_tommorow;

	    var shaa_zmanit = 0;
	    var hour = [0,0,0,0,0,0]; //29

		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var yasterday = getYasterday(today,"info"); //Gregorian.info(Time.now() - 1, Time.FORMAT_SHORT);	
	    var tomorrow = getTomorrow(today,"info"); //Gregorian.info(Time.now() + 1, Time.FORMAT_SHORT);

		//var yasterday = sunCalc.getMoonTimes(yasterday,latitude,longitude);
	
	    //the time of yasterday
	    var time_yasterday = [0, 0, 0, 0];
	    var time_today = [0, 0, 0, 0];
	    var time_tommorow = [0, 0, 0, 0];


		time_yasterday = suntime(yasterday.day, yasterday.month, yasterday.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

		//the time of the current day
		time_today = suntime(today.day, today.month, today.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);

		//the time of the next day
		time_tommorow = suntime(tomorrow.day, tomorrow.month, tomorrow.year, 90, 50,latitude,longitude);//, lngd, lngm, ewi, latd, latm, nsi, adj);


			System.println(time_today[3]);
	    //if (time_today[1] == 0) {
	        //sunrise_yasterdate = time_yasterday[2];
			sunrise_yasterday_man = time_yasterday[2];
			sunrise_man = time_today[2];
			sunrise_tommorow_man = time_tommorow[2];
			sunset_yasterday_man = time_yasterday[3];
			sunset_man = time_today[3];
			sunset_tommorow_man = time_tommorow[3];
	        
	        //System.println("sunrise: " + sunrise);	
			hour[0] = sunrise_yasterday_man;
			hour[1] = sunrise_man;
			hour[2] = sunrise_tommorow_man;
			hour[3] = sunset_yasterday_man;
			hour[4] = sunset_man;
			hour[5] = sunset_tommorow_man;
			
	        var shaa_zmanit_man = (sunset_man - sunrise_man) / 12;
	
	        //using current time in the computer to adjust the right secdule...
	        //get the time right now
			var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	        //var date = new Date();
	
	        var h = date.hour;
	        var minute = date.min;
	        var s = date.sec;
			var m = 500; //Sys.getTimer();
	        curr_hour_man = m + (s*1000) + (minute*60*1000) + (h*60*60*1000); 
	
	        var str = timeadj1(sunset_man);
	        var sunsetArray = splitStr(str,":");//str.split(":");
	        
	        
	        sunsetH_man = sunsetArray[0];
	        sunsetM_man = sunsetArray[1];
	        sunsetS_man = sunsetArray[2];

			return hour;
			//var sunsetMili = sunsetArray[3];
	}

	public function hebrewclock4man()
	{
        // Update the view
        //var view = View.findDrawableById("TimeLabel");
		//view.setColor(Application.getApp().getProperty("color#mazal_02"));
		//view.setColor(Application.getApp().getProperty("ForegroundColor"));
		//view.setText("23:1079:75")f;
		
		var zmanit_hour = doit4man();       //get the 24 shaaotzmaniot
		
		sunrise_yasterday_man = zmanit_hour[0];
		sunrise_man = zmanit_hour[1];
		sunrise_tommorow_man = zmanit_hour[2];
		sunset_yasterday_man = zmanit_hour[3];
		sunset_man = zmanit_hour[4];
		sunset_tommorow_man = zmanit_hour[5];


		var shaa_zmanit_night, shaa_zmanit_day;
	    
	    var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
		//var milisec = date.getMilliseconds();
	
		var curr_hour_man = /*milisec +*/ ((s.toNumber())*1000) + ((m.toNumber())*60*1000) + ((h.toNumber())*60*60*1000);
		curr_hour_man = curr_hour.toDouble()/(1000 * 3600);		



		//System.println("sunrise: " + sunrise + ", sunset:" + sunset);
		//System.println("curr_hour: " + curr_hour);
								
		//month days 23-7						
		//case 1:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour between them.
		if(sunset_man > sunrise_man && curr_hour_man < sunset_man)
		{
			//System.println("1");
			var length = sunset_man - sunrise_man;
			var curr_hour_offset = curr_hour_man - sunrise_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour+12;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
		//case 2:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour earlier.
		if(sunset_man > sunrise_man && curr_hour_man < sunrise_man)
		{
			//System.println("2");
			var length = sunrise_man + 24-sunset_yasterday_man;
			var curr_hour_offset = curr_hour_man + 24-sunset_yasterday_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
		//case 3:
		//moonrise at 06:57 and moonset at 17:17
		//curr_hour after moonset.
		if(sunset_man > sunrise_man && curr_hour_man > sunset_man)
		{
			//System.println("3");
			var length = sunrise_tommorow_man + 24-sunset_man;
			var curr_hour_offset = curr_hour_man - sunset_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
		//month days 07-23	
		//case 1:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour between them.
		if(sunset_man < sunrise_man  && curr_hour_man < sunrise_man)
		{
			//System.println("4");
			var length = sunrise_man - sunset_man;
			var curr_hour_offset = curr_hour_man - sunset_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
		//case 2:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour earlier.
		if(sunset_man < sunrise_man && curr_hour_man < sunset_man)
		{
			//System.println("5");
			var length = sunset_man + 24-sunrise_yasterday_man;
			var curr_hour_offset = curr_hour_man + 24-sunrise_yasterday_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour+12;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
		//case 3:
		//moonrise at 13:05 and moonset at 00:00
		//curr_hour after moonset.
		if(sunset_man < sunrise_man && curr_hour_man > sunrise_man)
		{
			//System.println("6");
			var length = sunset_tommorow_man + 24-sunrise_man;
			var curr_hour_offset = curr_hour_man - sunrise_man;
			
			var hour = Math.floor((12*(curr_hour_offset/length)).toDouble());
			var minute = Math.floor((12 * 1080 * (curr_hour_offset / length)).toDouble()) - hour*1080;
			var second = Math.floor((12 * 1080 * 76 * (curr_hour_offset / length)).toDouble()) - (hour * 1080 * 76) - (minute * 76);
		    
			lbHour_man = hour+12;
			lbMinute_man = minute;
			lbSecond_man = second;
		}
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

	//------------------------HebrewDate---------------------
	
	/*!
	*      This script was taked from this page and ported to Node.js by Ionică Bizău
	*      http://www.shamash.org/help/javadate.shtml
	*
	*      This script was adapted from C sources written by
	*      Scott E. Lee, which contain the following copyright notice:
	*
	*      Copyright 1993-1995, Scott E. Lee, all rights reserved.
	*      Permission granted to use, copy, modify, distribute and sell so long as
	*      the above copyright and this permission statement are retained in all
	*      copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
	*
	*      Bill Hastings
	*      RBI Software Systems
	*      bhastings@rbi.com
	*/
	var GREG_SDN_OFFSET = 32045
		, DAYS_PER_5_MONTHS = 153
		, DAYS_PER_4_YEARS = 1461
		, DAYS_PER_400_YEARS = 146097;

	var HALAKIM_PER_HOUR = 1080
		, HALAKIM_PER_DAY = 25920
		, HALAKIM_PER_LUNAR_CYCLE = ((29 * HALAKIM_PER_DAY) + 13753)
		, HALAKIM_PER_METONIC_CYCLE = (HALAKIM_PER_LUNAR_CYCLE * (12 * 19 + 7));

	var HEB_SDN_OFFSET = 347997
		, NEW_MOON_OF_CREATION = 31524
		, NOON = (18 * HALAKIM_PER_HOUR)
		, AM3_11_20 = ((9 * HALAKIM_PER_HOUR) + 204)
		, AM9_32_43 = ((15 * HALAKIM_PER_HOUR) + 589);

	var SUN = 0
		, MON = 1
		, TUES = 2
		, WED = 3
		, THUR = 4
		, FRI = 5
		, SAT = 6;

	// public function weekdayarr(d0, d1, d2, d3, d4, d5, d6) 
	// {
	// 		this[0] = d0;
	// 		this[1] = d1;
	// 		this[2] = d2;
	// 		this[3] = d3;
	// 		this[4] = d4;
	// 		this[5] = d5;
	// 		this[6] = d6;
	// }

	// public function gregmontharr(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11) 
	// {
	// 	this[0] = m0;
	// 	this[1] = m1;
	// 	this[2] = m2;
	// 	this[3] = m3;
	// 	this[4] = m4;
	// 	this[5] = m5;
	// 	this[6] = m6;
	// 	this[7] = m7;
	// 	this[8] = m8;
	// 	this[9] = m9;
	// 	this[10] = m10;
	// 	this[11] = m11;
	// }

	// public function hebrewmontharr(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13) 
	// {
	// 	this[0] = m0;
	// 	this[1] = m1;
	// 	this[2] = m2;
	// 	this[3] = m3;
	// 	this[4] = m4;
	// 	this[5] = m5;
	// 	this[6] = m6;
	// 	this[7] = m7;
	// 	this[8] = m8;
	// 	this[9] = m9;
	// 	this[10] = m10;
	// 	this[11] = m11;
	// 	this[12] = m12;
	// 	this[13] = m13;
	// }

	// public function monthsperyeararr(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9,
	// 	m10, m11, m12, m13, m14, m15, m16, m17, m18) {
	// 	this[0] = m0;
	// 	this[1] = m1;
	// 	this[2] = m2;
	// 	this[3] = m3;
	// 	this[4] = m4;
	// 	this[5] = m5;
	// 	this[6] = m6;
	// 	this[7] = m7;
	// 	this[8] = m8;
	// 	this[9] = m9;
	// 	this[10] = m10;
	// 	this[11] = m11;
	// 	this[12] = m12;
	// 	this[13] = m13;
	// 	this[14] = m14;
	// 	this[15] = m15;
	// 	this[16] = m16;
	// 	this[17] = m17;
	// 	this[18] = m18;
	// }

	public function getDateHebrew(date)
	{
		var date_str = ""; 
		//System.println("---date---" + date);
		switch(date.toNumber())
		{
			case 1:
				return date_str + "א'";
			case 2:
				return date_str + "ב'";
			case 3:
				return date_str + "ג'";
			case 4:
				return date_str + "ד'";
			case 5:
				return date_str + "ה'";
			case 6:
				return date_str + "ו'";
			case 7:
				return date_str + "ז'";
			case 8:
				return date_str + "ח'";
			case 9:
				return date_str + "ט'";
			case 10:
				return date_str + "י'";
			case 11:
				return date_str + "י\"א";
			case 12:
				return date_str + "י\"ב";
			case 13:
				return date_str + "י\"ג";
			case 14:
				return date_str + "י\"ד";
			case 15:
				return date_str + "ט\"ו";
			case 16:
				return date_str + "ט\"ז";
			case 17:
				return date_str + "י\"ז";
			case 18:
				return date_str + "י\"ח";
			case 19:
				return date_str + "י\"ט";
			case 20:
				return date_str + "כ'";
			case 21:
				return date_str + "כ\"א";
			case 22:
				return date_str + "כ\"ב";
			case 23:
				return date_str + "כ\"ג";
			case 24:
				return date_str + "כ\"ד";
			case 25:
				return date_str + "כ\"ה";
			case 26:
				return date_str + "כ\"ו";
			case 27:
				return date_str + "כ\"ז";
			case 28:
				return date_str + "כ\"ח";
			case 29:
				return date_str + "כ\"ט";
			case 30:
				return date_str + "ל'";
			default:
				return "";
		}
	}

//var ret = [0, 0, 0, 0];
const gWeekday = ["Sun", "Mon", "Tues", "Wednes", "Thurs", "Fri", "Satur"]
    , gMonth = ["January", "February", "March", "April", "May", "June", "July", "August","September","October","November","December"]
    , hMonth = ["Tishri", "Heshvan", "Kislev", "Tevet", "Shevat", "AdarI", "AdarII", "Nisan", "Iyyar", "Sivan", "Tammuz", "Av", "Elul"]
	, hMonthHebrew = ["תשרי", "חשוון", "כסלו", "טבת", "שבט", "אדר", "אדר ב", "ניסן", "אייר", "סיוון", "תמוז", "אב", "אלול"]
    , mpy = [12, 12, 13, 12, 12, 13, 12, 13, 12, 12, 13, 12, 12, 13, 12, 12, 13, 12, 13]
    ;

/**
 * hebrewDate
 * Convert the Gregorian dates  into Hebrew calendar dates.
 *
 * @name hebrewDate
 * @public function
 * @param {Date|Number} inputDate The date object (representing the Gregorian date) or the year.
 * @param {Number} inputMonth The Gregorian month (**one-indexed**, January being `1`!).
 * @param {Number} inputDate The Gregorian date.
 * @return {Object} An object containing:
 *
 *  - `year`: The Hebrew year.
 *  - `month`: The Hebrew month.
 *  - `month_name`: The Hebrew month name.
 *  - `date`: The Hebrew date.
 */

     var hebrewMonth = 0
      , hebrewDate = 0
      , hebrewYear = 0
      , metonicCycle = 0
      , metonicYear = 0
      , moladDay = 0
      , moladHalakim = 0;

	public function hebrewDateFunc(inputDateOrYear, inputMonth, inputDate, inputLang) 
	{
		//var deviceSettings = System.getDeviceSettings();

		var inputYear = inputDateOrYear;

		//if (typeof inputYear === "object") {
		//    inputMonth = inputDateOrYear.getMonth() + 1;
		//    inputDate = inputDateOrYear.getDate();
		//    inputYear = inputDateOrYear.getFullYear();
		//}

		SdnToHebrew(GregorianToSdn(inputYear, inputMonth, inputDate));

		var dateNow = Gregorian.info(Time.now(), Time.FORMAT_LONG);

		var h = dateNow.hour;
		var m = dateNow.min;
		var s = dateNow.sec;
		var mili = 500;
		var curr_hour = mili.toNumber() + ((s.toNumber())*1000) + ((m.toNumber())*60*1000) + ((h.toNumber())*60*60*1000);
		curr_hour = curr_hour.toDouble()/(1000 * 3600);	

		System.println("curr_hour: " + curr_hour);
		System.println("tzeit: " + tzeit);


		if (curr_hour > tzeit)
		{	
			hebrewDate = hebrewDate + 1;
			if(hebrewDate == 31)
			{
				hebrewDate = 1;
			}
		}

		if(inputLang.equals("English"))
		{
			var ret = [0, 0, 0, 0];
			ret[0] =  hebrewYear;
			ret[1] = hebrewMonth;
			ret[2] = hebrewDate;
			ret[3] = " At " + hMonth[hebrewMonth - 1];
			return ret;
		}
		else
		{
			var ret = [0, 0, 0, 0];
			ret[0] =  hebrewYear;
			ret[1] = hebrewMonth;
			ret[2] = getDateHebrew(hebrewDate);
			ret[3] = " ב" + hMonthHebrew[hebrewMonth - 1];
			return ret;
		}	
	}

    public function GregorianToSdn(inputYear, inputMonth, inputDay) 
	{
        var year = 0
          , month = 0
          , sdn
          ;

        // Make year a positive number
        if (inputYear < 0) {
            year = inputYear + 4801;
        } else {
            year = inputYear + 4800;
        }

        // Adjust the start of the year
        if (inputMonth > 2) {
            month = inputMonth - 3;
        } else {
            month = inputMonth + 9;
            year--;
        }

        sdn = Math.floor((Math.floor(year / 100) * DAYS_PER_400_YEARS) / 4);
        sdn += Math.floor(((year % 100) * DAYS_PER_4_YEARS) / 4);
        sdn += Math.floor((month * DAYS_PER_5_MONTHS + 2) / 5);
        sdn += inputDay - GREG_SDN_OFFSET;

        return sdn;
    }

    public function SdnToHebrew(sdn) {
        var tishri1 = 0
          , tishri1After = 0
          , yearLength = 0
          , inputDay = sdn - HEB_SDN_OFFSET
          ;

        FindTishriMolad(inputDay);
        tishri1 = Tishri1(metonicYear, moladDay, moladHalakim);

        if (inputDay >= tishri1) {
            // It found Tishri 1 at the start of the year.
            hebrewYear = metonicCycle * 19 + metonicYear + 1;
            if (inputDay < tishri1 + 59) {
                if (inputDay < tishri1 + 30) {
                    hebrewMonth = 1;
                    hebrewDate = inputDay - tishri1 + 1;
                } else {
                    hebrewMonth = 2;
                    hebrewDate = inputDay - tishri1 - 29;
                }
                return;
            }
            // We need the length of the year to figure this out,so find Tishri 1 of the next year.
            moladHalakim += HALAKIM_PER_LUNAR_CYCLE * mpy[metonicYear];
            moladDay += Math.floor(moladHalakim / HALAKIM_PER_DAY);
            moladHalakim = moladHalakim % HALAKIM_PER_DAY;
            tishri1After = Tishri1((metonicYear + 1) % 19, moladDay, moladHalakim);
        } else {
            // It found Tishri 1 at the end of the year.
            hebrewYear = metonicCycle * 19 + metonicYear;
            if (inputDay >= tishri1 - 177) {
                // It is one of the last 6 months of the year.
                if (inputDay > tishri1 - 30) {
                    hebrewMonth = 13;
                    hebrewDate = inputDay - tishri1 + 30;
                } else if (inputDay > tishri1 - 60) {
                    hebrewMonth = 12;
                    hebrewDate = inputDay - tishri1 + 60;
                } else if (inputDay > tishri1 - 89) {
                    hebrewMonth = 11;
                    hebrewDate = inputDay - tishri1 + 89;
                } else if (inputDay > tishri1 - 119) {
                    hebrewMonth = 10;
                    hebrewDate = inputDay - tishri1 + 119;
                } else if (inputDay > tishri1 - 148) {
                    hebrewMonth = 9;
                    hebrewDate = inputDay - tishri1 + 148;
                } else {
                    hebrewMonth = 8;
                    hebrewDate = inputDay - tishri1 + 178;
                }
                return;
            } else {
                if (mpy[(hebrewYear - 1) % 19] == 13) {
                    hebrewMonth = 7;
                    hebrewDate = inputDay - tishri1 + 207;
                    if (hebrewDate > 0)
					{
                        return;
					}
					hebrewMonth--;
                    hebrewDate += 30;
                    if (hebrewDate > 0)
                    {
						return;
					}
                    hebrewMonth--;
                    hebrewDate += 30;
                } else {
                    hebrewMonth = 6;
                    hebrewDate = inputDay - tishri1 + 207;
                    if (hebrewDate > 0)
					{
                        return;
					}
					hebrewMonth--;
                    hebrewDate += 30;
                }
                if (hebrewDate > 0)
				{
                    return;
				}
				hebrewMonth--;
                hebrewDate += 29;
                if (hebrewDate > 0)
                {
				    return;
				}
				// We need the length of the year to figure this out,so find Tishri 1 of this year.
                tishri1After = tishri1;
                FindTishriMolad(moladDay - 365);
                tishri1 = Tishri1(metonicYear, moladDay, moladHalakim);
            }
        }
        yearLength = tishri1After - tishri1;
        moladDay = inputDay - tishri1 - 29;
        if (yearLength == 355 || yearLength == 385) {
            // Heshvan has 30 days
            if (moladDay <= 30) {
                hebrewMonth = 2;
                hebrewDate = moladDay;
                return;
            }
            moladDay -= 30;
        } else {
            // Heshvan has 29 days
            if (moladDay <= 29) {
                hebrewMonth = 2;
                hebrewDate = moladDay;
                return;
            }
            moladDay -= 29;
        }
        // It has to be Kislev.
        hebrewMonth = 3;
        hebrewDate = moladDay;
    }

    public function FindTishriMolad(inputDay) 
	{
        // Estimate the metonic cycle number.  Note that this may be an under
        // estimate because there are 6939.6896 days in a metonic cycle not
        // 6940,but it will never be an over estimate.   The loop below will
        // correct for any error in this estimate.
        metonicCycle = Math.floor((inputDay + 310) / 6940);
        // Calculate the time of the starting molad for this metonic cycle.
        MoladOfMetonicCycle();
        // If the above was an under estimate,increment the cycle number until
        // the correct one is found.  For modern dates this loop is about 98.6%
        // likely to not execute,even once,because the above estimate is
        // really quite close.
        while (moladDay < inputDay - 6940 + 310) 
		{
            metonicCycle++;
            moladHalakim += HALAKIM_PER_METONIC_CYCLE;
            moladDay += Math.floor(moladHalakim / HALAKIM_PER_DAY);
            moladHalakim = moladHalakim % HALAKIM_PER_DAY;
        }
        // Find the molad of Tishri closest to this date.
        for (metonicYear = 0; metonicYear < 18; metonicYear++) 
		{
            if (moladDay > inputDay - 74)
			{
                break;
			}
            moladHalakim += HALAKIM_PER_LUNAR_CYCLE * mpy[metonicYear];
            moladDay += Math.floor(moladHalakim / HALAKIM_PER_DAY);
            moladHalakim = moladHalakim % HALAKIM_PER_DAY;
        }
    }

    public function MoladOfMetonicCycle() {
        var r1, r2, d1, d2;
        // Start with the time of the first molad after creation.
        r1 = NEW_MOON_OF_CREATION;
        // Calculate gMetonicCycle * HALAKIM_PER_METONIC_CYCLE.  The upper 32
        // bits of the result will be in r2 and the lower 16 bits will be in r1.
        r1 += metonicCycle * (HALAKIM_PER_METONIC_CYCLE & 0xFFFF);
        r2 = r1 >> 16;
        r2 += metonicCycle * ((HALAKIM_PER_METONIC_CYCLE >> 16) & 0xFFFF);
        // Calculate r2r1 / HALAKIM_PER_DAY.  The remainder will be in r1,the
        // upper 16 bits of the quotient will be in d2 and the lower 16 bits
        // will be in d1.
        d2 = Math.floor(r2 / HALAKIM_PER_DAY);
        r2 -= d2 * HALAKIM_PER_DAY;
        r1 = (r2 << 16) | (r1 & 0xFFFF);
        d1 = Math.floor(r1 / HALAKIM_PER_DAY);
        r1 -= d1 * HALAKIM_PER_DAY;
        moladDay = (d2 << 16) | d1;
        moladHalakim = r1;
    }

    public function Tishri1(metonicYear, moladDay, moladHalakim) 
	{
        var tishri1 = moladDay
          , dow = tishri1 % 7
          , leapYear = metonicYear == 2 || metonicYear == 5 || metonicYear == 7 || metonicYear == 10
                     || metonicYear == 13 || metonicYear == 16 || metonicYear == 18
          , lastWasLeapYear = metonicYear == 3 || metonicYear == 6 || metonicYear == 8 || metonicYear == 11
                           || metonicYear == 14 || metonicYear == 17 || metonicYear == 0
          ;

        // Apply rules 2,3 and 4
        if ((moladHalakim >= NOON) ||
            ((!leapYear) && dow == TUES && moladHalakim >= AM3_11_20) ||
            (lastWasLeapYear && dow == MON && moladHalakim >= AM9_32_43)) {
            tishri1++;
            dow++;
            if (dow == 7)
			{
                dow = 0;
			}
        }

        // Apply rule 1 after the others because it can cause an additional delay of one day.
        if (dow == WED || dow == FRI || dow == SUN) 
		{
            tishri1++;
        }

        return tishri1;
    }
	//------------------------HebrewDate---------------------


// 	//------------------------Tefila-------------------------
	public function Tefila()
	{	
		var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	
	    var h = date.hour;
	    var m = date.min;
	    var s = date.sec;
		//var milisec = date.getMilliseconds();
	
		var curr_hour = /*milisec +*/ ((s.toNumber())*1000) + ((m.toNumber())*60*1000) + ((h.toNumber())*60*60*1000);
		curr_hour = curr_hour.toDouble()/(1000 * 3600);	

		System.println("curr_hour: " + curr_hour);
		System.println("birkutHashahar: " + birkutHashahar);
		System.println("patachEliyaou: " + patachEliyaou);

		if(curr_hour >= birkutHashahar && curr_hour < patachEliyaou)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("ברכות השחר");
			}
			else
			{
				viewPrayPart.setText("Birkut Hashahar");
			}
			SecLeft(curr_hour,patachEliyaou);
		}
		else if(curr_hour >= patachEliyaou && curr_hour < korbanot)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("פתח אליהו");
			}
			else
			{
				viewPrayPart.setText("Patach Eliyaou");
			}
			SecLeft(curr_hour,korbanot);
		}
		else if(curr_hour >= korbanot && curr_hour < psokeiDzimra)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("קורבנות");
			}
			else
			{
				viewPrayPart.setText("Korbanot");
			}
			SecLeft(curr_hour,psokeiDzimra);
		}
		else if(nishmat == -1 && curr_hour >= psokeiDzimra && curr_hour < yozerOr)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("פסוקי דזמרה");
			}
			else
			{
				viewPrayPart.setText("Psokei Dzimra");
			}
			SecLeft(curr_hour,yozerOr);
		}
		else if(nishmat != -1 && curr_hour >= psokeiDzimra && curr_hour < nishmat)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("פסוקי דזמרה");
			}
			else
			{
				viewPrayPart.setText("Psokei Dzimra");
			}
			SecLeft(curr_hour,nishmat);
		}
		else if(nishmat != -1 && curr_hour >= nishmat && curr_hour < yozerOr)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("נשמת כל-חי");
			}
			else
			{
				viewPrayPart.setText("Nishmat");
			}
			SecLeft(curr_hour,yozerOr);
		}
		else if(curr_hour >= yozerOr && curr_hour < kriyahtShema)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("יוצר אור");
			}
			else
			{
				viewPrayPart.setText("Yotzer Or");
			}
			SecLeft(curr_hour,kriyahtShema);
		}
		else if(curr_hour >= kriyahtShema && curr_hour < sunrise)
		{
			var viewPrayPart = View.findDrawableById("MazalLabel") as Text;
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.systemLanguage == System.LANGUAGE_HEB)
			{
				viewPrayPart.setText("קריאת שמע");
			}
			else
			{
				viewPrayPart.setText("Kriyaht Shema");
			}
			SecLeft(curr_hour,sunrise);
		}
	}

	//return the seconds left until the next action need to begin
	public function SecLeft(curr_hour,nextAction_hour)
	{
		var counterDawn =  splitStr(timeadj1(nextAction_hour-curr_hour),":");

		var viewTimerHour = View.findDrawableById("HebrewClockHour") as Text;
		var viewTimerMin = View.findDrawableById("HebrewClockMin") as Text;
		var viewTimerSec = View.findDrawableById("HebrewClockSec") as Text;

		var minute = counterDawn[1].toNumber();
		if(minute < 10)
		{
		 	minute = "0" + minute;
		}
		var second = counterDawn[2].toNumber();
		if(second < 10)
		{
			second = "0" + second;
		}

		viewTimerHour.setText("00");
		viewTimerMin.setText(minute);
		viewTimerSec.setText(second);

		//viewTimer.setText("00:" + minute + ":" + second);
	}

// public function BirkutHashahar(secLeft)
// {
// 	document.querySelector(".circular").style.display = "unset";
// 	setTimeout(function() 
// 	{
// 		PatachEliyaou(60*3);		
// 	}, 1000 * secLeft); //wait maximum 4 minutes for the birkutHashahar will ends
// }

// public function PatachEliyaou(secLeft)
// {
// 	//break between birkutHashahar & patachEliyaou
// 	document.querySelector(".circular").style.display = "none";

// 	//patachEliyaou
// 	setTimeout(function() 
// 	{
// 		document.querySelector(".circular").style.display = "none";
		
// 		//3m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "פתח אליהו";

// 		document.querySelector(".circular").style.display = "unset";
		
// 	}, 2000); //wait 4 minutes + 10s for the birkutHashahar will ends

// 	setTimeout(function() 
// 	{
// 		Korbanot(60*13);
// 	}, /*1000*60*4 +*/ 1000*secLeft); //wait maximum 3 minutes for the patachEliyaou will ends
// }

// public function Korbanot(secLeft)
// {
// 	//break between patachEliyaou & korbanot
// 	document.querySelector(".circular").style.display = "none";

// 	//korbanot
// 	setTimeout(function() 
// 	{
// 		//13m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "קורבנות";

// 		document.querySelector(".circular").style.display = "unset";
// 	}, /*1000*60*4 + 1000*60*3*/2000); //wait 4+3 minutes + 10s for the patachEliyaou will ends

// 	setTimeout(function()
// 	{
// 		PsokeiDzimra(60*14);
// 	}, /*1000*60*4 + 1000*60*3 +*/ 1000*secLeft); //wait 4+3+13 minutes for the korbanot will ends
	
// }

// public function PsokeiDzimra(secLeft)
// {
// 	//console.log(secLeft);
// 	//break between korbanot & psokeiDzimra
// 	document.querySelector(".circular").style.display = "none";

// 	//psokeiDzimra
// 	setTimeout(function()
// 	{
// 		//14m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "פסוקי דזמרה";

// 		document.querySelector(".circular").style.display = "unset";
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 +*/2000); //wait 4+3+13 minutes + 10s for the korbanot will ends

// 	setTimeout(function() 
// 	{		
// 		YozerOr(60*4);		
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 +*/ 1000*secLeft); //wait 4+3+13+14 minutes for the psokeiDzimra will ends
	
// }

// public function YozerOr(secLeft)
// {
// 	//break between psokeiDzimra & YozerOr 
// 	document.querySelector(".circular").style.display = "none";		

// 	//YozerOr
// 	setTimeout(function() 
// 	{		
// 		//4m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "יוצר אור";

// 		document.querySelector(".circular").style.display = "unset";
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 +*/ 2000); //wait 4+3+13+14 minutes + 10s for the psokeiDzimra will ends

// 	setTimeout(function() 
// 	{
// 		KriyahtShema(60*4);
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 +*/ 1000*secLeft); //wait 4+3+13+14+4 minutes for the YozerOr will ends

// }

// public function KriyahtShema(secLeft)
// {
// 	//break between YozerOr & kriyahtShema
// 	document.querySelector(".circular").style.display = "none";

// 	//kriyahtShema
// 	setTimeout(function() 
// 	{
// 		document.querySelector(".circular").style.display = "none";

// 		//4m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "קריאת שמע";

// 		document.querySelector(".circular").style.display = "unset";		
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 + 1000*60*4 +*/ 2000); //wait 4+3+13+14+4 minutes + 10s for the YozerOr will ends

// 	setTimeout(function() 
// 	{
// 		Netz(60*6);
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 + 1000*60*4 +*/ 1000*secLeft); //wait 4+3+13+14+4+4 minutes for the kriyahtShema will ends
// }

// public function Netz(secLeft)
// {
// 	window.location.href = "https://hebrewclock13.web.app/man/simple/index.html";
// 	//break between kriyahtShema & netz
// 	document.querySelector(".circular").style.display = "none";		

// 	//netz
// 	setTimeout(function() 
// 	{
// 		//6m
// 		document.querySelector(".circle .left .progress").style.animation = "left " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animation = "right " + Number((secLeft/2)-1) + "s linear both";
// 		document.querySelector(".circle .right .progress").style.animationDelay = "" + Number((secLeft/2)-1) + "s";			
// 		document.querySelector(".number").innerText = "תפילת שמונה עשרה";

// 		document.querySelector(".circular").style.display = "unset";
		
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 + 1000*60*4 + 1000*60*4 +*/ 2000); //wait 4+3+13+14+4+4 minutes + 10s for the kriyahtShema will ends

// 	//end of netz
// 	setTimeout(function() 
// 	{
// 		window.location.href = "https://hebrewclock13.web.app/man/simple/index.html";
// 		//document.querySelector(".circular").style.display = "none";		
// 	}, /*1000*60*4 + 1000*60*3 + 1000*60*13 + 1000*60*14 + 1000*60*4 + 1000*60*4 +*/1000*secLeft); //wait 4+3+13+14+4+4+6 minutes for the netz will ends
// }

// public function TefilaNetz()
// {
// 	document.getElementById("btn").style.display = "none";
// 	document.getElementById("btn2").style.display = "none";
// 	tefilaNetz	 = true;
// 	Tefila(true);
// }

// //return the seconds left until the next action need to begin
// public function SecLeft(curr_hour,nextAction_hour)
// {
// 	var counterDawn =  timeadj1(nextAction_hour-curr_hour).split(':');
// 	var minuteLeft = Number(counterDawn[1]);
// 	var secondLeft = Number(counterDawn[2]);
	
// 	var secLeft = (minuteLeft*60)+secondLeft; 
	
// 	//console.log(minuteLeft);
// 	//console.log(secondLeft);
	
// 	return secLeft;
// }
	//------------------------Tefila-------------------------

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    public function onHide() as Void {
    }
}
