function [ t , y ] = ode4( f , t_span , y_0 , h )

%Runge's method (fourth order)
%
%[ t , y ] = ode4_test( Fun , [0 xf] , [first_function;second_function] , h );
%
%'t' is the dependant variable value and 'y' is the corresponding output
%value
%
%-'dy_dt' must be a function of both the independant variable and the
% dependent variable (in the order) i.e. 'f=@(t,y)'
%
%-'t_span' is a two element row vector which takes in as the first input the
% starting time of the simulation and the end time as the second element
% i.e. t_span=[ t_start , t_end ]
%
%-'y_0' is the initial condition/s column vector (in order)
%
%-'step' is the desired step size

y(1:length(y_0),1:(t_span(2)-t_span(1))/h)=0;
y(1:length(y_0),1)=y_0;
t=t_span(1):h:t_span(2);

for i=1:length(t)-1
       
    y(:,i+1)=y(:,i)+h*f(t(i),y(:,i));
    k1 = f(t(i),y(:,i));
    k2 = f(t(i)+h/2,y(:,i)+h*k1/2);
    k3 = f(t(i)+h/2,y(:,i)+h*k2/2);
    k4 = f(t(i)+h,y(:,i)+h*k3);
    y(:,i+1)=y(:,i)+h*(k1+2*k2+2*k3+k4)/6;
    
end

end