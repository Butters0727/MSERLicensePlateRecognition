classdef LPRec_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        LicensePlateRecgonitionUIFigure  matlab.ui.Figure
        OriAxes               matlab.ui.control.UIAxes
        SegAxes_3             matlab.ui.control.UIAxes
        SegAxes_4             matlab.ui.control.UIAxes
        SegAxes_5             matlab.ui.control.UIAxes
        SegAxes_6             matlab.ui.control.UIAxes
        SegAxes_2             matlab.ui.control.UIAxes
        SegAxes_1             matlab.ui.control.UIAxes
        SegAxes_7             matlab.ui.control.UIAxes
        LoadImageButton       matlab.ui.control.Button
        ApplyButton           matlab.ui.control.Button
        OutputEditFieldLabel  matlab.ui.control.Label
        OutputEditField       matlab.ui.control.EditField
        SegmentationLabel     matlab.ui.control.Label
        LcAxes                matlab.ui.control.UIAxes
        MSERAxes              matlab.ui.control.UIAxes
        LocateLabel           matlab.ui.control.Label
        MSERRegionsLabel      matlab.ui.control.Label
    end

    
    properties (Access = public)
        img
    end
    
    methods (Access = private)
        
        function updateimage(app,imagefile)
            try
                app.img = imread(imagefile);
            catch ME
                % If problem reading image, display error message
                uialert(app.LicensePlateRecgonitionUIFigure, ME.message, 'Image Error');
                return;
            end
            imagesc(app.OriAxes,app.img);
        end
        
        function lp = lp_detect(~,I)
            Image = I;              %ÿÿRGBÿÿ
            Image=im2double(Image); %ÿÿÿÿÿ ÿÿÿÿ
            I=rgb2hsv(Image);       %RGBÿÿÿÿhsvÿÿ
            [y,x,z]=size(I);        %%y x z ÿÿRGBÿÿÿÿÿÿÿÿÿ ÿ ÿ
            Blue_y = zeros(y, 1);
            p=[0.56 0.71 0.4 1 0.3 1 0];
            for i = 1 : y
                for j = 1 : x
                    hij = I(i, j, 1);
                    sij = I(i, j, 2);
                    vij = I(i, j, 3);
                    if (hij>=p(1) && hij<=p(2)) &&( sij >=p(3)&& sij<=p(4))&&...
                            (vij>=p(5)&&vij<=p(6))
                        Blue_y(i, 1) = Blue_y(i, 1) + 1;  %ÿÿÿÿÿÿÿ
                    end
                end
            end
            [~, MaxY] = max(Blue_y);  %ÿÿÿ
            Th = p(7);
            PY1 = MaxY;
            while ((Blue_y(PY1,1)>Th) && (PY1>0))
                PY1 = PY1 - 1;
            end
            PY2 = MaxY;
            while ((Blue_y(PY2,1)>Th) && (PY2<y))
                PY2 = PY2 + 1;
            end
            PY1 = PY1 - 2;
            PY2 = PY2 + 2;
            if PY1 < 1
                PY1 = 1;
            end
            if PY2 > y
                PY2 = y;
            end
            bw=Image(PY1:PY2,:,:);
            IY = I(PY1:PY2, :, :);
            I2=im2bw(IY,0.5);
            
            [y1,x1,z1]=size(IY);
            Blue_x=zeros(1,x1);
            for j = 1 : x1
                for i = 1 : y1
                    hij = IY(i, j, 1);
                    sij = IY(i, j, 2);
                    vij = IY(i, j, 3);
                    if (hij>=p(1) && hij<=p(2)) &&( sij >=p(3)&& sij<=p(4))&&...
                            (vij>=p(5)&&vij<=p(6))
                        Blue_x(1, j) = Blue_x(1, j) + 1;
                        %              bw1(i, j) = 1;
                    end
                end
            end
            PY1;PY2;
            
            [~, MaxX] = max(Blue_x);
            Th = p(7);
            PX1 = MaxX;
            
            while ((Blue_x(1,PX1)>Th) && (PX1>0))
                PX1 = PX1 - 1;
            end
            PX2 = MaxX;
            while ((Blue_x(1,PX2)>Th) && (PX2<x1))
                PX2 = PX2 + 1;
            end
            Picture=Image(PY1:PY2,PX1:PX2,:);
            lp = Picture;
        end
        
        function lp = lp_titlt(~,I)
            gray=rgb2gray(I);
            gray=edge(gray);
            theta = 1:180;
            [R,xp] = radon(gray,theta);
            [gray,J] = find(R>=max(max(R)));                 %Jÿÿÿÿÿÿ
            angle=90-J;
            lp=imrotate(I,angle,'bilinear','crop'); %ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿÿÿÿÿ
        end
        
        function mserRegions = detectMSER(~,I)
            mserRegions = detectMSERFeatures(I, ...
                'RegionAreaRange',[50 8000],'ThresholdDelta',4);
        end
        
        function [p_image,cwidth,seg_img_color] = conComp_analysis(app,bwimg,colorImg)
            [x,y]=size(bwimg);
            j=1;
            cwidth=[];
            whole=x*y;
            connComp = bwconncomp(bwimg); % Find connected components
            threefeature = regionprops(connComp,'Area','BoundingBox','Centroid');
            broder=[threefeature.BoundingBox];%[x y width height]ÿÿÿÿÿ
            area=[threefeature.Area];%ÿÿÿÿ
            centre=[threefeature.Centroid];
            %area
            for i=1:connComp.NumObjects
                leftx=broder((i-1)*4+1);
                lefty=broder((i-1)*4+2);
                width=broder((i-1)*4+3);
                height=broder((i-1)*4+4);
                cenx=floor(centre((i-1)*2+1));
                ceny=floor(centre((i-1)*2+2));
                
                if area(i)<10||area(i)>0.3*whole
                    %display(area(i));
                    bwimg(connComp.PixelIdxList{i})=0;
                elseif width/height<0.1||width/height>2
                    %display(width),display(height);
                    bwimg(connComp.PixelIdxList{i})=0;
                else
                    cwidth=[cwidth,width];
                    rectangle(app.MSERAxes,'Position',[leftx,lefty,width,height], 'EdgeColor','g');
                    seg_img_color{j}=colorImg(lefty+1:lefty+height,leftx+1:leftx+width,:); % +1 ÿÿÿÿÿ0
                    j=j+1;
                end
            end
            p_image=bwimg;
            
        end
        
        function [rec,seg_img_color] = f_conComp_analysis(app,P_image,colorImg)
            [x,y]=size(P_image);
            whole=x*y;
            j=1;
            rec=[];
            connComp = bwconncomp(P_image); % Find connected components
            threefeature = regionprops(connComp,'Area','BoundingBox');
            
            broder=[threefeature.BoundingBox];%[x y width height]ÿÿÿÿÿ
            area=[threefeature.Area];%ÿÿÿÿ
            for i=1:connComp.NumObjects
                leftx=floor(broder((i-1)*4+1));
                lefty=floor(broder((i-1)*4+2));
                width=broder((i-1)*4+3);
                height=broder((i-1)*4+4);
                %    data=grayimg_reserve(lefty:lefty+height-1,leftx:leftx+width-1);
                %    stda(i,:)=statxture(data);
                if area(i)<300||area(i)>whole*0.4
                    P_image(connComp.PixelIdxList{i})=0;
                    %     elseif width/height>2
                    %         P_image(connComp.PixelIdxList{i})=0;
                else
                    rect=[leftx,lefty,width,height];
                    rec=[rec;rect];
                    rectangle(app.MSERAxes,'Position',[leftx,lefty,width,height], 'EdgeColor','g');
                    seg_img_color{j}=colorImg(lefty+1:lefty+height,leftx+1:leftx+width,:); % +1 ÿÿÿÿÿ0
                    j=j+1;
                end
            end
            pp_image=P_image;
            
        end
        
        function characters = LicPlateRec(~,character_image)
            characters = '';
            lib1 = 'ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ';
            lib2 = '1234567890ABCDEFGHJKLMNPQRSTUVWXYZ';
            
            temp_char = character_image{1};
            temp_char = temp_char(:)';
            load('hanzi_theta1.mat');
            load('hanzi_theta2.mat');
            characters = strcat(characters, recognise(hanzi_theta1, hanzi_theta2, temp_char, lib1));
            
            load('theta1.mat');
            load('theta2.mat');
            for i = 2:7
                temp_char = character_image{i};
                temp_char = temp_char(:)';
                characters = strcat(characters, recognise(Theta1, Theta2, temp_char, lib2));
            end
        end
        
        function ch = recognise(~,Theta1, Theta2, X, lib)
            m = size(X, 1);
            
            h1 = sigmoid([ones(m, 1) X] * Theta1');
            h2 = sigmoid([ones(m, 1) h1] * Theta2');
            [~, p] = max(h2, [], 2);
            
            ch = lib(p);
        end
        
        function g = sigmoid(~,z)
            g = 1.0 ./ (1.0 + exp(-z));
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Configure image axes
            app.OriAxes.Visible = 'off';
            app.OriAxes.Colormap = gray(256);
            axis(app.OriAxes, 'image');
            
            % Update the image and histograms
            updateimage(app, 'test1.jpg');
        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)
            filterspec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
                fname = [p f];
                updateimage(app, fname);
            end
        end

        % Button pushed function: ApplyButton
        function ApplyButtonPushed(app, event)
            lp_color = lp_detect(app,app.img);
            lp_color = lp_titlt(app,lp_color);
            app.LcAxes.Visible = 'off';
            imagesc(app.LcAxes,lp_color);
            
            lp_bw = im2bw(lp_color);
            lp_bw = bwareaopen(lp_bw, 10);
            lp_bw = imclearborder(lp_bw,4);
            mserRegions = detectMSER(app,lp_bw);
            
            mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
            mserMask = false(size(lp_bw));
            ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
            mserMask(ind) = true;
            
            app.MSERAxes.Visible = 'off';
            imshow(mserMask,'Parent',app.MSERAxes);
            
            [p_image,cwidth,img_color] =conComp_analysis(app,mserMask,lp_color);
            
            if length(img_color)>7 %prevent over connected
                
                imshow(mserMask,'Parent',app.MSERAxes);
                wi= median(cwidth(:))/2;
                se1=strel('line',wi,0);
                p_image_dilate= imclose(p_image,se1);
                
                [rec_word,img_color]=f_conComp_analysis(app,p_image_dilate,lp_color);
            end
            
            for i = 1:7
                img_color{i}=imresize(img_color{i},[32,16],'nearest');
                img_bw{i}=im2bw(img_color{i},graythresh(img_color{i}));
            end
            
            app.SegAxes_1.Visible = 'off';
            imshow(img_bw{1},'Parent',app.SegAxes_1);
            app.SegAxes_2.Visible = 'off';
            imshow(img_bw{2},'Parent',app.SegAxes_2);
            app.SegAxes_3.Visible = 'off';
            imshow(img_bw{3},'Parent',app.SegAxes_3);
            app.SegAxes_4.Visible = 'off';
            imshow(img_bw{4},'Parent',app.SegAxes_4);
            app.SegAxes_5.Visible = 'off';
            imshow(img_bw{5},'Parent',app.SegAxes_5);
            app.SegAxes_6.Visible = 'off';
            imshow(img_bw{6},'Parent',app.SegAxes_6);
            app.SegAxes_7.Visible = 'off';
            imshow(img_bw{7},'Parent',app.SegAxes_7);
            
            characters = LicPlateRec(app,img_bw);
            app.OutputEditField.Value = characters;
            %disp(characters);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create LicensePlateRecgonitionUIFigure and hide until all components are created
            app.LicensePlateRecgonitionUIFigure = uifigure('Visible', 'off');
            app.LicensePlateRecgonitionUIFigure.Position = [100 100 760 524];
            app.LicensePlateRecgonitionUIFigure.Name = 'License Plate Recgonition';
            app.LicensePlateRecgonitionUIFigure.Resize = 'off';

            % Create OriAxes
            app.OriAxes = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.OriAxes.BoxStyle = 'full';
            app.OriAxes.XTick = [];
            app.OriAxes.XTickLabel = {'[ ]'};
            app.OriAxes.YTick = [];
            app.OriAxes.Position = [11 226 448 289];

            % Create SegAxes_3
            app.SegAxes_3 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_3.XTick = [];
            app.SegAxes_3.XTickLabel = {'[ ]'};
            app.SegAxes_3.YTick = [];
            app.SegAxes_3.Position = [323 116 46 69];

            % Create SegAxes_4
            app.SegAxes_4 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_4.XTick = [];
            app.SegAxes_4.XTickLabel = {'[ ]'};
            app.SegAxes_4.YTick = [];
            app.SegAxes_4.Position = [383 116 46 69];

            % Create SegAxes_5
            app.SegAxes_5 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_5.XTick = [];
            app.SegAxes_5.XTickLabel = {'[ ]'};
            app.SegAxes_5.YTick = [];
            app.SegAxes_5.Position = [438 116 46 69];

            % Create SegAxes_6
            app.SegAxes_6 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_6.XTick = [];
            app.SegAxes_6.XTickLabel = {'[ ]'};
            app.SegAxes_6.YTick = [];
            app.SegAxes_6.Position = [496 116 46 69];

            % Create SegAxes_2
            app.SegAxes_2 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_2.XTick = [];
            app.SegAxes_2.XTickLabel = {'[ ]'};
            app.SegAxes_2.YTick = [];
            app.SegAxes_2.Position = [267 116 46 69];

            % Create SegAxes_1
            app.SegAxes_1 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_1.XTick = [];
            app.SegAxes_1.XTickLabel = {'[ ]'};
            app.SegAxes_1.YTick = [];
            app.SegAxes_1.Position = [212 116 46 69];

            % Create SegAxes_7
            app.SegAxes_7 = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.SegAxes_7.XTick = [];
            app.SegAxes_7.XTickLabel = {'[ ]'};
            app.SegAxes_7.YTick = [];
            app.SegAxes_7.Position = [553 116 46 69];

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.LicensePlateRecgonitionUIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [553 276 115 37];
            app.LoadImageButton.Text = 'Load Image';

            % Create ApplyButton
            app.ApplyButton = uibutton(app.LicensePlateRecgonitionUIFigure, 'push');
            app.ApplyButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyButtonPushed, true);
            app.ApplyButton.Position = [553 226 115 37];
            app.ApplyButton.Text = 'Apply';

            % Create OutputEditFieldLabel
            app.OutputEditFieldLabel = uilabel(app.LicensePlateRecgonitionUIFigure);
            app.OutputEditFieldLabel.HorizontalAlignment = 'right';
            app.OutputEditFieldLabel.FontSize = 18;
            app.OutputEditFieldLabel.Position = [273 50 59 22];
            app.OutputEditFieldLabel.Text = 'Output';

            % Create OutputEditField
            app.OutputEditField = uieditfield(app.LicensePlateRecgonitionUIFigure, 'text');
            app.OutputEditField.HorizontalAlignment = 'center';
            app.OutputEditField.FontSize = 18;
            app.OutputEditField.Position = [347 46 100 25.8000011444092];

            % Create SegmentationLabel
            app.SegmentationLabel = uilabel(app.LicensePlateRecgonitionUIFigure);
            app.SegmentationLabel.FontSize = 15;
            app.SegmentationLabel.Position = [111 139 102 22];
            app.SegmentationLabel.Text = 'Segmentation:';

            % Create LcAxes
            app.LcAxes = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.LcAxes.XTick = [];
            app.LcAxes.XTickLabel = {'[ ]'};
            app.LcAxes.YTick = [];
            app.LcAxes.Position = [510 436 202 79];

            % Create MSERAxes
            app.MSERAxes = uiaxes(app.LicensePlateRecgonitionUIFigure);
            app.MSERAxes.XTick = [];
            app.MSERAxes.XTickLabel = {'[ ]'};
            app.MSERAxes.YTick = [];
            app.MSERAxes.Position = [510 343 202 79];

            % Create LocateLabel
            app.LocateLabel = uilabel(app.LicensePlateRecgonitionUIFigure);
            app.LocateLabel.Position = [590 421 42 22];
            app.LocateLabel.Text = 'Locate';

            % Create MSERRegionsLabel
            app.MSERRegionsLabel = uilabel(app.LicensePlateRecgonitionUIFigure);
            app.MSERRegionsLabel.Position = [567 322 87 22];
            app.MSERRegionsLabel.Text = 'MSER Regions';

            % Show the figure after all components are created
            app.LicensePlateRecgonitionUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = LPRec_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.LicensePlateRecgonitionUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.LicensePlateRecgonitionUIFigure)
        end
    end
end