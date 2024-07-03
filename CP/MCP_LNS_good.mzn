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
array[1..m, 1..n] of var 0..n+1: delivery_paths_i;
array[1..m, 1..n] of var 0..n+1: delivery_paths_j;

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
 

constraint    
    % Define delivery_paths as sets of tuples (i, j)
    forall(k in 1..m, i in 1..n, j in 1..n) (
        if x[i, j, k] == 1 then
            delivery_paths_i[k, i] = i /\
            delivery_paths_j[k, i] = j
        else
            true
        endif
    );

constraint
    % Check format of the delivery_paths
    forall(k in 1..m) (
        let {
            int: path_length = sum(i in 1..n) (delivery_paths_i[k, i] != 0)
        } in
        if path_length > 0 then
            % First element of the first tuple must be 1
            delivery_paths_i[k, 1] = 1 /\
            % Last element of the last tuple must be 1
            delivery_paths_j[k, path_length] = 1 /\
            % Check sequential correctness
            forall(i in 1..path_length-1) (
                delivery_paths_j[k, i] = delivery_paths_i[k, i+1]
            )
        else
            true
        endif
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
    "Deliveryman " ++ show(k) ++ ": " ++ show([(fix(delivery_paths_i[k, i]), fix(delivery_paths_j[k, i])) | i in 1..n where fix(delivery_paths_i[k, i])!= 0]) ++ "\n"
    | k in 1..m
];