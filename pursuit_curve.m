close all;
clear;
clc;
%diff(f(x))
GUI = {'Projectile Speed[m/s]: ' , 'Simulation Time[s]: ','Start Point[x]: ','Start Point[y]: ', 'Time Step: ' };
Title = 'Pursuit Curve';
lines = [1 50];
default_answer_1 = {'350','10','200','400','0.02'};
inputs_m = inputdlg(GUI,Title,lines,default_answer_1);
w = str2double(inputs_m{1});
h = str2double(inputs_m{5});
xf = str2double(inputs_m{2});
X_IN = str2double(inputs_m{3});
Y_IN = str2double(inputs_m{4});


question = questdlg('Please Select The Movement Type : ', 'Pursuit Curve','Straight Line','Next Page','Straight Line');
switch question
    case 'Straight Line'
        GUI={'Target Speed[m/s]: ','Start Point[x]: ', 'Start Point[y]: ' ,'Slope: '};
            Title='Persuit Curve';
            lines=[1 50];
            anss={'300','3000','1800','0'};
            inputs = inputdlg(GUI,Title,lines,anss);
            v = str2double(inputs{1});
            X = str2double(inputs{2});
            Y = str2double(inputs{3});
            slope = -str2double(inputs{4});
            T = @(t) (-v)*[cos(atan(slope))*t+X/(-v);sin(atan(slope))*t+Y/(-v)];
    
    case 'Next Page'
        question2 = questdlg('Please Select The Movement Type : ','Pursuit Curve','Circular Motion','Custom Function','Circular Motion');
        switch question2
            case 'Custom Function'
                %T = @(t)[-5*t + 40;20*(sin(0.5*pi*t).*sin(pi*t))]  w =20
                GUI={'Function: '};
                Title='Persuit Curve';
                lines=[1 50];
                anss={'[3500-300*t ; 1000 + 150*sin(2*t)]'};
                inputs = inputdlg(GUI,Title,lines,anss);
                T = str2func("@(t)"+anss{1});
                %T = @(t)[t*v*(cos(v*pi*t).*sin(pi*t)) + X;t*v*(sin(v*pi*t).*cos(pi*t))+Y];
                
            case 'Circular Motion'
                GUI={'Target Speed[m/s]: ','Rotation Center[x]: ', 'Rotation Center[y]: ' ,'Circle Radius: '};
                Title='Persuit Curve';
                lines=[1 50];
                anss={'200','2000','1000','500'};
                inputs = inputdlg(GUI,Title,lines,anss);
                v = str2double(inputs{1});
                X = str2double(inputs{2});
                Y = str2double(inputs{3});
                r = str2double(inputs{4});
                T = @(t) r*[cos(v/r*t)+X/r;sin(v/r*t)+Y/r];
            
        end
end

% Solving The Equation For the Movment
dpdt = @(t,p) (w*((T(t) - p)/(norm(T(t)-p))));
% change x,y in [0;0]
[ t , p ] = ode4( dpdt , [0 xf] , [X_IN;Y_IN] , h );
G = T(t(1));

L=3138; %length of runway
dx=3246-63; %difference in pixels between the two ends of the runway (X)
dy=474-2262; %difference in pixels between the two ends of the runway (Y)

theta=atan(dy/dx);

L_x=cos(theta)*L;
L_y=sin(theta)*L;

meter_per_pixel_x=L_x/dx;
meter_per_pixel_y=L_y/dy;

base=imread('image.jpg');
dim=size(base);

X_max=dim(2)*meter_per_pixel_x;
Y_max=dim(1)*meter_per_pixel_y;

figure('Units','normalized','Position',[0 0 1 1])

hold on

image([0 X_max],[Y_max 0],base)
axis([0 X_max 0 Y_max])
axis image
axis manual
% axis ≃ [3770;l930]

z = plot(p(1,1),p(2,1),'bo',G(1,1),G(2,1),'ro',p(1),p(2),'bs');
set(z(1),'MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','b');
set(z(2),'MarkerSize',7,'MarkerFaceColor','r','MarkerEdgeColor','k');
set(z(3),'MarkerSize',15,'MarkerFaceColor','b','MarkerEdgeColor','k');
xlabel('X-AXIS','Editing','off');
ylabel('Y-AXIS','Editing','off');
legend('Projectile','Target','Launch Site');
grid on;
hold off
%curve = animatedline(G(1),G(2),"Color",'r');
%curve2 = animatedline(p(1,1),p(2,1),"Color","white");

impact = 0;
X = 0;
Y = 0;


for i=1:length(t)
    G = T(t(i));
    set(z(1),'XData',p(1,i),'YData',p(2,i));
    set(z(2),'XData',G(1),'YData',G(2));
    %addpoints(curve,G(1),G(2));
    %addpoints(curve2,p(1,i),p(2,i));
    drawnow;
    if (norm(p(:,i)-G) <= 20)
        impact = 1;
        X = p(1,i);
        Y = p(2,i);
        break;
    end
end

if(impact == 1)
    set(z(2),'MarkerSize',15,'MarkerFaceColor','y','MarkerEdgeColor','r','Marker','p','LineWidth',1.75)
    set(z(1),'MarkerSize',10,'MarkerFaceColor','y','MarkerEdgeColor','r','Marker','h','LineWidth',1.8)
    d = dialog('Position',[800 300 350 150],'Name','Collision Information');
        txt1 = uicontrol('Parent',d,...
            'Style','text',...
            'Position',[40 70 250 30],...
            'String',['Collision Position(x,y) : ' ,'(',num2str(X),',',num2str(Y),')'],...
            'FontSize',10,...
            'Units', 'normalized');
        txt2 = uicontrol('Parent',d,...
            'Style','text',...
             'Position',[40 110 200 15],...
             'String',['Collision Time(seconds) : ','(',num2str(t(i)),')'],...
             'FontSize',10,...
             'Units','normalized');
        btn = uicontrol('Parent',d,...
            'Position',[140 20 70 25],...
            'String','Close',...
            'Callback','delete(gcf)');
else
    d = dialog('Position',[800 300 350 150],'Name','Collision Information');
        txt1 = uicontrol('Parent',d,...
            'Style','text',...
            'Position',[40 70 250 30],...
            'String',("The Projectile didn't hit the target in the simulation time"),...
            'FontSize',10,...
            'Units', 'normalized');
end



figure('Units','normalized','Position',[0 0 1 1])

subplot(1,2,1);
axis([-50 3800 -50 1940])
plot(p(1,1:i),p(2,1:i),'b');
title('Projectile movment');
xlabel('X-AXIS','Editing','off');
ylabel('Y-AXIS','Editing','off');
grid on;
target = T(t(1:i));
subplot(1,2,2)
plot(target(1,:),target(2,:),'r')
title('Target movment')
xlabel('X-AXIS','Editing','off');
ylabel('Y-AXIS','Editing','off');
grid on;
