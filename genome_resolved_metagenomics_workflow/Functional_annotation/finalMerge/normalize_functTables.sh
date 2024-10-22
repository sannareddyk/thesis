#!/bin/bash

##norm_factor.txt should be in the same folder

python3 div_KO.py finalKO.txt norm_factor.txt KO_normalized.txt
python3 div_PF.py finalPF.txt norm_factor.txt PF_normalized.txt
python3 div_GO.py finalGO.txt norm_factor.txt GO_normalized.txt
python3 div_Uniref.py finalUniref.txt norm_factor.txt Uniref_normalized.txt
python3 div_dbCAN4.py finaldbCAN4.txt norm_factor.txt dbCAN4_normalized.txt
