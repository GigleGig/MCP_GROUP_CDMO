param m >= 0 integer;  # number of couriers
param n >= 0 integer;  # number of objects

set couriers := {1..m};
set objects := {1..n};

param l_values{couriers} >= 0;  # max load of each courier
param s_values{objects} >= 0;   # size of each object

set distances := {1..n+1};  # n+1 is the origin
param distance_matrix{distances, distances} >= 0;

param upper_bound := distance_matrix[n+1,1] +
                          sum{i in 1..n-1} distance_matrix[i, i+1] +
                          distance_matrix[n, n+1];
param lower_bound := max {i in objects} (distance_matrix[n+1,i]+distance_matrix[i,n+1]);

var X{couriers, distances, distances} binary; # boolean that tells whether courier goes from one location to another
var succ{objects} >= 1, <= n integer; # sequence with the order of the visited locations

var courier_distance{couriers} >= 0 integer; # distance of each courier
var max_distance >= lower_bound, <= upper_bound integer;
var num_objects{couriers} >= 0 integer;

minimize obj_max_distance:
    max_distance; # we want to minimize the max distance

subject to max_courier_distance{i in couriers}:
    max_distance >= courier_distance[i]; # define the max distance as the max among the couriers distances
subject to one_courier_per_item_start{j in objects}:
    sum{i in couriers, k in distances} X[i,j,k]=1; # one courier per item
subject to one_courier_per_item_end{k in objects}:
    sum{i in couriers, j in distances} X[i,j,k]=1; # one courier per item
subject to one_visit{i in couriers, j in objects}:
    X[i, j, j] = 0;
subject to implied_constraint {i in couriers}: # at least one object per courier
    X[i,n+1,n+1]=0;
subject to continuative{i in couriers, j in objects}:
    sum{k in distances} X[i, k, j] = sum{k in distances} X[i, j, k];
subject to start_origin{i in couriers}:
    sum{k in objects} X[i, n+1, k]=1; # path must start at origin
subject to end_origin{i in couriers}:
    sum{j in objects} X[i, j, n+1]=1; # path must end at origin

subject to load_not_exceed_capacity{i in couriers}:
    sum{j in objects, k in distances} X[i,j,k] * s_values[j] <= l_values[i]; # the objects load must not exceed the capacity
subject to compute_distance{i in couriers}:
    courier_distance[i] = sum{j in distances, k in distances} distance_matrix[j, k] * X[i, j, k]; # to compute the distance of each courier

subject to first_location{i in couriers, k in objects}:
        succ[k] <= 1 + 2*n * (1-X[i,n+1,k]); # first location
subject to succ_location{i in couriers, j in objects, k in objects}:
        succ[j]-succ[k] >= 1 - 2*n * (1-X[i,k,j]); # successive location
          
subject to compute_num_objects{i in couriers}:
    num_objects[i] = sum{j in objects, k in distances} X[i, j, k];

param M := upper_bound;

subject to symmetry_breaking{i in 1..m-1}:
    courier_distance[i] <= courier_distance[i+1] + M * (num_objects[i+1] - num_objects[i]);



