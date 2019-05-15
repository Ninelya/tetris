program tetris;
{$R-}
uses Graph, crt;

label 888; {Again}

const
 MAX_LEVEL=16;{>=1}
 MAX_LINES=15;{>=1}
 MAX_SPEED=5; {>1}
 ONE_ROW_SCORE=50;
 
 MIN_LEVEL=1;	
 MIN_SPEED=1;	
 MIN_LINES=0;	
 MIN_SCORE=0;

 PIXEL_SIZE=9;
 FIELD_WIDTH=10;
 FIELD_HEIGHT=20;
 FIG_SIZE=4;
 FIGURE_COUNT=19;
 
 FIG_O=1;
 FIG_I=2;
 FIG_I_DOWN=3;
 FIG_S=4;
 FIG_S_LEFT=5;
 FIG_Z=6;
 FIG_Z_RIGHT=7;
 FIG_T=8;
 FIG_T_LEFT=9;
 FIG_T_DOWN=10;
 FIG_T_RIGHT=11;
 FIG_J=12;
 FIG_J_LEFT=13;
 FIG_J_DOWN=14;
 FIG_J_RIGHT=15;
 FIG_L=16;
 FIG_L_LEFT=17;
 FIG_L_DOWN=18;
 FIG_L_RIGHT=19;

 YTOP=73; {top left point of the field}
 XLEFT=275;
 XMENU=370; {left coordinate of the next figure in Menu}
 XNOW_FIRST=3;{first coords of the falling figure}
 YNOW_FIRST=-1;

 STANDARD_LINE=0;
 HOR_TEXT=0;
 SMALL_TEXT=1;
 MEDIUM_TEXT=2;
 BIG_TEXT=3;
 MAX_DELAY=65500;
 
