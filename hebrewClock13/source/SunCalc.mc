using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

//System.println("Time.today(): " + Time.today());
////same as javascript date.valueOf()
//System.println("today:" + (Time.today().value().toString()+"000").toDouble());


class SunCalc
{
    
    const   dayMs = 1000 * 60 * 60 * 24,
            J1970 = 2440588,
            J2000 = 2451545;
    const rad  = Math.PI / 180;
    
    function toJulian(date) { return (date.value().toString()+"000").toDouble() / dayMs - 0.5 + J1970; }
    function fromJulian(j)  { return new Time.Moment((j + 0.5 - J1970) * dayMs); }
    function toDays(date)   { return toJulian(date) - J2000; }

    // general calculations for position

    var e = rad * 23.4397; // obliquity of the Earth

    function rightAscension(l, b) { return Math.atan2(Math.sin(l) * Math.cos(e) - Math.tan(b) * Math.sin(e), Math.cos(l)); }
    function declination(l, b)    { return Math.asin(Math.sin(b) * Math.cos(e) + Math.cos(b) * Math.sin(e) * Math.sin(l)); }

    function azimuth(H, phi, dec)  { return Math.atan2(Math.sin(H), Math.cos(H) * Math.sin(phi) - Math.tan(dec) * Math.cos(phi)); }
    function altitude(H, phi, dec) { return Math.asin(Math.sin(phi) * Math.sin(dec) + Math.cos(phi) * Math.cos(dec) * Math.cos(H)); }

    function siderealTime(d, lw) { return rad * (280.16 + 360.9856235 * d) - lw; }

    function astroRefraction(h) {
        if (h < 0) // the following formula works for positive altitudes only.
        {
            h = 0; // if h = -0.08901179 a div/0 would occur.
        }

        // formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
        // 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
        return 0.0002967 / Math.tan(h + 0.00312536 / (h + 0.08901179));
    }

    public function getMoonTimes(date, lat, lng, inUTC) 
    {
        // Options for Saturday February 24th, 2018 12:12am
        var options = {
            :year   => date.year,
            :month  => date.month,
            :day    => date.day,
            :hour   => 0,
            :minute => 0,
            :second => 0
        };

        var t = Gregorian.moment(options);

        //System.println(t.value());
        //console.log(t); --> check here the bug...
//        if (inUTC) t.setUTCHours(0, 0, 0, 0);
        //else 
        //t.setHours(0, 0, 0, 0);

        var hc = 0.133 * rad,
        h0 = SunCalc.getMoonPosition(t, lat, lng)[1] - hc,
        h1=0, h2=0, rise=0, set=0, a=0, b=0, xe=0, ye=0, d=0, roots=0, x1=0, x2=0, dx=0;

        // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
        for (var i = 1; i <= 25; i += 2) 
        {
            h1 = SunCalc.getMoonPosition(hoursLater(t, i), lat, lng)[1] - hc;
            h2 = SunCalc.getMoonPosition(hoursLater(t, i + 1), lat, lng)[1] - hc;

            a = (h0 + h2) / 2 - h1;
            b = (h2 - h0) / 2;
            xe = -b / (2 * a);
            ye = (a * xe + b) * xe + h1;
            d = b * b - 4 * a * h1;
            roots = 0;

            if (d >= 0) 
            {
                dx = Math.sqrt(d) / ((a).abs() * 2);
                x1 = xe - dx;
                x2 = xe + dx;
                if ((x1).abs() <= 1) 
                {
                    roots++;
                }
                if ((x2).abs() <= 1) 
                {
                    roots++;
                }
                if (x1 < -1)
                {   
                    x1 = x2;
                }
            }

            if (roots == 1) 
            {
                if (h0 < 0) 
                {
                    rise = i + x1;
                }
                else 
                {
                    set = i + x1;
                }
            } else if (roots == 2) 
            {
                rise = i + (ye < 0 ? x2 : x1);
                set = i + (ye < 0 ? x1 : x2);
            }

            if (rise !=0 && set != 0) 
            {
                break;
            }

            h0 = h2;
        }

        var result = [0,0,0,0];

        if (rise != 0) 
        {
            result[2] = rise;//hoursLater(t, rise); ***need to fix
        }
        if (set != 0) 
        {
            result[3] = set;//convertDateTimeToFloat(hoursLater(t, set)); ***need to fix
        }
        if (rise == 0 && set == 0)
        { 
            //set result[0] or result[1] with true value - specific cased in notrh/south edge of earth.
            if(ye > 0)
            {
                result[0] = true; //alwaysDown
            }
            else 
            {
                result[1] = true; //alwaysUp
            }
            //result[ye > 0 ? 'alwaysUp' : 'alwaysDown'] = true;
        }

        System.println("rise - " + rise);
        System.println("hoursLater(t, rise): " + hoursLater(t, rise));
        System.println("set - " + set);
        System.println("hoursLater(t, set): " + hoursLater(t, set));


        return result;

        // // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
        //  for (var i = 1; i <= 24; i += 2) 
        //  {
        //      System.println(hoursLater(t, i).value());
        //      System.println(hoursLater(t, i + 1).value());
        //  }
    }

    public function convertDateTimeToFloat(date)
    {
        //date.hour
        var info = Gregorian.utcInfo(date, Time.FORMAT_LONG);
        var h = info.hour;
        var m = info.min;
        var s = info.sec;
        var milisec = 0;
        var floatDate = milisec + (s*1000) + (m*60*1000) + ((h)*60*60*1000);	
        floatDate = floatDate/(1000 * 3600);

        return floatDate;
    }

    public function getMoonPosition (date, lat, lng) 
    {
        var lw  = rad * -lng,
            phi = rad * lat,
            d   = toDays(date),

            c = moonCoords(d),
            H = siderealTime(d, lw) - c[0],
            h = altitude(H, phi, c[1]),
            // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
            pa = Math.atan2(Math.sin(H), Math.tan(phi) * Math.cos(c[1]) - Math.sin(c[1]) * Math.cos(H));

        h = h + astroRefraction(h); // altitude correction for refraction

        var result = [  azimuth(H, phi, c[1]),    //azimuth
                        h,                        //altitude
                        c[2],                     //distance
                        pa];                      //parallacticAngle
        
        return result;
    }

    function moonCoords(d) 
    { // geocentric ecliptic coordinates of the moon

        var L = rad * (218.316 + 13.176396 * d), // ecliptic longitude
            M = rad * (134.963 + 13.064993 * d), // mean anomaly
            F = rad * (93.272 + 13.229350 * d),  // mean distance

            l  = L + rad * 6.289 * Math.sin(M), // longitude
            b  = rad * 5.128 * Math.sin(F),     // latitude
            dt = 385001 - 20905 * Math.cos(M);  // distance to the moon in km

        var result = [  rightAscension(l, b),   //ra
                        declination(l, b),      //dec
                        dt];                    //dist
        
        return result;
    }

    public function hoursLater(date, h) 
    {
        var hoursLater = (Time.today().value().toString()+"000").toDouble() + h * dayMs / 24;
        return new Time.Moment(hoursLater);
    }

}