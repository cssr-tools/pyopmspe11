-- Copyright (C) 2023-2025 NORCE
-- This deck was generated by pyopmspe11 https://github.com/OPM/pyopmspe11
----------------------------------------------------------------------------
RUNSPEC
----------------------------------------------------------------------------
DIMENS 
${dic['noCells'][0]} ${dic['noCells'][1]} ${dic['noCells'][2]} /

EQLDIMS
/

TABDIMS
% if dic['model'] != 'convective':
${dic['noSands']} /
% else:
${dic['noSands']} ${dic['noSands']} /
% endif

WATER
GAS
CO2STORE
% if dic['model'] != 'immiscible':
DISGASW
VAPWAT
% if (dic["diffusion"][0] + dic["diffusion"][1]) > 0:
DIFFUSE
% endif
% endif

METRIC

START
1 JAN 2025 /
% if sum(dic['radius']) > 0:

WELLDIMS
${len(dic['wellijk'])} ${dic['noCells'][2]} ${len(dic['wellijk'])} ${len(dic['wellijk'])} /
% endif

UNIFOUT
----------------------------------------------------------------------------
GRID
----------------------------------------------------------------------------
INIT

% if dic["grid"] == 'corner-point':
INCLUDE
GRID.INC /
% elif dic["grid"] == 'tensor':
INCLUDE
DX.INC /

DY 
${dic['noCells'][0]*dic['noCells'][1]*dic['noCells'][2]}*${dic['ymy'][1]} /

INCLUDE
DZ.INC /

TOPS
${dic['noCells'][0]}*0 /
% else:
DX 
${dic['noCells'][0]*dic['noCells'][1]*dic['noCells'][2]}*${dic['dsize'][0]} /

DY 
${dic['noCells'][0]*dic['noCells'][1]*dic['noCells'][2]}*${dic['dsize'][1]} /

DZ 
${dic['noCells'][0]*dic['noCells'][1]*dic['noCells'][2]}*${dic['dsize'][2]} /

TOPS
${dic['noCells'][0]}*0 /
% endif

INCLUDE
FLUXNUM.INC /
% if dic['model'] != 'immiscible' and sum(dic["dispersion"]) > 0:

DISPERC
${dic['noCells'][0]*dic['noCells'][1]*dic['noCells'][2]}*0 /
% endif

EQUALREG
% for i in range(dic['noSands']):
PORO    ${f"{dic['rock'][i][1]:E}"} ${i+1} F /
% endfor
% for i in range(dic['noSands']):
PERMX   ${f"{dic['rock'][i][0]:E}"} ${i+1} F /
% endfor
% for i in range(dic['noSands']):
PERMY   ${f"{dic['rock'][i][0]:E}"} ${i+1} F /
% endfor
% for i in range(dic['noSands']):
PERMZ   ${f"{dic['rock'][i][0]*dic['kzMult']:E}"} ${i+1} F /
% endfor
% if dic['model'] != 'immiscible' and sum(dic["dispersion"]) > 0:
% for i in range(dic['noSands']):
DISPERC ${f"{dic['dispersion'][i]:E}"} ${i+1} F /
% endfor
% endif
/
% if dic["spe11aBC"] == 0:

BCCON 
1 1 ${dic['noCells'][0]} 1 1 1 1 Z- /
/
% else:
----------------------------------------------------------------------------
EDIT
----------------------------------------------------------------------------
ADD
PORV ${dic["spe11aBC"]} 4* 1 1 /
/
% endif
----------------------------------------------------------------------------
PROPS
----------------------------------------------------------------------------
INCLUDE
TABLES.INC /
% if dic['model'] != 'immiscible':
% if (dic["diffusion"][0] + dic["diffusion"][1]) > 0:

DIFFAWAT
${dic["diffusion"][0]} ${dic["diffusion"][0]} /
% if dic['model'] == 'convective':
% for i in range(dic['noSands']-1):
/
% endfor
% endif

DIFFAGAS
${dic["diffusion"][1]} ${dic["diffusion"][1]} /
% if dic['model'] == 'convective':
% for i in range(dic['noSands']-1):
/
% endfor
% endif
% endif

THCO2MIX
NONE NONE NONE /
% endif
----------------------------------------------------------------------------
REGIONS
----------------------------------------------------------------------------
COPY
FLUXNUM SATNUM /
/

INCLUDE
FIPNUM.INC /
% if dic['model'] == 'convective':

