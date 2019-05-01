program tetris;
{$R-}
uses Graph, crt;

label 888; {again}

const
 MAXLEVEL=16;{>=1}
 MAXLINES=15;{>=1}
 MAXSPEED=5; {>1}
 PIXELSIZE=9;
 FIELDWIDTH=10;
 FIELDHEIGHT=20;
 FIGSIZE=4;
 FIGURECOUNT=19;
 TOPY=73;   {top left point of the field}
 LEFTX=275;
 XM=370; {left coordinate of the next figure in menu}
 
var 
 speed,lines,alines,score:word;
 finish,rot:boolean;
 a:string;
 
 level:integer;{level number}
 f,fnext:integer; {number of current and next figures}
 p:integer; {bottom left point of fallen figure}
 d,m,er:integer;{for graphics setup}
 xnow,ynow:integer; {current coords of the figure}
 pix:pointer;{one square}
 spix:longint; {size of the square}
 time:longint;{number of ticks in 1 milisecond}
 i,j,q:integer; {technical}

 s,w:array[1..FIELDWIDTH,0..FIELDHEIGHT] of boolean; {main and extra field matrixes with extra line and column}
 sv:array[0..FIELDHEIGHT] of integer; {sum of lines}
 fbox:array[1..FIGSIZE,1..FIGSIZE]of boolean; {figure matrix}
 box:array[1..FIGURECOUNT,1..FIGSIZE,1..2]of integer; {pixels coordinates of all figures}
 
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

procedure pausepicture (ticks:longint);
begin
 if ticks>65500 
  then begin
   for i:=1 to (ticks div 65500) do 
    delay(65500);
   delay(ticks mod 65500);
  end
  else delay(ticks);
end;

procedure timing;
var 
 ticks:longint; {quantity of timer ticks in 5 secs of delay}
 delays:longint; {quantity of delay in 5 secs of real time}
 stimer:longint absolute $0040:$006C;
begin
 writeln;
 writeln(' Correcting delay will take about 5 seconds, please wait.');
 ticks:=stimer;
 delays:=0;
 while stimer<=(ticks+46) do 
 begin
  delay(1);
  inc(delays); 
 end;
 ticks:=stimer;
 pausepicture(delays);
 ticks:=stimer-ticks; 
 while (keypressed) do 
  readkey;
 writeln(' 1 sec of runtime = delay(',round(delays/(ticks*55)*1000)+1,')');
 writeln(' Press any key to continue.');
 time:=round(delays/(ticks*55));
 if ((time mod 1)>4) or (time<1) 
  then inc(time);
 readkey;
 clrscr;
 while (keypressed) do 
  readkey;
end;{timing}

procedure fieldbar(x1,y1,x2,y2:integer);
begin
 bar(LEFTX+x1,TOPY+y1,LEFTX+x2,TOPY+y2);
end;{fieldbar}

procedure menubar(x1,y1,x2,y2:integer);
begin
 bar(XM+x1,TOPY+y1,XM+x2,TOPY+y2);
end;{menubar}

procedure eraser(px,py,x0,y0:integer);
var
 x,y:integer;
begin
 x:=x0+px*PIXELSIZE;
 y:=y0+py*PIXELSIZE;
 setfillstyle(1,7);
 bar(x,y,x+7,y+7);
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

 spix:=imagesize(1,1,PIXELSIZE-1,PIXELSIZE-1);
 getmem(pix,spix);
 getimage(1,1,PIXELSIZE-1,PIXELSIZE-1,pix^);
 eraser(0,0,1,1);
end;{savepixel}

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

procedure writeonfield(x,y:integer;w:string);
begin
 outtextxy(LEFTX+x,TOPY+y,w);
end;{writeonfield}

procedure writeonmenu(x,y:integer;w:string);
begin
 outtextxy(XM+x,TOPY+y,w);
end;{writeonmenu}

