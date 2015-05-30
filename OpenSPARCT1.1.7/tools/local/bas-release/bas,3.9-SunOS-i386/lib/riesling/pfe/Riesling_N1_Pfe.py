
import Pfe_Shell
import riesling_n1

pfe = 'n1pfe'
Pfe_Shell.options(pfe)
Pfe_Shell.history('.'+pfe)

from Riesling_N1_Model import *
sim = Model(riesling_n1,riesling_n1.Ni_System())
Pfe_Shell.setup(sim)

for arg in Pfe_Shell.args:
  execfile(arg)

hexmode()