var 
 _Speed,_Score,_OneSpeedLines,_TotalLines:word;
 _Level:integer;
 _IsFinish:boolean;
  
 _FigureNow,_FigNext:integer; {number of current and next figures}
 _Point:integer; {bottom left point of fallen figure}
 _Xnow,_Ynow:integer; {current coords of the figure}
 _Pix:pointer;{one square}
 _PixSize:longint; {size of the square}
 _Time:longint;{number of ticks in 1 milisecond}
 
 {main field matrix with extra line and column}
 _MainField:array[1..FIELD_WIDTH,0..FIELD_HEIGHT] of boolean; 
 _LinesSum:array[0..FIELD_HEIGHT] of integer; {sum of lines}
 _FigBox:array[1..FIG_SIZE,1..FIG_SIZE] of boolean; {figure matrix for movement}
 _Box:array[1..FIGURE_COUNT,1..FIG_SIZE,1..2] of integer; {Pixels' coordinates of all figures}
 
 {technical}
 _Output:string;
 i,j:integer; 
 
procedure SaveFigures;
var
 x,y,pixel1,pixel2,pixel3,pixel4:integer;
begin
 x:=1;
 y:=2;
 pixel1:=1;
 pixel2:=2;
 pixel3:=3;
 pixel4:=4; 
 
 _Box[FIG_O,pixel1,x]:=2;       {  1234}
 _Box[FIG_O,pixel1,y]:=2;       {1 ....}
 _Box[FIG_O,pixel2,x]:=2;       {2 .13.}
 _Box[FIG_O,pixel2,y]:=3;       {3 .24.}
 _Box[FIG_O,pixel3,x]:=3;       {4 ....}
 _Box[FIG_O,pixel3,y]:=2;
 _Box[FIG_O,pixel4,x]:=3;
 _Box[FIG_O,pixel4,y]:=3;
 
 _Box[FIG_I,pixel1,x]:=2;       {  1234}
 _Box[FIG_I,pixel1,y]:=1;       {1 .1..}
 _Box[FIG_I,pixel2,x]:=2;       {2 .2..}
 _Box[FIG_I,pixel2,y]:=2;       {3 .3..}
 _Box[FIG_I,pixel3,x]:=2;       {4 .4..}
 _Box[FIG_I,pixel3,y]:=3;
 _Box[FIG_I,pixel4,x]:=2;
 _Box[FIG_I,pixel4,y]:=4;
 
 _Box[FIG_I_DOWN,pixel1,x]:=1;  {  1234}
 _Box[FIG_I_DOWN,pixel1,y]:=2;  {1 ....}
 _Box[FIG_I_DOWN,pixel2,x]:=2;  {2 1234}
 _Box[FIG_I_DOWN,pixel2,y]:=2;  {3 ....}
 _Box[FIG_I_DOWN,pixel3,x]:=3;  {4 ....}
 _Box[FIG_I_DOWN,pixel3,y]:=2;
 _Box[FIG_I_DOWN,pixel4,x]:=4;
 _Box[FIG_I_DOWN,pixel4,y]:=2;
 
 _Box[FIG_S,pixel1,x]:=2;       {  1234}
 _Box[FIG_S,pixel1,y]:=2;       {1 ....}
 _Box[FIG_S,pixel2,x]:=3;       {2 .12.}
 _Box[FIG_S,pixel2,y]:=2;       {3 34..}
 _Box[FIG_S,pixel3,x]:=1;       {4 ....}
 _Box[FIG_S,pixel3,y]:=3;
 _Box[FIG_S,pixel4,x]:=2;
 _Box[FIG_S,pixel4,y]:=3;
 
 _Box[FIG_S_LEFT,pixel1,x]:=2;  {  1234}
 _Box[FIG_S_LEFT,pixel1,y]:=2;  {1 ....}
 _Box[FIG_S_LEFT,pixel2,x]:=2;  {2 .1..}
 _Box[FIG_S_LEFT,pixel2,y]:=3;  {3 .23.}
 _Box[FIG_S_LEFT,pixel3,x]:=3;  {4 ..4.}
 _Box[FIG_S_LEFT,pixel3,y]:=3;
 _Box[FIG_S_LEFT,pixel4,x]:=3;
 _Box[FIG_S_LEFT,pixel4,y]:=4;

 _Box[FIG_Z,pixel1,x]:=1;       {  1234}
 _Box[FIG_Z,pixel1,y]:=2;       {1 ....}
 _Box[FIG_Z,pixel2,x]:=2;       {2 12..}
 _Box[FIG_Z,pixel2,y]:=2;       {3 .34.}
 _Box[FIG_Z,pixel3,x]:=2;       {4 ....}
 _Box[FIG_Z,pixel3,y]:=3;
 _Box[FIG_Z,pixel4,x]:=3;
 _Box[FIG_Z,pixel4,y]:=3;
 
 _Box[FIG_Z_RIGHT,pixel1,x]:=3; {  1234}
 _Box[FIG_Z_RIGHT,pixel1,y]:=2; {1 ....}
 _Box[FIG_Z_RIGHT,pixel2,x]:=3; {2 ..1.}
 _Box[FIG_Z_RIGHT,pixel2,y]:=3; {3 .32.}
 _Box[FIG_Z_RIGHT,pixel3,x]:=2; {4 .4..}
 _Box[FIG_Z_RIGHT,pixel3,y]:=3;
 _Box[FIG_Z_RIGHT,pixel4,x]:=2;
 _Box[FIG_Z_RIGHT,pixel4,y]:=4;
 
 _Box[FIG_T,pixel1,x]:=1;       {  1234}      
 _Box[FIG_T,pixel1,y]:=2;       {1 ....}        
 _Box[FIG_T,pixel2,x]:=2;       {2 123.}        
 _Box[FIG_T,pixel2,y]:=2;       {3 .4..}        
 _Box[FIG_T,pixel3,x]:=3;       {4 ....}
 _Box[FIG_T,pixel3,y]:=2;
 _Box[FIG_T,pixel4,x]:=2;                     
 _Box[FIG_T,pixel4,y]:=3;

 _Box[FIG_T_LEFT,pixel1,x]:=2;  {  1234}        
 _Box[FIG_T_LEFT,pixel1,y]:=1;  {1 .1..}         
 _Box[FIG_T_LEFT,pixel2,x]:=2;  {2 .24.}         
 _Box[FIG_T_LEFT,pixel2,y]:=2;  {3 .3..}         
 _Box[FIG_T_LEFT,pixel3,x]:=2;  {4 ....}               
 _Box[FIG_T_LEFT,pixel3,y]:=3;
 _Box[FIG_T_LEFT,pixel4,x]:=3;
 _Box[FIG_T_LEFT,pixel4,y]:=2;

 _Box[FIG_T_DOWN,pixel1,x]:=2;  {  1234}
 _Box[FIG_T_DOWN,pixel1,y]:=1;  {1 .1..}
 _Box[FIG_T_DOWN,pixel2,x]:=1;  {2 234.}
 _Box[FIG_T_DOWN,pixel2,y]:=2;  {3 ....}
 _Box[FIG_T_DOWN,pixel3,x]:=2;  {4 ....}
 _Box[FIG_T_DOWN,pixel3,y]:=2;  
 _Box[FIG_T_DOWN,pixel4,x]:=3;
 _Box[FIG_T_DOWN,pixel4,y]:=2;
 
 _Box[FIG_T_RIGHT,pixel1,x]:=1; {  1234}          
 _Box[FIG_T_RIGHT,pixel1,y]:=2; {1 .2..}
 _Box[FIG_T_RIGHT,pixel2,x]:=2; {2 13..}          
 _Box[FIG_T_RIGHT,pixel2,y]:=1; {3 .4..}
 _Box[FIG_T_RIGHT,pixel3,x]:=2; {4 ....}          
 _Box[FIG_T_RIGHT,pixel3,y]:=2;            
 _Box[FIG_T_RIGHT,pixel4,x]:=2;
 _Box[FIG_T_RIGHT,pixel4,y]:=3;
 
 _Box[FIG_J,pixel1,x]:=2;       {  1234}   
 _Box[FIG_J,pixel1,y]:=2;       {1 ....}  
 _Box[FIG_J,pixel2,x]:=2;       {2 .1..}  
 _Box[FIG_J,pixel2,y]:=3;       {3 .2..}  
 _Box[FIG_J,pixel3,x]:=2;       {4 43..}
 _Box[FIG_J,pixel3,y]:=4;
 _Box[FIG_J,pixel4,x]:=1;
 _Box[FIG_J,pixel4,y]:=4;
 
 _Box[FIG_J_LEFT,pixel1,x]:=1;  {  1234}
 _Box[FIG_J_LEFT,pixel1,y]:=2;  {1 ....}
 _Box[FIG_J_LEFT,pixel2,x]:=2;  {2 123.}    
 _Box[FIG_J_LEFT,pixel2,y]:=2;  {3 ..4.}    
 _Box[FIG_J_LEFT,pixel3,x]:=3;  {4 ....}    
 _Box[FIG_J_LEFT,pixel3,y]:=2;      
 _Box[FIG_J_LEFT,pixel4,x]:=3;
 _Box[FIG_J_LEFT,pixel4,y]:=3;
 
 _Box[FIG_J_DOWN,pixel1,x]:=2;  {  1234}
 _Box[FIG_J_DOWN,pixel1,y]:=2;  {1 ....}
 _Box[FIG_J_DOWN,pixel2,x]:=2;  {2 .14.}
 _Box[FIG_J_DOWN,pixel2,y]:=3;  {3 .2..}
 _Box[FIG_J_DOWN,pixel3,x]:=2;  {4 .3..}
 _Box[FIG_J_DOWN,pixel3,y]:=4; 
 _Box[FIG_J_DOWN,pixel4,x]:=3;
 _Box[FIG_J_DOWN,pixel4,y]:=2;
 
 _Box[FIG_J_RIGHT,pixel1,x]:=1; {  1234}           
 _Box[FIG_J_RIGHT,pixel1,y]:=3; {1 ....}           
 _Box[FIG_J_RIGHT,pixel2,x]:=2; {2 4...}                 
 _Box[FIG_J_RIGHT,pixel2,y]:=3; {3 123.}
 _Box[FIG_J_RIGHT,pixel3,x]:=3; {4 ....}           
 _Box[FIG_J_RIGHT,pixel3,y]:=3;            
 _Box[FIG_J_RIGHT,pixel4,x]:=1;
 _Box[FIG_J_RIGHT,pixel4,y]:=2;
 
 _Box[FIG_L,pixel1,x]:=2;       {  1234}
 _Box[FIG_L,pixel1,y]:=2;       {1 ....}
 _Box[FIG_L,pixel2,x]:=2;       {2 .1..}
 _Box[FIG_L,pixel2,y]:=3;       {3 .2..}
 _Box[FIG_L,pixel3,x]:=2;       {4 .34.}
 _Box[FIG_L,pixel3,y]:=4;
 _Box[FIG_L,pixel4,x]:=3;
 _Box[FIG_L,pixel4,y]:=4;
 
 _Box[FIG_L_LEFT,pixel1,x]:=1;  {  1234}    
 _Box[FIG_L_LEFT,pixel1,y]:=3;  {1 ....}    
 _Box[FIG_L_LEFT,pixel2,x]:=2;  {2 ..4.}    
 _Box[FIG_L_LEFT,pixel2,y]:=3;  {3 123.}    
 _Box[FIG_L_LEFT,pixel3,x]:=3;  {4 ....}
 _Box[FIG_L_LEFT,pixel3,y]:=3;
 _Box[FIG_L_LEFT,pixel4,x]:=3;
 _Box[FIG_L_LEFT,pixel4,y]:=2;

 _Box[FIG_L_DOWN,pixel1,x]:=1;  {  1234}        
 _Box[FIG_L_DOWN,pixel1,y]:=2;  {1 ....}       
 _Box[FIG_L_DOWN,pixel2,x]:=2;  {2 12..}       
 _Box[FIG_L_DOWN,pixel2,y]:=2;  {3 .3..}       
 _Box[FIG_L_DOWN,pixel3,x]:=2;  {4 .4..}
 _Box[FIG_L_DOWN,pixel3,y]:=3;
 _Box[FIG_L_DOWN,pixel4,x]:=2;
 _Box[FIG_L_DOWN,pixel4,y]:=4;
 
 _Box[FIG_L_RIGHT,pixel1,x]:=1; {  1234}      
 _Box[FIG_L_RIGHT,pixel1,y]:=2; {1 ....}     
 _Box[FIG_L_RIGHT,pixel2,x]:=2; {2 123.}     
 _Box[FIG_L_RIGHT,pixel2,y]:=2; {3 4...}     
 _Box[FIG_L_RIGHT,pixel3,x]:=3; {4 ....}
 _Box[FIG_L_RIGHT,pixel3,y]:=2;
 _Box[FIG_L_RIGHT,pixel4,x]:=1;
 _Box[FIG_L_RIGHT,pixel4,y]:=3;

end;{SaveFigures}

{====================================================}

procedure PausePicture (ticks:longint);
begin
 if ticks>MAX_DELAY
  then begin
   for i:=1 to (ticks div MAX_DELAY) do 
    delay(MAX_DELAY);
   delay(ticks mod MAX_DELAY);
  end
  else delay(ticks);
end;

procedure Timing;
var 
 ticks:longint; {quantity of Timer ticks in 5 secs of delay}
 delays:longint; {quantity of delay in 5 secs of real time}
 timer:longint absolute $0040:$006C;
begin
 writeln;
 writeln(' Correcting delay will take about 5 seconds, please wait.');
 ticks:=timer;
 delays:=0;
 while timer<=(ticks+46) do 
 begin
  delay(1);
  inc(delays); 
 end;
 ticks:=timer;
 PausePicture(delays);
 ticks:=timer-ticks; 
 while (keypressed) do 
  readkey;
 writeln(' 1 sec of runTime = delay(',round(delays/(ticks*55)*1000)+1,')');
 writeln(' Press any key to continue.');
 _Time:=round(delays/(ticks*55));
 if ((_Time mod 1)>4) or (_Time<1) 
  then inc(_Time);
 readkey;
 clrscr;
 while (keypressed) do 
  readkey;
end;{Timing}

procedure SetDefaultTextStyle;
begin
 settextstyle(DefaultFont,HOR_TEXT,MEDIUM_TEXT);
end;{SetDefaultTextStyle}

procedure SetDefaultFillStyle;
begin
 setfillstyle(SolidFill,LightGray);
end;{SetDefaultFillStyle}

procedure SetDefaultColor;
begin
 setcolor(Black);
end;{SetDefaultColor}

procedure SetDefaultLineStyle;
begin
 setlinestyle(SolidLn,STANDARD_LINE,NormWidth);
end;{SetDefaultLineStyle}

procedure BarOnField(x1,y1,x2,y2:integer);
begin
 bar(XLEFT+x1,YTOP+y1,XLEFT+x2,YTOP+y2);
end;{BarOnField}

procedure BarOnMenu(x1,y1,x2,y2:integer);
begin
 bar(XMENU+x1,YTOP+y1,XMENU+x2,YTOP+y2);
end;{BarOnMenu}

procedure Eraser(xi,yi,x0,y0:integer);
var
 x,y:integer;
begin
 x:=x0+(xi-1)*PIXEL_SIZE;
 y:=y0+(yi-1)*PIXEL_SIZE;
 bar(x,y,x+7,y+7);
end;{Eraser}

procedure SavePixel;
begin
 moveto(1,1);
 linerel(0,7);
 linerel(7,0);
 linerel(0,-7);
 linerel(-7,0);

 setfillstyle(SolidFill,Black);
 bar(3,3,6,6);
 SetDefaultFillStyle;
 
 _PixSize:=imagesize(1,1,PIXEL_SIZE-1,PIXEL_SIZE-1);
 getmem(_Pix,_PixSize);
 getimage(1,1,PIXEL_SIZE-1,PIXEL_SIZE-1,_Pix^);
 Eraser(1,1,1,1);
end;{SavePixel}

procedure PlayGround;
begin
 moveto((getmaxx-94) div 2, 70); {roof}
 linerel(94,0);

 moverel(0,3); {right}
 linerel(0,178);

 moverel(0,3); {floor}
 linerel(-94,0);

 moverel(0,-3); {left}
 linerel(0,-178);
end;{PlayGround}

procedure WriteOnField(x,y:integer;s:string);
begin
 outtextxy(XLEFT+x,YTOP+y,s);
end;{WriteOnField}

procedure WriteOnMenu(x,y:integer;s:string);
begin
 outtextxy(XMENU+x,YTOP+y,s);
end;{WriteOnMenu}

procedure Menu;
begin
 settextstyle(DefaultFont,HOR_TEXT,BIG_TEXT);
 WriteOnField(-25,-50,'Tetris');
 settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);

 WriteOnMenu(0,45,'Lines:');
 WriteOnMenu(0,60,'Score:');
 WriteOnMenu(0,157,'Level:');
 WriteOnMenu(0,172,'Speed:');

 setcolor(DarkGray);
 WriteOnField(-200,55,'Pause:');
 WriteOnField(-200,75,'Exit:');
 WriteOnField(-200,95,'Rotate:');
 WriteOnField(-200,115,'Faster:');
 WriteOnField(-200,135,'Left:');
 WriteOnField(-200,155,'Right:');
 WriteOnField(-200,175,'Fall:');

 WriteOnField(-130,55,'Enter');
 WriteOnField(-130,75,'Escape');
 WriteOnField(-130,95,'num 8');
 WriteOnField(-130,115,'num 5');
 WriteOnField(-130,135,'num 4');
 WriteOnField(-130,155,'num 6');
 WriteOnField(-130,175,'num 0');

 WriteOnField(-70,95,'W');
 WriteOnField(-70,115,'S');
 WriteOnField(-70,135,'A');
 WriteOnField(-70,155,'D');
 WriteOnField(-70,175,'Space');

 WriteOnField(-50,95,chr(24));  {arrow up}
 WriteOnField(-50,115,chr(25)); {arrow down}
 WriteOnField(-50,135,chr(27)); {arrow left}
 WriteOnField(-50,155,chr(26)); {arrow right}

 outtextxy(getmaxx-115,getmaxy-15,'Homeniuk Nina');
 SetDefaultColor;
 SetDefaultTextStyle;
