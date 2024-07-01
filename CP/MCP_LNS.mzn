include "globals.mzn";

% Input data
int: m;  % Number of couriers
int: n;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (dist[i,j] includes distance to depot)

% Decision variables
array[1..n] of var 1..m: item_to_courier; % Assign each item to a courier
array[1..m, 1..(n+1), 1..(n+1)] of var 0..1: routes; % Indicator if courier k visits location j (k, i, j)
array[1..m] of var 0..n: n_assigned; % Number of assigned items to each courier
array[1..m, 1..n+1] of var 0..1: is_visited; % Indicator if location j is visited by courier k
array[1..m] of var 0..10000: load; % Total load for each courier (assuming a reasonable upper bound)

% Total distance variable to minimize
var float: total_distance = sum(k in 1..m, i in 1..n, j in 1..n) (D[i+1,j+1] * routes[k,i,j]);

% Constraints
constraint
    % Each item is assigned to exactly one courier and no courier exceeds its load limit
    forall(k in 1..m) (
        load[k] == sum(i in 1..n) (if item_to_courier[i] == k then sj[i] else 0 endif)
    ) /\
    forall(k in 1..m) (
        load[k] <= li[k]
    );
        % items_to courier = [2, 1, 2]
        
constraint
    % Each courier starts and ends at the depot (1 is the depot)
    forall(k in 1..m) (
        sum(i in 2..n+1) (routes[k,1,i]) = 1 /\
        sum(i in 2..n+1) (routes[k,i,1]) = 1
    );

constraint
    % Each item must be visited by its assigned courier
    forall(i in 1..n) (
        sum(j in 1..n+1 where i+1 != j) (routes[item_to_courier[i], i+1, j]) == 1 /\
        sum(j in 1..n+1 where i+1 != j) (routes[item_to_courier[i], j, i+1]) == 1
    );
    %item 1
    %routes = (2, 2, 1)
    %routes = (2, 2, 3)
    %routes = (2, 2, 4)
    %item 2
    %routes = (1, 3, 1)
    %routes = (1, 3, 2)
    %routes = (1, 3, 4)
    %item 3
    %routes = (2, 4, 1)
    %routes = (2, 4, 2)
    %routes = (2, 4, 3)

   constraint
    % Ensure couriers only visit assigned items
    forall(k in 1..m, i in 1..n, j in 1..n) (
        routes[k, i, j] = 1 -> (
            (item_to_courier[i] == k \/ i == 1) /\  
            (item_to_courier[j] == k \/ j == 1)     
        )
    );
    % items_to courier = [2, 1, 2]
    %k=2 i = 1
    %routes[2, 1, 2]

constraint
    % Ensure that if a courier leaves a node, they must enter another, forming a valid route
    forall(k in 1..m, i in 2..n+1) (
        sum(j in 1..n+1 where i != j) (routes[k,i,j]) == 1 ->
        sum(j in 1..n+1 where i != j) (routes[k,j,i]) == 1
    );

% Objective: Minimize the total distance
solve minimize total_distance;

% Output the results
output [
    "Total Distance: ", show(total_distance), "\n",
    "Assignments:\n"
] ++ [ 
    "Deliveryman " ++ show(k) ++ ": " ++ show([i | i in 1..n where fix(item_to_courier[i]) == k]) ++ "\n" 
    | k in 1..m 
] ++ [
    "Routes:\n"
] ++ [
    "Deliveryman " ++ show(k) ++ ": " ++ show([j | j in 1..n where fix(routes[k, i, j]) == 1]) ++ "\n" 
    | k in 1..m, i in 1..n
];
