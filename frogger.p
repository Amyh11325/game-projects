Program Frogger;
uses crt;

Type
ArrayType=array [1..38,1..79]of char;

//CarSpeeds: how fast the cars move, the lower the faster
//CarSpacing: how many spaces between cars
//CarLength: 1 or 2
//CarDirection: left(0) or right(1)
//Road: if true there are cars, if false there is grass and trees
OneRoadRecord=record
		CarSpeeds,CarSpacing,CarStart,CarLength,CarDirection:integer;
		Road:boolean;
		end;

RecordType=array[1..38] of OneRoadRecord;

Var
//array containing game: ' ' nothing, '*' tree, '=' car, 'o' player
gameDisplay:ArrayType;

//seconds: arbitrary measure of time
//score: the furthest up the player moved
//highscore: highest score in one session
//maxRows: height of the gameDisplay
//maxColums: width of the gameDisplay
seconds,score,highscore,maxRows,maxColumns:integer;

//counter: arbitrary measure of time
counter:real;

//contains array of road information
RoadRecord:RecordType;

//if true, the player died
EndOfGame:boolean;

{**********************************************************************************************************************}
//displays instructions and sets grid size
Procedure Introduction(var Col,row:integer);
begin
writeln('Amy He''s Frogger':49);
writeln;
writeln('This is a recreation of the game Frogger or Crossy Road.');
writeln('Like Crossy Road this is unlimited, randomly generated play until you lose.');
writeln('Please press enter.');
readln;
clrscr;
writeln('How to Play:':46);
writeln;
writeln('This section is for those who don''t know how to play Crossy Road or Frogger.');
writeln;
writeln('In these games you are a frog or chicken trying to cross the road.');
writeln('However, there are several moving cars that are willing to run you over.');
writeln('You must dodge the cars and get as far as you can.');
readln;
clrscr;
writeln('Instructions On This Game:':56);
writeln;
writeln('This is you.');
writeln;
writeln('o':10);
writeln;
writeln('(Use your imagination)');
writeln('Use the arrow keys to move yourself.');
readln;
writeln('These are cars.');
writeln;
writeln('=':10);
writeln;
writeln('If you touch them you will die.');
readln;
writeln('These are trees.');
writeln;
writeln('*':10);
writeln;
writeln('You can''t go through trees.');
readln;
clrscr;
writeln('Notes This Game:':56);
writeln('This game has:');
writeln('Increasing difficulties as your score increases');
writeln('Different sized cars with defferent speeds and spacings');
writeln('Selectable game size');
writeln('Screen that moves forward if you are too slow');
writeln('A score counter');
readln;
writeln('This game does not have:');
writeln('Rivers or trains');
writeln('Good graphics');
writeln;
writeln('That''s about all you need to know');
writeln('Have Fun!');
readln;
clrscr;
writeln('Please enter the number of columns and rows you would like.');
writeln('First the number of rows, press enter, then the number of columns.');
writeln;
writeln('Note:The more rows and columns the more the graphics will the flash');
writeln('Note:Larger graphics are not tested. Use at your own risk.');
writeln('Max number of rows: 38. Max number of columns: 79.');
writeln('Minimum number of rows: 5. Minimum number of columns: 2.');
writeln('Recommended size: 10 by 20.');
readln(row);
readln(col);
end;
{**********************************************************************************************************************}
//initializes the game display
Procedure Initialize(Var game:arraytype);
	Var
	row,col:integer;
	begin
	for row:=1 to maxRows do
		begin
		for col:=1 to maxColumns do
			begin
			game[row,col]:=' ';
			end;
		end;
	end;
{**********************************************************************************************************************}
//displays the game with colors
//green: grass, gray: road
Procedure DisplayGame(game:arraytype;
			RoadRecord:recordType);
	Var
	row,col:integer;
	begin
	clrscr;
	for row:=1 to maxRows do
		begin
		If RoadRecord[row].Road=true then
			textBackground(7)
			else
			If RoadRecord[row].Road=false then
				textBackground(10);
		for col:=1 to maxColumns do
			begin
			write(game[row,col]);
			end;
		textBackground(0);
		writeln;
		end;
	writeln('score: ',score);
	writeln('highscore: ',highscore);
	end;
{**********************************************************************************************************************}
// move one row of cars left
// works by shifting where the train of cars "start" left
Procedure MoveLeft(Var game:arraytype;
		   Var RoadRecord:recordtype;
		   Row:integer;
		   Var EndGame:boolean);
Var
col,i:integer;
begin

