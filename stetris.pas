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
 box:array[1..19,1..4,1..2]of integer; {pixels coordinates of all figures}
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
 writeln(' 1 sec of runtime = delay(',round(b*1000/(a*55))+1,')');
 writeln(' Press any key to continue.');
 time:=round(b/(a*55));
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

 outtextxy(leftx-50,topy+95,chr(24)); {arrow up}
 outtextxy(leftx-50,topy+115,chr(25)); {arrow down}
 outtextxy(leftx-50,topy+135,chr(27)); {arrow left}
 outtextxy(leftx-50,topy+155,chr(26)); {arrow right}

 outtextxy(getmaxx-115,getmaxy-15,'Homeniuk Nina');
 setcolor(0);
end;{menu}

{====================================================}

procedure savefigures;
begin
 box[1,1,1]:=2; {....}
 box[1,1,2]:=2; {.xx.}
 box[1,2,1]:=2; {.xx.}
 box[1,2,2]:=3; {....}
 box[1,3,1]:=3;
 box[1,3,2]:=2;
 box[1,4,1]:=3;
 box[1,4,2]:=3;
 
 box[2,1,1]:=1; {....} 
 box[2,1,2]:=2; {xxxx}
 box[2,2,1]:=2; {....}
 box[2,2,2]:=2; {....}
 box[2,3,1]:=3;
 box[2,3,2]:=2;
 box[2,4,1]:=4;
 box[2,4,2]:=2;
 
 box[3,1,1]:=2; {.x..}
 box[3,1,2]:=1; {.x..}
 box[3,2,1]:=2; {.x..}
 box[3,2,2]:=2; {.x..}
 box[3,3,1]:=2;
 box[3,3,2]:=3;
 box[3,4,1]:=2;
 box[3,4,2]:=4;
 
 box[4,1,1]:=2; {....}
 box[4,1,2]:=2; {.x..}
 box[4,2,1]:=2; {.xx.}
 box[4,2,2]:=3; {..x.}
 box[4,3,1]:=3;
 box[4,3,2]:=3;
 box[4,4,1]:=3;
 box[4,4,2]:=4;
 
 box[5,1,1]:=2; {....}
 box[5,1,2]:=2; {.xx.}
 box[5,2,1]:=3; {xx..}
 box[5,2,2]:=2; {....}
 box[5,3,1]:=1;
 box[5,3,2]:=3;
 box[5,4,1]:=2;
 box[5,4,2]:=3;
 
 box[6,1,1]:=3; {....}
 box[6,1,2]:=2; {..x.}
 box[6,2,1]:=3; {.xx.}
 box[6,2,2]:=3; {.x..}
 box[6,3,1]:=2;
 box[6,3,2]:=3;
 box[6,4,1]:=2;
 box[6,4,2]:=4;
 
 box[7,1,1]:=1; {....}
 box[7,1,2]:=2; {xx..}
 box[7,2,1]:=2; {.xx.}
 box[7,2,2]:=2; {....}
 box[7,3,1]:=2;
 box[7,3,2]:=3;
 box[7,4,1]:=3;
 box[7,4,2]:=3;
 
 box[8,1,1]:=1; {.x..}
 box[8,1,2]:=2; {xxx.}
 box[8,2,1]:=2; {....}
 box[8,2,2]:=2; {....}
 box[8,3,1]:=2;
 box[8,3,2]:=1;
 box[8,4,1]:=3;
 box[8,4,2]:=2;
 
 box[9,1,1]:=1; {.x..}
 box[9,1,2]:=2; {xx..}
 box[9,2,1]:=2; {.x..}
 box[9,2,2]:=2; {....}
 box[9,3,1]:=2;
 box[9,3,2]:=1;
 box[9,4,1]:=2;
 box[9,4,2]:=3;
 
 box[10,1,1]:=1; {....}
 box[10,1,2]:=2; {xxx.}
 box[10,2,1]:=2; {.x..}
 box[10,2,2]:=2; {....}
 box[10,3,1]:=2;
 box[10,3,2]:=3;
 box[10,4,1]:=3;
 box[10,4,2]:=2;
 
 box[11,1,1]:=2; {.x..}
 box[11,1,2]:=1; {.xx.}
 box[11,2,1]:=2; {.x..}
 box[11,2,2]:=2; {....}
 box[11,3,1]:=2;
 box[11,3,2]:=3;
 box[11,4,1]:=3;
 box[11,4,2]:=2;
 
 box[12,1,1]:=2; {....}
 box[12,1,2]:=4; {.xx.}
 box[12,2,1]:=2; {.x..}
 box[12,2,2]:=2; {.x..}
 box[12,3,1]:=2;
 box[12,3,2]:=3;
 box[12,4,1]:=3;
 box[12,4,2]:=2;
 
 box[13,1,1]:=1; {....}
 box[13,1,2]:=3; {x...}
 box[13,2,1]:=3; {xxx.}
 box[13,2,2]:=3; {....}
 box[13,3,1]:=2;
 box[13,3,2]:=3;
 box[13,4,1]:=1;
 box[13,4,2]:=2;
 
 box[14,1,1]:=2; {....}
 box[14,1,2]:=2; {.x..}
 box[14,2,1]:=2; {.x..}
 box[14,2,2]:=3; {xx..}
 box[14,3,1]:=2;
 box[14,3,2]:=4;
 box[14,4,1]:=1;
 box[14,4,2]:=4;
 
 box[15,1,1]:=2; {....}
 box[15,1,2]:=2; {xxx.}
 box[15,2,1]:=3; {..x.}
 box[15,2,2]:=2; {....}
 box[15,3,1]:=3;
 box[15,3,2]:=3;
 box[15,4,1]:=1;
 box[15,4,2]:=2;
 
 box[16,1,1]:=1; {....}
 box[16,1,2]:=2; {xx..}
 box[16,2,1]:=2; {.x..}
 box[16,2,2]:=2; {.x..}
 box[16,3,1]:=2;
 box[16,3,2]:=3;
 box[16,4,1]:=2;
 box[16,4,2]:=4;
 
 box[17,1,1]:=1; {....}
 box[17,1,2]:=2; {xxx.}
 box[17,2,1]:=2; {x...}
 box[17,2,2]:=2; {....}
 box[17,3,1]:=3;
 box[17,3,2]:=2;
 box[17,4,1]:=1;
 box[17,4,2]:=3;
 
 box[18,1,1]:=2; {....}
 box[18,1,2]:=3; {.x..}
 box[18,2,1]:=2; {.x..}
 box[18,2,2]:=2; {.xx.}
 box[18,3,1]:=2;
 box[18,3,2]:=4;
 box[18,4,1]:=3;
 box[18,4,2]:=4;
 
 box[19,1,1]:=2; {....}
 box[19,1,2]:=3; {..x.}
 box[19,2,1]:=1; {xxx.}
 box[19,2,2]:=3; {....}
 box[19,3,1]:=3;
 box[19,3,2]:=3;
 box[19,4,1]:=3;
 box[19,4,2]:=2;
