import os
import subprocess
import json
import re

# Percorsi delle cartelle e dei file
instances_folder = './CP/Instances'
modelfiles = ['./CP/MCP_no_bounds.mzn']
solutions_folder = './res/CP/MCP_no_bounds/'

# Crea la cartella delle soluzioni se non esiste
if not os.path.exists(solutions_folder):
    os.makedirs(solutions_folder)

# Ottieni la lista di tutti i file .dzn nella cartella delle istanze
instances = [f for f in os.listdir(instances_folder) if f.endswith('.dzn')]

for instance in instances:
    instance_path = os.path.join(instances_folder, instance)
    solution_path_txt = os.path.join(solutions_folder, instance.replace('.dzn', '.txt'))
    solution_path_json = os.path.join(solutions_folder, instance.replace('.dzn', '.json'))
    
    # Dizionario per memorizzare le informazioni JSON
    results = {}
    for model in modelfiles:
        # Comando per risolvere l'istanza con MiniZinc per ogni solver
        for solver in ['gecode', 'chuffed']:
            command = ['minizinc', '--solver', solver, "--output-time", "--solver-time-limit", "300000", model, instance_path]
            
            try:
                # Esegui il comando e cattura l'output
                result = subprocess.run(command, capture_output=True, text=True, check=True)
                
                # Analizza l'output per estrarre le informazioni desiderate
                lines = result.stdout.strip().splitlines()
                total_distance = None
                assignments = []
                routes = []
                tempo = None  # Inizializza tempo
                
                for line in lines:
                    if line.startswith("Distance:"):
                        total_distance = int(line.split(":")[1].strip())
                    elif line.startswith("% time elapsed"):
                        regex = r'\d+\.\d+'
                        match = re.search(regex, line)
                        if match:
                            tempo = match.group(0)
                    elif line.startswith("Deliveryman"):
                        parts = line.split(":")
                        deliveryman = int(parts[0].split()[1])
                        route = json.loads(parts[1])

                        assignments.append((deliveryman, route))

                list_routes = str([lst for _, lst in assignments])
                # Costruisci l'oggetto JSON per il solver corrente
                results[solver] = {
                    "time": tempo,  
                    "optimal": False,  
                    "obj": total_distance,  
                    "sol": list_routes
                }
            
            except subprocess.CalledProcessError as e:
                print(f'Error solving {instance} with {solver}: {e.stderr}')
                results[solver] = {
                    "time": 0.0,
                    "optimal": False,
                    "obj": 0,
                    "sol": []
                }
        
        # Scrivi l'output nel file JSON
        with open(solution_path_json, 'w') as json_file:
            json.dump(results, json_file, indent=2)
        print(f'Solved {instance} and saved the solutions to {solution_path_txt} and {solution_path_json}')