//clears a row, unless the player is there
for i:=1 to maxColumns do
	begin
	If game[row,i]<>'o' then
		game[row,i] :=' ';
	end;

//if a car reaches the edge of the screen, set carStart to CarSpacing
If RoadRecord[row].CarStart <=1 then
	begin
	RoadRecord[row].CarStart:=RoadRecord[row].CarSpacing;
	//if a car is two long and reaches the edge
	If RoadRecord[row].CarLength=2 then
		begin
		If game[row,1]='o' then
			EndGame:=true;
		game[row,1]:='=';
		RoadRecord[row].CarStart:=RoadRecord[row].CarStart+1;
		end;
	end
//else just shift where the cars start left one
else
	RoadRecord[row].CarStart:=RoadRecord[row].CarStart-1;
col:=RoadRecord[Row].CarStart;

//redisplay the cars now shifted left one
While (col<=MaxColumns)do
	begin
	//first check if player is in the way
	If game[row,col]='o' then
		EndGame:=true;

	game[row,col]:='=';
	//if the cars are two long, add their second part
	If (RoadRecord[Row].CarLength=2) and (col<maxColumns) then
		begin
		col:=col+1;
		If game[row,col]='o' then
			EndGame:=true;
		Game[row,col]:='=';
		end;
	writeln(RoadRecord[row].CarSpacing,col);
	col:=col+RoadRecord[Row].CarSpacing;
	end;
end;
{**********************************************************************************************************************}
//move one row of cars right
//same logic as MoveLeft
Procedure MoveRight(Var game:arraytype;
		    Var RoadRecord:recordtype;
		    Row:integer;
		    Var EndGame:boolean);
Var
col,i:integer;

begin
//remove the cars currently on the road
for i:= 1 to maxColumns do
	begin
	If game[row,i]<>'o' then
		game[row,i]:=' ';
	end;

//if the first car reached the end of the road, set where the cars start to CarSpacing
If RoadRecord[Row].Carstart<=1 then
	begin
	RoadRecord[row].CarStart:=RoadRecord[row].CarSpacing;

	//if the cars are two long on this road, add the half of the last car still on the road
	If RoadRecord[row].CarLength=2 then
		begin
		If game[row,maxColumns]='o' then
			endGame:=true;
		game[row,maxColumns]:='=';
		RoadRecord[row].CarStart:=RoadRecord[row].CarStart+1;
		end;
	end
//else shift the cars one right
else
	RoadRecord[row].CarStart:=RoadRecord[row].CarStart-1;

//redisplay the cars
col:=MaxColumns-RoadRecord[Row].CarStart+1;
While (col>=1) do
	begin
	//first check if player is in the way
	If game[row,col]='o' then
		Endgame:=true;
	Game[row,col]:='=';

	//if the cars are two long, display the second half
	If (RoadRecord[Row].CarLength=2) and(col>1) then
		begin
		col:=col-1;
		If game[row,col]='o' then
			Endgame:=true;
		Game[row,col]:='=';
		end;

	col:=col-RoadRecord[Row].CarSpacing;
	end;
end;
{**********************************************************************************************************************}
//takes the array of road records and shifts them down an array index
Procedure MoveDownRecord(Var UsedRecord:RecordType);
Var
i:integer;
begin
i:=maxRows;
While i>0 do
	begin
	UsedRecord[i]:=UsedRecord[i-1];
	i:=i-1;
	end;
end;
{**********************************************************************************************************************}
//called when the player moves forward
//creates new rows of the game
//the probability variables can be changed to change the difficulty
Procedure CreateNewLand(var game:arraytype;
			var roadRecord:recordtype);
Var
col,roadProb,spacingProb,lowestSpacing,prob,treeProb:integer;
begin
treeProb:=6;	//probability there is a tree
roadProb:=6;	//probability there is a road
spacingProb:=4;	//controls the range of the  space between cars
lowestSpacing:=5;//controls the closes together cars can be
prob:=3;	//controls the probability there is a road

//adjusts probabilities to make the game harder when score is higher
If (score>15) then
	begin
	roadProb:=roadProb+1;
	prob:=2;
	treeProb:=treeProb-1;
	end;
If (score>40) then
	lowestSpacing:=lowestSpacing-1;
If(score>100) then
	begin
	roadProb:=roadProb+1;
	spacingProb:=spacingProb-1;
	treeProb:=treeProb-1;
	prob:=1;
	end;
If (score>150) then
	lowestSpacing:=lowestSpacing-1;