end;{savefigures}

{====================================================}

procedure newfigure(f0,x0,y0:integer);
var 
 x,y:integer;
begin
 for i:=1 to 4 do
  for j:=1 to 4 do
   fbox[i,j]:=false;

 for i:=1 to 4 do 
 begin
  x:=box[f0,i,1];
  y:=box[f0,i,2];
  fbox[x,y]:=true;
  pixel((x-1)*9+x0,(y-1)*9+y0);
 end;
end;{newfigure}

procedure delfigure(f0,x0,y0:integer);
var 
 x,y:integer;
begin
 for i:=1 to 4 do
 begin
  x:=box[f0,i,1]-1;
  y:=box[f0,i,2]-1;
  eraser(x*9+x0,y*9+y0);
 end;
end;{delfigure}

procedure fullrow(y0:integer);
begin
 for i:=0 to 9 do
  pixel(i*9+leftx,y0);
end;{fullrow}

procedure delrow(y0:integer);
begin
 for i:=0 to 9 do
  eraser(i*9+leftx,y0);
end;{delrow}

procedure drawlevel;
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
     if random(2)=0 
      then s[i,j]:=false
      else s[i,j]:=true;
     if s[i,j]
      then begin
       sv[j]:=sv[j]+1;
       pixel(leftx+(i-1)*9,topy+(j-1)*9);
      end;
    end;
end;{drawlevel}

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
  u:=(xnow-leftx) div 9 + i;
  for j:=1 to 4 do
   if fbox[i,j]
    then fboxv[i]:=j;
  if (fboxv[i]<>0) 
   then begin
    v:=(ynow-topy) div 9 + fboxv[i]+1;
    bv:=bv and not s[u,v] and (v<21);
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
  v:=(ynow-topy) div 9 + j;
  for i:=4 downto 1 do
   if fbox[i,j]
    then fboxv[j]:=i;
   if (fboxv[j]<>0) 
    then begin
     u:=(xnow-leftx) div 9 + fboxv[j]-1;
     bv:=bv and not s[u,v] and (u>0);
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
  v:=(ynow-topy) div 9 + j;
  for i:=1 to 4 do
   if fbox[i,j]
    then fboxv[j]:=i;
  if (fboxv[j]<>0) 
   then begin
    u:=(xnow-leftx) div 9 + fboxv[j]+1;
    bv:=bv and not s[u,v] and (u<11);
   end;
 end;
 checkright:=bv;
end;{checkright}

procedure moveright;
begin
 if checkright 
  then begin
   delfigure(f,xnow,ynow);
   xnow:=xnow+9;
   newfigure(f,xnow,ynow);
  end;
end; {moveright}

procedure moveleft;
begin
 if checkleft 
  then begin
   delfigure(f,xnow,ynow);
   xnow:=xnow-9;
   newfigure(f,xnow,ynow);
  end;