end;{Menu}

{====================================================}

procedure Pixel (x,y,x0:integer);
begin
 putimage(x0+(x-1)*PIXEL_SIZE, YTOP+(y-1)*PIXEL_SIZE, _Pix^, 0);
end;{Pixel}

procedure NewFig(figure,xi,yi,x0:integer);
var 
 x,y:integer;
begin
 for i:=1 to FIG_SIZE do
  for j:=1 to FIG_SIZE do
   _FigBox[i,j]:=false; 
 for i:=1 to FIG_SIZE do 
 begin
  x:=_Box[figure,i,1];
  y:=_Box[figure,i,2];
  _FigBox[x,y]:=true;
  Pixel(xi+x,yi+y,x0);
 end;
end;{NewFig}

procedure NewFigure;
begin
 NewFig(_FigureNow,_Xnow,_Ynow,XLEFT);
end;{NewFigure}

procedure NewFigNext;
begin
 NewFig(_FigNext,0,0,XMENU);
end;{NewFigNext}

procedure DelFig(figure,xi,yi,x0:integer);
var 
 x,y:integer;
begin
 for i:=1 to FIG_SIZE do
 begin
  x:=_Box[figure,i,1];
  y:=_Box[figure,i,2];
  Eraser(xi+x,yi+y,x0,YTOP);
 end;
