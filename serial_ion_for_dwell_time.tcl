source ion_calculator_modified.tcl

set zmax 12.71
set zmin -12.71


ion_translocate nw_mosse_se-se_d15.8_0.8nm_ions nw_mosse_se-se_d15.8_0.8nm_20.0V_1 POT $zmax $zmin ./
ion_translocate nw_mosse_se-se_d15.8_0.8nm_ions nw_mosse_se-se_d15.8_0.8nm_20.0V_1 CLA $zmax $zmin ./
