program tetris;
{$R-}
uses Graph, crt;

label 888; {Again}

const
 MAX_LEVEL=16;{>=1}
 MAX_LINES=15;{>=1}
 MAX_SPEED=5; {>1}

 PIXEL_SIZE=9;
 FIELD_WIDTH=10;
 FIELD_HEIGHT=20;
 FIG_SIZE=4;
 FIGURE_COUNT=19;

 TOPY=73; {top left point of the field}
 LEFTX=275;
 XM=370; {left coordinate of the next figure in Menu}

 STANDARD_LINE=0;
 HOR_TEXT=0;
 SMALL_TEXT=1;
 MEDIUM_TEXT=2;
 BIG_TEXT=3;
 MAX_DELAY=65500;
 
var 
 _Speed,_Score,_OneSpeedLines,_TotalLines:word;
 _IsFinish:boolean;
 _Output:string;
 
 _Level:integer;{level number}
 _FigureNow,_FigNext:integer; {number of current and next figures}
 _Point:integer; {bottom left point of fallen figure}
 _GraphDriver,_GraphMode,_GraphError:integer;{for graphics setup}
 _Xnow,_Ynow:integer; {current coords of the figure}
 _Pix:pointer;{one square}
 _PixSize:longint; {size of the square}
 _Time:longint;{number of ticks in 1 milisecond}
 i,j:integer; {technical}

 {main and extra field matrixes with extra line and column}
 _MainField,_MainFieldCopy:array[1..FIELD_WIDTH,0..FIELD_HEIGHT] of boolean; 
 _LinesSum:array[0..FIELD_HEIGHT] of integer; {sum of lines}
 _FigBox:array[1..FIG_SIZE,1..FIG_SIZE] of boolean; {figure matrix}
 _Box:array[1..FIGURE_COUNT,1..FIG_SIZE,1..2] of integer; {Pixels coordinates of all figures}
 
