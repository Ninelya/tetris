program tetris;
{$R-}
uses Graph, crt;

label 888; {again}

const
 maxlevel=16;{>=1}
 maxlines=15;{>=1}
 maxspeed=5; {>1}

var 
 speed,lines,alines,score:word;
 finish,rot:boolean;
 a:string;
 
 level:integer;{level number}
 f,fnext:integer; {number of current and next figures}
 leftx,topy:integer; {top left point of the field}
 xm:integer; {coords of the next figure in menu}
 p:integer; {bottom left point of fallen figure}
 d,m,er:integer;{for graphics setup}
 xnow,ynow:integer; {current coords of the figure}
 pix:pointer;{one square}
 spix:longint; {size of the square}
 time:longint;{time corrector}
 i,j,q:integer; {technical}

 s,w:array[1..10,0..20] of boolean; {main and extra field matrixes with extra line and column}
 sv:array[0..20] of integer; {sum of lines}
 fbox:array[1..4,1..4]of boolean; {figure matrix}

procedure pausepicture (a:longint);
begin
 if a>65500 
  then begin
   for i:=1 to (a div 65500) do 
    delay(65500);
   delay(a mod 65500);
  end
  else delay(a);
end;

procedure timing;
var 
 a:longint; {quantity of timer ticks in 5 secs of delay}
 b:longint; {quantity of delay in 5 secs of real time}
 stimer: longint absolute $0040:$006C;
begin
 writeln;
 writeln(' Correcting delay will take about 5 seconds, please wait.');
 a:=stimer;
 b:=0;
 while stimer<=(a+46) do 
 begin
  delay(1);
  inc(b); 
 end;
 a:=stimer;
 pausepicture(b);
 a:=stimer-a; 
 while (keypressed) do 
  readkey;
 writeln(' 1 sec of runtime = delay(',round(1000*b/(a*55))+1,')');
 writeln(' Press any key to continue.');
 time:=round(b/(55*a));
 if ((time mod 1)>4) or (time<1) 
  then inc(time);
 readkey;
 clrscr;
 while (keypressed) do 
  readkey;
end;{timing}

procedure eraser(px,py:integer);
begin
 setfillstyle(1,7);
 bar(px,py,px+7,py+7);
end;{eraser}

procedure savepixel;
begin
 setlinestyle(0,0,1);
 setcolor(0);
 moveto(1,1);
 linerel(0,7);
 linerel(7,0);
 linerel(0,-7);
 linerel(-7,0);

 setfillstyle(1,0);
 bar(3,3,6,6);

 spix:=imagesize(1,1,8,8);
 getmem(pix,spix);
 getimage(1,1,8,8,pix^);
 eraser(1,1);
end;{savepixel}

procedure pixel (px,py:integer);
begin
 putimage(px,py,pix^,0);
end;{pixel}

procedure playground;
begin
 setlinestyle(0,0,1);
 setcolor(0);

 moveto((getmaxx-94) div 2,70); {roof}
 linerel(94,0);

 moverel(0,3); {right}
 linerel(0,178);

 moverel(0,3); {floor}
 linerel(-94,0);

 moverel(0,-3); {left}
 linerel(0,-178);
end;{playground}

procedure menu;
begin
 settextstyle(0,0,3);
 outtextxy(leftx-25,topy-50,'Tetris');
 settextstyle(0,0,1);

 outtextxy(xm,topy+45,'Lines:');
 outtextxy(xm,topy+60,'Score:');
 outtextxy(xm,topy+157,'Level:');
 outtextxy(xm,topy+172,'Speed:');

 setcolor(8);
 outtextxy(leftx-200,topy+55,'Pause:');
 outtextxy(leftx-200,topy+75,'Exit:');
 outtextxy(leftx-200,topy+95,'Rotate:');
 outtextxy(leftx-200,topy+115,'Faster:');
 outtextxy(leftx-200,topy+135,'Left:');
 outtextxy(leftx-200,topy+155,'Right:');
 outtextxy(leftx-200,topy+175,'Fall:');

 outtextxy(leftx-130,topy+55,'Enter');
 outtextxy(leftx-130,topy+75,'Escape');
 outtextxy(leftx-130,topy+95,'num 8');
 outtextxy(leftx-130,topy+115,'num 5');
 outtextxy(leftx-130,topy+135,'num 4');
 outtextxy(leftx-130,topy+155,'num 6');
 outtextxy(leftx-130,topy+175,'num 0');

 outtextxy(leftx-70,topy+95,'W');
 outtextxy(leftx-70,topy+115,'S');
 outtextxy(leftx-70,topy+135,'A');
 outtextxy(leftx-70,topy+155,'D');
 outtextxy(leftx-70,topy+175,'Space');

 outtextxy(leftx-50,topy+95,chr(24));
 outtextxy(leftx-50,topy+115,chr(25));
 outtextxy(leftx-50,topy+135,chr(27));
 outtextxy(leftx-50,topy+155,chr(26));

 outtextxy(getmaxx-115,getmaxy-15,'Homeniuk Nina');
 setcolor(0);
