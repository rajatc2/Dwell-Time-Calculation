source ion_calculator_modified.tcl

set dcd nw_mosse_se-se_d15.8_0.8nm_20.0V_1.dcd
ion_translocate nw_mosse_se-se_d15.8_0.8nm_ions nw_mosse_se-se_d15.8_0.8nm_20.0V_1 POT ./
ion_translocate nw_mosse_se-se_d15.8_0.8nm_ions nw_mosse_se-se_d15.8_0.8nm_20.0V_1 CLA ./