procedure SaveFigures;
begin
 _Box[1,1,1]:=2; {....}
 _Box[1,1,2]:=2; {.xx.}
 _Box[1,2,1]:=2; {.xx.}
 _Box[1,2,2]:=3; {....}
 _Box[1,3,1]:=3;
 _Box[1,3,2]:=2;
 _Box[1,4,1]:=3;
 _Box[1,4,2]:=3;
 
 _Box[2,1,1]:=1; {....} 
 _Box[2,1,2]:=2; {xxxx}
 _Box[2,2,1]:=2; {....}
 _Box[2,2,2]:=2; {....}
 _Box[2,3,1]:=3;
 _Box[2,3,2]:=2;
 _Box[2,4,1]:=4;
 _Box[2,4,2]:=2;
 
 _Box[3,1,1]:=2; {.x..}
 _Box[3,1,2]:=1; {.x..}
 _Box[3,2,1]:=2; {.x..}
 _Box[3,2,2]:=2; {.x..}
 _Box[3,3,1]:=2;
 _Box[3,3,2]:=3;
 _Box[3,4,1]:=2;
 _Box[3,4,2]:=4;
 
 _Box[4,1,1]:=2; {....}
 _Box[4,1,2]:=2; {.x..}
 _Box[4,2,1]:=2; {.xx.}
 _Box[4,2,2]:=3; {..x.}
 _Box[4,3,1]:=3;
 _Box[4,3,2]:=3;
 _Box[4,4,1]:=3;
 _Box[4,4,2]:=4;
 
 _Box[5,1,1]:=2; {....}
 _Box[5,1,2]:=2; {.xx.}
 _Box[5,2,1]:=3; {xx..}
 _Box[5,2,2]:=2; {....}
 _Box[5,3,1]:=1;
 _Box[5,3,2]:=3;
 _Box[5,4,1]:=2;
 _Box[5,4,2]:=3;
 
 _Box[6,1,1]:=3; {....}
 _Box[6,1,2]:=2; {..x.}
 _Box[6,2,1]:=3; {.xx.}
 _Box[6,2,2]:=3; {.x..}
 _Box[6,3,1]:=2;
 _Box[6,3,2]:=3;
 _Box[6,4,1]:=2;
 _Box[6,4,2]:=4;
 
 _Box[7,1,1]:=1; {....}
 _Box[7,1,2]:=2; {xx..}
 _Box[7,2,1]:=2; {.xx.}
 _Box[7,2,2]:=2; {....}
 _Box[7,3,1]:=2;
 _Box[7,3,2]:=3;
 _Box[7,4,1]:=3;
 _Box[7,4,2]:=3;
 
 _Box[8,1,1]:=1; {.x..}
 _Box[8,1,2]:=2; {xxx.}
 _Box[8,2,1]:=2; {....}
 _Box[8,2,2]:=2; {....}
 _Box[8,3,1]:=2;
 _Box[8,3,2]:=1;
 _Box[8,4,1]:=3;
 _Box[8,4,2]:=2;
 
 _Box[9,1,1]:=1; {.x..}
 _Box[9,1,2]:=2; {xx..}
 _Box[9,2,1]:=2; {.x..}
 _Box[9,2,2]:=2; {....}
 _Box[9,3,1]:=2;
 _Box[9,3,2]:=1;
 _Box[9,4,1]:=2;
 _Box[9,4,2]:=3;
 
 _Box[10,1,1]:=1; {....}
 _Box[10,1,2]:=2; {xxx.}
 _Box[10,2,1]:=2; {.x..}
 _Box[10,2,2]:=2; {....}
 _Box[10,3,1]:=2;
 _Box[10,3,2]:=3;
 _Box[10,4,1]:=3;
 _Box[10,4,2]:=2;
 
 _Box[11,1,1]:=2; {.x..}
 _Box[11,1,2]:=1; {.xx.}
 _Box[11,2,1]:=2; {.x..}
 _Box[11,2,2]:=2; {....}
 _Box[11,3,1]:=2;
 _Box[11,3,2]:=3;
 _Box[11,4,1]:=3;
 _Box[11,4,2]:=2;
 
 _Box[12,1,1]:=2; {....}
 _Box[12,1,2]:=4; {.xx.}
 _Box[12,2,1]:=2; {.x..}
 _Box[12,2,2]:=2; {.x..}
 _Box[12,3,1]:=2;
 _Box[12,3,2]:=3;
 _Box[12,4,1]:=3;
 _Box[12,4,2]:=2;
 
 _Box[13,1,1]:=1; {....}
 _Box[13,1,2]:=3; {x...}
 _Box[13,2,1]:=3; {xxx.}
 _Box[13,2,2]:=3; {....}
 _Box[13,3,1]:=2;
 _Box[13,3,2]:=3;
 _Box[13,4,1]:=1;
 _Box[13,4,2]:=2;
 
 _Box[14,1,1]:=2; {....}
 _Box[14,1,2]:=2; {.x..}
 _Box[14,2,1]:=2; {.x..}
 _Box[14,2,2]:=3; {xx..}
 _Box[14,3,1]:=2;
 _Box[14,3,2]:=4;
 _Box[14,4,1]:=1;
 _Box[14,4,2]:=4;
 
 _Box[15,1,1]:=2; {....}
 _Box[15,1,2]:=2; {xxx.}
 _Box[15,2,1]:=3; {..x.}
 _Box[15,2,2]:=2; {....}
 _Box[15,3,1]:=3;
 _Box[15,3,2]:=3;
 _Box[15,4,1]:=1;
 _Box[15,4,2]:=2;
 
 _Box[16,1,1]:=1; {....}
 _Box[16,1,2]:=2; {xx..}
 _Box[16,2,1]:=2; {.x..}
 _Box[16,2,2]:=2; {.x..}
 _Box[16,3,1]:=2;
 _Box[16,3,2]:=3;
 _Box[16,4,1]:=2;
 _Box[16,4,2]:=4;
 
 _Box[17,1,1]:=1; {....}
 _Box[17,1,2]:=2; {xxx.}
 _Box[17,2,1]:=2; {x...}
 _Box[17,2,2]:=2; {....}
 _Box[17,3,1]:=3;
 _Box[17,3,2]:=2;
 _Box[17,4,1]:=1;
 _Box[17,4,2]:=3;
 
 _Box[18,1,1]:=2; {....}
 _Box[18,1,2]:=3; {.x..}
 _Box[18,2,1]:=2; {.x..}
 _Box[18,2,2]:=2; {.xx.}
 _Box[18,3,1]:=2;
 _Box[18,3,2]:=4;
 _Box[18,4,1]:=3;
 _Box[18,4,2]:=4;
 
 _Box[19,1,1]:=2; {....}
 _Box[19,1,2]:=3; {..x.}
 _Box[19,2,1]:=1; {xxx.}
 _Box[19,2,2]:=3; {....}
 _Box[19,3,1]:=3;
 _Box[19,3,2]:=3;
 _Box[19,4,1]:=3;
 _Box[19,4,2]:=2;
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
 bar(LEFTX+x1,TOPY+y1,LEFTX+x2,TOPY+y2);