end;{DelFig}

procedure DelFigure;
begin
 DelFig(_FigureNow,_Xnow,_Ynow,XLEFT);
end;{DelFigure}

procedure DelFigNext;
begin
 DelFig(_FigNext,0,0,XMENU);
end;{DelFigNext}

procedure FullRow(y0:integer);
begin
 for i:=1 to FIELD_WIDTH do
  Pixel(i,y0,XLEFT);
end;{FullRow}

procedure DelRow(y0:integer);
begin
 for i:=1 to FIELD_WIDTH do
  Eraser(i,y0,XLEFT,YTOP);
end;{DelRow}

function CheckFall: boolean;
var
 figLinesSum:integer; 
 canFall:boolean;
 x,y:integer;
begin
 canFall:=true;
 for i:=1 to FIG_SIZE do 
 begin
  figLinesSum:=0;
  for j:=1 to FIG_SIZE do
   if _FigBox[i,j]
    then figLinesSum:=j;
  if (figLinesSum<>0) 
   then begin
    x:=_Xnow+i;
    y:=_Ynow+figLinesSum+1;
    canFall:=canFall
     and not _MainField[x,y]
	 and (y<=FIELD_HEIGHT);
   end;
 end;
 CheckFall:=canFall;
end;{CheckFall}

function CheckLeft: boolean;
var
 figColsSum:integer; 
 canGoLeft:boolean;
 x,y:integer;
