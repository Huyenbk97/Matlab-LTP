function LTP()
	clear all;
	
	% import packages
	import libht.core.*
	% declare global variables
	global scr;
	
	disableStuckKeys();
	
	% main
	try
		[scr.window, scr.rect]=setupScreen([0 0 1280 800]);
		setup();
		while(quitByKey('ESCAPE'))
			update();
			draw();
		end
		resetEnvironment();
	catch
		resetEnvironment();
		psychrethrow(psychlasterror);
	end
end


function setup()
	% import
	import libht.math.*
	
	% declare global variables
	global scr;
	global state;
	global cond;
	global time;
	global cross;

	global hfs_state;
	hfs_state = 0;
	global timeHFS;
	global hfsFlag;
	hfsFlag = 0;

	
	% initialize variables
	scr.BGColor=[255];
	scr.textColor=[0];
	scr.textSize=15;
	
	state.scene=1;
	state.trialID=1;
	state.trialPhase=1;
	state.blockID=1;
	state.trialIDwithinBlock=1;
	state.isInterblockRest=0;
	state.isInterblockRestTriggered=0;
	
	% cond.setsize=[1 2 3];
	cond.setsize=1;

	cond.numColor=8;
	cond.numBlock=2;
	cond.numcolorWithinBlock=10; % recommend: 1-5 
	cond.numTrial=cond.numColor * cond.numBlock * cond.numcolorWithinBlock;

	cond.numTotalTrial=cond.numTrial*size(cond.setsize,2);
	cond.maxSetsize=max(cond.setsize);
	cond.setsizeOrder=...
		makeSetsizeOrder(cond.setsize, cond.numTrial, cond.numBlock);
	
	cond.TF=binaryArrayShuffled(cond.numTotalTrial);
	cond.response=zeros(1, cond.numTotalTrial); % true or false
	cond.reactiontime=zeros(1, cond.numTotalTrial);

	
	cond.memoryDuration=1;
	cond.blankDuration=0.1;
	cond.responseDuration=3;
	cond.restDuration=1.5;

	% cond.hzduration=0.1111; % 9Hz
	cond.hzduration=0.05; % 9Hz
	cond.showduration=0.00334; % 33.4msec
	cond.gridsize=80;

	
	%%%%% color %%%%%
	cond.ceilcolor=249;
	cond.color=[
				cond.ceilcolor; 
				cond.ceilcolor - 1;
				cond.ceilcolor - 2;
				cond.ceilcolor - 3;
				cond.ceilcolor - 4;
				cond.ceilcolor - 5;
				cond.ceilcolor - 6;
				cond.ceilcolor - 7;
				];
	
	cond.color_list=zeros(1,cond.numTrial);

	tempList = zeros(1,cond.numTrial/2);
	j = 1;
	for i=1:cond.numTrial/2
		tempList(i) = j;
		% if (mod(i,3) == 0)
		if (mod(i,cond.numcolorWithinBlock) == 0)
			j = j + 1;
		end

	end
	listA = Shuffle(tempList);
	listB = Shuffle(tempList);

	randomList = horzcat(listA,listB);

	cond.colorRandomList = zeros(1,cond.numTrial);
	for i=1:cond.numTrial
		cond.colorRandomList(i) = cond.color(randomList(i));	
	end
	cond.colorRandomList
	%%%%% end of color %%%%%



	time.initTime=clock;
	
	crossSize=20;
	texArray=ones(crossSize, crossSize)*scr.BGColor;
	texArray(crossSize/2:crossSize/2+1,:)=0; % horizontal line
	texArray(:,crossSize/2:crossSize/2+1)=0; % vertical line
	cross.tex=Screen('MakeTexture', scr.window, texArray);
	cross.width=crossSize;
	cross.height=crossSize;
	
	Screen('TextSize',  scr.window, scr.textSize);
	
end


