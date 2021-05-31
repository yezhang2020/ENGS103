%% MMm registration
lambda=1/1.11;
mu=1/4;
m=8;
q=200;
denom_p0=0;
p=zeros(q+1,1);
for i=0:q
    if i<=m
        p(i+1)=1/factorial(i)*(lambda/mu)^i;
    else
        p(i+1)=1/(m^(i-m)*factorial(m))*(lambda/mu)^i;
    end
    denom_p0=denom_p0+p(i+1);
end
p0=1/denom_p0;
p=p*p0;
nn=0:1:q;
L=sum(p.*nn');
W=L/lambda;

%% MMn vaccination, with m registration, 0 queue capacity (no queue when n>5)
m=3;
n=5; % # of vaccination station
lambda=m/4;
mu=1/3;
dem_p0=0;
p=zeros(1,n);
for i=0:n
    p(i+1)=(lambda/mu)^i/factorial(i);
    dem_p0=dem_p0+p(i+1);
end
p0=1/dem_p0;
p=p*p0;

nn=0:1:n;
L=sum(p.*nn);
W=L/lambda;

%% MMn vaccination, with m registration, with infinite queue capacity
m=4;
n=7;
lambda=m/4;
mu=1/3;

q=200;
denom_p0=0;
p=zeros(q+1,1);
for i=0:q
    if i<=n
        p(i+1)=1/factorial(i)*(lambda/mu)^i;
    else
        p(i+1)=1/(n^(i-n)*factorial(n))*(lambda/mu)^i;
    end
    denom_p0=denom_p0+p(i+1);
end
p0=1/denom_p0;
p=p*p0;
nn=0:1:q;
L=sum(p.*nn');
W=L/lambda;
Wq=W-1/mu;
Lq=lambda*Wq;