end;{moveleft}

procedure movedown;
begin
 if checkfall 
  then begin
   delfigure(f,xnow,ynow);
   ynow:=ynow+9;
   newfigure(f,xnow,ynow);
  end;
end;{movedown}

procedure checkrot(a,b:integer);
var 
 u,v:integer;
begin
 u:=(xnow-leftx) div 9 + a;
 v:=(ynow-topy) div 9 + b;
 case u of
  0:begin
   moveright;
   u:=(xnow-leftx) div 9 + a;
  end;
  11:begin
   moveleft;
   if f=3 
    then moveleft;
   u:=(xnow-leftx) div 9 + a;
  end;
 end;
 if (v=0) 
  then begin
   movedown;
   v:=(ynow-topy) div 9 + b;
  end;
 
 rot:=rot and not s[u,v] 
  and (u>0) and (u<11) and (v>0) and (v<21);
end;{checkrot}

function checkrotate(newf:integer): boolean;
var
 newbox:array[1..4,1..4]of boolean;
begin
 if(newf=f)
  then rot:=false
  else begin
   rot:=true;
   for i:=1 to 4 do 
    newbox[box[newf,i,1],box[newf,i,2]]:=true;
   for i:=1 to 4 do
    for j:=1 to 4 do
     if not fbox[i,j] and newbox[i,j]
      then checkrot(i,j);
  end;
 checkrotate:=rot;
end;{checkrotate}

procedure rotate;
var 
 newf:integer;
begin
 case f of
  1: newf:=f;
  3,5,7: newf:=f-1;
  11: newf:=8;
  15: newf:=12;
  19: newf:=16;
  else newf:=f+1;
 end;
 if checkrotate(newf)
  then begin
   delfigure(f,xnow,ynow);
   f:=newf;
   newfigure(f,xnow,ynow);
  end;
end;{rotate}

procedure crash;
begin
 delfigure(f,xnow,ynow);
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
 down:boolean;
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
       n:=630-(speed-1)*480 div (maxspeed-1);
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
         n:=630-(speed-1)*480 div (maxspeed-1);
      end;
    end;
  until n>(625-(speed-1)*480 div (maxspeed-1));
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
   if fbox[i,j]
    then begin
     u:=(xnow-leftx) div 9 + i;
     v:=(ynow-topy) div 9 + j;
     s[u,v]:=true;
     sv[v]:=sv[v]+1;
    end;
  if (v>p) 
   then p:=v;
 end;
end;{addfigure}

procedure delete;
var 
 z,h:integer;
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
   outtextxy(xm+50,topy+45,a);{rows}

   score:=score+50+j*50; 
   bar(xm+49,topy+59,xm+100,topy+69);
   str(score,a);
   outtextxy(xm+50,topy+60,a);{scores}

   {blink with full rows}
   delay(time*250);
   for z:=1 to j do 
    delrow((k[z]-1)*9+topy);
   delay(time*250);
   for z:=1 to j do 
    fullrow((k[z]-1)*9+topy);
   delay(time*250);
   for z:=1 to j do 
   begin
    delrow((k[z]-1)*9+topy);
    sv[k[z]]:=0;
   end;
   delay(time*250);
   
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
      delrow((z-1)*9+topy);
     end;
   end;

   {draw lowered lines}
   for i:=0 to (h-1) do 
   begin
    z:=k[1]-h+i+1;
    for j:=1 to 10 do 
    begin
     s[j,z]:=w[j,i+1];
     if s[j,z] 
      then begin
       pixel(leftx+(j-1)*9,topy+(z-1)*9);
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
begin
 for j:=q-1 to 20 do 
 begin
  delrow(topy+(j-1)*9);
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
begin
 for j:=20 downto 1 do 
 begin 
  if (j mod 2 = 0) 
   then 
    for i:=9 downto 0 do 
    begin
     pixel(leftx+i*9,topy+(j-1)*9);
     delay(time*20);
    end
   else
    for i:=0 to 9 do 
    begin 
     pixel(leftx+i*9,topy+(j-1)*9);
     delay(time*20);
    end;
 end;
 for j:=1 to 20 do 
  delrow(topy+(j-1)*9);
end;{looser}

procedure goodbye;
begin
 for j:=1 to 20 do 
  delrow(topy+(j-1)*9);
 settextstyle(0,0,2);
 outtextxy(leftx+13,topy+50,'Come');
 outtextxy(leftx+15,topy+80,'back');
 outtextxy(leftx+1,topy+110,'soon:)');
 pausepicture(time*1500);
 halt;
end;{goodbye}

procedure epicwin;
begin
 delfigure(fnext,xm,topy);
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
 delfigure(fnext,xm,topy);
 fnext:=1+random(19);
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
 savefigures;
 finish:=false;
 while not finish do {game session}
 begin
  startgame;
  f:=1+random(19);
  fnext:=1+random(19);
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