COPY
SATNUM PVTNUM /
/
% endif
----------------------------------------------------------------------------
SOLUTION
---------------------------------------------------------------------------
EQUIL
${dic['dims'][2]-dic['datum']} ${dic['pressure']/1.E5} 0 0 0 0 1 1 0 /

RPTRST
BASIC=2 DEN PCGW ${f"RSWSAT /" if dic['model'] != 'immiscible' else "/"}

RTEMPVD
0   ${dic["temperature"][1]}
${dic['dims'][2]} ${dic["temperature"][0]} /
----------------------------------------------------------------------------
SUMMARY
----------------------------------------------------------------------------
PERFORMA
FGMIP
RGKTR
/
RGKMO
/
RGMDS
/
BWPR
% for sensor in dic["sensorijk"]: 
${sensor[0]+1} ${sensor[1]+1} ${sensor[2]+1} /
% endfor
/
----------------------------------------------------------------------------
SCHEDULE
----------------------------------------------------------------------------
RPTRST
BASIC=2 DEN PCGW RESIDUAL ${f"RSWSAT /" if dic['model'] != 'immiscible' else "/"}
% if dic['model'] == 'convective':

DRSDTCON
% if 'drsdtcon' in dic:
% for row in dic['drsdtcon']:
${str([val for val in row])[1:-1]} /
% endfor
% else:
-1.0 /
0.04 0.34 3.0e-09 ALL /
-1.0 /
-1.0 /
0.04 0.34 3.0e-09 ALL /
-1.0 /
-1.0 /
% endif
/
% endif
% if sum(dic['radius']) > 0:

WELSPECS
% for i in range(len(dic['wellijk'])):
% if dic['radius'][i] > 0:
INJ${i} G1 ${dic['wellijk'][i][0]} ${dic['wellijk'][i][1]} 1* GAS ${dic['radius'][i]} /
% endif
% endfor
/

COMPDAT
% for i in range(len(dic['wellijk'])):
% if dic['radius'][i] > 0:
INJ${i} ${dic['wellijk'][i][0]} ${dic['wellijk'][i][1]} ${dic['wellijk'][i][2]} ${dic['wellijk'][i][2]} OPEN 2* ${2.*dic['radius'][i]} /
% endif
% endfor
/
% endif
% if dic["spe11aBC"] == 0:

BCPROP
1 DIRICHLET WATER 1* ${(dic['pressure']+dic["safu"][0][2])/1.E5} /
/
% endif
% for j in range(len(dic['inj'])):

% if dic["tuning"]:
TUNING
${dic['inj'][j][8]+" " if len(dic['inj'][j])>8 else ""}/
${dic['inj'][j][9]+" " if len(dic['inj'][j])>9 else ""}/
${dic['inj'][j][10]+" " if len(dic['inj'][j])>10 else ""}/
% endif
% if max(dic['radius']) > 0:
WCONINJE
% for i in range(len(dic['wellijk'])):
% if dic['radius'][i] > 0:
% if dic['inj'][j][2+3*i] > 0:
INJ${i} GAS ${'OPEN' if dic['inj'][j][3+3*i] > 0 else 'SHUT'} RATE ${f"{dic['inj'][j][3+3*i] * 86400 / 1.86843:E}"} 1* 480 /
% else:
INJ${i} WATER ${'OPEN' if dic['inj'][j][3+3*i] > 0 else 'SHUT'} RATE ${f"{dic['inj'][j][3+3*i] * 86400 / 998.108:E}"} 1* 480 /
% endif
% endif
% endfor
/
% endif
% if min(dic['radius']) == 0:
SOURCE
% for i in range(len(dic['wellijk'])):
% if dic['radius'][i] == 0:
% if dic['inj'][j][2+3*i] > 0:
${dic['wellijk'][i][0]} ${dic['wellijk'][i][1]} ${dic['wellijk'][i][2]} GAS ${f"{dic['inj'][j][3+3*i] * 86400:E}"} /
% else:
${dic['wellijk'][i][0]} ${dic['wellijk'][i][1]} ${dic['wellijk'][i][2]} WATER ${f"{dic['inj'][j][3+3*i] * 86400:E}"} /
% endif
% endif
% endfor
/
% endif
TSTEP
${f"{round(dic['inj'][j][0]/dic['inj'][j][1])}*" if round(dic['inj'][j][0]/dic['inj'][j][1]) > 1 else ""}${dic['inj'][j][1] / 86400.} /
% endfor