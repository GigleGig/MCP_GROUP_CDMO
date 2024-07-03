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

% Each item must be visited exactly once
constraint forall(i in 2..n+1) (
  sum(k in K) (sum(j in V) (x[k, i, j])) = 1
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

% Subtour elimination constraints
array[K, 2..n+1] of var 1..n: u;
constraint forall(k in K, i in 2..n+1, j in 2..n+1 where i != j) (
  u[k, i] - u[k, j] + n * x[k, i, j] <= n - 1
);

% Prevent staying at the same place
constraint forall(k in K, i in V) (
  x[k, i, i] = 0
);

% Definizione della funzione obiettivo (minimizzazione della distanza totale)
var int: total_distance = sum(k in K, i in V, j in V) (D[i, j] * x[k, i, j]);

% Soluzione iniziale
solve minimize total_distance;

% Parametri per LNS
int: perturbation_size = 3;  % Numero di deliverymen da perturbare

% Algoritmo LNS
repeat {
    % Perturbazione: reset delle assegnazioni per alcuni deliverymen
    array[1..perturbation_size] of int: perturbed_deliverymen = [rand(1..m) | i in 1..perturbation_size];
    array[1..perturbation_size] of var K: new_visited[k];
    array[1..perturbation_size, V] of var 0..1: new_x[k, i, j];

    % Esempio di perturbazione: resettare le assegnazioni di visited e x per i deliverymen selezionati
    constraint forall(k in perturbed_deliverymen) (
        new_visited[k] = [if rand() < 0.5 then 0 else 1 endif | i in V];
        new_x[k, i, j] = [if rand() < 0.5 then 0 else 1 endif | i, j in V];
    );

    % Ricostruzione: ricalcola il modello con le nuove variabili perturbate
    solve minimize total_distance;

    % Se la nuova soluzione è migliore, aggiorna le variabili
    % (nell'esempio semplificato, questo passaggio potrebbe richiedere una gestione più sofisticata)
} until (criterio_di_terminazione);

