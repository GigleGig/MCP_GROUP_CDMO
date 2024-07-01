include "globals.mzn";

% Input data
int: m ;  % Number of couriers
int: n ;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (dist[i,j] includes distance to depot)

% Decision variables
array[1..n] of var 1..m: item_to_courier; % Assign each item to a courier
array[1..n+1, 1..n+1, 1..m] of var bool: x; % x[i,j,k] is true if courier k travels from item i to item j
array[1..m] of var int: load; % Total load for each courier

% Total distance variable to minimize
var float: total_distance = sum(k in 1..m, i in 1..n+1, j in 1..n+1) (D[i,j] * x[i,j,k]);

% Constraints
constraint
    % Each item is assigned to exactly one courier and no courier exceeds its load limit
    forall(k in 1..m) (
        load[k] = sum(i in 1..n where item_to_courier[i] = k) (sj[i])
    ) /\
    forall(k in 1..m) (
        load[k] <= li[k]
    );

constraint
    % Each item must be visited by its assigned courier
    forall(i in 1..n) (
        sum(j in 1..n+1 where i+1 != j) (x[i+1,j,item_to_courier[i]]) = 1 /\
        sum(j in 1..n+1 where i+1 != j) (x[j,i+1,item_to_courier[i]]) = 1
    );

constraint
    % Each courier starts and ends at the depot (1 is the depot)
    forall(k in 1..m) (
        sum(i in 2..n+1) (x[1,i,k]) = 1 /\
        sum(i in 2..n+1) (x[i,1,k]) = 1
    );

% Additional constraints to ensure valid routes
constraint
    % Ensure continuity in routes (subtour elimination)
    forall(k in 1..m, i in 1..n, j in 1..n where i != j) (
        x[i+1,j+1,k] + x[j+1,i+1,k] <= 1
    );

% Additional constraints for efficiency
constraint
    % Ensure load feasibility throughout the route
    forall(k in 1..m, i in 1..n) (
        sum(j in 1..n where j != i) (sj[i] * x[i+1,j+1,k]) <= li[k]
    );

% Objective: Minimize the total distance
solve :: int_search(item_to_courier, first_fail, indomain_min, complete) minimize total_distance;

% Output the results
output [
    "Total Distance: ", show(total_distance), "\n",
    "Assignments:\n"
] ++ [ 
    "Deliveryman " ++ show(k) ++ ": " ++ show([i | i in 1..n where fix(item_to_courier[i]) = k]) ++ "\n" 
    | k in 1..m 
] ++ [
    "Routes:\n"
] ++ [
    "Deliveryman " ++ show(k) ++ ": " ++ show([ (i, j) | i in 1..n+1, j in 1..n+1 where i != j /\ fix(x[i, j, k]) = 1 ]) ++ "\n" 
    | k in 1..m 
];