procedure menu;
begin
 settextstyle(0,0,3);
 writeonfield(-25,-50,'Tetris');
 settextstyle(0,0,1);

 writeonmenu(0,45,'Lines:');
 writeonmenu(0,60,'Score:');
 writeonmenu(0,157,'Level:');
 writeonmenu(0,172,'Speed:');

 setcolor(8);
 writeonfield(-200,55,'Pause:');
 writeonfield(-200,75,'Exit:');
 writeonfield(-200,95,'Rotate:');
 writeonfield(-200,115,'Faster:');
 writeonfield(-200,135,'Left:');
 writeonfield(-200,155,'Right:');
 writeonfield(-200,175,'Fall:');

 writeonfield(-130,55,'Enter');
 writeonfield(-130,75,'Escape');
 writeonfield(-130,95,'num 8');
 writeonfield(-130,115,'num 5');
 writeonfield(-130,135,'num 4');
 writeonfield(-130,155,'num 6');
 writeonfield(-130,175,'num 0');

 writeonfield(-70,95,'W');
 writeonfield(-70,115,'S');
 writeonfield(-70,135,'A');
 writeonfield(-70,155,'D');
 writeonfield(-70,175,'Space');

 writeonfield(-50,95,chr(24)); {arrow up}
 writeonfield(-50,115,chr(25)); {arrow down}
 writeonfield(-50,135,chr(27)); {arrow left}
 writeonfield(-50,155,chr(26)); {arrow right}

 outtextxy(getmaxx-115,getmaxy-15,'Homeniuk Nina');
 setcolor(0);
end;{menu}

{====================================================}

procedure pixel (px,py,x0:integer);
begin
 putimage(x0+px*PIXELSIZE,TOPY+py*PIXELSIZE,pix^,0);
end;{pixel}

procedure newfig(f0,xi,yi,x0:integer);
var 
 x,y:integer;
begin
 for i:=1 to FIGSIZE do
  for j:=1 to FIGSIZE do
   fbox[i,j]:=false; 
 for i:=1 to FIGSIZE do 
 begin
  x:=box[f0,i,1];
  y:=box[f0,i,2];
  fbox[x,y]:=true;
   pixel(xi+x-1,yi+y-1,x0);
 end;
end;{newfig}

procedure newfigure;
begin
 newfig(f,xnow,ynow,LEFTX);
end;{newfigure}

procedure newfnext;
begin
 newfig(fnext,0,0,XM);
end;{newfnext}

procedure delfig(f0,xi,yi,x0:integer);
var 
 x,y:integer;
begin
 for i:=1 to FIGSIZE do
 begin
  x:=box[f0,i,1];
  y:=box[f0,i,2];
  eraser(xi+x-1,yi+y-1,x0,TOPY);
 end;
end;{delfig}

procedure delfigure;
begin
 delfig(f,xnow,ynow,LEFTX);
end;{delfigure}

procedure delfnext;
begin
 delfig(fnext,0,0,XM);
end;{delfnext}

procedure fullrow(y0:integer);
begin
 for i:=0 to FIELDWIDTH-1 do
  pixel(i,y0,LEFTX);
end;{fullrow}

procedure delrow(y0:integer);
begin
 for i:=0 to FIELDWIDTH-1 do
  eraser(i,y0,LEFTX,TOPY);
end;{delrow}

function checkfall: boolean;
var
 fboxv:integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for i:=1 to FIGSIZE do 
 begin
  fboxv:=0;
  for j:=1 to FIGSIZE do
   if fbox[i,j]
    then fboxv:=j;
  if (fboxv<>0) 
   then begin
    u:=xnow+i;
    v:=ynow+fboxv+1;
    bv:=bv and not s[u,v] and (v<=FIELDHEIGHT);
   end;
 end;
 checkfall:=bv;
end;{checkfall}

function checkleft: boolean;
var
 fboxv:integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for j:=1 to FIGSIZE do 
 begin
  fboxv:=0;
  for i:=FIGSIZE downto 1 do
   if fbox[i,j]
    then fboxv:=i;
  if (fboxv<>0) 
   then begin
    v:=ynow+j;
    u:=xnow+fboxv-1;
    bv:=bv and not s[u,v] and (u>0);
   end;
 end;
 checkleft:=bv;
end;{checkleft}

function checkright: boolean;
var
 fboxv:integer; 
 bv:boolean;
 u,v:integer;
