from os import system
from multiprocessing import Pool
from pandas import read_csv

# Open the seeds file

seeds = read_csv(r'../Inputs/seeds.csv')


def slim_call(seed):
    system('slim -s {} ~/Desktop/example_script.slim'.format(seed)) 

# Open a new 'pool' - like makeCluster() in R

cluster = Pool()

# Do an operation on the pool - this is like mclapply() in R
if __name__ == "__main__":
    cluster.map(slim_call, seeds['Seed'].tolist())

cluster.close()
cluster.join()

