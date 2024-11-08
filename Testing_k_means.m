clc
close all

NB_POINTS = 20;
MAX_STEPS = 10;
RANDOM = true;
MIN_CENTER_DIST = 0;

points = ...
[ 8 -8;
  5 -7;
  9 -4;
  5 -9;
  7 -6;
  7 -9;
  8 -7;

  -8 8;
  -5 7;
  -9 4;
  -5 9;
  -7 6;
  -7 9;
  -8 7;
];

if RANDOM
    points = -10 + (20 * rand(NB_POINTS,2));
end

N = size(points,1);

%% Functions
function drawLine(point1, point2)
    plot([point1(1), point2(1)], [point1(2), point2(2)], '-k', 'LineWidth', 0.5);
    hold on;
end

function [d] = d1(p1,p2)
    d = norm(p2-p1);
end

function [g1,g2] = dissociate(points,n)
    N = size(points,1);
    ng1 = 1; ng2 = 1;
    g1 = zeros(N-n,2); g2 = zeros(n,2);
    
    for k=1:N
        if points(k,3) == 1
            g2(ng2,:) = points(k,1:2); ng2 = ng2+1;
        else
            g1(ng1,:) = points(k,1:2); ng1 = ng1+1;
        end
    end
end

function plot_points(points,centers)
    N = size(points,1);
    figure
    plot(centers(1,[1,3]), centers(1,[2,4]), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 10);
    hold on;
    plot(centers(2:end,1), centers(2:end,2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
    plot(centers(2:end,3), centers(2:end,4), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
    plot(centers(:,1), centers(:,2), '-r');
    plot(centers(:,3), centers(:,4), '-r');
    
    for m=1:N
        if points(m,3)==1
            plot(points(m,1), points(m,2), 'ko', 'MarkerFaceColor', 'g','LineWidth',0.5);
        else
            plot(points(m,1), points(m,2), 'ko', 'MarkerFaceColor', 'b','LineWidth',0.5);
        end
    end
    
    hold on;
    for j = 1:N
        if points(j,3)==1
            drawLine(centers(end,3:4),points(j,1:2));
        else
            drawLine(centers(end,1:2),points(j,1:2));
        end
    end
    grid on;
end

% Choose two random points as cluster centers
if RANDOM==false, rand('seed', 1); end
init_centers = -10 + (20 * rand(1,4));
while d1(init_centers(1,1:2),init_centers(1,3:4))<MIN_CENTER_DIST
    init_centers = -10 + (20 * rand(1,4));
end

centers = zeros(MAX_STEPS,4);
centers(1,:) = init_centers;

% Iterate Responsability
for i=1:MAX_STEPS
    n = 0;
    for j=1:N
        if d1(centers(i,3:4),points(j,1:2)) <= d1(centers(i,1:2),points(j,1:2))
            points(j,3) = 1;
            n = n+1;
        else
            points(j,3) = 0;
        end    
    end
    [g1,g2] = dissociate(points,n);
    
    if i<MAX_STEPS
        centers(i+1,1:2) = mean(g1);
        centers(i+1,3:4) = mean(g2);
    end

    if i>1
        if centers(i,1)==centers(i-1,1) && ...
           centers(i,2)==centers(i-1,2) && ...
           centers(i,3)==centers(i-1,3) && ...
           centers(i,4)==centers(i-1,4)
            fprintf('Convergence reached in %i steps', i-1);
            centers = centers(1:i-1,:);
            break;
        end
    end
end

% Plot results
plot_points(points,centers);