begin
 bv:=true;
 for j:=1 to FIGSIZE do 
 begin
  fboxv:=0;
  for i:=1 to FIGSIZE do
   if fbox[i,j]
    then fboxv:=i;
  if (fboxv<>0) 
   then begin
    v:=ynow+j;
    u:=xnow+fboxv+1;
    bv:=bv and not s[u,v] and (u<=FIELDWIDTH);
   end;
 end;
 checkright:=bv;
end;{checkright}

procedure moveright;
begin
 if checkright 
  then begin
   delfigure;
   inc(xnow);
   newfigure;
  end;
end; {moveright}

procedure moveleft;
begin
 if checkleft 
  then begin
   delfigure;
   dec(xnow);
   newfigure;
  end;
end;{moveleft}

procedure movedown;
begin
 if checkfall 
  then begin
   delfigure;
   inc(ynow);
   newfigure;
  end;
end;{movedown}

procedure checkrot(a,b:integer);
var 
 u,v:integer;
begin
 u:=xnow+a;
 v:=ynow+b;
 case u of
  0:begin
   moveright;
   u:=xnow+a;
  end;
  11:begin
   moveleft;
   if f=3 
    then moveleft;
   u:=xnow+a;
  end;
 end;
 if (v=0) 
  then begin
   movedown;
   v:=ynow+b;
  end;
 
 rot:=rot and not s[u,v] 
  and (u>0) and (u<=FIELDWIDTH) and (v>0) and (v<=FIELDHEIGHT);
end;{checkrot}

function checkrotate(newf:integer): boolean;
var
 newbox:array[1..FIGSIZE,1..FIGSIZE]of boolean;
begin
 if(newf=f)
  then rot:=false
  else begin
   rot:=true;
   for i:=1 to FIGSIZE do 
    newbox[box[newf,i,1],box[newf,i,2]]:=true;
   for i:=1 to FIGSIZE do
    for j:=1 to FIGSIZE do
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
   delfigure;
   f:=newf;
   newfigure;
  end;
end;{rotate}

procedure crash;
begin
 delfigure;
 while checkfall do
  inc(ynow);
 newfigure;
end;{crash}

procedure pause;
begin
 setcolor(8);
 settextstyle(0,0,2);
 writeonmenu(0,80,'Pause');
 settextstyle(0,0,1);
 setfillstyle(1,8);
 pieslice(XM+30,TOPY+120,180,360,20);
 menubar(10,115,50,120);
 menubar(5,140,55,144);
 setlinestyle(0,0,3);
 circle(XM+54,TOPY+125,7);
 setlinestyle(0,0,1);
 setfillstyle(1,7);
 setcolor(0);

 for i:=2 to 4 do begin
  putpixel(XM+i*10,TOPY+110,0);
  putpixel(XM+i*10,TOPY+109,0);
  putpixel(XM+i*10,TOPY+108,0);
  putpixel(XM+i*10+1,TOPY+107,0);
  putpixel(XM+i*10+2,TOPY+106,0);
  putpixel(XM+i*10+2,TOPY+105,0);
  putpixel(XM+i*10+2,TOPY+104,0);
  putpixel(XM+i*10+1,TOPY+103,0);
  putpixel(XM+i*10,TOPY+102,0);
  putpixel(XM+i*10,TOPY+101,0);
 end;
end;{pause}

function speeddelay:integer;
begin
 speeddelay:=630-(speed-1)*480 div (MAXSPEED-1);