end;{menu}

{====================================================}

procedure figure1;
begin
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[3,2]:=true;
 fbox[3,3]:=true;
end;{figure1}

procedure figure2;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[3,2]:=true;
 fbox[4,2]:=true;
end;{figure2}

procedure figure3;
begin
 fbox[2,1]:=true;
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
end;{figure3}

procedure figure4;
begin
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[3,3]:=true;
 fbox[3,4]:=true;
end;{figure4}

procedure figure5;
begin
 fbox[2,2]:=true;
 fbox[3,2]:=true;
 fbox[1,3]:=true;
 fbox[2,3]:=true;
end;{figure5}

procedure figure6;
begin
 fbox[3,2]:=true;
 fbox[3,3]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
end;{figure6}

procedure figure7;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[3,3]:=true;
end;{figure7}

procedure figure8;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,1]:=true;
 fbox[3,2]:=true;
end;{figure8}

procedure figure9;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,1]:=true;
 fbox[2,3]:=true;
end;{figure9}

procedure figure10;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[3,2]:=true;
end;{figure10}

procedure figure11;
begin
 fbox[2,1]:=true;
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[3,2]:=true;
end;{figure11}

procedure figure12;
begin
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
 fbox[3,2]:=true;
end;{figure12}

procedure figure13;
begin
 fbox[1,2]:=true;
 fbox[1,3]:=true;
 fbox[2,3]:=true;
 fbox[3,3]:=true;
end;{figure13}

procedure figure14;
begin
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
 fbox[1,4]:=true;
end;{figure14}

procedure figure15;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[3,2]:=true;
 fbox[3,3]:=true;
end;{figure15}

procedure figure16;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
end;{figure16}

procedure figure17;
begin
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[3,2]:=true;
 fbox[1,3]:=true;
end;{figure17}

procedure figure18;
begin
 fbox[2,2]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
 fbox[3,4]:=true;
end;{figure18}

procedure figure19;
begin
 fbox[3,2]:=true;
 fbox[1,3]:=true;
 fbox[2,3]:=true;
 fbox[3,3]:=true;
end;{figure19}

{====================================================}

procedure rotate2;
begin
 eraser(xnow,ynow+9);
 eraser(xnow+18,ynow+9);
 eraser(xnow+27,ynow+9);
 pixel(xnow+9,ynow);
 pixel(xnow+9,ynow+18);
 pixel(xnow+9,ynow+27);
 f:=3;
 fbox[1,2]:=false;
 fbox[3,2]:=false;
 fbox[4,2]:=false;
 fbox[2,1]:=true;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
end;{rotate2}

procedure rotate3;
begin
 eraser(xnow+9,ynow);
 eraser(xnow+9,ynow+18);
 eraser(xnow+9,ynow+27);
 pixel(xnow,ynow+9);
 pixel(xnow+18,ynow+9);
 pixel(xnow+27,ynow+9);
 f:=2;
 fbox[2,1]:=false;
 fbox[2,3]:=false;
 fbox[2,4]:=false;
 fbox[1,2]:=true;
 fbox[3,2]:=true;
 fbox[4,2]:=true;
end;{rotate3}

procedure rotate4;
begin
 eraser(xnow+18,ynow+18);
 eraser(xnow+18,ynow+27);
 pixel(xnow,ynow+18);
 pixel(xnow+18,ynow+9);
 f:=5;
 fbox[3,3]:=false;
 fbox[3,4]:=false;
 fbox[3,2]:=true;
 fbox[1,3]:=true;
end;{rotate4}

