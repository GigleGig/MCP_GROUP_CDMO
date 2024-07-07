include "globals.mzn";

% Input data
int: m;  % Number of couriers
int: n;  % Number of items
array[1..m] of int: li; % Maximum load for each courier
array[1..n] of int: sj; % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix (D[i,j] includes distance to depot)

% Decision variables
set of int: V = 1..n+1; % Set of all vertices (warehouse + items)
set of int: K = 1..m; % Set of deliverymen
array[K, V, V] of var 0..1: x; % x[k, i, j] = 1 if deliveryman k travels from i to j, 0 otherwise
array[K, V] of var 0..1: visited; % visited[k, i] = 1 if deliveryman k visits vertex i, 0 otherwise

% Variable for the distance traveled by each deliveryman
array[K] of var 0..sum(D): distance;

% Constraints

% Each item must be visited exactly once
constraint forall(i in 2..n+1) (
  sum(k in K) (sum(j in V where j != i) (x[k, i, j])) = 1
);

% Ensure flow consistency for each deliveryman
constraint forall(k in K, i in V) (
  sum(j in V) (x[k, i, j]) = visited[k, i] /\
  sum(j in V) (x[k, j, i]) = visited[k, i]
);

% Deliverymen must start and end at the warehouse
constraint forall(k in K) (
  sum(j in 2..n+1) (x[k, 1, j]) = 1 /\
  sum(i in 2..n+1) (x[k, i, 1]) = 1
);

% Load constraints for each deliveryman
constraint forall(k in K) (
  sum(i in 2..n+1) (visited[k, i] * sj[i-1]) <= li[k]
);

% Symmetry breaking constraint

% Subtour elimination constraints
array[K, 2..n+1] of var 1..n: u;
constraint forall(k in K, i in 2..n+1, j in 2..n+1 where i != j) (
  u[k, i] - u[k, j] + n * x[k, i, j] <= n - 1
);

% Calculate the distance traveled by each deliveryman
constraint forall(k in K) (
  distance[k] = sum(i in V, j in V) (x[k, i, j] * D[i, j])
);

% Objective: minimize the maximum distance traveled by any deliveryman
var 0..sum(D): max_route_length;
constraint max_route_length = max(distance);
% Solving
solve minimize max_route_length;

% Output
output ["Distance: " ++ show(max_route_length) ++ "\n"] ++
       ["Deliveryman " ++ show(k) ++ ": " ++ show([i-1 | i in 2..n+1 where visited[k, i] = 1]) ++ "\n" | k in K];

