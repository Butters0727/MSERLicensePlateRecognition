function lp = lp_titlt(I)
gray=rgb2gray(I);
gray=edge(gray);
theta = 1:180;
[R,xp] = radon(gray,theta);
[gray,J] = find(R>=max(max(R)));                 
angle=90-J;
lp=imrotate(I,angle,'bilinear','crop'); 
