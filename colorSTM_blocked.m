
function colorSTM_blocked()
	clear all;
	
	% import packages
	import libht.core.*
	% declare global variables
	global scr;
	
	disableStuckKeys();
	
	% main
	try
		[scr.window, scr.rect]=setupScreen([0 0 800 600]);
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
	
	% initialize variables
	scr.BGColor=[200];
	scr.textColor=[0];
	scr.textSize=15;
	
	state.scene=1;
	state.trialID=1;
	state.trialPhase=1;
	state.blockID=1;
	state.trialIDwithinBlock=1;
	state.isInterblockRest=0;
	state.isInterblockRestTriggered=0;
	
	cond.numTrial=2;
	cond.setsize=[1 2 3];
	cond.numBlock=3;
	cond.numTotalTrial=cond.numTrial*size(cond.setsize,2);
	cond.maxSetsize=max(cond.setsize);
	cond.setsizeOrder=...
		makeSetsizeOrder(cond.setsize, cond.numTrial, cond.numBlock);
	
	cond.TF=binaryArrayShuffled(cond.numTotalTrial);
	cond.response=zeros(1, cond.numTotalTrial);
	
	cond.distance=150;
	cond.diameter=60;
	
	cond.memoryDuration=1;
	cond.blankDuration=1;
	cond.responseDuration=3;
	cond.restDuration=1;
	cond.numColor=8;
	
	cond.color=[255 000 000; % red
				000 255 000; % green
				000 000 255; % blue
				255 255 000; % yellow
				000 255 255; % light blue
				255 000 255; % pink
				255 255 255; % white
				000 000 000; % black
				];
	
	cond.currentColor=zeros(max(cond.setsize), 3);
	cond.falseColor=[0 0 0];
	cond.currentPosition=zeros(max(cond.setsize), 2);
	
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
	
	% check keyboard to transit scene
	[keyIsDown, secs, keyCode]=KbCheck;
	if keyIsDown
		keys=find(keyCode);
		names=cellstr(KbName(keys));
		if(state.scene==1 && strcmp(names, 'space'))
			state.scene=2;
		elseif(state.scene==2 && state.trialPhase==4 && strcmp(names, '1!'))
			if(cond.TF(state.trialID)==1)
				cond.response(state.trialID)=1;
			end
			tic;
			state.trialPhase=5;
		elseif(state.scene==2 && state.trialPhase==4 && strcmp(names, '2@'))
			if(cond.TF(state.trialID)==0)
				cond.response(state.trialID)=1;
			end
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
	
	% draw current scene
	switch(state.scene)
		case 1;		startScene();
		case 2;		trialScene();
		case 3;		  endScene();
		otherwise;	startScene();
	end
	
	% draw information
	margin=18;
	Screen('DrawText', scr.window,...
		sprintf('time:%02.2f', time.elapsed),...
		10, margin*1, scr.textColor);
	Screen('DrawText', scr.window,...
		sprintf('cond.scene:%d', state.scene),...
		10, margin*2, scr.textColor);
	Screen('DrawText', scr.window,...
		sprintf('state.trialID:%d', state.trialID),...
		10, margin*3, scr.textColor);
	Screen('DrawText', scr.window,...
		sprintf('cond.TF:%d', cond.TF(state.trialID)),...
		10, margin*4, scr.textColor);
	Screen('DrawText', scr.window,...
		sprintf('state.trialPhase:%d', state.trialPhase),...
		10, margin*5, scr.textColor);
	Screen('DrawText', scr.window,...
		sprintf('state.trialPhase:%d', state.isInterblockRest),...
		10, margin*6, scr.textColor);
	
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
	
	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% trials
	% Phase1: generate stimuli
	if(state.trialPhase==1)
		% set currentSetsize
		currentSetsize=...
			cond.setsizeOrder(state.blockID, state.trialIDwithinBlock);
		
		% set current color
		randomColor=randomInt(cond.numColor, cond.maxSetsize);
		for i=1:currentSetsize
			cond.currentColor(i,:)=cond.color(randomColor(i),:);
		end
		% set false-probe's color
		while 1
			%c=random('unid', cond.setsize);
			if(currentSetsize==1)
				c=2;
				break;
			end
			c=randi(currentSetsize, 1);
			if(c~=1)
				break;
			end
		end
		cond.falseColor=cond.color(randomColor(c),:);
		% set current position
		%randomOffset=random('unid', 360);
		randomOffset=randi(360, 1);
		angularInterval=360/currentSetsize;
		for i=1:currentSetsize
			theta=randomOffset+angularInterval*i;
			x=scr.width/2 + cond.distance*cos(deg2rad(theta));
			y=scr.height/2 + cond.distance*sin(deg2rad(theta));
			cond.currentPosition(i,:)=[x,y];
		end
		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);
		% transition to next phase
		tic;
		state.trialPhase=2;
		
	% Phase2: display memory items
	elseif(state.trialPhase==2)
		% set currentSetsize
		currentSetsize=...
			cond.setsizeOrder(state.blockID, state.trialIDwithinBlock);
		% draw color circles
		for i=1:currentSetsize
			rect=[cond.currentPosition(i,1), cond.currentPosition(i,2),...
				  cond.diameter, cond.diameter];
			color=cond.currentColor(i,:);
			fillOval(rect, color);
		end
		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);
		% transition to next phase
		if(toc>cond.memoryDuration)
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
			tic;
			state.trialPhase=4;
		end
		
	% Phase4: response
	elseif(state.trialPhase==4)
		% draw probe item
		rect=[cond.currentPosition(1,1), cond.currentPosition(1,2),...
				  cond.diameter, cond.diameter];
		if(cond.TF(state.trialID)==1)
			color=cond.currentColor(1,:);
		else
			color=cond.falseColor;
		end
		fillOval(rect, color);
		% draw center cross
		drawTexture(cross.tex,...
			[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
			[cross.width cross.height]);
		% transition to next phase
		if(toc>cond.responseDuration)
			tic;
			state.trialPhase=5;
		end
		
	% Phase5: inter-trial rest
	elseif(state.trialPhase==5)
		% transition to first phase
		if(toc>cond.restDuration)
			if(state.trialID+1>cond.numTotalTrial)
				state.scene=3;
				cond.response
			elseif(state.trialIDwithinBlock==size(cond.setsizeOrder,2)...
					|| cond.setsizeOrder(state.blockID, state.trialIDwithinBlock)==0)
				if(state.isInterblockRestTriggered && toc>cond.restDuration) % transition to next trial
					state.isInterblockRest=0;
					state.isInterblockRestTriggered=0;
					state.blockID=state.blockID+1;
					state.trialIDwithinBlock=1;
					state.trialPhase=1;
					state.trialID=state.trialID+1;
					% draw center cross
					drawTexture(cross.tex,...
						[scr.width/2-cross.width/2 scr.height/2-cross.width/2],...
						[cross.width cross.height]);
				elseif(state.isInterblockRestTriggered) % some pause
					
				else % participant is taking a rest
					state.isInterblockRest=1;
					Screen('DrawText', scr.window,...
						sprintf('Take a rest, please.'),...
						scr.width*0.3, scr.height*0.5, scr.textColor);
					Screen('DrawText', scr.window,...
						sprintf('Press space button to continue experiment.'),...
						scr.width*0.3, scr.height*0.5+30, scr.textColor);
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
	
	% background
	Screen('FillRect', scr.window, scr.BGColor);
	
	% text message
	Screen('DrawText', scr.window,...
		sprintf('Experiment has finished. Thank you for your time!'),...
		scr.width*0.3, scr.height*0.5, scr.textColor);
	
end