begin
 canGoLeft:=true;
 for j:=1 to FIG_SIZE do 
 begin
  figColsSum:=0;
  for i:=FIG_SIZE downto 1 do
   if _FigBox[i,j]
    then figColsSum:=i;
  if (figColsSum<>0) 
   then begin
    x:=_Xnow+figColsSum-1;
	y:=_Ynow+j;
    canGoLeft:=canGoLeft 
	 and not _MainField[x,y]
	 and (x>0);
   end;
 end;
 CheckLeft:=canGoLeft;
end;{CheckLeft}

function CheckRight: boolean;
var
 figColsSum:integer; 
 canGoRight:boolean;
 x,y:integer;
begin
 canGoRight:=true;
 for j:=1 to FIG_SIZE do 
 begin
  figColsSum:=0;
  for i:=1 to FIG_SIZE do
   if _FigBox[i,j]
    then figColsSum:=i;
  if (figColsSum<>0) 
   then begin
    x:=_Xnow+figColsSum+1;
    y:=_Ynow+j;
    canGoRight:=canGoRight 
	 and not _MainField[x,y] 
	 and (x<=FIELD_WIDTH);
   end;
 end;
 CheckRight:=canGoRight;
end;{CheckRight}

procedure MoveRight;
begin
 if CheckRight 
  then begin
   DelFigure;
   inc(_Xnow);
   NewFigure;
  end;
end; {MoveRight}

procedure MoveLeft;
begin
 if CheckLeft 
  then begin
   DelFigure;
   dec(_Xnow);
   NewFigure;
  end;
end;{MoveLeft}

procedure MoveDown;
begin
 if CheckFall 
  then begin
   DelFigure;
   inc(_Ynow);
   NewFigure;
  end;
end;{MoveDown}

function CheckRot(xi,yi:integer): boolean;
var 
 x,y:integer;
begin
 x:=_Xnow+xi;
 y:=_Ynow+yi; 
 case x of
  0: MoveRight;
  11: begin
   MoveLeft;
   if _FigureNow=FIG_I
    then MoveLeft;
  end;
 end;
 if (y=0) 
  then MoveDown;
 x:=_Xnow+xi;
 y:=_Ynow+yi; 
 CheckRot:= not _MainField[x,y] 
   and (x>0) and (x<=FIELD_WIDTH) 
   and (y>0) and (y<=FIELD_HEIGHT);
end;{CheckRot}

function CheckRotate(newFig:integer): boolean;
var
 canRotate:boolean;
 x,y:integer;