end;{BarOnField}

procedure BarOnMenu(x1,y1,x2,y2:integer);
begin
 bar(XM+x1,TOPY+y1,XM+x2,TOPY+y2);
end;{BarOnMenu}

procedure Eraser(xi,yi,x0,y0:integer);
var
 x,y:integer;
begin
 x:=x0+xi*PIXEL_SIZE;
 y:=y0+yi*PIXEL_SIZE;
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
 Eraser(0,0,1,1);
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
 outtextxy(LEFTX+x,TOPY+y,s);
end;{WriteOnField}

procedure WriteOnMenu(x,y:integer;s:string);
begin
 outtextxy(XM+x,TOPY+y,s);
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

 WriteOnField(-50,95,chr(24)); {arrow up}
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
 putimage(x0+x*PIXEL_SIZE,TOPY+y*PIXEL_SIZE,_Pix^,0);
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
  Pixel(xi+x-1,yi+y-1,x0);
 end;
end;{NewFig}

procedure NewFigure;
begin
 NewFig(_FigureNow,_Xnow,_Ynow,LEFTX);
end;{NewFigure}

procedure NewFigNext;
begin
 NewFig(_FigNext,0,0,XM);
end;{NewFigNext}

procedure DelFig(figure,xi,yi,x0:integer);
var 
 x,y:integer;
begin
 for i:=1 to FIG_SIZE do
 begin
  x:=_Box[figure,i,1];
  y:=_Box[figure,i,2];
  Eraser(xi+x-1,yi+y-1,x0,TOPY);
 end;
end;{DelFig}

procedure DelFigure;
begin
 DelFig(_FigureNow,_Xnow,_Ynow,LEFTX);
end;{DelFigure}

procedure DelFigNext;
begin
 DelFig(_FigNext,0,0,XM);
end;{DelFigNext}

procedure FullRow(y0:integer);
begin
 for i:=0 to FIELD_WIDTH-1 do
  Pixel(i,y0,LEFTX);
end;{FullRow}

procedure DelRow(y0:integer);
begin
 for i:=0 to FIELD_WIDTH-1 do
  Eraser(i,y0,LEFTX,TOPY);
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
 case x of
  0: MoveRight;
  11: begin
   MoveLeft;
   if _FigureNow=3 
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
 newBox:array[1..FIG_SIZE,1..FIG_SIZE]of boolean;
 canRotate:boolean;
