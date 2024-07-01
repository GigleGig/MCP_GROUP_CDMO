include "globals.mzn";

% Input data
int: m;  % Number of couriers
int: n;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (dist[i,j] includes distance to depot)

% Decision variables
array[1..n] of var 1..m: item_to_courier; % Assign each item to a courier
array[1..n+1, 1..n+1, 1..m] of var bool: x; % x[i,j,k] is true if courier k travels from item i to item j
array[1..m] of var int: load; % Total load for each courier


% Total distance variable to minimize
var float: total_distance = sum(k in 1..m, i in 1..n+1, j in 1..n+1) (D[i,j] * x[i,j,k]);

% Auxiliary variables to store delivery paths
array[1..m] of var set of int: delivery_paths;

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
 
    
constraint forall (k in 1..m) (
    % Initialize the set for delivery_paths[k]
    delivery_paths[k] = {1} ++ { j |
        i, j in 2..n+1 where fix(x[i-1, j, k]) = 1
    } ++ {1} /\
    % Ensure consecutive pairs (i, j) satisfy the condition
    forall(idx in 2..card(delivery_paths[k])) (
        let {
            int: i = delivery_paths[k][idx - 1],
            int: j = delivery_paths[k][idx]
        } in
        (fix(x[i, j, k]) = 1 /\ i != j)
    )
);
  

% Objective: Minimize the total distance
solve :: int_search(item_to_courier, input_order, indomain_random, complete) minimize total_distance;

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
     "Deliveryman " ++ show(k) ++ ": " ++ show(delivery_paths[k]) ++ "\n"

    | k in 1..m 
];