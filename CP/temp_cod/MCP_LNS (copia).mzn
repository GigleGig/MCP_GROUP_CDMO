include "globals.mzn";

% Input data
int: m; % number of deliverymen
int: n; % number of items
array[1..m] of int: li; % maximum load each deliveryman can carry
array[1..n] of int: sj; % weight of each item
array[1..n+1, 1..n+1] of int: D; % distance matrix

% Decision variables
set of int: V = 1..n+1; % Set of all vertices (warehouse + items)
set of int: K = 1..m; % Set of deliverymen
array[K, V, V] of var 0..1: x; % x[k, i, j] = 1 if deliveryman k travels from i to j, 0 otherwise
array[K, V] of var 0..1: visited; % visited[k, i] = 1 if deliveryman k visits vertex i, 0 otherwise


% Constraints
/*
% Load constraints for each deliveryman
constraint forall(k in K) (
  sum(i in 2..n+1) (visited[k, i] * sj[i-1]) <= li[k]
);

% Subtour elimination constraints
array[K, 2..n+1] of var 1..n: u;
constraint forall(k in K, i in 2..n+1, j in 2..n+1 where i != j) (
  u[k, i] - u[k, j] + n * x[k, i, j] <= n - 1
);

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

% Prevent staying at the same place
constraint forall(k in K, i in V) (
  x[k, i, i] = 0
);

*/

% Upper and lower bounds

int: obj_lowerbound = sum(i in 1..n+1)(min(j in 1..n+1 where i != j)(D[i,j]));

int: dist_upperbound = sum(i in 1..n+1, j in 1..n+1) (D[i,j]);



% Objective: minimize the total distance traveled
var int: total_distance = sum(k in K, i in V, j in V) (D[i, j] * x[k, i, j]);
/*
constraint
    total_distance >= obj_lowerbound /\
    total_distance <= dist_upperbound; 

solve
    :: int_search([x[k, i, j] | k in K, i in V, j in V], input_order, indomain_min, complete)
    minimize total_distance;
*/
solve minimize total_distance;

% Output
output [
  "Total Distance: ", show(total_distance), "\n",
  "Assignments:\n"
  ]++[ 
  "Deliveryman " ++ show(k) ++ ": " ++ show([ i-1 | i in 2..n+1 where visited[k, i] == 1 ]) ++ "\n" 
  | k in 1..m 
  ]++[
  "Routes:\n"
  ]++[ 
  "Route of deliveryman " ++ show(k) ++ ": " ++ show([ (i-1, j-1) | i in V, j in V where x[k, i, j] == 1 ]) ++ "\n" 
  | k in 1..m  
  ];
