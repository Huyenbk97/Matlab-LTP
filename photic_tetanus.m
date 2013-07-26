function photic_tetanus()
	clear all;

	import libht.core.*

	global scr;

	try
		[scr.window, scr.rect]=setupScreen([0 0 800 600]);
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

end


function update()
	global hfs_state;
end

function draw()
	import libht.wrap.*
	import libht.math.*

	global scr;
	global hfs_state;

	hfsScene();


	Screen('Flip', scr.window);
end

function hfsScene()
	import libht.wrap.*
	import libht.math.*

	global scr;
	global hfs_state;

	threSample=0;
	showduration = 1;
	hzduration = 0.11;
	gridsize=80;
	X=scr.width/2-gridsize*2.5;
	Y=scr.height/2-gridsize*2.5;
	tempX=X;


	Screen('FillRect', scr.window, [255 255 255]);

	if(hfs_state==1)

		tic;
		hfs_state =2

	elseif(hfs_state==2)
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
		if(toc>hzduration)
			tic;
			hfs_state =3;
		end

	elseif(hfs_state==3)
		for i=1:25
			if (mod(i, 2)==0)
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

		if(toc>hzduration)
			tic;
			hfs_state =2;
		end


	else
		hfs_state = 1;
	end

end