begin
 if(newFig=_FigureNow)
  then canRotate:=false 
  else begin
   canRotate:=true;
   for i:=1 to FIG_SIZE do 
   begin
    x:=_Box[newFig,i,1];
    y:=_Box[newFig,i,2];
	if not _FigBox[x,y]
      then canRotate:=canRotate and CheckRot(x,y);
   end;
  end;
 CheckRotate:=canRotate;
end;{CheckRotate}

procedure Rotate;
var 
 newFig:integer;
begin
 case _FigureNow of
  FIG_O: newFig:=_FigureNow;
  FIG_I_DOWN,
  FIG_S_LEFT,
  FIG_Z_RIGHT: newFig:=_FigureNow-1;
  FIG_T_RIGHT: newFig:=FIG_T;
  FIG_J_RIGHT: newFig:=FIG_J;
  FIG_L_RIGHT: newFig:=FIG_L;
  else newFig:=_FigureNow+1;
 end;
 if CheckRotate(newFig)
  then begin
   DelFigure;
   _FigureNow:=newFig;
   NewFigure;
  end;
end;{Rotate}

procedure Crash;
begin
 DelFigure;
 while CheckFall do
  inc(_Ynow);
 NewFigure;
end;{Crash}

procedure BlackPixel(x,y:integer);
begin
 putpixel(XMENU+x,YTOP+y,Black);
end;

procedure Pause;
begin
 setcolor(DarkGray);
 WriteOnMenu(0,80,'Pause');
 setfillstyle(SolidFill,DarkGray);
 pieslice(XMENU+30,YTOP+120,180,360,20);
 BarOnMenu(10,115,50,120);
 BarOnMenu(5,140,55,144);
 setlinestyle(SolidLn,STANDARD_LINE,ThickWidth);
 circle(XMENU+54,YTOP+125,7);
 SetDefaultLineStyle;
 SetDefaultFillStyle;
 SetDefaultColor;

 for i:=2 to 4 do begin
  BlackPixel(i*10,110);
  BlackPixel(i*10,109);
  BlackPixel(i*10,108);
  BlackPixel(i*10+1,107);
  BlackPixel(i*10+2,106);
  BlackPixel(i*10+2,105);
  BlackPixel(i*10+2,104);
  BlackPixel(i*10+1,103);
  BlackPixel(i*10,102);
  BlackPixel(i*10,101);
 end;
end;{Pause}

function SpeedDelay:integer;
begin
 SpeedDelay:=630-(_Speed-1)*480 div (MAX_SPEED-1);
end;{SpeedDelay}

procedure FallControl;
var 
 delays:real;
 canGoDown:boolean;
begin
 canGoDown:=true;
 while canGoDown do
 begin
  if not CheckFall 
   then canGoDown:=false;
  delays:=0;
  repeat
   delay(_Time);
   delays:=delays+1;
   if keypressed 
    then case readkey of			{866 symbol table (ASCII, OEM, DOS)}
      #27: begin 					{ESC}
       _IsFinish:=true; 
       exit;
      end;
      #13: begin					{Enter}
       Pause;
       if readkey=#27 				{ESC}
        then begin
         _IsFinish:=true; 
         exit;
        end
        else begin 
         BarOnMenu(-3,70,100,155); 
        end;
      end;
      #48,#32: begin				{num0,Space}
       Crash;
       exit;
      end;
      #56,#87,#119,#150,#230: begin {num8,W,w,Ц,ц}
       Rotate;
       canGoDown:=true;
      end;
      #54,#68,#100,#130,#162: begin	{num6,D,d,В,в}
       MoveRight;
       canGoDown:=true;
      end;
      #52,#65,#97,#148,#228: begin	{num4,A,a,Ф,ф}
       MoveLeft;
       canGoDown:=true;
      end;
      #53,#83,#115,#155,#235:		{num2,S,s,І,і}
       delays:=SpeedDelay;
      #0: case readkey of
        #72: begin 					{arrow up}
         Rotate;
         canGoDown:=true;
        end;
        #77: begin 					{arrow right}
         MoveRight;
         canGoDown:=true;
        end;
        #75: begin 					{arrow left}
         MoveLeft;
         canGoDown:=true;
        end;
        #80: 						{arrow down}
         delays:=SpeedDelay;
      end;
    end;
  until delays>(SpeedDelay-5);
  MoveDown;
 end;{while}
end;{FallControl}

procedure Delete;
var 
 loweredLine,row,loweredSum,fullRowsNum:integer;
 fullRows:array[1..FIG_SIZE] of integer; {full rows to be deleted}
 mainFieldCopy:array[1..FIELD_WIDTH,0..FIELD_HEIGHT] of boolean; 