function update()
	% declare global variable
	global state;
	global time;
	global cond;

	global hfs_state;
	
	% check keyboard to transit scene
	[keyIsDown, secs, keyCode]=KbCheck;
	if keyIsDown
		keys=find(keyCode);
		names=cellstr(KbName(keys));
		if(state.scene==1 && strcmp(names, 'space'))
			state.scene=2;
		elseif(state.scene==4 && strcmp(names, 'space'))
			state.scene=2;
		elseif(state.scene==2 && state.trialPhase==4 && strcmp(names, '1!'))
			cond.reactiontime(state.trialID)=toc;
			if(cond.TF(state.trialID)==1) % answer is L
				cond.response(state.trialID)=1;
				% tic;
			end
			tic;
			state.trialPhase=5;
		elseif(state.scene==2 && state.trialPhase==4 && strcmp(names, '2@'))
			cond.reactiontime(state.trialID)=toc;
			if(cond.TF(state.trialID)==0) % answer is R
				cond.response(state.trialID)=1;
				% tic;
			end
			tic;
			state.trialPhase=5;
		elseif(state.scene==2 && state.trialPhase==4 && strcmp(names, '3#'))
			cond.reactiontime(state.trialID)=toc;
			cond.response(state.trialID)=-1;
			tic;
			state.trialPhase=5;
		elseif(state.isInterblockRest && state.isInterblockRestTriggered==0 && strcmp(names, 'space'))
			state.isInterblockRestTriggered=1;
			tic;
		end
	end
	
	% update elapsed time
	time.elapsed=etime(clock, time.initTime);
end


function draw()
	% declare global variable
	global scr;
	global state;
	global time;
	global cond;

	global hfs_state;

	
	% draw current scene
	switch(state.scene)
		case 1; 	startScene();
		case 2; 	trialScene();
		case 3; 	  endScene();
		case 4; 	 restScene();
		otherwise;	startScene();
	end
	
	% draw information
	margin=18;
	Screen('DrawText', scr.window,...
		sprintf('time:%02.2f', time.elapsed),...
		10, margin*1, scr.textColor);
	% Screen('DrawText', scr.window,...
	%	sprintf('cond.scene:%d', state.scene),...
	%	10, margin*2, scr.textColor);
	% Screen('DrawText', scr.window,...
	%	sprintf('state.trialID:%d', state.trialID),...
	%	10, margin*3, scr.textColor);
	% Screen('DrawText', scr.window,...
	%	sprintf('cond.TF:%d', cond.TF(state.trialID)),...
	%	10, margin*4, scr.textColor);
	% Screen('DrawText', scr.window,...
	%	sprintf('state.trialPhase:%d', state.trialPhase),...
	%	10, margin*5, scr.textColor);
	% Screen('DrawText', scr.window,...
	%	sprintf('state.trialPhase:%d', state.isInterblockRest),...
	%	10, margin*6, scr.textColor);
	
	% flip screen
	Screen('Flip', scr.window);
end


function startScene()
	% declare global variable
	global scr;
	
	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% text message
	Screen('DrawText', scr.window,...
		sprintf('Press space button to start experiment.'),...
		scr.width*0.3, scr.height*0.5, scr.textColor);
	
end


