package CalendarMaker;
use strict; use warnings;
use DateTime;

my $pageDims={height=>10,width=>10};
my $defaultText={size=>16,anchor=>"middle",
	             fill=>"black",
	             font=>"Arial, Helvetica, sans-serif",
	             anchor=>"middle",
			 };
my $defaultLine={color=>'rgb(0,0,0)',
	             width=>2};

sub new{
	my $class=shift;
	my $self={};
	$self->{svg}="";
	$self->{parts}={};
	bless $self,$class;
	return $self;
}

sub addComponent{
	my ($self,$name,$type,@parameters)=@_;
	$name=nextName($self,$type) unless $name;
	$self->{parts}{$name}={assembly=>[$name,$type,@parameters],
		                  hidden =>0,
		                  svg    =>make($name,$type,@parameters),
		                  refresh=>0,
					  };	
}

sub nextName{
	my ($self,$type)=@_;
	my @list=sort grep {/^$type\d*/} keys %{$self->{parts}};
	return $type.1 unless @list;
	my $lastNo=$list[-1]=~s/[^0-9]//g;
	return $type.($lastNo+1);
	
}

sub assemble{
	my $self=shift;
	$self->{svg}="";
	foreach my $part (keys %{$self->{parts}}){
		next if ($self->{parts}{$part}{hidden});
		make(@{$self->{parts}{$part}{assembly}}) if $self->{parts}{$part}{refresh};
		$self->{svg}.=$self->{parts}{$part}{svg} if $self->{parts}{$part}{svg};
			
	}	
}

sub group{
	my ($self,$name,@parts)=shift;
	my $grp="<g id='$name'>\n";
	foreach my $part (@parts){
		next if ($self->{parts}{$part}{hidden});
		make(@{$self->{parts}{$part}{assembly}}) if $self->{parts}{$part}{refresh};
		$grp.=$self->{parts}{$part}{svg} if $self->{parts}{$part}{svg};
		$self->{parts}{$part}{hidden}=1;
	}	
	$grp.="</g>\n";
	
	$self->{parts}{$name}={assembly=>[$name,"group",$grp],
		                  hidden =>0,
		                  svg    =>$grp,
		                  refresh=>0,
					  };
	
}

sub make{
	my( $name,$type,@parameters)=@_;
	return makeGrid($name,@parameters) if $type eq "grid";
	return makeText($name,@parameters) if $type eq "text";
	return makeHead($name,@parameters) if $type eq "head";
	return makeDate($name,@parameters) if $type eq "date";
	
}

sub makeGrid{
  my ($name,$position,$gridGeometry,$cellGeometry)=@_;
  my $grid="<g id='$name'>";
  foreach my $y(0..$$gridGeometry{rows}){
     $grid.=line({x=>$$position{x},y=>$$position{y}+$y*$$cellGeometry{height}},{x=>$$position{x}+$$gridGeometry{cols}*$$cellGeometry{width},y=>$$position{y}+$y*$$cellGeometry{height}});
  }
  foreach my $x(0..$$gridGeometry{cols}){
     $grid.=line({x=>$$position{x}+$x*$$cellGeometry{width},y=>$$position{y}},{x=>$$position{x}+$x*$$cellGeometry{width},y=>$$position{y}+$$gridGeometry{rows}*$$cellGeometry{height}});
  }
  return  $grid."</g>\n";
}

sub makeText{
	my ($name,$position,$text,$style)=@_;
	my $svg="";
	$text={text=>$text} unless ref $text;
	if ($style and ref $style){
		foreach (keys %$style){
			$$text{$_}=$$style{$_}
		}
	}
	$name="id='$name'" if $name;
    my ($size, $fill, $font, $anchor, $textStr)=defaultsUndef($text,$defaultText,qw/size fill font anchor text/);
	return "<text $name x='$$position{x}' y='$$position{y}' font-family='$font'
font-size='$size' fill='$fill' text-anchor='$anchor'>$textStr</text>\n"; 
}

sub makeHead{
  my ($name,$position,$gridGeometry,$cellGeometry,$style)=@_;
  my $days="<g id='$name'>\n";
  my @days=qw/Mon Tue Wed Thu Fri Sat Sun/;
  $$position{x}+=$$cellGeometry{width}/2;
  foreach my $day (0..$#days){
	$days.=makeText("day-$day",$position,{text=>$days[$day],size=>$$cellGeometry{width}/3},$style);
	$$position{x}+=$$cellGeometry{width};
  }
  return $days."</g>\n";
}

sub makeDate{
  my ($name,$position,$gridGeometry,$cellGeometry,$startCell,$days,$style)=@_;
  $style//={};
  my $dates="<g id='$name'>\n";
  foreach my $cell ($startCell+1..$startCell+$days){
     my $column=($cell-2)%7;
     my $row=int(($cell-2)/7);
     my $x=$$position{x}+$$cellGeometry{width}*($column+1/2);
     my $y=$$position{y}+$$cellGeometry{height}*($row+0.8);
     $$style{size}//=$$cellGeometry{height}*0.8;
     $dates.=makeText("date-".($cell-$startCell),{y=>$y,x=>$x},$cell-$startCell,$style);
  }
  return $dates."</g>\n";
}

sub defaultsUndef{
  my ($input,$default,@parameters)=@_;
  my @values=();
  foreach my $attr(@parameters){
	if (ref $input){
      push @values,exists $$input{$attr}?$$input{$attr}:$$default{$attr};
    }
	else{
	  push @values,exists $$default{$attr}?$$default{$attr}:$input;		  
	}
  }
  return @values;
}

