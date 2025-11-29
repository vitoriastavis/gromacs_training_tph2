#!/bin/bash

# Usage: ./run_analysis.sh md_rep1.tpr md_rep1.xtc rep1
if [ $# -ne 3 ]; then
    echo "Usage: $0 <TPR> <XTC> <rep_id (e.g. rep1)>"
    exit 1
fi

TPR=$1
XTC=$2
REP=$3

BASE_DIR=analysis/${REP}
mkdir -p ${BASE_DIR}/rmsd ${BASE_DIR}/rmsf ${BASE_DIR}/dssp ${BASE_DIR}/sasa ${BASE_DIR}/contacts

echo "=== [$REP] RMSD (Backbone) ==="
gmx rms -s $TPR -f $XTC -o ${BASE_DIR}/rmsd/rmsd.xvg -tu ns << EOF
4
4
EOF

echo "=== [$REP] RMSF (Residue flexibility) ==="
gmx rmsf -s $TPR -f $XTC -o ${BASE_DIR}/rmsf/rmsf.xvg -res << EOF
4
EOF

echo "=== [$REP] DSSP (secondary structure) ==="
gmx do_dssp -s $TPR -f $XTC \
    -o ${BASE_DIR}/dssp/ss.xpm \
    -sc ${BASE_DIR}/dssp/summary.xvg

echo "=== [$REP] SASA for residue 441 ==="
echo -e "r 441\nq" | gmx make_ndx -f $TPR -o ${BASE_DIR}/sasa/index_441.ndx
gmx sasa -s $TPR -f $XTC \
    -surface 2 \
    -output 2 \
    -o ${BASE_DIR}/sasa/sasa_441.xvg \
    -ndx ${BASE_DIR}/sasa/index_441.ndx << EOF
2
EOF

echo "=== [$REP] Native contacts / min distance for residue 441 ==="
echo -e "r 441\nq" | gmx make_ndx -f $TPR -o ${BASE_DIR}/contacts/index_441.ndx

# Group 2 = residue 441, group 1 = System (or Protein, depending on your index)
# Here: distance between residue 441 and the rest of the system
gmx mindist -s $TPR -f $XTC \
    -od ${BASE_DIR}/contacts/min_dist_441.xvg \
    -n ${BASE_DIR}/contacts/index_441.ndx << EOF
2
1
EOF

echo "=== [$REP] DONE ==="