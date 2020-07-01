# CalendarMaker
Makes Calendars in SVG

A simple project to make calendars in SVG for embedding into web pages or documents or printing.
Three methods are supplied in this version that alows one of three formats of output.  Th module also
contains primitives that can be used to customise outputs.

This is simple tool, but [IvanWills](https://github.com/ivanwills) has developed a much more powerful utility, [SVG::Calendar](https://github.com/ivanwills/SVG-Calendar) (which I realised only after I started my project) and I would recommend you try that one first.  The only advantage of my utility, as far as I can see is the much lower number of dependencies.

```
#!/usr/env perl
use strict;use warnings;
use CalendarMaker;

my $cal=new CalendarMaker->monthPage(1, 2020,"test1.svg");        # Example 1
$cal=new CalendarMaker->monthPageSmallDate(1, 2020,"test2.svg");  # Example 2
$cal=new CalendarMaker->monthPagePreAndPost(1, 2020,"test3.svg"); # Example 3
```
The script above generates the following SVG images.

![example1](https://github.com/saiftynet/CalendarMaker/blob/master/Images/test1.svg)

![example2](https://github.com/saiftynet/CalendarMaker/blob/master/Images/test2.svg)

![example3](https://github.com/saiftynet/CalendarMaker/blob/master/Images/test3.svg)


Dependency: DateTime
