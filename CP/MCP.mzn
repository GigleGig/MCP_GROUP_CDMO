int: m;  % Number of deliverymen
int: n;  % Number of items
array[1..n+1, 1..n+1] of int: dist;  % Distance matrix (dist[i,j] includes distance to depot)
array[1..n] of int: weight;  % Weights of items (integer type)
array[1..m] of int: weight_limit;  % Weight limits of deliverymen (integer type)

% Decision variable: x[i,j,k] is true if deliveryman k travels from item i to item j
array[1..n+1, 1..n+1, 1..m] of var bool: x;

% Decision variable: load[k] is the total weight carried by deliveryman k
array[1..m] of var int: load;

% Total distance variable to minimize
var float: total_distance = sum(k in 1..m, i in 1..n+1, j in 1..n+1) (dist[i,j] * x[i,j,k]);

% Constraints
constraint
    % Each item is visited exactly once
    forall(i in 1..n) (
        sum([x[i,j,k] | k in 1..m, j in 1..n+1 where i != j]) = 1
    );

constraint
    % Each deliveryman starts and ends at the depot (n+1 is the depot)
    forall(k in 1..m) (
        sum(i in 1..n) (x[n+1,i,k]) = 1
    ) /\
    forall(k in 1..m) (
        sum(j in 1..n) (x[j,n+1,k]) = 1
    );

constraint
    % Load constraint for each deliveryman
    forall(k in 1..m) (
        load[k] = sum([weight[i] * x[i,j,k] | i in 1..n, j in 1..n+1 where i != j]) /\
        load[k] <= weight_limit[k]
    );

constraint
    % Flow constraints to ensure continuity of the route
    forall(k in 1..m, i in 1..n) (
        sum([x[i,j,k] | j in 1..n+1 where i != j]) = sum([x[j,i,k] | j in 1..n+1 where i != j])
    );

% Objective: Minimize the total distance
solve minimize total_distance;


% Output the results
output [
    "Total Distance: ", show(total_distance), "\n",
    "Routes:\n"
] ++
["Deliveryman " ++ show(k) ++ ": " ++ show([ (i, j) | i in 1..n+1, j in 1..n+1 where i != j /\ fix(x[i, j, k]) = 1 ]) ++ "\n" | k in 1..m];