begin
 for i:=1 to FIG_SIZE do
  fullRows[i]:=0;
 
 {remember indexes of full rows in array fullRows}
 fullRowsNum:=0;
 repeat
  if (_LinesSum[_Point]=FIELD_WIDTH) 
   then begin
    inc(fullRowsNum);
    fullRows[fullRowsNum]:=_Point; 
   end;
  dec(_Point);
 until (_LinesSum[_Point]=0); {_Point - first non zero line, go bottom up}

 if (fullRowsNum>0) 
  then begin {there are full rows}

   {increment points and lines}
   _OneSpeedLines:=_OneSpeedLines+fullRowsNum;
   _TotalLines:=_TotalLines+fullRowsNum;
   BarOnMenu(49,44,100,54);
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
   str(_TotalLines,_Output);
   WriteOnMenu(50,45,_Output);{rows}

   _Score:=_Score+(fullRowsNum+1)*ONE_ROW_SCORE; 
   BarOnMenu(49,59,100,69);
   str(_Score,_Output);
   WriteOnMenu(50,60,_Output);{scores}
   SetDefaultTextStyle;

   {blink with full rows}
   delay(_Time*250);
   for row:=1 to fullRowsNum do 
    DelRow(fullRows[row]);
   delay(_Time*250);
   for row:=1 to fullRowsNum do 
    FullRow(fullRows[row]);
   delay(_Time*250);
   for row:=1 to fullRowsNum do 
   begin
    DelRow(fullRows[row]);
    _LinesSum[fullRows[row]]:=0;
   end;
   delay(_Time*250);
   
   {_move down what's left_}
   {save all visible to matrix mainFieldCopy and arase}
   loweredSum:=0; {number of remaining lines}
   for loweredLine:=(_Point+1) to (fullRows[1]) do  {top to bottom}
   begin
    if (_LinesSum[loweredLine]=0) 
     then begin
      for i:=1 to FIELD_WIDTH do
       _MainField[i,loweredLine]:=false;
      continue;
     end
     else begin
      inc(loweredSum);
      for i:=1 to FIELD_WIDTH do 
      begin
       mainFieldCopy[i,loweredSum]:=_MainField[i,loweredLine];
       _MainField[i,loweredLine]:=false;
      end;
      _LinesSum[loweredLine]:=0;
      DelRow(loweredLine);
     end;
   end;

   {draw lowered lines}
   for j:=1 to loweredSum do 
   begin
    loweredLine:=fullRows[1]-loweredSum+j;
    for i:=1 to FIELD_WIDTH do 
    begin
     _MainField[i,loweredLine]:=mainFieldCopy[i,j];
     if _MainField[i,loweredLine] 
      then begin
       Pixel(i,loweredLine,XLEFT);
       inc(_LinesSum[loweredLine]);
      end;
    end;
   end;

 end;{there are full rows}
end;{Delete}

{====================================================}

procedure Hello;
 begin
 WriteOnField(0,70,'Ready?');
 WriteOnField(25,105,'Go!');
 readkey;
 BarOnField(0,49,90,130);
end;{Hello}

procedure FinishSpeed;
begin
 for j:=_Point-1 to FIELD_HEIGHT do 
 begin
  DelRow(j);
  _LinesSum[j]:=0;
 end;
 inc(_Speed);
 if _Speed<=MAX_SPEED 
  then begin
   BarOnMenu(49,171,100,181);
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
   str(_Speed,_Output);
   WriteOnMenu(50,172,_Output);{_Speed}
   SetDefaultTextStyle;
  end;
end;{FinishSpeed}

procedure Win;
begin
 WriteOnField(18,50,'Win!');
 WriteOnField(0,80,'Speed+');
 WriteOnField(23,110,':-)');
 PausePicture(_Time*1500);
 BarOnField(0,49,90,130);
end;{Win}

procedure WinLevel;
begin
 WriteOnField(18,50,'Win!');
 WriteOnField(6,80,'Level');
 WriteOnField(0,110,'up :-)');
 PausePicture(_Time*1500);
 BarOnField(0,49,90,130);
end;{WinLevel}

procedure Again;
begin
 WriteOnField(20,50,'Try');
 WriteOnField(5,80,'again');
 WriteOnField(23,110,':-)');
 readkey;
 BarOnField(4,49,82,130);
 BarOnMenu(49,171,100,181);
 BarOnMenu(49,156,100,166);
end;{Again}

procedure Looser;
begin
 for j:=FIELD_HEIGHT downto 1 do 
 begin 
  if (j mod 2 = 0) 
   then 
    for i:=FIELD_WIDTH downto 1 do 
    begin
     Pixel(i,j,XLEFT);
     delay(_Time*20);
    end
   else
    for i:=1 to FIELD_WIDTH do 
    begin 
     Pixel(i,j,XLEFT);
     delay(_Time*20);
    end;
 end;
 for j:=1 to FIELD_HEIGHT do 
  DelRow(j);
end;{Looser}

procedure Goodbye;
begin
 for j:=1 to FIELD_HEIGHT do 
  DelRow(j);
 WriteOnField(13,50,'Come');
 WriteOnField(15,80,'back');
 WriteOnField(1,110,'soon:)');
 PausePicture(_Time*1500);
 halt;
end;{Goodbye}

procedure EpicWin;
begin
 DelFigNext;
 WriteOnField(20,50,'You');
 WriteOnField(20,80,'did');
 WriteOnField(21,110,'it!');
 BarOnMenu(49,171,100,181);
 BarOnMenu(49,156,100,166); 
 PausePicture(_Time*1500);
 BarOnField(0,49,90,130);
 readkey;
end;{EpicWin}

{====================================================}

procedure CloseGame;
begin
 Goodbye;
 freemem(_Pix,_PixSize);
 closegraph;
 halt;
end;{CloseGame}

procedure SetupGraph;
var
  graphDriver,graphMode,graphError:integer;
begin
 DetectGraph(graphDriver,graphMode);
 InitGraph(graphDriver,graphMode,'');
 if GraphResult <> grOk 
  then begin
   clrscr;
   writeln(GraphErrorMsg(graphError));
   writeln('Press any key to exit.');
   readkey
  end;
end;{SetupGraph}

procedure SetupPlayGround;
begin
 cleardevice;
 SetDefaultTextStyle;
 SetDefaultFillStyle;
 SetDefaultColor;
 SetDefaultLineStyle;
 bar(0,0,getmaxx,getmaxy);

 PlayGround; {draw game field}
 Menu; {draw side Menu}
end;{SetupPlayGround}

procedure StartGame;
begin
 _TotalLines:=MIN_LINES;
 _Score:=MIN_SCORE;
 _Level:=MIN_LEVEL;
 _FigureNow:=random(FIGURE_COUNT)+1;
 _FigNext:=random(FIGURE_COUNT)+1;
 
 Hello;{ready? go!}
end;{StartGame}

procedure StartLevel;
begin
 _Speed:=MIN_SPEED;
 BarOnMenu(49,171,100,181);
 settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
 str(_Speed, _Output);
 WriteOnMenu(50,172,_Output);{_Speed}
 SetDefaultTextStyle;
end;{StartLevel}

procedure WriteLevel;
begin
 BarOnMenu(49,156,100,166);
 if (_Level<=MAX_LEVEL) {Level}
  then begin
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
   str(_Level,_Output);
   WriteOnMenu(50,157,_Output);
   SetDefaultTextStyle;
  end;
end;{WriteLevel}

procedure DrawLevel;
begin
 for j:=0 to (FIELD_HEIGHT-_Level+1) do
 begin
  _LinesSum[j]:=0;
  for i:=1 to FIELD_WIDTH do 
   _MainField[i,j]:=false;
 end;
 if (_Level>=2) 
  then
   for j:=(FIELD_HEIGHT-_Level+2) to FIELD_HEIGHT do
    for i:=1 to FIELD_WIDTH do 
    begin
     _MainField[i,j]:=random(2)=0;
     if _MainField[i,j]
      then begin
       _LinesSum[j]:=_LinesSum[j]+1;
       Pixel(i,j,XLEFT);
      end;
    end;
end;{DrawLevel}

procedure DrawFigures;
begin
 {draw next figure}
 DelFigNext;
 _FigNext:=random(FIGURE_COUNT)+1;
 NewFigNext;

 {top left point of figure}
 _Xnow:=XNOW_FIRST; 
 _Ynow:=YNOW_FIRST;
 for i:=1 to FIG_SIZE do
  if (_Box[_FigureNow,i,2]=1)
   then begin
    inc(_Ynow);
	break;
   end;
  
 NewFigure; {draw current figure}
end;{DrawFigures}

procedure AddFigure;
var 
 x,y:integer;
begin
 _Point:=1;
 y:=1;
 for i:=1 to FIG_SIZE do 
 begin
  x:=_Xnow+_Box[_FigureNow,i,1];
  y:=_Ynow+_Box[_FigureNow,i,2];
  _MainField[x,y]:=true;
  _LinesSum[y]:=_LinesSum[y]+1;
  if (y>_Point) 
   then _Point:=y;
 end;
end;{AddFigure}

procedure NextSpeed;
begin
 {clear screen and go to next speed}
 FinishSpeed; 
 delay(_Time*250);
 if _Speed<=MAX_SPEED 
  then Win
  else 
   if _Level<MAX_LEVEL 
    then WinLevel;
end;{NextSpeed}

{====================================================}

begin
 randomize;
 clrscr;
 Timing;
 SetupGraph;
 SetupPlayGround;
 SavePixel;
 SaveFigures;
 _IsFinish:=false;
 while not _IsFinish do {game session}
 begin
  StartGame;
  888:
  repeat {one level}
   StartLevel;
   WriteLevel;
   while (_Speed<=MAX_SPEED) do {one speed}
   begin
    _OneSpeedLines:=MIN_LINES;
    {initial filling of field matrix with zeros + level}
    DrawLevel; 
    repeat{one figure fall}
     if keypressed 
      then readkey;
     
     {draw current and next figures} 
     DrawFigures;
     
     {main fall and control}
     FallControl; 
     if _IsFinish 
      then CloseGame;
     
     {add freshly fallen figure to the field matrix}
     AddFigure; 

     {delete full rows if there are any}
     Delete; 

     {check if level is lost and goto start if yes}
     if (_LinesSum[1]>0) 
      then begin 
       Looser; 
       Again;
       goto 888;
      end;

     _FigureNow:=_FigNext;
    until (_OneSpeedLines>=MAX_LINES); {one figure fall}
    NextSpeed;
   end; {one Speed}
   inc(_Level);
   WriteLevel;
  until (_Level>MAX_LEVEL); {one level}
  EpicWin;
 end; {game session}
end.