procedure rotate5;
begin
 eraser(xnow,ynow+18);
 eraser(xnow+18,ynow+9);
 pixel(xnow+18,ynow+27);
 pixel(xnow+18,ynow+18);
 f:=4;
 fbox[1,3]:=false;
 fbox[3,2]:=false;
 fbox[3,3]:=true;
 fbox[3,4]:=true;
end;{rotate5}

procedure rotate6;
begin
 eraser(xnow+18,ynow+9);
 eraser(xnow+9,ynow+27);
 pixel(xnow,ynow+9);
 pixel(xnow+9,ynow+9);
 f:=7;
 fbox[3,2]:=false;
 fbox[2,4]:=false;
 fbox[1,2]:=true;
 fbox[2,2]:=true;
end;{rotate6}

procedure rotate7;
begin
 eraser(xnow,ynow+9);
 eraser(xnow+9,ynow+9);
 pixel(xnow+18,ynow+9);
 pixel(xnow+9,ynow+27);
 f:=6;
 fbox[1,2]:=false;
 fbox[2,2]:=false;
 fbox[3,2]:=true;
 fbox[2,4]:=true;
end;{rotate7}

procedure rotate8;
begin
 eraser(xnow+18,ynow+9);
 pixel(xnow+9,ynow+18);
 f:=9;
 fbox[3,2]:=false;
 fbox[2,3]:=true;
end;{rotate8}

procedure rotate9;
begin
 eraser(xnow+9,ynow);
 pixel(xnow+18,ynow+9);
 f:=10;
 fbox[2,1]:=false;
 fbox[3,2]:=true;
end;{rotate9}

procedure rotate10;
begin
 eraser(xnow,ynow+9);
 pixel(xnow+9,ynow);
 f:=11;
 fbox[1,2]:=false;
 fbox[2,1]:=true;
end;{rotate10}

procedure rotate11;
begin
 eraser(xnow+9,ynow+18);
 pixel(xnow,ynow+9);
 f:=8;
 fbox[2,3]:=false;
 fbox[1,2]:=true;
end;{rotate11}

procedure rotate12;
begin
 eraser(xnow+9,ynow+9);
 eraser(xnow+18,ynow+9);
 eraser(xnow+9,ynow+27);
 pixel(xnow,ynow+9);
 pixel(xnow,ynow+18);
 pixel(xnow+18,ynow+18);
 f:=13;
 fbox[2,2]:=false;
 fbox[2,4]:=false;
 fbox[3,2]:=false;
 fbox[1,2]:=true;
 fbox[1,3]:=true;
 fbox[3,3]:=true;
end;{rotate12}

procedure rotate13;
begin
 eraser(xnow,ynow+9);
 eraser(xnow,ynow+18);
 eraser(xnow+18,ynow+18);
 pixel(xnow+9,ynow+9);
 pixel(xnow,ynow+27);
 pixel(xnow+9,ynow+27);
 f:=14;
 fbox[1,2]:=false;
 fbox[1,3]:=false;
 fbox[3,3]:=false;
 fbox[2,2]:=true;
 fbox[2,4]:=true;
 fbox[1,4]:=true;
end;{rotate13}

procedure rotate14;
begin
 eraser(xnow,ynow+27);
 eraser(xnow+9,ynow+27);
 eraser(xnow+9,ynow+18);
 pixel(xnow,ynow+9);
 pixel(xnow+18,ynow+18);
 pixel(xnow+18,ynow+9);
 f:=15;
 fbox[2,3]:=false;
 fbox[2,4]:=false;
 fbox[1,4]:=false;
 fbox[1,2]:=true;
 fbox[3,2]:=true;
 fbox[3,3]:=true;
end;{rotate14}

procedure rotate15;
begin
 eraser(xnow,ynow+9);
 eraser(xnow+18,ynow+18);
 pixel(xnow+9,ynow+27);
 pixel(xnow+9,ynow+18);
 f:=12;
 fbox[1,2]:=false;
 fbox[3,3]:=false;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
end;{rotate15}

procedure rotate16;
begin
 eraser(xnow+9,ynow+27);
 eraser(xnow+9,ynow+18);
 pixel(xnow+18,ynow+9);
 pixel(xnow,ynow+18);
 f:=17;
 fbox[2,3]:=false;
 fbox[2,4]:=false;
 fbox[3,2]:=true;
 fbox[1,3]:=true;
end;{rotate16}