//if there was a road before this one, make the probability that there will be a road after lower, else higher
If RoadRecord[2].Road=true then
	roadProb:=roadProb-2
else
	roadProb:=roadProb+1;

//make grass and trees or a road and cars
If random(RoadProb)<prob then
	begin
	for col:=1 to maxColumns do
		begin
		If random(treeProb)=0 then
			game[1,col]:='*'
		else
			game[1,col]:=' ';
		end;
	RoadRecord[1].Road:=false;
	end
else
	begin
	for col:=1 to maxColumns do
		begin
		game[1,col]:=' ';
		end;
	RoadRecord[1].CarSpacing:=random(spacingProb)+LowestSpacing;
	RoadRecord[1].CarLength:=random(2)+1;
	RoadRecord[1].CarStart:=random(4)+1;
	RoadRecord[1].CarDirection:=random(2);
	RoadRecord[1].CarSpeeds:=random(10)+1;
	RoadRecord[1].Road:=True;
	If RoadRecord[1].CarDirection=0 then
		MoveLeft(game,RoadRecord,1,EndOfGame)
	else
		MoveRight(game,RoadRecord,1,EndOfGame);
	end;
end;
{*********************************************************************************************************************}
//moves all the cars with car speeds between min and max
Procedure MoveCars(Var RoadRecord:Recordtype;
			min,max:integer);
var
i:integer;
begin
for i:=1 to maxRows do
	begin
	If (RoadRecord[i].Road=true) and(RoadRecord[i].CarSpeeds>min) and (RoadRecord[i].CarSpeeds<max) then
		begin
		If RoadRecord[i].CarDirection=0 then
			moveLeft(gameDisplay,RoadRecord,i,EndOfGame)
		else
			moveRight(gameDisplay,RoadRecord,i,EndOfGame);
		DisplayGame(gameDisplay,RoadRecord);
		end;
	end;
end;
{**********************************************************************************************************************}
//calls MoveCars with certain parameters to move certain rows of cars
//used to regulate various timings
//there are currently three different speeds:
//cars that move 1, 2, or 3 seconds
Procedure CheckSpeeds(Var RoadRecord:Recordtype;
		      Var second:integer);
var
diff:integer;	//if diff is the probability of faster cars is higher
begin
diff:=2;
If (score>100) then
	diff:=0
else
	If (score>15) then
		diff:=1;
If (second=1) then
	moveCars(RoadRecord,0,4-diff)	//moves cars with speeds between 0 and 4-diff
else
	begin
	If (second=2) then
		moveCars(RoadRecord,0,7-diff)
	else
		begin
		If (second=3) then
			begin
			moveCars(RoadRecord,7-diff,11);
			moveCars(RoadRecord,0,4-diff);
			end
		else
			If (second=4) then
				movecars(RoadRecord,0,7-diff)
			else
				If (second=5) then
					moveCars(RoadRecord,0,4-diff)
				else
					If (second=6) then
						begin
						moveCars(RoadRecord,0,11);
						second:=0;	//resets second
						end;
		end;
	end;
end;
{**********************************************************************************************************************}
//moves every character, except'o', in the array down a row
//calls createNewLand
Procedure MoveDownDisplay(Var game:arraytype);
Var
row,col:integer;
begin
row:=maxRows;
While (row>0) do
	begin
	for col:=1 to maxColumns do
		begin
		If (game[row,col]<>'o') and(game[row-1,col]<>'o') and(game[row,col]<>game[row-1,col])then
			game[row,col]:=game[row-1,col]
		else
			begin
			If (game[row,col]='o')then
				gameDisplay[row+1,col]:=' ';
			end;
		end;
	row:=row-1;
	end;
moveDownRecord(roadRecord);
createNewLand(game,roadRecord);
end;
{**********************************************************************************************************************}
//backbone of the program
//moves the frog, and keeps count of the seconds
Procedure MoveFrog(Var game:arraytype;
		  Var counter:real;
		  Var milliseconds,score:integer;
		  Var EndGame:boolean);
Var
//row, col: position of the player
//counter2, transferseconds: timer to move the screen forward automatically
//time: determines how fast the screen moves forward automatically
row,col,counter2,i,time,transferseconds:integer;
key:char;

begin
transferseconds:=0;
row:=maxRows-2;
col:=maxColumns div 2;
counter:=0;
seconds:=0;
score:=0;
time:=750;
game[row,col]:='o';
endGame:=false;

//create the starting game screen
for i:=1 to maxRows do
	begin
	moveDownDisplay(game);
	end;
