function color_random()
	color=[
			252;
			251;
			250;
			249;
			248;
			247;
			246;
			245;
			];

	tempList = zeros(1,24);
	j = 1;
	for i=1:24
		tempList(i) = j;
		if (mod(i,3) == 0)
			j = j + 1;
		end

	end
	listA = Shuffle(tempList);
	listB = Shuffle(tempList);

	randomList = horzcat(listA,listB);

	colorRandomList = zeros(1,48);
	for i=1:48
		colorRandomList(i) = color(randomList(i));	
	end
	colorRandomList

end