function trialScene()
	% import packages
	import libht.wrap.*
	import libht.math.*
	
	% declare global variable
	global scr;
	global state;
	global cond;
	global cross;
	
	global hfs_state;
	global timeHFS;
	global hfsFlag;

	threSample=0;
	% showduration = 1;
	hzduration = 0.11;
	gridsize=80;
	X=scr.width/2-gridsize*2.5;
	Y=scr.height/2-gridsize*2.5;
	tempX=X;


	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% trials
	% Phase1: generate stimuli
	if(state.trialPhase==1)
		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);
		% transition to next phase
		tic;
		state.trialPhase=2;
		
	% Phase2: display checkerboard stimuli 
	elseif(state.trialPhase==2)

		color=cond.colorRandomList(state.trialID);
		gridsize=30;

		% set X & Y
		if(cond.TF(state.trialID)==0)
			X=scr.width/2-gridsize*2.5+scr.width/4; % Right
		else
			X=scr.width/2-gridsize*2.5-scr.width/4; % Left
		end
		tempX=X;
		Y=scr.height/2-gridsize*2.5;


		for i=1:25
			if (mod(i, 2)==1)
				Screen('FillRect', scr.window,[color], [X Y X+gridsize Y+gridsize]);
			else
				Screen('FillRect', scr.window,[255 255 255], [X Y X+gridsize Y+gridsize]);
			end
			X=X+gridsize;

			if (mod(i,5)==0)
				X=tempX;
				Y=Y+gridsize;
			end
		end

		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);

		if(toc>cond.showduration)
			tic;
			state.trialPhase=3;
		end
		
	% Phase3: blank interbal
	elseif(state.trialPhase==3)
		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);
		% transition to next phase
		if(toc>cond.blankDuration)
			% tic;
			state.trialPhase=4;
		end
		
	% Phase4: response
	elseif(state.trialPhase==4)
		 Screen('DrawText', scr.window,...
			sprintf('Left of Right?'),...
			scr.width*0.4, scr.height*0.7, scr.textColor);
		 Screen('DrawText', scr.window,...
			sprintf('Left = 1, Right = 2'),...
			scr.width*0.4, scr.height*0.7+30, scr.textColor);

		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);

		% transition to next phase
		if(toc>cond.responseDuration)
			% tic;
			Screen('DrawText', scr.window,...
				sprintf('Prease press 1 or 2 even if you could not detect it'),...
				scr.width*0.4, scr.height*0.8+30, scr.textColor);

			% state.trialPhase=5;
		end
		
	% Phase5: inter-trial rest
	elseif(state.trialPhase==5)
		% transition to first phase
		if(toc>cond.restDuration)
			if(state.trialID+1>cond.numTotalTrial)

				%%%  print result %%%
				% cond.color_list 
				cond.colorRandomList
				cond.response
				% cond.reactiontime

				directory='result/';
				% currentDate=datestr(now, 'yyyy_mmdd_HHMMSS');
				currentDate=datestr(now,31);
				fileName=strcat(directory, currentDate, '.mat');
				
				% save variables
				save(fileName); % save all variables
				%save(fileName, 'a'); % save only a

				%%%  end of print result %%%

				state.scene=3;%endScene

			elseif(state.trialIDwithinBlock==size(cond.setsizeOrder,2)...
					|| cond.setsizeOrder(state.blockID, state.trialIDwithinBlock)==0)
				if(state.isInterblockRestTriggered && toc>cond.restDuration) % transition to next trial
					state.isInterblockRest=0;
					state.isInterblockRestTriggered=0;
					state.blockID=state.blockID+1;
					state.trialIDwithinBlock=1;
					state.trialPhase=1;
					state.trialID=state.trialID+1;

					%%%
					state.scene = 4; % to start scene
					%%%

					% draw center cross
					drawTexture(cross.tex,...
						[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
						[cross.width cross.height]);
				elseif(state.isInterblockRestTriggered) % some pause
					
				else % Display HFC Stimuli
					state.isInterblockRest=1;
					% if (hfs_state == 1)
					%	hfsScene(1)
					%	pause(cond.hzduration)
					%	hfs_state = 2;
					% else
					%	% hfsScene(0)
					%	pause(cond.hzduration)
					%	hfs_state = 1;
					% end
					hfsScene(hfs_state);
					pause(cond.hzduration)
					hfs_state = 1 - hfs_state;

					if (hfsFlag == 0)
						timeHFS = clock;
						hfsFlag = 1;
					end

					if (etime(clock, timeHFS) > 120)
						state.isInterblockRestTriggered=1;
						tic;
					end

				end

			else
				state.trialIDwithinBlock=state.trialIDwithinBlock+1;
				state.trialPhase=1;
				state.trialID=state.trialID+1;
				% draw center cross
				drawTexture(cross.tex,...
					[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
					[cross.width cross.height]);
			end
		else
			% draw center cross
			drawTexture(cross.tex,...
				[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
				[cross.width cross.height]);
		end
	end
	
	
end


function endScene()
	% import packages
	import libht.wrap.*
	import libht.math.*
	
	% declare global variable
	global scr;
	global cond;
	
	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% text message
	Screen('DrawText', scr.window,...
		sprintf('Experiment has finished. Thank you for your time!'),...
		scr.width*0.3, scr.height*0.5, scr.textColor);
	

end


function hfsScene(a)
	import libht.wrap.*
	import libht.math.*

	global scr;
	global hfs_state;

	threSample=0;
	% hzduration = 0.11;
	gridsize=80;
	gridnum=7; % 2n -1
	% X=scr.width/2-gridsize*2.5;
	% Y=scr.height/2-gridsize*2.5;
	X=scr.width/2-gridsize*gridnum/2;
	Y=scr.height/2-gridsize*gridnum/2;
	tempX=X;

	if (a ~= 0 && a ~= 1)
		a = 1;
	end

	% for i=1:25
	for i=1:gridnum*gridnum
		if (mod(i, 2)==a)
			Screen('FillRect', scr.window,[threSample threSample threSample], [X Y X+gridsize Y+gridsize]);
		else
			Screen('FillRect', scr.window,[255 255 255], [X Y X+gridsize Y+gridsize]);
		end
		X=X+gridsize;

		if (mod(i,gridnum)==0)
			X=tempX;
			Y=Y+gridsize;
		end
	end

end

function restScene()
	% declare global variable
	global scr;
	
	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% text message
	Screen('DrawText', scr.window,...
		sprintf('Press space button to restart experiment.'),...
		scr.width*0.3, scr.height*0.5, scr.textColor);
	
end