begin
 if(newFig=_FigureNow)
  then canRotate:=false
  else begin
   canRotate:=true;
   for i:=1 to FIG_SIZE do
    for j:=1 to FIG_SIZE do 
	 newBox[i,j]:=false;
   for i:=1 to FIG_SIZE do 
    newBox[_Box[newFig,i,1],_Box[newFig,i,2]]:=true;
   for i:=1 to FIG_SIZE do
    for j:=1 to FIG_SIZE do 
     if not _FigBox[i,j] and newBox[i,j]
      then canRotate:=canRotate and CheckRot(i,j);
  end;
 SetDefaultTextStyle;
 CheckRotate:=canRotate;
end;{CheckRotate}

procedure Rotate;
var 
 newFig:integer;
begin
 case _FigureNow of
  1: newFig:=_FigureNow;
  3,5,7: newFig:=_FigureNow-1;
  11: newFig:=8;
  15: newFig:=12;
  19: newFig:=16;
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
 putpixel(XM+x,TOPY+y,Black);
end;

procedure Pause;
begin
 setcolor(DarkGray);
 WriteOnMenu(0,80,'Pause');
 setfillstyle(SolidFill,DarkGray);
 pieslice(XM+30,TOPY+120,180,360,20);
 BarOnMenu(10,115,50,120);
 BarOnMenu(5,140,55,144);
 setlinestyle(SolidLn,STANDARD_LINE,ThickWidth);
 circle(XM+54,TOPY+125,7);
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
 isDown:boolean;
begin
 isDown:=true;
 while isDown do
 begin
  if not CheckFall 
   then isDown:=false;
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
       isDown:=true;
      end;
      #54,#68,#100,#130,#162: begin	{num6,D,d,В,в}
       MoveRight;
       isDown:=true;
      end;
      #52,#65,#97,#148,#228: begin	{num4,A,a,Ф,ф}
       MoveLeft;
       isDown:=true;
      end;
      #53,#83,#115,#155,#235:		{num2,S,s,І,і}
       delays:=SpeedDelay;
      #0: case readkey of
        #72: begin 					{arrow up}
         Rotate;
         isDown:=true;
        end;
        #77: begin 					{arrow right}
         MoveRight;
         isDown:=true;
        end;
        #75: begin 					{arrow left}
         MoveLeft;
         isDown:=true;
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
 index,loweredLine:integer;
 fullRows:array[1..FIG_SIZE] of integer; {full rows to be deleted}
