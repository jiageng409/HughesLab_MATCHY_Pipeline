#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 19:22:20 2024

@author: jiagengliu
"""

#!/usr/bin/env python3

"""
A script to generate the bootstrap matrices of adhesion strengths, by resampling the AFM measurements of cell-by-cell
adhesion strength (found in raw_data/adhesion_dict.json).
"""

import json
import os

import numpy as np

if __name__ == "__main__":

    # number of bootstrap iterations to be used in the ensemble.
    n_iter = 500
 

    # where the adhesion data is stored. This has been reformatted as a json dictionary.
    adhesion_dict = json.load(open("../raw_data/adhesion_dict.json"))
    

    # number of cells in the CPM simulation. nE is the number of ES, nT the number of TS, and nX the number of XEN.
    nNPC, nPN, nPTA, nRV, nBRV, nUE = 60, 15, 15, 15, 15, 30 

    # Coding between cell-type names and cell_type indices. 0 -> ES, 1 -> TS, 2 -> XEN.
    pair_names = {(0, 0): "NPC-NPC",
                  (1, 1): "PN-PN",
                  (0, 1): "NPC-PN",
                  (1, 0): "NPC-PN",
                  (0, 2): "NPC-PTA",
                  (2, 0): "NPC-PTA",
                  (1, 2): "PN-PTA",
                  (2, 1): "PN-PTA",
                  (2, 2): "PTA-PTA",
                  #new code
                  (3, 3): "RV-RV",
                  (3, 0): "RV-NPC",
                  (0, 3): "RV-NPC",
                  (3, 1): "PN-RV",
                  (1, 3): "PN-RV",
                  (3, 2): "PTA-RV",
                  (2, 3): "PTA-RV",
                  (4, 4): "BRV-BRV",
                  (4, 0): "NPC-BRV",
                  (0, 4): "NPC-BRV",
                  (4, 1): "PN-BRV",
                  (1, 4): "PN-BRV",
                  (4, 2): "PTA-BRV",
                  (2, 4): "PTA-BRV",
                  (4, 3): "RV-BRV",
                  (3, 4): "RV-BRV",
                  (5, 5): "UE-UE",
                  (5, 0): "UE-NPC",
                  (0, 5): "UE-NPC",
                  (5, 1): "UE-PN",
                  (1, 5): "UE-PN",
                  (5, 2): "UE-PTA",
                  (2, 5): "UE-PTA",
                  (5, 3): "UE-RV",
                  (3, 5): "UE-RV",
                  (5, 4): "UE-BRV",
                  (4, 5): "UE-BRV"
                  }


    def sample(pair):
        """
        Given a pair of cell type indices e.g. (0,1), randomly sample the adhesion dictionary once. Ignore nan values.
        :param pair:
        :return:
        """
        val = np.nan
        while np.isnan(val):
            val = np.random.choice(adhesion_dict[pair_names[pair]])
        return val

    
    def get_adhesion_matrix(nNPC, nPN, nPTA, nRV, nBRV, nUE):
        """
        Generate a (nE + nT + nX x nE + nT + nX) matrix of adhesion values by resampling the AFM adhesion data.
        :param nE: number of ES cells in the CPM simulation
        :param nT: number of TS cells in the CPM simulation
        :param nX: number of XEN cells in the CPM simulation
        :return: a (nE + nT + nX x nE + nT + nX) matrix of adhesion values by resampling the AFM adhesion data.
        """
        # number of cells is the sum of the number of cells of each type.
        nc = nNPC + nPN + nPTA + nRV + nBRV + nUE

        # establish a vector cell_types, where the first nE are 0, the next nT are 1, and the final nX are 2.
        c_types = np.zeros((nc), dtype=int)
        c_types[nNPC:nNPC + nPN] = 1
        c_types[nNPC + nPN:nNPC+nPN+nPTA] = 2
        c_types[nNPC+nPN+nPTA:nNPC+nPN+nPTA+nRV] = 3
        c_types[nNPC+nPN+nPTA+nRV:nNPC+nPN+nPTA+nRV+nBRV] = 4
        c_types[nNPC+nPN+nPTA+nRV+nBRV:] = 5

        # Across the nc x nc matrix, randomly sample adhesion values from the AFM data.
        c_type1, c_type2 = np.meshgrid(c_types, c_types, indexing="ij")
        c_type_pairs = list(zip(c_type1.ravel(), c_type2.ravel()))
        adhesion_vals = list(map(sample, c_type_pairs))
        adhesion_vals = np.array(adhesion_vals).reshape((len(c_types), len(c_types)))
        adhesion_vals = np.triu(adhesion_vals, 1) + np.triu(adhesion_vals, 1).T
        return adhesion_vals

    
    
    def get_adhesion_matrix_scrambled(nNPC, nPN, nPTA, nRV, nBRV, nUE):
        """
        Same as *get_adhesion_matrix* apart from scrambles the order of cell-types, making cell-cell adhesion values and
        the cell-types indpendent.
        :param nE: number of ES cells in the CPM simulation
        :param nT: number of TS cells in the CPM simulation
        :param nX: number of XEN cells in the CPM simulation
        :return: a (nE + nT + nX x nE + nT + nX) SCRAMBLED matrix of adhesion values by resampling the AFM adhesion data
        """
        # number of cells is the sum of the number of cells of each type.
        nc = nNPC + nPN + nPTA + nRV + nBRV

        # establish a vector cell_types, where the first nE are 0, the next nT are 1, and the final nX are 2.
        c_types = np.zeros((nc), dtype=int)
        c_types[nNPC:nNPC + nPN] = 1
        c_types[nNPC + nPN:nNPC+nPN+nPTA] = 2
        c_types[nNPC+nPN+nPTA+nRV:nNPC+nPN+nPTA+nRV+nBRV] = 4
        c_types[nNPC+nPN+nPTA+nRV+nBRV:] = 5

        np.random.shuffle(c_types)

        c_type1, c_type2 = np.meshgrid(c_types, c_types, indexing="ij")
        c_type_pairs = list(zip(c_type1.ravel(), c_type2.ravel()))
        adhesion_vals = list(map(sample, c_type_pairs))
        adhesion_vals = np.array(adhesion_vals).reshape((len(c_types), len(c_types)))
        adhesion_vals = np.triu(adhesion_vals, 1) + np.triu(adhesion_vals, 1).T
        return adhesion_vals
    
    

    # Establish directory structure, for saving.
    if not os.path.exists("../bootstrap_samples"):
        os.mkdir("../bootstrap_samples")

    if not os.path.exists("../bootstrap_samples/adhesion_matrices"):
        os.mkdir("../bootstrap_samples/adhesion_matrices")

    if not os.path.exists("../bootstrap_samples/adhesion_matrices_scrambled"):
        os.mkdir("../bootstrap_samples/adhesion_matrices_scrambled")

    # Save adhesion matrices, and the corresponding scrambled ones, to file. In npz compressed format.
    #nc = nE + nT + nX
    nc = nNPC + nPN + nPTA + nRV + nBRV + nUE
    for i in range(n_iter):
        adhesion_vals = get_adhesion_matrix(nNPC, nPN, nPTA, nRV, nBRV, nUE)
        adhesion_vals_full = np.zeros((nc + 1, nc + 1))
        adhesion_vals_full[1:, 1:] = adhesion_vals
        np.savez("../bootstrap_samples/adhesion_matrices/%i.npz" % i, adhesion_vals=adhesion_vals_full)
