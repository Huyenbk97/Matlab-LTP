function threshold()
	clear all;

	% import libht.core.*

	global scr;

	try
		% [scr.window, scr.rect]=setupScreen([0 0 600 400]);
		[scr.window, scr.rect]=setupScreen([0 0 1024 760]);
		while(quitByKey('ESCAPE'))
			draw();
		end
		resetEnvironment();
	catch
		resetEnvironment();
		psychrethrow(psychlasterror);
	end
end

function draw()
	import libht.wrap.*
	import libht.math.*

	global scr;

	threSample=230;
	showduration = 1;
	gridsize=20;
	X=scr.width/2-gridsize*2.5;
	Y=scr.height/2-gridsize*2.5;
	tempX=X;

	Screen('FillRect', scr.window, [255 255 255]);

	% Screen('FillRect', scr.window,[0 0 0], [100 0 150 50]);
	for i=1:25
		if (mod(i, 2)==1)
			Screen('FillRect', scr.window,[threSample threSample threSample], [X Y X+gridsize Y+gridsize]);
		else
			Screen('FillRect', scr.window,[255 255 255], [X Y X+gridsize Y+gridsize]);
		end
		X=X+gridsize;

		if (mod(i,5)==0)
			X=tempX;
			Y=Y+gridsize;
		end
	end

	Screen('Flip', scr.window);
end