procedure rotate17;
begin
 eraser(xnow,ynow+18);
 eraser(xnow,ynow+9);
 eraser(xnow+18,ynow+9);
 pixel(xnow+9,ynow+27);
 pixel(xnow+18,ynow+27);
 pixel(xnow+9,ynow+18);
 f:=18;
 fbox[3,2]:=false;
 fbox[1,3]:=false;
 fbox[1,2]:=false;
 fbox[2,3]:=true;
 fbox[2,4]:=true;
 fbox[3,4]:=true;
end;{rotate17}

procedure rotate18;
begin
 eraser(xnow+9,ynow+9);
 eraser(xnow+9,ynow+27);
 eraser(xnow+18,ynow+27);
 pixel(xnow,ynow+18);
 pixel(xnow+18,ynow+18);
 pixel(xnow+18,ynow+9);
 f:=19;
 fbox[2,2]:=false;
 fbox[2,4]:=false;
 fbox[3,4]:=false;
 fbox[3,2]:=true;
 fbox[1,3]:=true;
 fbox[3,3]:=true;
end;{rotate18}

procedure rotate19;
begin
 eraser(xnow,ynow+18);
 eraser(xnow+18,ynow+18);
 eraser(xnow+18,ynow+9);
 pixel(xnow,ynow+9);
 pixel(xnow+9,ynow+9);
 pixel(xnow+9,ynow+27);
 f:=16;
 fbox[3,2]:=false;
 fbox[1,3]:=false;
 fbox[3,3]:=false;
 fbox[1,2]:=true;
 fbox[2,2]:=true;
 fbox[2,4]:=true;
end;{rotate19}

{====================================================}

procedure newfigure(f0:integer;x0,y0:integer);
begin
 for i:=1 to 4 do
  for j:=1 to 4 do
   fbox[i,j]:=false;

 case f0 of
  1:figure1;
  2:figure2;
  3:figure3;
  4:figure4;
  5:figure5;
  6:figure6;
  7:figure7;
  8:figure8;
  9:figure9;
  10:figure10;
  11:figure11;
  12:figure12;
  13:figure13;
  14:figure14;
  15:figure15;
  16:figure16;
  17:figure17;
  18:figure18;
  19:figure19;
 end;

 for i:=0 to 3 do
  for j:=0 to 3 do 
   if (fbox[i+1,j+1]=true)
    then pixel(x0+i*9,y0+j*9);
end;{newfigure}

procedure delfigure;
begin
 for i:=0 to 3 do
  for j:=0 to 3 do 
   if (fbox[i+1,j+1]=true)
    then eraser(xnow+i*9,ynow+j*9);
end;{delfigure}

procedure fullrow(y0:integer);
begin
 for i:=0 to 9 do
  pixel(leftx+i*9,y0);
end;{fullrow}

procedure delrow(y0:integer);
begin
 for i:=0 to 9 do
  eraser(leftx+i*9,y0);
end;{delrow}

procedure drawlevel;
var u,v,x:integer;
begin
 for j:=0 to (21-level) do
  for i:=1 to 10 do 
  begin
   s[i,j]:=false;
   sv[j]:=0;
  end;

 if (level>1) 
  then
   for j:=(22-level) to 20 do
    for i:=1 to 10 do 
    begin
     x:=random(2);
     if x=0 
      then s[i,j]:=false
      else s[i,j]:=true;
     if (s[i,j]=true) 
      then begin
       sv[j]:=sv[j]+1;
       u:=leftx+(i-1)*9;
       v:=topy+(j-1)*9;
       pixel(u,v);
      end;
    end;
end;{drawlevel}

procedure clearnext;
var 
 u,v:integer;
begin
 u:=xm;
 v:=topy;
 for i:=0 to 3 do
  for j:=0 to 3 do
   eraser(i*9+u,j*9+v);
end;{clearnext}

function checkfall: boolean;
var
 fboxv:array[1..4]of integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for i:=1 to 4 do 
 begin
  fboxv[i]:=0;
  u:=(xnow-leftx) div 9+i;
  for j:=1 to 4 do
   if (fbox[i,j]=true) 
    then fboxv[i]:=j;
  if (fboxv[i]<>0) 
   then begin
    v:=(ynow-topy) div 9+fboxv[i]+1;
    bv:=bv and (s[u,v]=false) and (v<21);
   end;
 end;
 checkfall:=bv;
end;{checkfall}

