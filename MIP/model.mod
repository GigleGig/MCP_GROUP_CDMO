param m >= 0 integer;
param n >= 0 integer;

set courier := {1..m}; # courier maximum load
set object := {1..n}; # object sizes

param l_values{courier} >= 0;

param s_values{object} >= 0;

set distances := 1..(n+1);
param distance_matrix{distances, distances} >= 0;

var X{courier, object} binary; # courier m object n;

var courier_distance{courier} >= 0 integer;
var max_distance >= 0;

minimize obj_max_distance:
    max_distance;


subject to max_courier_distance{i in courier}:
    max_distance >= courier_distance[i];
subject to one_courier_per_item{j in object}:
    sum{i in courier} X[i,j]=1;
subject to load_not_exceed_capacity{i in courier}:
    sum{j in object} X[i,j] * s_values[j] <= l_values[i];
subject to start_end_origin{i in courier}:
    courier_distance[i] = sum{j in object} (X[i, j] * (distance_matrix[n+1, j] + distance_matrix[j, n+1]));