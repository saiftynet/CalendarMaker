# CalendarMaker
Makes Calendars in SVG

A simple project to make calendars in SVG for embedding into web pages or documents or printing.
Three methods are supplied in this version that alows one of three formats of output.  Th module also
contains primitives that can be used to customise outputs.

```
#!/usr/env perl
use strict;use warnings;
use lib "./lib";
use CalendarMaker;

my $cal=new CalendarMaker->monthPage(1, 2020,"test1.svg");
$cal=new CalendarMaker->monthPageSmallDate(1, 2020,"test2.svg");
$cal=new CalendarMaker->monthPagePreAndPost(1, 2020,"test3.svg");
```

![example3](https://github.com/saiftynet/CalendarMaker/blob/master/Images/test3.svg)