function checkleft: boolean;
var
 fboxv:array[1..4]of integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for j:=1 to 4 do 
 begin
  fboxv[j]:=0;
  v:=(ynow-topy) div 9+j;
  for i:=4 downto 1 do
   if (fbox[i,j]=true) 
    then fboxv[j]:=i;
   if (fboxv[j]<>0) 
    then begin
     u:=(xnow-leftx) div 9+fboxv[j]-1;
     bv:=bv and (s[u,v]=false) and (u>0);
    end;
 end;
 checkleft:=bv;
end;{checkleft}

function checkright: boolean;
var
 fboxv:array[1..4]of integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for j:=1 to 4 do 
 begin
  fboxv[j]:=0;
  v:=(ynow-topy) div 9+j;
  for i:=1 to 4 do
   if (fbox[i,j]=true) 
    then fboxv[j]:=i;
  if (fboxv[j]<>0) 
   then begin
    u:=(xnow-leftx) div 9+fboxv[j]+1;
    bv:=bv and (s[u,v]=false) and (u<11);
   end;
 end;
 checkright:=bv;
end;{checkright}

procedure moveright;
begin
 if checkright 
  then begin
   delfigure;
   xnow:=xnow+9;
   newfigure(f,xnow,ynow);
  end;
end; {moveright}

procedure moveleft;
begin
 if checkleft 
  then begin
   delfigure;
   xnow:=xnow-9;
   newfigure(f,xnow,ynow);
  end;
end;{moveleft}

procedure movedown;
begin
 if checkfall 
  then begin
   delfigure;
   ynow:=ynow+9;
   newfigure(f,xnow,ynow);
  end;
end;{movedown}

procedure checkrot(a,b:integer);
var 
 u,v:integer;
begin
 u:=(xnow-leftx) div 9+a;
 v:=(ynow-topy) div 9+b;
 case u of
  0:begin
   moveright;
   u:=(xnow-leftx) div 9+a;
  end;
  11:begin
   moveleft;
   if f=3 
    then moveleft;
   u:=(xnow-leftx) div 9+a;
  end;
 end;
 if (v=0) 
  then begin
   movedown;
   v:=(ynow-topy) div 9+b;
  end;
 
 rot:=rot and (s[u,v]=false) 
  and (u>0) and (u<11) and (v<21) and (v>0);
end;{checkrot}

function checkrotate: boolean;
begin
 rot:=true;
 case f of 
  2:begin
   checkrot(2,1);
   checkrot(2,3);
   checkrot(2,4);
  end;
  3:begin
   checkrot(1,2);
   checkrot(3,2);
   checkrot(4,2);
  end;
  4:begin
   checkrot(1,3);
   checkrot(3,2);
  end;
  5:begin
   checkrot(3,3);
   checkrot(3,4);
  end;
  6:begin
   checkrot(1,2);
   checkrot(2,2);
  end;
  7:begin
   checkrot(2,4);
   checkrot(3,2);
  end;
  8:checkrot(2,3);
  9:checkrot(3,2);
  10:checkrot(2,1);
  11:checkrot(1,2);
  12:begin
   checkrot(1,2);
   checkrot(1,3);
   checkrot(3,3);
  end;
  13:begin
   checkrot(2,2);
   checkrot(1,4);
   checkrot(2,4);
  end;
  14:begin
   checkrot(1,2);
   checkrot(3,2);
   checkrot(3,3);
  end;
  15:begin
   checkrot(2,4);
   checkrot(2,3);
  end;
  16:begin
   checkrot(1,3);
   checkrot(3,2);
  end;
  17:begin
   checkrot(2,4);
   checkrot(2,3);
   checkrot(3,4);
  end;
  18:begin
   checkrot(1,3);
   checkrot(3,2);
   checkrot(3,3);
  end;
  19:begin
   checkrot(1,2);
   checkrot(2,2);
   checkrot(2,4);
  end
  else rot:=false;
 end;
 
 checkrotate:=rot;
end;{checkrotate}

procedure rotate;
begin
 if checkrotate 
  then
   case f of
    2:rotate2;
    3:rotate3;
    4:rotate4;
    5:rotate5;
    6:rotate6;
    7:rotate7;
    8:rotate8;
    9:rotate9;
    10:rotate10;
    11:rotate11;
    12:rotate12;
    13:rotate13;
    14:rotate14;
    15:rotate15;
    16:rotate16;
    17:rotate17;
    18:rotate18;
    19:rotate19;
   end;
