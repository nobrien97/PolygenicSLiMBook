from os import system
from multiprocessing import Pool
from itertools import product
from pandas import read_csv, DataFrame
from joblib import Parallel, delayed

# Open the seeds file as a list

seeds = read_csv(r'../Inputs/seeds.csv')['Seed'].to_list()

# Create a list of parameters and generate unique combinations, then form a list of tuples
# You can also use the pandas.write_csv() function to store this output and read it later like
# we have been doing with seeds

p = {'param1' : [0.1, 0.2, 0.3], 'param2' : ['"Low"', '"Medium"', '"High"']}
keys, values = zip(*p.items())
# https://stackoverflow.com/a/61335465/13586824
combos = [dict(zip(keys, v)) for v in product(*values)]
combos = DataFrame.from_dict(combos)
combos = list(combos.itertuples(index=False, name=None))


# Do an operation on the pool - this is like foreach() in R
# \" is an escaped string, which we need for the command line to be able to feed SLiM string parameters properly

def slim_call(param1, param2):
    for seed in seeds:
        system('slim -s {se} -d param1={p1} -d \"param2=\'{p2}\'\" ~/Desktop/example_script.slim'.format(se=seed, p1=param1, p2=param2)) 

# Open a new 'pool' - like makeCluster() in R

cluster = Pool()

if __name__ == "__main__":
    cluster.starmap(slim_call, combos)
cluster.close()
cluster.join()