sub line{
   my ($from,$to,$style)=@_;
   my ($color, $width, $anchor)=defaultsUndef($style,$defaultLine,qw/color width anchor/);
   $$pageDims{width} =$$from{x}+10 if $$from{x}>$$pageDims{width}-10;
   $$pageDims{width} =$$to{x}+10   if $$to{x}  >$$pageDims{width}-10;
   $$pageDims{height}=$$from{y}+10 if $$from{y}>$$pageDims{height}-10;
   $$pageDims{height}=$$to{y}+10   if $$to{y}  >$$pageDims{height}-10;
   return "<line x1='$$from{x}' y1='$$from{y}' x2='$$to{x}' y2='$$to{y}' style='stroke:$color;stroke-width:$width' />\n"
}

sub monthPage{
  my ($self, $month, $year,$file)=@_;
  my $dt = DateTime->new(year => $year, month => $month, day => 1);
  $self->addComponent("grid","grid",{x=>10,y=>70},{rows=>6,cols=>7},{width=>70,height=>60});
#$cal->addComponent("","text",{x=>200,y=>380},"January");
  $self->addComponent("","text",{x=>250,y=>38},{text=>$dt->month_name()." ".$year,size=>40});
  $self->addComponent("days","head",{x=>10,y=>65},{rows=>5,cols=>7},{width=>70,height=>60});
  $self->addComponent("dates","date",{x=>10,y=>70},{rows=>5,cols=>7},{width=>70,height=>60},$dt->day_of_week(),$dt->month_length());
  $self->assemble();
  $self->saveSVG($file);
}

sub monthPageSmallDate{
  my ($self, $month, $year,$file)=@_;
  my $dt = DateTime->new(year => $year, month => $month, day => 1);
  $self->addComponent("grid","grid",{x=>10,y=>70},{rows=>6,cols=>7},{width=>70,height=>60});
#$cal->addComponent("","text",{x=>200,y=>380},"January");
  $self->addComponent("","text",{x=>250,y=>38},{text=>$dt->month_name()." ".$year,size=>40,fill=>"red"});
  $self->addComponent("days","head",{x=>10,y=>65},{rows=>5,cols=>7},{width=>70,height=>60});
  $self->addComponent("dates","date",{x=>-15, y=>35	},{rows=>5,cols=>7},{width=>70,height=>60},$dt->day_of_week(),$dt->month_length(),{size=>12});
  $self->assemble();
  $self->saveSVG($file);
}

sub monthPagePreAndPost{
  my ($self, $month, $year,$file)=@_;
  my $dt = DateTime->new(year => $year, month => $month, day => 1);
  $self->addComponent("grid","grid",{x=>10,y=>70},{rows=>6,cols=>7},{width=>70,height=>60});
#$cal->addComponent("","text",{x=>200,y=>380},"January");
  $self->addComponent("","text",{x=>250,y=>38},{text=>$dt->month_name()." ".$year,size=>40,fill=>"green"});
  $self->addComponent("days","head",{x=>10,y=>65},{rows=>5,cols=>7},{width=>70,height=>60});
  $self->addComponent("dates","date",{x=>-15, y=>35	},{rows=>5,cols=>7},{width=>70,height=>60},$dt->day_of_week(),$dt->month_length(),{size=>12});
  
  $dt = DateTime->new(year => ($month==1?$year-1:$year), month => ($month==1?12:$month-1), day => 1);
  $self->addComponent("grid2","grid",{x=>520,y=>70},{rows=>6,cols=>7},{width=>28,height=>24});
  $self->addComponent("mpre","text",{x=>615,y=>55},{text=>$dt->month_name()." ".$dt->year(),size=>20,fill=>"red"});
  $self->addComponent("days2","head",{x=>520,y=>65},{rows=>5,cols=>7},{width=>28,height=>24});
  $self->addComponent("dates2","date",{x=>520, y=>70	},{rows=>5,cols=>7},{width=>28,height=>24},$dt->day_of_week(),$dt->month_length()); 

  $dt = DateTime->new(year => ($month==12?$year+1:$year), month => ($month==12?1:$month+1), day => 1);
  $self->addComponent("grid3","grid",{x=>520,y=>270},{rows=>6,cols=>7},{width=>28,height=>24});
  $self->addComponent("mpost","text",{x=>615,y=>255},{text=>$dt->month_name()." ".$dt->year(),size=>20,fill=>"blue"});
  $self->addComponent("days3","head",{x=>520,y=>265},{rows=>5,cols=>7},{width=>28,height=>24});
  $self->addComponent("dates3","date",{x=>520, y=>270	},{rows=>5,cols=>7},{width=>28,height=>24},$dt->day_of_week(),$dt->month_length()); 
 
  $self->assemble();
  
  $self->saveSVG($file);
}



sub saveSVG{
my ($self,$file)=@_;
  open my $fh, ">",$file;
  print $fh <<EndSVG;
<svg version="1.1"     baseProfile="full"     width="$$pageDims{width}" height="$$pageDims{height}"  xmlns="http://www.w3.org/2000/svg">
<image href="imageFilePath" height="200" width="200"/>
<rect  width="$$pageDims{width}" height="$$pageDims{height}"  style="fill:white;stroke-width:3;stroke:rgb(0,0,0)" />
$self->{svg}
</svg>  
EndSVG

  close $fh
}

1;