end;{rotate}

procedure crash;
begin
 delfigure;
 while checkfall do
  ynow:=ynow+9;
 newfigure(f,xnow,ynow);
end;{crash}

procedure pause;
begin
 setcolor(8);
 settextstyle(0,0,2);
 outtextxy(xm,topy+80,'Pause');
 settextstyle(0,0,1);
 setfillstyle(1,8);
 pieslice(xm+30,topy+120,180,360,20);
 bar(xm+10,topy+115,xm+50,topy+120);
 bar(xm+5,topy+140,xm+55,topy+144);
 setlinestyle(0,0,3);
 circle(xm+54,topy+125,7);
 setlinestyle(0,0,1);
 setfillstyle(1,7);
 setcolor(0);

 for i:=2 to 4 do begin
  putpixel(xm+i*10,topy+110,0);
  putpixel(xm+i*10,topy+109,0);
  putpixel(xm+i*10,topy+108,0);
  putpixel(xm+1+i*10,topy+107,0);
  putpixel(xm+2+i*10,topy+106,0);
  putpixel(xm+2+i*10,topy+105,0);
  putpixel(xm+2+i*10,topy+104,0);
  putpixel(xm+1+i*10,topy+103,0);
  putpixel(xm+i*10,topy+102,0);
  putpixel(xm+i*10,topy+101,0);
 end;
end;{pause}

procedure fall;
var 
 n:real;
 down,lm:boolean;
begin
 down:=true;
 while down do
 begin
  if not checkfall 
   then down:=false;
  n:=0;
  repeat
   delay(time);
   n:=n+1;
   if keypressed 
    then case readkey of
      #27: begin
       finish:=true; 
       exit;
      end;
      #13: begin
       pause;
       if readkey=#27 
        then begin
         finish:=true; 
         exit;
        end
        else begin 
         setfillstyle(1,7);
         bar(xm-3,topy+70,xm+100,topy+155); 
        end;
      end;
      #32,#48: begin
       crash;
       exit;
      end;
      #56,#87,#119,#150,#230: begin
       rotate;
       down:=true;
      end;
      #54,#68,#100,#130,#162: begin
       moveright;
       down:=true;
      end;
      #52,#65,#97,#148,#228: begin
       moveleft;
       down:=true;
      end;
      #53,#83,#115,#155,#235:
       n:=630-480*(speed-1) div (maxspeed-1);
      #0: case readkey of
        #72: begin
         rotate;
         down:=true;
        end;
        #77: begin
         moveright;
         down:=true;
        end;
        #75:begin
         moveleft;
         down:=true;
        end;
        #80: 
         n:=630-480*(speed-1) div (maxspeed-1);
      end;
    end;
  until n>(625-480*(speed-1) div (maxspeed-1));
  movedown;
 end;{while}
end;{fall}

procedure addfigure;
var 
 u,v:integer;
begin
 p:=1;
 v:=1;
 for i:=1 to 4 do 
 begin
  for j:=1 to 4 do
   if (fbox[i,j]=true) 
    then begin
     u:=(xnow-leftx) div 9+i;
     v:=(ynow-topy) div 9+j;
     s[u,v]:=true;
     sv[v]:=sv[v]+1;
    end;
  if (v>p) 
   then p:=v;
 end;
end;{addfigure}

procedure delete;
var 
 z,h,t,u,v:integer;
 k:array[1..4] of integer; {full rows to be deleted}