//sets the row the player starts on to grass with no trees
RoadRecord[maxRows-2].Road:=false;
for i:=1 to maxColumns do
	begin
	if game[maxRows-2,i]<>'o' then
		game[maxRows-2,i]:=' ';
	end;

DisplayGame(game,RoadRecord);

//runs until the player dies or goes out of bounds
While (row<=maxRows)and(row>0)and (col>0) and(col<=maxColumns) and (EndGame=false) do
	begin
	While (keyPressed=true) do
		begin
		//takes keyboard input
		key:=Readkey;
		Case key of
		//player moves up
		#72:begin
		If (game[row-1,col]=' ') then
			begin
			//if the player tries to moves forward at two rows from the bottom, move the display down
			If (row=MaxRows-2) then
				begin
				score:=score+1;
				moveDownDisplay(game);

				//if the player moves forward reset the timer for moving the screen
				counter2:=0;
				transferseconds:=0;
				end
			//else move the player forward normally
			else
				begin
				game[row,col]:=' ';
				row:=row-1;
				game[row,col]:='o';
				end
			end
		else
			begin
			//if car is where player is trying to move, end the game
			If (game[row-1,col]='=') then
				EndGame:=true;
			end;
		end;

		//player moves down
		#80:begin
		If (game[row+1,col]<>'*') and(game[row+1,col]<>'=') then
			begin
			game[row,col]:=' ';
			row:=row+1;
			game[row,col]:='o';
			end
		else
			begin
			If game[row+1,col]='=' then
				Endgame:=true
			else
				begin
				If row=maxRows then
					endGame:=true
				end;
			end;
		end;

		//player moves left
		#75:begin
		If (game[row,col-1]=' ') then
			begin
			game[row,col]:=' ';
			col:=col-1;
			gameDisplay[row,col]:='o';
			end
		else
			begin
			If(game[row,col-1]='=') then
				EndGame:=true
			else
				begin
				If col=1 then
					Endgame:=true;
				end;
			end;
		end;

		//player moves right
		#77:begin
		If game[row,col+1]=' ' then
			begin
			game[row,col]:=' ';
			col:=col+1;
			game[row,col]:='o';
			end
		else
			begin
			If (game[row,col+1]='=') then
				endGame:=true
			else
				begin
				If (col=maxColumns) then
					endGame:=true;
				end;
			end;
		end;
		end;
		writeln(transferseconds);
		displayGame(game,RoadRecord);
		end;
	//increment transferseconds and counter2
	transferseconds:=transferseconds+1;
	If (transferseconds=4000) then
		begin
		transferseconds:=0;
		counter2:=counter2+1;
		end;

	//when score is higher, time decreases
	If (score>=50) and (score<100) then
		time:=715
	else
		begin
		If (score>=100) then
			time:=680;
		end;
	
	//increment counter and seconds and move cars
	counter:=counter+0.5;
	If counter=80000 then
		begin
		seconds:=seconds+1;
		counter:=0;
		CheckSpeeds(Roadrecord,seconds);
		end;

	//if counter2 equals the set time, move the screen ahead of the player
	If (counter2=time) then
		begin
		game[row,col]:=' ';
		row:=row+1;
		game[row,col]:='o';
		counter2:=0;
		moveDownDisplay(game);
		displayGame(game,RoadRecord);
		end;
	end;
end;
{**********************************************************************************************************************}
//displays game over and score message
//asks to restart game or quit playing
Procedure EndOfProgram;
Var
	answer:char;
begin
writeln;
writeln('Game Over');
writeln('Your final score is ', score,'.');
If(score>highscore) then
	begin
	writeln('New High Score!!!');
	writeln('(for this session)');
	highscore:=score;
	end
else
	writeln('The highest score of this session was ', highscore,'.');
writeln;
writeln('Would you like to play again(y or n)');
readln(answer);
If answer='y' then
	begin
	initialize(gameDisplay);
	MoveFrog(gameDisplay,counter,seconds,score,EndOfGame);
	endOfProgram;
	end
else
	If answer='n' then
	begin
	writeln('Thanks for playing!!!');
	writeln;
	writeln('End of Program. Please press Enter.');
	writeln('Amy He 2016');
	end;
exit;
end;
{**********************************************************************************************************************}
begin
randomize;
clrscr;
cursoroff;
highscore:=0;
Introduction(maxColumns,maxRows);
Initialize(gameDisplay);
textColor(15);
MoveFrog(gameDisplay,counter,seconds,score,EndOfGame);
EndOfProgram;
end.