end;{speeddelay}

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
    then case readkey of			{866 symbol table (ASCII, OEM, DOS)}
      #27: begin 					{ESC}
       finish:=true; 
       exit;
      end;
      #13: begin					{Enter}
       pause;
       if readkey=#27 				{ESC}
        then begin
         finish:=true; 
         exit;
        end
        else begin 
         setfillstyle(1,7);
         menubar(-3,70,100,155); 
        end;
      end;
      #48,#32: begin				{num0,Space}
       crash;
       exit;
      end;
      #56,#87,#119,#150,#230: begin {num8,W,w,Ц,ц}
       rotate;
       down:=true;
      end;
      #54,#68,#100,#130,#162: begin	{num6,D,d,В,в}
       moveright;
       down:=true;
      end;
      #52,#65,#97,#148,#228: begin	{num4,A,a,Ф,ф}
       moveleft;
       down:=true;
      end;
      #53,#83,#115,#155,#235:		{num2,S,s,І,і}
       n:=speeddelay;
      #0: case readkey of
        #72: begin 					{Up}
         rotate;
         down:=true;
        end;
        #77: begin 					{Right}
         moveright;
         down:=true;
        end;
        #75:begin 					{Left}
         moveleft;
         down:=true;
        end;
        #80: 						{Down}
         n:=speeddelay;
      end;
    end;
  until n>(speeddelay-5);
  movedown;
 end;{while}
end;{fall}

procedure delete;
var 
 z,h:integer;
 k:array[1..FIGSIZE] of integer; {full rows to be deleted}
begin
 for j:=1 to FIGSIZE do
  k[j]:=0;
 j:=0;
 q:=p; {lowest added square}

 {remember indexes of full rows in array K}
 repeat
  if (sv[q]=FIELDWIDTH) 
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
   menubar(49,44,100,54);
   str(alines,a);
   writeonmenu(50,45,a);{rows}

   score:=score+50+j*50; 
   menubar(49,59,100,69);
   str(score,a);
   writeonmenu(50,60,a);{scores}

   {blink with full rows}
   delay(time*250);
   for z:=1 to j do 
    delrow(k[z]-1);
   delay(time*250);
   for z:=1 to j do 
    fullrow(k[z]-1);
   delay(time*250);
   for z:=1 to j do 
   begin
    delrow(k[z]-1);
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
      for j:=1 to FIELDWIDTH do
       s[j,z]:=false;
      continue;
     end
     else begin
      inc(h);
      for j:=1 to FIELDWIDTH do 
      begin
       w[j,h]:=s[j,z];
       s[j,z]:=false;
      end;
      sv[z]:=0;
      delrow(z-1);
     end;
   end;

   {draw lowered lines}
   for i:=1 to h do 
   begin
    z:=k[1]-h+i;
    for j:=1 to FIELDWIDTH do 
    begin
     s[j,z]:=w[j,i];
     if s[j,z] 
      then begin
       pixel(j-1,z-1,LEFTX);
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
 writeonfield(0,70,'Ready?');
 writeonfield(25,105,'Go!');
 readkey;
 setfillstyle(1,7);
 fieldbar(0,49,90,130);
end;{hello}

procedure finishspeed;
begin
 for j:=q-1 to FIELDHEIGHT do 
 begin
  delrow(j-1);
  sv[j]:=0;
 end;
 inc(speed);
 setfillstyle(1,7);
 settextstyle(0,0,1);
 str(speed,a);
 if speed<=MAXSPEED 
  then begin
   menubar(49,171,100,181);
   writeonmenu(50,172,a);{speed}
  end;
end;{finishspeed}

procedure win;
begin
 settextstyle(0,0,2);
 writeonfield(18,50,'Win!');
 writeonfield(0,80,'Speed+');
 writeonfield(23,110,':-)');
 pausepicture(time*1500);
 setfillstyle(1,7);
 fieldbar(0,49,90,130);
end;{win}

procedure winlevel;
begin
 settextstyle(0,0,2);
 writeonfield(18,50,'Win!');
 writeonfield(6,80,'Level');
 writeonfield(0,110,'up :-)');
 pausepicture(time*1500);
 setfillstyle(1,7);
 fieldbar(0,49,90,130);
end;{winlevel}

procedure again;
begin
 settextstyle(0,0,2);
 writeonfield(20,50,'Try');
 writeonfield(5,80,'again');
 writeonfield(23,110,':-)');
 settextstyle(0,0,1);
 readkey;
 setfillstyle(1,7);
 fieldbar(4,49,82,130);
 menubar(49,171,100,181);
 menubar(49,156,100,166);
end;{again}

