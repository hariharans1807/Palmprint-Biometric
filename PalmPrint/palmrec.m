%PALMPRINT IDENTIFICATION SYSTEM V3
%
% The images included are taken from CASIA Palmprint Database, available at
% http://www.cbsr.ia.ac.cn/PalmDatabase.htm
% See the cited references for more informations.
%
%
%
%  References:
%  Mongkon Sakdanupab, "A Fast and E?cient Palmprint Identi?cation Method
%  for a Large Database", available at
%  http://www.ecti-thailand.org/assets/papers/1224_pub_41.pdf
%
%  CASIA Palmprint Database is available at
%  http://www.cbsr.ia.ac.cn/PalmDatabase.htm
%
%
%
%
% 
% 
%
% 
%
% 
% 
% 
% 
% 
% 
% 
%
%
%

%--------------------------------------------------------------------
%clear;
function palmrec()
clc;
chos=0;
possibility=10;

messaggio='Insert the number of set: each set determins a class. This set should include a number of images for each person, with some variations in expression and in the lighting.';

while chos~=possibility,
    chos=menu('Palmprint Identification System','Select image','Add selected image to database','Database Info','Palmprint Identication (1:N match)','Palmprint Verification (1:1 match)',...
        'Feature Visualization','Delete Database','Info',...
        'Source code for Palmprint Identification System','Exit');
    %----------------
    if chos==1,
        clc;
        [namefile,pathname]=uigetfile('*.*','Select image');
        if namefile~=0
            [img,map]=imread(strcat(pathname,namefile));
            disp('Selected image: ');
            disp(strcat(pathname,namefile));
            disp(' ');
            imshow(img);
            dimensioni = size(img);
            if ndims(img)==3
                disp('Input image is RGB. It has been converted into grayscale.');
                img = rgb2gray(img);
                disp(' ');
            end
            disp('Palmprint segmentation in progress... please wait.');
            [img] = palmprintsegmentation(img);
            disp('Done.');
            
            disp('Feature encoding... please wait.');
            nscales=1;
            minWaveLength=18;
            mult=1; % not applicable if using nscales = 1
            sigmaOnf=0.5;
            [template,mask] = encode(img, nscales, minWaveLength, mult, sigmaOnf);
            disp('Done.');
            
            disp(' ');
            disp('Input image has been selected.');
            disp('Now press on "Add selected image to database" button to add this image to database or,');
            disp('press on "Palmprint Recognition" button to start palmprint matching.');
        else
            warndlg('Input image must be selected.',' Warning ')
        end
    end
    %----------------
    if chos==2,
        %clc;
        if exist('img')
            if (exist('palmprint_database.dat')==2)
                load('palmprint_database.dat','-mat');
                face_number=face_number+1;
                data{face_number,1}=img(:);
                prompt={strcat(messaggio,'Class number must be a positive integer <= ',num2str(max_class))};
                mytitle='Class number';
                lines=1;
                def={'1'};
                answer=inputdlg(prompt,mytitle,lines,def);
                zparameter=double(str2num(char(answer)));
                if size(zparameter,1)~=0
                    class_number=zparameter(1);
                    if (class_number<=0)||(class_number>max_class)||(floor(class_number)~=class_number)||(~isa(class_number,'double'))||(any(any(imag(class_number))))
                        warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                    else
                        if class_number==max_class;
                            max_class=class_number+1;
                        end
                        data{face_number,2}=class_number;
                        data{face_number,3}=strcat(pathname,namefile);
                        data{face_number,4}=template;
                        data{face_number,5}=mask;
                        save('palmprint_database.dat','data','face_number','max_class','-append');
                        msgbox(strcat('Database already exists: image succesfully added to class number ',num2str(class_number)),'Database result','help');
                        close all;
                        clear('img')
                    end
                else
                    warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                end
            else
                face_number=1;
                max_class=1;
                data{face_number,1}=img(:);
                prompt={strcat(messaggio,'Class number must be a positive integer <= ',num2str(max_class))};
                mytitle='Class number';
                lines=1;
                def={'1'};
                answer=inputdlg(prompt,mytitle,lines,def);
                zparameter=double(str2num(char(answer)));
                if size(zparameter,1)~=0
                    class_number=zparameter(1);
                    if (class_number<=0)||(class_number>max_class)||(floor(class_number)~=class_number)||(~isa(class_number,'double'))||(any(any(imag(class_number))))
                        warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                    else
                        max_class=2;
                        data{face_number,2}=class_number;
                        data{face_number,3}=strcat(pathname,namefile);
                        data{face_number,4}=template;
                        data{face_number,5}=mask;
                        save('palmprint_database.dat','data','face_number','max_class','dimensioni');
                        msgbox(strcat('Database was empty. Database has just been created. Image succesfully added to class number ',num2str(class_number)),'Database result','help');
                        close all;
                        clear('img')
                    end
                else
                    warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                end

            end
        else
            errordlg('No image has been selected.','File Error');
        end
    end
    %----------------
    if chos==3,
        clc;
        close all;
        clear('img');
        if (exist('palmprint_database.dat')==2)
            load('palmprint_database.dat','-mat');
            msgbox(strcat('Database has ',num2str(face_number),' image(s). There are',num2str(max_class-1),' class(es). Input images must have the same size.'),'Database result','help');
            L = size(data,1);
            disp('Images present in Database:');
            disp(' ');
            for ii=1:L
                disp('Location:');
                disp(data{ii,3});
                disp('Class number:');
                disp(data{ii,2});
                %disp(' - '); 
            end
        else
            msgbox('Database is empty.','Database result','help');
        end
    end
    %----------------
    if chos==4,
        clc;
        close all;
        if exist('img')
            ingresso=double(img(:));
            if (exist('palmprint_database.dat')==2)
                load('palmprint_database.dat','-mat');
                % face_number is equal to "M" of Turk's paper
                % i.e. the number of faces present in the database.
                % These image are grouped into classes. Every class (or set) should include
                % a number of images for each person, with some variations in expression and in the
                % lighting.
                template1 = template;
                mask1     = mask;
                
                MinDistace = Inf;
                for scan_db=1:size(data,1)
                    id2       = data{scan_db,2};
                    template2 = data{scan_db,4};
                    mask2     = data{scan_db,5}; 
                    
                    hd = gethammingdistance(template1, mask1, template2, mask2, nscales);
                    if hd<MinDistace
                        MinDistace = hd;
                        RecId  = id2;
                        RecPos = scan_db;
                    end
                end            
                



                %messaggio1='See Matlab Command Window to see matching result. The program has just calculated the minimal distance from classes and the distance from Palmprint Space. ';
                %messaggio2='You now should fix the two threshold-values to determine if this mathing is correct. If both distances are below the threshold values it means that the input ';
                %messaggio3='palmprint was correctly matched with a known palmprint. If the distance from Palmprint Space is below the threshold value but the minimal distance from classes is above the other threshold value, ';
                %messaggio4=' it means that the input image is an unknown palmprint. See the cited article for more informations.';

                %msgbox(strcat(messaggio1,messaggio2,messaggio3,messaggio4),'Matching result','help');
                disp('Input unknown image: ');
                disp(strcat(pathname,namefile));
                disp(' ');

                disp('The nearest class is number:');
                disp(RecId);
                disp('with a distance equal to:');
                disp(MinDistace);
                               
                disp('Recognized palmprint location: ');
                disp(data{RecPos,3});
                disp(' ');
            else
                warndlg('No image processing is possible. Database is empty.',' Warning ')
            end
        else
            warndlg('Input image must be selected.',' Warning ')
        end
    end
    %----------------
    if chos==5,
        clc;
        warning1 = 0;
        [namefile1,pathname1]=uigetfile('*.*','Select first image');
        if namefile1~=0
            [img1,map1]=imread(strcat(pathname1,namefile1));
            disp('Selected image: ');
            disp(strcat(pathname1,namefile1));
            disp(' ');
            if ndims(img1)==3
                disp('Input image is RGB. It has been converted into grayscale.');
                img1 = rgb2gray(img1);
                disp(' ');
            end
            disp('Palmprint segmentation in progress... please wait.');
            [img1] = palmprintsegmentation(img1);
            disp('Done.');            
            disp('Feature encoding... please wait.');
            nscales=1;
            minWaveLength=18;
            mult=1; % not applicable if using nscales = 1
            sigmaOnf=0.5;
            [template1,mask1] = encode(img1, nscales, minWaveLength, mult, sigmaOnf);
            disp('Done.');            
            disp(' ');            
        else
            warning1 = 1;
        end
        
        warning2 = 0;
        [namefile2,pathname2]=uigetfile('*.*','Select second image');
        if namefile2~=0
            [img2,map2]=imread(strcat(pathname2,namefile2));
            disp('Selected image: ');
            disp(strcat(pathname2,namefile2));
            disp(' ');
            if ndims(img2)==3
                disp('Input image is RGB. It has been converted into grayscale.');
                img2 = rgb2gray(img2);
                disp(' ');
            end
            disp('Palmprint segmentation in progress... please wait.');
            [img2] = palmprintsegmentation(img2);
            disp('Done.');            
            disp('Feature encoding... please wait.');
            nscales=1;
            minWaveLength=18;
            mult=1; % not applicable if using nscales = 1
            sigmaOnf=0.5;
            [template2,mask2] = encode(img2, nscales, minWaveLength, mult, sigmaOnf);
            disp('Done.');            
            disp(' ');            
        else
            warning2 = 1;
        end
        if warning1==0 && warning2==0
            hd = gethammingdistance(template1, mask1, template2, mask2, nscales);
            if hd<0.4
                mymessage = sprintf('%s','Status: RECOGNIZED');
                disp(mymessage);
                mymessage = sprintf('%s%s','Distance: ',num2str(hd));
                disp(mymessage);
            else
                mymessage = sprintf('%s','Status: NOT RECOGNIZED');
                disp(mymessage);
                mymessage = sprintf('%s%s','Distance: ',num2str(hd));
                disp(mymessage);
            end
        else
            warndlg('Select two images.',' Warning ')
        end
    end
    %----------------
    if chos==6,
        clc;
        [namefile,pathname]=uigetfile('*.*','Select image');
        if namefile~=0
            [img,map]=imread(strcat(pathname,namefile));
            disp('Selected image: ');
            disp(strcat(pathname,namefile));
            disp(' ');
            
            
            if ndims(img)==3
                disp('Input image is RGB. It has been converted into grayscale.');
                img = rgb2gray(img);
                disp(' ');
            end
            disp('Palmprint segmentation in progress... please wait.');
            [ROI] = palmprintsegmentation(img);
            disp('Done.');
            
            disp('Feature encoding... please wait.');
            nscales=1;
            minWaveLength=18;
            mult=1; % not applicable if using nscales = 1
            sigmaOnf=0.5;
            [template,mask] = encode(ROI, nscales, minWaveLength, mult, sigmaOnf);
            disp('Done.');
            
            figure,
            subplot(2,2,1),imshow(uint8(img)),title('Input image');
            subplot(2,2,2),imshow(uint8(ROI)),title('ROI image');  
            subplot(2,2,3),imshow(template),title('Encoded feature vector');
            subplot(2,2,4),imshow(mask),title('Binary mask');
        else
            warndlg('Input image must be selected.',' Warning ')
        end
    end
    %----------------
    if chos==7,
        clc;
        close all;
        if (exist('palmprint_database.dat')==2)
            button = questdlg('Do you really want to remove the Database?');
            if strcmp(button,'Yes')
                delete('palmprint_database.dat');
                msgbox('Database was succesfully removed from the current directory.','Database removed','help');
            end
        else
            warndlg('Database is empty.',' Warning ')
        end
    end
    %----------------
    if chos==8,
        clc;
        close all;
        helpwin readme;
    end
    %----------------
    if chos==9,
        clc;
        close all;
        web http://matlab-recognition-code.com/palmprint-recognition-system-matlab-full-source-code/
        helpwin sourcecode;
    end
    %----------------
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [out]=palmprintsegmentation(img)
%clc;clear;close all;
%perc_num  = '0078';
%perc_base = 'C:\HamdiFolder\progetti\palmprint\Palmprint Database\';
%cartella  = strcat(perc_base,perc_num);
%listafile = dir(strcat(cartella,'\','*.jpg'));
%nfile     = length(listafile);
%casuale   = round(nfile*rand(1));
%if casuale==0
%    casuale = 1;
%end
%percorso = strcat(perc_base,perc_num,'\',listafile(casuale).name);
%img      = imread(percorso);
%disp(percorso);


% percorso = 'C:\HamdiFolder\progetti\palmprint\Palmprint Database\0149\0149_m_r_03.jpg';
% img      = imread(percorso);
% disp(percorso);

[level EM] = graythresh(img);
BW         = im2bw(img,level);
[L,num]    = bwlabel(BW);

maxarea = -Inf;
Lmax    = 0;
for ii=1:num
    numero = length(find(L==ii));
    if numero>maxarea
        maxarea = numero;
        Lmax    = ii;
    end
end
ok = (L==Lmax);
%imshow(img.*uint8(ok))

s       = edge(double(ok),'canny',0.5,5);
thinned = bwmorph(s,'thin',Inf);
[x0,y0] = find(thinned);
L       = length(x0);
radius  = 70;
[dimx,dimy] = size(thinned);
matrice     = zeros(dimx,dimy);
for scanx=1:L
    xc  = x0(scanx);
    yc  = y0(scanx);

    x_s = max(1,xc-radius);
    x_e = min(dimx,xc+radius);
    y_s = max(1,yc-radius);
    y_e = min(dimy,yc+radius);

    for ii=x_s:x_e
        for jj=y_s:y_e
            if ok(ii,jj)
                r = sqrt((ii-xc)^2+(jj-yc)^2);
                if r<radius
                    matrice(xc,yc) = matrice(xc,yc)+1;
                end
            end
        end
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
nz       = 0;
glob_max = max(matrice(:));
my_thres = 0.7;
while nz<3
    zone     = matrice>my_thres*glob_max;
    zone     = imdilate(zone,strel('disk',2));
    [Lz,nz]  = bwlabel(zone);
    my_thres = my_thres-0.25;
end
%glob_max = max(matrice(:));
%zone     = matrice>0.7*glob_max;
%zone     = imdilate(zone,strel('disk',2));
%[Lz,nz]  = bwlabel(zone);
if nz<3
    error('Errore. Le zone di massimi relativi sono troppo poche.');
end
if nz==3
    x = [];
    y = [];
    for ii=1:nz
        pos         = find(Lz==ii);
        [vmax,pmax] = max(matrice(pos));
        mpos        = pos(pmax);
        [xm,ym]     = ind2sub(size(matrice),mpos);
        x           = [x;xm];
        y           = [y;ym];
    end
    %disp('3 punti');
    %imshow(img);
    %hold on,
    %for ii=1:3
    %    %[x,y]=ind2sub(size(matrice),pos_fin(ii));
    %    plot(y(ii),x(ii),'X');
    %end
    %hold off;


    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    y1 = y(1);
    y2 = y(2);
    y3 = y(3);
    % Trovo i punti estremi
    d12 = sqrt((x1-x2)^2+(y1-y2)^2);
    d13 = sqrt((x1-x3)^2+(y1-y3)^2);
    d23 = sqrt((x2-x3)^2+(y2-y3)^2);
    if (d12>d13) && (d12>d23)
        Ax = x1;
        Ay = y1;
        Bx = x2;
        By = y2;
    end
    if (d13>d12) && (d13>d23)
        Ax = x1;
        Ay = y1;
        Bx = x3;
        By = y3;
    end
    if (d23>d12) && (d23>d13)
        Ax = x2;
        Ay = y2;
        Bx = x3;
        By = y3;
    end
    
    %figure,imshow(img),hold on,
    %plot(Ay,Ax,'X'),...
    %    plot(By,Bx,'X'),...
    %    hold off;
end
if nz>=4
    vettore_massimi   = [];
    vettore_posizioni = [];
    for ii=1:nz
        pos         = find(Lz==ii);
        [vmax,pmax] = max(matrice(pos));
        mpos        = pos(pmax);

        vettore_massimi   = [vettore_massimi;vmax];
        vettore_posizioni = [vettore_posizioni;mpos];
    end
    [v_m_ord,indici] = sort(vettore_massimi,'descend');
    v_p_ord = vettore_posizioni(indici);

    pos_fin = v_p_ord(1:4);


    %disp('4 punti');
%     imshow(img);
%     hold on,
%     for ii=1:4
%         [x,y]=ind2sub(size(matrice),pos_fin(ii));
%         plot(y,x,'X');
%     end
%     hold off;

    [x,y]=ind2sub(size(matrice),pos_fin);


    max_temp = -Inf;
    v1memo   = 0;
    v2memo   = 0;
    v3memo   = 0;
    v4memo   = 0;

    v1     = 1;
    v2     = 2;
    v3     = 3;
    v4     = 4;
    p      = polyfit([x(v1) x(v2) x(v3)],[y(v1) y(v2) y(v3)],1);
    errore = p(1)*x(v4)+p(2)-y(v4);
    errore = abs(errore);
    %disp(errore);
    if errore>max_temp
        max_temp = errore;
        v1memo   = v1;
        v2memo   = v2;
        v3memo   = v3;
        v4memo   = v4;
    end

    v1     = 1;
    v2     = 2;
    v3     = 4;
    v4     = 3;
    p      = polyfit([x(v1) x(v2) x(v3)],[y(v1) y(v2) y(v3)],1);
    errore = p(1)*x(v4)+p(2)-y(v4);
    errore = abs(errore);
    %disp(errore);
    if errore>max_temp
        max_temp = errore;
        v1memo   = v1;
        v2memo   = v2;
        v3memo   = v3;
        v4memo   = v4;
    end

    v1     = 1;
    v2     = 3;
    v3     = 4;
    v4     = 2;
    p      = polyfit([x(v1) x(v2) x(v3)],[y(v1) y(v2) y(v3)],1);
    errore = p(1)*x(v4)+p(2)-y(v4);
    errore = abs(errore);
    %disp(errore);
    if errore>max_temp
        max_temp = errore;
        v1memo   = v1;
        v2memo   = v2;
        v3memo   = v3;
        v4memo   = v4;
    end

    v1     = 2;
    v2     = 3;
    v3     = 4;
    v4     = 1;
    p      = polyfit([x(v1) x(v2) x(v3)],[y(v1) y(v2) y(v3)],1);
    errore = p(1)*x(v4)+p(2)-y(v4);
    errore = abs(errore);
    %disp(errore);
    if errore>max_temp
        max_temp = errore;
        v1memo   = v1;
        v2memo   = v2;
        v3memo   = v3;
        v4memo   = v4;
    end

    x1 = x(v1memo);
    x2 = x(v2memo);
    x3 = x(v3memo);
    y1 = y(v1memo);
    y2 = y(v2memo);
    y3 = y(v3memo);
    % Trovo i punti estremi
    d12 = sqrt((x1-x2)^2+(y1-y2)^2);
    d13 = sqrt((x1-x3)^2+(y1-y3)^2);
    d23 = sqrt((x2-x3)^2+(y2-y3)^2);
    if (d12>d13) && (d12>d23)
        Ax = x1;
        Ay = y1;
        Bx = x2;
        By = y2;
    end
    if (d13>d12) && (d13>d23)
        Ax = x1;
        Ay = y1;
        Bx = x3;
        By = y3;
    end
    if (d23>d12) && (d23>d13)
        Ax = x2;
        Ay = y2;
        Bx = x3;
        By = y3;
    end
    
%     figure,imshow(img),hold on,
%     plot(Ay,Ax,'X'),...
%         plot(By,Bx,'X'),...
%         hold off;

%     figure,imshow(img),hold on,
%     plot(y(v1memo),x(v1memo),'X'),...
%         plot(y(v2memo),x(v2memo),'X'),...
%         plot(y(v3memo),x(v3memo),'X'),...
%         hold off
end

p = polyfit([Ax Bx],[Ay By],1);
% Y = p(1)*X + p(2)
% [dimx,dimy]  = size(matrice);
% disequazione = zeros(dimx,dimy);
% for ii=1:dimx
%     for jj=1:dimy
%         if ii*p(1)+p(2)<jj
%             disequazione(ii,jj) = 1;
%         end
%     end
% end
% figure,imshow(uint8(disequazione).*img)

STATS      = regionprops(double(ok),'Centroid');
baricentro = STATS.Centroid;
bary       = round(baricentro(1));
barx       = round(baricentro(2));
%figure,imshow(img),hold on,plot(bary,barx,'O'),hold off;

condizione = barx*p(1)+p(2)<bary;
% disp('Condizione');
% disp(condizione);

% Punto di mezzo
clx     = (Ax+Bx)/2;
cly     = (Ay+By)/2;
% Coefficienti retta
c_a     = p(1);
c_b     = p(2);
% Coefficienti retta perpendicolare che passa per il punto di mezzo
c_a_new = -1/c_a;
c_b_new = cly + 1/c_a*clx;

d   = 150;
t_a = 1+c_a_new^2;
t_b = -2*clx+2*(c_b_new-cly)*c_a_new;
t_c = clx^2+(c_b_new-cly)^2-d^2;

Px1 = (-t_b + sqrt(t_b^2-4*t_a*t_c))/(2*t_a);
Py1 = c_a_new*Px1+c_b_new;

Px2 = (-t_b - sqrt(t_b^2-4*t_a*t_c))/(2*t_a);
Py2 = c_a_new*Px2+c_b_new;

condizione_corrente = Px1*p(1)+p(2)<Py1;
if condizione == condizione_corrente
    Px = Px1;
    Py = Py1;
else
    Px = Px2;
    Py = Py2;
end

% figure,imshow(img),hold on,...
%     plot(round(Py),round(Px),'O'),...
%     plot(Ay,Ax,'X'),...
%     plot(By,Bx,'X'),...
%     hold off;

angolo      = atan(p(1));
[dimx,dimy] = size(matrice);
shiftx      = Px-dimx/2;
shifty      = Py-dimy/2;
shiftxnew   = shiftx*cos(angolo)+shifty*sin(angolo);
shiftynew   = -shiftx*sin(angolo)+shifty*cos(angolo);
imgnew      = imrotate(img,-rad2deg(atan(p(1))),'bilinear');

[dimxnew,dimynew] = size(imgnew);
Pxnew = shiftxnew+dimxnew/2;
Pynew = shiftynew+dimynew/2;
% figure,imshow(imgnew),hold on,...
%     plot(round(Pynew),round(Pxnew),'O'),...
%     hold off;

halfx = 141;
halfy = 141;
x0    = round(Pxnew);
y0    = round(Pynew);
croppedimage = imgnew(x0-halfx:x0+halfx,y0-halfy:y0+halfy);
%figure,imshow(croppedimage)
out = croppedimage;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------