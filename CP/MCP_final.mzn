include "globals.mzn";

% Input data
int: m;  % Number of couriers
int: n;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (D[i,j] includes distance to depot)

% Decision variables
set of int: couriers = 1..m;
set of int: items = 1..n;
set of int: nodes = 1..n+1;

array[couriers, nodes, nodes] of var 0..1: x; % x[k, i, j] == 1 if courier k travels from i to j
array[couriers, nodes] of var 0..1: visited; % visited[k, i] == 1 if courier k visits node i

% Constraints

% Each item must be visited exactly once
constraint forall(i in 1..nodes) (
  sum(k in couriers, j in nodes) (x[k, i, j]) = 1
);

% Ensure flow consistency for each deliveryman
constraint forall(k in couriers, i in nodes) (
  sum(j in nodes) (x[k, i, j]) = visited[k, i] /\
  sum(j in nodes) (x[k, j, i]) = visited[k, i]
);

% Deliverymen must start and end at the warehouse
constraint forall(k in couriers) (
  sum(j in nodes) (x[k, n+1, j]) = 1 /\
  sum(i in nodes) (x[k, i, n+1]) = 1
);

% Load constraints for each deliveryman
constraint forall(k in couriers) (
  sum(i in nodes) (visited[k, i] * sj[i]) <= li[k]
);

% Symmetry breaking constraint

% Subtour elimination constraints
array[couriers, nodes] of var 1..n: u;
constraint forall(k in couriers, i in nodes, j in nodes where i != j) (
  u[k, i] - u[k, j] + n * x[k, i, j] <= n - 1
);

% Objective function
var int: lower_bound = max(i in 1..n) (D[n+1, i] + D[i, n+1]);
int: obj_upperbound = D[n+1, 1] + sum(i in 1..n) (D[i, i+1]) + D[n, n+1];

var obj_lowerbound..obj_upperbound: max_route_length = max(k in couriers)(
    sum(i in nodes, j in nodes) (x[k, i, j] * D[i, j])
);

% Solving
solve minimize max_route_length;

% Output
output ["Distance: " ++ show(max_route_length) ++ "\n"] ++
       ["Deliveryman " ++ show(k) ++ ": " ++ show([i-1 | i in 2..n+1 where visited[k, i] = 1]) ++ "\n" | k in couriers];



