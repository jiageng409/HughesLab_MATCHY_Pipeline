#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 19:26:01 2024

@author: jiagengliu
"""

#!/usr/bin/env python3

"""
A script to run the CPM model, given a set of bootstrap-sampled adhesion matrices.

Run from the command-line:

e.g. python run_softstiff.py 72

where 72 defines the bootstrap adhesion matrix that is to be used for parameterising the CPM.

See run_scripts/make_adhesion_matrices.py for details on the bootstraping procedure.
"""
import numpy as np
#from CPM.cpm import CPM
from cpm import CPM
import matplotlib.pyplot as plt
import time
import os
import sys


if __name__ == "__main__":

    #Set up directory architecture.
    if not os.path.exists("../results"):
        os.mkdir("../results")

    if not os.path.exists("../results/plots"):
        os.mkdir("../results/plots")

    if not os.path.exists("../results/stiff"):
        os.mkdir("../results/stiff")

    if not os.path.exists("../results/scrambled"):
        os.mkdir("../results/scrambled")

    if not os.path.exists("../results/plots/stiff"):
        os.mkdir("../results/plots/stiff")

    if not os.path.exists("../results/plots/scrambled"):
        os.mkdir("../results/plots/scrambled")


    Index of the bootstrapped adhesion-matrix. From the command-line.
    iter_i = int(sys.argv[1])

    #Set up the parameters
    A0 = 30
    P0 = 0
    lambda_A = 1
    lambda_P = 0.2
    b_e = -0.5

    # Define the W-matrix. Needed, given the architecture, but actually not used in practice, as is replaced by the
    # bootstrapped adhesion matrices.
    W = np.array([[b_e,b_e,b_e,b_e,b_e,b_e,b_e],
                  [b_e,1.911305,0.494644,0.505116,0.505116,0.505116,0.505116],
                  [b_e,0.494644,2.161360,0.420959,0.505116,0.505116,0.505116],
                  [b_e,0.505116,0.420959,0.529589,0.505116,0.505116,0.505116],
                  [b_e,0.505116,0.420959,0.529589,0.505116,0.505116,0.505116],
                  [b_e,0.505116,0.420959,0.529589,0.505116,0.505116,0.505116],
                  [b_e,0.505116,0.420959,0.529589,0.505116,0.505116,0.505116]])*6.02


    params = {"A0":[A0,A0,A0,A0,A0,A0],
              "P0":[P0,P0,P0,P0,P0,P0],
              "lambda_A":[lambda_A,lambda_A,lambda_A,lambda_A,lambda_A,lambda_A],
              "lambda_P":[lambda_P,lambda_P,lambda_P,lambda_P,lambda_P,lambda_P],
              "W":W,
              "T":15}
    cpm = CPM(params)
    cpm.make_grid(130,130)
    cpm.generate_cells(N_cell_dict={"NPC": 60, "PN": 15,"PTA":15, "RV":15, "BRV": 15, "UE": 30})
    cpm.make_init("circle", np.sqrt(params["A0"][0] / np.pi) * 0.8, np.sqrt(params["A0"][0] / np.pi) * 0.2)

    #Import the bootstrapped adhesion values, derived from the AFM data.
    adhesion_vals_full = np.load("../bootstrap_samples/adhesion_matrices/%i.npz" % iter_i).get("adhesion_vals")
    adhesion_vals_full[0] = b_e*cpm.lambda_P
    adhesion_vals_full[:,0] = b_e*cpm.lambda_P
    adhesion_vals_full[0,0] = 0
    cpm.J = -adhesion_vals_full * 6
    cpm.get_J_diff()
    
    cpm.simulate(int(1e7), int(1000), initialize=True, J0=-8)
    cpm.save_simulation("../results/stiff",str(iter_i))

    #Save the last frame of the CPM simulation as an image.
    fig, ax = plt.subplots()
    ax.imshow(cpm.generate_image(cpm.I, res=8, col_dict={1: "m", 2: "b", 3: "g", 4: "gold", 5: "tab:red", 6: "gray"}))

    ax.axis("off")
    fig.savefig("../results/plots/stiff/%d.pdf"%iter_i,dpi=300)

    cpm.generate_image_t(col_dict={1: "m", 2: "b", 3: "g", 4: "gold", 5: "tab:red", 6: "gray"})
    ax.imshow(cpm.generate_image(cpm.I, res=8, col_dict={1: "m", 2: "b", 3: "g", 4: "gold", 5: "tab:red", 6: "gray"}))
    cpm.animate(file_name=str(iter_i), dir_name="../results/plots/stiff/")

        


    
