include "globals.mzn";

% Input data
int: m;  % Number of couriers
int: n;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (dist[i,j] includes distance to depot)

% Decision variables
array[1..n] of var 1..m: item_to_courier; % Assign each item to a courier
array[1..m, 1..n+1] of var 1..n+1: x; % x[k, i] represents the next node that courier k visits from node i
array[1..m] of var 0..sum(D): distance_traveled; % Total distance traveled by each courier

% Constraints

% Ensure each item is assigned to exactly one courier and the load capacities are respected
constraint forall(k in 1..m) (
    sum(i in 1..n where item_to_courier[i] == k)(sj[i]) <= li[k]
);

% Constraints to create T as a set of Hamiltonian sub-cycles (or sub-circuits)
constraint forall(k in 1..m) (
    subcircuit(x[k,..])
);

% Calculate distance traveled by each courier
constraint forall(k in 1..m)(
    distance_traveled[k] = sum(i in 1..n+1)(D[i, x[k, i]])
);

% Deliverymen must start and end at the warehouse
constraint forall(k in 1..m) (
    sum(j in 2..n+1) (x[k, 1] == j) == 1 /\
    sum(i in 2..n+1) (x[k, i] == 1) == 1
);

% Ensure that if a courier visits a node, that node is assigned to the same courier
constraint forall(k in 1..m, i in 1..n, j in 1..n where i != j) (
    (item_to_courier[i] == k /\ item_to_courier[j] == k) -> x[k, i+1] == j+1
);

% Objective: minimize the maximum distance traveled by any courier
var 0..sum(D): max_distance;
constraint max_distance = max(distance_traveled);
solve minimize max_distance;

/*
% Upper and lower bound for total_distance
int: obj_lowerbound = max(i in 1..n)(D[n+1,i] + D[i,n+1]);

array[1..n] of int: max_dists = sort([max(j in 1..n)(D[i,j]) | i in 1..n]);
int: obj_upperbound = sum(i in m+1..n)(max_dists[i]) + max(j in 1..n)(D[n+1,j]) + max(j in 1..n)(D[j,n+1]);

% Objective: Minimize total distance
var obj_lowerbound..obj_upperbound:
var int: total_distance = sum(k in 1..m)(
  sum(i in 1..n+1 where x[k,i] != i) (
    D[i, x[k,i]]
  )
);
 */
% Output section
output [
  "Maximum distance traveled by any courier: ", show(max_distance), "\n",
  "Distances traveled by each courier: ", show(distance_traveled), "\n",
  "Courier routes:\n",
  concat([ "Courier " ++ show(k) ++ ": " ++ show([x[k, i] | i in 1..n+1]) ++ "\n" | k in 1..m])
];