procedure looser;
begin
 for j:=FIELDHEIGHT downto 1 do 
 begin 
  if (j mod 2 = 0) 
   then 
    for i:=FIELDWIDTH-1 downto 0 do 
    begin
     pixel(i,j-1,LEFTX);
     delay(time*20);
    end
   else
    for i:=0 to FIELDWIDTH-1 do 
    begin 
     pixel(i,j-1,LEFTX);
     delay(time*20);
    end;
 end;
 for j:=1 to FIELDHEIGHT do 
  delrow(j-1);
end;{looser}

procedure goodbye;
begin
 for j:=1 to FIELDHEIGHT do 
  delrow(j-1);
 settextstyle(0,0,2);
 writeonfield(13,50,'Come');
 writeonfield(15,80,'back');
 writeonfield(1,110,'soon:)');
 pausepicture(time*1500);
 halt;
end;{goodbye}

procedure epicwin;
begin
 delfnext;
 settextstyle(0,0,2);
 writeonfield(20,50,'You');
 writeonfield(20,80,'did');
 writeonfield(21,110,'it!');
 settextstyle(0,0,1);
 menubar(49,171,100,181);
 menubar(49,156,100,166); 
 pausepicture(time*1500);
 fieldbar(0,49,90,130);
 readkey;
end;{epicwin}

{====================================================}

procedure closegame;
begin
 goodbye;
 freemem(pix,spix);
 closegraph;
 halt;
end;{closegame}

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

 {draw side menu}
 menu; 
end;{setupplayground}

procedure startgame;
begin
 alines:=0;
 score:=0;
 level:=1;
 f:=random(FIGURECOUNT)+1;
 fnext:=random(FIGURECOUNT)+1;
 
 {ready? go!}
 hello;
end;{startgame}

procedure startlevel;
begin
 settextstyle(0,0,1);
 speed:=1;
 menubar(49,171,100,181);
 writeonmenu(50,172,'1');{speed}
end;{startlevel}

procedure writelevel;
begin
 setfillstyle(1,7);
 settextstyle(0,0,1);
 str(level,a);
 menubar(49,156,100,166);
 if (level<=MAXLEVEL) {level}
  then writeonmenu(50,157,a);
end;{writelevel}

procedure drawlevel;
begin
 for j:=0 to (FIELDHEIGHT-level+1) do
 begin
  sv[j]:=0;
  for i:=1 to FIELDWIDTH do 
   s[i,j]:=false;
 end;
 if (level>1) 
  then
   for j:=(FIELDHEIGHT-level+2) to FIELDHEIGHT do
    for i:=1 to FIELDWIDTH do 
    begin
     if random(2)=0 
      then s[i,j]:=false
      else s[i,j]:=true;
     if s[i,j]
      then begin
       sv[j]:=sv[j]+1;
       pixel(i-1,j-1,LEFTX);
      end;
    end;
end;{drawlevel}

procedure drawfigures;
begin
 {draw next figure}
 delfnext;
 fnext:=random(FIGURECOUNT)+1;
 newfnext;

 {top left point of figure}
 xnow:=3; 
 ynow:=-1;
 case f of
  3,8,9,11:
   inc(ynow);
 end;
 
 {draw current figure}
 newfigure; 
end;{drawfigures}

procedure addfigure;
var 
 u,v:integer;
begin
 p:=1;
 v:=1;
 for i:=1 to FIGSIZE do 
 begin
  for j:=1 to FIGSIZE do
   if fbox[i,j]
    then begin
     u:=xnow+i;
     v:=ynow+j;
     s[u,v]:=true;
     sv[v]:=sv[v]+1;
    end;
  if (v>p) 
   then p:=v;
 end;
end;{addfigure}

procedure nextspeed;
begin
 {clear screen and go to next speed}
 finishspeed; 
 if speed<=MAXSPEED 
  then win
  else 
   if level<MAXLEVEL 
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
  888:
  repeat {one level}
   startlevel;
   writelevel;
   while (speed<=MAXSPEED) do {one speed}
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
    until (lines>=MAXLINES); {one figure fall}
    nextspeed;
   end; {one speed}
   inc(level);
   writelevel;
  until (level>MAXLEVEL); {one level}
  epicwin;
 end; {game session}
end.
