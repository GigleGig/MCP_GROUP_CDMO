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

minimize obj_max_distance:
    max_distance; # we want to minimize the max distance

subject to max_courier_distance{k in couriers}:
    max_distance >= courier_distance[k]; # define the max distance as the max among the couriers distances
subject to one_courier_per_item_start{i in objects}:
    sum{k in couriers, j in distances} X[k,i,j]=1; # one courier per item
subject to one_courier_per_item_end{j in objects}:
    sum{k in couriers, i in distances} X[k,i,j]=1; # one courier per item
subject to one_visit{k in couriers, i in objects}:
    X[k, i, i] = 0;
subject to one_object {k in couriers}: # at least one object per courier
    X[k,n+1,n+1]=0;
subject to continuative{k in couriers, i in objects}:
    sum{j in distances} X[k, j, i] = sum{j in distances} X[k, i, j];
subject to start_origin{k in couriers}:
    sum{j in objects} X[k, n+1, j]=1; # path must start at origin
subject to end_origin{k in couriers}:
    sum{i in objects} X[k, i, n+1]=1; # path must end at origin

subject to load_not_exceed_capacity{k in couriers}:
    sum{i in objects, j in distances} X[k,i,j] * s_values[i] <= l_values[k]; # the objects load must not exceed the capacity
subject to compute_distance{k in couriers}:
    courier_distance[k] = sum{i in distances, j in distances} distance_matrix[i, j] * X[k, i, j]; # to compute the distance of each courier

subject to first_location{k in couriers, j in objects}:
        succ[j] <= 1 + 2*n * (1-X[k,n+1,j]); # first location
subject to succ_location{k in couriers, i in objects, j in objects}:
        succ[i]-succ[j] >= 1 - 2*n * (1-X[k,j,i]); # successive location
          