begin
 for j:=1 to 4 do
  k[j]:=0;
 j:=0;
 q:=p; {lowest added square}

 {remember indexes of full rows in array K}
 repeat
  if (sv[q]=10) 
   then begin
    inc(j);
    k[j]:=q; 
   end;
  dec(q);
 until (sv[q]=0); {q - first non zero line, go bottom up}

 if (j>0) 
  then begin {there are full rows}

   {increment points and lines}
   setfillstyle(1,7);
   settextstyle(0,0,1);

   lines:=lines+j;
   alines:=alines+j;
   bar(xm+49,topy+44,xm+100,topy+54);
   str(alines,a);
   outtextxy(xm+50,topy+45,a);{lines}

   score:=score+50+50*j; 
   bar(xm+49,topy+59,xm+100,topy+69);
   str(score,a);
   outtextxy(xm+50,topy+60,a);{scores}

   {blink with full rows}
   delay(250*time);
   for z:=1 to j do 
   begin
    t:=(k[z]-1)*9+topy;
    delrow(t);
   end;
   delay(250*time);
   for z:=1 to j do 
   begin
    t:=(k[z]-1)*9+topy;
    fullrow(t);
   end;
   delay(250*time);
   for z:=1 to j do 
   begin
    t:=(k[z]-1)*9+topy;
    delrow(t);
    sv[k[z]]:=0;
   end;
   delay(250*time);

   {_move down what's left_}
   {save all visible to matrix W and arase}
   h:=0; {number of remaining lines}
   for z:=(q+1) to (k[1]) do  {top to bottom}
   begin
    if (sv[z]=0) 
     then begin
      for j:=1 to 10 do
       s[j,z]:=false;
      continue;
     end
     else begin
      inc(h);
      for j:=1 to 10 do 
      begin
       w[j,h]:=s[j,z];
       s[j,z]:=false;
      end;
      sv[z]:=0;
      t:=(z-1)*9+topy;
      delrow(t);
     end;
   end;

   {draw lowered lines}
   for i:=0 to (h-1) do 
   begin
    z:=k[1]-h+i+1;
    for j:=1 to 10 do 
    begin
     s[j,z]:=w[j,i+1];
     if (s[j,z]=true) 
      then begin
       u:=leftx+(j-1)*9;
       v:=topy+(z-1)*9;
       pixel(u,v);
       sv[z]:=sv[z]+1;
      end;
    end;
   end;

 end;{there are full rows}
end;{delete}

{====================================================}

procedure hello;
 begin
 settextstyle(0,0,2);
 outtextxy(leftx,topy+70,'Ready?');
 outtextxy(leftx+25,topy+105,'Go!');
 readkey;
 setfillstyle(1,7);
 bar(leftx,topy+49,leftx+90,topy+130);
end;{hello}

procedure finishspeed;
var 
 u,v:integer;
begin
 for j:=q-1 to 20 do 
 begin
  v:=topy+(j-1)*9;
  delrow(v);
  sv[j]:=0;
 end;
 inc(speed);
 setfillstyle(1,7);
 settextstyle(0,0,1);
 str(speed,a);
 if speed<=maxspeed 
  then begin
   bar(xm+49,topy+171,xm+100,topy+181);
   outtextxy(xm+50,topy+172,a);{speed}
  end;
end;{finishspeed}

procedure win;
begin
 settextstyle(0,0,2);
 outtextxy(leftx+18,topy+50,'Win!');
 outtextxy(leftx,topy+80,'Speed+');
 outtextxy(leftx+23,topy+110,':-)');
 pausepicture(time*1500);
 setfillstyle(1,7);
 bar(leftx,topy+49,leftx+90,topy+130);
end;{win}

procedure winlevel;
begin
 settextstyle(0,0,2);
 outtextxy(leftx+18,topy+50,'Win!');
 outtextxy(leftx+6,topy+80,'Level');
 outtextxy(leftx,topy+110,'up :-)');
 pausepicture(time*1500);
 setfillstyle(1,7);
 bar(leftx,topy+49,leftx+90,topy+130);
end;{winlevel}

procedure again;
begin
 settextstyle(0,0,2);
 outtextxy(leftx+20,topy+50,'Try');
 outtextxy(leftx+5,topy+80,'again');
 outtextxy(leftx+23,topy+110,':-)');
 readkey;
 setfillstyle(1,7);
 bar(leftx+4,topy+49,leftx+82,topy+130);
 settextstyle(0,0,1);
 bar(xm+49,topy+171,xm+100,topy+181);
 bar(xm+49,topy+156,xm+100,topy+166);
end;{again}

procedure looser;
var 
 u,v:integer;
begin
 for j:=20 downto 1 do 
 begin 
  v:=topy+(j-1)*9;
  if (j mod 2=0) 
   then 
    for i:=9 downto 0 do 
    begin
     u:=leftx+i*9;
     pixel(u,v);
     delay(20*time);
    end
   else
    for i:=0 to 9 do 
    begin 
     u:=leftx+i*9;
     pixel(u,v);
     delay(20*time);
    end;
 end;
 for j:=1 to 20 do 
 begin 
  v:=topy+(j-1)*9;
  delrow(v);
 end;
end;{looser}

procedure goodbye;
var 
 v:integer;
begin
 for j:=1 to 20 do 
 begin
  v:=topy+(j-1)*9;
  delrow(v);
 end;
 settextstyle(0,0,2);
 outtextxy(leftx+13,topy+50,'Come');
 outtextxy(leftx+15,topy+80,'back');
 outtextxy(leftx+1,topy+110,'soon:)');
 pausepicture(time*1500);
 halt;
end;{goodbye}

procedure epicwin;
begin
 clearnext;
 settextstyle(0,0,2);
 outtextxy(leftx+20,topy+50,'You');
 outtextxy(leftx+20,topy+80,'did');
 outtextxy(leftx+21,topy+110,'it!');
 settextstyle(0,0,1);
 bar(xm+49,topy+171,xm+100,topy+181);
 bar(xm+49,topy+156,xm+100,topy+166); 
 pausepicture(time*1500);
 bar(leftx,topy+49,leftx+90,topy+130);
 readkey;
end;{epicwin}

{====================================================}

procedure closegame;
begin
 goodbye;
 freemem(pix,spix);
 closegraph;
 halt;
end; {closegame}

procedure setupgraph;
begin
 DetectGraph(d,m);
 InitGraph(d,m,'');
 if GraphResult <> grOk 
  then begin
   clrscr;
   writeln(GraphErrorMsg(er));
   writeln('Press any key to exit.');
   readkey
  end;
end;{setupgraph}

procedure setupplayground;
begin
 {background color: light-gray}
 cleardevice;
 setfillstyle(1,7);
 bar(0,0,getmaxx,getmaxy);

 {draw game field}
 playground; 
 {top left point of the field}
 leftx:=getx+3;
 topy:=gety;
 {top left point of right menu}
 xm:=leftx+95;
 {draw side menu}
 menu; 
end;{setupplayground}

procedure startgame;
begin
 alines:=0;
 score:=0;
 level:=1;
 
 {ready? go!}
 hello;
end;{startgame}

procedure writelevel;
begin
 setfillstyle(1,7);
 settextstyle(0,0,1);
 str(level,a);
 bar(xm+49,topy+156,xm+100,topy+166);
 if (level<=maxlevel) {level}
  then outtextxy(xm+50,topy+157,a);
end;{writelevel}

procedure startlevel;
begin
 settextstyle(0,0,1);
 speed:=1;
 bar(xm+49,topy+171,xm+100,topy+181);
 outtextxy(xm+50,topy+172,'1');{speed}
end;{startlevel}

procedure drawfigures;
begin
 {draw next figure}
 fnext:=1+random(19);
 clearnext;
 newfigure(fnext,xm,topy);

 {top left point of figure}
 xnow:=leftx+27; 
 ynow:=topy-9;
 case f of
  3,8,9,11:
   ynow:=ynow+9; 
 end;
 
 {draw current figure}
 newfigure(f,xnow,ynow); 
end;{drawfigures}

procedure nextspeed;
begin
 {clear screen and go to next speed}
 finishspeed; 
 if speed<=maxspeed 
  then win
  else 
   if level<maxlevel 
    then winlevel;
end;{nextspeed}

{====================================================}

begin
 randomize;
 clrscr;
 timing;
 setupgraph;
 setupplayground;
 savepixel;
 finish:=false;
 while not finish do {game session}
 begin
  startgame;
  f:=1+random(19);
  888:
  repeat {one level}
   startlevel;
   writelevel;
   while (speed<=maxspeed) do {one speed}
   begin
    lines:=0;
    {initial filling of field matrix with zeros + level}
    drawlevel; 
    repeat{one figure fall}
     if keypressed 
      then readkey;
     
     {draw current and next figures} 
     drawfigures;
     
     {main fall and control}
     fall; 
     if finish 
      then closegame;
     
     {add freshly fallen figure to the field matrix}
     addfigure; 

     {delete full rows if there are any}
     delete; 

     {check if level is lost and goto start if yes}
     if (sv[1]>0) 
      then begin 
       looser; 
       again;
       goto 888;
      end;

     f:=fnext;
    until (lines>=maxlines); {one figure fall}
    nextspeed;
   end; {one speed}
   inc(level);
   writelevel;
  until (level>maxlevel); {one level}
  epicwin;
 end; {game session}
end.
