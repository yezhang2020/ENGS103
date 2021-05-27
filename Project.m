%% MM2 registration
lambda=1/3;
mu=1/5;
m=2;
q=25;
p=zeros(q,1);
p0=(1-lambda/(2*mu))/(1+lambda/(2*mu));
for i=1:q
    p(i)=2*(lambda/2/mu)^i*p0;
end
nn=1:1:25;
L=sum(p.*nn');
W=L/lambda;

%% MM3 registration
lambda=1/3;
mu=1/5;
m=3;
q=25;
p=zeros(q,1);
p0=1/(1+lambda/mu+0.5*(lambda/mu)^2*(1/(lambda/(3*mu))));
p(1)=lambda/mu*p0;
p(2)=lambda/(2*mu)*p(1);
for i=3:q
    p(i)=lambda/(3*mu)*p(i-1);
end
nn=1:1:25;
L=sum(p.*nn');
W=L/lambda;

%% MM5 vaccination, with 2 registration, 0 queue capacity?
lambda=1/(5*m);
mu=1/8;
n=5;
dem_p0=0;
p=zeros(1,n);
for i=0:n
    dem_p0=dem_p0+(lambda/mu)^i/factorial(i);
end
p0=1/dem_p0;
for i=1:n
    p(i)=(lambda/mu)^i/factorial(i)*p0;
end

nn=1:1:n;
L=sum(p.*nn);
W=L/lambda;