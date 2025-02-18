function varargout = PalmPrint(varargin)
% PALMPRINT MATLAB code for PalmPrint.fig
%      PALMPRINT, by itself, creates a new PALMPRINT or raises the existing
%      singleton*.
%
%      H = PALMPRINT returns the handle to a new PALMPRINT or the handle to
%      the existing singleton*.
%
%      PALMPRINT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PALMPRINT.M with the given input arguments.
%
%      PALMPRINT('Property','Value',...) creates a new PALMPRINT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PalmPrint_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PalmPrint_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PalmPrint

% Last Modified by GUIDE v2.5 05-Nov-2014 13:06:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PalmPrint_OpeningFcn, ...
                   'gui_OutputFcn',  @PalmPrint_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PalmPrint is made visible.
function PalmPrint_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PalmPrint (see VARARGIN)

% Choose default command line output for PalmPrint
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PalmPrint wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PalmPrint_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global pathname;
global namefile;
global img;
global template;
global mask;
global nscales;
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
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global pathname;
global namefile;
global img;
global template;
global mask;
global nscales;
if exist('img')
            if (exist('palmprint_database.dat')==2)
                load('palmprint_database.dat','-mat');
                face_number=face_number+1;
                data{face_number,1}=img(:);
                prompt={strcat('Class number must be a positive integer <= ',num2str(max_class))};
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
                        
                        %clear('img')
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
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    global pathname;
global namefile;
global img;
global template;
global mask;
global nscales;
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
                set(handles.edit3,'String',RecId);
                disp('with a distance equal to:');
                disp(MinDistace);
                set(handles.edit4,'String',MinDistace);
                               
                disp('Recognized palmprint location: ');
                disp(data{RecPos,3});
                disp(' ');
            else
                warndlg('No image processing is possible. Database is empty.',' Warning ')
            end
        else
            warndlg('Input image must be selected.',' Warning ')
        end
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)

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
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)


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
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

 
        if (exist('palmprint_database.dat')==2)
            button = questdlg('Do you really want to remove the Database?');
            if strcmp(button,'Yes')
                delete('palmprint_database.dat');
                msgbox('Database was succesfully removed from the current directory.','Database removed','help');
            end
        else
            warndlg('Database is empty.',' Warning ')
        end
    
    %----------------
   
    %----------------
   
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit1.
function edit1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
