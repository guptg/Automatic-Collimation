%% Collimation function to be used in the GUI 

function [X,ROIs,ArtHex,x_vertices,y_vertices] = collimate(coordinates,skel_img,bg_img) 
%Inputs: 
X = bg_img; %Background image to be collimated
img = skel_img; %Skeletonized image used for collimation 

%Outputs: 
%X is final collimated image 
%ROIs is used for manual selection 

%% Extracting coordinates from ROI test 
x_vertices = []; %Declaring an empty array to store all the x-coordinates of all 56 Hexagons 
y_vertices = []; %Declaring an empty array to store all the y-coordinates of all 56 Hexagons 

% The following loop rearranges the contents of the variable "coordinates"

for i = 1:length(coordinates)
    xcoordinates = coordinates{1,i}(1:2:12);
    x_vertices = [x_vertices ;xcoordinates]; %Returns a 56x6 array 
    ycoordinates = coordinates{1,i}(2:2:12); 
    y_vertices = [y_vertices ;ycoordinates]; %Returns a 56x6 array 
end 

%%
ROIs = {}; %Declaring an empty cell that will store a binary mask image for each Hexagon 
for i = 1:length(coordinates)
    c = x_vertices(i,:); %Extracting x-coordinates row by row as per iteration number and storing it into variable c 
    r = y_vertices(i,:); %Extracting y-coordinates row by row as per iteration number and storing it into variable r
    BW = roipoly(img,c,r);  %Creates a bunary mask (or Region of Interest) for as per coordinates defined in c and r 
    ROIs{i} = BW; %Stores the current mask in cell ROI 
end   
BinaryHexagons = {}; %Declaring an empty cell to contain all all 56 images each corresponding containing an area "cropped" by the masks in ROIs
cla reset; 
figure;
imshow(img); %gfc gets current figure from here 

for i = 1:length(coordinates) 
%     F = getframe(gca);
%     [X, Map] = frame2im(F);
    myImage = findall(gcf,'type','image');  
    set(myImage,'AlphaData',ROIs{i});  %Sets variable myImage to equal an image (graphics) defined by current iteration in ROI
    saveas(gcf,'hexagon1.jpg') %saves the graphics as a JPEG file so that it is composed of pixels and is a 3D matrix 
    T = imread('hexagon1.jpg'); %reads the saves image from files  
    BinaryHexagon = im2bw(T, 0.75); %Converts T "the extracted hexagonal image" into a binary image (0s and 1s 0: artery, 1: background)
    BinaryHexagons{i} = BinaryHexagon; %Stores binary image into the cell "BinaryHexagons" BinaryHexagons is now a cell containing 56 2D arrays 
end 

%Y = im2bw(img, 0.75); %Converting original 2D projection PNG file of the arteries into a binary image (will be used as a base on which regions are filled)
ArtHex = []; %This empty matrix will store all the index numbers coresponding to those hexagons that DO contain arteries 
%figure(3);%Displaying base image, hold on ensures regions are filled on top of this image 
size_Hex = size(BinaryHexagon); %Getting the dimensions of the hexagonal images T
%The following loop will detect which hexagon contains an artery 


for i=1:length(coordinates)
    flag = 0; %Useful to break out of second for loop in a nested for loop 
    for j = 1:size_Hex(1)  %Number of pixel rows in the images contained in "BinaryHexagons" 
        for k = 1:size_Hex(2) %Number of pixel columns in the images contained in "BinaryHexagons"
            c = x_vertices(i,:); %Extracting x-coordinates row by row as per iteration number and storing it into variable c 
            r = y_vertices(i,:); %Extracting y-coordinates row by row as per iteration number and storing it into variable r 
            if BinaryHexagons{i}(j,k) == 0  %Detecting an artery pixel in the hexagonal extracted image 
                X = hexa_modi(c,r,X,0.8);                
                ArtHex = [ArtHex i]; %Filling ArtHex with all the indices of hexagons that have arteries 
                flag = 1; %Setting condition to break out of second for loop 
                break;
            end
        end
        if (flag == 1) %Breaking out of nested for loop 
            break  
        end 
    end 
end

%The following loop displays the collimating hexagons in blue with the help
%of ArtHex

for i = 1:length(x_vertices)
    if (isempty(find(ArtHex==i)));  %If i is not in the array of non-collimating hexagons, returns empty array (if it finds it it returns a number) 
         c = x_vertices(i,:); %Extracts the x-coordinates of the hexagons that do not contain arteries 
         r = y_vertices(i,:); %Extracts the y-coordinates of the hexagons that do not contain arteries 
         X = hexa_modi(c,r,X,0.2);
%          l = fill(c,r, 'b'); %Fills coordinates c and r with blue       
%          alpha(l , 0.25); %Setting the translucency 
    end 
end


end