begin
 for j:=1 to FIG_SIZE do
  fullRows[j]:=0;
 j:=0;
 
 {remember indexes of full rows in array K}
 repeat
  if (_LinesSum[_Point]=FIELD_WIDTH) 
   then begin
    inc(j);
    fullRows[j]:=_Point; 
   end;
  dec(_Point);
 until (_LinesSum[_Point]=0); {q - first non zero line, go bottom up}

 if (j>0) 
  then begin {there are full rows}

   {increment points and lines}
   _OneSpeedLines:=_OneSpeedLines+j;
   _TotalLines:=_TotalLines+j;
   BarOnMenu(49,44,100,54);
   str(_TotalLines,_Output);
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
   WriteOnMenu(50,45,_Output);{rows}

   _Score:=_Score+50+j*50; 
   BarOnMenu(49,59,100,69);
   str(_Score,_Output);
   WriteOnMenu(50,60,_Output);{scores}
   SetDefaultTextStyle;

   {blink with full rows}
   delay(_Time*250);
   for index:=1 to j do 
    DelRow(fullRows[index]-1);
   delay(_Time*250);
   for index:=1 to j do 
    FullRow(fullRows[index]-1);
   delay(_Time*250);
   for index:=1 to j do 
   begin
    DelRow(fullRows[index]-1);
    _LinesSum[fullRows[index]]:=0;
   end;
   delay(_Time*250);
   
   {_move down what's left_}
   {save all visible to matrix W and arase}
   loweredLine:=0; {number of remaining lines}
   for index:=(_Point+1) to (fullRows[1]) do  {top to bottom}
   begin
    if (_LinesSum[index]=0) 
     then begin
      for j:=1 to FIELD_WIDTH do
       _MainField[j,index]:=false;
      continue;
     end
     else begin
      inc(loweredLine);
      for j:=1 to FIELD_WIDTH do 
      begin
       _MainFieldCopy[j,loweredLine]:=_MainField[j,index];
       _MainField[j,index]:=false;
      end;
      _LinesSum[index]:=0;
      DelRow(index-1);
     end;
   end;

   {draw lowered lines}
   for i:=1 to loweredLine do 
   begin
    index:=fullRows[1]-loweredLine+i;
    for j:=1 to FIELD_WIDTH do 
    begin
     _MainField[j,index]:=_MainFieldCopy[j,i];
     if _MainField[j,index] 
      then begin
       Pixel(j-1,index-1,LEFTX);
       _LinesSum[index]:=_LinesSum[index]+1;
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
  DelRow(j-1);
  _LinesSum[j]:=0;
 end;
 inc(_Speed);
 str(_Speed,_Output);
 if _Speed<=MAX_SPEED 
  then begin
   BarOnMenu(49,171,100,181);
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
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
    for i:=FIELD_WIDTH-1 downto 0 do 
    begin
     Pixel(i,j-1,LEFTX);
     delay(_Time*20);
    end
   else
    for i:=0 to FIELD_WIDTH-1 do 
    begin 
     Pixel(i,j-1,LEFTX);
     delay(_Time*20);
    end;
 end;
 for j:=1 to FIELD_HEIGHT do 
  DelRow(j-1);
end;{Looser}

procedure Goodbye;
begin
 for j:=1 to FIELD_HEIGHT do 
  DelRow(j-1);
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
begin
 DetectGraph(_GraphDriver,_GraphMode);
 InitGraph(_GraphDriver,_GraphMode,'');
 if GraphResult <> grOk 
  then begin
   clrscr;
   writeln(GraphErrorMsg(_GraphError));
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

 {draw game field}
 PlayGround; 

 {draw side Menu}
 Menu; 
end;{SetupPlayGround}

procedure StartGame;
begin
 _TotalLines:=0;
 _Score:=0;
 _Level:=1;
 _FigureNow:=random(FIGURE_COUNT)+1;
 _FigNext:=random(FIGURE_COUNT)+1;
 
 {ready? go!}
 Hello;
end;{StartGame}

procedure StartLevel;
begin
 _Speed:=1;
 str(_Speed, _Output);
 BarOnMenu(49,171,100,181);
 settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
 WriteOnMenu(50,172,_Output);{_Speed}
 SetDefaultTextStyle;
end;{StartLevel}

procedure WriteLevel;
begin
 str(_Level,_Output);
 BarOnMenu(49,156,100,166);
 if (_Level<=MAX_LEVEL) {Level}
  then begin
   settextstyle(DefaultFont,HOR_TEXT,SMALL_TEXT);
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
     if random(2)=0 
      then _MainField[i,j]:=false
      else _MainField[i,j]:=true;
     if _MainField[i,j]
      then begin
       _LinesSum[j]:=_LinesSum[j]+1;
       Pixel(i-1,j-1,LEFTX);
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
 _Xnow:=3; 
 _Ynow:=-1;
 case _FigureNow of
  3,8,9,11:
   inc(_Ynow);
 end;
 
 {draw current figure}
 NewFigure; 
end;{DrawFigures}

procedure AddFigure;
var 
 x,y:integer;
begin
 _Point:=1;
 y:=1;
 for i:=1 to FIG_SIZE do 
 begin
  for j:=1 to FIG_SIZE do
   if _FigBox[i,j]
    then begin
     x:=_Xnow+i;
     y:=_Ynow+j;
     _MainField[x,y]:=true;
     _LinesSum[y]:=_LinesSum[y]+1;
    end;
  if (y>_Point) 
   then _Point:=y;
 end;
end;{AddFigure}

procedure NextSpeed;
begin
 {clear screen and go to next speed}
 FinishSpeed; 
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
    _OneSpeedLines:=0;
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
